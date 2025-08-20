-- Truncation Fix Test Script
-- This script tests the fix for "String or binary data would be truncated" error

-- Step 1: Drop existing table if it exists
IF OBJECT_ID('vmCore_Product_Ultra_Fast', 'U') IS NOT NULL
    DROP TABLE vmCore_Product_Ultra_Fast;

-- Step 2: Create ultra-optimized materialized table with FIXED COLUMN SIZES + OVERFLOW FIX
CREATE TABLE vmCore_Product_Ultra_Fast (
    iMasterId bigint PRIMARY KEY,  -- Changed from int to bigint
    sName nvarchar(500) NOT NULL,  -- Increased from 255
    sCode nvarchar(100) NOT NULL,  -- Increased from 50
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
    pImageName nvarchar(500) NULL,  -- Increased from 255
    iLPGenerationType int NULL,
    SKU nvarchar(200) NULL,  -- Increased from 100
    ItemAlias nvarchar(200) NULL,  -- Increased from 100
    ProductShortDescription nvarchar(1000) NULL,  -- Increased from 500
    ProductLongDescription nvarchar(4000) NULL,  -- Increased from 2000
    AvailableForOnline int NULL,
    MakeOnOrder int NULL,
    Daystomake int NULL,
    Warranty int NULL,
    SMUPrivateLable int NULL,
    AttributeValue1 nvarchar(200) NULL,  -- Increased from 100
    AttributeValue2 nvarchar(200) NULL,  -- Increased from 100
    AttributeValue3 nvarchar(200) NULL,  -- Increased from 100
    AttributeValue4 nvarchar(200) NULL,  -- Increased from 100
    GRWt float NULL,
    NetWt float NULL,
    ItemFlag nvarchar(100) NULL,  -- Increased from 50
    iProductMake int NULL,
    bPerishableItem bit NULL,
    GSTTaxValidation bit NULL,
    AttributeValue5 nvarchar(200) NULL,  -- Increased from 100
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
    Printer nvarchar(200) NULL,  -- Increased from 100
    sDescription nvarchar(1000) NULL,  -- Increased from 500
    iParentId bigint NULL,  -- Changed from int to bigint
    iSequence bigint NULL,  -- Changed from int to bigint
    iLevel bigint NULL,  -- Changed from int to bigint
    iTreeId bigint NULL,  -- Changed from int to bigint
    LastUpdated datetime2 NOT NULL DEFAULT GETDATE()
);

-- Step 3: Create diagnostic procedure to check for potential truncation issues
CREATE OR ALTER PROCEDURE sp_Check_Truncation_Issues
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT 'Checking for potential truncation issues...';
    
    -- Check for long product names
    SELECT TOP 10 
        'Long Product Names' as Issue,
        iMasterId,
        sName,
        LEN(sName) as NameLength
    FROM mCore_Product WITH(NOLOCK)
    WHERE LEN(sName) > 250
    ORDER BY LEN(sName) DESC;
    
    -- Check for long product codes
    SELECT TOP 10 
        'Long Product Codes' as Issue,
        iMasterId,
        sCode,
        LEN(sCode) as CodeLength
    FROM mCore_Product WITH(NOLOCK)
    WHERE LEN(sCode) > 50
    ORDER BY LEN(sCode) DESC;
    
    -- Check for long image names
    SELECT TOP 10 
        'Long Image Names' as Issue,
        iMasterId,
        pImageName,
        LEN(pImageName) as ImageNameLength
    FROM muCore_Product WITH(NOLOCK)
    WHERE LEN(pImageName) > 250
    ORDER BY LEN(pImageName) DESC;
    
    -- Check for long SKUs
    SELECT TOP 10 
        'Long SKUs' as Issue,
        iMasterId,
        SKU,
        LEN(SKU) as SKULength
    FROM muCore_Product WITH(NOLOCK)
    WHERE LEN(SKU) > 100
    ORDER BY LEN(SKU) DESC;
    
    -- Check for long descriptions
    SELECT TOP 10 
        'Long Short Descriptions' as Issue,
        iMasterId,
        ProductShortDescription,
        LEN(ProductShortDescription) as ShortDescLength
    FROM muCore_Product WITH(NOLOCK)
    WHERE LEN(ProductShortDescription) > 500
    ORDER BY LEN(ProductShortDescription) DESC;
    
    SELECT TOP 10 
        'Long Long Descriptions' as Issue,
        iMasterId,
        ProductLongDescription,
        LEN(ProductLongDescription) as LongDescLength
    FROM muCore_Product WITH(NOLOCK)
    WHERE LEN(ProductLongDescription) > 2000
    ORDER BY LEN(ProductLongDescription) DESC;
    
    PRINT 'Truncation check completed.';
    
    -- Check for potential overflow issues
    PRINT 'Checking for potential overflow issues...';
    
    -- Check for large integer values that might cause overflow
    SELECT TOP 10 
        'Large iMasterId Values' as Issue,
        iMasterId,
        'Value: ' + CAST(iMasterId AS VARCHAR(20)) as ValueInfo
    FROM mCore_Product WITH(NOLOCK)
    WHERE iMasterId > 2147483647  -- Max int value
    ORDER BY iMasterId DESC;
    
    SELECT TOP 10 
        'Large iCreatedBy Values' as Issue,
        iMasterId,
        iCreatedBy,
        'Value: ' + CAST(iCreatedBy AS VARCHAR(20)) as ValueInfo
    FROM mCore_Product WITH(NOLOCK)
    WHERE iCreatedBy > 2147483647  -- Max int value
    ORDER BY iCreatedBy DESC;
    
    SELECT TOP 10 
        'Large iModifiedBy Values' as Issue,
        iMasterId,
        iModifiedBy,
        'Value: ' + CAST(iModifiedBy AS VARCHAR(20)) as ValueInfo
    FROM mCore_Product WITH(NOLOCK)
    WHERE iModifiedBy > 2147483647  -- Max int value
    ORDER BY iModifiedBy DESC;
    
    SELECT TOP 10 
        'Large Date Values' as Issue,
        iMasterId,
        iCreatedDate,
        'Value: ' + CAST(iCreatedDate AS VARCHAR(20)) as ValueInfo
    FROM mCore_Product WITH(NOLOCK)
    WHERE iCreatedDate > 2147483647  -- Max int value
    ORDER BY iCreatedDate DESC;
    
    PRINT 'Overflow check completed.';
END;

-- Step 4: Create ultra-fast data population procedure with error handling
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
        SELECT 
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

-- Step 5: Run the test
PRINT '=== TRUNCATION FIX TEST ===';
PRINT 'Step 1: Checking for potential truncation issues...';
EXEC sp_Check_Truncation_Issues;

PRINT '';
PRINT 'Step 2: Attempting to populate the ultra-fast table...';
EXEC sp_Populate_Ultra_Fast_Products;

PRINT '';
PRINT 'Step 3: Verifying data was inserted...';
SELECT COUNT(*) as TotalRecords FROM vmCore_Product_Ultra_Fast;

PRINT '';
PRINT '=== TEST COMPLETED ===';
PRINT 'If you see this message, the truncation fix was successful!';
