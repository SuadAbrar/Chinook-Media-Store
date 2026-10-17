# Chinook SQL Data Quality Audit

A beginner portfolio project that uses MySQL to investigate data quality in the Chinook sample digital media store. It pairs ten SQL transformation exercises with read-only checks for customer contact data, relationships, invoice values, and invoice-line consistency.

## Analytical question

Can a user prepare common customer and invoice fields for analysis, then identify records that merit review without changing the source database or treating every unusual value as an error?

## Objectives

- Demonstrate SQL selection, string functions, date conversion, casting, aggregation, joins, grouping, and conditional logic.
- Distinguish a potential anomaly from a confirmed defect.
- Record results and recommendations from reproducible queries.
- Keep source data unchanged: all project queries are `SELECT` statements.

## Dataset and source

Chinook is a sample digital media store database with customers, employees, invoices, tracks, and related tables. This repository contains analysis queries and documentation; the database runs locally in MySQL and is not included here.

Use the [official Chinook database repository](https://github.com/lerocha/chinook-database) and its [MIT license](https://github.com/lerocha/chinook-database/blob/master/LICENSE.md). The project links to the upstream source instead of redistributing a database dump. The checks were reviewed against the upstream [MySQL schema script](https://github.com/lerocha/chinook-database/blob/v1.4.5/ChinookDatabase/DataSources/Chinook_MySql.sql) for Chinook version 1.4.5.

## Tools and techniques

- MySQL (use MySQL 8 or later for the regular-expression check)
- Visual Studio Code with SQLTools and a MySQL driver
- String cleanup and formatting: `TRIM`, `LOWER`, `UPPER`, `CONCAT`, `SUBSTRING`
- Date and type conversion: `DATE`, `CAST`
- Quality checks: NULL/blank handling, normalized grouping, `REGEXP`, `LEFT JOIN`, aggregate reconciliation

## Repository layout

```text
README.md
sql/
  data_quality_audit.sql          # the original ten transformation exercises
  additional_quality_checks.sql   # separate read-only investigation queries
reports/
  data_quality_findings.md        # evidence-based findings (awaiting local results)
  results_template.md              # record query outputs and interpretation
  validation_checklist.md          # execution and review steps
screenshots/
  .gitkeep                         # placeholder; add genuine SQLTools captures here
```

Local SQLTools connection settings are excluded from Git. Do not add passwords, private connection profiles, database dumps, or environment files to this repository.

## Prerequisites

- A running local MySQL Server.
- The Chinook database installed locally and named `Chinook`.
- Visual Studio Code with SQLTools and its MySQL/MariaDB driver.

## Set up the database

If `Chinook` is already installed locally, skip to **Run the audit**. Otherwise:

1. Open the [official Chinook releases](https://github.com/lerocha/chinook-database/releases) and download `Chinook_MySql.sql` from release 1.4.5.
2. Read the script header before running it. The official script **drops and recreates a database named `Chinook`**. Run it only on a disposable/new local setup or after backing up anything that must be preserved. Never run it over a database you need to keep.
3. In VS Code, connect SQLTools to your local MySQL server, open the downloaded script, and execute it with the connection selected. The script creates and populates `Chinook`.
4. Confirm that the database appears in the SQLTools explorer and that tables such as `Customer`, `Invoice`, and `InvoiceLine` are present.

The similarly named `Chinook_MySql_AutoIncrementPKs.sql` creates `Chinook_AutoIncrement`, not `Chinook`; use the non-AutoIncrement script above for these project queries.

## Run the audit in VS Code

1. Create or select a SQLTools connection to the local MySQL server and choose the `Chinook` database. Keep its password in SQLTools' secret storage or prompt; do not commit connection settings.
2. Open `sql/data_quality_audit.sql` and execute one statement or the full file. Review the result grid for each task.
3. Open `sql/additional_quality_checks.sql` and run the checks individually. Some return candidate records; a nonempty result calls for interpretation, not automatic cleanup.
4. Record the run date, MySQL version, actual counts/examples, and observations in [`reports/results_template.md`](reports/results_template.md).
5. Update [`reports/data_quality_findings.md`](reports/data_quality_findings.md) only after checking the actual result rows and relevant schema/data context.

All included project queries are read-only. A trimmed or reformatted value is a derived result, not a change to a stored row. Do not use an `UPDATE` as part of this audit.

## Findings and recommendations

**No query results have been captured for this project yet.** This workspace did not have an accessible MySQL client or reachable local MySQL port during preparation, so findings remain explicitly marked **awaiting local verification**. No counts, defects, or recommendations about specific Chinook records are claimed. After execution, summarize only observed results in the findings report and distinguish an anomaly from a confirmed issue.

## Assumptions and limitations

- The analysis targets the official Chinook 1.4.5 MySQL schema. The provided schema marks customer names/email, invoice date/total, and invoice-line price/quantity as `NOT NULL`, and declares the audited foreign keys. These checks are still useful if the local copy differs, constraints were disabled during import, or data was altered.
- The email regular expression is a simple shape check, not full RFC validation, domain verification, or proof of deliverability.
- Matching normalized email or profile attributes identifies candidates for review. Shared addresses, household details, and repeated names may be legitimate.
- The invoice reconciliation assumes `Invoice.Total` equals the sum of `InvoiceLine.UnitPrice * Quantity`, rounded to two decimal places. Verify this rule and local results before treating a mismatch as an error.
- The Chinook sample is designed for learning, not as a representative production customer dataset. Location, invoice, and contact patterns should not be generalized to a real business.

## Screenshots

No screenshots are included because no query results were available to capture. Follow the genuine-capture checklist in [`reports/validation_checklist.md`](reports/validation_checklist.md) and save unaltered SQLTools screenshots under `screenshots/` before referencing them here.

## Useful next steps

- Execute the validation checklist and attach real result screenshots.
- Refine findings from observed results, including a clear “no issue detected” result where supported.
- If expanding the project, add a small verified summary of affected records and an explanation of business impact rather than adding more checks without a clear purpose.
