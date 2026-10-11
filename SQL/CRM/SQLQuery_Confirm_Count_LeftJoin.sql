SELECT o.OpportunityID, o.CustomerID, c.FirstName, c.LastName
FROM dbo.Opportunity o
LEFT JOIN dbo.Customer c ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;