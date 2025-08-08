<template>
  <div class="h-100">
    <div class="row h-100">
      <div class="col-12">
        <div class="card h-100">
          <div class="card-header bg-success text-white">
            <h4 class="mb-0">Cash Payment</h4>
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
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="cashReceived" class="form-label">Cash Amount Received</label>
                  <input
                    type="number"
                    class="form-control"
                    id="cashReceived"
                    v-model="cashReceived"
                    placeholder="Enter amount"
                    step="0.01"
                  />
                </div>
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="schemesDiscount" class="form-label">Schemes Discount</label>
                  <input
                    type="number"
                    class="form-control"
                    id="schemesDiscount"
                    v-model="schemesDiscount"
                    placeholder="0.00"
                    step="0.01"
                  />
                </div>
              </div>
            </div>

            <!-- Collapsible Additional Details -->
            <div class="accordion mt-3" id="cashPaymentDetails">
              <div class="accordion-item">
                <h2 class="accordion-header">
                  <button
                    class="accordion-button"
                    :class="{ collapsed: !isAdditionalDetailsOpen }"
                    type="button"
                    @click="toggleAdditionalDetails"
                    :aria-expanded="isAdditionalDetailsOpen"
                    aria-controls="notesCollapse"
                  >
                    <i class="bi bi-sticky me-2"></i>
                    Additional Details
                  </button>
                </h2>
                <div
                  id="notesCollapse"
                  class="accordion-collapse"
                  :class="{
                    'collapse show': isAdditionalDetailsOpen,
                    collapse: !isAdditionalDetailsOpen,
                  }"
                >
                  <div class="accordion-body">
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
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Floating Action Panel -->
  <posFloatingActionPanel
    :payment-processed="paymentProcessed"
    :is-valid-payment="isValidPayment"
    payment-button-text="Pay Cash"
    payment-icon="bi bi-cash-coin"
    @reset="resetForm"
    @process-payment="processPayment"
    @print-receipt="printReceipt"
    @email-receipt="emailReceipt"
    @send-sms="sendSMS"
    @new-transaction="newTransaction"
    @close-payment="closePayment"
  />

  <!-- Debug Info (remove in production) -->
  <div
    class="position-fixed top-0 end-0 p-3"
    style="z-index: 1001; background: rgba(0, 0, 0, 0.8); color: white; font-size: 12px"
  >
    <div>Cash Received: {{ cashReceived }}</div>
    <div>Amount Due: {{ amountDue }}</div>
    <div>Is Valid: {{ isValidPayment }}</div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import posFloatingActionPanel from './posFloatingActionPanel.vue'

interface CashPaymentData {
  type: 'cash'
  amountDue: number
  cashReceived: number
  schemesDiscount: number
  notes: string
  timestamp: string
}

const emit = defineEmits<{
  'payment-processed': [data: CashPaymentData | null]
}>()

const amountDue = ref(0)
const cashReceived = ref(0)
const schemesDiscount = ref(0)
const notes = ref('')
const paymentProcessed = ref(false)
const isAdditionalDetailsOpen = ref(true)

const isValidPayment = computed(() => {
  // Allow payment if cash received is greater than 0 (less strict validation)
  const isValid = cashReceived.value > 0
  console.log('Payment validation:', {
    cashReceived: cashReceived.value,
    amountDue: amountDue.value,
    isValid: isValid,
  })
  return isValid
})

const processPayment = () => {
  const paymentData: CashPaymentData = {
    type: 'cash',
    amountDue: amountDue.value,
    cashReceived: cashReceived.value,
    schemesDiscount: schemesDiscount.value,
    notes: notes.value,
    timestamp: new Date().toISOString(),
  }

  emit('payment-processed', paymentData)
  console.log('Cash payment processed:', paymentData)
  paymentProcessed.value = true
}

const resetForm = () => {
  cashReceived.value = 0
  schemesDiscount.value = 0
  notes.value = ''
  paymentProcessed.value = false
}

const printReceipt = () => {
  console.log('Printing receipt...')
  // Implement print functionality
}

const emailReceipt = () => {
  console.log('Emailing receipt...')
  // Implement email functionality
}

const sendSMS = () => {
  console.log('Sending SMS...')
  // Implement SMS functionality
}

const newTransaction = () => {
  console.log('Starting new transaction...')
  resetForm()
}

const closePayment = () => {
  console.log('Closing payment...')
  paymentProcessed.value = false
  emit('payment-processed', null)
}

const toggleAdditionalDetails = () => {
  isAdditionalDetailsOpen.value = !isAdditionalDetailsOpen.value
}

onMounted(() => {
  // Simulate amount due (in real app, this would come from props or store)
  amountDue.value = 125.5
  // Set default cash received to match amount due for testing
  cashReceived.value = 125.5
})
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
