# Oasis Infobyte Internship (OIBSIP) — Cybersecurity Track

## Security Analyst Internship Portfolio

### Project Overview
This repository contains the practical lab implementations, configuration scripts, vulnerability analyses, and research documentation completed for the **Oasis Infobyte Security Analyst Internship (OIBSIP)**. 

The focus of this portfolio is developing core competencies across the fundamental pillars of defensive and offensive security operations:
1. **Network Discovery & Attack Surface Mapping** — Active port scanning, service enumeration, and fingerprinting with Nmap.
2. **Host-Based Perimeter Defense** — Network traffic filtering, stateful firewall policies, and defense-in-depth with Ubuntu UFW.
3. **Web Application Vulnerability Analysis** — Controlled exploitation, root-cause code inspection, and parameterized query remediation of SQL Injection within Damn Vulnerable Web Application (DVWA).
4. **Threat Intelligence & Network Defense Analysis** — Structured research and comparative technical evaluation of critical network threats (DoS/DDoS, MitM, IP Spoofing, and DNS Cache Poisoning).

---

## Learning Objectives
As an entry-level security analyst, this lab portfolio demonstrates hands-on mastery of:
- **Core Networking Concepts**: TCP/IP protocol suite operations, three-way handshakes, socket states (open, closed, filtered), and port-to-service relationships.
- **Defensive Engineering**: Implementing the principle of least privilege on network endpoints, establishing default-deny firewall policies, and preventing remote lockout.
- **Secure Software Development (AppSec)**: Identifying how unvalidated user inputs corrupt database syntax, understanding SQL parser execution trees, and engineering defensive remediation via parameterized prepared statements.
- **Threat Modeling & Mitigation**: Evaluating adversary tactics, analyzing real-world historical incidents, and formulating enterprise-grade defensive architectures (e.g., BCP 38, DNSSEC, TLS 1.3, DDoS scrubbing).

---

## Task Inventory

| Task Folder | Category | Project Title | Key Artifacts | Deliverable Type |
|---|---|---|---|---|
| `CyberSecurity-Task1-Nmap/` | Network Security | Basic Network Scanning with Nmap | `nmap_scan_results.txt`, Scan Analysis, Screenshots | Practical Lab + Walkthrough |
| `CyberSecurity-Task2-UFW/` | Defensive Security | Basic Firewall Configuration with UFW | `ufw_configuration.sh`, Policy Audit, Screenshots | Automation Script + Lab |
| `CyberSecurity-Task3-DVWA-SQLInjection/` | Web Application Security | SQL Injection on DVWA (Low Security) | `sql_injection_notes.md`, Proof of Concept, Code Fix | Practical Lab + Remediation |
| `CyberSecurity-Task4-NetworkThreatsReport/` | Cyber Threat Intelligence | Research Report: Common Network Threats | `network_security_threats_report.md` | Comprehensive Technical Report |

---

## Lab Safety & Ethical Boundaries Statement

> **STRICT COMPLIANCE NOTICE**: All security operations, scans, and exploitation techniques documented in this repository were conducted strictly within isolated, private, and authorized lab environments (localhost loopback interfaces, local virtual machines, and intentionally vulnerable sandbox containers).

1. **Explicit Authorization**: Testing was performed solely against systems owned or explicitly designated for educational testing by the analyst.
2. **Zero External Impact**: No public IP addresses, third-party hosts, cloud assets, or organizational production networks were scanned, probed, or targeted.
3. **Data Protection**: No personal identifiable information (PII), production secrets, private encryption keys, or sensitive credentials are stored or committed within this repository.
4. **Educational Intent**: These artifacts are compiled solely to fulfill internship evaluation requirements and advance practical knowledge in ethical cybersecurity analysis.

---

## Repository Structure

```text
OIBSIP/
├── .gitignore
├── README.md                                      # Root project documentation (this file)
├── CyberSecurity-Task1-Nmap/
│   ├── README.md                                  # Detailed Nmap guide, scan methodology & port breakdown
│   ├── nmap_scan_results.txt                      # Raw terminal output from active scanning exercises
│   └── screenshots/                               # Timestamped terminal screenshots of Nmap commands
├── CyberSecurity-Task2-UFW/
│   ├── README.md                                  # UFW firewall architecture, rule rationale & testing guide
│   ├── ufw_configuration.sh                       # Production-safe hardening shell script
│   └── screenshots/                               # Verification screenshots (ufw status, blocked traffic)
├── CyberSecurity-Task3-DVWA-SQLInjection/
│   ├── README.md                                  # SQLi primer, lab setup, PoC analysis & defense guide
│   ├── sql_injection_notes.md                     # Raw test logs, payload analysis, and PDO remediation code
│   └── screenshots/                               # Evidence of normal operation, injected input, and DB responses
└── CyberSecurity-Task4-NetworkThreatsReport/
    ├── README.md                                  # Executive summary & reading guide for the threat report
    └── network_security_threats_report.md         # Full research report covering DoS, MitM, Spoofing, DNS
```

---

## Tools & Environments Used

- **Operating Systems**: Windows 11 (Host workstation), Ubuntu Linux 22.04 LTS (Local VM / WSL2 environment).
- **Network Reconnaissance**: Nmap (Network Mapper) v7.80+ for TCP SYN, Version, and OS detection.
- **Host Firewalling**: Uncomplicated Firewall (UFW) on Linux with underlying `iptables`/`nftables` packet filtering.
- **Web Security Lab**: Damn Vulnerable Web Application (DVWA) running in a local isolated Docker container / Apache-PHP-MySQL stack.
- **Version Control**: Git & GitHub with conventional semantic commits.

---

## How to Navigate Each Task

Each project folder is self-contained and structured with:
1. A specialized `README.md` containing an executive summary, scope, prerequisite concepts, step-by-step reproduction instructions, defensive security analysis, and lessons learned.
2. Direct technical deliverables (`.sh` scripts, `.txt` command logs, `.md` vulnerability notes).
3. A dedicated `screenshots/` directory providing visual proof of execution.

To review an individual task:
- Navigate into `CyberSecurity-Task1-Nmap/` to inspect host discovery, port enumeration, and service vulnerability surface mapping.
- Navigate into `CyberSecurity-Task2-UFW/` to inspect and execute the automated firewall configuration script and verify stateful packet drops.
- Navigate into `CyberSecurity-Task3-DVWA-SQLInjection/` to review controlled SQL injection test cases, database responses, and defensive PHP/PDO source code patches.
- Navigate into `CyberSecurity-Task4-NetworkThreatsReport/` to read the in-depth comparative threat study with authoritative citations from NIST, CISA, and IETF.

---

## Evidence & Verification Policy

To ensure high-integrity academic and professional standards:
- All command outputs are preserved verbatim in dedicated text records.
- All terminal operations include timestamped and clear visual evidence.
- Defensive remediations provide side-by-side comparisons of insecure code vs. secure implementation patterns.
- No synthetic or fabricated target data is used; all examples reflect genuine interaction with local lab infrastructure.
