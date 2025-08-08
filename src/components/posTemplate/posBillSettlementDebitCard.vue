<template>
  <div class="h-100">
    <div class="row h-100">
      <div class="col-12">
        <div class="card h-100">
          <div class="card-header bg-success text-white">
            <h4 class="mb-0">Debit Card Payment</h4>
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
                  <label for="cardNumber" class="form-label">Card Number</label>
                  <input
                    type="text"
                    class="form-control"
                    id="cardNumber"
                    v-model="cardNumber"
                    placeholder="1234 5678 9012 3456"
                    maxlength="19"
                  />
                </div>
                <div class="row">
                  <div class="col-6">
                    <div class="mb-3">
                      <label for="expiryDate" class="form-label">Expiry Date</label>
                      <input
                        type="text"
                        class="form-control"
                        id="expiryDate"
                        v-model="expiryDate"
                        placeholder="MM/YY"
                        maxlength="5"
                      />
                    </div>
                  </div>
                  <div class="col-6">
                    <div class="mb-3">
                      <label for="pin" class="form-label">PIN</label>
                      <input
                        type="password"
                        class="form-control"
                        id="pin"
                        v-model="pin"
                        placeholder="****"
                        maxlength="4"
                      />
                    </div>
                  </div>
                </div>
              </div>
              <div class="col-md-6">
                <div class="mb-3">
                  <label for="cardholderName" class="form-label">Cardholder Name</label>
                  <input
                    type="text"
                    class="form-control"
                    id="cardholderName"
                    v-model="cardholderName"
                    placeholder="John Doe"
                  />
                </div>
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
                    <i class="bi bi-bank me-2"></i>
                    Pay Card
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

interface DebitCardPaymentData {
  type: 'debitCard'
  amountDue: number
  cardNumber: string
  expiryDate: string
  pin: string
  cardholderName: string
  transactionId: string
  notes: string
  timestamp: string
}

const emit = defineEmits<{
  'payment-processed': [data: DebitCardPaymentData]
}>()

const amountDue = ref(0)
const cardNumber = ref('')
const expiryDate = ref('')
const pin = ref('')
const cardholderName = ref('')
const transactionId = ref('')
const notes = ref('')

const isValidPayment = computed(() => {
  return (
    cardNumber.value.length >= 16 &&
    expiryDate.value.length === 5 &&
    pin.value.length === 4 &&
    cardholderName.value.trim() !== ''
  )
})

const processPayment = () => {
  const paymentData: DebitCardPaymentData = {
    type: 'debitCard',
    amountDue: amountDue.value,
    cardNumber: cardNumber.value.replace(/\s/g, ''),
    expiryDate: expiryDate.value,
    pin: pin.value,
    cardholderName: cardholderName.value,
    transactionId: transactionId.value,
    notes: notes.value,
    timestamp: new Date().toISOString(),
  }

  emit('payment-processed', paymentData)
  console.log('Debit card payment processed:', paymentData)
}

const resetForm = () => {
  cardNumber.value = ''
  expiryDate.value = ''
  pin.value = ''
  cardholderName.value = ''
  notes.value = ''
}

const generateTransactionId = () => {
  const timestamp = Date.now()
  const random = Math.floor(Math.random() * 10000)
  transactionId.value = `DC-${timestamp}-${random}`
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
