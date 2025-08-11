<template>
  <div class="h-100">
    <div class="row h-100">
      <div class="col-12">
        <div class="card h-100">
          <div class="card-header bg-success text-white">
            <h4 class="mb-0">Credit Note Payment</h4>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="amount" class="form-label">Amount Due</label>
                  <input
                    type="number"
                    class="form-control"
                    id="amount"
                    v-model="amountDue"
                    readonly
                    placeholder="0.00"
                  />
                </div>
                <div class="mb-3">
                  <label for="creditNoteNumber" class="form-label">Credit Note Number</label>
                  <input
                    type="text"
                    class="form-control"
                    id="creditNoteNumber"
                    v-model="creditNoteNumber"
                    placeholder="CN-2024-001"
                  />
                </div>
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="creditNoteAmount" class="form-label">Credit Note Amount</label>
                  <input
                    type="number"
                    class="form-control"
                    id="creditNoteAmount"
                    v-model="creditNoteAmount"
                    placeholder="0.00"
                    step="0.01"
                  />
                </div>
                <div class="mb-3">
                  <label for="remainingBalance" class="form-label">Remaining Balance</label>
                  <input
                    type="number"
                    class="form-control"
                    id="remainingBalance"
                    v-model="remainingBalance"
                    readonly
                    placeholder="0.00"
                  />
                </div>
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="customerName" class="form-label">Customer Name</label>
                  <input
                    type="text"
                    class="form-control"
                    id="customerName"
                    v-model="customerName"
                    placeholder="Customer Name"
                  />
                </div>
                <div class="mb-3">
                  <label for="issueDate" class="form-label">Issue Date</label>
                  <input type="date" class="form-control" id="issueDate" v-model="issueDate" />
                </div>
              </div>
            </div>
            <div class="row">
              <div class="col-12">
                <div class="mb-3">
                  <label for="notes" class="form-label">Notes</label>
                  <textarea
                    class="form-control"
                    id="notes"
                    v-model="notes"
                    rows="3"
                    placeholder="Enter any additional notes..."
                  ></textarea>
                </div>
              </div>
            </div>
            <div class="row mt-4">
              <div class="col-12">
                <div class="d-flex justify-content-end gap-2">
                  <button type="button" class="btn btn-secondary" @click="resetForm">Reset</button>
                  <button
                    type="button"
                    class="btn btn-success"
                    @click="processPayment"
                    :disabled="!isValidPayment"
                    style="padding: 10px; width: fit-content"
                  >
                    <i class="bi bi-receipt me-2"></i>
                    Pay with Credit Note
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'

interface CreditNotePaymentData {
  type: 'creditNote'
  amountDue: number
  creditNoteNumber: string
  creditNoteAmount: number
  remainingBalance: number
  customerName: string
  issueDate: string
  expiryDate: string
  notes: string
  timestamp: string
}

const emit = defineEmits<{
  'payment-processed': [data: CreditNotePaymentData]
}>()

const amountDue = ref(0)
const creditNoteNumber = ref('')
const creditNoteAmount = ref(0)
const remainingBalance = ref(0)
const customerName = ref('')
const issueDate = ref('')
const expiryDate = ref('')
const notes = ref('')

const isValidPayment = computed(() => {
  return (
    creditNoteNumber.value.trim() !== '' &&
    creditNoteAmount.value > 0 &&
    customerName.value.trim() !== '' &&
    issueDate.value !== '' &&
    expiryDate.value !== ''
  )
})

const calculateRemainingBalance = () => {
  if (creditNoteAmount.value > 0) {
    remainingBalance.value = Math.max(0, creditNoteAmount.value - amountDue.value)
  } else {
    remainingBalance.value = 0
  }
}

const processPayment = () => {
  const paymentData: CreditNotePaymentData = {
    type: 'creditNote',
    amountDue: amountDue.value,
    creditNoteNumber: creditNoteNumber.value,
    creditNoteAmount: creditNoteAmount.value,
    remainingBalance: remainingBalance.value,
    customerName: customerName.value,
    issueDate: issueDate.value,
    expiryDate: expiryDate.value,
    notes: notes.value,
    timestamp: new Date().toISOString(),
  }

  emit('payment-processed', paymentData)
  console.log('Credit note payment processed:', paymentData)
}

const resetForm = () => {
  creditNoteNumber.value = ''
  creditNoteAmount.value = 0
  remainingBalance.value = 0
  customerName.value = ''
  issueDate.value = ''
  expiryDate.value = ''
  notes.value = ''
}

onMounted(() => {
  // Simulate amount due (in real app, this would come from props or store)
  amountDue.value = 125.5
  // Set default dates
  const today = new Date()
  issueDate.value = today.toISOString().split('T')[0]
  const expiry = new Date()
  expiry.setFullYear(expiry.getFullYear() + 1)
  expiryDate.value = expiry.toISOString().split('T')[0]
})

// Watch for changes in credit note amount to calculate remaining balance
watch(creditNoteAmount, calculateRemainingBalance)
</script>

<style scoped>
.card {
  border: none;
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
}

.btn-lg {
  padding: 0.75rem 1.5rem;
  font-size: 1.1rem;
}
</style>
