# SQL / ERP

DDL and schema scripts for the ERP side: SalesOrder, SalesOrderLine, Product, ProductCategory, Inventory, Supplier, PurchaseOrder.

Seeded from the AdventureWorks (OLTP) sample database, restored locally as `ContosoERP`. Every table carries `CreatedDate`, `ModifiedDate` and `IsDeleted` audit columns for the Phase 3 incremental-load watermark.
