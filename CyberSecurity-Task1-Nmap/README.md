# Task 1: Basic Network Scanning with Nmap

**Author**: Gyandeep Duwarah  
**Target**: `127.0.0.1` (Localhost)  
**Tool**: Nmap 7.95 (Windows)

---

## Overview
This task demonstrates basic network reconnaissance and port scanning using Nmap on a local machine to discover active services and open ports.

## Commands Executed

1. **Verify Installation**:
   ```powershell
   nmap --version
   ```

2. **Basic Port Scan (Top 1000 TCP Ports)**:
   ```powershell
   nmap 127.0.0.1
   ```

3. **Service & Version Enumeration**:
   ```powershell
   nmap -sV 127.0.0.1
   ```

4. **Export Scan Results to File**:
   ```powershell
   nmap -sV -oN nmap_scan_results.txt 127.0.0.1
   ```

## Identified Services

From the scan results ([nmap_scan_results.txt](./nmap_scan_results.txt)):
- Port 80/tcp: Microsoft IIS httpd 10.0
- Port 135/tcp: Microsoft Windows RPC
- Port 445/tcp: Microsoft Windows SMB
- Port 3306/tcp: MariaDB (MySQL) 5.5.5-10.4.32
- Port 5432/tcp: PostgreSQL DB 9.6.0+
- Port 8080/tcp: Apache httpd 2.4.58 (PHP 8.2.12)
- Port 8081/tcp: Apache httpd

## Screenshots

Evidence of execution is stored in [`screenshots/`](./screenshots/):
- `01_nmap_installation_check.png` — Version check verification
- `02_nmap_basic_scan.png` — Initial port scan output
- `03_nmap_service_version_scan.png` — Service and version detection
- `04_nmap_save_output.png` — Saving output to `nmap_scan_results.txt`
