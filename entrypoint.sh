#!/bin/ash

set -euo pipefail

###############################################
# 1. DETECT EXISTING CONFIGURATION STATE      #
###############################################

# Count existing enabled configurations
INGRESS_COUNT=$(ls /etc/nginx/conf-enabled/ingress-*.conf 2>/dev/null | wc -l || true)
EGRESS_COUNT=$(ls /etc/nginx/conf-enabled/egress-*.conf 2>/dev/null | wc -l || true)
MAIL_COUNT=$(ls /etc/nginx/conf-enabled/mail-*.conf 2>/dev/null | wc -l || true)

OTHER_COUNT=$(ls /etc/nginx/conf-enabled/*.conf 2>/dev/null | grep -vE 'ingress-|egress-|mail-' | wc -l || true)

# Detect mixed ingress + egress/mail (invalid state)
if [ "$INGRESS_COUNT" -gt 0 ] && { [ "$EGRESS_COUNT" -gt 0 ] || [ "$MAIL_COUNT" -gt 0 ]; }; then
    echo "[ERROR] Mixed ingress-* and egress-*/mail-* configuration files detected in /etc/nginx/conf-enabled/"
    echo "[INFO] This container supports only one mode at a time."
    exit 1
fi

# Warn about unknown configuration files
if [ "$OTHER_COUNT" -gt 0 ]; then
    echo "[WARN] Detected configuration files that do not follow ingress-*, egress-* or mail-* naming."
    echo "[WARN] These files will be loaded by NGINX, but the container cannot classify them."
    echo "[WARN] Files:"
    ls /etc/nginx/conf-enabled/*.conf | grep -vE 'ingress-|egress-|mail-' || true
fi

#####################################################
# 2. APPLY ENVIRONMENT VARIABLES (LINK BASE FILES)  #
#####################################################

# Ingress HTTP mode
if [ "${INGRESS_HTTP_ENABLED:-false}" = "true" ]; then
    echo "[INFO] Enabling ingress HTTP mode"
    ln -sf /etc/nginx/conf-available/ingress-http.conf /etc/nginx/conf-enabled/ingress-http.conf
fi

# Ingress STREAM mode
if [ "${INGRESS_STREAM_ENABLED:-false}" = "true" ]; then
    echo "[INFO] Enabling ingress STREAM mode"
    ln -sf /etc/nginx/conf-available/ingress-stream.conf /etc/nginx/conf-enabled/ingress-stream.conf
fi

# Egress HTTP mode
if [ "${EGRESS_HTTP_ENABLED:-false}" = "true" ]; then
    echo "[INFO] Enabling egress HTTP mode"
    ln -sf /etc/nginx/conf-available/egress-http.conf /etc/nginx/conf-enabled/egress-http.conf
fi

# Egress STREAM mode
if [ "${EGRESS_STREAM_ENABLED:-false}" = "true" ]; then
    echo "[INFO] Enabling egress STREAM mode"
    ln -sf /etc/nginx/conf-available/egress-stream.conf /etc/nginx/conf-enabled/egress-stream.conf
fi

# Egress MAIL mode
if [ "${EGRESS_MAIL_ENABLED:-false}" = "true" ]; then
    echo "[INFO] Enabling egress MAIL mode"
    ln -sf /etc/nginx/conf-available/egress-mail.conf /etc/nginx/conf-enabled/mail-egress.conf
fi

###############################################################
# 3. REVALIDATE STATE AFTER APPLYING ENVIRONMENT VARIABLES    #
###############################################################

# Recount after linking
INGRESS_COUNT=$(ls /etc/nginx/conf-enabled/ingress-*.conf 2>/dev/null | wc -l || true)
EGRESS_COUNT=$(ls /etc/nginx/conf-enabled/egress-*.conf 2>/dev/null | wc -l || true)
MAIL_COUNT=$(ls /etc/nginx/conf-enabled/mail-*.conf 2>/dev/null | wc -l || true)

# Mixed mode after env vars → invalid
if [ "$INGRESS_COUNT" -gt 0 ] && { [ "$EGRESS_COUNT" -gt 0 ] || [ "$MAIL_COUNT" -gt 0 ]; }; then
    echo "[ERROR] Ingress and Egress/Mail configurations active at the same time."
    echo "[INFO] Please enable only one mode."
    exit 1
fi

###############################################################
# 4. VALIDATE REQUIRED SUBDIRECTORIES (http.d / stream.d / mail.d)
###############################################################

# Ingress mode validation
if [ "$INGRESS_COUNT" -gt 0 ]; then
    if ! ls /etc/nginx/conf-enabled/ingress/http.d/*.conf 1>/dev/null 2>&1 &&
       ! ls /etc/nginx/conf-enabled/ingress/stream.d/*.conf 1>/dev/null 2>&1; then
        echo "[ERROR] Ingress mode enabled but no http.d/ or stream.d/ configuration files found."
        exit 1
    fi
fi

# Egress mode validation (HTTP/STREAM/MAIL)
if [ "$EGRESS_COUNT" -gt 0 ] || [ "$MAIL_COUNT" -gt 0 ]; then
    if ! ls /etc/nginx/conf-enabled/egress/http.d/*.conf 1>/dev/null 2>&1 &&
       ! ls /etc/nginx/conf-enabled/egress/stream.d/*.conf 1>/dev/null 2>&1 &&
       ! ls /etc/nginx/conf-enabled/egress/mail.d/*.conf 1>/dev/null 2>&1; then
        echo "[ERROR] Egress mode enabled but no http.d/, stream.d/, or mail.d/ configuration files found."
        exit 1
    fi
fi

###############################################################
# 5. ENSURE AT LEAST ONE CONFIGURATION FILE IS ENABLED        #
###############################################################

if ! ls /etc/nginx/conf-enabled/*.conf 1> /dev/null 2>&1; then
    echo "[ERROR] No configuration files found in /etc/nginx/conf-enabled/"
    echo "[INFO] Please enable at least one mode or mount your own configuration."
    exit 1
fi

###############################################################
# 6. TEST AND START NGINX                                      #
###############################################################

echo "[INFO] NGINX version: $(nginx -v 2>&1)"
echo "[INFO] Running configuration test..."

if ! nginx -T; then
    echo "[ERROR] NGINX configuration test failed"
    exit 1
fi

echo "[INFO] Configuration OK — starting NGINX"
exec nginx -g 'daemon off;'
