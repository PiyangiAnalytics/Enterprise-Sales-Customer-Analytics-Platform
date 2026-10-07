CREATE SCHEMA erp;
GO

CREATE VIEW erp.SalesOrder AS
SELECT SalesOrderID, CustomerID, OrderDate, TotalDue AS Revenue,
       ModifiedDate, CreatedDate, IsDeleted
FROM Sales.SalesOrderHeader;
GO

CREATE VIEW erp.SalesOrderLine AS
SELECT SalesOrderDetailID, SalesOrderID, ProductID,
       OrderQty AS Quantity, UnitPrice, UnitPriceDiscount AS Discount,
       LineTotal AS LineRevenue, ModifiedDate, CreatedDate, IsDeleted
FROM Sales.SalesOrderDetail;
GO

CREATE VIEW erp.Product AS
SELECT ProductID, Name AS ProductName, ProductNumber, ProductSubcategoryID,
       StandardCost, ListPrice, Color, SellStartDate, SellEndDate, DiscontinuedDate,
       ModifiedDate, CreatedDate, IsDeleted
FROM Production.Product;
GO

CREATE VIEW erp.ProductCategory AS
SELECT sc.ProductSubcategoryID, sc.Name AS SubcategoryName,
       c.ProductCategoryID, c.Name AS CategoryName,
       sc.ModifiedDate, sc.CreatedDate, sc.IsDeleted
FROM Production.ProductSubcategory sc
JOIN Production.ProductCategory c ON sc.ProductCategoryID = c.ProductCategoryID;
GO

CREATE VIEW erp.Inventory AS
SELECT ProductID, LocationID, Shelf, Bin, Quantity AS QuantityOnHand,
       ModifiedDate, CreatedDate, IsDeleted
FROM Production.ProductInventory;
GO

CREATE VIEW erp.Supplier AS
SELECT BusinessEntityID AS SupplierID, Name AS SupplierName, AccountNumber,
       CreditRating, PreferredVendorStatus, ActiveFlag,
       ModifiedDate, CreatedDate, IsDeleted
FROM Purchasing.Vendor;
GO

CREATE VIEW erp.PurchaseOrder AS
SELECT poh.PurchaseOrderID, pod.PurchaseOrderDetailID,
       poh.VendorID AS SupplierID, poh.EmployeeID, poh.Status,
       poh.OrderDate, poh.ShipDate,
       pod.ProductID, pod.OrderQty AS Quantity, pod.UnitPrice,
       pod.LineTotal AS Amount,
       pod.ModifiedDate, pod.CreatedDate, pod.IsDeleted
FROM Purchasing.PurchaseOrderHeader poh
JOIN Purchasing.PurchaseOrderDetail pod ON poh.PurchaseOrderID = pod.PurchaseOrderID;
GO