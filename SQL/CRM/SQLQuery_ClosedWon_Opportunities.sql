SELECT o.OpportunityID, o.CustomerID, c.FirstName + ' ' + c.LastName AS CustomerName, o.EstimatedValue, o.CloseDate
FROM ContosoCRM.dbo.Opportunity o
JOIN ContosoCRM.dbo.Customer c ON o.CustomerID = c.CustomerID
WHERE o.Stage = 'Closed Won'
  AND NOT EXISTS (SELECT 1 FROM ContosoERP.erp.SalesOrder so WHERE so.CustomerID = o.CustomerID)
ORDER BY o.EstimatedValue DESC;