#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
   echo "This script must be executed with root/sudo privileges."
   echo "Usage: sudo bash ufw_configuration.sh"
   exit 1
fi

if ! command -v ufw >/dev/null 2>&1; then
    apt-get update -qq
    apt-get install -y -qq ufw
fi

ufw --force reset >/dev/null 2>&1

ufw default deny incoming
ufw default allow outgoing
ufw default deny routed

ufw allow 22/tcp comment 'Allow incoming SSH management'
ufw deny 80/tcp comment 'Deny incoming unencrypted HTTP'
ufw allow 443/tcp comment 'Allow incoming secure HTTPS'
ufw limit 22/tcp comment 'Rate-limit SSH connections (mitigate brute-force)'
ufw allow in on lo comment 'Allow all loopback traffic'

ufw --force enable

echo "=== UFW Detailed Status (Verbose) ==="
ufw status verbose

echo "=== UFW Numbered Rule List ==="
ufw status numbered

echo "====================================================="
echo "[SUCCESS] UFW configuration applied successfully!"
echo "====================================================="
echo "Testing Recommendations:"
echo " 1. Verify blocked HTTP traffic:  curl -m 3 http://localhost:80 (Should time out / be rejected)"
echo " 2. Verify allowed SSH traffic:    ssh -p 22 <user>@localhost"
echo " 3. Verify logging status:         sudo ufw status verbose | grep -i logging"
