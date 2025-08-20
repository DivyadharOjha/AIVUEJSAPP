-- Performance Testing Script for vmCore_Product Optimization
-- Compare original query vs optimized materialized table

-- Step 1: Test original query performance
PRINT '=== TESTING ORIGINAL QUERY PERFORMANCE ===';
PRINT 'Testing original vmCore_Product view...';

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

-- Test 1: Full dataset
SELECT COUNT(*) as TotalRecords FROM vmCore_Product WHERE iStatus < 5;

-- Test 2: Active products only
SELECT COUNT(*) as ActiveRecords FROM vmCore_Product WHERE iStatus = 1;

-- Test 3: Sample data retrieval
SELECT TOP 1000 
    iMasterId, sName, sCode, iProductType, iProductTypeName, iStatus, iCategory, iCategoryName
FROM vmCore_Product 
WHERE iStatus = 1
ORDER BY iMasterId;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

PRINT 'Original query tests completed.';
PRINT '';

-- Step 2: Test optimized materialized table performance
PRINT '=== TESTING OPTIMIZED MATERIALIZED TABLE PERFORMANCE ===';
PRINT 'Testing vmCore_Product_Ultimate_Optimized view...';

SET STATISTICS TIME ON;
SET STATISTICS IO ON;

-- Test 1: Full dataset
SELECT COUNT(*) as TotalRecords FROM vmCore_Product_Ultimate_Optimized WHERE iStatus < 5;

-- Test 2: Active products only
SELECT COUNT(*) as ActiveRecords FROM vmCore_Product_Ultimate_Optimized WHERE iStatus = 1;

-- Test 3: Sample data retrieval
SELECT TOP 1000 
    iMasterId, sName, sCode, iProductType, iProductTypeName, iStatus, iCategory, iCategoryName
FROM vmCore_Product_Ultimate_Optimized 
WHERE iStatus = 1
ORDER BY iMasterId;

-- Test 4: Complex filtering
SELECT TOP 1000 
    iMasterId, sName, sCode, iProductType, iProductTypeName, iCategory, iCategoryName, iBin, iBinName
FROM vmCore_Product_Ultimate_Optimized 
WHERE iStatus = 1 
    AND iProductType IN (1, 4)
    AND iCategory IS NOT NULL
ORDER BY iCategory, sName;

-- Test 5: Search functionality
SELECT TOP 1000 
    iMasterId, sName, sCode, iProductType, iProductTypeName, iStatus
FROM vmCore_Product_Ultimate_Optimized 
WHERE iStatus = 1 
    AND (sName LIKE '%test%' OR sCode LIKE '%test%')
ORDER BY sName;

SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

PRINT 'Optimized query tests completed.';
PRINT '';

-- Step 3: Performance comparison summary
PRINT '=== PERFORMANCE COMPARISON SUMMARY ===';

-- Get table sizes
SELECT 
    'vmCore_Product_Ultimate' as TableName,
    COUNT(*) as RecordCount,
    GETDATE() as LastUpdated
FROM vmCore_Product_Ultimate;

-- Get index usage statistics
SELECT 
    OBJECT_NAME(i.object_id) as TableName,
    i.name as IndexName,
    i.type_desc as IndexType,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id
WHERE OBJECT_NAME(i.object_id) LIKE '%Product%'
ORDER BY s.user_seeks + s.user_scans DESC;

PRINT 'Performance testing completed!';
PRINT 'Expected improvement: 90-95% faster execution time';
PRINT 'Target: 2-3 seconds for 90,000 products';
