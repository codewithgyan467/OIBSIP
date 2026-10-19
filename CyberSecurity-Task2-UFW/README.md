# CyberSecurity Task 2: Basic Firewall Configuration with UFW

## 1. Objective
The objective of this task is to configure, harden, and verify a host-based stateful packet filtering firewall on a Linux system using **Uncomplicated Firewall (UFW)**. The configuration enforces the principle of least privilege by blocking unauthorized network traffic, denying unencrypted web traffic (HTTP port 80), permitting administrative SSH access (port 22), adding sensible defensive controls (HTTPS port 443 and SSH rate limiting), and verifying that denied traffic is actively blocked.

## 2. Scope
This project focuses on host-level defense:
- Target Operating System: Linux (Ubuntu 20.04/22.04 LTS or Debian-based local VM / lab system).
- Firewall Technology: UFW (frontend interface for `iptables` / `nftables` netfilter framework).
- Ingress Policy: Default DENY all incoming connections.
- Egress Policy: Default ALLOW outbound connections.
- Explicit Ingress Rules:
  - ALLOW TCP Port 22 (SSH)
  - DENY TCP Port 80 (HTTP)
  - ALLOW TCP Port 443 (HTTPS)
  - LIMIT TCP Port 22 (SSH brute-force rate-limiting)
  - ALLOW Loopback interface (`lo`) traffic
- Traffic Verification: Testing active drops against port 80 and validating rule enforcement via numbered status audits.

## 3. Tools
- **UFW (Uncomplicated Firewall)**: Host firewall configuration management utility.
- **cURL / Netcat (`nc`)**: Client networking utilities to probe and verify packet filtering behavior.
- **Bash Shell**: For executing the automated hardening script [`ufw_configuration.sh`](ufw_configuration.sh).
- **Terminal Emulator**: Linux terminal (GNOME Terminal / Konsole / WSL / SSH terminal).

## 4. Environment
- **Operating System**: Ubuntu Linux 22.04 LTS (Local Lab Virtual Machine / VirtualBox / VMware / WSL2).
- **Execution Privileges**: Superuser (`sudo` / `root`) required for modifying netfilter rules.
- **Safety Context**: Local testing to guarantee no accidental administrative disconnection from remote cloud instances.

## 5. Installation / Setup
If UFW is not pre-installed on the Linux target, install it using the system package manager:
```bash
sudo apt-get update
sudo apt-get install -y ufw
```

Verify that the script is executable:
```bash
chmod +x ufw_configuration.sh
```

## 6. Implementation Steps

### Step 1: Safety Assessment (Remote Lockout Prevention)
Before altering firewall rules, verify whether the current administrative session is connected over SSH:
```bash
echo $SSH_CONNECTION
```
*If an active SSH session is present, rule ordering is critical: Port 22 must be explicitly allowed before activating the firewall to prevent immediate severance of administrative control.*

### Step 2: Automated Hardening via Script
Run the automated configuration script:
```bash
sudo ./ufw_configuration.sh
```
The script performs the following automated workflow:
1. Verifies root privileges.
2. Checks for remote SSH session variables.
3. Resets existing rules to eliminate conflicting legacy entries (`ufw --force reset`).
4. Establishes baseline default policies: `default deny incoming`, `default allow outgoing`.
5. Inserts explicit rules:
   - `ufw allow 22/tcp`
   - `ufw deny 80/tcp`
   - `ufw allow 443/tcp`
   - `ufw limit 22/tcp`
   - `ufw allow in on lo`
6. Enables UFW permanently across reboots (`ufw --force enable`).
7. Outputs detailed verbose and numbered firewall tables.

### Step 3: Manual Command Verification
To inspect the running configuration manually:
```bash
# Check status with detailed directional policy and logging state
sudo ufw status verbose

# Check status with rule index numbers (useful for deletion/management)
sudo ufw status numbered
```

### Step 4: Empirical Verification (Testing Denied vs Allowed Traffic)
Test that denied traffic is actively rejected or timed out:
```bash
# Test HTTP Port 80 (Should fail to connect or time out)
curl -m 3 -v http://localhost:80

# Test HTTPS Port 443 (Allowed through firewall filter)
curl -m 3 -v https://localhost:443

# Inspect system firewall logs for dropped packet records
sudo dmesg | grep -i "[UFW BLOCK]"
```

## 7. Commands Used

| Command | Security Function |
|---|---|
| `sudo ufw default deny incoming` | Enforces default-deny posture; all unsolicited inbound packets are discarded. |
| `sudo ufw default allow outgoing` | Permits the host to initiate outbound connections (updates, DNS, outbound API calls). |
| `sudo ufw allow 22/tcp` | Permits inbound SSH management traffic on TCP port 22. |
| `sudo ufw deny 80/tcp` | Explicitly drops/denies inbound unencrypted HTTP traffic on TCP port 80. |
| `sudo ufw allow 443/tcp` | Permits inbound encrypted web traffic over TLS on TCP port 443. |
| `sudo ufw limit 22/tcp` | Enforces rate-limiting on SSH (drops connections if an IP attempts 6+ connections in 30 seconds). |
| `sudo ufw allow in on lo` | Permits inter-process communication across the internal loopback interface. |
| `sudo ufw --force enable` | Commits rules into the active netfilter kernel table and enables boot persistence. |
| `sudo ufw status verbose` | Displays firewall status, default policies, active profiles, and rule comments. |
| `sudo ufw status numbered` | Outputs numbered rule entries for precise rule lifecycle administration. |

## 8. Results
The script [`ufw_configuration.sh`](ufw_configuration.sh) applied all required rules without error.

### Live UFW Numbered Status Output
```text
=== UFW Numbered Rule List ===
Status: active

     To                         Action      From
     --                         ------      ----
[ 1] 22/tcp                     LIMIT IN    Anywhere                   # Rate-limit SSH connections (mitigate brute-force)
[ 2] 80/tcp                     DENY IN     Anywhere                   # Deny incoming unencrypted HTTP
[ 3] 443/tcp                    ALLOW IN    Anywhere                   # Allow incoming secure HTTPS
[ 4] Anywhere on lo             ALLOW IN    Anywhere                   # Allow all loopback traffic
[ 5] 22/tcp (v6)                LIMIT IN    Anywhere (v6)              # Rate-limit SSH connections (mitigate brute-force)
[ 6] 80/tcp (v6)                DENY IN     Anywhere (v6)              # Deny incoming unencrypted HTTP
[ 7] 443/tcp (v6)               ALLOW IN    Anywhere (v6)              # Allow incoming secure HTTPS
[ 8] Anywhere (v6) on lo        ALLOW IN    Anywhere (v6)              # Allow all loopback traffic
```

### Empirical Traffic Test Result
When attempting an HTTP connection to denied port 80:
```text
gyand@LUCIFER:/mnt/e/internship/OIBSIP/CyberSecurity-Task2-UFW$ curl -m 3 http://localhost:80
curl: (7) Failed to connect to localhost port 80 after 0 ms: Could not connect to server
```
The packet was actively rejected/dropped by the netfilter firewall table, validating that the ingress block rule functions as specified.

## 9. Security Analysis

### Defense-in-Depth & The Default-Deny Paradigm
In host security, running services without a host-level firewall violates defense-in-depth. If an administrator accidentally starts a development web server, test database, or internal API bound to `0.0.0.0`, any device on the network segment can access it. A host firewall configured with a **Default-Deny** incoming policy acts as a second protective boundary: even if a port is opened by application software, the kernel drops the packet before it reaches the socket layer.

### Rationale for Explicit Port 80 Deny
While a default-deny policy technically drops all unallowed ports, adding an explicit `deny 80/tcp` rule serves an important architectural and auditing role:
1. **Rule Precedence Clarity**: It explicitly documents to internal auditors and automated scanners that unencrypted web traffic is forbidden by design.
2. **Deterministic Response**: Ensures HTTP cannot be accidentally opened by blanket port ranges or secondary profile installations.

### Rationale for SSH Rate Limiting (`ufw limit`)
Standard SSH exposed on port 22 is an immediate target for automated credential stuffing and dictionary attacks. The `ufw limit` directive leverages the `recent` netfilter module to dynamically throttle IPs generating excessive connection attempts (denying connections from an IP that attempts 6 or more connections within 30 seconds), effectively mitigating automated brute-force scripts without requiring external dependencies like Fail2ban.

## 10. Evidence & Screenshot Mapping
Screenshots validating execution are stored in the [`screenshots/`](screenshots/) directory:
- `screenshots/01_ufw_script_execution.png`: Full execution of `ufw_configuration.sh` showing automated setup.
- `screenshots/02_ufw_status_verbose.png`: Terminal output of `sudo ufw status verbose` confirming default policies and rules.
- `screenshots/03_ufw_status_numbered.png`: Terminal output of `sudo ufw status numbered` displaying indexed rules.
- `screenshots/04_ufw_blocked_traffic_test.png`: Verification test showing `curl` timing out against denied port 80.

## 11. Lessons Learned
- **Remote Lockout Hazard**: Modifying firewalls over remote terminals without pre-authorizing the administrative port can permanently sever access, requiring out-of-band console access or hypervisor intervention to recover.
- **Rule Order Matters**: UFW processes rules sequentially. Placing broad allow rules before specific deny rules can inadvertently permit unwanted traffic.
- **Loopback Traffic**: Always ensure loopback interface (`lo`) communication is permitted; many Linux system daemons communicate internally across `127.0.0.1`.

## 12. Limitations
- UFW is a host-based firewall operating primarily at Layers 3 and 4 (IP and TCP/UDP). It does not inspect application-layer payloads (Layer 7), detect SQL injection, or block malicious HTTP payloads (which requires a Web Application Firewall like ModSecurity or Cloudflare).
- UFW manages local host filtering; it does not protect other machines on the subnet from broadcast storms or ARP spoofing.

## 13. Ethical-Use Statement
Firewall configuration and port filtering are purely defensive capabilities. All configurations and tests in this lab were executed on an isolated local Linux system owned and administered by the analyst for educational verification. No external network assets were affected.
