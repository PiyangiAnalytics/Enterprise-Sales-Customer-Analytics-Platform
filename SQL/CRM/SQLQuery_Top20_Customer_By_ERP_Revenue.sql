SELECT TOP 20
    so.CustomerID,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    c.Region,
    SUM(so.Revenue) AS TotalERPRevenue,
    COALESCE(opp.PipelineValue, 0) AS OpenPipelineValue
FROM ContosoERP.erp.SalesOrder so
JOIN ContosoCRM.dbo.Customer c ON so.CustomerID = c.CustomerID
LEFT JOIN (
    SELECT CustomerID, SUM(EstimatedValue) AS PipelineValue
    FROM ContosoCRM.dbo.Opportunity
    WHERE Stage NOT IN ('Closed Won','Closed Lost')
    GROUP BY CustomerID
) opp ON so.CustomerID = opp.CustomerID
GROUP BY so.CustomerID, c.FirstName, c.LastName, c.Region, opp.PipelineValue
ORDER BY TotalERPRevenue DESC;