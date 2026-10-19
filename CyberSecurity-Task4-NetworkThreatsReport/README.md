# CyberSecurity Task 4: Common Network Security Threats Report

## 1. Objective
The objective of this task is to research, systematically analyze, and document fundamental network-level security threats that undermine modern networked computing environments. This research report provides a deep technical examination of Denial of Service (DoS/DDoS), Man-in-the-Middle (MitM) attacks, IP Address Spoofing, and DNS Cache Poisoning/Spoofing, detailing their execution mechanisms, real-world manifestations, business and technical impacts, multi-tier mitigations, and defensive administrator takeaways.

## 2. Scope
This deliverable is a formal technical research report. The scope covers:
- Core networking protocols (IPv4, IPv6, TCP, UDP, ARP, DNS).
- Four threat vectors: DoS/DDoS, MitM, IP Spoofing, and DNS Poisoning.
- Documented historical cyber incidents (Mirai/Dyn, DigiNotar, GitHub Memcached DDoS, Malaysia Airlines DNS hijack).
- Defensive architectural patterns (Anycast, BCP 38, uRPF, DNSSEC, TLS 1.3, DAI, DHCP Snooping).
- Per internship guidelines, Task 4 is a structured documentation deliverable requiring no demo video.

## 3. Tools
- **Document Authoring**: Markdown standard formatting, GitHub Flavored Markdown (GFM).
- **Academic & Industry Research Sources**: NIST Special Publications, CISA Alerts, MITRE ATT&CK Knowledgebase, and IETF RFC Standards.
- **Protocol Analysis References**: Wireshark packet captures and RFC protocol specifications.

## 4. Environment
- **Operating Environment**: Multi-platform research documentation workstation.
- **Reference Environments**: Enterprise perimeter routing topologies, ISP peering exchanges, and distributed cloud computing environments.

## 5. Installation / Setup
No specialized software compilation is required to review this deliverable. The report can be read directly via GitHub's Markdown viewer or converted to PDF using standard Markdown rendering tools:
```bash
# Optional: convert report to PDF using pandoc if installed
pandoc network_security_threats_report.md -o network_security_threats_report.pdf
```

## 6. Implementation Steps
1. Conducted literature review of NIST Special Publications (SP 800-81-2, SP 800-92) and CISA advisory bulletins.
2. Analyzed protocol design specifications from the Internet Engineering Task Force (RFC 2827/BCP 38, RFC 4033).
3. Investigated verified incident retrospectives for each threat vector.
4. Synthesized findings into structured threat categories (mechanism, execution flow, case study, impact, and controls).
5. Constructed a comparative multi-dimensional risk matrix.
6. Formulated three concrete defensive imperatives for network administrators.

## 7. Commands Used
While Task 4 is an analytical research report, the following investigative commands and tools were reviewed to analyze how each threat manifests in packet captures and operational environments:
```bash
# Inspecting DNS resolution and DNSSEC signatures
dig +dnssec @8.8.8.8 example.com

# Monitoring local ARP cache for spoofing/poisoning detection
arp -a

# Checking Linux kernel reverse path filtering settings
sysctl net.ipv4.conf.all.rp_filter
```

## 8. Results
The primary deliverable of this task is the complete technical report:
- [`network_security_threats_report.md`](network_security_threats_report.md)

Key findings documented in the report include:
- Unauthenticated UDP services remain the primary catalyst for multi-terabit amplification DDoS attacks.
- Lack of encryption at Layers 2 and 7 enables zero-warning MitM interception unless HSTS and 802.1X are enforced.
- IP spoofing is solvable through ingress/egress filtering (BCP 38), but global enforcement depends on ISP-level compliance.
- DNS cache poisoning has evolved from brute-forcing TXIDs (Kaminsky) to sophisticated registrar and upstream redirection attacks.

## 9. Security Analysis
The analysis demonstrates that modern network security vulnerabilities are rarely isolated software bugs; they are often systemic design choices inherited from the early internet's open-trust model. A recurring theme across all four analyzed threats is the reliance on implicit trust:
- IP assumes the source header is honest.
- ARP assumes all hosts on a local segment are benign.
- DNS historically assumed the fastest response to UDP port 53 was authentic.
True defense requires shifting from implicit trust to explicit cryptographic verification (Zero Trust Architecture, mTLS, DNSSEC, and BCP 38).

## 10. Evidence
- Full technical report located at [`network_security_threats_report.md`](network_security_threats_report.md).
- Authoritative reference list with persistent links to NIST, CISA, MITRE ATT&CK, and IETF RFCs.
- Detailed comparative threat matrix mapping vector, impact, and mitigation difficulty.

## 11. Lessons Learned
- **Security in Depth**: Perimeter firewalls alone cannot protect against volumetric DDoS or local ARP spoofing; host-based and protocol-level controls are equally critical.
- **Protocol Hygiene**: Eliminating legacy cleartext services significantly shrinks the attack surface.
- **Incident Retrospectives**: Studying historical breaches (e.g., DigiNotar, Dyn) provides invaluable insight into how real-world attackers chain multiple small weaknesses into catastrophic failures.

## 12. Limitations
- This report focuses on network-layer and transport-layer threats; application-layer vulnerabilities (such as SQL injection, XSS, and SSRF) are addressed separately in Task 3.
- Mitigations involving global internet routing policies (such as BCP 38 adoption by transit providers) are outside the direct control of enterprise-edge administrators and must be supplemented with cloud scrubbing.

## 13. Ethical-Use Statement
The theoretical and practical insights documented in this report are intended exclusively for educational defense, network architecture hardening, and security analysis. Understanding attack flows and exploitation vectors is essential for designing resilient network defenses, conducting authorized vulnerability assessments, and responding effectively to security incidents.
