# Enterprise Sales & Customer Analytics Platform

An end-to-end enterprise analytics platform for a fictional company, **Contoso Retail & Distribution**, built to learn SQL, Azure, Azure Data Factory, Microsoft Fabric, Data Governance and Power BI as one integrated project rather than separate tutorials.

## Architecture

```
ERP + CRM (SQL Server) → Azure Data Factory → ADLS Gen2 / OneLake
    → Fabric Lakehouse (Bronze → Silver → Gold) → Fabric Warehouse
    → Semantic Model → Power BI
```

Data Governance (ownership, classification, quality, lineage, access control, PII protection) wraps around every stage. See `Architecture/` for the full diagram.

## Data sources

- **ERP:** SalesOrder, SalesOrderLine, Product, ProductCategory, Inventory, Supplier, PurchaseOrder — seeded from the AdventureWorks (OLTP) sample database.
- **CRM:** Customer, Lead, Opportunity, Campaign, CustomerInteraction, SalesRepresentative — synthetically generated with Python/Faker, keyed to the same customer IDs used on the ERP side.
- **External:** exchange rates, calendar/date dimension, product/category reference data.

## Repository structure

| Folder | Contents |
| --- | --- |
| `Architecture/` | Architecture diagram(s) |
| `SQL/ERP`, `SQL/CRM` | Source database DDL and schema scripts |
| `ADF/pipelines`, `ADF/incremental_load` | Azure Data Factory pipeline definitions |
| `Fabric/notebooks`, `Fabric/lakehouse`, `Fabric/warehouse` | Fabric notebooks, Lakehouse (Bronze/Silver/Gold), Warehouse (Gold star schema) |
| `Governance/data_dictionary`, `Governance/governance_framework`, `Governance/data_quality` | Data governance artifacts |
| `PowerBI/dashboards` | Power BI dashboard files |
| `Documentation/` | Learning log, write-ups, phase notes |

## Status

🟡 **Phase 1, Week 1, Day 1** — environment and repository setup in progress.

## Roadmap

Full 16-week phased roadmap: see `Enterprise Sales & Customer Analytics Platform — Roadmap.docx` one level up, or the living Claude Docs version.
