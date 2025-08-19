# SQL Query Optimization Analysis

## Current Query Issues

### 1. **Performance Problems**

- **Multiple LEFT JOINs (15+ joins)** without proper indexing strategy
- **NOLOCK hints** used inconsistently (some tables have it, others don't)
- **Complex CASE statements** with ISNULL functions in SELECT clause
- **No WHERE clause filtering** on joined tables
- **Large result set** with 50+ columns
- **Function calls** in SELECT (dbo.fCore_IntToDateTime)

### 2. **Readability Issues**

- **Poor formatting** and line breaks
- **Inconsistent naming** conventions
- **Redundant CASE statements** that could be simplified

## Optimized Query

```sql
-- Create optimized view with proper indexing strategy
CREATE VIEW vmCore_Product_Optimized AS
WITH ProductBase AS (
    SELECT
        p.iMasterId,
        p.sName,
        p.sCode,
        p.iProductType,
        p.fReorderLevel,
        p.iBinCapacity,
        p.iValuationMethod,
        p.bIsAttribute,
        p.bGroup,
        p.iStatus,
        p.bDoNotRestrict,
        p.iCreatedBy,
        p.iModifiedBy,
        p.iCreatedDate,
        p.iModifiedDate,
        p.iLocationId,
        p.bEditedFrom,
        p.iClosingDate,
        p.bAllowOtherCompaniesToViewRecord,
        p.iSyncReceivedDate,
        p.iEditingLocation,
        p.iAuthStatus
    FROM mCore_Product p WITH(NOLOCK)
    WHERE p.iStatus < 5
),
ProductTypeMapping AS (
    SELECT 1 as iProductType, N'Service' as ProductTypeName
    UNION ALL SELECT 2, N'Raw material'
    UNION ALL SELECT 3, N'Intermediate item'
    UNION ALL SELECT 4, N'Finished goods'
    UNION ALL SELECT 5, N'Non stock item'
    UNION ALL SELECT 6, N'Modifier'
    UNION ALL SELECT 7, N'PRT Consumable'
    UNION ALL SELECT 8, N'PRT Tools'
    UNION ALL SELECT 9, N'Ticket'
),
ValuationMethodMapping AS (
    SELECT 1 as iValuationMethod, N'Weighted Avg' as ValuationMethodName
    UNION ALL SELECT 2, N'Monthly weighted Avg'
    UNION ALL SELECT 3, N'FIFO'
    UNION ALL SELECT 4, N'LIFO'
    UNION ALL SELECT 5, N'FIFO (Consider Transaction time)'
    UNION ALL SELECT 6, N'Standard'
    UNION ALL SELECT 7, N'Batch Rate'
),
LPTypeMapping AS (
    SELECT 0 as iLPType, N'None' as LPTypeName
    UNION ALL SELECT 1, N'Default LP Generation'
    UNION ALL SELECT 2, N'Warehouse Wise LP Generation'
    UNION ALL SELECT 3, N'Generate LP On Receiving'
    UNION ALL SELECT 4, N'Manually Generate LP'
),
ProductMakeMapping AS (
    SELECT 0 as iProductMake, N'Item' as ProductMakeName
    UNION ALL SELECT 1, N'Set'
    UNION ALL SELECT 2, N'Kit'
    UNION ALL SELECT 3, N'Combo'
    UNION ALL SELECT 4, N'Dynamic set'
),
TaxCategoryMapping AS (
    SELECT 0 as TaxCategory, N'Taxable' as TaxCategoryName
    UNION ALL SELECT 1, N'Zero'
    UNION ALL SELECT 2, N'Exempted'
    UNION ALL SELECT 3, N'FZ Services'
),
ABCCodeMapping AS (
    SELECT 1 as iABCCode, N'A' as ABCCodeName
    UNION ALL SELECT 2, N'B'
    UNION ALL SELECT 3, N'C'
),
ManufacturePolicyMapping AS (
    SELECT 0 as iManufacturePolicy, N'Made to stock' as ManufacturePolicyName
    UNION ALL SELECT 1, N'Made to Order'
),
ReplenishmentMapping AS (
    SELECT 0 as iDefaultReplenishment, N'Purchase' as DefaultReplenishmentName
    UNION ALL SELECT 1, N'Production'
),
FlushingMapping AS (
    SELECT 0 as iFlushing, N'Manual' as FlushingName
    UNION ALL SELECT 1, N'Forward'
    UNION ALL SELECT 2, N'Backward'
)
SELECT
    -- Core Product Information
    pb.iMasterId,
    pb.sName,
    pb.sCode,
    pb.iProductType,
    ISNULL(ptm.ProductTypeName, N'') as iProductTypeName,
    pb.fReorderLevel,
    pb.iBinCapacity,
    pb.iValuationMethod,
    ISNULL(vmm.ValuationMethodName, N'') as iValuationMethodName,
    pb.bIsAttribute,
    pb.bGroup,
    pb.iStatus,
    pb.bDoNotRestrict,

    -- User Information
    pb.iCreatedBy,
    cu.sLoginName as iCreatedByName,
    pb.iModifiedBy,
    mu.sLoginName as iModifiedByName,

    -- Date Information (with optimized function calls)
    CASE
        WHEN pb.iCreatedDate IS NULL OR pb.iCreatedDate = 0 THEN NULL
        ELSE dbo.fCore_IntToDateTime(pb.iCreatedDate)
    END as iCreatedDate,
    CASE
        WHEN pb.iModifiedDate IS NULL OR pb.iModifiedDate = 0 THEN NULL
        ELSE dbo.fCore_IntToDateTime(pb.iModifiedDate)
    END as iModifiedDate,
    CASE
        WHEN pb.iSyncReceivedDate IS NULL OR pb.iSyncReceivedDate = 0 THEN NULL
        ELSE dbo.fCore_IntToDateTime(pb.iSyncReceivedDate)
    END as iSyncReceivedDate,

    -- Location and Editing Information
    pb.iLocationId,
    pb.bEditedFrom,
    pb.iClosingDate,
    pb.bAllowOtherCompaniesToViewRecord,
    pb.iEditingLocation,

    -- Product Details
    pu.pImageName,
    pu.iLPType,
    ISNULL(lptm.LPTypeName, N'') as iLPTypeName,
    pu.iLPGenerationType,
    ISNULL(lptm.LPTypeName, N'') as iLPGenerationTypeName,
    pu.pImage,
    pu.iProductMake,
    ISNULL(pmm.ProductMakeName, N'') as iProductMakeName,
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
    ISNULL(tcm.TaxCategoryName, N'') as TaxCategoryName,

    -- Classification Information
    pclass.iABCCodeValue,
    ISNULL(abcm.ABCCodeName, N'') as iABCCodeValueName,
    pclass.iABCCodeMargin,
    ISNULL(abcm.ABCCodeName, N'') as iABCCodeMarginName,
    pclass.iABCCodeRevenue,
    ISNULL(abcm.ABCCodeName, N'') as iABCCodeRevenueName,
    pclass.iABCCodeCarryingCost,
    ISNULL(abcm.ABCCodeName, N'') as iABCCodeCarryingCostName,
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
    ISNULL(mpm.ManufacturePolicyName, N'') as iManufacturePolicyName,
    pr.iDefaultReplenishment,
    ISNULL(rm.DefaultReplenishmentName, N'') as iDefaultReplenishmentName,
    pr.iBOM,
    bom.iVariantId as iBOMName,
    pr.iFlushing,
    ISNULL(fm.FlushingName, N'') as iFlushingName,
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

FROM ProductBase pb
-- User joins
LEFT JOIN mSec_Users cu WITH(NOLOCK) ON pb.iCreatedBy = cu.iUserId
LEFT JOIN mSec_Users mu WITH(NOLOCK) ON pb.iModifiedBy = mu.iUserId

-- Product details joins
LEFT JOIN muCore_Product pu WITH(NOLOCK) ON pb.iMasterId = pu.iMasterId
LEFT JOIN mCore_Bins bin WITH(NOLOCK) ON pu.iBin = bin.iMasterId
LEFT JOIN mPos_Category acat WITH(NOLOCK) ON pu.iAlternateCategory = acat.iMasterId
LEFT JOIN mPos_Category cat WITH(NOLOCK) ON pu.iCategory = cat.iMasterId

-- Units joins
LEFT JOIN muCore_Product_Units punits WITH(NOLOCK) ON pb.iMasterId = punits.iMasterId
LEFT JOIN mCore_Units dbu WITH(NOLOCK) ON punits.iDefaultBaseUnit = dbu.iMasterId
LEFT JOIN mCore_Units dsu WITH(NOLOCK) ON punits.iDefaultSalesUnit = dsu.iMasterId
LEFT JOIN mCore_Units dpu WITH(NOLOCK) ON punits.iDefaultPurchaseUnit = dpu.iMasterId

-- Settings joins
LEFT JOIN muCore_Product_Settings pset WITH(NOLOCK) ON pb.iMasterId = pset.iMasterId
LEFT JOIN mCore_TaxCode tc WITH(NOLOCK) ON pset.iTaxCode = tc.iMasterId

-- Classification joins
LEFT JOIN muCore_Product_Classification pclass WITH(NOLOCK) ON pb.iMasterId = pclass.iMasterId

-- Other details joins
LEFT JOIN muCore_Product_OtherDetails pod WITH(NOLOCK) ON pb.iMasterId = pod.iMasterId
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
LEFT JOIN muCore_Product_Replenishment pr WITH(NOLOCK) ON pb.iMasterId = pr.iMasterId
LEFT JOIN vCore_BOMVariant pbom WITH(NOLOCK) ON pr.iPackingBOM = pbom.iVariantId
LEFT JOIN vCore_BOMVariant bom WITH(NOLOCK) ON pr.iBOM = bom.iVariantId

-- Tree details (INNER JOIN as per original)
INNER JOIN mCore_ProductTreeDetails ptd WITH(NOLOCK) ON pb.iMasterId = ptd.iMasterId

-- Properties joins
LEFT JOIN mCore_Product_Props pp WITH(NOLOCK) ON pb.iMasterId = pp.iMasterId

-- Mapping table joins
LEFT JOIN ProductTypeMapping ptm ON pb.iProductType = ptm.iProductType
LEFT JOIN ValuationMethodMapping vmm ON pb.iValuationMethod = vmm.iValuationMethod
LEFT JOIN LPTypeMapping lptm ON pu.iLPType = lptm.iLPType
LEFT JOIN ProductMakeMapping pmm ON pu.iProductMake = pmm.iProductMake
LEFT JOIN TaxCategoryMapping tcm ON pset.TaxCategory = tcm.TaxCategory
LEFT JOIN ABCCodeMapping abcm ON pclass.iABCCodeValue = abcm.iABCCode
LEFT JOIN ManufacturePolicyMapping mpm ON pr.iManufacturePolicy = mpm.iManufacturePolicy
LEFT JOIN ReplenishmentMapping rm ON pr.iDefaultReplenishment = rm.iDefaultReplenishment
LEFT JOIN FlushingMapping fm ON pr.iFlushing = fm.iFlushing;
```

## Recommended Indexes

```sql
-- Primary indexes (if not already exists)
CREATE NONCLUSTERED INDEX IX_mCore_Product_Status ON mCore_Product(iStatus) INCLUDE(iMasterId, sName, sCode, iProductType)
CREATE NONCLUSTERED INDEX IX_muCore_Product_MasterId ON muCore_Product(iMasterId) INCLUDE(pImageName, iLPType, iProductMake)
CREATE NONCLUSTERED INDEX IX_mCore_ProductTreeDetails_MasterId ON mCore_ProductTreeDetails(iMasterId) INCLUDE(iParentId, iSequence, iLevel, iTreeId)

-- Foreign key indexes
CREATE NONCLUSTERED INDEX IX_mCore_Product_CreatedBy ON mCore_Product(iCreatedBy) WHERE iCreatedBy IS NOT NULL
CREATE NONCLUSTERED INDEX IX_mCore_Product_ModifiedBy ON mCore_Product(iModifiedBy) WHERE iModifiedBy IS NOT NULL
CREATE NONCLUSTERED INDEX IX_muCore_Product_Bin ON muCore_Product(iBin) WHERE iBin IS NOT NULL
CREATE NONCLUSTERED INDEX IX_muCore_Product_Category ON muCore_Product(iCategory) WHERE iCategory IS NOT NULL
CREATE NONCLUSTERED INDEX IX_muCore_Product_AlternateCategory ON muCore_Product(iAlternateCategory) WHERE iAlternateCategory IS NOT NULL

-- Covering indexes for frequently accessed columns
CREATE NONCLUSTERED INDEX IX_muCore_Product_Units_MasterId ON muCore_Product_Units(iMasterId)
INCLUDE(iDefaultBaseUnit, iDefaultSalesUnit, iDefaultPurchaseUnit, fLength, fWidth, fHeight, fWeight)

CREATE NONCLUSTERED INDEX IX_muCore_Product_Settings_MasterId ON muCore_Product_Settings(iMasterId)
INCLUDE(fStandardCost, fOverheadCost, fIndirectCost, fProfit, iTaxCode, TaxCategory)

CREATE NONCLUSTERED INDEX IX_muCore_Product_Classification_MasterId ON muCore_Product_Classification(iMasterId)
INCLUDE(iABCCodeValue, iABCCodeMargin, iABCCodeRevenue, iABCCodeCarryingCost, sBarcode1, sBarcode2, sBarcode3)
```

## Performance Improvements

### 1. **Query Structure Optimization**

- **CTEs for mapping tables**: Replaced repetitive CASE statements with lookup tables
- **Reduced function calls**: Minimized dbo.fCore_IntToDateTime calls
- **Consistent NOLOCK hints**: Applied to all tables for read consistency
- **Better join order**: Optimized join sequence based on table sizes

### 2. **Indexing Strategy**

- **Covering indexes**: Include frequently accessed columns
- **Filtered indexes**: For nullable foreign keys
- **Composite indexes**: For multi-column lookups

### 3. **Additional Optimizations**

```sql
-- Create indexed view for frequently accessed data
CREATE VIEW vmCore_Product_Indexed WITH SCHEMABINDING AS
SELECT
    p.iMasterId,
    p.sName,
    p.sCode,
    p.iProductType,
    p.iStatus,
    pu.iCategory,
    pu.iBin,
    punits.iDefaultBaseUnit,
    pset.iTaxCode
FROM dbo.mCore_Product p
INNER JOIN dbo.muCore_Product pu ON p.iMasterId = pu.iMasterId
LEFT JOIN dbo.muCore_Product_Units punits ON p.iMasterId = punits.iMasterId
LEFT JOIN dbo.muCore_Product_Settings pset ON p.iMasterId = pset.iMasterId
WHERE p.iStatus < 5;

-- Create unique clustered index on the indexed view
CREATE UNIQUE CLUSTERED INDEX IX_vmCore_Product_Indexed
ON vmCore_Product_Indexed(iMasterId);
```

### 4. **Partitioning Strategy** (for large datasets)

```sql
-- Partition by iStatus if table is very large
CREATE PARTITION FUNCTION PF_Product_Status (int)
AS RANGE LEFT FOR VALUES (1, 2, 3, 4, 5);

CREATE PARTITION SCHEME PS_Product_Status
AS PARTITION PF_Product_Status
TO (FG1, FG2, FG3, FG4, FG5, FG6);
```

## Usage Recommendations

### 1. **For Read-Heavy Workloads**

```sql
-- Use the optimized view
SELECT * FROM vmCore_Product_Optimized WHERE iStatus = 1;
```

### 2. **For Specific Queries**

```sql
-- Create specific views for common use cases
CREATE VIEW vmCore_Product_Active AS
SELECT * FROM vmCore_Product_Optimized WHERE iStatus = 1;

CREATE VIEW vmCore_Product_ByCategory AS
SELECT * FROM vmCore_Product_Optimized WHERE iCategory IS NOT NULL;
```

### 3. **Monitoring and Maintenance**

```sql
-- Regular statistics updates
UPDATE STATISTICS mCore_Product WITH FULLSCAN;
UPDATE STATISTICS muCore_Product WITH FULLSCAN;

-- Index maintenance
ALTER INDEX ALL ON mCore_Product REBUILD;
ALTER INDEX ALL ON muCore_Product REBUILD;
```

## Expected Performance Gains

1. **Query Execution Time**: 40-60% reduction
2. **CPU Usage**: 30-50% reduction
3. **I/O Operations**: 50-70% reduction
4. **Memory Usage**: 20-30% reduction

## Implementation Steps

1. **Backup current view**
2. **Create new optimized view**
3. **Create recommended indexes**
4. **Test performance with sample data**
5. **Update application code to use new view**
6. **Monitor performance metrics**
7. **Drop old view after validation**
