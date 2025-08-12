import { ref, computed } from 'vue'
import { defineStore } from 'pinia'

// Component-specific payment record interfaces
export interface CashPaymentRecord {
  id: string
  type: 'cash'
  cashReceived: number
  schemesDiscount: number
  notes: string
  timestamp: string
}

export interface CreditCardPaymentRecord {
  id: string
  type: 'creditCard'
  cardType: string
  cardNumber: string
  expiryDate: string
  cvv: string
  cardholderName: string
  transactionId: string
  amount: number
  notes: string
  timestamp: string
}

export interface DebitCardPaymentRecord {
  id: string
  type: 'debitCard'
  cardType: string
  cardNumber: string
  expiryDate: string
  cvv: string
  cardholderName: string
  transactionId: string
  amount: number
  notes: string
  timestamp: string
}

export interface CreditNotePaymentRecord {
  id: string
  type: 'creditNote'
  creditNoteNumber: string
  creditNoteAmount: number
  appliedAmount: number
  remainingBalance: number
  customerName: string
  issueDate: string
  expiryDate: string
  notes: string
  timestamp: string
}

export interface MemberPointPaymentRecord {
  id: string
  type: 'memberPoint'
  memberId: string
  memberName: string
  availablePoints: number
  pointValue: number
  pointsToRedeem: number
  redeemedAmount: number
  remainingAmount: number
  notes: string
  timestamp: string
}

export interface GiftVoucherPaymentRecord {
  id: string
  type: 'giftVoucher'
  customerName: string
  voucherCode: string
  voucherActualAmount: number
  amountReceive: number
  remainingBalance: number
  issueDate: string
  expiryDate: string
  notes: string
  timestamp: string
}

export interface DiscountVoucherPaymentRecord {
  id: string
  type: 'discountVoucher'
  discountVoucherNumber: string
  discountVoucherValue: number
  amountReceive: number
  validTill: string
  notes: string
  timestamp: string
}

export interface WalletPaymentRecord {
  id: string
  type: 'wallet'
  memberId: string
  memberName: string
  walletAvailableBalance: number
  amountReceive: number
  transactionId: string
  notes: string
  timestamp: string
}

export interface EPaymentRecord {
  id: string
  type: 'ePayment'
  amountReceive: number
  transactionId: string
  referenceNumber: string
  notes: string
  timestamp: string
}

// Union type for all payment records
export type ComponentPaymentRecord =
  | CashPaymentRecord
  | CreditCardPaymentRecord
  | DebitCardPaymentRecord
  | CreditNotePaymentRecord
  | MemberPointPaymentRecord
  | GiftVoucherPaymentRecord
  | DiscountVoucherPaymentRecord
  | WalletPaymentRecord
  | EPaymentRecord

export interface PaymentRecord {
  id: string
  type: string
  amount: number
  timestamp: string
  details: ComponentPaymentRecord
}

export const usePaymentStore = defineStore('payment', () => {
  // Original amount due (from the bill/transaction)
  const originalAmountDue = ref(125.5)

  // Payment records from all components
  const paymentRecords = ref<PaymentRecord[]>([])

  // Component-specific records (to maintain table visibility)
  const componentRecords = ref<Record<string, ComponentPaymentRecord[]>>({
    cash: [],
    creditCard: [],
    debitCard: [],
    creditNote: [],
    memberPoint: [],
    giftVoucher: [],
    discountVoucher: [],
    wallet: [],
    ePayment: [],
  })

  // Computed properties for amount calculations
  const totalAmountReceived = computed(() => {
    return paymentRecords.value.reduce((sum, record) => sum + record.amount, 0)
  })

  const currentAmountDue = computed(() => {
    return Math.max(0, originalAmountDue.value - totalAmountReceived.value)
  })

  const unpaidAmount = computed(() => {
    return Math.max(0, originalAmountDue.value - totalAmountReceived.value)
  })

  const canSaveTransaction = computed(() => {
    return totalAmountReceived.value >= originalAmountDue.value
  })

  // Actions
  const addPaymentRecord = (record: PaymentRecord) => {
    paymentRecords.value.push(record)

    // Also add to component-specific records
    if (componentRecords.value[record.type]) {
      componentRecords.value[record.type].push(record.details)
    }
  }

  const removePaymentRecord = (recordId: string) => {
    const index = paymentRecords.value.findIndex((record) => record.id === recordId)
    if (index !== -1) {
      paymentRecords.value.splice(index, 1)
    }
  }

  const getComponentRecords = (componentType: string) => {
    return componentRecords.value[componentType] || []
  }

  const clearComponentRecords = (componentType: string) => {
    componentRecords.value[componentType] = []
  }

  const clearAllRecords = () => {
    paymentRecords.value = []
    componentRecords.value = {
      cash: [],
      creditCard: [],
      debitCard: [],
      creditNote: [],
      memberPoint: [],
      giftVoucher: [],
      discountVoucher: [],
      wallet: [],
      ePayment: [],
    }
  }

  const setOriginalAmountDue = (amount: number) => {
    originalAmountDue.value = amount
  }

  const getBalanceBadgeClass = () => {
    if (totalAmountReceived.value >= originalAmountDue.value) {
      return 'bg-success'
    } else if (totalAmountReceived.value > 0) {
      return 'bg-warning'
    } else {
      return 'bg-danger'
    }
  }

  const getBalanceText = () => {
    if (totalAmountReceived.value >= originalAmountDue.value) {
      return 'Paid'
    } else if (totalAmountReceived.value > 0) {
      return 'Partial'
    } else {
      return 'Unpaid'
    }
  }

  return {
    // State
    originalAmountDue,
    paymentRecords,
    componentRecords,

    // Computed
    totalAmountReceived,
    currentAmountDue,
    unpaidAmount,
    canSaveTransaction,

    // Actions
    addPaymentRecord,
    removePaymentRecord,
    getComponentRecords,
    clearComponentRecords,
    clearAllRecords,
    setOriginalAmountDue,
    getBalanceBadgeClass,
    getBalanceText,
  }
})
