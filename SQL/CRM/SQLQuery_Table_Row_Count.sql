SELECT 'SalesRepresentative', COUNT(*) FROM dbo.SalesRepresentative
UNION ALL SELECT 'Campaign', COUNT(*) FROM dbo.Campaign
UNION ALL SELECT 'Customer', COUNT(*) FROM dbo.Customer
UNION ALL SELECT 'Lead', COUNT(*) FROM dbo.Lead
UNION ALL SELECT 'Opportunity', COUNT(*) FROM dbo.Opportunity
UNION ALL SELECT 'CustomerInteraction', COUNT(*) FROM dbo.CustomerInteraction;