WITH ERPTotals AS (
    SELECT CustomerID, COUNT(*) AS OrderCount, SUM(Revenue) AS TotalRevenue
    FROM ContosoERP.erp.SalesOrder
    GROUP BY CustomerID
),
CRMTotals AS (
    SELECT CustomerID, COUNT(*) AS OpportunityCount, SUM(EstimatedValue) AS TotalPipelineValue
    FROM ContosoCRM.dbo.Opportunity
    GROUP BY CustomerID
)
SELECT TOP 20
    c.CustomerID, c.FirstName + ' ' + c.LastName AS CustomerName, c.Region,
    COALESCE(e.OrderCount, 0) AS ERPOrders, COALESCE(e.TotalRevenue, 0) AS ERPRevenue,
    COALESCE(o.OpportunityCount, 0) AS CRMOpportunities, COALESCE(o.TotalPipelineValue, 0) AS CRMPipelineValue
FROM ContosoCRM.dbo.Customer c
LEFT JOIN ERPTotals e ON c.CustomerID = e.CustomerID
LEFT JOIN CRMTotals o ON c.CustomerID = o.CustomerID
WHERE c.IsDeleted = 0
ORDER BY ERPRevenue DESC;