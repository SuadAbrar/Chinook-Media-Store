-- Additional read-only quality investigations for the Chinook MySQL schema.
-- Run after loading the official Chinook MySQL sample database into `Chinook`.
-- These checks surface candidates for review; none changes source data.

-- Check 1: Count customer email values that are NULL, blank, or present.
-- A zero missing count does not prove an address is deliverable or belongs to the customer.
SELECT
    COUNT(*) AS customer_count,
    SUM(Email IS NULL) AS null_email_count,
    SUM(Email IS NOT NULL AND TRIM(Email) = '') AS blank_email_count,
    SUM(Email IS NOT NULL AND TRIM(Email) <> '') AS nonblank_email_count
FROM Customer;

-- Check 2: Find email values duplicated after trimming and case normalization.
-- Shared email addresses can be legitimate; review customer records before classifying them.
SELECT
    LOWER(TRIM(Email)) AS normalized_email,
    COUNT(*) AS customer_count,
    GROUP_CONCAT(CustomerId ORDER BY CustomerId) AS customer_ids
FROM Customer
WHERE Email IS NOT NULL
  AND TRIM(Email) <> ''
GROUP BY LOWER(TRIM(Email))
HAVING COUNT(*) > 1
ORDER BY customer_count DESC, normalized_email;

-- Check 3: Flag nonblank email values that fail a deliberately simple shape check.
-- This is not full RFC validation and cannot confirm that a mailbox or domain exists.
SELECT
    CustomerId,
    Email
FROM Customer
WHERE Email IS NOT NULL
  AND TRIM(Email) <> ''
  AND TRIM(Email) NOT REGEXP '^[^[:space:]@]+@[^[:space:]@]+[.][^[:space:]@]+$'
ORDER BY CustomerId;

-- Check 4: Find NULL or blank customer names and other useful contact/location fields.
-- NULL and whitespace-only values are both treated as missing for this review.
SELECT
    CustomerId,
    FirstName,
    LastName,
    Email,
    Address,
    City,
    Country
FROM Customer
WHERE FirstName IS NULL OR TRIM(FirstName) = ''
   OR LastName IS NULL OR TRIM(LastName) = ''
   OR Email IS NULL OR TRIM(Email) = ''
   OR Address IS NULL OR TRIM(Address) = ''
   OR City IS NULL OR TRIM(City) = ''
   OR Country IS NULL OR TRIM(Country) = ''
ORDER BY CustomerId;

-- Check 5: Find possible repeated customer profiles using normalized name, email,
-- and mailing address. Candidate groups need manual review; shared household details
-- and intentionally shared email addresses do not by themselves prove duplication.
SELECT
    LOWER(TRIM(FirstName)) AS normalized_first_name,
    LOWER(TRIM(LastName)) AS normalized_last_name,
    LOWER(TRIM(Email)) AS normalized_email,
    LOWER(TRIM(Address)) AS normalized_address,
    LOWER(TRIM(City)) AS normalized_city,
    LOWER(TRIM(Country)) AS normalized_country,
    COUNT(*) AS customer_count,
    GROUP_CONCAT(CustomerId ORDER BY CustomerId) AS customer_ids
FROM Customer
WHERE FirstName IS NOT NULL AND TRIM(FirstName) <> ''
  AND LastName IS NOT NULL AND TRIM(LastName) <> ''
  AND Email IS NOT NULL AND TRIM(Email) <> ''
GROUP BY
    LOWER(TRIM(FirstName)),
    LOWER(TRIM(LastName)),
    LOWER(TRIM(Email)),
    LOWER(TRIM(Address)),
    LOWER(TRIM(City)),
    LOWER(TRIM(Country))
HAVING COUNT(*) > 1
ORDER BY customer_count DESC, normalized_last_name, normalized_first_name;

-- Check 6: Locate leading or trailing whitespace in customer and employee text.
-- The result shows original values for review; TRIM is not written back to the tables.
SELECT 'Customer' AS table_name, 'FirstName' AS field_name,
       CustomerId AS record_id, FirstName AS observed_value
FROM Customer
WHERE FirstName IS NOT NULL AND BINARY FirstName <> BINARY TRIM(FirstName)
UNION ALL
SELECT 'Customer', 'LastName', CustomerId, LastName
FROM Customer
WHERE LastName IS NOT NULL AND BINARY LastName <> BINARY TRIM(LastName)
UNION ALL
SELECT 'Customer', 'Email', CustomerId, Email
FROM Customer
WHERE Email IS NOT NULL AND BINARY Email <> BINARY TRIM(Email)
UNION ALL
SELECT 'Customer', 'Address', CustomerId, Address
FROM Customer
WHERE Address IS NOT NULL AND BINARY Address <> BINARY TRIM(Address)
UNION ALL
SELECT 'Customer', 'City', CustomerId, City
FROM Customer
WHERE City IS NOT NULL AND BINARY City <> BINARY TRIM(City)
UNION ALL
SELECT 'Customer', 'Country', CustomerId, Country
FROM Customer
WHERE Country IS NOT NULL AND BINARY Country <> BINARY TRIM(Country)
UNION ALL
SELECT 'Employee', 'FirstName', EmployeeId, FirstName
FROM Employee
WHERE FirstName IS NOT NULL AND BINARY FirstName <> BINARY TRIM(FirstName)
UNION ALL
SELECT 'Employee', 'LastName', EmployeeId, LastName
FROM Employee
WHERE LastName IS NOT NULL AND BINARY LastName <> BINARY TRIM(LastName)
UNION ALL
SELECT 'Employee', 'Title', EmployeeId, Title
FROM Employee
WHERE Title IS NOT NULL AND BINARY Title <> BINARY TRIM(Title)
ORDER BY table_name, field_name, record_id;

-- Check 7: Find non-NULL relationship keys with no matching parent record.
-- NULL support representatives and top-level employees are not treated as orphans.
SELECT 'Invoice.CustomerId' AS relationship_name,
       CAST(i.InvoiceId AS CHAR) AS child_record_id,
       CAST(i.CustomerId AS CHAR) AS missing_parent_id
FROM Invoice AS i
LEFT JOIN Customer AS c ON c.CustomerId = i.CustomerId
WHERE i.CustomerId IS NOT NULL AND c.CustomerId IS NULL
UNION ALL
SELECT 'Customer.SupportRepId',
       CAST(c.CustomerId AS CHAR),
       CAST(c.SupportRepId AS CHAR)
FROM Customer AS c
LEFT JOIN Employee AS e ON e.EmployeeId = c.SupportRepId
WHERE c.SupportRepId IS NOT NULL AND e.EmployeeId IS NULL
UNION ALL
SELECT 'InvoiceLine.InvoiceId',
       CAST(il.InvoiceLineId AS CHAR),
       CAST(il.InvoiceId AS CHAR)
FROM InvoiceLine AS il
LEFT JOIN Invoice AS i ON i.InvoiceId = il.InvoiceId
WHERE il.InvoiceId IS NOT NULL AND i.InvoiceId IS NULL
UNION ALL
SELECT 'InvoiceLine.TrackId',
       CAST(il.InvoiceLineId AS CHAR),
       CAST(il.TrackId AS CHAR)
FROM InvoiceLine AS il
LEFT JOIN Track AS t ON t.TrackId = il.TrackId
WHERE il.TrackId IS NOT NULL AND t.TrackId IS NULL
UNION ALL
SELECT 'Employee.ReportsTo',
       CAST(e.EmployeeId AS CHAR),
       CAST(e.ReportsTo AS CHAR)
FROM Employee AS e
LEFT JOIN Employee AS manager ON manager.EmployeeId = e.ReportsTo
WHERE e.ReportsTo IS NOT NULL AND manager.EmployeeId IS NULL
ORDER BY relationship_name, child_record_id;

-- Check 8: Surface NULL or negative invoice and invoice-line amounts/quantities.
-- Negative values are suspicious for this sales schema; zero is left unflagged
-- because the expected zero-value policy has not been verified.
SELECT 'Invoice' AS table_name,
       CAST(InvoiceId AS CHAR) AS record_id,
       Total AS amount,
       NULL AS quantity
FROM Invoice
WHERE Total IS NULL OR Total < 0
UNION ALL
SELECT 'InvoiceLine',
       CAST(InvoiceLineId AS CHAR),
       UnitPrice,
       Quantity
FROM InvoiceLine
WHERE UnitPrice IS NULL OR UnitPrice < 0
   OR Quantity IS NULL OR Quantity < 0
ORDER BY table_name, record_id;

-- Check 9: Find missing/zero invoice dates and dates later than the run time.
-- Future dates are relative to CURRENT_TIMESTAMP and are candidates for review,
-- not confirmed defects; this check intentionally makes no fixed-date assumption.
SELECT
    InvoiceId,
    CustomerId,
    InvoiceDate,
    CASE
        WHEN InvoiceDate IS NULL THEN 'null invoice date'
        WHEN CAST(InvoiceDate AS CHAR) LIKE '0000-00-00%' THEN 'zero invoice date'
        WHEN InvoiceDate > CURRENT_TIMESTAMP THEN 'future invoice date'
    END AS date_issue
FROM Invoice
WHERE InvoiceDate IS NULL
   OR CAST(InvoiceDate AS CHAR) LIKE '0000-00-00%'
   OR InvoiceDate > CURRENT_TIMESTAMP
ORDER BY InvoiceId;

-- Check 10a: Find invoices without detail lines.
-- An invoice with no lines may be incomplete; confirm the sample-data business rules.
SELECT
    i.InvoiceId,
    i.CustomerId,
    i.InvoiceDate,
    i.Total
FROM Invoice AS i
LEFT JOIN InvoiceLine AS il ON il.InvoiceId = i.InvoiceId
WHERE il.InvoiceLineId IS NULL
ORDER BY i.InvoiceId;

-- Check 10b: Reconcile stored invoice totals to rounded line extensions.
-- Assumption to verify locally: invoice total is the sum of UnitPrice * Quantity,
-- rounded to two decimal places. This reports cent-level mismatches only; it does
-- not assert tax/discount rules beyond what the sample schema encodes.
SELECT
    i.InvoiceId,
    i.Total AS stored_invoice_total,
    ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS calculated_invoice_total,
    ROUND(i.Total, 2) - ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS difference
FROM Invoice AS i
JOIN InvoiceLine AS il ON il.InvoiceId = i.InvoiceId
GROUP BY i.InvoiceId, i.Total
HAVING i.Total IS NULL
    OR ROUND(i.Total, 2) <> ROUND(SUM(il.UnitPrice * il.Quantity), 2)
ORDER BY i.InvoiceId;
