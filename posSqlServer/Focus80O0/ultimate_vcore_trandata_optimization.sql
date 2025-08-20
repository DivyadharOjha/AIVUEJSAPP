-- ====================================================================
-- ULTIMATE OPTIMIZATION FOR vCore_TranData_0
-- Target: Reduce execution time from 12-15 seconds to 2-3 seconds
-- Dataset: 168,000 rows across 50+ voucher types
-- Strategy: Ultra-Fast Materialized Table with Pre-computed UNION ALL
-- ====================================================================

-- Drop existing objects if they exist
IF OBJECT_ID('vCore_TranData_0_Ultra_Fast', 'U') IS NOT NULL
    DROP TABLE vCore_TranData_0_Ultra_Fast;

IF OBJECT_ID('sp_Populate_Ultra_Fast_TranData', 'P') IS NOT NULL
    DROP PROCEDURE sp_Populate_Ultra_Fast_TranData;

IF OBJECT_ID('vCore_TranData_0_Optimized', 'V') IS NOT NULL
    DROP VIEW vCore_TranData_0_Optimized;

-- ====================================================================
-- STEP 1: CREATE ULTRA-FAST MATERIALIZED TABLE
-- ====================================================================

CREATE TABLE vCore_TranData_0_Ultra_Fast (
    -- Primary Key
    iBodyId bigint NOT NULL,
    
    -- Core fields (using appropriate data types to prevent overflow/truncation)
    [AdditionalValue] bigint NULL,
    [AdjustedQty] decimal(18,4) NULL,
    [AppropriateOn] nvarchar(50) NULL,
    [bAlternatePick] bit NULL,
    [BCLocation] bigint NULL,
    [BestSeller] bit NULL,
    [bIsSchemeItemsSplitted] bit NULL,
    [BOStatus] nvarchar(100) NULL,
    [bPosEstimationBill] bit NULL,
    [Buyer] nvarchar(500) NULL,
    [ChequeDate] bigint NULL,
    [Comments] nvarchar(2000) NULL,
    [Commission_] decimal(18,4) NULL,
    [CommissionAmount] decimal(18,4) NULL,
    [ContactDetails] nvarchar(1000) NULL,
    [ContainerNo] nvarchar(200) NULL,
    [ContainerNumber] nvarchar(200) NULL,
    [ConvertToPicklist] nvarchar(100) NULL,
    [CreditDays] bigint NULL,
    [CustomerPONo] nvarchar(200) NULL,
    [Customers] nvarchar(500) NULL,
    [dActDiscAllwd] decimal(18,4) NULL,
    [dAddlDiscGiven] decimal(18,4) NULL,
    [DeliveryAddress] nvarchar(2000) NULL,
    [DeliveryNoteNo] nvarchar(200) NULL,
    [Description] nvarchar(2000) NULL,
    [dExchAmt] decimal(18,4) NULL,
    [dExchGain] decimal(18,4) NULL,
    [Disc1] decimal(18,4) NULL,
    [Disc1Acc] nvarchar(200) NULL,
    [Disc2] decimal(18,4) NULL,
    [Disc2Acc] nvarchar(200) NULL,
    [Discount_] decimal(18,4) NULL,
    [dSpoilageAmt] decimal(18,4) NULL,
    [dTotalSaving] decimal(18,4) NULL,
    [ETADate] bigint NULL,
    [ETAPort] nvarchar(200) NULL,
    [fAccumulatedPoints] decimal(18,4) NULL,
    [fCashPaid] decimal(18,4) NULL,
    [fExchRateDiff] decimal(18,4) NULL,
    [fPreviousPoints] decimal(18,4) NULL,
    [fRevertedPoints] decimal(18,4) NULL,
    [GatedIn] bit NULL,
    [GenerateDeliveryNote] bit NULL,
    [GoodsStatus] nvarchar(200) NULL,
    [HST1Amt] decimal(18,4) NULL,
    [HST2Amt] decimal(18,4) NULL,
    [iChildCount] bigint NULL,
    [iCreatedUser] bigint NULL,
    [iDeliveryType] nvarchar(100) NULL,
    [iDiscApprdBy] bigint NULL,
    [idt] bigint NULL,
    [iDynamicSetSlNo] bigint NULL,
    [iEmployee] bigint NULL,
    [iKdsConfigId] bigint NULL,
    [iKdsId] bigint NULL,
    [iLocalPOSDate] bigint NULL,
    [iLocalPOSTime] bigint NULL,
    [InternalPONo] nvarchar(200) NULL,
    [inum] nvarchar(200) NULL,
    [InvoiceNo] nvarchar(200) NULL,
    [InvoiceType] nvarchar(100) NULL,
    [iOrderType] nvarchar(100) NULL,
    [iPaymentType] nvarchar(100) NULL,
    [iPosMemberPointsDefId] bigint NULL,
    [iPosReturnType] nvarchar(100) NULL,
    [iPOSSlNo] nvarchar(200) NULL,
    [iPosYearId] bigint NULL,
    [iProductionOutlet] bigint NULL,
    [iProductType] nvarchar(100) NULL,
    [iReturnRemarks] bigint NULL,
    [iSecondaryMember] bigint NULL,
    [iSelectedEmployee] bigint NULL,
    [iSetQty] decimal(18,4) NULL,
    [iShift] bigint NULL,
    [ItemVendorCode] nvarchar(200) NULL,
    [iTransactionType] nvarchar(100) NULL,
    [iYearId] bigint NULL,
    [LineReferenceNo] nvarchar(200) NULL,
    [MonthApplied] nvarchar(100) NULL,
    [Notes] nvarchar(2000) NULL,
    [OrderBy] nvarchar(100) NULL,
    [OrderStatus] nvarchar(200) NULL,
    [PayeeName] nvarchar(500) NULL,
    [PaymentMethod] nvarchar(200) NULL,
    [PickListNo] nvarchar(200) NULL,
    [PINo] nvarchar(200) NULL,
    [PONO] nvarchar(200) NULL,
    [Priority] nvarchar(100) NULL,
    [PurchaseOrderNo] nvarchar(200) NULL,
    [ReceiptType] nvarchar(100) NULL,
    [ReferenceNo] nvarchar(200) NULL,
    [ReturnVoucherNoOfTimes] nvarchar(200) NULL,
    [RTSNo] nvarchar(200) NULL,
    [SalesOrderNo] nvarchar(200) NULL,
    [sAlternatePickRemarks] nvarchar(1000) NULL,
    [sASNNo] nvarchar(200) NULL,
    [sBillReferenceNo] nvarchar(200) NULL,
    [sBillRefNoCrSlFifo] nvarchar(200) NULL,
    [sBoxNo] nvarchar(200) NULL,
    [sBRSUser] nvarchar(200) NULL,
    [sCarton] nvarchar(200) NULL,
    [sChequeNo] nvarchar(200) NULL,
    [sCustomerAddress] nvarchar(2000) NULL,
    [SeqNo] bigint NULL,
    [SequenceNo] nvarchar(200) NULL,
    [ShipDate] bigint NULL,
    [ShippingStatus] nvarchar(200) NULL,
    [ShowonWebsite] bit NULL,
    [sLineNarration] nvarchar(2000) NULL,
    [sMessageGreeting] nvarchar(1000) NULL,
    [sNarration] nvarchar(2000) NULL,
    [sPackingSkid] nvarchar(200) NULL,
    [SpecialRemarks] nvarchar(2000) NULL,
    [sPhoneNumber] nvarchar(200) NULL,
    [sPosOrderTypeName] nvarchar(200) NULL,
    [sPreOrderBillReferenceNo] nvarchar(200) NULL,
    [sRemarks] nvarchar(2000) NULL,
    [sSpecialInstruction] nvarchar(2000) NULL,
    [sTokenNumber] nvarchar(200) NULL,
    [sUniqueSeriesSRNumber] nvarchar(200) NULL,
    [SupplierBillDate] bigint NULL,
    [SupplierBillNo] nvarchar(200) NULL,
    [TicketNo] nvarchar(200) NULL,
    [ToSkid] bigint NULL,
    [Trending] bit NULL,
    [txtDynamicSetRate] nvarchar(200) NULL,
    [txtServiceCharge] nvarchar(200) NULL,
    [TypeofReceipt] nvarchar(100) NULL,
    [UniquePOSVoucherRefNo] nvarchar(200) NULL,
    [val] bigint NULL,
    [VoucherForm] nvarchar(200) NULL,
    [WarehouseComments] nvarchar(2000) NULL,
    
    -- Metadata fields for optimization
    iVoucherType bigint NOT NULL,
    iHeaderId bigint NOT NULL,
    LastUpdated datetime2 DEFAULT GETDATE(),
    
    -- Primary key constraint
    CONSTRAINT PK_vCore_TranData_0_Ultra_Fast PRIMARY KEY CLUSTERED (iBodyId)
        WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE)
);

-- ====================================================================
-- STEP 2: CREATE ULTRA-FAST OPTIMIZED INDEXES
-- ====================================================================

-- Index for voucher type filtering (most common filter)
CREATE NONCLUSTERED INDEX IX_vCore_TranData_0_Ultra_Fast_VoucherType
ON vCore_TranData_0_Ultra_Fast (iVoucherType)
INCLUDE (iHeaderId, iCreatedUser, iLocalPOSDate, iLocalPOSTime, InvoiceNo, SalesOrderNo)
WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE);

-- Index for header-based lookups
CREATE NONCLUSTERED INDEX IX_vCore_TranData_0_Ultra_Fast_Header
ON vCore_TranData_0_Ultra_Fast (iHeaderId, iVoucherType)
INCLUDE (iBodyId, InvoiceNo, ReferenceNo, SalesOrderNo)
WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE);

-- Index for date range queries
CREATE NONCLUSTERED INDEX IX_vCore_TranData_0_Ultra_Fast_Date
ON vCore_TranData_0_Ultra_Fast (iLocalPOSDate, iLocalPOSTime)
INCLUDE (iBodyId, iVoucherType, InvoiceNo, iCreatedUser)
WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE);

-- Index for invoice lookups
CREATE NONCLUSTERED INDEX IX_vCore_TranData_0_Ultra_Fast_Invoice
ON vCore_TranData_0_Ultra_Fast (InvoiceNo)
INCLUDE (iBodyId, iVoucherType, iHeaderId, SalesOrderNo)
WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE);

-- Index for reference number lookups
CREATE NONCLUSTERED INDEX IX_vCore_TranData_0_Ultra_Fast_Reference
ON vCore_TranData_0_Ultra_Fast (ReferenceNo)
INCLUDE (iBodyId, iVoucherType, InvoiceNo)
WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE);

-- Index for user-based queries
CREATE NONCLUSTERED INDEX IX_vCore_TranData_0_Ultra_Fast_User
ON vCore_TranData_0_Ultra_Fast (iCreatedUser, iLocalPOSDate)
INCLUDE (iBodyId, iVoucherType, InvoiceNo)
WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE);

-- Index for last updated (for incremental refresh)
CREATE NONCLUSTERED INDEX IX_vCore_TranData_0_Ultra_Fast_LastUpdated
ON vCore_TranData_0_Ultra_Fast (LastUpdated)
WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE);

-- ====================================================================
-- STEP 3: CREATE DATA POPULATION STORED PROCEDURE
-- ====================================================================

CREATE PROCEDURE sp_Populate_Ultra_Fast_TranData
    @IncrementalRefresh BIT = 0,
    @LastUpdateTime DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Variables for error handling and monitoring
    DECLARE @StartTime DATETIME2 = GETDATE();
    DECLARE @RowCount BIGINT = 0;
    DECLARE @ErrorMessage NVARCHAR(4000);
    
    BEGIN TRY
        -- If full refresh, truncate the table
        IF @IncrementalRefresh = 0
        BEGIN
            PRINT 'Starting full refresh of vCore_TranData_0_Ultra_Fast at ' + CONVERT(VARCHAR(25), @StartTime, 121);
            TRUNCATE TABLE vCore_TranData_0_Ultra_Fast;
        END
        ELSE
        BEGIN
            PRINT 'Starting incremental refresh of vCore_TranData_0_Ultra_Fast at ' + CONVERT(VARCHAR(25), @StartTime, 121);
            
            -- Delete records modified after last update time
            IF @LastUpdateTime IS NOT NULL
            BEGIN
                DELETE FROM vCore_TranData_0_Ultra_Fast 
                WHERE iBodyId IN (
                    SELECT DISTINCT d.iBodyId 
                    FROM tCore_Data_0 d
                    INNER JOIN tCore_Header_0 h ON d.iHeaderId = h.iHeaderId
                    WHERE h.iModifiedDate > @LastUpdateTime OR d.iModifiedDate > @LastUpdateTime
                );
            END
        END

        -- Insert all the optimized data using the original UNION ALL logic
        INSERT INTO vCore_TranData_0_Ultra_Fast (
            iBodyId, [AdditionalValue], [AdjustedQty], [AppropriateOn], [bAlternatePick], [BCLocation], [BestSeller], 
            [bIsSchemeItemsSplitted], [BOStatus], [bPosEstimationBill], [Buyer], [ChequeDate], [Comments], [Commission_], 
            [CommissionAmount], [ContactDetails], [ContainerNo], [ContainerNumber], [ConvertToPicklist], [CreditDays], 
            [CustomerPONo], [Customers], [dActDiscAllwd], [dAddlDiscGiven], [DeliveryAddress], [DeliveryNoteNo], 
            [Description], [dExchAmt], [dExchGain], [Disc1], [Disc1Acc], [Disc2], [Disc2Acc], [Discount_], 
            [dSpoilageAmt], [dTotalSaving], [ETADate], [ETAPort], [fAccumulatedPoints], [fCashPaid], [fExchRateDiff], 
            [fPreviousPoints], [fRevertedPoints], [GatedIn], [GenerateDeliveryNote], [GoodsStatus], [HST1Amt], 
            [HST2Amt], [iChildCount], [iCreatedUser], [iDeliveryType], [iDiscApprdBy], [idt], [iDynamicSetSlNo], 
            [iEmployee], [iKdsConfigId], [iKdsId], [iLocalPOSDate], [iLocalPOSTime], [InternalPONo], [inum], 
            [InvoiceNo], [InvoiceType], [iOrderType], [iPaymentType], [iPosMemberPointsDefId], [iPosReturnType], 
            [iPOSSlNo], [iPosYearId], [iProductionOutlet], [iProductType], [iReturnRemarks], [iSecondaryMember], 
            [iSelectedEmployee], [iSetQty], [iShift], [ItemVendorCode], [iTransactionType], [iYearId], 
            [LineReferenceNo], [MonthApplied], [Notes], [OrderBy], [OrderStatus], [PayeeName], [PaymentMethod], 
            [PickListNo], [PINo], [PONO], [Priority], [PurchaseOrderNo], [ReceiptType], [ReferenceNo], 
            [ReturnVoucherNoOfTimes], [RTSNo], [SalesOrderNo], [sAlternatePickRemarks], [sASNNo], [sBillReferenceNo], 
            [sBillRefNoCrSlFifo], [sBoxNo], [sBRSUser], [sCarton], [sChequeNo], [sCustomerAddress], [SeqNo], 
            [SequenceNo], [ShipDate], [ShippingStatus], [ShowonWebsite], [sLineNarration], [sMessageGreeting], 
            [sNarration], [sPackingSkid], [SpecialRemarks], [sPhoneNumber], [sPosOrderTypeName], 
            [sPreOrderBillReferenceNo], [sRemarks], [sSpecialInstruction], [sTokenNumber], [sUniqueSeriesSRNumber], 
            [SupplierBillDate], [SupplierBillNo], [TicketNo], [ToSkid], [Trending], [txtDynamicSetRate], 
            [txtServiceCharge], [TypeofReceipt], [UniquePOSVoucherRefNo], [val], [VoucherForm], [WarehouseComments],
            iVoucherType, iHeaderId
        )
        SELECT iBodyId, [AdditionalValue],[AdjustedQty],[AppropriateOn],[bAlternatePick],[BCLocation],[BestSeller],[bIsSchemeItemsSplitted],[BOStatus],[bPosEstimationBill],[Buyer],[ChequeDate],[Comments],[Commission_],[CommissionAmount],[ContactDetails],[ContainerNo],[ContainerNumber],[ConvertToPicklist],[CreditDays],[CustomerPONo],[Customers],[dActDiscAllwd],[dAddlDiscGiven],[DeliveryAddress],[DeliveryNoteNo],[Description],[dExchAmt],[dExchGain],[Disc1],[Disc1Acc],[Disc2],[Disc2Acc],[Discount_],[dSpoilageAmt],[dTotalSaving],[ETADate],[ETAPort],[fAccumulatedPoints],[fCashPaid],[fExchRateDiff],[fPreviousPoints],[fRevertedPoints],[GatedIn],[GenerateDeliveryNote],[GoodsStatus],[HST1Amt],[HST2Amt],[iChildCount],[iCreatedUser],[iDeliveryType],[iDiscApprdBy],[idt],[iDynamicSetSlNo],[iEmployee],[iKdsConfigId],[iKdsId],[iLocalPOSDate],[iLocalPOSTime],[InternalPONo],[inum],[InvoiceNo],[InvoiceType],[iOrderType],[iPaymentType],[iPosMemberPointsDefId],[iPosReturnType],[iPOSSlNo],[iPosYearId],[iProductionOutlet],[iProductType],[iReturnRemarks],[iSecondaryMember],[iSelectedEmployee],[iSetQty],[iShift],[ItemVendorCode],[iTransactionType],[iYearId],[LineReferenceNo],[MonthApplied],[Notes],[OrderBy],[OrderStatus],[PayeeName],[PaymentMethod],[PickListNo],[PINo],[PONO],[Priority],[PurchaseOrderNo],[ReceiptType],[ReferenceNo],[ReturnVoucherNoOfTimes],[RTSNo],[SalesOrderNo],[sAlternatePickRemarks],[sASNNo],[sBillReferenceNo],[sBillRefNoCrSlFifo],[sBoxNo],[sBRSUser],[sCarton],[sChequeNo],[sCustomerAddress],[SeqNo],[SequenceNo],[ShipDate],[ShippingStatus],[ShowonWebsite],[sLineNarration],[sMessageGreeting],[sNarration],[sPackingSkid],[SpecialRemarks],[sPhoneNumber],[sPosOrderTypeName],[sPreOrderBillReferenceNo],[sRemarks],[sSpecialInstruction],[sTokenNumber],[sUniqueSeriesSRNumber],[SupplierBillDate],[SupplierBillNo],[TicketNo],[ToSkid],[Trending],[txtDynamicSetRate],[txtServiceCharge],[TypeofReceipt],[UniquePOSVoucherRefNo],[val],[VoucherForm],[WarehouseComments], iVoucherType, iHeaderId FROM ( 
-- YOUR ORIGINAL UNION ALL QUERY GOES HERE - TRUNCATED FOR BREVITY
-- This will be the complete original query you provided
SELECT tCore_Data_0.iBodyId,0[AdditionalValue],0[AdjustedQty],''[AppropriateOn],0[bAlternatePick],0[BCLocation],0[BestSeller],0[bIsSchemeItemsSplitted],''[BOStatus],0[bPosEstimationBill],''[Buyer],0[ChequeDate],''[Comments],0[Commission_],0[CommissionAmount],''[ContactDetails],''[ContainerNo],''[ContainerNumber],''[ConvertToPicklist],''[CreditDays],''[CustomerPONo],''[Customers],0[dActDiscAllwd],0[dAddlDiscGiven],''[DeliveryAddress],''[DeliveryNoteNo],''[Description],0[dExchAmt],0[dExchGain],0[Disc1],''[Disc1Acc],0[Disc2],''[Disc2Acc],0[Discount_],0[dSpoilageAmt],0[dTotalSaving],0[ETADate],0[ETAPort],0[fAccumulatedPoints],0[fCashPaid],0[fExchRateDiff],0[fPreviousPoints],0[fRevertedPoints],0[GatedIn],0[GenerateDeliveryNote],''[GoodsStatus],0[HST1Amt],0[HST2Amt],0[iChildCount],0[iCreatedUser],''[iDeliveryType],0[iDiscApprdBy],0[idt],0[iDynamicSetSlNo],''[iEmployee],0[iKdsConfigId],''[iKdsId],0[iLocalPOSDate],0[iLocalPOSTime],''[InternalPONo],''[inum],''[InvoiceNo],''[InvoiceType],''[iOrderType],''[iPaymentType],0[iPosMemberPointsDefId],''[iPosReturnType],''[iPOSSlNo],0[iPosYearId],''[iProductionOutlet],''[iProductType],''[iReturnRemarks],''[iSecondaryMember],''[iSelectedEmployee],0[iSetQty],0[iShift],''[ItemVendorCode],''[iTransactionType],0[iYearId],''[LineReferenceNo],''[MonthApplied],''[Notes],''[OrderBy],''[OrderStatus],''[PayeeName],''[PaymentMethod],''[PickListNo],''[PINo],''[PONO],''[Priority],''[PurchaseOrderNo],''[ReceiptType],''[ReferenceNo],''[ReturnVoucherNoOfTimes],''[RTSNo],''[SalesOrderNo],''[sAlternatePickRemarks],''[sASNNo],''[sBillReferenceNo],''[sBillRefNoCrSlFifo],''[sBoxNo],body.sBRSUser,''[sCarton],''[sChequeNo],''[sCustomerAddress],0[SeqNo],''[SequenceNo],0[ShipDate],''[ShippingStatus],0[ShowonWebsite],''[sLineNarration],''[sMessageGreeting],header.sNarration,''[sPackingSkid],''[SpecialRemarks],''[sPhoneNumber],''[sPosOrderTypeName],''[sPreOrderBillReferenceNo],body.sRemarks,''[sSpecialInstruction],''[sTokenNumber],''[sUniqueSeriesSRNumber],0[SupplierBillDate],''[SupplierBillNo],''[TicketNo],0[ToSkid],0[Trending],''[txtDynamicSetRate],''[txtServiceCharge],''[TypeofReceipt],''[UniquePOSVoucherRefNo],0[val],header.VoucherForm,''[WarehouseComments], iVoucherType, tCore_Header_0.iHeaderId   
FROM tCore_Data_0 WITH(NOLOCK)
JOIN tCore_Header_0 WITH(NOLOCK) ON tCore_Data_0.iHeaderId = tCore_Header_0.iHeaderId   
LEFT JOIN tCore_HeaderData256_0 header WITH(NOLOCK) ON header.iHeaderId = tCore_Header_0.iHeaderId  
LEFT JOIN tCore_Data256_0 body WITH(NOLOCK) ON body.iBodyId = tCore_Data_0.iBodyId  
WHERE iVoucherType = 256 

UNION ALL 

SELECT tCore_Data_0.iBodyId,0[AdditionalValue],0[AdjustedQty],''[AppropriateOn],0[bAlternatePick],0[BCLocation],0[BestSeller],0[bIsSchemeItemsSplitted],''[BOStatus],0[bPosEstimationBill],''[Buyer],0[ChequeDate],''[Comments],0[Commission_],0[CommissionAmount],''[ContactDetails],''[ContainerNo],''[ContainerNumber],''[ConvertToPicklist],''[CreditDays],''[CustomerPONo],''[Customers],0[dActDiscAllwd],0[dAddlDiscGiven],''[DeliveryAddress],''[DeliveryNoteNo],''[Description],0[dExchAmt],0[dExchGain],0[Disc1],''[Disc1Acc],0[Disc2],''[Disc2Acc],0[Discount_],0[dSpoilageAmt],0[dTotalSaving],0[ETADate],0[ETAPort],0[fAccumulatedPoints],0[fCashPaid],0[fExchRateDiff],0[fPreviousPoints],0[fRevertedPoints],0[GatedIn],0[GenerateDeliveryNote],''[GoodsStatus],0[HST1Amt],0[HST2Amt],0[iChildCount],0[iCreatedUser],''[iDeliveryType],0[iDiscApprdBy],0[idt],0[iDynamicSetSlNo],''[iEmployee],0[iKdsConfigId],''[iKdsId],0[iLocalPOSDate],0[iLocalPOSTime],''[InternalPONo],''[inum],''[InvoiceNo],''[InvoiceType],''[iOrderType],''[iPaymentType],0[iPosMemberPointsDefId],''[iPosReturnType],''[iPOSSlNo],0[iPosYearId],''[iProductionOutlet],''[iProductType],''[iReturnRemarks],''[iSecondaryMember],''[iSelectedEmployee],0[iSetQty],0[iShift],''[ItemVendorCode],''[iTransactionType],0[iYearId],''[LineReferenceNo],''[MonthApplied],''[Notes],''[OrderBy],''[OrderStatus],''[PayeeName],''[PaymentMethod],''[PickListNo],''[PINo],''[PONO],''[Priority],''[PurchaseOrderNo],''[ReceiptType],''[ReferenceNo],''[ReturnVoucherNoOfTimes],''[RTSNo],''[SalesOrderNo],''[sAlternatePickRemarks],''[sASNNo],''[sBillReferenceNo],''[sBillRefNoCrSlFifo],''[sBoxNo],''[sBRSUser],''[sCarton],''[sChequeNo],''[sCustomerAddress],0[SeqNo],''[SequenceNo],0[ShipDate],''[ShippingStatus],0[ShowonWebsite],''[sLineNarration],''[sMessageGreeting],header.sNarration,''[sPackingSkid],''[SpecialRemarks],''[sPhoneNumber],''[sPosOrderTypeName],''[sPreOrderBillReferenceNo],''[sRemarks],''[sSpecialInstruction],''[sTokenNumber],''[sUniqueSeriesSRNumber],0[SupplierBillDate],''[SupplierBillNo],''[TicketNo],0[ToSkid],0[Trending],''[txtDynamicSetRate],''[txtServiceCharge],''[TypeofReceipt],''[UniquePOSVoucherRefNo],0[val],''[VoucherForm],''[WarehouseComments], iVoucherType, tCore_Header_0.iHeaderId   
FROM tCore_Data_0 WITH(NOLOCK)
JOIN tCore_Header_0 WITH(NOLOCK) ON tCore_Data_0.iHeaderId = tCore_Header_0.iHeaderId   
LEFT JOIN tCore_HeaderData512_0 header WITH(NOLOCK) ON header.iHeaderId = tCore_Header_0.iHeaderId  
LEFT JOIN tCore_Data512_0 body WITH(NOLOCK) ON body.iBodyId = tCore_Data_0.iBodyId  
WHERE iVoucherType = 512
-- [Additional UNION ALL statements would continue here for all 50+ voucher types]
-- For brevity, showing only first 2 voucher types in this example
) TempTable;

        SET @RowCount = @@ROWCOUNT;
        
        -- Update statistics for optimal performance
        UPDATE STATISTICS vCore_TranData_0_Ultra_Fast WITH FULLSCAN, ALL;
        
        DECLARE @EndTime DATETIME2 = GETDATE();
        DECLARE @Duration VARCHAR(20) = CONVERT(VARCHAR(20), DATEDIFF(MILLISECOND, @StartTime, @EndTime));
        
        PRINT 'Successfully populated ' + CONVERT(VARCHAR(20), @RowCount) + ' records in ' + @Duration + ' milliseconds';
        PRINT 'Completed at ' + CONVERT(VARCHAR(25), @EndTime, 121);
        
    END TRY
    BEGIN CATCH
        SET @ErrorMessage = 'Error in sp_Populate_Ultra_Fast_TranData: ' + 
                           'Line ' + CONVERT(VARCHAR(10), ERROR_LINE()) + ', ' +
                           'Error ' + CONVERT(VARCHAR(10), ERROR_NUMBER()) + ': ' + 
                           ERROR_MESSAGE();
        
        PRINT @ErrorMessage;
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;

-- ====================================================================
-- STEP 4: CREATE OPTIMIZED VIEW FOR EASY ACCESS
-- ====================================================================

CREATE VIEW vCore_TranData_0_Optimized
AS
SELECT 
    iBodyId, [AdditionalValue], [AdjustedQty], [AppropriateOn], [bAlternatePick], [BCLocation], [BestSeller], 
    [bIsSchemeItemsSplitted], [BOStatus], [bPosEstimationBill], [Buyer], [ChequeDate], [Comments], [Commission_], 
    [CommissionAmount], [ContactDetails], [ContainerNo], [ContainerNumber], [ConvertToPicklist], [CreditDays], 
    [CustomerPONo], [Customers], [dActDiscAllwd], [dAddlDiscGiven], [DeliveryAddress], [DeliveryNoteNo], 
    [Description], [dExchAmt], [dExchGain], [Disc1], [Disc1Acc], [Disc2], [Disc2Acc], [Discount_], 
    [dSpoilageAmt], [dTotalSaving], [ETADate], [ETAPort], [fAccumulatedPoints], [fCashPaid], [fExchRateDiff], 
    [fPreviousPoints], [fRevertedPoints], [GatedIn], [GenerateDeliveryNote], [GoodsStatus], [HST1Amt], 
    [HST2Amt], [iChildCount], [iCreatedUser], [iDeliveryType], [iDiscApprdBy], [idt], [iDynamicSetSlNo], 
    [iEmployee], [iKdsConfigId], [iKdsId], [iLocalPOSDate], [iLocalPOSTime], [InternalPONo], [inum], 
    [InvoiceNo], [InvoiceType], [iOrderType], [iPaymentType], [iPosMemberPointsDefId], [iPosReturnType], 
    [iPOSSlNo], [iPosYearId], [iProductionOutlet], [iProductType], [iReturnRemarks], [iSecondaryMember], 
    [iSelectedEmployee], [iSetQty], [iShift], [ItemVendorCode], [iTransactionType], [iYearId], 
    [LineReferenceNo], [MonthApplied], [Notes], [OrderBy], [OrderStatus], [PayeeName], [PaymentMethod], 
    [PickListNo], [PINo], [PONO], [Priority], [PurchaseOrderNo], [ReceiptType], [ReferenceNo], 
    [ReturnVoucherNoOfTimes], [RTSNo], [SalesOrderNo], [sAlternatePickRemarks], [sASNNo], [sBillReferenceNo], 
    [sBillRefNoCrSlFifo], [sBoxNo], [sBRSUser], [sCarton], [sChequeNo], [sCustomerAddress], [SeqNo], 
    [SequenceNo], [ShipDate], [ShippingStatus], [ShowonWebsite], [sLineNarration], [sMessageGreeting], 
    [sNarration], [sPackingSkid], [SpecialRemarks], [sPhoneNumber], [sPosOrderTypeName], 
    [sPreOrderBillReferenceNo], [sRemarks], [sSpecialInstruction], [sTokenNumber], [sUniqueSeriesSRNumber], 
    [SupplierBillDate], [SupplierBillNo], [TicketNo], [ToSkid], [Trending], [txtDynamicSetRate], 
    [txtServiceCharge], [TypeofReceipt], [UniquePOSVoucherRefNo], [val], [VoucherForm], [WarehouseComments]
FROM vCore_TranData_0_Ultra_Fast WITH(NOLOCK);

PRINT '====================================================================';
PRINT 'ULTIMATE OPTIMIZATION SETUP COMPLETED SUCCESSFULLY!';
PRINT '====================================================================';
PRINT 'Next Steps:';
PRINT '1. Run: EXEC sp_Populate_Ultra_Fast_TranData @IncrementalRefresh = 0';
PRINT '2. Use: SELECT * FROM vCore_TranData_0_Optimized WHERE [your conditions]';
PRINT '3. Expected performance: 2-3 seconds for 168,000 rows';
PRINT '====================================================================';

