# Week 1 — SQL Foundation: ERP/CRM Database & Data Quality

## What got built

- Installed SQL Server 2025 Developer Edition + SSMS; restored AdventureWorks2025 as `ContosoERP` and created `ContosoCRM` fresh.
- Built the `erp` schema: 7 views over the real AdventureWorks tables (`SalesOrder`, `SalesOrderLine`, `Product`, `ProductCategory`, `Inventory`, `Supplier`, `PurchaseOrder`), each exposing clean, renamed business columns plus the same three audit columns (`ModifiedDate`, `CreatedDate`, `IsDeleted`) in the same position every time.
- Designed and built `ContosoCRM`: 6 tables (`SalesRepresentative`, `Customer`, `Campaign`, `Lead`, `Opportunity`, `CustomerInteraction`) with PK/FK relationships, CHECK constraints, and the same audit columns on every table.
- Wrote `SQL/CRM/data_generator.py` (Python/Faker) to generate synthetic CRM data keyed to the real ERP customer universe: 35 reps, 35 campaigns, 19,124 customers (19,119 real + 5 planted duplicates), 3,500 leads, 3,505 opportunities (3,500 clean + 5 planted orphans), 5,000 interactions — loaded into `ContosoCRM`, with 400 deliberately planted data-quality defects logged to `planted_defects.csv`.
- Debugged three real load-script bugs along the way: an `IDENTITY_INSERT` conflict, a `pyodbc`/`fast_executemany` first-row type-inference bug causing a spurious `Datetime field overflow`, and an FK violation caused by accidentally inserting the orphaned rows twice.
- Validated the load end to end: row counts against targets, referential integrity table by table, reconciliation of the planted defects against the database via Python, and a join sanity check across `Customer` + `Opportunity` + `SalesRepresentative`.
- Wrote 5 cross-system queries joining `ContosoERP.erp.SalesOrder` with `ContosoCRM.dbo.Customer`/`Opportunity` using three-part naming, surfacing a CRM coverage gap and a CRM/ERP reconciliation mismatch as real examples of the kind of check Phase 5's governance work will formalize.
- Started `Governance/data_dictionary/data_dictionary.csv`, covering all 119 fields across both schemas in the Roadmap's `Field / Definition / Owner / Classification / Quality Rule` format (plus a `Table` column).
- Sketched Architecture v1 (`Architecture/architecture.png`): both schemas, their internal FK relationships, and the shared `CustomerID` link between them.

## Decisions made

- **AdventureWorks + Faker hybrid.** Real transactional data (ERP) from Microsoft's AdventureWorks2025 sample database, paired with synthetic CRM data generated via Python/Faker and keyed to the real ERP `CustomerID`s. Avoids inventing an unrealistic ERP from scratch while keeping full control over the CRM side's data quality and defects.
- **Shared customer ID space.** `CRM.Customer.CustomerID` was deliberately built *without* an `IDENTITY` property, specifically so the real ERP `CustomerID`s could be inserted directly rather than generating a new, disconnected ID space. This single decision is what made every cross-system join in Day 6 possible.
- **Audit columns on every table and view.** `CreatedDate`, `ModifiedDate`, `IsDeleted` appended consistently everywhere, in anticipation of Phase 2's watermark-based incremental ADF load, which will filter on `ModifiedDate`.
- **No cross-database foreign key between ERP and CRM.** `CustomerID` is a shared *business* key, not a database-enforced FK — SQL Server can't enforce a constraint across two separate databases, which mirrors how real separate ERP/CRM systems actually behave. Integrity between the two has to be checked downstream (as Days 5–6 did manually); ADF/Fabric will need to own this on an ongoing basis.
- **Deliberately broken data, logged as an answer key.** 5 orphaned FKs, 8 impossible dates, 191 missing emails, 191 invalid emails, 5 duplicate customers — all planted on purpose and logged to `planted_defects.csv`, so Phase 5's governance and data-quality work has known ground truth to validate against rather than hoping it finds the right things.

## Open questions for Week 2

- Azure region and resource-group naming (`rg-enterprise-data-platform`) need to be finalized before provisioning anything.
- How will Azure Data Factory actually reach two local SQL Server databases? ADF running in the cloud likely needs a Self-hosted Integration Runtime to connect to a non-cloud SQL Server — needs confirming and setting up early in Week 2, since the whole Phase 1→3 pipeline depends on it.
- Once ERP and CRM are pulled into ADLS Gen2 as separate datasets by two separate pipelines, where does the "shared `CustomerID`" reconciliation actually happen — Bronze (as-is, two separate folders) or Silver (joined/conformed)? Worth deciding before building the medallion layers in Phase 4 rather than improvising it then.
- Cost-management guardrails (budget alerts, which SKUs) before any billable Azure resource gets created.
- Should the other 6 ERP views get a second look for the same kind of grain mismatch `PurchaseOrder` originally had, before they're ingested downstream, or is validating them structurally (like Day 5 did for the CRM tables) sufficient?
