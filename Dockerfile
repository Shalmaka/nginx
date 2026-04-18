FROM nginx:1.27.4-alpine-slim

# Install minimal required packages
RUN apk add --no-cache curl && apk upgrade --no-cache

# Remove default NGINX HTML assets
RUN rm -rf /usr/share/nginx/html/*

# Copy entrypoint and set permissions
COPY entrypoint.sh /entrypoint.sh
RUN chmod 700 /entrypoint.sh && \
    chown nginx:nginx /entrypoint.sh

# Create configuration directories
RUN mkdir -p /etc/nginx/conf-available && \
    mkdir -p /etc/nginx/conf-enabled/ingress/http.d && \
    mkdir -p /etc/nginx/conf-enabled/ingress/stream.d && \
    mkdir -p /etc/nginx/conf-enabled/egress/http.d && \
    mkdir -p /etc/nginx/conf-enabled/egress/stream.d && \
    mkdir -p /etc/nginx/conf-enabled/egress/mail.d && \
    mkdir -p /etc/nginx/templates

# Copy base configuration files
COPY nginx.conf /etc/nginx/nginx.conf
COPY ingress-*.conf /etc/nginx/conf-available/
COPY egress-*.conf /etc/nginx/conf-available/
COPY templates/* /etc/nginx/templates/

# Create runtime directories (actual permissions will be overridden by tmpfs if used)
RUN mkdir -p /usr/share/nginx/html && \
    mkdir -p /var/cache/nginx && \
    mkdir -p /var/log/nginx && \
    mkdir -p /var/run && \
    mkdir -p /usr/share/nginx/certs && \
    touch /var/log/nginx/error.log && \
    touch /var/run/nginx.pid

# Ensure runtime directories are writable when not using read-only mode
RUN chown -R nginx:nginx \
    /etc/nginx/conf-enabled \
    /var/cache/nginx \
    /var/log/nginx \
    /var/run \
    /usr/share/nginx/certs

# Run container as non-root user
USER nginx

# Entrypoint script
ENTRYPOINT [ "/entrypoint.sh" ]
