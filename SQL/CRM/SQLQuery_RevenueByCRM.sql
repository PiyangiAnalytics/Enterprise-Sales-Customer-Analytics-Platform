SELECT c.Region, COUNT(DISTINCT so.CustomerID) AS Customers, COUNT(so.SalesOrderID) AS Orders, SUM(so.Revenue) AS TotalRevenue
FROM ContosoERP.erp.SalesOrder so
JOIN ContosoCRM.dbo.Customer c ON so.CustomerID = c.CustomerID
WHERE c.IsDeleted = 0
GROUP BY c.Region
ORDER BY TotalRevenue DESC;