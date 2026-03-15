#!/bin/bash
# ============================================================
# set_permissions.sh — AfterInstall hook
# Installs Nginx if needed, sets correct file permissions
# ============================================================

set -e

echo "[set_permissions] Running post-install setup..."

# Install Nginx if not already installed
if ! command -v nginx &> /dev/null; then
    echo "[set_permissions] Installing Nginx..."
    if command -v yum &> /dev/null; then
        # Amazon Linux / RHEL
        yum install -y nginx
    elif command -v apt-get &> /dev/null; then
        # Ubuntu / Debian
        apt-get update -y
        apt-get install -y nginx
    fi
    echo "[set_permissions] Nginx installed."
else
    echo "[set_permissions] Nginx already installed."
fi

# Ensure Nginx is enabled to start on boot
systemctl enable nginx

# Write a clean Nginx config optimised for a single-page static portfolio
cat > /etc/nginx/conf.d/portfolio.conf << 'NGINXCONF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html;

    server_name _;

    # Serve all static assets directly
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets for 7 days
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 7d;
        add_header Cache-Control "public, no-transform";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/javascript image/svg+xml;
    gzip_min_length 1000;
}
NGINXCONF

# Remove default Nginx welcome page config (Amazon Linux path)
if [ -f /etc/nginx/sites-enabled/default ]; then
    rm -f /etc/nginx/sites-enabled/default
fi

# Set correct file ownership and permissions
echo "[set_permissions] Setting file permissions..."
chown -R nginx:nginx /var/www/html 2>/dev/null || chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Verify Nginx config is valid
echo "[set_permissions] Testing Nginx configuration..."
nginx -t

echo "[set_permissions] Post-install setup complete."
