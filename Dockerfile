FROM nginx:1.27.4-alpine-slim

# Install required packages (minimal)
RUN apk add --no-cache curl && apk upgrade --no-cache

# Remove default HTML files
RUN rm -rf /usr/share/nginx/html/*

# Copy entrypoint and set correct permissions
COPY entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh && \
    chown nginx:nginx /entrypoint.sh

# Create directories for NGINX configs available and set ownership
RUN mkdir -p /etc/nginx/conf-available/http.d && \
    mkdir -p /etc/nginx/conf-available/stream.d && \
    chown -R nginx:nginx /etc/nginx/conf-available

# Create directories for NGINX configs enabled and set ownership
RUN mkdir -p /etc/nginx/conf-enabled/http.d/ingress && \
    mkdir -p /etc/nginx/conf-enabled/stream.d && \
    chown -R nginx:nginx /etc/nginx/conf-enabled

# Copy base and additional NGINX configuration files
COPY nginx.conf /etc/nginx/nginx.conf
COPY http.conf /etc/nginx/conf-available/http.conf
COPY stream.conf /etc/nginx/conf-available/stream.conf
COPY templates/ingress/ingress.conf /etc/nginx/conf-available/http.d/ingress.d/ingress.conf
COPY templates/ingress/ingress.ssl.conf /etc/nginx/conf-available/http.d/ingress.d/ingress.ssl.conf
COPY templates/stream/server.conf /etc/nginx/conf-available/stream.d/server.conf

# Optional: leave /usr/share/nginx/html owned by nginx, but writeable externally via volume
RUN mkdir -p /usr/share/nginx/html && \
    chown -R nginx:nginx /usr/share/nginx/html

# Prepare log files and ownership
RUN touch /var/log/nginx/error.log && \
    chown -R nginx:nginx /var/log/nginx/

# Prepare NGINX runtime dirs and certs
RUN mkdir -p /var/cache/nginx /usr/share/nginx/certs && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/cache/nginx /var/run/nginx.pid /etc/nginx /usr/share/nginx/certs

# Set user (non-root)
USER nginx

# Entrypoint
ENTRYPOINT [ "/entrypoint.sh" ]
