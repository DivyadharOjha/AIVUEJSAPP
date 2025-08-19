<template>
  <div class="container-fluid h-100">
    <div class="row h-100">
      <!-- Payment Type Column -->
      <div class="col-3 border-end panel-container">
        <div class="d-flex flex-column h-100 p-3">
          <div class="d-flex flex-column gap-2 payment-types-container">
            <button
              v-for="paymentType in paymentTypes"
              :key="paymentType.id"
              @click="selectPaymentType(paymentType.id)"
              :class="[
                'payment-type-btn text-start',
                { 'payment-type-btn-active': selectedPaymentType === paymentType.id },
              ]"
            >
              {{ paymentType.name }}
            </button>
          </div>
        </div>
      </div>

      <!-- Payment Content Area -->
      <div class="col-9 panel-container" id="divBillSettlementRightPanelPaymentType">
        <div class="d-flex flex-column h-100">
          <div class="flex-grow-1 p-3 payment-content-container">
            <component
              :is="currentPaymentComponent"
              v-if="currentPaymentComponent"
              :key="selectedPaymentType || 'default'"
              @payment-record-added="handlePaymentRecordAdded"
              @payment-record-removed="handlePaymentRecordRemoved"
            />
            <div v-else class="d-flex align-items-center justify-content-center h-100">
              <div class="text-center text-muted">
                <h4>Select a Payment Type</h4>
                <p>Choose a payment method from the left panel to proceed with the transaction.</p>
              </div>
            </div>
          </div>

          <!-- Save Transaction Button -->
          <div class="p-3 border-top bg-light">
            <div class="d-flex justify-content-between align-items-center">
              <div class="d-flex align-items-center gap-3">
                <span class="fw-bold">Amount Due: ${{ totalAmountDue.toFixed(2) }}</span>
                <span class="fw-bold">Total Received: ${{ totalAmountReceived.toFixed(2) }}</span>
                <span v-if="totalAmountReceived > 0" class="badge" :class="getBalanceBadgeClass()">
                  {{ getBalanceText() }}
                </span>
              </div>
              <button
                type="button"
                class="btn btn-primary btn-lg"
                @click="saveTransaction"
                :disabled="!canSaveTransaction"
              >
                <i class="bi bi-check-circle me-2"></i>
                Save Transaction
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { usePaymentStore } from '../../stores/paymentStore'
import PosBillSettlementCash from './posBillSettlementCash.vue'
import PosBillSettlementCreditCard from './posBillSettlementCreditCard.vue'
import PosBillSettlementDebitCard from './posBillSettlementDebitCard.vue'
import PosBillSettlementCreditNote from './posBillSettlementCreditNote.vue'
import PosBillSettlementMemberPoint from './posBillSettlementMemberPoint.vue'
import PosBillSettlementGiftVoucher from './posBillSettlementGiftVoucher.vue'
import PosBillSettlementDiscountVoucher from './posBillSettlementDiscountVoucher.vue'
import PosBillSettlementWallet from './posBillSettlementWallet.vue'
import PosBillSettlementEPayment from './posBillSettlementEPayment.vue'

// Use the payment store
const paymentStore = usePaymentStore()

const selectedPaymentType = ref<string | null>(null)

const paymentTypes = [
  { id: 'cash', name: 'Cash' },
  { id: 'creditCard', name: 'Credit Card' },
  { id: 'debitCard', name: 'Debit Card' },
  { id: 'creditNote', name: 'Credit Note' },
  { id: 'memberPoint', name: 'Member Point' },
  { id: 'giftVoucher', name: 'Gift Voucher' },
  { id: 'discountVoucher', name: 'Discount Voucher' },
  { id: 'wallet', name: 'Wallet' },
  { id: 'ePayment', name: 'EPayment' },
]

const componentMap = {
  cash: PosBillSettlementCash,
  creditCard: PosBillSettlementCreditCard,
  debitCard: PosBillSettlementDebitCard,
  creditNote: PosBillSettlementCreditNote,
  memberPoint: PosBillSettlementMemberPoint,
  giftVoucher: PosBillSettlementGiftVoucher,
  discountVoucher: PosBillSettlementDiscountVoucher,
  wallet: PosBillSettlementWallet,
  ePayment: PosBillSettlementEPayment,
}

const currentPaymentComponent = computed(() => {
  if (!selectedPaymentType.value) return null
  return componentMap[selectedPaymentType.value as keyof typeof componentMap] || null
})

// Use store computed properties
const totalAmountDue = computed(() => paymentStore.originalAmountDue)
const totalAmountReceived = computed(() => paymentStore.totalAmountReceived)
const canSaveTransaction = computed(() => paymentStore.canSaveTransaction)

const getBalanceBadgeClass = () => paymentStore.getBalanceBadgeClass()
const getBalanceText = () => paymentStore.getBalanceText()

const handlePaymentRecordAdded = (record: any) => {
  console.log('Payment record added:', record)

  // Convert component record to store format
  const storeRecord = {
    id: record.id,
    type: record.type,
    amount:
      record.amount ||
      record.cashReceived ||
      record.appliedAmount ||
      record.redeemedAmount ||
      record.amountReceive ||
      record.discountAmount ||
      0,
    timestamp: new Date().toISOString(),
    details: record,
  }

  console.log('Store record:', storeRecord)
  paymentStore.addPaymentRecord(storeRecord)
}

const handlePaymentRecordRemoved = (recordId: string) => {
  paymentStore.removePaymentRecord(recordId)
}

const saveTransaction = () => {
  if (canSaveTransaction.value) {
    alert('Transaction posted successfully.')
    // Here you would typically save to database
    console.log('Transaction saved:', {
      totalAmountDue: totalAmountDue.value,
      totalAmountReceived: totalAmountReceived.value,
      paymentRecords: paymentStore.paymentRecords,
    })
    // Clear all records after successful save
    paymentStore.clearAllRecords()
  }
}

const selectPaymentType = (paymentTypeId: string) => {
  // Add a small delay to ensure proper component cleanup
  setTimeout(() => {
    selectedPaymentType.value = paymentTypeId
  }, 0)
}

onMounted(() => {
  // Initialize the store with the original amount due
  paymentStore.setOriginalAmountDue(125.5)

  // Set default payment type (optional - remove if you want user to select manually)
  // selectedPaymentType.value = 'giftVoucher'
})
</script>

<style scoped>
.payment-type-btn {
  background-color: #1a5f1a;
  color: white;
  border: 1px solid #1a5f1a;
  padding: 10px 15px;
  margin-bottom: 10px;
  border-radius: 5px;
  transition: all 0.3s ease;
  font-weight: 500;
}

.payment-type-btn:hover {
  border: 1px solid #006400;
  box-shadow: 0 0 10px rgba(0, 100, 0, 0.3);
  transform: translateX(5px);
}

.payment-type-btn-active {
  background-color: #146c43;
  border-color: #0f5132;
  box-shadow: 0 0 10px rgba(0, 100, 0, 0.3);
}

/* Scrollbar styles for left panel (payment types) */
.payment-types-container {
  height: calc(100% - 2rem);
  overflow-y: auto;
  overflow-x: hidden;
  padding-right: 5px;
  position: relative;
}

.payment-types-container::-webkit-scrollbar {
  width: 8px;
}

.payment-types-container::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.payment-types-container::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 4px;
}

.payment-types-container::-webkit-scrollbar-thumb:hover {
  background: #555;
}

/* Scrollbar styles for right panel (payment content) */
.payment-content-container {
  height: calc(100% - 2rem);
  overflow-y: auto;
  overflow-x: hidden;
  padding-right: 5px;
  position: relative;
}

.payment-content-container::-webkit-scrollbar {
  width: 8px;
}

.payment-content-container::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.payment-content-container::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 4px;
}

.payment-content-container::-webkit-scrollbar-thumb:hover {
  background: #555;
}

/* Firefox scrollbar styles */
.payment-types-container,
.payment-content-container {
  scrollbar-width: thin;
  scrollbar-color: #888 #f1f1f1;
}

/* Panel container styles */
.panel-container {
  height: 100%;
  max-height: 100%;
  overflow: hidden;
}

/* Ensure parent container constraints */
.container-fluid {
  height: 100vh;
  max-height: 100vh;
  overflow: hidden;
}

.row.h-100 {
  height: 100% !important;
  max-height: 100%;
}
</style>
