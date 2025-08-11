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
                    class="btn pay-cash-btn"
                    @click="processPayment"
                    :disabled="!isValidPayment"
                    style="padding: 10px; width: fit-content"
                  >
                    <i class="bi bi-cash-coin me-2"></i>
                    Pay Cash
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

interface CashPaymentData {
  type: 'cash'
  amountDue: number
  cashReceived: number
  schemesDiscount: number
  notes: string
  timestamp: string
}

const emit = defineEmits<{
  'payment-processed': [data: CashPaymentData]
}>()

const amountDue = ref(0)
const cashReceived = ref(0)
const schemesDiscount = ref(0)
const notes = ref('')

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
}

const resetForm = () => {
  cashReceived.value = 0
  schemesDiscount.value = 0
  notes.value = ''
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

.pay-cash-btn {
  background-color: #5f9ea0;
  color: #f0f8ff;
  border: 1px solid #5f9ea0;
  transition: all 0.3s ease;
}

.pay-cash-btn:hover {
  background-color: #4a7c7e;
  border-color: #4a7c7e;
  color: #f0f8ff;
}

.pay-cash-btn:disabled {
  background-color: #a0a0a0;
  border-color: #a0a0a0;
  color: #d0d0d0;
}
</style>
