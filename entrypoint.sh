#!/bin/ash

set -euo pipefail

# Check which configuration are enabled and link the appropriate files
if [ "${INGRESS_ENABLED:-false}" = "true" ]; then
  # Link the ingress configuration files
  echo "[INFO] Ingress enabled, linking http configuration files"
  ln -sf /etc/nginx/conf-available/http.conf /etc/nginx/conf-enabled/http.conf

  # Check if the any ingress configuration files exist in conf-enabled/http.d/ingress.d directory
  if ! ls /etc/nginx/conf-enabled/http.d/ingress.d/*.conf 1> /dev/null 2>&1; then
    echo "[ERROR] No ingress configuration files found in /etc/nginx/conf-enabled/http.d/ingress.d/"
    echo "[INFO] Please ensure that you have placed your ingress configuration files in this directory."
    echo "[INFO] Example ingress configuration files can be found in /etc/nginx/conf-available/http.d/ingress.d/"
    exit 1
  fi
fi

  # if [ "${HTTP_ENABLED:-false}" = "true" ]; then
  #     ln -sf /etc/nginx/conf-available/http/http.conf /etc/nginx/conf-enabled/http.conf
  # fi

  # if [ "${PROXY_ENABLED:-false}" = "true" ]; then
  #     ln -sf /etc/nginx/conf-available/proxy/proxy.conf /etc/nginx/conf-enabled/proxy.conf
  # fi

  # if [ "${SMTP_ENABLED:-false}" = "true" ]; then
  #     ln -sf /etc/nginx/conf-available/smtp/smtp.conf /etc/nginx/conf-enabled/smtp.conf
  # fi

if [ "${STREAM_ENABLED:-false}" = "true" ]; then
  # Link the stream configuration files
  echo "[INFO] Stream enabled, linking stream configuration files"
  ln -sf /etc/nginx/conf-available/stream.conf /etc/nginx/conf-enabled/stream.conf

  # Check if the any stream configuration files exist in conf-enabled/stream.d directory
  if ! ls /etc/nginx/conf-enabled/stream.d/*.conf 1> /dev/null 2>&1; then
    echo "[ERROR] No stream configuration files found in /etc/nginx/conf-enabled/stream.d/"
    echo "[INFO] Please ensure that you have placed your stream configuration files in this directory."
    echo "[INFO] Example stream configuration files can be found in /etc/nginx/conf-available/stream.d/ or via github/shalmaka/nginx/tree/main/templates/stream/"
    exit 1
  fi
fi

# Check if thre are any configuration files in /etc/nginx/conf-enabled/
if ! ls /etc/nginx/conf-enabled/*.conf 1> /dev/null 2>&1; then
    echo "[ERROR] No configuration files found in /etc/nginx/conf-enabled/"
    echo "[INFO] Please ensure you have enabled at least one configuration file by setting the appropriate environment variable."
    exit 1
fi

# Print the NGINX configuration files that will be used
echo "[INFO] NGINX started with the following configuration:"
echo "[INFO] NGINX version: $(nginx -v 2>&1)"

# Check if the NGINX configuration is valid
echo "[INFO] NGINX configuration test:"
if ! nginx -T; then
    echo "[ERROR] NGINX configuration test failed"
    exit 1
fi
echo "[INFO] NGINX configuration test passed"

# Start NGINX in the foreground
echo "[INFO] Starting NGINX in the foreground"
exec nginx -g 'daemon off;'
# vim: set ft=sh ts=2 sw=2 et: