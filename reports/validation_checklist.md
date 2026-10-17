# Local validation and screenshot checklist

## Before running queries

- [ ] Start the local MySQL Server and connect through SQLTools in VS Code.
- [ ] Select the `Chinook` database, not `Chinook_AutoIncrement` or another schema.
- [ ] Confirm MySQL version. The email `REGEXP` check targets MySQL 8 or later.
- [ ] Compare the local table/column definitions with the upstream Chinook 1.4.5 MySQL schema. The official schema marks customer first/last name and email, invoice date/total, and invoice-line price/quantity `NOT NULL`, and declares foreign keys for the relationships checked here.
- [ ] Do not rerun the official setup script against a database that contains data you need: it begins by dropping `Chinook` before recreating it.

## Execute and inspect

- [ ] Run each statement in `sql/data_quality_audit.sql` separately. Confirm each returns the expected columns and no SQL error; inspect NULL propagation in the concatenation tasks and confirm the name prefix is not treated as a unique key.
- [ ] Run each check in `sql/additional_quality_checks.sql` separately. Capture actual row counts and example records for non-empty results.
- [ ] For duplicate email/profile groups, inspect every customer ID and compare names/address/source context. A match is a candidate, not an instruction to merge.
- [ ] For email shape results, remember the pattern is deliberately limited and cannot prove whether a mailbox exists.
- [ ] For whitespace results, inspect the exact raw values. If spaces are visually ambiguous, query a character count or display delimiters around the string.
- [ ] For zero rows in a check, record “no rows detected by this check,” not “the database is error-free.”
- [ ] For numeric flags, verify local column nullability and whether zero or negative values have a documented meaning.
- [ ] For future invoice dates, record the run date/time and time zone; the test uses `CURRENT_TIMESTAMP`.
- [ ] For invoice totals, independently inspect several invoices and their lines. Confirm whether the stored total equals the sum of `UnitPrice * Quantity` rounded to two decimal places before making a recommendation.
- [ ] Record the MySQL version, actual results, assumptions, and errors in `reports/results_template.md`.
- [ ] Update `reports/data_quality_findings.md` only from inspected results. Preserve “awaiting verification” for checks not run.

## Capture genuine screenshots

Use VS Code with SQLTools visible. Capture the query text and its actual SQLTools result grid in the same image where practical; crop unrelated desktop content, but do not edit or synthesize result values.

1. Run Task 1 (trimmed email projection) or Task 5 (date projection). Save the genuine query plus result view as `screenshots/original-task-results.png`.
2. Run one meaningful additional check, preferably normalized duplicate email groups or the invoice reconciliation. Save the query plus actual result view as `screenshots/additional-check-results.png`.
3. After populating the findings report, capture its verified summary in VS Code as `screenshots/verified-findings-summary.png` (or use a real spreadsheet/report view if that is where you present the recorded results).
4. Add links to these files in the README only after the image files exist. Do not add blank placeholders or use sample/expected output as evidence.

## What execution can establish

Successful execution confirms syntax and object names for the connected local schema. It does not alone establish that a returned row is wrong, that an address is deliverable, that customer profiles represent the same person, or that the invoice reconciliation rule is correct. Interpret results with the schema, source context, and assumptions recorded in the findings report.
