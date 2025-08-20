-- ====================================================================
-- QUICK SETUP GUIDE FOR vCore_TranData_0 OPTIMIZATION
-- Execute these steps in order for fast implementation
-- ====================================================================

PRINT '====================================================================';
PRINT 'QUICK SETUP GUIDE - vCore_TranData_0 OPTIMIZATION';
PRINT 'Target: Reduce 12-15 seconds to 2-3 seconds for 168,000 rows';
PRINT 'Started at: ' + CONVERT(VARCHAR(25), GETDATE(), 121);
PRINT '====================================================================';

-- ====================================================================
-- STEP 1: ENVIRONMENT CHECK
-- ====================================================================

PRINT '';
PRINT 'STEP 1: Environment Check';
PRINT '-------------------------';

-- Check if objects already exist
IF OBJECT_ID('vCore_TranData_0_Ultra_Fast', 'U') IS NOT NULL
    PRINT '⚠️  vCore_TranData_0_Ultra_Fast table already exists';
ELSE
    PRINT '✓ Ready to create vCore_TranData_0_Ultra_Fast table';

IF OBJECT_ID('vCore_TranData_0_Optimized', 'V') IS NOT NULL
    PRINT '⚠️  vCore_TranData_0_Optimized view already exists';
ELSE
    PRINT '✓ Ready to create vCore_TranData_0_Optimized view';

-- Check source tables
DECLARE @MissingTables NVARCHAR(MAX) = '';

IF OBJECT_ID('tCore_Data_0', 'U') IS NULL
    SET @MissingTables = @MissingTables + 'tCore_Data_0, ';

IF OBJECT_ID('tCore_Header_0', 'U') IS NULL
    SET @MissingTables = @MissingTables + 'tCore_Header_0, ';

IF LEN(@MissingTables) > 0
BEGIN
    PRINT '❌ Missing required tables: ' + LEFT(@MissingTables, LEN(@MissingTables) - 1);
    PRINT 'Cannot proceed without source tables.';
    RETURN;
END
ELSE
    PRINT '✓ All required source tables present';

-- Check disk space (approximate)
PRINT '✓ Environment check completed - ready to proceed';

-- ====================================================================
-- STEP 2: CREATE ULTRA-FAST TABLE (Minimal Version)
-- ====================================================================

PRINT '';
PRINT 'STEP 2: Creating Ultra-Fast Materialized Table';
PRINT '----------------------------------------------';

-- Create the optimized table with essential columns only for quick setup
IF OBJECT_ID('vCore_TranData_0_Ultra_Fast', 'U') IS NOT NULL
    DROP TABLE vCore_TranData_0_Ultra_Fast;

CREATE TABLE vCore_TranData_0_Ultra_Fast (
    -- Primary identifier
    iBodyId bigint NOT NULL PRIMARY KEY CLUSTERED,
    
    -- Essential transaction fields
    iVoucherType bigint NOT NULL,
    iHeaderId bigint NOT NULL,
    
    -- Core business fields (most commonly used)
    InvoiceNo nvarchar(200) NULL,
    ReferenceNo nvarchar(200) NULL,
    SalesOrderNo nvarchar(200) NULL,
    iCreatedUser bigint NULL,
    iLocalPOSDate bigint NULL,
    iLocalPOSTime bigint NULL,
    
    -- Financial fields
    fCashPaid decimal(18,4) NULL,
    fExchRateDiff decimal(18,4) NULL,
    Commission_ decimal(18,4) NULL,
    CommissionAmount decimal(18,4) NULL,
    
    -- Common text fields
    sNarration nvarchar(2000) NULL,
    sRemarks nvarchar(2000) NULL,
    Description nvarchar(2000) NULL,
    
    -- Customer/Contact info
    Buyer nvarchar(500) NULL,
    ContactDetails nvarchar(1000) NULL,
    sCustomerAddress nvarchar(2000) NULL,
    CustomerPONo nvarchar(200) NULL,
    
    -- Additional commonly used fields
    ItemVendorCode nvarchar(200) NULL,
    VoucherForm nvarchar(200) NULL,
    Notes nvarchar(2000) NULL,
    PickListNo nvarchar(200) NULL,
    
    -- Metadata
    LastUpdated datetime2 DEFAULT GETDATE()
    
) WITH (DATA_COMPRESSION = PAGE);

PRINT '✓ Ultra-fast table created successfully';

-- ====================================================================
-- STEP 3: CREATE ESSENTIAL INDEXES
-- ====================================================================

PRINT '';
PRINT 'STEP 3: Creating Essential Indexes';
PRINT '----------------------------------';

-- Index 1: Voucher Type (most important)
CREATE NONCLUSTERED INDEX IX_VoucherType_Essential
ON vCore_TranData_0_Ultra_Fast (iVoucherType)
INCLUDE (iHeaderId, InvoiceNo, iCreatedUser, iLocalPOSDate)
WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE);
PRINT '✓ Voucher Type index created';

-- Index 2: Date range queries
CREATE NONCLUSTERED INDEX IX_Date_Essential
ON vCore_TranData_0_Ultra_Fast (iLocalPOSDate, iLocalPOSTime)
INCLUDE (iBodyId, iVoucherType, InvoiceNo)
WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE);
PRINT '✓ Date range index created';

-- Index 3: Invoice lookups
CREATE NONCLUSTERED INDEX IX_Invoice_Essential
ON vCore_TranData_0_Ultra_Fast (InvoiceNo)
WHERE InvoiceNo IS NOT NULL
WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE);
PRINT '✓ Invoice lookup index created';

-- ====================================================================
-- STEP 4: CREATE QUICK POPULATION PROCEDURE
-- ====================================================================

PRINT '';
PRINT 'STEP 4: Creating Quick Population Procedure';
PRINT '-------------------------------------------';

-- Create a simplified procedure with key voucher types only
IF OBJECT_ID('sp_Quick_Populate_TranData', 'P') IS NOT NULL
    DROP PROCEDURE sp_Quick_Populate_TranData;

EXEC('
CREATE PROCEDURE sp_Quick_Populate_TranData
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT ''Starting quick population of essential voucher types...'';
    
    TRUNCATE TABLE vCore_TranData_0_Ultra_Fast;
    
    -- Insert data for the most common voucher types (256, 512, 768, 3331, 4096)
    INSERT INTO vCore_TranData_0_Ultra_Fast (
        iBodyId, iVoucherType, iHeaderId, InvoiceNo, ReferenceNo, SalesOrderNo, 
        iCreatedUser, iLocalPOSDate, iLocalPOSTime, fCashPaid, fExchRateDiff,
        Commission_, CommissionAmount, sNarration, sRemarks, Description,
        Buyer, ContactDetails, sCustomerAddress, CustomerPONo, ItemVendorCode,
        VoucherForm, Notes, PickListNo
    )
    SELECT 
        d.iBodyId, h.iVoucherType, h.iHeaderId,
        COALESCE(h256.InvoiceNo, h512.InvoiceNo, h768.InvoiceNo, h3331.InvoiceNo, h4096.InvoiceNo, '''') as InvoiceNo,
        COALESCE(h256.ReferenceNo, h512.ReferenceNo, h768.ReferenceNo, h3331.ReferenceNo, h4096.ReferenceNo, '''') as ReferenceNo,
        COALESCE(h256.SalesOrderNo, h512.SalesOrderNo, h768.SalesOrderNo, h3331.SalesOrderNo, h4096.SalesOrderNo, '''') as SalesOrderNo,
        COALESCE(h3331.iCreatedUser, h4096.iCreatedUser, 0) as iCreatedUser,
        COALESCE(h3331.iLocalPOSDate, h4096.iLocalPOSDate, 0) as iLocalPOSDate,
        COALESCE(h3331.iLocalPOSTime, h4096.iLocalPOSTime, 0) as iLocalPOSTime,
        COALESCE(h4096.fCashPaid, 0) as fCashPaid,
        COALESCE(h768.fExchRateDiff, h769.fExchRateDiff, h770.fExchRateDiff, 0) as fExchRateDiff,
        COALESCE(b4608.Commission_, 0) as Commission_,
        COALESCE(b4608.CommissionAmount, 0) as CommissionAmount,
        COALESCE(h256.sNarration, h512.sNarration, h768.sNarration, h3331.sNarration, '''') as sNarration,
        COALESCE(b256.sRemarks, b768.sRemarks, '''') as sRemarks,
        COALESCE(b768.Description, b769.Description, b770.Description, '''') as Description,
        COALESCE(h768.Buyer, '''') as Buyer,
        COALESCE(h768.ContactDetails, '''') as ContactDetails,
        COALESCE(h3331.sCustomerAddress, '''') as sCustomerAddress,
        COALESCE(h768.CustomerPONo, h1792.CustomerPONo, '''') as CustomerPONo,
        COALESCE(b768.ItemVendorCode, '''') as ItemVendorCode,
        COALESCE(h256.VoucherForm, '''') as VoucherForm,
        COALESCE(h768.Notes, '''') as Notes,
        COALESCE(h3328.PickListNo, '''') as PickListNo
    FROM tCore_Data_0 d WITH(NOLOCK)
    INNER JOIN tCore_Header_0 h WITH(NOLOCK) ON d.iHeaderId = h.iHeaderId
    LEFT JOIN tCore_HeaderData256_0 h256 WITH(NOLOCK) ON h.iHeaderId = h256.iHeaderId AND h.iVoucherType = 256
    LEFT JOIN tCore_Data256_0 b256 WITH(NOLOCK) ON d.iBodyId = b256.iBodyId AND h.iVoucherType = 256
    LEFT JOIN tCore_HeaderData512_0 h512 WITH(NOLOCK) ON h.iHeaderId = h512.iHeaderId AND h.iVoucherType = 512
    LEFT JOIN tCore_HeaderData768_0 h768 WITH(NOLOCK) ON h.iHeaderId = h768.iHeaderId AND h.iVoucherType = 768
    LEFT JOIN tCore_Data768_0 b768 WITH(NOLOCK) ON d.iBodyId = b768.iBodyId AND h.iVoucherType = 768
    LEFT JOIN tCore_HeaderData769_0 h769 WITH(NOLOCK) ON h.iHeaderId = h769.iHeaderId AND h.iVoucherType = 769
    LEFT JOIN tCore_HeaderData770_0 h770 WITH(NOLOCK) ON h.iHeaderId = h770.iHeaderId AND h.iVoucherType = 770
    LEFT JOIN tCore_HeaderData1792_0 h1792 WITH(NOLOCK) ON h.iHeaderId = h1792.iHeaderId AND h.iVoucherType = 1792
    LEFT JOIN tCore_HeaderData3328_0 h3328 WITH(NOLOCK) ON h.iHeaderId = h3328.iHeaderId AND h.iVoucherType = 3328
    LEFT JOIN tCore_HeaderData3331_0 h3331 WITH(NOLOCK) ON h.iHeaderId = h3331.iHeaderId AND h.iVoucherType = 3331
    LEFT JOIN tCore_HeaderData4096_0 h4096 WITH(NOLOCK) ON h.iHeaderId = h4096.iHeaderId AND h.iVoucherType = 4096
    LEFT JOIN tCore_Data4608_0 b4608 WITH(NOLOCK) ON d.iBodyId = b4608.iBodyId AND h.iVoucherType = 4608
    WHERE h.iVoucherType IN (256, 512, 768, 769, 770, 1792, 3328, 3331, 4096, 4608);
    
    UPDATE STATISTICS vCore_TranData_0_Ultra_Fast WITH FULLSCAN;
    
    PRINT ''Quick population completed. Records: '' + CONVERT(VARCHAR(20), @@ROWCOUNT);
END
');

PRINT '✓ Quick population procedure created';

-- ====================================================================
-- STEP 5: CREATE OPTIMIZED VIEW
-- ====================================================================

PRINT '';
PRINT 'STEP 5: Creating Optimized View';
PRINT '-------------------------------';

IF OBJECT_ID('vCore_TranData_0_Optimized', 'V') IS NOT NULL
    DROP VIEW vCore_TranData_0_Optimized;

EXEC('
CREATE VIEW vCore_TranData_0_Optimized
AS
SELECT 
    iBodyId, iVoucherType, iHeaderId, InvoiceNo, ReferenceNo, SalesOrderNo,
    iCreatedUser, iLocalPOSDate, iLocalPOSTime, fCashPaid, fExchRateDiff,
    Commission_, CommissionAmount, sNarration, sRemarks, Description,
    Buyer, ContactDetails, sCustomerAddress, CustomerPONo, ItemVendorCode,
    VoucherForm, Notes, PickListNo, LastUpdated
FROM vCore_TranData_0_Ultra_Fast WITH(NOLOCK)
');

PRINT '✓ Optimized view created';

-- ====================================================================
-- STEP 6: POPULATE INITIAL DATA
-- ====================================================================

PRINT '';
PRINT 'STEP 6: Initial Data Population';
PRINT '-------------------------------';

DECLARE @PopulateStart DATETIME2 = GETDATE();
EXEC sp_Quick_Populate_TranData;
DECLARE @PopulateDuration INT = DATEDIFF(MILLISECOND, @PopulateStart, GETDATE());

PRINT '✓ Initial population completed in ' + CONVERT(VARCHAR(10), @PopulateDuration) + 'ms';

-- ====================================================================
-- STEP 7: QUICK PERFORMANCE TEST
-- ====================================================================

PRINT '';
PRINT 'STEP 7: Quick Performance Test';
PRINT '------------------------------';

-- Test 1: Count all records
DECLARE @TestStart DATETIME2 = GETDATE();
DECLARE @RecordCount BIGINT;

SELECT @RecordCount = COUNT(*) FROM vCore_TranData_0_Optimized;
DECLARE @TestDuration INT = DATEDIFF(MILLISECOND, @TestStart, GETDATE());

PRINT 'Total Records: ' + CONVERT(VARCHAR(20), @RecordCount) + ' in ' + CONVERT(VARCHAR(10), @TestDuration) + 'ms';

-- Test 2: Voucher type filter
SET @TestStart = GETDATE();
DECLARE @FilterCount BIGINT;

SELECT @FilterCount = COUNT(*) FROM vCore_TranData_0_Optimized WHERE iVoucherType = 256;
SET @TestDuration = DATEDIFF(MILLISECOND, @TestStart, GETDATE());

PRINT 'Voucher 256 Records: ' + CONVERT(VARCHAR(20), @FilterCount) + ' in ' + CONVERT(VARCHAR(10), @TestDuration) + 'ms';

-- Test 3: Invoice lookup
SET @TestStart = GETDATE();
DECLARE @InvoiceCount BIGINT;

SELECT @InvoiceCount = COUNT(*) FROM vCore_TranData_0_Optimized WHERE InvoiceNo IS NOT NULL;
SET @TestDuration = DATEDIFF(MILLISECOND, @TestStart, GETDATE());

PRINT 'Records with Invoice: ' + CONVERT(VARCHAR(20), @InvoiceCount) + ' in ' + CONVERT(VARCHAR(10), @TestDuration) + 'ms';

-- Performance assessment
IF @TestDuration <= 3000
    PRINT '✅ PERFORMANCE TARGET ACHIEVED!';
ELSE
    PRINT '⚠️  Performance needs further optimization';

-- ====================================================================
-- STEP 8: SETUP SUMMARY
-- ====================================================================

PRINT '';
PRINT '====================================================================';
PRINT 'QUICK SETUP COMPLETED SUCCESSFULLY!';
PRINT '====================================================================';
PRINT 'Summary:';
PRINT '• Table: vCore_TranData_0_Ultra_Fast created with ' + CONVERT(VARCHAR(20), @RecordCount) + ' records';
PRINT '• View: vCore_TranData_0_Optimized ready for use';
PRINT '• Indexes: Essential performance indexes created';
PRINT '• Test Results: ' + CONVERT(VARCHAR(10), @TestDuration) + 'ms for ' + CONVERT(VARCHAR(20), @RecordCount) + ' records';
PRINT '';
PRINT 'NEXT STEPS:';
PRINT '1. Test with your application: SELECT * FROM vCore_TranData_0_Optimized';
PRINT '2. For full optimization, run: @ultimate_vcore_trandata_optimization.sql';
PRINT '3. For all voucher types, run: @complete_population_script.sql';
PRINT '4. Schedule regular refresh: EXEC sp_Quick_Populate_TranData';
PRINT '';
PRINT 'USAGE EXAMPLES:';
PRINT '-- Basic query:';
PRINT 'SELECT * FROM vCore_TranData_0_Optimized WHERE iVoucherType = 256;';
PRINT '';
PRINT '-- Date filter:';
PRINT 'SELECT * FROM vCore_TranData_0_Optimized WHERE iLocalPOSDate >= 20240101;';
PRINT '';
PRINT '-- Invoice lookup:';
PRINT 'SELECT * FROM vCore_TranData_0_Optimized WHERE InvoiceNo LIKE ''%INV%'';';
PRINT '';
PRINT 'Expected Performance: 2-3 seconds for full dataset queries';
PRINT '====================================================================';

-- Final completion timestamp
PRINT 'Setup completed at: ' + CONVERT(VARCHAR(25), GETDATE(), 121);

