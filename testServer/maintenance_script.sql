-- Maintenance Script for vmCore_Product Optimization
-- Automated refresh and monitoring of the materialized table

-- Step 1: Create maintenance procedure
CREATE OR ALTER PROCEDURE sp_Maintain_Ultimate_Products
    @RefreshData bit = 1,
    @UpdateStatistics bit = 1,
    @CheckPerformance bit = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StartTime datetime2 = GETDATE();
    DECLARE @EndTime datetime2;
    DECLARE @Duration int;
    DECLARE @RecordCount int;
    
    PRINT '=== MAINTENANCE PROCEDURE STARTED ===';
    PRINT 'Start Time: ' + CAST(@StartTime AS VARCHAR(30));
    PRINT '';
    
    -- Step 1: Refresh data if requested
    IF @RefreshData = 1
    BEGIN
        PRINT 'Step 1: Refreshing materialized table data...';
        EXEC sp_Populate_Ultimate_Products;
        
        SELECT @RecordCount = COUNT(*) FROM vmCore_Product_Ultimate;
        PRINT 'Records in materialized table: ' + CAST(@RecordCount AS VARCHAR(20));
        PRINT '';
    END
    
    -- Step 2: Update statistics if requested
    IF @UpdateStatistics = 1
    BEGIN
        PRINT 'Step 2: Updating statistics...';
        
        UPDATE STATISTICS vmCore_Product_Ultimate WITH FULLSCAN, ALL;
        UPDATE STATISTICS mCore_Product WITH FULLSCAN, ALL;
        UPDATE STATISTICS muCore_Product WITH FULLSCAN, ALL;
        UPDATE STATISTICS mCore_ProductTreeDetails WITH FULLSCAN, ALL;
        
        PRINT 'Statistics updated successfully.';
        PRINT '';
    END
    
    -- Step 3: Performance check if requested
    IF @CheckPerformance = 1
    BEGIN
        PRINT 'Step 3: Checking performance...';
        
        -- Test query performance
        SET STATISTICS TIME ON;
        
        SELECT COUNT(*) as TotalRecords 
        FROM vmCore_Product_Ultimate_Optimized 
        WHERE iStatus = 1;
        
        SELECT TOP 1000 
            iMasterId, sName, sCode, iProductType, iProductTypeName
        FROM vmCore_Product_Ultimate_Optimized 
        WHERE iStatus = 1
        ORDER BY iMasterId;
        
        SET STATISTICS TIME OFF;
        
        PRINT 'Performance check completed.';
        PRINT '';
    END
    
    -- Step 4: Generate maintenance report
    SET @EndTime = GETDATE();
    SET @Duration = DATEDIFF(SECOND, @StartTime, @EndTime);
    
    PRINT '=== MAINTENANCE REPORT ===';
    PRINT 'Start Time: ' + CAST(@StartTime AS VARCHAR(30));
    PRINT 'End Time: ' + CAST(@EndTime AS VARCHAR(30));
    PRINT 'Duration: ' + CAST(@Duration AS VARCHAR(10)) + ' seconds';
    PRINT 'Records in table: ' + CAST(@RecordCount AS VARCHAR(20));
    PRINT 'Last Updated: ' + CAST((SELECT MAX(LastUpdated) FROM vmCore_Product_Ultimate) AS VARCHAR(30));
    PRINT '';
    
    -- Check table health
    PRINT '=== TABLE HEALTH CHECK ===';
    
    -- Check for fragmentation
    SELECT 
        OBJECT_NAME(ips.object_id) as TableName,
        ips.index_id,
        ips.avg_fragmentation_in_percent,
        ips.page_count
    FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('vmCore_Product_Ultimate'), NULL, NULL, 'LIMITED') ips
    WHERE ips.avg_fragmentation_in_percent > 10;
    
    -- Check index usage
    SELECT 
        OBJECT_NAME(i.object_id) as TableName,
        i.name as IndexName,
        s.user_seeks,
        s.user_scans,
        s.user_lookups,
        s.user_updates,
        s.last_user_seek,
        s.last_user_scan
    FROM sys.dm_db_index_usage_stats s
    INNER JOIN sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id
    WHERE OBJECT_NAME(i.object_id) = 'vmCore_Product_Ultimate'
    ORDER BY s.user_seeks + s.user_scans DESC;
    
    PRINT '=== MAINTENANCE COMPLETED ===';
END;

-- Step 2: Create monitoring procedure
CREATE OR ALTER PROCEDURE sp_Monitor_Ultimate_Products
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT '=== PERFORMANCE MONITORING REPORT ===';
    PRINT 'Generated: ' + CAST(GETDATE() AS VARCHAR(30));
    PRINT '';
    
    -- Table size information
    SELECT 
        'vmCore_Product_Ultimate' as TableName,
        COUNT(*) as RecordCount,
        MAX(LastUpdated) as LastUpdated,
        DATEDIFF(MINUTE, MAX(LastUpdated), GETDATE()) as MinutesSinceLastUpdate
    FROM vmCore_Product_Ultimate;
    
    -- Performance metrics
    PRINT '';
    PRINT '=== PERFORMANCE METRICS ===';
    
    -- Test query execution time
    DECLARE @StartTime datetime2 = GETDATE();
    DECLARE @EndTime datetime2;
    DECLARE @Duration int;
    
    SELECT COUNT(*) FROM vmCore_Product_Ultimate_Optimized WHERE iStatus = 1;
    SET @EndTime = GETDATE();
    SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime);
    
    PRINT 'Active products count query: ' + CAST(@Duration AS VARCHAR(10)) + ' ms';
    
    -- Test complex query
    SET @StartTime = GETDATE();
    SELECT TOP 1000 * FROM vmCore_Product_Ultimate_Optimized WHERE iStatus = 1 AND iProductType IN (1, 4);
    SET @EndTime = GETDATE();
    SET @Duration = DATEDIFF(MILLISECOND, @StartTime, @EndTime);
    
    PRINT 'Complex query (1000 records): ' + CAST(@Duration AS VARCHAR(10)) + ' ms';
    
    -- Index health
    PRINT '';
    PRINT '=== INDEX HEALTH ===';
    
    SELECT 
        i.name as IndexName,
        ips.avg_fragmentation_in_percent as Fragmentation,
        ips.page_count as Pages,
        CASE 
            WHEN ips.avg_fragmentation_in_percent > 30 THEN 'REBUILD NEEDED'
            WHEN ips.avg_fragmentation_in_percent > 10 THEN 'REORGANIZE NEEDED'
            ELSE 'HEALTHY'
        END as Status
    FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('vmCore_Product_Ultimate'), NULL, NULL, 'LIMITED') ips
    INNER JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
    ORDER BY ips.avg_fragmentation_in_percent DESC;
    
    PRINT '';
    PRINT '=== MONITORING COMPLETED ===';
END;

-- Step 3: Create automated refresh job (example)
PRINT '=== AUTOMATED REFRESH JOB SETUP ===';
PRINT 'To set up automated refresh, create a SQL Server Agent job with the following command:';
PRINT 'EXEC sp_Maintain_Ultimate_Products @RefreshData = 1, @UpdateStatistics = 1, @CheckPerformance = 0;';
PRINT '';
PRINT 'Recommended schedule: Every 15-30 minutes during business hours';
PRINT '';

-- Step 4: Quick refresh procedure (for manual use)
CREATE OR ALTER PROCEDURE sp_Quick_Refresh_Ultimate_Products
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT 'Quick refresh started: ' + CAST(GETDATE() AS VARCHAR(30));
    
    EXEC sp_Populate_Ultimate_Products;
    
    PRINT 'Quick refresh completed: ' + CAST(GETDATE() AS VARCHAR(30));
END;

-- Step 5: Usage examples
PRINT '=== USAGE EXAMPLES ===';
PRINT '';
PRINT '1. Full maintenance (refresh + statistics + performance check):';
PRINT '   EXEC sp_Maintain_Ultimate_Products;';
PRINT '';
PRINT '2. Quick refresh only:';
PRINT '   EXEC sp_Quick_Refresh_Ultimate_Products;';
PRINT '';
PRINT '3. Performance monitoring:';
PRINT '   EXEC sp_Monitor_Ultimate_Products;';
PRINT '';
PRINT '4. Refresh data only:';
PRINT '   EXEC sp_Maintain_Ultimate_Products @RefreshData = 1, @UpdateStatistics = 0, @CheckPerformance = 0;';
PRINT '';

PRINT 'Maintenance script setup completed!';
