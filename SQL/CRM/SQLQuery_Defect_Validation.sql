USE ContosoCRM;
SELECT COUNT(*) FROM dbo.Customer;     -- ~4005 (real customers + 5 duplicates)
SELECT COUNT(*) FROM dbo.Opportunity;  -- ~3505 (normal + 5 orphans)
SELECT * FROM dbo.Opportunity WHERE CustomerID NOT IN (SELECT CustomerID FROM dbo.Customer); -- the 5 orphans