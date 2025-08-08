<template>
  <div class="h-100">
    <div class="row h-100">
      <div class="col-12">
        <div class="card h-100">
          <div class="card-header bg-success text-white">
            <h4 class="mb-0">Gift Voucher Payment</h4>
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
                  <label for="voucherCode" class="form-label">Voucher Code</label>
                  <input
                    type="text"
                    class="form-control"
                    id="voucherCode"
                    v-model="voucherCode"
                    placeholder="GV-2024-001"
                  />
                </div>
                <div class="mb-3">
                  <label for="voucherAmount" class="form-label">Voucher Amount</label>
                  <input
                    type="number"
                    class="form-control"
                    id="voucherAmount"
                    v-model="voucherAmount"
                    readonly
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
              <div class="col-md-6">
                <div class="mb-3">
                  <label for="customerName" class="form-label">Customer Name</label>
                  <input
                    type="text"
                    class="form-control"
                    id="customerName"
                    v-model="customerName"
                    placeholder="Customer Name"
                    readonly
                  />
                </div>
                <div class="mb-3">
                  <label for="issueDate" class="form-label">Issue Date</label>
                  <input
                    type="date"
                    class="form-control"
                    id="issueDate"
                    v-model="issueDate"
                    readonly
                  />
                </div>
                <div class="mb-3">
                  <label for="expiryDate" class="form-label">Expiry Date</label>
                  <input
                    type="date"
                    class="form-control"
                    id="expiryDate"
                    v-model="expiryDate"
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
                    <i class="bi bi-gift me-2"></i>
                    Pay with Gift Voucher
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

interface GiftVoucherPaymentData {
  type: 'giftVoucher'
  amountDue: number
  voucherCode: string
  voucherAmount: number
  remainingBalance: number
  customerName: string
  issueDate: string
  expiryDate: string
  notes: string
  timestamp: string
}

const emit = defineEmits<{
  'payment-processed': [data: GiftVoucherPaymentData]
}>()

const amountDue = ref(0)
const voucherCode = ref('')
const voucherAmount = ref(0)
const remainingBalance = ref(0)
const customerName = ref('')
const issueDate = ref('')
const expiryDate = ref('')
const notes = ref('')

const isValidPayment = computed(() => {
  return voucherCode.value.trim() !== '' && voucherAmount.value > 0
})

const calculateRemainingBalance = () => {
  if (voucherAmount.value > 0) {
    remainingBalance.value = Math.max(0, voucherAmount.value - amountDue.value)
  } else {
    remainingBalance.value = 0
  }
}

const processPayment = () => {
  const paymentData: GiftVoucherPaymentData = {
    type: 'giftVoucher',
    amountDue: amountDue.value,
    voucherCode: voucherCode.value,
    voucherAmount: voucherAmount.value,
    remainingBalance: remainingBalance.value,
    customerName: customerName.value,
    issueDate: issueDate.value,
    expiryDate: expiryDate.value,
    notes: notes.value,
    timestamp: new Date().toISOString(),
  }

  emit('payment-processed', paymentData)
  console.log('Gift voucher payment processed:', paymentData)
}

const resetForm = () => {
  voucherCode.value = ''
  voucherAmount.value = 0
  remainingBalance.value = 0
  customerName.value = ''
  issueDate.value = ''
  expiryDate.value = ''
  notes.value = ''
}

const loadVoucherData = () => {
  // Simulate loading voucher data (in real app, this would be an API call)
  if (voucherCode.value.trim() !== '') {
    voucherAmount.value = 200.0
    customerName.value = 'Jane Smith'
    issueDate.value = '2024-01-15'
    expiryDate.value = '2024-12-31'
    calculateRemainingBalance()
  }
}

onMounted(() => {
  // Simulate amount due (in real app, this would come from props or store)
  amountDue.value = 125.5
})

// Watch for changes in voucher code to load voucher data
watch(voucherCode, loadVoucherData)
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
