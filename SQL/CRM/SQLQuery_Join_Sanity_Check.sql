SELECT TOP 20 c.CustomerID, c.FirstName + ' ' + c.LastName AS CustomerName,
    o.OpportunityID, o.Stage, o.EstimatedValue, r.FirstName + ' ' + r.LastName AS SalesRep, r.Region
FROM dbo.Opportunity o
INNER JOIN dbo.Customer c ON o.CustomerID = c.CustomerID
INNER JOIN dbo.SalesRepresentative r ON o.RepID = r.RepID
ORDER BY o.EstimatedValue DESC;