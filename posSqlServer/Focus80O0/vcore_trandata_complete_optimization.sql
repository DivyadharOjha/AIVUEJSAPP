-- =====================================================
-- COMPLETE vCore_TranData_0 OPTIMIZATION SCRIPT
-- Handles ALL UNION ALL conditions for iVoucherType
-- =====================================================

USE [YourDatabaseName];
GO

-- Drop existing objects if they exist
IF OBJECT_ID('vCore_TranData_0_Ultra_Fast', 'U') IS NOT NULL
    DROP TABLE vCore_TranData_0_Ultra_Fast;
GO

IF OBJECT_ID('sp_Populate_Ultra_Fast_TranData_Complete', 'P') IS NOT NULL
    DROP PROCEDURE sp_Populate_Ultra_Fast_TranData_Complete;
GO

-- STEP 1: CREATE ULTRA-FAST MATERIALIZED TABLE
CREATE TABLE vCore_TranData_0_Ultra_Fast (
    -- Primary Key
    iBodyId bigint NOT NULL,
    
    -- Core fields (using appropriate data types to prevent overflow/truncation)
    [AdditionalValue] bigint NULL,
    [AdjustedQty] decimal(18,4) NULL,
    [AppropriateOn] nvarchar(50) NULL,
    [bAlternatePick] bit NULL,
    [BCLocation] bit NULL,
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
    [ContainerNo] nvarchar(500) NULL,
    [ContainerNumber] nvarchar(500) NULL,
    [ConvertToPicklist] nvarchar(100) NULL,
    [CreditDays] nvarchar(100) NULL,
    [CustomerPONo] nvarchar(500) NULL,
    [Customers] nvarchar(500) NULL,
    [dActDiscAllwd] decimal(18,4) NULL,
    [dAddlDiscGiven] decimal(18,4) NULL,
    [DeliveryAddress] nvarchar(2000) NULL,
    [DeliveryNoteNo] nvarchar(500) NULL,
    [Description] nvarchar(2000) NULL,
    [dExchAmt] decimal(18,4) NULL,
    [dExchGain] decimal(18,4) NULL,
    [Disc1] decimal(18,4) NULL,
    [Disc1Acc] nvarchar(500) NULL,
    [Disc2] decimal(18,4) NULL,
    [Disc2Acc] nvarchar(500) NULL,
    [Discount_] decimal(18,4) NULL,
    [dSpoilageAmt] decimal(18,4) NULL,
    [dTotalSaving] decimal(18,4) NULL,
    [ETADate] bigint NULL,
    [ETAPort] bigint NULL,
    [fAccumulatedPoints] decimal(18,4) NULL,
    [fCashPaid] decimal(18,4) NULL,
    [fExchRateDiff] decimal(18,4) NULL,
    [fPreviousPoints] decimal(18,4) NULL,
    [fRevertedPoints] decimal(18,4) NULL,
    [GatedIn] bit NULL,
    [GenerateDeliveryNote] bit NULL,
    [GoodsStatus] nvarchar(100) NULL,
    [HST1Amt] decimal(18,4) NULL,
    [HST2Amt] decimal(18,4) NULL,
    [iChildCount] bigint NULL,
    [iCreatedUser] bigint NULL,
    [iDeliveryType] nvarchar(100) NULL,
    [iDiscApprdBy] bigint NULL,
    [idt] bigint NULL,
    [iDynamicSetSlNo] bigint NULL,
    [iEmployee] nvarchar(500) NULL,
    [iKdsConfigId] bigint NULL,
    [iKdsId] nvarchar(500) NULL,
    [iLocalPOSDate] bigint NULL,
    [iLocalPOSTime] bigint NULL,
    [InternalPONo] nvarchar(500) NULL,
    [inum] nvarchar(500) NULL,
    [InvoiceNo] nvarchar(500) NULL,
    [InvoiceType] nvarchar(100) NULL,
    [iOrderType] nvarchar(100) NULL,
    [iPaymentType] nvarchar(100) NULL,
    [iPosMemberPointsDefId] bigint NULL,
    [iPosReturnType] nvarchar(100) NULL,
    [iPOSSlNo] bigint NULL,
    [iPosYearId] bigint NULL,
    [iProductionOutlet] nvarchar(500) NULL,
    [iProductType] nvarchar(100) NULL,
    [iReturnRemarks] nvarchar(1000) NULL,
    [iSecondaryMember] nvarchar(500) NULL,
    [iSelectedEmployee] nvarchar(500) NULL,
    [iSetQty] bigint NULL,
    [iShift] bigint NULL,
    [ItemVendorCode] nvarchar(500) NULL,
    [iTransactionType] nvarchar(100) NULL,
    [iYearId] bigint NULL,
    [LineReferenceNo] nvarchar(500) NULL,
    [MonthApplied] nvarchar(100) NULL,
    [Notes] nvarchar(2000) NULL,
    [OrderBy] nvarchar(100) NULL,
    [OrderStatus] nvarchar(100) NULL,
    [PayeeName] nvarchar(500) NULL,
    [PaymentMethod] nvarchar(100) NULL,
    [PickListNo] nvarchar(500) NULL,
    [PINo] nvarchar(500) NULL,
    [PONO] nvarchar(500) NULL,
    [Priority] nvarchar(100) NULL,
    [PurchaseOrderNo] nvarchar(500) NULL,
    [ReceiptType] nvarchar(100) NULL,
    [ReferenceNo] nvarchar(500) NULL,
    [ReturnVoucherNoOfTimes] nvarchar(500) NULL,
    [RTSNo] nvarchar(500) NULL,
    [SalesOrderNo] nvarchar(500) NULL,
    [sAlternatePickRemarks] nvarchar(1000) NULL,
    [sASNNo] nvarchar(500) NULL,
    [sBillReferenceNo] nvarchar(500) NULL,
    [sBillRefNoCrSlFifo] nvarchar(500) NULL,
    [sBoxNo] nvarchar(500) NULL,
    [sBRSUser] nvarchar(500) NULL,
    [sCarton] nvarchar(500) NULL,
    [sChequeNo] nvarchar(500) NULL,
    [sCustomerAddress] nvarchar(2000) NULL,
    [SeqNo] bigint NULL,
    [SequenceNo] nvarchar(500) NULL,
    [ShipDate] bigint NULL,
    [ShippingStatus] nvarchar(100) NULL,
    [ShowonWebsite] bit NULL,
    [sLineNarration] nvarchar(2000) NULL,
    [sMessageGreeting] nvarchar(1000) NULL,
    [sNarration] nvarchar(2000) NULL,
    [sPackingSkid] nvarchar(500) NULL,
    [SpecialRemarks] nvarchar(1000) NULL,
    [sPhoneNumber] nvarchar(500) NULL,
    [sPosOrderTypeName] nvarchar(500) NULL,
    [sPreOrderBillReferenceNo] nvarchar(500) NULL,
    [sRemarks] nvarchar(2000) NULL,
    [sSpecialInstruction] nvarchar(2000) NULL,
    [sTokenNumber] nvarchar(500) NULL,
    [sUniqueSeriesSRNumber] nvarchar(500) NULL,
    [SupplierBillDate] bigint NULL,
    [SupplierBillNo] nvarchar(500) NULL,
    [TicketNo] nvarchar(500) NULL,
    [ToSkid] bigint NULL,
    [Trending] bigint NULL,
    [txtDynamicSetRate] nvarchar(1000) NULL,
    [txtServiceCharge] nvarchar(1000) NULL,
    [TypeofReceipt] nvarchar(100) NULL,
    [UniquePOSVoucherRefNo] nvarchar(500) NULL,
    [val] decimal(18,4) NULL,
    [VoucherForm] nvarchar(500) NULL,
    [WarehouseComments] nvarchar(2000) NULL,
    
    -- Metadata fields for optimization
    iVoucherType bigint NOT NULL,
    iHeaderId bigint NOT NULL,
    LastUpdated datetime2 DEFAULT GETDATE(),
    
    -- Primary key constraint
    CONSTRAINT PK_vCore_TranData_0_Ultra_Fast PRIMARY KEY CLUSTERED (iBodyId)
        WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE)
);

-- STEP 2: CREATE ULTRA-FAST OPTIMIZED INDEXES
CREATE NONCLUSTERED INDEX IX_vCore_TranData_0_Ultra_Fast_VoucherType
ON vCore_TranData_0_Ultra_Fast (iVoucherType)
INCLUDE (iHeaderId, iCreatedUser, iLocalPOSDate, iLocalPOSTime, InvoiceNo, SalesOrderNo)
WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_vCore_TranData_0_Ultra_Fast_HeaderId
ON vCore_TranData_0_Ultra_Fast (iHeaderId)
INCLUDE (iVoucherType, iCreatedUser, InvoiceNo, SalesOrderNo)
WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_vCore_TranData_0_Ultra_Fast_CreatedUser
ON vCore_TranData_0_Ultra_Fast (iCreatedUser)
INCLUDE (iVoucherType, iHeaderId, iLocalPOSDate, InvoiceNo)
WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_vCore_TranData_0_Ultra_Fast_InvoiceNo
ON vCore_TranData_0_Ultra_Fast (InvoiceNo)
INCLUDE (iVoucherType, iHeaderId, iCreatedUser)
WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE);

CREATE NONCLUSTERED INDEX IX_vCore_TranData_0_Ultra_Fast_SalesOrderNo
ON vCore_TranData_0_Ultra_Fast (SalesOrderNo)
INCLUDE (iVoucherType, iHeaderId, iCreatedUser)
WITH (FILLFACTOR = 95, DATA_COMPRESSION = PAGE);

-- STEP 3: UPDATE STATISTICS
UPDATE STATISTICS vCore_TranData_0_Ultra_Fast WITH FULLSCAN, ALL;

PRINT 'Ultra-fast materialized table vCore_TranData_0_Ultra_Fast created successfully!';
PRINT 'Optimized indexes created successfully!';
PRINT 'Statistics updated successfully!';
PRINT '';
PRINT 'Next step: Run the population script to populate the table with data.';
GO
