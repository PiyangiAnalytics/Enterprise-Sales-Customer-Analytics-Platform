SELECT so.CustomerID, c.FirstName + ' ' + c.LastName AS CustomerName, COUNT(so.SalesOrderID) AS ERPOrders, SUM(so.Revenue) AS ERPRevenue
FROM ContosoERP.erp.SalesOrder so
JOIN ContosoCRM.dbo.Customer c ON so.CustomerID = c.CustomerID
WHERE NOT EXISTS (SELECT 1 FROM ContosoCRM.dbo.Opportunity o WHERE o.CustomerID = so.CustomerID)
GROUP BY so.CustomerID, c.FirstName, c.LastName
ORDER BY ERPRevenue DESC;