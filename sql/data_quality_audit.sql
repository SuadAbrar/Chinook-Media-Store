-- Chinook SQL data quality audit: original transformation exercises
-- These SELECT statements create derived views only; they do not update source data.

-- Task 1: Show how TRIM would remove leading and trailing whitespace from email.
-- Limitation: this returns a cleaned representation; the stored email is unchanged.
SELECT
    CustomerId,
    Email AS original_email,
    TRIM(Email) AS trimmed_email
FROM Customer;

-- Task 2: Format customer names as "LAST, FIRST" in uppercase.
-- CONCAT returns NULL if either name is NULL in MySQL; inspect missing names separately.
SELECT
    CustomerId,
    UPPER(CONCAT(LastName, ', ', FirstName)) AS formatted_customer_name
FROM Customer;

-- Task 3: Combine employee name, title, and phone for display.
-- CONCAT returns NULL if any input is NULL; this is not a source-data repair.
SELECT
    EmployeeId,
    CONCAT(FirstName, ' ', LastName, ', ', Title, ', ', Phone) AS employee_details
FROM Employee;

-- Task 4: Derive a lowercase three-character prefix from the customer city.
-- This is a prefix, not a unique city code; cities can share the same prefix.
SELECT
    CustomerId,
    FirstName,
    LastName,
    City,
    LOWER(SUBSTRING(City, 1, 3)) AS city_prefix
FROM Customer;

-- Task 5: Return the date portion of each invoice timestamp.
-- Limitation: the derived date omits the time of day; InvoiceDate remains unchanged.
SELECT
    InvoiceId,
    CustomerId,
    DATE(InvoiceDate) AS invoice_date
FROM Invoice;

-- Task 6: Build a four-character name prefix from the first two letters of each name.
-- This is not a cryptographic hash or a reliable identifier; collisions are expected.
SELECT
    CustomerId,
    CONCAT(
        LOWER(SUBSTRING(FirstName, 1, 2)),
        LOWER(SUBSTRING(LastName, 1, 2))
    ) AS customer_name_prefix
FROM Customer;

-- Task 7: Cast the invoice identifier to text for display or text-oriented export.
-- Limitation: this does not change the stored type or add analytical value to the ID.
SELECT
    InvoiceId,
    CustomerId,
    CAST(InvoiceId AS CHAR) AS invoice_id_text
FROM Invoice;

-- Task 8: Extract the email domain when the address has one non-edge @ sign.
-- This checks only a simple structure; it does not establish that an address is valid.
SELECT
    CustomerId,
    Email,
    CASE
        WHEN Email IS NOT NULL
            AND CHAR_LENGTH(Email) - CHAR_LENGTH(REPLACE(Email, '@', '')) = 1
            AND LOCATE('@', Email) > 1
            AND LOCATE('@', Email) < CHAR_LENGTH(Email)
        THEN SUBSTRING(Email, LOCATE('@', Email) + 1)
        ELSE NULL
    END AS email_domain
FROM Customer;

-- Task 9: Measure customer first-name length in characters, not bytes.
-- NULL names produce a NULL length; blank names have length zero and need separate review.
SELECT
    CustomerId,
    FirstName,
    CHAR_LENGTH(FirstName) AS first_name_character_count
FROM Customer;

-- Task 10: Return employee titles in lowercase for consistent display/grouping.
-- Limitation: capitalization is standardized only in this result, not in stored data.
SELECT
    EmployeeId,
    LastName,
    Title AS original_title,
    LOWER(Title) AS lowercase_title
FROM Employee;
