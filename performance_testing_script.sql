-- Performance Testing and Comparison Script
-- This script will help you measure the performance improvements

-- Step 1: Enable performance monitoring
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

-- Step 2: Test Original Query Performance (Baseline)
PRINT '=== TESTING ORIGINAL QUERY ===';
DECLARE @StartTime1 DATETIME2 = GETDATE();
DECLARE @EndTime1 DATETIME2;

-- Test with a smaller subset first
SELECT TOP 100 
    p.iMasterId,
    p.sName,
    p.sCode,
    p.iProductType,
    CASE ISNULL(p.iProductType,1) 
        WHEN 1 THEN N'Service' 
        WHEN 2 THEN N'Raw material'
        WHEN 3 THEN N'Intermediate item' 
        WHEN 4 THEN N'Finished goods' 
        WHEN 5 THEN N'Non stock item' 
        WHEN 6 THEN N'Modifier' 
        WHEN 7 THEN N'PRT Consumable' 
        WHEN 8 THEN N'PRT Tools' 
        WHEN 9 THEN N'Ticket' 
        ELSE '' 
    END as iProductTypeName
FROM mCore_Product p WITH(NOLOCK)
WHERE p.iStatus < 5;

SET @EndTime1 = GETDATE();
PRINT 'Original Query (100 rows): ' + CAST(DATEDIFF(MILLISECOND, @StartTime1, @EndTime1) AS VARCHAR(10)) + ' ms';

-- Step 3: Test Optimized View Performance
PRINT '=== TESTING OPTIMIZED VIEW ===';
DECLARE @StartTime2 DATETIME2 = GETDATE();
DECLARE @EndTime2 DATETIME2;

SELECT TOP 100 
    iMasterId,
    sName,
    sCode,
    iProductType,
    iProductTypeName
FROM vmCore_Product_Optimized
WHERE iStatus < 5;

SET @EndTime2 = GETDATE();
PRINT 'Optimized View (100 rows): ' + CAST(DATEDIFF(MILLISECOND, @StartTime2, @EndTime2) AS VARCHAR(10)) + ' ms';

-- Step 4: Test Ultra Optimized View Performance
PRINT '=== TESTING ULTRA OPTIMIZED VIEW ===';
DECLARE @StartTime3 DATETIME2 = GETDATE();
DECLARE @EndTime3 DATETIME2;

SELECT TOP 100 
    iMasterId,
    sName,
    sCode,
    iProductType,
    iProductTypeName
FROM vmCore_Product_Ultra_Optimized
WHERE iStatus < 5;

SET @EndTime3 = GETDATE();
PRINT 'Ultra Optimized View (100 rows): ' + CAST(DATEDIFF(MILLISECOND, @StartTime3, @EndTime3) AS VARCHAR(10)) + ' ms';

-- Step 5: Test Materialized Table Performance
PRINT '=== TESTING MATERIALIZED TABLE ===';
DECLARE @StartTime4 DATETIME2 = GETDATE();
DECLARE @EndTime4 DATETIME2;

SELECT TOP 100 
    iMasterId,
    sName,
    sCode,
    iProductType,
    iProductTypeName
FROM vmCore_Product_Materialized
WHERE iStatus < 5;

SET @EndTime4 = GETDATE();
PRINT 'Materialized Table (100 rows): ' + CAST(DATEDIFF(MILLISECOND, @StartTime4, @EndTime4) AS VARCHAR(10)) + ' ms';

-- Step 6: Test Full Dataset Performance (if data size allows)
PRINT '=== TESTING FULL DATASET PERFORMANCE ===';

-- Count total records
DECLARE @StartTime5 DATETIME2 = GETDATE();
DECLARE @EndTime5 DATETIME2;

SELECT COUNT(*) as TotalRecords FROM vmCore_Product_Ultra_Optimized;

SET @EndTime5 = GETDATE();
PRINT 'Full Dataset Count: ' + CAST(DATEDIFF(MILLISECOND, @StartTime5, @EndTime5) AS VARCHAR(10)) + ' ms';

-- Step 7: Performance Analysis
PRINT '=== PERFORMANCE ANALYSIS ===';
DECLARE @OriginalTime INT = DATEDIFF(MILLISECOND, @StartTime1, @EndTime1);
DECLARE @OptimizedTime INT = DATEDIFF(MILLISECOND, @StartTime2, @EndTime2);
DECLARE @UltraTime INT = DATEDIFF(MILLISECOND, @StartTime3, @EndTime3);
DECLARE @MaterializedTime INT = DATEDIFF(MILLISECOND, @StartTime4, @EndTime4);

PRINT 'Performance Improvement Analysis:';
PRINT 'Original Query: ' + CAST(@OriginalTime AS VARCHAR(10)) + ' ms';
PRINT 'Optimized View: ' + CAST(@OptimizedTime AS VARCHAR(10)) + ' ms';
PRINT 'Ultra Optimized: ' + CAST(@UltraTime AS VARCHAR(10)) + ' ms';
PRINT 'Materialized Table: ' + CAST(@MaterializedTime AS VARCHAR(10)) + ' ms';

IF @OriginalTime > 0
BEGIN
    DECLARE @OptimizedImprovement DECIMAL(5,2) = ((@OriginalTime - @OptimizedTime) * 100.0) / @OriginalTime;
    DECLARE @UltraImprovement DECIMAL(5,2) = ((@OriginalTime - @UltraTime) * 100.0) / @OriginalTime;
    DECLARE @MaterializedImprovement DECIMAL(5,2) = ((@OriginalTime - @MaterializedTime) * 100.0) / @OriginalTime;
    
    PRINT 'Improvement vs Original:';
    PRINT 'Optimized View: ' + CAST(@OptimizedImprovement AS VARCHAR(10)) + '% faster';
    PRINT 'Ultra Optimized: ' + CAST(@UltraImprovement AS VARCHAR(10)) + '% faster';
    PRINT 'Materialized Table: ' + CAST(@MaterializedImprovement AS VARCHAR(10)) + '% faster';
END

-- Step 8: Test Specific Use Cases
PRINT '=== TESTING SPECIFIC USE CASES ===';

-- Test filtering by status
DECLARE @StartTime6 DATETIME2 = GETDATE();
SELECT COUNT(*) FROM vmCore_Product_Ultra_Optimized WHERE iStatus = 1;
DECLARE @EndTime6 DATETIME2 = GETDATE();
PRINT 'Filter by Status=1: ' + CAST(DATEDIFF(MILLISECOND, @StartTime6, @EndTime6) AS VARCHAR(10)) + ' ms';

-- Test filtering by category
DECLARE @StartTime7 DATETIME2 = GETDATE();
SELECT COUNT(*) FROM vmCore_Product_Ultra_Optimized WHERE iCategory IS NOT NULL;
DECLARE @EndTime7 DATETIME2 = GETDATE();
PRINT 'Filter by Category: ' + CAST(DATEDIFF(MILLISECOND, @StartTime7, @EndTime7) AS VARCHAR(10)) + ' ms';

-- Test searching by name
DECLARE @StartTime8 DATETIME2 = GETDATE();
SELECT TOP 10 iMasterId, sName, sCode FROM vmCore_Product_Ultra_Optimized WHERE sName LIKE '%Product%';
DECLARE @EndTime8 DATETIME2 = GETDATE();
PRINT 'Search by Name: ' + CAST(DATEDIFF(MILLISECOND, @StartTime8, @EndTime8) AS VARCHAR(10)) + ' ms';

-- Step 9: Memory and CPU Usage Analysis
PRINT '=== MEMORY AND CPU ANALYSIS ===';

-- Check index usage
SELECT 
    OBJECT_NAME(i.object_id) as TableName,
    i.name as IndexName,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups,
    ius.user_updates,
    ius.last_user_seek,
    ius.last_user_scan
FROM sys.dm_db_index_usage_stats ius
INNER JOIN sys.indexes i ON ius.object_id = i.object_id AND ius.index_id = i.index_id
WHERE OBJECT_NAME(i.object_id) LIKE '%Product%'
ORDER BY ius.user_seeks + ius.user_scans DESC;

-- Check index fragmentation
SELECT 
    OBJECT_NAME(ind.OBJECT_ID) AS TableName,
    ind.name AS IndexName,
    indexstats.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, NULL) indexstats
INNER JOIN sys.indexes ind ON ind.object_id = indexstats.object_id AND ind.index_id = indexstats.index_id
WHERE OBJECT_NAME(ind.OBJECT_ID) LIKE '%Product%'
ORDER BY indexstats.avg_fragmentation_in_percent DESC;

-- Step 10: Recommendations
PRINT '=== RECOMMENDATIONS ===';
PRINT '1. Use vmCore_Product_Ultra_Optimized for general queries';
PRINT '2. Use vmCore_Product_Materialized for read-heavy operations';
PRINT '3. Schedule regular index maintenance (REBUILD/REORGANIZE)';
PRINT '4. Monitor index fragmentation monthly';
PRINT '5. Update statistics weekly for optimal query plans';

-- Step 11: Cleanup (optional - uncomment if needed)
-- SET STATISTICS TIME OFF;
-- SET STATISTICS IO OFF;

PRINT '=== PERFORMANCE TESTING COMPLETE ===';
