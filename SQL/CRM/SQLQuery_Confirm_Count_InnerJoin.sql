SELECT COUNT(*) FROM dbo.Opportunity o
INNER JOIN dbo.Customer c ON o.CustomerID = c.CustomerID
INNER JOIN dbo.SalesRepresentative r ON o.RepID = r.RepID;