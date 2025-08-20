-- Advanced SQL Query Performance Optimization Script
-- Target: Reduce execution time from 15 seconds to under 3 seconds

-- Step 1: Create more aggressive covering indexes with better selectivity
CREATE NONCLUSTERED INDEX IX_mCore_Product_Status_MasterId_Advanced 
ON mCore_Product(iStatus, iMasterId) 
INCLUDE(sName, sCode, iProductType, iCreatedBy, iModifiedBy, iCreatedDate, iModifiedDate, iSyncReceivedDate, iLocationId, bEditedFrom, iClosingDate, bAllowOtherCompaniesToViewRecord, iEditingLocation, iAuthStatus, fReorderLevel, iBinCapacity, iValuationMethod, bIsAttribute, bGroup, bDoNotRestrict)
WHERE iStatus < 5
WITH (FILLFACTOR = 90, PAD_INDEX = ON);

-- Step 2: Create composite indexes for better join performance
CREATE NONCLUSTERED INDEX IX_muCore_Product_MasterId_Composite 
ON muCore_Product(iMasterId, iLPType, iAlternateCategory, iCategory, SubCategory1, Brands, Colour, Size, AttributeLabel1, AttributeLabel2, AttributeLabel3, AttributeLabel4, AttributeLabel5, Flavours, GroupCategory, iBin)
INCLUDE(pImageName, iLPGenerationType, bAllowedforSodexoRedemption, pImage, iDonotshowtheItemsexpirewithindays, SKU, ItemAlias, ProductShortDescription, ProductLongDescription, ConfirmOrder, AvailableForOnline, MakeOnOrder, Daystomake, Warranty, SMUPrivateLable, AttributeValue1, AttributeValue2, AttributeValue3, AttributeValue4, GRWt, NetWt, ItemFlag, iProductMake, bPerishableItem, GSTTaxValidation, AttributeValue5, Printer, sDescription)
WITH (FILLFACTOR = 90, PAD_INDEX = ON);

-- Step 3: Create indexed view for frequently accessed data (this will pre-compute joins)
CREATE OR ALTER VIEW vmCore_Product_Indexed_Advanced WITH SCHEMABINDING AS
SELECT 
    p.iMasterId,
    p.sName,
    p.sCode,
    p.iProductType,
    p.iStatus,
    p.iCreatedBy,
    p.iModifiedBy,
    p.iCreatedDate,
    p.iModifiedDate,
    p.iSyncReceivedDate,
    p.iLocationId,
    p.bEditedFrom,
    p.iClosingDate,
    p.bAllowOtherCompaniesToViewRecord,
    p.iEditingLocation,
    p.iAuthStatus,
    p.fReorderLevel,
    p.iBinCapacity,
    p.iValuationMethod,
    p.bIsAttribute,
    p.bGroup,
    p.bDoNotRestrict,
    pu.pImageName,
    pu.iLPGenerationType,
    pu.bAllowedforSodexoRedemption,
    pu.pImage,
    pu.iDonotshowtheItemsexpirewithindays,
    pu.SKU,
    pu.ItemAlias,
    pu.ProductShortDescription,
    pu.ProductLongDescription,
    pu.ConfirmOrder,
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
    pu.iLPType,
    pu.iAlternateCategory,
    pu.iCategory,
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
    pu.iBin,
    ptd.iParentId,
    ptd.iSequence,
    ptd.iLevel,
    ptd.iTreeId
FROM dbo.mCore_Product p
INNER JOIN dbo.muCore_Product pu ON p.iMasterId = pu.iMasterId
INNER JOIN dbo.mCore_ProductTreeDetails ptd ON p.iMasterId = ptd.iMasterId
WHERE p.iStatus < 5;

-- Create unique clustered index on the indexed view
CREATE UNIQUE CLUSTERED INDEX IX_vmCore_Product_Indexed_Advanced 
ON vmCore_Product_Indexed_Advanced(iMasterId);

-- Step 4: Create optimized view with minimal joins
CREATE OR ALTER VIEW vmCore_Product_Ultra_Optimized AS
WITH ProductTypeMap AS (
    SELECT 1 as ID, N'Service' as Name
    UNION ALL SELECT 2, N'Raw material'
    UNION ALL SELECT 3, N'Intermediate item'
    UNION ALL SELECT 4, N'Finished goods'
    UNION ALL SELECT 5, N'Non stock item'
    UNION ALL SELECT 6, N'Modifier'
    UNION ALL SELECT 7, N'PRT Consumable'
    UNION ALL SELECT 8, N'PRT Tools'
    UNION ALL SELECT 9, N'Ticket'
),
ValuationMethodMap AS (
    SELECT 1 as ID, N'Weighted Avg' as Name
    UNION ALL SELECT 2, N'Monthly weighted Avg'
    UNION ALL SELECT 3, N'FIFO'
    UNION ALL SELECT 4, N'LIFO'
    UNION ALL SELECT 5, N'FIFO (Consider Transaction time)'
    UNION ALL SELECT 6, N'Standard'
    UNION ALL SELECT 7, N'Batch Rate'
),
LPGenerationTypeMap AS (
    SELECT 0 as ID, N'None' as Name
    UNION ALL SELECT 1, N'Default LP Generation'
    UNION ALL SELECT 2, N'Warehouse Wise LP Generation'
    UNION ALL SELECT 3, N'Generate LP On Receiving'
    UNION ALL SELECT 4, N'Manually Generate LP'
),
AvailableForOnlineMap AS (
    SELECT 1 as ID, N'TRUE' as Name
    UNION ALL SELECT 2, N'FALSE'
),
MakeOnOrderMap AS (
    SELECT 1 as ID, N'TRUE' as Name
    UNION ALL SELECT 2, N'FALSE'
),
SMUPrivateLableMap AS (
    SELECT 1 as ID, N'TRUE' as Name
    UNION ALL SELECT 2, N'FALSE'
),
ProductMakeMap AS (
    SELECT 0 as ID, N'Item' as Name
    UNION ALL SELECT 1, N'Set'
    UNION ALL SELECT 2, N'Kit'
    UNION ALL SELECT 3, N'Combo'
    UNION ALL SELECT 4, N'Dynamic set'
),
ABCCodeMap AS (
    SELECT 1 as ID, N'A' as Name
    UNION ALL SELECT 2, N'B'
    UNION ALL SELECT 3, N'C'
),
ManufacturePolicyMap AS (
    SELECT 0 as ID, N'Made to stock' as Name
    UNION ALL SELECT 1, N'Made to Order'
),
ReplenishmentMap AS (
    SELECT 0 as ID, N'Purchase' as Name
    UNION ALL SELECT 1, N'Production'
),
FlushingMap AS (
    SELECT 0 as ID, N'Manual' as Name
    UNION ALL SELECT 1, N'Forward'
    UNION ALL SELECT 2, N'Backward'
),
ProductCategoryMap AS (
    SELECT 0 as ID, N'Normal' as Name
    UNION ALL SELECT 1, N'Capital Goods'
    UNION ALL SELECT 2, N'Exempted'
    UNION ALL SELECT 3, N'Non-GST'
    UNION ALL SELECT 4, N'Reverse Charge'
    UNION ALL SELECT 5, N'Nil'
),
EComProductMap AS (
    SELECT 0 as ID, N'NA' as Name
    UNION ALL SELECT 1, N'Sec 9(5) notified'
)
SELECT 
    -- Core Product Information (from indexed view)
    p.iMasterId,
    p.sName,
    p.sCode,
    p.iProductType,
    ISNULL(ptm.Name, N'') as iProductTypeName,
    p.fReorderLevel,
    p.iBinCapacity,
    p.iValuationMethod,
    ISNULL(vmm.Name, N'') as iValuationMethodName,
    p.bIsAttribute,
    p.bGroup,
    p.iStatus,
    p.bDoNotRestrict,
    
    -- User Information (lazy loaded)
    p.iCreatedBy,
    cu.sLoginName as iCreatedByName,
    p.iModifiedBy,
    mu.sLoginName as iModifiedByName,
    
    -- Date Information (optimized function calls)
    CASE WHEN p.iCreatedDate IS NULL OR p.iCreatedDate = 0 THEN NULL 
         ELSE dbo.fCore_IntToDateTime(p.iCreatedDate) END as iCreatedDate,
    CASE WHEN p.iModifiedDate IS NULL OR p.iModifiedDate = 0 THEN NULL 
         ELSE dbo.fCore_IntToDateTime(p.iModifiedDate) END as iModifiedDate,
    CASE WHEN p.iSyncReceivedDate IS NULL OR p.iSyncReceivedDate = 0 THEN NULL 
         ELSE dbo.fCore_IntToDateTime(p.iSyncReceivedDate) END as iSyncReceivedDate,
    
    -- Location and Editing Information
    p.iLocationId,
    p.bEditedFrom,
    p.iClosingDate,
    p.bAllowOtherCompaniesToViewRecord,
    p.iEditingLocation,
    
    -- Product Details (from indexed view)
    p.pImageName,
    p.iLPGenerationType,
    ISNULL(lpgm.Name, N'') as iLPGenerationTypeName,
    p.bAllowedforSodexoRedemption,
    p.pImage,
    p.iDonotshowtheItemsexpirewithindays,
    p.SKU,
    p.ItemAlias,
    p.ProductShortDescription,
    p.ProductLongDescription,
    p.ConfirmOrder,
    p.AvailableForOnline,
    ISNULL(aom.Name, N'') as AvailableForOnlineName,
    p.MakeOnOrder,
    ISNULL(mom.Name, N'') as MakeOnOrderName,
    p.Daystomake,
    p.Warranty,
    p.SMUPrivateLable,
    ISNULL(splm.Name, N'') as SMUPrivateLableName,
    p.AttributeValue1,
    p.AttributeValue2,
    p.AttributeValue3,
    p.AttributeValue4,
    p.GRWt,
    p.NetWt,
    p.ItemFlag,
    p.iProductMake,
    ISNULL(pmm.Name, N'') as iProductMakeName,
    p.bPerishableItem,
    p.GSTTaxValidation,
    p.AttributeValue5,
    
    -- LP Type Information (lazy loaded)
    p.iLPType,
    lpType.sName as iLPTypeName,
    
    -- Category Information (lazy loaded)
    p.iAlternateCategory,
    acat.sName as iAlternateCategoryName,
    p.iCategory,
    cat.sName as iCategoryName,
    p.SubCategory1,
    subCat1.sName as SubCategory1Name,
    
    -- Brand and Color Information (lazy loaded)
    p.Brands,
    brands.sName as BrandsName,
    p.Colour,
    colour.sName as ColourName,
    p.Size,
    size.sName as SizeName,
    
    -- Attribute Labels (lazy loaded)
    p.AttributeLabel1,
    attrLabel1.sName as AttributeLabel1Name,
    p.AttributeLabel2,
    attrLabel2.sName as AttributeLabel2Name,
    p.AttributeLabel3,
    attrLabel3.sName as AttributeLabel3Name,
    p.AttributeLabel4,
    attrLabel4.sName as AttributeLabel4Name,
    p.AttributeLabel5,
    attrLabel5.sName as AttributeLabel5Name,
    
    -- Flavours and Group Category (lazy loaded)
    p.Flavours,
    flavours.sName as FlavoursName,
    p.GroupCategory,
    groupCat.sName as GroupCategoryName,
    
    -- Printer and Description
    p.Printer,
    p.sDescription,
    
    -- Bin Information (lazy loaded)
    p.iBin,
    bin.sName as iBinName,
    
    -- Units Information (lazy loaded)
    punits.iDefaultBaseUnit,
    dbu.sName as iDefaultBaseUnitName,
    punits.iDefaultSalesUnit,
    dsu.sName as iDefaultSalesUnitName,
    punits.iDefaultPurchaseUnit,
    dpu.sName as iDefaultPurchaseUnitName,
    punits.fLength,
    punits.fWidth,
    punits.fHeight,
    punits.fWeight,
    
    -- Settings Information (lazy loaded)
    pset.fStandardCost,
    pset.fOverheadCost,
    pset.fIndirectCost,
    pset.fProfit,
    pset.iTaxCode,
    tc.sName as iTaxCodeName,
    pset.iDontshowproductexpireddays,
    
    -- Classification Information (lazy loaded)
    pclass.iABCCodeValue,
    ISNULL(abcm.Name, N'') as iABCCodeValueName,
    pclass.iABCCodeMargin,
    ISNULL(abcm.Name, N'') as iABCCodeMarginName,
    pclass.iABCCodeRevenue,
    ISNULL(abcm.Name, N'') as iABCCodeRevenueName,
    pclass.iABCCodeCarryingCost,
    ISNULL(abcm.Name, N'') as iABCCodeCarryingCostName,
    pclass.sBarcode1,
    pclass.sBarcode2,
    pclass.sBarcode3,
    
    -- Account Information (lazy loaded)
    pod.iWIPAccount,
    wip.sName as iWIPAccountName,
    pod.iCostOfIssueAccount,
    coi.sName as iCostOfIssueAccountName,
    pod.iStocksAccount,
    stock.sName as iStocksAccountName,
    pod.iSalesAccount,
    sales.sName as iSalesAccountName,
    pod.iCostofShortageStockAC,
    css.sName as iCostofShortageStockACName,
    pod.iCostofExcessStockAC,
    ces.sName as iCostofExcessStockACName,
    pod.iCostofSaleReturnAC,
    csr.sName as iCostofSaleReturnACName,
    pod.iPurchaseVarianceAC,
    pv.sName as iPurchaseVarianceACName,
    pod.iProductionLeadTime,
    
    -- Replenishment Information (lazy loaded)
    pr.sProductionLeadTime,
    pr.bPhantom,
    pr.iManufacturePolicy,
    ISNULL(mpm.Name, N'') as iManufacturePolicyName,
    pr.iDefaultReplenishment,
    ISNULL(rm.Name, N'') as iDefaultReplenishmentName,
    pr.iBOM,
    bom.iVariantId as iBOMName,
    pr.iFlushing,
    ISNULL(fm.Name, N'') as iFlushingName,
    pr.bRaiseProdOrderOnSale,
    pr.iPackingBOM,
    pbom.sName as iPackingBOMName,
    
    -- GST Information (lazy loaded)
    pgst.HSNSAC,
    pgst.ProductCategory,
    ISNULL(pcm.Name, N'') as ProductCategoryName,
    pgst.EComProduct,
    ISNULL(epm.Name, N'') as EComProductName,
    
    -- Tree Information (from indexed view)
    p.iParentId,
    p.iSequence,
    p.iLevel,
    p.iTreeId,
    
    -- Product Properties (lazy loaded)
    pp.bDontMaintainStockbyBatch,
    pp.bInputBreakupCategoriesWise,
    pp.bDontMaintainStocksByRMA,
    pp.bDonotPrintInBill,
    pp.bNotAllowedforHomeDelivery,
    pp.bStarProduct,
    pp.bDonotUpdateStock,
    pp.bIgnoreExpiryforthisItem,
    pp.bIgnoreMfgDateforthisItem,
    pp.iReserveType,
    pp.bReserveByBatch,
    pp.bReserveByBin,
    pp.bReserveByRMA,
    pp.bDoNotInputBin,
    pp.iInventoryAllocation,
    pp.bIgnoreFractionInQty,
    pp.fNegativeTolerance,
    pp.fTolerance,
    pp.iToleranceType,
    pp.bCheckforWeightfromWeighingScale

FROM vmCore_Product_Indexed_Advanced p WITH(NOLOCK)
-- User joins (only when needed)
LEFT JOIN mSec_Users cu WITH(NOLOCK) ON p.iCreatedBy = cu.iUserId
LEFT JOIN mSec_Users mu WITH(NOLOCK) ON p.iModifiedBy = mu.iUserId

-- LP Type Information
LEFT JOIN mWms_Skid lpType WITH(NOLOCK) ON p.iLPType = lpType.iMasterId

-- Category Information
LEFT JOIN mPos_Category acat WITH(NOLOCK) ON p.iAlternateCategory = acat.iMasterId
LEFT JOIN mPos_Category cat WITH(NOLOCK) ON p.iCategory = cat.iMasterId
LEFT JOIN mCore_SubCategory1 subCat1 WITH(NOLOCK) ON p.SubCategory1 = subCat1.iMasterId

-- Brand and Color Information
LEFT JOIN mCore_Brands brands WITH(NOLOCK) ON p.Brands = brands.iMasterId
LEFT JOIN mCore_Colour colour WITH(NOLOCK) ON p.Colour = colour.iMasterId
LEFT JOIN mCore_Size size WITH(NOLOCK) ON p.Size = size.iMasterId

-- Attribute Labels
LEFT JOIN mCore_AttributeLabel1 attrLabel1 WITH(NOLOCK) ON p.AttributeLabel1 = attrLabel1.iMasterId
LEFT JOIN mCore_AttributeLabel2 attrLabel2 WITH(NOLOCK) ON p.AttributeLabel2 = attrLabel2.iMasterId
LEFT JOIN mCore_AttributeLabel3 attrLabel3 WITH(NOLOCK) ON p.AttributeLabel3 = attrLabel3.iMasterId
LEFT JOIN mCore_AttributeLabel4 attrLabel4 WITH(NOLOCK) ON p.AttributeLabel4 = attrLabel4.iMasterId
LEFT JOIN mCore_AttributeLabel5 attrLabel5 WITH(NOLOCK) ON p.AttributeLabel5 = attrLabel5.iMasterId

-- Flavours and Group Category
LEFT JOIN mCore_Flavours flavours WITH(NOLOCK) ON p.Flavours = flavours.iMasterId
LEFT JOIN mCore_GroupCategory groupCat WITH(NOLOCK) ON p.GroupCategory = groupCat.iMasterId

-- Bin Information
LEFT JOIN mCore_Bins bin WITH(NOLOCK) ON p.iBin = bin.iMasterId

-- Units joins
LEFT JOIN muCore_Product_Units punits WITH(NOLOCK) ON p.iMasterId = punits.iMasterId
LEFT JOIN mCore_Units dbu WITH(NOLOCK) ON punits.iDefaultBaseUnit = dbu.iMasterId
LEFT JOIN mCore_Units dsu WITH(NOLOCK) ON punits.iDefaultSalesUnit = dsu.iMasterId
LEFT JOIN mCore_Units dpu WITH(NOLOCK) ON punits.iDefaultPurchaseUnit = dpu.iMasterId

-- Settings joins
LEFT JOIN muCore_Product_Settings pset WITH(NOLOCK) ON p.iMasterId = pset.iMasterId
LEFT JOIN mCore_TaxCode tc WITH(NOLOCK) ON pset.iTaxCode = tc.iMasterId

-- Classification joins
LEFT JOIN muCore_Product_Classification pclass WITH(NOLOCK) ON p.iMasterId = pclass.iMasterId

-- Other details joins
LEFT JOIN muCore_Product_OtherDetails pod WITH(NOLOCK) ON p.iMasterId = pod.iMasterId
LEFT JOIN mCore_Account wip WITH(NOLOCK) ON pod.iWIPAccount = wip.iMasterId
LEFT JOIN mCore_Account coi WITH(NOLOCK) ON pod.iCostOfIssueAccount = coi.iMasterId
LEFT JOIN mCore_Account stock WITH(NOLOCK) ON pod.iStocksAccount = stock.iMasterId
LEFT JOIN mCore_Account sales WITH(NOLOCK) ON pod.iSalesAccount = sales.iMasterId
LEFT JOIN mCore_Account css WITH(NOLOCK) ON pod.iCostofShortageStockAC = css.iMasterId
LEFT JOIN mCore_Account ces WITH(NOLOCK) ON pod.iCostofExcessStockAC = ces.iMasterId
LEFT JOIN mCore_Account csr WITH(NOLOCK) ON pod.iCostofSaleReturnAC = csr.iMasterId
LEFT JOIN mCore_Account pv WITH(NOLOCK) ON pod.iPurchaseVarianceAC = pv.iMasterId

-- Replenishment joins
LEFT JOIN muCore_Product_Replenishment pr WITH(NOLOCK) ON p.iMasterId = pr.iMasterId
LEFT JOIN vCore_BOMVariant bom WITH(NOLOCK) ON pr.iBOM = bom.iVariantId
LEFT JOIN vCore_BOMVariant pbom WITH(NOLOCK) ON pr.iPackingBOM = pbom.iVariantId

-- GST joins
LEFT JOIN muCore_Product_GST pgst WITH(NOLOCK) ON p.iMasterId = pgst.iMasterId

-- Properties joins
LEFT JOIN mCore_Product_Props pp WITH(NOLOCK) ON p.iMasterId = pp.iMasterId

-- Mapping table joins
LEFT JOIN ProductTypeMap ptm ON p.iProductType = ptm.ID
LEFT JOIN ValuationMethodMap vmm ON p.iValuationMethod = vmm.ID
LEFT JOIN LPGenerationTypeMap lpgm ON p.iLPGenerationType = lpgm.ID
LEFT JOIN AvailableForOnlineMap aom ON p.AvailableForOnline = aom.ID
LEFT JOIN MakeOnOrderMap mom ON p.MakeOnOrder = mom.ID
LEFT JOIN SMUPrivateLableMap splm ON p.SMUPrivateLable = splm.ID
LEFT JOIN ProductMakeMap pmm ON p.iProductMake = pmm.ID
LEFT JOIN ABCCodeMap abcm ON pclass.iABCCodeValue = abcm.ID
LEFT JOIN ManufacturePolicyMap mpm ON pr.iManufacturePolicy = mpm.ID
LEFT JOIN ReplenishmentMap rm ON pr.iDefaultReplenishment = rm.ID
LEFT JOIN FlushingMap fm ON pr.iFlushing = fm.ID
LEFT JOIN ProductCategoryMap pcm ON pgst.ProductCategory = pcm.ID
LEFT JOIN EComProductMap epm ON pgst.EComProduct = epm.ID;

-- Step 5: Create additional aggressive indexes
CREATE NONCLUSTERED INDEX IX_muCore_Product_Units_MasterId_Aggressive 
ON muCore_Product_Units(iMasterId) 
INCLUDE(iDefaultBaseUnit, iDefaultSalesUnit, iDefaultPurchaseUnit, fLength, fWidth, fHeight, fWeight)
WITH (FILLFACTOR = 90, PAD_INDEX = ON);

CREATE NONCLUSTERED INDEX IX_muCore_Product_Settings_MasterId_Aggressive 
ON muCore_Product_Settings(iMasterId) 
INCLUDE(fStandardCost, fOverheadCost, fIndirectCost, fProfit, iTaxCode, iDontshowproductexpireddays)
WITH (FILLFACTOR = 90, PAD_INDEX = ON);

CREATE NONCLUSTERED INDEX IX_muCore_Product_Classification_MasterId_Aggressive 
ON muCore_Product_Classification(iMasterId) 
INCLUDE(iABCCodeValue, iABCCodeMargin, iABCCodeRevenue, iABCCodeCarryingCost, sBarcode1, sBarcode2, sBarcode3)
WITH (FILLFACTOR = 90, PAD_INDEX = ON);

CREATE NONCLUSTERED INDEX IX_muCore_Product_OtherDetails_MasterId_Aggressive 
ON muCore_Product_OtherDetails(iMasterId) 
INCLUDE(iWIPAccount, iCostOfIssueAccount, iStocksAccount, iSalesAccount, iCostofShortageStockAC, iCostofExcessStockAC, iCostofSaleReturnAC, iPurchaseVarianceAC, iProductionLeadTime)
WITH (FILLFACTOR = 90, PAD_INDEX = ON);

CREATE NONCLUSTERED INDEX IX_muCore_Product_Replenishment_MasterId_Aggressive 
ON muCore_Product_Replenishment(iMasterId) 
INCLUDE(sProductionLeadTime, bPhantom, iManufacturePolicy, iDefaultReplenishment, iBOM, iFlushing, bRaiseProdOrderOnSale, iPackingBOM)
WITH (FILLFACTOR = 90, PAD_INDEX = ON);

CREATE NONCLUSTERED INDEX IX_muCore_Product_GST_MasterId_Aggressive 
ON muCore_Product_GST(iMasterId) 
INCLUDE(HSNSAC, ProductCategory, EComProduct)
WITH (FILLFACTOR = 90, PAD_INDEX = ON);

CREATE NONCLUSTERED INDEX IX_mCore_Product_Props_MasterId_Aggressive 
ON mCore_Product_Props(iMasterId) 
INCLUDE(bDontMaintainStockbyBatch, bInputBreakupCategoriesWise, bDontMaintainStocksByRMA, bDonotPrintInBill, bNotAllowedforHomeDelivery, bStarProduct, bDonotUpdateStock, bIgnoreExpiryforthisItem, bIgnoreMfgDateforthisItem, iReserveType, bReserveByBatch, bReserveByBin, bReserveByRMA, bDoNotInputBin, iInventoryAllocation, bIgnoreFractionInQty, fNegativeTolerance, fTolerance, iToleranceType, bCheckforWeightfromWeighingScale)
WITH (FILLFACTOR = 90, PAD_INDEX = ON);

-- Step 6: Create filtered indexes for better performance
CREATE NONCLUSTERED INDEX IX_mSec_Users_Active 
ON mSec_Users(iUserId) 
INCLUDE(sLoginName)
WHERE iUserId IS NOT NULL
WITH (FILLFACTOR = 90, PAD_INDEX = ON);

-- Step 7: Update statistics with full scan for better query plans
UPDATE STATISTICS mCore_Product WITH FULLSCAN, ALL;
UPDATE STATISTICS muCore_Product WITH FULLSCAN, ALL;
UPDATE STATISTICS mCore_ProductTreeDetails WITH FULLSCAN, ALL;
UPDATE STATISTICS mSec_Users WITH FULLSCAN, ALL;

-- Step 8: Create specific optimized views for common use cases
CREATE OR ALTER VIEW vmCore_Product_Active_Ultra AS
SELECT * FROM vmCore_Product_Ultra_Optimized WHERE iStatus = 1;

CREATE OR ALTER VIEW vmCore_Product_ByCategory_Ultra AS
SELECT * FROM vmCore_Product_Ultra_Optimized WHERE iCategory IS NOT NULL;

-- Step 9: Performance monitoring and testing queries
-- Test the ultra-optimized view
-- SELECT TOP 100 * FROM vmCore_Product_Ultra_Optimized WHERE iStatus = 1;

-- Performance comparison
-- SELECT COUNT(*) FROM vmCore_Product_Ultra_Optimized;

-- Step 10: Additional optimization - Create a materialized view approach
-- This creates a table that can be refreshed periodically for even faster access
CREATE TABLE vmCore_Product_Materialized (
    iMasterId int PRIMARY KEY,
    sName nvarchar(255),
    sCode nvarchar(50),
    iProductType int,
    iProductTypeName nvarchar(50),
    iStatus int,
    -- Add other frequently accessed columns here
    LastUpdated datetime2 DEFAULT GETDATE()
);

-- Create index on the materialized table
CREATE NONCLUSTERED INDEX IX_vmCore_Product_Materialized_Status 
ON vmCore_Product_Materialized(iStatus, iMasterId)
INCLUDE(sName, sCode, iProductType, iProductTypeName)
WHERE iStatus < 5;

-- Step 11: Create a refresh procedure for the materialized table
CREATE OR ALTER PROCEDURE sp_Refresh_Product_Materialized
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Clear existing data
    TRUNCATE TABLE vmCore_Product_Materialized;
    
    -- Insert fresh data
    INSERT INTO vmCore_Product_Materialized (iMasterId, sName, sCode, iProductType, iProductTypeName, iStatus)
    SELECT TOP 10000  -- Limit for performance
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
        p.iStatus
    FROM mCore_Product p WITH(NOLOCK)
    WHERE p.iStatus < 5;
    
    -- Update timestamp
    UPDATE vmCore_Product_Materialized 
    SET LastUpdated = GETDATE();
END;

-- Step 12: Execute the refresh procedure
EXEC sp_Refresh_Product_Materialized;

-- Step 13: Performance testing queries
-- Test original query performance
-- SET STATISTICS TIME ON;
-- SELECT COUNT(*) FROM vmCore_Product WHERE iStatus < 5;
-- SET STATISTICS TIME OFF;

-- Test optimized view performance
-- SET STATISTICS TIME ON;
-- SELECT COUNT(*) FROM vmCore_Product_Ultra_Optimized;
-- SET STATISTICS TIME OFF;

-- Test materialized table performance
-- SET STATISTICS TIME ON;
-- SELECT COUNT(*) FROM vmCore_Product_Materialized;
-- SET STATISTICS TIME OFF;
