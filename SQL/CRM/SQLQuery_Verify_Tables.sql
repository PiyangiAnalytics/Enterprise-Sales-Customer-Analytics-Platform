SELECT t.name AS table_name, COUNT(c.column_id) AS column_count
FROM sys.tables t JOIN sys.columns c ON t.object_id = c.object_id
GROUP BY t.name ORDER BY t.name;