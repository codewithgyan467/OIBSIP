# Task 3: SQL Injection on DVWA

**Author**: Gyandeep Duwarah  
**Environment**: Damn Vulnerable Web Application (DVWA) - Low Security  
**Database**: MySQL / MariaDB

---

## Overview
This lab demonstrates identifying and testing SQL Injection vulnerabilities in DVWA, understanding how unvalidated user input alters SQL execution logic, and implementing secure coding remediation using parameterized prepared statements.

## Payloads Tested

1. **Boolean Tautology (Dump All Users)**:
   - Input: `1' OR '1'='1`
   - Result: WHERE condition always evaluates to TRUE; dumps all user records.

2. **UNION-Based Credential Extraction**:
   - Input: `1' UNION SELECT user, password FROM users #`
   - Result: Appends database username and password hashes into the response.

## Remediation

The root cause is direct string concatenation of user input into dynamic SQL queries. The fix is using **Prepared Statements with Parameterized Queries** (e.g. PHP PDO):

```php
$stmt = $pdo->prepare('SELECT first_name, last_name FROM users WHERE user_id = :id');
$stmt->bindValue(':id', $id, PDO::PARAM_INT);
$stmt->execute();
$results = $stmt->fetchAll(PDO::FETCH_ASSOC);
```

For full analysis, source code breakdown, and notes, see [`sql_injection_notes.md`](./sql_injection_notes.md).

## Screenshots

Evidence is stored in [`screenshots/`](./screenshots/):
- `01_dvwa_security_low.png` — DVWA security set to Low
- `02_normal_behavior_id1.png` — Baseline test with ID = 1
- `03_sqli_boolean_all_users.png` — Boolean injection output
- `04_sqli_union_password_hashes.png` — UNION query extracting password hashes
