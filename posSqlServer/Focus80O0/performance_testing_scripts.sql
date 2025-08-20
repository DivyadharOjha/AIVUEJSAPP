-- ====================================================================
-- PERFORMANCE TESTING SCRIPTS FOR vCore_TranData_0 OPTIMIZATION
-- Test execution times and compare original vs optimized performance
-- ====================================================================

-- Enable execution time statistics
SET STATISTICS TIME ON;
SET STATISTICS IO ON;

PRINT '====================================================================';
PRINT 'PERFORMANCE TESTING SUITE FOR vCore_TranData_0';
PRINT 'Started at: ' + CONVERT(VARCHAR(25), GETDATE(), 121);
PRINT '====================================================================';

-- ====================================================================
-- TEST 1: FULL DATASET RETRIEVAL PERFORMANCE
-- ====================================================================

PRINT '';
PRINT '--- TEST 1: FULL DATASET RETRIEVAL ---';
PRINT 'Testing complete dataset retrieval (168,000+ records)';

-- Test Original View (if exists)
PRINT '';
PRINT 'Testing Original vCore_TranData_0 View:';
BEGIN
    DECLARE @StartTime1 DATETIME2 = GETDATE();
    DECLARE @Count1 BIGINT;
    
    IF OBJECT_ID('vCore_TranData_0', 'V') IS NOT NULL
    BEGIN
        SELECT @Count1 = COUNT(*) FROM vCore_TranData_0;
        DECLARE @Duration1 INT = DATEDIFF(MILLISECOND, @StartTime1, GETDATE());
        PRINT 'Original View - Records: ' + CONVERT(VARCHAR(20), @Count1) + ', Time: ' + CONVERT(VARCHAR(10), @Duration1) + 'ms';
    END
    ELSE
    BEGIN
        PRINT 'Original vCore_TranData_0 view not found - will test against UNION ALL query directly';
    END
END

-- Test Optimized View
PRINT '';
PRINT 'Testing Optimized vCore_TranData_0_Optimized View:';
BEGIN
    DECLARE @StartTime2 DATETIME2 = GETDATE();
    DECLARE @Count2 BIGINT;
    
    SELECT @Count2 = COUNT(*) FROM vCore_TranData_0_Optimized;
    DECLARE @Duration2 INT = DATEDIFF(MILLISECOND, @StartTime2, GETDATE());
    PRINT 'Optimized View - Records: ' + CONVERT(VARCHAR(20), @Count2) + ', Time: ' + CONVERT(VARCHAR(10), @Duration2) + 'ms';
    
    IF @Duration2 <= 3000
        PRINT '✓ PERFORMANCE TARGET ACHIEVED (≤3 seconds)';
    ELSE
        PRINT '✗ Performance target not met - needs further optimization';
END

-- ====================================================================
-- TEST 2: VOUCHER TYPE FILTERING PERFORMANCE
-- ====================================================================

PRINT '';
PRINT '--- TEST 2: VOUCHER TYPE FILTERING ---';
PRINT 'Testing filtered queries by voucher type';

-- Test common voucher type filters
DECLARE @VoucherTypes TABLE (VoucherType INT);
INSERT INTO @VoucherTypes VALUES (256), (512), (768), (3331), (4096);

DECLARE @VT INT;
DECLARE voucher_cursor CURSOR FOR SELECT VoucherType FROM @VoucherTypes;
OPEN voucher_cursor;
FETCH NEXT FROM voucher_cursor INTO @VT;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '';
    PRINT 'Testing Voucher Type: ' + CONVERT(VARCHAR(10), @VT);
    
    -- Test optimized view
    DECLARE @StartTimeVT DATETIME2 = GETDATE();
    DECLARE @CountVT BIGINT;
    
    SELECT @CountVT = COUNT(*) 
    FROM vCore_TranData_0_Optimized 
    WHERE iVoucherType = @VT;
    
    DECLARE @DurationVT INT = DATEDIFF(MILLISECOND, @StartTimeVT, GETDATE());
    PRINT 'VoucherType ' + CONVERT(VARCHAR(10), @VT) + ' - Records: ' + CONVERT(VARCHAR(20), @CountVT) + ', Time: ' + CONVERT(VARCHAR(10), @DurationVT) + 'ms';
    
    FETCH NEXT FROM voucher_cursor INTO @VT;
END

CLOSE voucher_cursor;
DEALLOCATE voucher_cursor;

-- ====================================================================
-- TEST 3: DATE RANGE FILTERING PERFORMANCE
-- ====================================================================

PRINT '';
PRINT '--- TEST 3: DATE RANGE FILTERING ---';
PRINT 'Testing date-based queries';

-- Test recent records (last 30 days equivalent in integer format)
DECLARE @RecentDate BIGINT = CONVERT(BIGINT, CONVERT(VARCHAR(8), DATEADD(DAY, -30, GETDATE()), 112));

PRINT 'Testing recent records (last 30 days equivalent):';
DECLARE @StartTimeDate DATETIME2 = GETDATE();
DECLARE @CountDate BIGINT;

SELECT @CountDate = COUNT(*) 
FROM vCore_TranData_0_Optimized 
WHERE iLocalPOSDate >= @RecentDate;

DECLARE @DurationDate INT = DATEDIFF(MILLISECOND, @StartTimeDate, GETDATE());
PRINT 'Recent Records - Count: ' + CONVERT(VARCHAR(20), @CountDate) + ', Time: ' + CONVERT(VARCHAR(10), @DurationDate) + 'ms';

-- ====================================================================
-- TEST 4: COMPLEX FILTERING PERFORMANCE
-- ====================================================================

PRINT '';
PRINT '--- TEST 4: COMPLEX FILTERING ---';
PRINT 'Testing multi-column filtered queries';

-- Test complex filter (voucher type + date + invoice)
PRINT 'Testing complex multi-column filter:';
DECLARE @StartTimeComplex DATETIME2 = GETDATE();
DECLARE @CountComplex BIGINT;

SELECT @CountComplex = COUNT(*) 
FROM vCore_TranData_0_Optimized 
WHERE iVoucherType IN (256, 512, 768, 3331, 4096)
  AND iLocalPOSDate >= @RecentDate
  AND InvoiceNo IS NOT NULL;

DECLARE @DurationComplex INT = DATEDIFF(MILLISECOND, @StartTimeComplex, GETDATE());
PRINT 'Complex Filter - Records: ' + CONVERT(VARCHAR(20), @CountComplex) + ', Time: ' + CONVERT(VARCHAR(10), @DurationComplex) + 'ms';

-- ====================================================================
-- TEST 5: JOIN PERFORMANCE SIMULATION
-- ====================================================================

PRINT '';
PRINT '--- TEST 5: JOIN PERFORMANCE SIMULATION ---';
PRINT 'Testing query that simulates real-world usage with JOINs';

-- Simulate a common business query
PRINT 'Testing business-like query with aggregation:';
DECLARE @StartTimeJoin DATETIME2 = GETDATE();

SELECT 
    iVoucherType,
    COUNT(*) AS TransactionCount,
    COUNT(DISTINCT iCreatedUser) AS UniqueUsers,
    AVG(CAST(fCashPaid AS FLOAT)) AS AvgCashPaid
FROM vCore_TranData_0_Optimized 
WHERE iLocalPOSDate >= @RecentDate
GROUP BY iVoucherType
ORDER BY TransactionCount DESC;

DECLARE @DurationJoin INT = DATEDIFF(MILLISECOND, @StartTimeJoin, GETDATE());
PRINT 'Business Query - Time: ' + CONVERT(VARCHAR(10), @DurationJoin) + 'ms';

-- ====================================================================
-- TEST 6: PAGINATION PERFORMANCE
-- ====================================================================

PRINT '';
PRINT '--- TEST 6: PAGINATION PERFORMANCE ---';
PRINT 'Testing pagination scenarios (OFFSET/FETCH)';

-- Test pagination performance
PRINT 'Testing pagination (first 1000 records):';
DECLARE @StartTimePage DATETIME2 = GETDATE();

SELECT TOP 1000 
    iBodyId, InvoiceNo, iVoucherType, iCreatedUser, sNarration
FROM vCore_TranData_0_Optimized 
ORDER BY iBodyId;

DECLARE @DurationPage INT = DATEDIFF(MILLISECOND, @StartTimePage, GETDATE());
PRINT 'Pagination Query - Time: ' + CONVERT(VARCHAR(10), @DurationPage) + 'ms';

-- Test deep pagination
PRINT 'Testing deep pagination (records 50,000-51,000):';
DECLARE @StartTimeDeepPage DATETIME2 = GETDATE();

SELECT 
    iBodyId, InvoiceNo, iVoucherType, iCreatedUser, sNarration
FROM vCore_TranData_0_Optimized 
ORDER BY iBodyId
OFFSET 50000 ROWS
FETCH NEXT 1000 ROWS ONLY;

DECLARE @DurationDeepPage INT = DATEDIFF(MILLISECOND, @StartTimeDeepPage, GETDATE());
PRINT 'Deep Pagination Query - Time: ' + CONVERT(VARCHAR(10), @DurationDeepPage) + 'ms';

-- ====================================================================
-- TEST 7: SEARCH PERFORMANCE
-- ====================================================================

PRINT '';
PRINT '--- TEST 7: SEARCH PERFORMANCE ---';
PRINT 'Testing text search scenarios';

-- Test invoice number search
PRINT 'Testing invoice number search (pattern matching):';
DECLARE @StartTimeSearch DATETIME2 = GETDATE();
DECLARE @CountSearch BIGINT;

SELECT @CountSearch = COUNT(*) 
FROM vCore_TranData_0_Optimized 
WHERE InvoiceNo LIKE '%POS%';

DECLARE @DurationSearch INT = DATEDIFF(MILLISECOND, @StartTimeSearch, GETDATE());
PRINT 'Invoice Search - Records: ' + CONVERT(VARCHAR(20), @CountSearch) + ', Time: ' + CONVERT(VARCHAR(10), @DurationSearch) + 'ms';

-- ====================================================================
-- TEST 8: STRESS TEST - CONCURRENT QUERIES
-- ====================================================================

PRINT '';
PRINT '--- TEST 8: STRESS TEST SIMULATION ---';
PRINT 'Testing multiple concurrent query patterns';

-- Simulate multiple different queries in sequence
DECLARE @StressStartTime DATETIME2 = GETDATE();

-- Query 1: Count by voucher type
SELECT COUNT(*) FROM vCore_TranData_0_Optimized WHERE iVoucherType = 256;

-- Query 2: Recent transactions
SELECT TOP 100 * FROM vCore_TranData_0_Optimized WHERE iLocalPOSDate >= @RecentDate ORDER BY iBodyId DESC;

-- Query 3: User activity
SELECT iCreatedUser, COUNT(*) FROM vCore_TranData_0_Optimized WHERE iCreatedUser > 0 GROUP BY iCreatedUser;

-- Query 4: Invoice lookup
SELECT * FROM vCore_TranData_0_Optimized WHERE InvoiceNo IS NOT NULL AND LEN(InvoiceNo) > 5;

-- Query 5: Complex aggregation
SELECT 
    iVoucherType, 
    COUNT(*) as TxnCount,
    SUM(CAST(fCashPaid AS FLOAT)) as TotalCash
FROM vCore_TranData_0_Optimized 
WHERE iVoucherType IN (256, 512, 768)
GROUP BY iVoucherType;

DECLARE @StressDuration INT = DATEDIFF(MILLISECOND, @StressStartTime, GETDATE());
PRINT 'Stress Test (5 sequential queries) - Total Time: ' + CONVERT(VARCHAR(10), @StressDuration) + 'ms';

-- ====================================================================
-- PERFORMANCE SUMMARY AND RECOMMENDATIONS
-- ====================================================================

PRINT '';
PRINT '====================================================================';
PRINT 'PERFORMANCE TESTING COMPLETED';
PRINT 'Completed at: ' + CONVERT(VARCHAR(25), GETDATE(), 121);
PRINT '====================================================================';

-- Generate performance summary
SELECT 
    'PERFORMANCE SUMMARY' AS ReportSection,
    'Total Records' AS Metric,
    COUNT(*) AS Value
FROM vCore_TranData_0_Ultra_Fast

UNION ALL

SELECT 
    'PERFORMANCE SUMMARY' AS ReportSection,
    'Unique Voucher Types' AS Metric,
    COUNT(DISTINCT iVoucherType) AS Value
FROM vCore_TranData_0_Ultra_Fast

UNION ALL

SELECT 
    'PERFORMANCE SUMMARY' AS ReportSection,
    'Table Size (MB)' AS Metric,
    (SUM(reserved_page_count) * 8.0 / 1024) AS Value
FROM sys.dm_db_partition_stats 
WHERE object_id = OBJECT_ID('vCore_TranData_0_Ultra_Fast');

-- Check if performance targets are met
IF EXISTS (
    SELECT 1 FROM vCore_TranData_0_Ultra_Fast 
    HAVING COUNT(*) >= 150000  -- Expecting 168,000+ records
)
BEGIN
    PRINT '';
    PRINT '✓ DATA VOLUME TARGET: ACHIEVED (≥150,000 records)';
END
ELSE
BEGIN
    PRINT '';
    PRINT '✗ DATA VOLUME TARGET: NOT MET (<150,000 records)';
END

PRINT '';
PRINT 'OPTIMIZATION RECOMMENDATIONS:';
PRINT '1. Monitor query execution plans for any full table scans';
PRINT '2. Consider adding application-specific indexes based on usage patterns';
PRINT '3. Schedule regular incremental refreshes (every few hours)';
PRINT '4. Monitor index fragmentation and rebuild when >30%';
PRINT '5. Consider partitioning if data grows beyond 1 million records';
PRINT '';
PRINT '====================================================================';

-- Disable statistics
SET STATISTICS TIME OFF;
SET STATISTICS IO OFF;

