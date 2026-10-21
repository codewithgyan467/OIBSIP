# Task 2: Firewall Configuration with UFW

**Author**: Gyandeep Duwarah  
**Environment**: Ubuntu Linux (WSL2 / VM)  
**Tool**: Uncomplicated Firewall (UFW)

---

## Overview
This task configures a host-based firewall using UFW on Linux to restrict unauthorized inbound traffic while permitting required management and secure web services.

## Policy & Rules

1. **Default Policies**:
   - Inbound: `deny` (block all unsolicited incoming traffic)
   - Outbound: `allow` (allow system updates and outbound traffic)
   - Routed: `deny`

2. **Configured Rules**:
   - `ufw allow 22/tcp` — Allow SSH incoming
   - `ufw limit 22/tcp` — Rate-limit SSH to mitigate brute-force attempts
   - `ufw deny 80/tcp` — Explicitly block unencrypted HTTP
   - `ufw allow 443/tcp` — Allow secure HTTPS traffic
   - `ufw allow in on lo` — Allow local loopback traffic

## How to Run

Make the script executable and run with sudo:
```bash
sudo chmod +x ufw_configuration.sh
sudo bash ufw_configuration.sh
```

## Verification

Check status and rule numbers:
```bash
sudo ufw status verbose
sudo ufw status numbered
```

## Screenshots

Evidence is stored in [`screenshots/`](./screenshots/):
- `01_ufw_script_execution.png` — Automated script execution and rule application
- `02_ufw_status_verbose.png` — Verbose status output
- `03_ufw_status_numbered.png` — Numbered rule list
- `04_ufw_blocked_traffic_test.png` — Verification of blocked HTTP traffic
