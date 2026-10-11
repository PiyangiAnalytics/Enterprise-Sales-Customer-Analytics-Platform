-- Opportunity -> Customer: expect 5
SELECT COUNT(*) FROM dbo.Opportunity o LEFT JOIN dbo.Customer c ON o.CustomerID = c.CustomerID WHERE c.CustomerID IS NULL;
-- Opportunity -> SalesRepresentative: expect 0
SELECT COUNT(*) FROM dbo.Opportunity o LEFT JOIN dbo.SalesRepresentative r ON o.RepID = r.RepID WHERE r.RepID IS NULL;
-- CustomerInteraction -> Customer: expect 0
SELECT COUNT(*) FROM dbo.CustomerInteraction i LEFT JOIN dbo.Customer c ON i.CustomerID = c.CustomerID WHERE c.CustomerID IS NULL;
-- CustomerInteraction -> SalesRepresentative: expect 0 (NULL RepID is valid; only a non-null mismatch counts)
SELECT COUNT(*) FROM dbo.CustomerInteraction i LEFT JOIN dbo.SalesRepresentative r ON i.RepID = r.RepID WHERE i.RepID IS NOT NULL AND r.RepID IS NULL;
-- Lead -> Campaign: expect 0 (NULL CampaignID is valid)
SELECT COUNT(*) FROM dbo.Lead l LEFT JOIN dbo.Campaign c ON l.CampaignID = c.CampaignID WHERE l.CampaignID IS NOT NULL AND c.CampaignID IS NULL;