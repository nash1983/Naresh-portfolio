#!/bin/bash
# ============================================================
# start_server.sh — ApplicationStart hook
# Starts Nginx to serve the Naresh Portfolio
# ============================================================

set -e

echo "[start_server] Starting Nginx..."

systemctl start nginx

# Give Nginx a moment to fully start
sleep 2

if systemctl is-active --quiet nginx; then
    echo "[start_server] Nginx is running successfully."
else
    echo "[start_server] ERROR: Nginx failed to start!"
    journalctl -u nginx --no-pager -n 20
    exit 1
fi

echo "[start_server] Portfolio is now being served on port 80."
