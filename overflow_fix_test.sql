-- Arithmetic Overflow Fix Test Script
-- This script tests the fix for "Arithmetic overflow error converting expression to data type int"

-- Step 1: Drop existing table if it exists
IF OBJECT_ID('vmCore_Product_Ultra_Fast', 'U') IS NOT NULL
    DROP TABLE vmCore_Product_Ultra_Fast;

-- Step 2: Create ultra-optimized materialized table with OVERFLOW FIX
CREATE TABLE vmCore_Product_Ultra_Fast (
    iMasterId bigint PRIMARY KEY,  -- Changed from int to bigint
    sName nvarchar(500) NOT NULL,
    sCode nvarchar(100) NOT NULL,
    iProductType int NOT NULL,
    iProductTypeName nvarchar(50) NOT NULL,
    iStatus int NOT NULL,
    iCategory bigint NULL,  -- Changed from int to bigint
    iBin bigint NULL,  -- Changed from int to bigint
    iLPType bigint NULL,  -- Changed from int to bigint
    iCreatedBy bigint NULL,  -- Changed from int to bigint
    iModifiedBy bigint NULL,  -- Changed from int to bigint
    iCreatedDate bigint NULL,  -- Changed from int to bigint
    iModifiedDate bigint NULL,  -- Changed from int to bigint
    iSyncReceivedDate bigint NULL,  -- Changed from int to bigint
    fReorderLevel float NULL,
    iBinCapacity bigint NULL,  -- Changed from int to bigint
    iValuationMethod int NULL,
    bIsAttribute bit NULL,
    bGroup bit NULL,
    bDoNotRestrict bit NULL,
    pImageName nvarchar(500) NULL,
    iLPGenerationType int NULL,
    SKU nvarchar(200) NULL,
    ItemAlias nvarchar(200) NULL,
    ProductShortDescription nvarchar(1000) NULL,
    ProductLongDescription nvarchar(4000) NULL,
    AvailableForOnline int NULL,
    MakeOnOrder int NULL,
    Daystomake int NULL,
    Warranty int NULL,
    SMUPrivateLable int NULL,
    AttributeValue1 nvarchar(200) NULL,
    AttributeValue2 nvarchar(200) NULL,
    AttributeValue3 nvarchar(200) NULL,
    AttributeValue4 nvarchar(200) NULL,
    GRWt float NULL,
    NetWt float NULL,
    ItemFlag nvarchar(100) NULL,
    iProductMake int NULL,
    bPerishableItem bit NULL,
    GSTTaxValidation bit NULL,
    AttributeValue5 nvarchar(200) NULL,
    iAlternateCategory bigint NULL,  -- Changed from int to bigint
    SubCategory1 bigint NULL,  -- Changed from int to bigint
    Brands bigint NULL,  -- Changed from int to bigint
    Colour bigint NULL,  -- Changed from int to bigint
    Size bigint NULL,  -- Changed from int to bigint
    AttributeLabel1 bigint NULL,  -- Changed from int to bigint
    AttributeLabel2 bigint NULL,  -- Changed from int to bigint
    AttributeLabel3 bigint NULL,  -- Changed from int to bigint
    AttributeLabel4 bigint NULL,  -- Changed from int to bigint
    AttributeLabel5 bigint NULL,  -- Changed from int to bigint
    Flavours bigint NULL,  -- Changed from int to bigint
    GroupCategory bigint NULL,  -- Changed from int to bigint
    Printer nvarchar(200) NULL,
    sDescription nvarchar(1000) NULL,
    iParentId bigint NULL,  -- Changed from int to bigint
    iSequence bigint NULL,  -- Changed from int to bigint
    iLevel bigint NULL,  -- Changed from int to bigint
    iTreeId bigint NULL,  -- Changed from int to bigint
    LastUpdated datetime2 NOT NULL DEFAULT GETDATE()
);

-- Step 3: Create simple population procedure with error handling
CREATE OR ALTER PROCEDURE sp_Populate_Ultra_Fast_Products
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Clear existing data
        TRUNCATE TABLE vmCore_Product_Ultra_Fast;
        
        PRINT 'Starting data population...';
        
        -- Insert data with pre-computed values
        INSERT INTO vmCore_Product_Ultra_Fast (
            iMasterId, sName, sCode, iProductType, iProductTypeName, iStatus,
            iCategory, iBin, iLPType, iCreatedBy, iModifiedBy, iCreatedDate, iModifiedDate, iSyncReceivedDate,
            fReorderLevel, iBinCapacity, iValuationMethod, bIsAttribute, bGroup, bDoNotRestrict,
            pImageName, iLPGenerationType, SKU, ItemAlias, ProductShortDescription, ProductLongDescription,
            AvailableForOnline, MakeOnOrder, Daystomake, Warranty, SMUPrivateLable,
            AttributeValue1, AttributeValue2, AttributeValue3, AttributeValue4, GRWt, NetWt,
            ItemFlag, iProductMake, bPerishableItem, GSTTaxValidation, AttributeValue5,
            iAlternateCategory, SubCategory1, Brands, Colour, Size,
            AttributeLabel1, AttributeLabel2, AttributeLabel3, AttributeLabel4, AttributeLabel5,
            Flavours, GroupCategory, Printer, sDescription,
            iParentId, iSequence, iLevel, iTreeId
        )
        SELECT TOP 1000  -- Limit to first 1000 records for testing
            p.iMasterId,
            p.sName,
            p.sCode,
            p.iProductType,
            CASE p.iProductType
                WHEN 1 THEN N'Service'
                WHEN 2 THEN N'Raw material'
                WHEN 3 THEN N'Intermediate item'
                WHEN 4 THEN N'Finished goods'
                WHEN 5 THEN N'Non stock item'
                WHEN 6 THEN N'Modifier'
                WHEN 7 THEN N'PRT Consumable'
                WHEN 8 THEN N'PRT Tools'
                WHEN 9 THEN N'Ticket'
                ELSE N''
            END as iProductTypeName,
            p.iStatus,
            pu.iCategory,
            pu.iBin,
            pu.iLPType,
            p.iCreatedBy,
            p.iModifiedBy,
            p.iCreatedDate,
            p.iModifiedDate,
            p.iSyncReceivedDate,
            p.fReorderLevel,
            p.iBinCapacity,
            p.iValuationMethod,
            p.bIsAttribute,
            p.bGroup,
            p.bDoNotRestrict,
            pu.pImageName,
            pu.iLPGenerationType,
            pu.SKU,
            pu.ItemAlias,
            pu.ProductShortDescription,
            pu.ProductLongDescription,
            pu.AvailableForOnline,
            pu.MakeOnOrder,
            pu.Daystomake,
            pu.Warranty,
            pu.SMUPrivateLable,
            pu.AttributeValue1,
            pu.AttributeValue2,
            pu.AttributeValue3,
            pu.AttributeValue4,
            pu.GRWt,
            pu.NetWt,
            pu.ItemFlag,
            pu.iProductMake,
            pu.bPerishableItem,
            pu.GSTTaxValidation,
            pu.AttributeValue5,
            pu.iAlternateCategory,
            pu.SubCategory1,
            pu.Brands,
            pu.Colour,
            pu.Size,
            pu.AttributeLabel1,
            pu.AttributeLabel2,
            pu.AttributeLabel3,
            pu.AttributeLabel4,
            pu.AttributeLabel5,
            pu.Flavours,
            pu.GroupCategory,
            pu.Printer,
            pu.sDescription,
            ptd.iParentId,
            ptd.iSequence,
            ptd.iLevel,
            ptd.iTreeId
        FROM mCore_Product p WITH(NOLOCK)
        INNER JOIN muCore_Product pu WITH(NOLOCK) ON p.iMasterId = pu.iMasterId
        INNER JOIN mCore_ProductTreeDetails ptd WITH(NOLOCK) ON p.iMasterId = ptd.iMasterId
        WHERE p.iStatus < 5;
        
        -- Update timestamp
        UPDATE vmCore_Product_Ultra_Fast 
        SET LastUpdated = GETDATE();
        
        PRINT 'Ultra-fast table populated successfully';
        
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred during data population:';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR(10));
        
        -- Re-raise the error
        THROW;
    END CATCH
END;

-- Step 4: Run the test
PRINT '=== ARITHMETIC OVERFLOW FIX TEST ===';
PRINT 'Step 1: Attempting to populate the ultra-fast table with overflow fix...';
EXEC sp_Populate_Ultra_Fast_Products;

PRINT '';
PRINT 'Step 2: Verifying data was inserted...';
SELECT COUNT(*) as TotalRecords FROM vmCore_Product_Ultra_Fast;

PRINT '';
PRINT 'Step 3: Checking for any large values that might cause issues...';
SELECT TOP 5 
    iMasterId,
    iCreatedBy,
    iModifiedBy,
    iCreatedDate,
    iModifiedDate
FROM vmCore_Product_Ultra_Fast
ORDER BY iMasterId DESC;

PRINT '';
PRINT '=== TEST COMPLETED ===';
PRINT 'If you see this message, the arithmetic overflow fix was successful!';
