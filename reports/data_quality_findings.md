# Chinook data quality findings

**Status: awaiting local verification.** The SQL has not been executed against the local database in this environment. This report intentionally contains no invented counts or record examples. Fill in results from [`results_template.md`](results_template.md) after running the queries in SQLTools.

## Finding 1: Customer email completeness

- **Quality dimension:** Completeness.
- **SQL check used:** Additional check 1 in `sql/additional_quality_checks.sql`.
- **Actual result/status:** Awaiting local verification.
- **Evidence:** Record NULL, blank, and nonblank email counts from the result grid.
- **Interpretation:** The official Chinook 1.4.5 schema declares `Customer.Email` `NOT NULL`; blank values can still exist. A zero missing count does not prove deliverability.
- **Potential impact:** Missing contact details can impede customer communication or segmentation.
- **Recommended action:** Confirm any candidates against source records before proposing a correction. Keep a cleaned projection in SQL unless a separately authorized data change is justified.
- **Limitations:** Does not verify address ownership, mailbox existence, or business consent.

## Finding 2: Duplicate normalized email addresses

- **Quality dimension:** Uniqueness / consistency.
- **SQL check used:** Additional check 2; compare candidate IDs with check 5.
- **Actual result/status:** Awaiting local verification.
- **Evidence:** Record grouped normalized email values, counts, and customer IDs.
- **Interpretation:** Case- and whitespace-insensitive matches are potential shared addresses, not proof of duplicate people or accounts.
- **Potential impact:** Deduplication based only on email could merge different members of a household.
- **Recommended action:** Review the associated names, addresses, and source context; do not automatically merge or delete.
- **Limitations:** Normalization handles surrounding whitespace and case only; it does not canonicalize provider-specific aliases.

## Finding 3: Email shape review

- **Quality dimension:** Validity (basic format).
- **SQL check used:** Additional check 3.
- **Actual result/status:** Awaiting local verification.
- **Evidence:** Record returned addresses and customer IDs, or note no rows returned.
- **Interpretation:** Returned rows fail the project's intentionally simple one-`@`, non-whitespace, dotted-domain pattern.
- **Potential impact:** Malformed addresses can reduce the reliability of contact workflows.
- **Recommended action:** Verify candidates with authoritative source records before correcting them.
- **Limitations:** A regex cannot prove deliverability or full standards compliance and may flag unusual but valid addresses.

## Finding 4: Customer names and contact/location completeness

- **Quality dimension:** Completeness.
- **SQL check used:** Additional check 4.
- **Actual result/status:** Awaiting local verification.
- **Evidence:** Record affected IDs, fields, and values.
- **Interpretation:** NULL and whitespace-only values are surfaced. The official schema requires first name and last name, but some other listed fields are nullable.
- **Potential impact:** Missing values can affect customer display, grouping, and contact analysis.
- **Recommended action:** Assess each field's business necessity and consult source records; do not infer replacement values.
- **Limitations:** Empty strings and whitespace-only strings are treated as missing for this check, but other placeholder values are not inferred to be missing.

## Finding 5: Candidate repeated customer profiles

- **Quality dimension:** Uniqueness / identity resolution.
- **SQL check used:** Additional check 5.
- **Actual result/status:** Awaiting local verification.
- **Evidence:** Record the normalized grouping fields, customer count, and IDs for each candidate group.
- **Interpretation:** Exact matches across normalized name, email, and address/location are candidates only.
- **Potential impact:** Genuine duplicate accounts could distort customer counts; false positives could wrongly combine distinct people.
- **Recommended action:** Manually compare source records and business context before assigning any duplicate status.
- **Limitations:** Similarity matching is outside this check; blank/null address values can still group otherwise matching profiles.

## Finding 6: Leading or trailing whitespace

- **Quality dimension:** Consistency / usability.
- **SQL check used:** Additional check 6.
- **Actual result/status:** Awaiting local verification.
- **Evidence:** Record table, field, ID, and raw value; inspect whitespace visibly or by character/length in SQLTools if needed.
- **Interpretation:** Binary comparison is used so trailing spaces are not hidden by common MySQL text collations.
- **Potential impact:** Untrimmed values can create inconsistent display and grouping results.
- **Recommended action:** Use `TRIM` in a derived query for analysis; only consider a permanent update with explicit approval, backup, and a documented rule.
- **Limitations:** This checks only selected customer and employee text fields and only leading/trailing spaces handled by `TRIM`.

## Finding 7: Relationship integrity

- **Quality dimension:** Referential integrity.
- **SQL check used:** Additional check 7.
- **Actual result/status:** Awaiting local verification.
- **Evidence:** Record any child row and unresolved parent ID, or note no rows returned.
- **Interpretation:** The official schema declares these foreign keys, so zero orphan rows is expected for an intact import; it does not verify every relationship in Chinook.
- **Potential impact:** Orphan references can break joins, reporting, or application behavior.
- **Recommended action:** Confirm schema constraints and import history before investigating any returned row; do not fabricate a parent or delete the child automatically.
- **Limitations:** The check covers invoice/customer, customer/support-representative, invoice-line/invoice, invoice-line/track, and employee/manager relationships only.

## Finding 8: Invoice and invoice-line numeric values

- **Quality dimension:** Validity / numeric domain.
- **SQL check used:** Additional check 8.
- **Actual result/status:** Awaiting local verification.
- **Evidence:** Record IDs and the NULL/negative values returned.
- **Interpretation:** Negative amounts/quantities are flagged as suspicious for this sales sample. Zero is not flagged because its intended business meaning was not established.
- **Potential impact:** Unexpected signs or missing values can affect sales totals and unit-level analysis.
- **Recommended action:** Verify against the source invoice and schema before changing data.
- **Limitations:** Official schema columns are `NOT NULL`; this remains a defensive check for a nonstandard or altered local copy. It does not test every possible numeric business rule.

## Finding 9: Invoice date review

- **Quality dimension:** Validity / timeliness.
- **SQL check used:** Additional check 9.
- **Actual result/status:** Awaiting local verification.
- **Evidence:** Record returned invoice IDs, dates, and issue labels.
- **Interpretation:** NULL or zero dates are structural candidates; a future date is relative to the time the query runs and needs context.
- **Potential impact:** Incorrect dates can distort period reporting.
- **Recommended action:** Compare flagged dates with the source; document the run time when interpreting future-date results.
- **Limitations:** The official schema requires a date. This does not validate chronology against customer creation, system time zone, or external records.

## Finding 10: Invoice-line presence and total reconciliation

- **Quality dimension:** Completeness and arithmetic consistency.
- **SQL check used:** Additional checks 10a and 10b.
- **Actual result/status:** Awaiting local verification.
- **Evidence:** Record invoices without lines and any stored/calculated total differences.
- **Interpretation:** A missing line or cent-level mismatch is an investigation candidate. The reconciliation assumes total equals `SUM(UnitPrice * Quantity)` rounded to two decimal places.
- **Potential impact:** Unexplained differences may affect revenue summaries or indicate incomplete sample records.
- **Recommended action:** Verify line items and the sample's calculation rules before describing a mismatch as a defect.
- **Limitations:** The assumption should be confirmed for this version; discounts, tax, or rounding at different stages could change the expected equality. Invoices with no lines are separately reported and excluded from the reconciliation query.

## Data handling note

Finding an anomaly, returning a cleaned representation with `TRIM`/`LOWER`/other expressions, and permanently updating a source record are separate actions. This project performs only the first two. It does not change the database.
