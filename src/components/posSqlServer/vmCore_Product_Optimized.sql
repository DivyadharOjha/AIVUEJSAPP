-- Quick SQL Query Optimization Script
-- This script provides immediate performance improvements for the vmCore_Product view

-- Step 1: Create optimized indexes (run these first)
CREATE NONCLUSTERED INDEX IX_mCore_Product_Status_MasterId 
ON mCore_Product(iStatus, iMasterId) 
INCLUDE(sName, sCode, iProductType, iCreatedBy, iModifiedBy, iCreatedDate, iModifiedDate)
WHERE iStatus < 5;

CREATE NONCLUSTERED INDEX IX_muCore_Product_MasterId_Covering 
ON muCore_Product(iMasterId) 
INCLUDE(pImageName, iLPType, iProductMake, iBin, iCategory, iAlternateCategory, sDescription);

CREATE NONCLUSTERED INDEX IX_mCore_ProductTreeDetails_MasterId_Covering 
ON mCore_ProductTreeDetails(iMasterId) 
INCLUDE(iParentId, iSequence, iLevel, iTreeId);

-- Step 2: Create optimized view with better structure
CREATE OR ALTER VIEW vmCore_Product_Optimized AS
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
)
SELECT 
    -- Core Product Information
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
    
    -- User Information
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
    
    -- Product Details
    pu.pImageName,
    pu.iLPType,
    CASE ISNULL(pu.iLPType,0) 
        WHEN 0 THEN N'None'
        WHEN 1 THEN N'Default LP Generation'
        WHEN 2 THEN N'Warehouse Wise LP Generation'
        WHEN 3 THEN N'Generate LP On Receiving'
        WHEN 4 THEN N'Manually Generate LP'
        ELSE N'' END as iLPTypeName,
    pu.iLPGenerationType,
    CASE ISNULL(pu.iLPGenerationType,0) 
        WHEN 0 THEN N'None'
        WHEN 1 THEN N'Default LP Generation'
        WHEN 2 THEN N'Warehouse Wise LP Generation'
        WHEN 3 THEN N'Generate LP On Receiving'
        WHEN 4 THEN N'Manually Generate LP'
        ELSE N'' END as iLPGenerationTypeName,
    pu.pImage,
    pu.iProductMake,
    CASE ISNULL(pu.iProductMake,0) 
        WHEN 0 THEN N'Item'
        WHEN 1 THEN N'Set'
        WHEN 2 THEN N'Kit'
        WHEN 3 THEN N'Combo'
        WHEN 4 THEN N'Dynamic set'
        ELSE N'' END as iProductMakeName,
    pu.bAllowedforSodexoRedemption,
    pu.iDonotshowtheItemsexpirewithindays,
    pu.DiscounZero,
    pu.Printer,
    pu.sDescription,
    pu.bPerishableItem,
    
    -- Bin Information
    pu.iBin,
    bin.sName as iBinName,
    
    -- Category Information
    pu.iAlternateCategory,
    acat.sName as iAlternateCategoryName,
    pu.iCategory,
    cat.sName as iCategoryName,
    
    -- Units Information
    punits.bConvertToBaseUnitWhenItemScannedPOS,
    punits.bDonotAllowToChangeUnitInTransaction,
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
    
    -- Settings Information
    pset.fStandardCost,
    pset.fOverheadCost,
    pset.fIndirectCost,
    pset.fProfit,
    pset.iTaxCode,
    tc.sName as iTaxCodeName,
    pset.iDontshowproductexpireddays,
    pset.TaxCategory,
    CASE ISNULL(pset.TaxCategory,0) 
        WHEN 0 THEN N'Taxable'
        WHEN 1 THEN N'Zero'
        WHEN 2 THEN N'Exempted'
        WHEN 3 THEN N'FZ Services'
        ELSE N'' END as TaxCategoryName,
    
    -- Classification Information
    pclass.iABCCodeValue,
    CASE ISNULL(pclass.iABCCodeValue,1) 
        WHEN 1 THEN N'A'
        WHEN 2 THEN N'B'
        WHEN 3 THEN N'C'
        ELSE N'' END as iABCCodeValueName,
    pclass.iABCCodeMargin,
    CASE ISNULL(pclass.iABCCodeMargin,1) 
        WHEN 1 THEN N'A'
        WHEN 2 THEN N'B'
        WHEN 3 THEN N'C'
        ELSE N'' END as iABCCodeMarginName,
    pclass.iABCCodeRevenue,
    CASE ISNULL(pclass.iABCCodeRevenue,1) 
        WHEN 1 THEN N'A'
        WHEN 2 THEN N'B'
        WHEN 3 THEN N'C'
        ELSE N'' END as iABCCodeRevenueName,
    pclass.iABCCodeCarryingCost,
    CASE ISNULL(pclass.iABCCodeCarryingCost,1) 
        WHEN 1 THEN N'A'
        WHEN 2 THEN N'B'
        WHEN 3 THEN N'C'
        ELSE N'' END as iABCCodeCarryingCostName,
    pclass.sBarcode1,
    pclass.sBarcode2,
    pclass.sBarcode3,
    
    -- Account Information
    pod.iWIPAccount,
    wip.sName as iWIPAccountName,
    pod.iCostOfIssueAccount,
    coi.sName as iCostOfIssueAccountName,
    pod.iStocksAccount,
    stock.sName as iStocksAccountName,
    pod.iSalesAccount,
    sales.sName as iSalesAccountName,
    pod.VATExpenseAccount,
    vat.sName as VATExpenseAccountName,
    pod.iCostofShortageStockAC,
    css.sName as iCostofShortageStockACName,
    pod.iCostofExcessStockAC,
    ces.sName as iCostofExcessStockACName,
    pod.iCostofSaleReturnAC,
    csr.sName as iCostofSaleReturnACName,
    pod.iPurchaseVarianceAC,
    pv.sName as iPurchaseVarianceACName,
    
    -- Replenishment Information
    pr.bPhantom,
    pr.iPackingBOM,
    pbom.iVariantId as iPackingBOMName,
    pr.iManufacturePolicy,
    CASE ISNULL(pr.iManufacturePolicy,0) 
        WHEN 0 THEN N'Made to stock'
        WHEN 1 THEN N'Made to Order'
        ELSE N'' END as iManufacturePolicyName,
    pr.iDefaultReplenishment,
    CASE ISNULL(pr.iDefaultReplenishment,0) 
        WHEN 0 THEN N'Purchase'
        WHEN 1 THEN N'Production'
        ELSE N'' END as iDefaultReplenishmentName,
    pr.iBOM,
    bom.iVariantId as iBOMName,
    pr.iFlushing,
    CASE ISNULL(pr.iFlushing,0) 
        WHEN 0 THEN N'Manual'
        WHEN 1 THEN N'Forward'
        WHEN 2 THEN N'Backward'
        ELSE N'' END as iFlushingName,
    pr.bRaiseProdOrderOnSale,
    
    -- Tree Information
    ptd.iParentId,
    ptd.iSequence,
    ptd.iLevel,
    ptd.iTreeId,
    
    -- Product Properties
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

FROM mCore_Product p WITH(NOLOCK)
-- User joins
LEFT JOIN mSec_Users cu WITH(NOLOCK) ON p.iCreatedBy = cu.iUserId
LEFT JOIN mSec_Users mu WITH(NOLOCK) ON p.iModifiedBy = mu.iUserId

-- Product details joins
LEFT JOIN muCore_Product pu WITH(NOLOCK) ON p.iMasterId = pu.iMasterId
LEFT JOIN mCore_Bins bin WITH(NOLOCK) ON pu.iBin = bin.iMasterId
LEFT JOIN mPos_Category acat WITH(NOLOCK) ON pu.iAlternateCategory = acat.iMasterId
LEFT JOIN mPos_Category cat WITH(NOLOCK) ON pu.iCategory = cat.iMasterId

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
LEFT JOIN mCore_Account vat WITH(NOLOCK) ON pod.VATExpenseAccount = vat.iMasterId
LEFT JOIN mCore_Account css WITH(NOLOCK) ON pod.iCostofShortageStockAC = css.iMasterId
LEFT JOIN mCore_Account ces WITH(NOLOCK) ON pod.iCostofExcessStockAC = ces.iMasterId
LEFT JOIN mCore_Account csr WITH(NOLOCK) ON pod.iCostofSaleReturnAC = csr.iMasterId
LEFT JOIN mCore_Account pv WITH(NOLOCK) ON pod.iPurchaseVarianceAC = pv.iMasterId

-- Replenishment joins
LEFT JOIN muCore_Product_Replenishment pr WITH(NOLOCK) ON p.iMasterId = pr.iMasterId
LEFT JOIN vCore_BOMVariant pbom WITH(NOLOCK) ON pr.iPackingBOM = pbom.iVariantId
LEFT JOIN vCore_BOMVariant bom WITH(NOLOCK) ON pr.iBOM = bom.iVariantId

-- Tree details (INNER JOIN as per original)
INNER JOIN mCore_ProductTreeDetails ptd WITH(NOLOCK) ON p.iMasterId = ptd.iMasterId

-- Properties joins
LEFT JOIN mCore_Product_Props pp WITH(NOLOCK) ON p.iMasterId = pp.iMasterId

-- Mapping table joins
LEFT JOIN ProductTypeMap ptm ON p.iProductType = ptm.ID
LEFT JOIN ValuationMethodMap vmm ON p.iValuationMethod = vmm.ID

WHERE p.iStatus < 5;

-- Step 3: Create additional covering indexes for better performance
CREATE NONCLUSTERED INDEX IX_muCore_Product_Units_MasterId_Covering 
ON muCore_Product_Units(iMasterId) 
INCLUDE(iDefaultBaseUnit, iDefaultSalesUnit, iDefaultPurchaseUnit, fLength, fWidth, fHeight, fWeight);

CREATE NONCLUSTERED INDEX IX_muCore_Product_Settings_MasterId_Covering 
ON muCore_Product_Settings(iMasterId) 
INCLUDE(fStandardCost, fOverheadCost, fIndirectCost, fProfit, iTaxCode, TaxCategory);

CREATE NONCLUSTERED INDEX IX_muCore_Product_Classification_MasterId_Covering 
ON muCore_Product_Classification(iMasterId) 
INCLUDE(iABCCodeValue, iABCCodeMargin, iABCCodeRevenue, iABCCodeCarryingCost, sBarcode1, sBarcode2, sBarcode3);

-- Step 4: Update statistics for better query plan generation
UPDATE STATISTICS mCore_Product WITH FULLSCAN;
UPDATE STATISTICS muCore_Product WITH FULLSCAN;
UPDATE STATISTICS mCore_ProductTreeDetails WITH FULLSCAN;

-- Step 5: Test the optimized view
-- SELECT TOP 100 * FROM vmCore_Product_Optimized WHERE iStatus = 1;

-- Performance monitoring query
-- SELECT 
--     execution_count,
--     total_elapsed_time / 1000000.0 as total_elapsed_time_seconds,
--     (total_elapsed_time / execution_count) / 1000000.0 as avg_elapsed_time_seconds,
--     total_logical_reads,
--     total_physical_reads
-- FROM sys.dm_exec_procedure_stats 
-- WHERE object_name(object_id) LIKE '%Product%';
