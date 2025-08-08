<template>
  <div class="h-100">
    <div class="row h-100">
      <div class="col-12">
        <div class="card h-100">
          <div class="card-header bg-success text-white">
            <h4 class="mb-0">E-Payment</h4>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-6">
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
                  <label for="paymentMethod" class="form-label">Payment Method</label>
                  <select class="form-control" id="paymentMethod" v-model="paymentMethod">
                    <option value="">Select Method</option>
                    <option value="bank_transfer">Bank Transfer</option>
                    <option value="online_banking">Online Banking</option>
                    <option value="mobile_banking">Mobile Banking</option>
                    <option value="qr_payment">QR Payment</option>
                    <option value="upi">UPI</option>
                    <option value="neft">NEFT</option>
                    <option value="imps">IMPS</option>
                  </select>
                </div>
                <div class="mb-3">
                  <label for="accountNumber" class="form-label">Account Number</label>
                  <input
                    type="text"
                    class="form-control"
                    id="accountNumber"
                    v-model="accountNumber"
                    placeholder="Account Number"
                  />
                </div>
                <div class="mb-3">
                  <label for="ifscCode" class="form-label">IFSC Code</label>
                  <input
                    type="text"
                    class="form-control"
                    id="ifscCode"
                    v-model="ifscCode"
                    placeholder="IFSC Code"
                  />
                </div>
              </div>
              <div class="col-md-6">
                <div class="mb-3">
                  <label for="transactionId" class="form-label">Transaction ID</label>
                  <input
                    type="text"
                    class="form-control"
                    id="transactionId"
                    v-model="transactionId"
                    placeholder="Auto-generated"
                    readonly
                  />
                </div>
                <div class="mb-3">
                  <label for="referenceNumber" class="form-label">Reference Number</label>
                  <input
                    type="text"
                    class="form-control"
                    id="referenceNumber"
                    v-model="referenceNumber"
                    placeholder="Reference Number"
                  />
                </div>
                <div class="mb-3">
                  <label for="paymentStatus" class="form-label">Payment Status</label>
                  <select class="form-control" id="paymentStatus" v-model="paymentStatus">
                    <option value="pending">Pending</option>
                    <option value="processing">Processing</option>
                    <option value="completed">Completed</option>
                    <option value="failed">Failed</option>
                  </select>
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
                    class="btn btn-success btn-lg"
                    @click="processPayment"
                    :disabled="!isValidPayment"
                  >
                    <i class="bi bi-credit-card me-2"></i>
                    Process E-Payment
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
import { ref, computed, onMounted } from 'vue'

interface EPaymentData {
  type: 'ePayment'
  amountDue: number
  paymentMethod: string
  accountNumber: string
  ifscCode: string
  transactionId: string
  referenceNumber: string
  paymentStatus: string
  notes: string
  timestamp: string
}

const emit = defineEmits<{
  'payment-processed': [data: EPaymentData]
}>()

const amountDue = ref(0)
const paymentMethod = ref('')
const accountNumber = ref('')
const ifscCode = ref('')
const transactionId = ref('')
const referenceNumber = ref('')
const paymentStatus = ref('pending')
const notes = ref('')

const isValidPayment = computed(() => {
  return (
    paymentMethod.value !== '' && accountNumber.value.trim() !== '' && ifscCode.value.trim() !== ''
  )
})

const processPayment = () => {
  const paymentData: EPaymentData = {
    type: 'ePayment',
    amountDue: amountDue.value,
    paymentMethod: paymentMethod.value,
    accountNumber: accountNumber.value,
    ifscCode: ifscCode.value,
    transactionId: transactionId.value,
    referenceNumber: referenceNumber.value,
    paymentStatus: paymentStatus.value,
    notes: notes.value,
    timestamp: new Date().toISOString(),
  }

  emit('payment-processed', paymentData)
  console.log('E-Payment processed:', paymentData)
}

const resetForm = () => {
  paymentMethod.value = ''
  accountNumber.value = ''
  ifscCode.value = ''
  referenceNumber.value = ''
  paymentStatus.value = 'pending'
  notes.value = ''
}

const generateTransactionId = () => {
  const timestamp = Date.now()
  const random = Math.floor(Math.random() * 10000)
  transactionId.value = `EPAY-${timestamp}-${random}`
}

onMounted(() => {
  // Simulate amount due (in real app, this would come from props or store)
  amountDue.value = 125.5
  generateTransactionId()
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
