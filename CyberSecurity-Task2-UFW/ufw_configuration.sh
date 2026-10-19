#!/usr/bin/env bash
# ==============================================================================
# Script Name   : ufw_configuration.sh
# Track         : OIBSIP Cyber Security - Task 2: Host Firewall Configuration
# Description   : Automates production-grade hardening and rule configuration
#                 for Ubuntu's Uncomplicated Firewall (UFW).
# Author        : Security Analyst Intern
# Safe Execution: Requires root/sudo privileges. Runs in local VM or Linux host.
# ==============================================================================

set -euo pipefail

# ANSI Color Codes for readable output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================================${NC}"
echo -e "${BLUE}    OIBSIP Task 2: UFW Host Firewall Configuration   ${NC}"
echo -e "${BLUE}=====================================================${NC}"

# 1. ROOT PRIVILEGE CHECK
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[ERROR] This script must be executed with root/sudo privileges.${NC}"
   echo "Usage: sudo bash ufw_configuration.sh"
   exit 1
fi

# 2. REMOTE LOCKOUT SAFETY AUDIT
# If running over an active SSH session, warn the user before altering rules.
if [[ -n "${SSH_CONNECTION:-}" || -n "${SSH_CLIENT:-}" || -n "${SSH_TTY:-}" ]]; then
    echo -e "${YELLOW}[WARNING] Active SSH session detected!${NC}"
    echo -e "${YELLOW}Ensuring SSH (Port 22/tcp) is permitted before activating firewall.${NC}"
    echo -e "${YELLOW}Proceeding cautiously to prevent administrative lockout...${NC}"
fi

# 3. VERIFY UFW INSTALLATION
echo -e "\n${BLUE}[STEP 1/6] Verifying UFW installation...${NC}"
if ! command -v ufw >/dev/null 2>&1; then
    echo -e "${YELLOW}UFW not found. Installing via apt...${NC}"
    apt-get update -qq
    apt-get install -y -qq ufw
    echo -e "${GREEN}UFW successfully installed.${NC}"
else
    echo -e "${GREEN}UFW is already installed ($(ufw --version | head -n1)).${NC}"
fi

# 4. RESET EXISTING RULES (Ensuring clean, repeatable baseline)
echo -e "\n${BLUE}[STEP 2/6] Resetting existing rules to baseline defaults...${NC}"
ufw --force reset >/dev/null 2>&1
echo -e "${GREEN}Firewall reset complete.${NC}"

# 5. CONFIGURE DEFAULT POLICIES (Principle of Least Privilege)
echo -e "\n${BLUE}[STEP 3/6] Applying default directional policies...${NC}"
# Inbound: Deny all unsolicited incoming traffic by default
ufw default deny incoming
# Outbound: Allow outbound connections so host can update and communicate
ufw default allow outgoing
# Routed: Deny forwarding unless specifically acting as a router
ufw default deny routed
echo -e "${GREEN}Default policies applied: Default DENY Incoming, Default ALLOW Outgoing.${NC}"

# 6. IMPLEMENT TASK RULES & SENSIBLE CONTROLS
echo -e "\n${BLUE}[STEP 4/6] Adding explicit ingress filtering rules...${NC}"

# Required Rule 1: Allow SSH (Port 22/tcp) with rate-limiting protection
echo "--> [RULE 1] Allowing SSH (Port 22/tcp)..."
ufw allow 22/tcp comment 'Allow incoming SSH management'

# Required Rule 2: Explicitly Deny HTTP (Port 80/tcp)
echo "--> [RULE 2] Explicitly Denying unencrypted HTTP (Port 80/tcp)..."
ufw deny 80/tcp comment 'Deny incoming unencrypted HTTP'

# Additional Sensible Rule 1: Allow HTTPS (Port 443/tcp)
echo "--> [RULE 3 (Additional)] Allowing encrypted HTTPS (Port 443/tcp)..."
ufw allow 443/tcp comment 'Allow incoming secure HTTPS'

# Additional Sensible Rule 2: Rate-limit SSH to mitigate brute-force attacks
echo "--> [RULE 4 (Additional)] Enabling rate-limiting on SSH (Port 22/tcp)..."
ufw limit 22/tcp comment 'Rate-limit SSH connections (mitigate brute-force)'

# Additional Sensible Rule 3: Allow Localhost Loopback Interface Traffic
echo "--> [RULE 5 (Hardening)] Allowing trusted loopback interface traffic..."
ufw allow in on lo comment 'Allow all loopback traffic'

# 7. ENABLE FIREWALL
echo -e "\n${BLUE}[STEP 5/6] Activating and enabling UFW...${NC}"
ufw --force enable
echo -e "${GREEN}UFW is now active and will persist across system reboots.${NC}"

# 8. VERIFICATION AND STATUS AUDIT
echo -e "\n${BLUE}[STEP 6/6] Verifying firewall operational status...${NC}"
echo -e "\n${YELLOW}=== UFW Detailed Status (Verbose) ===${NC}"
ufw status verbose

echo -e "\n${YELLOW}=== UFW Numbered Rule List ===${NC}"
ufw status numbered

echo -e "\n${GREEN}=====================================================${NC}"
echo -e "${GREEN}[SUCCESS] UFW configuration applied successfully!    ${NC}"
echo -e "${GREEN}=====================================================${NC}"
echo -e "Testing Recommendations:"
echo -e " 1. Verify blocked HTTP traffic:  curl -m 3 http://localhost:80 (Should time out / be rejected)"
echo -e " 2. Verify allowed SSH traffic:    ssh -p 22 <user>@localhost"
echo -e " 3. Verify logging status:         sudo ufw status verbose | grep -i logging"
