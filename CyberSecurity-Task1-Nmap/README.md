# CyberSecurity Task 1: Basic Network Scanning with Nmap

## 1. Objective
The objective of this task is to perform ethical network discovery, port enumeration, service identification, and operating system detection against an authorized local lab target using **Nmap (Network Mapper)**. The exercise establishes foundational skills in attack surface reconnaissance, mapping discovered network ports to their underlying services, evaluating security exposure, and adhering to strict ethical scanning boundaries.

## 2. Scope
- **Authorized Target**: Localhost loopback interface (`127.0.0.1`) and local laboratory Virtual Machine (Ubuntu Linux on isolated private host-only network `192.168.x.x` / `10.0.2.x`).
- **Scanning Types**:
  1. Default TCP Port Discovery (`nmap TARGET_IP`)
  2. Service and Version Detection (`nmap -sV TARGET_IP`)
  3. Operating System Fingerprinting (`sudo nmap -O TARGET_IP`)
- **Ethical Boundary**: Under no circumstances are public IPs, educational institutions, cloud environments, or external systems scanned. All operations are confined to locally owned, authorized hardware.

## 3. Tools
- **Nmap (Network Mapper)**: Open-source network exploration tool and security scanner.
- **Terminal Environment**: Linux Terminal (Ubuntu/Kali) or Windows PowerShell.
- **Local Target**: Ubuntu Linux VM running typical network daemons (SSH, Web Server, RPC).

## 4. Environment
- **Host OS**: Windows 11 Workstation.
- **Lab Target**: Ubuntu Linux 22.04 LTS (Local VM / Host Loopback).
- **Network Interface**: Host-Only Private Subnet / Local Loopback (`127.0.0.1`).

## 5. Installation / Setup

### Installing on Linux (Ubuntu / Debian / Kali)
```bash
sudo apt-get update
sudo apt-get install -y nmap
nmap --version
```

### Installing on Windows
1. Download the official installer from [https://nmap.org/download.html](https://nmap.org/download.html).
2. Run `nmap-setup.exe` and ensure the Npcap packet capture driver is selected.
3. Open PowerShell and verify:
```powershell
nmap --version
```

---

## 6. Implementation Steps

### Step 1: Pre-Scan Conceptual Verification
Before initiating active network probing, the analyst must understand the following network primitives:
- **IP Address**: Logical Layer 3 address identifying a network node.
- **Port**: 16-bit Layer 4 abstraction (0–65535) routing packets to specific application processes.
- **TCP vs. UDP**: TCP provides connection-oriented, reliable transmission via a 3-way handshake (`SYN` -> `SYN-ACK` -> `ACK`); UDP is lightweight, connectionless, and unacknowledged.
- **Socket States**:
  - `Open`: Target actively accepts connections; an application daemon is listening.
  - `Closed`: Port is accessible (packet received), but no service is listening (responds with TCP `RST`).
  - `Filtered`: A firewall, packet filter, or router prevents probe packets from reaching the port (no response or ICMP unreachable error).
- **Attack Surface**: The total sum of reachable interfaces, open ports, and running daemons exposed to potential adversaries.

### Step 2: Basic Host and Port Discovery
Initiate a standard scan against the authorized target to discover open TCP ports within the default top 1,000 port list:
```bash
nmap 127.0.0.1
```

### Step 3: Service and Version Detection
Interrogate open ports using application-level protocol probes to determine exact service names and software version numbers:
```bash
nmap -sV 127.0.0.1
```

### Step 4: Operating System Detection (Privileged)
Analyze TCP/IP stack implementation quirks (window size, TCP options, IP ID generation) using privileged raw socket probes to identify the remote OS:
```bash
sudo nmap -O 127.0.0.1
```

### Step 5: Save Results
Direct all terminal findings into a persistent evidentiary record:
```bash
nmap -sV -O 127.0.0.1 -oN nmap_scan_results.txt
```

---

## 7. Commands Used

| Command | Syntax / Flags | Purpose |
|---|---|---|
| Basic Port Scan | `nmap <target>` | Scans the top 1,000 most common TCP ports using standard TCP connect/SYN scans. |
| Service Version Detection | `nmap -sV <target>` | Connects to open ports and probes banners to determine software versions. |
| OS Fingerprinting | `sudo nmap -O <target>` | Sends crafted TCP/UDP packets and analyzes response nuances to deduce OS family and kernel version. |
| Verbose Output | `nmap -v <target>` | Increases output verbosity, displaying open ports in real time as they are identified. |
| Save to Plain Text | `-oN <filename>` | Exports scan output to an organized human-readable text file. |

---

## 8. Results
The scan results against the local authorized lab environment are cataloged in [`nmap_scan_results.txt`](nmap_scan_results.txt).

### Raw Scan Output Summary
```text
PORT     STATE SERVICE VERSION
22/tcp   open  ssh     OpenSSH 8.9p1 Ubuntu 3ubuntu0.6 (Ubuntu Linux; protocol 2.0)
80/tcp   open  http    Apache httpd 2.4.52 ((Ubuntu))
443/tcp  open  ssl/http Apache httpd 2.4.52 ((Ubuntu))
3306/tcp open  mysql   MySQL 8.0.36-0ubuntu0.22.04.1
```

---

## 9. Security Analysis of Discovered Services

Every open port expands the target's attack surface. Below is a comprehensive defensive risk analysis for each discovered service:

### 1. Port 22/tcp — OpenSSH 8.9p1
- **Service Purpose**: Secure Shell (SSH) provides encrypted remote administrative command-line access and secure file transfer (SFTP/SCP).
- **Potential Security Exposure**:
  - **Credential Brute-Forcing**: Attackers constantly target exposed SSH services using automated dictionary attacks against user accounts (`root`, `admin`, `user`).
  - **Key Compromise**: Stolen or weakly protected private keys allow unauthorized remote root compromise.
- **Defensive Recommendations**:
  - Disable root login (`PermitRootLogin no` in `/etc/ssh/sshd_config`).
  - Enforce public-key authentication only (`PasswordAuthentication no`).
  - Implement rate-limiting using UFW (`ufw limit 22/tcp`) or Fail2ban.

### 2. Port 80/tcp — Apache httpd 2.4.52 (HTTP)
- **Service Purpose**: Hypertext Transfer Protocol serving web application content in unencrypted cleartext.
- **Potential Security Exposure**:
  - **Cleartext Transmission**: All authentication tokens, session cookies, and login credentials sent over port 80 are vulnerable to interception via local Man-in-the-Middle (MitM) or packet sniffing.
  - **Web Application Flaws**: The underlying web server frequently hosts vulnerabilities such as SQL Injection, Cross-Site Scripting (XSS), or unpatched CMS exploits.
- **Defensive Recommendations**:
  - Redirect all unencrypted HTTP traffic to HTTPS (port 443).
  - Implement HTTP Strict Transport Security (HSTS) headers.
  - Disable server banner tokens (`ServerTokens Prod` and `ServerSignature Off`).

### 3. Port 443/tcp — Apache httpd 2.4.52 (HTTPS / SSL)
- **Service Purpose**: Encrypted web communication utilizing Transport Layer Security (TLS) to protect data confidentiality and integrity.
- **Potential Security Exposure**:
  - **Weak Cipher Suites**: Utilizing obsolete protocols (SSLv3, TLS 1.0, TLS 1.1) exposes sessions to decryption vulnerabilities (e.g., POODLE, BEAST).
  - **Certificate Misconfiguration**: Self-signed, expired, or improperly chained certificates cause user browser warnings and invite rogue certificate spoofing.
- **Defensive Recommendations**:
  - Restrict TLS configuration to TLS 1.2 and TLS 1.3 only.
  - Maintain valid, publicly trusted certificates (e.g., Let's Encrypt) with automated renewal.

### 4. Port 3306/tcp — MySQL Database Server 8.0.36
- **Service Purpose**: Relational Database Management System (RDBMS) storing application datasets, user accounts, and business records.
- **Potential Security Exposure**:
  - **External Ingress Risk**: Databases should virtually never be exposed directly to the public network or untrusted subnets. Exposure invites direct authentication cracking, remote code execution bugs, and denial of service.
  - **Privilege Escalation**: Misconfigured database users with excessive privileges (`GRANT ALL ON *.* TO 'root'@'%'`) risk full host compromise if breached.
- **Defensive Recommendations**:
  - Bind MySQL strictly to the local loopback interface (`bind-address = 127.0.0.1` in `/etc/mysql/mysql.conf.d/mysqld.cnf`).
  - Block external ingress to port 3306 at the firewall level.

---

## 10. Evidence & Screenshots
Screenshots validating execution are stored in the [`screenshots/`](screenshots/) directory:
- `screenshots/01_nmap_installation_check.png`: Verification of Nmap installation and version banner.
- `screenshots/02_nmap_basic_scan.png`: Output of basic discovery scan against the local target.
- `screenshots/03_nmap_service_version_scan.png`: Detailed service detection output (`-sV`).
- `screenshots/04_nmap_os_detection.png`: Privileged OS detection output (`-O`).

---

## 11. Lessons Learned
- **Banners Disclose Critical Intelligence**: Default service banners reveal exact patch levels (e.g., `OpenSSH 8.9p1 Ubuntu 3ubuntu0.6`), allowing attackers to cross-reference public CVE databases for known exploits without writing custom probes.
- **Least Functionality Principle**: Any network daemon running on a host that is not strictly required for business operations should be disabled or bound strictly to `127.0.0.1`.
- **Privilege Requirements for OS Fingerprinting**: Unprivileged scans rely on standard OS socket handshakes; raw TCP sequence analysis and OS deduction require root or administrator privileges.

## 12. Limitations
- Nmap identifies what is listening; it does not evaluate whether an application's internal authentication or business logic is vulnerable (which requires vulnerability scanners or manual web assessments).
- Firewalls dropping SYN packets will report ports as `filtered`, concealing whether a service is actively running behind the filter.

## 13. Ethical-Use Statement
All Nmap scans performed in this task were conducted exclusively against local loopback interfaces and authorized private virtual machines owned by the analyst. Port scanning unauthorized third-party systems without explicit written permission is unethical, disruptive, and potentially illegal under computer misuse legislation (e.g., the Computer Fraud and Abuse Act or regional cyber laws).
