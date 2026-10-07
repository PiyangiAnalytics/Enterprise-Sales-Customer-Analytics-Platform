SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN ('SalesOrderHeader','SalesOrderDetail','Product','ProductCategory',
                     'ProductSubcategory','ProductInventory','Vendor',
                     'PurchaseOrderHeader','PurchaseOrderDetail')
  AND COLUMN_NAME IN ('ModifiedDate','CreatedDate','IsDeleted','rowguid')
ORDER BY TABLE_NAME, COLUMN_NAME;