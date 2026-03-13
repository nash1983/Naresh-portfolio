#!/bin/bash
# ============================================================
# stop_server.sh — BeforeInstall hook
# Stops Nginx gracefully and clears old deployment files
# ============================================================

set -e

echo "[stop_server] Starting pre-deployment cleanup..."

# Stop Nginx if it's running
if systemctl is-active --quiet nginx; then
    echo "[stop_server] Stopping Nginx..."
    systemctl stop nginx
    echo "[stop_server] Nginx stopped."
else
    echo "[stop_server] Nginx was not running, skipping stop."
fi

# Remove old site files (keep the directory itself)
if [ -d /var/www/html ]; then
    echo "[stop_server] Cleaning /var/www/html..."
    rm -rf /var/www/html/*
    echo "[stop_server] Old files removed."
else
    echo "[stop_server] Creating /var/www/html directory..."
    mkdir -p /var/www/html
fi

echo "[stop_server] Pre-deployment cleanup complete."
