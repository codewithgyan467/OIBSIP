# CyberSecurity Task 1: Basic Network Scanning with Nmap

## 1. Objective
The objective of this task is to perform ethical network discovery, port enumeration, service identification, and attack surface mapping against an authorized local lab machine (`127.0.0.1`) using **Nmap (Network Mapper)**. The exercise builds core competencies in active reconnaissance, interpreting TCP connection states, identifying software versions, evaluating security exposures across listening network daemons, and adhering to strict rules of engagement in a local laboratory environment.

## 2. Scope
- **Authorized Target**: Localhost loopback interface (`127.0.0.1` / `3ca52znvmj.adobe.io`).
- **Scanning Types**:
  1. Tool verification (`nmap --version`)
  2. Basic TCP Port Scan across the top 1,000 common ports (`nmap 127.0.0.1`)
  3. Service and Version Detection (`nmap -sV 127.0.0.1`)
  4. Structured Scan Export (`nmap -sV 127.0.0.1 -oN nmap_scan_results.txt`)
- **Ethical Boundary**: All commands were executed strictly against local loopback interfaces owned and administered by the analyst. No public networks, third-party domains, or unauthorized cloud endpoints were scanned.

## 3. Tools
- **Nmap (Network Mapper) v7.95**: Official network scanner compiled with Npcap v1.79 packet driver, OpenSSL 3.0.13, and Lua 5.4.6.
- **Terminal**: Windows PowerShell (Windows 11).
- **Target Host**: Local workstation running internal services (IIS, Apache XAMPP, MariaDB, PostgreSQL, Windows RPC/SMB).

## 4. Environment
- **Operating System**: Microsoft Windows 11 Workstation.
- **Scanner Architecture**: `i686-pc-windows-windows` with `iocp` engine and Npcap driver.
- **Target Address**: `127.0.0.1` (Local Loopback).

## 5. Installation / Setup
1. Downloaded the official installer `nmap-7.95-setup.exe` from [nmap.org](https://nmap.org/download.html).
2. Installed Nmap and the Npcap packet capture driver with standard defaults.
3. Verified the installation in Windows PowerShell:
```powershell
nmap --version
```
*Output confirmed: `Nmap version 7.95 ( https://nmap.org )` with Npcap 1.79 support.*

---

## 6. Implementation Steps

### Step 1: Pre-Scan Conceptual Verification
Before scanning, the following networking and security fundamentals were verified:
- **IP Address**: Unique Layer 3 network identifier; `127.0.0.1` represents the local loopback adapter.
- **Port**: 16-bit Layer 4 abstraction (0–65535) routing packets to specific application processes.
- **TCP Handshake**: Nmap probes ports by initiating TCP connections (`SYN` -> `SYN-ACK` -> `ACK`).
- **Socket States**:
  - `Open`: The host responds with `SYN-ACK`; an active daemon is listening.
  - `Closed`: The host responds with `RST`; no service is bound to the port.
  - `Filtered`: Probes receive no response or ICMP unreachable errors due to firewall rules.
- **Attack Surface**: The aggregate total of externally accessible open ports, daemons, and application protocols.

### Step 2: Basic Host and Port Enumeration
```powershell
nmap 127.0.0.1
```
Scanned the top 1,000 TCP ports in 0.40 seconds, discovering active listener ports across web, database, and system communication services.

### Step 3: Service and Software Version Detection
```powershell
nmap -sV 127.0.0.1
```
Interrogated the open sockets with application-layer probes to determine exact service banners and software versions.

### Step 4: Export Scan Findings to Persistent Evidence File
```powershell
nmap -sV 127.0.0.1 -oN E:\internship\OIBSIP\CyberSecurity-Task1-Nmap\nmap_scan_results.txt
```
Saved full scan logs into [`nmap_scan_results.txt`](nmap_scan_results.txt).

---

## 7. Commands Used

| Command | Flags / Syntax | Purpose |
|---|---|---|
| Version Verification | `nmap --version` | Validates Nmap executable availability, version, and packet driver support. |
| Basic Port Scan | `nmap 127.0.0.1` | Quickly sweeps the top 1,000 TCP ports on the loopback target. |
| Service Version Scan | `nmap -sV 127.0.0.1` | Probes open ports to identify software daemons and exact version strings. |
| Save to Plain Text | `-oN <file_path>` | Directs scan output into a persistent, human-readable text file. |

---

## 8. Results
The complete raw scan log is preserved in [`nmap_scan_results.txt`](nmap_scan_results.txt).

### Discovered Open Ports & Services
```text
PORT     STATE SERVICE       VERSION
80/tcp   open  http          Microsoft IIS httpd 10.0
135/tcp  open  msrpc         Microsoft Windows RPC
445/tcp  open  microsoft-ds?
3306/tcp open  mysql         MariaDB 5.5.5-10.4.32
5432/tcp open  postgresql    PostgreSQL DB 9.6.0 or later
8080/tcp open  http          Apache httpd 2.4.58 ((Win64) OpenSSL/3.1.3 PHP/8.2.12)
8081/tcp open  http          Apache httpd
```

---

## 9. Security Analysis of Discovered Services

Every discovered open port expands the system's attack surface. Below is a comprehensive defensive security analysis for each identified service:

### 1. Port 80/tcp — Microsoft IIS httpd 10.0
- **Service Purpose**: Web server built into Windows Server / Professional editions for hosting web applications.
- **Potential Security Exposure**:
  - Unencrypted cleartext transmission of HTTP requests.
  - Misconfigured virtual directories or exposed administrative interfaces (`/aspnet_client/`).
- **Defensive Recommendations**:
  - Stop or disable IIS if not actively required (`Stop-Service W3SVC`).
  - Redirect HTTP traffic to HTTPS (port 443) using URL Rewrite modules.

### 2. Port 135/tcp — Microsoft Windows Remote Procedure Call (RPC)
- **Service Purpose**: Endpoint mapper enabling inter-process communication between Windows network components (DCOM, WMI).
- **Potential Security Exposure**:
  - Historically targeted by major worm exploits (e.g., Blaster worm).
  - Allows remote attackers to enumerate registered RPC interfaces, user accounts, and system services using tools like `rpcdump`.
- **Defensive Recommendations**:
  - Block port 135 at network perimeter firewalls and disable external access.
  - Enforce host-based Windows Defender Firewall rules restricting RPC strictly to local subnets.

### 3. Port 445/tcp — Microsoft-DS (Server Message Block / SMB)
- **Service Purpose**: Native Windows file and printer sharing protocol across local networks.
- **Potential Security Exposure**:
  - High-risk target for network lateral movement and remote code execution (e.g., EternalBlue / MS17-010, WannaCry ransomware).
  - Vulnerable to NTLM relay attacks and SMB signing bypass if improperly configured.
- **Defensive Recommendations**:
  - Never expose port 445 to untrusted networks or the public internet.
  - Mandate SMB signing (`RequireSecuritySignature = True`) and enforce SMBv3 encryption.

### 4. Port 3306/tcp — MariaDB Database Server (10.4.32)
- **Service Purpose**: Relational Database Management System supporting the local XAMPP stack and DVWA laboratory database.
- **Potential Security Exposure**:
  - Direct database brute-force attacks against the `root` administrative account.
  - Exposes internal table structures and sensitive data if bound to `0.0.0.0`.
- **Defensive Recommendations**:
  - Ensure MySQL is bound strictly to `127.0.0.1` (`bind-address = 127.0.0.1` in `my.ini`).
  - Set strong administrative passwords and remove anonymous accounts (`mysql_secure_installation`).

### 5. Port 5432/tcp — PostgreSQL Database Server (9.6.0+)
- **Service Purpose**: Enterprise object-relational database management system.
- **Potential Security Exposure**:
  - Outdated versions (9.6.x) have reached End-of-Life (EOL) and no longer receive security patches.
  - Vulnerable to credential stuffing if default accounts (`postgres`) use weak passwords.
- **Defensive Recommendations**:
  - Upgrade PostgreSQL to an active, supported long-term release (v15/v16).
  - Restrict client authentication via `pg_hba.conf` to trusted local socket connections (`scram-sha-256`).

### 6. Port 8080/tcp & 8081/tcp — Apache httpd 2.4.58 (OpenSSL/3.1.3 PHP/8.2.12)
- **Service Purpose**: Apache HTTP server hosting the local DVWA web application on alternate port 8080.
- **Potential Security Exposure**:
  - Detailed server banner disclosures (`Apache/2.4.58 (Win64) OpenSSL/3.1.3 PHP/8.2.12`) announce exact patch levels to scanners.
  - Hosts educational web vulnerabilities (SQLi, XSS, Command Injection) inside DVWA.
- **Defensive Recommendations**:
  - Suppress banner leakage via `ServerTokens Prod` and `ServerSignature Off` in `httpd.conf`.
  - Confine development instances strictly to loopback interfaces.

---

## 10. Evidence & Screenshot Mapping
Screenshots validating execution are cataloged in [`screenshots/`](screenshots/):
- `screenshots/01_nmap_installation_check.png`: Verification of `nmap --version` displaying Nmap 7.95 with Npcap 1.79.
- `screenshots/02_nmap_basic_scan.png`: Terminal output of basic discovery scan (`nmap 127.0.0.1`) identifying open TCP ports.
- `screenshots/03_nmap_service_version_scan.png`: Service and version detection (`nmap -sV 127.0.0.1`) displaying detailed banners.
- `screenshots/04_nmap_save_output.png`: Scan execution saving results directly to `nmap_scan_results.txt`.

---

## 11. Lessons Learned
- **Reconnaissance Speed**: Nmap sweeps 1,000 ports on localhost in under half a second, illustrating how quickly automated scanners can map an organization's network perimeter.
- **Banner Information Leakage**: Default service banners announce exact software versions (e.g., `Apache 2.4.58`, `MariaDB 10.4.32`, `Microsoft IIS 10.0`), allowing attackers to query CVE databases for targeted exploits without needing custom probes.
- **Internal Service Hardening**: Critical administrative and database services (ports 135, 445, 3306, 5432) must never be accessible across public interfaces; they must be bound strictly to `127.0.0.1` or firewalled.

## 12. Limitations
- Scanning localhost (`127.0.0.1`) bypasses external network firewalls and Network Address Translation (NAT), showing all locally bound sockets.
- Port scans identify open network sockets; they do not assess whether web application business logic or backend authentication mechanisms are secure.

## 13. Ethical-Use Statement
All Nmap network scans performed in this task were conducted exclusively against the analyst's local loopback interface (`127.0.0.1`). Unauthorized port scanning of external networks or third-party computing systems is disruptive, unethical, and prohibited under international cybersecurity laws (e.g., the Computer Fraud and Abuse Act and IT Acts).
