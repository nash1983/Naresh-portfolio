#!/bin/bash
# ============================================================
# validate_service.sh — ValidateService hook
# Confirms Nginx is running and serving the portfolio
# ============================================================

set -e

echo "[validate] Running service validation..."

# Check Nginx process is active
if ! systemctl is-active --quiet nginx; then
    echo "[validate] FAIL: Nginx is NOT running!"
    exit 1
fi
echo "[validate] PASS: Nginx process is active."

# Check HTTP response on localhost returns 200
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/)
if [ "$HTTP_CODE" != "200" ]; then
    echo "[validate] FAIL: Expected HTTP 200 but got HTTP $HTTP_CODE"
    exit 1
fi
echo "[validate] PASS: HTTP 200 response received from localhost."

# Check index.html exists
if [ ! -f /var/www/html/index.html ]; then
    echo "[validate] FAIL: index.html not found in /var/www/html!"
    exit 1
fi
echo "[validate] PASS: index.html present in /var/www/html."

echo "[validate] All validation checks passed! Naresh Portfolio is live."
