<template>
  <div class="h-100">
    <div class="row h-100">
      <div class="col-12">
        <div class="card h-100">
          <div class="card-header bg-success text-white">
            <h4 class="mb-0">Digital Wallet Payment</h4>
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
                  <label for="walletType" class="form-label">Wallet Type</label>
                  <select class="form-control" id="walletType" v-model="walletType">
                    <option value="">Select Wallet</option>
                    <option value="paypal">PayPal</option>
                    <option value="applepay">Apple Pay</option>
                    <option value="googlepay">Google Pay</option>
                    <option value="samsungpay">Samsung Pay</option>
                    <option value="alipay">AliPay</option>
                    <option value="wechatpay">WeChat Pay</option>
                  </select>
                </div>
                <div class="mb-3">
                  <label for="walletId" class="form-label">Wallet ID/Email</label>
                  <input
                    type="text"
                    class="form-control"
                    id="walletId"
                    v-model="walletId"
                    placeholder="user@example.com"
                  />
                </div>
                <div class="mb-3">
                  <label for="walletBalance" class="form-label">Wallet Balance</label>
                  <input
                    type="number"
                    class="form-control"
                    id="walletBalance"
                    v-model="walletBalance"
                    readonly
                    placeholder="0.00"
                    step="0.01"
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
                  <label for="paymentAmount" class="form-label">Payment Amount</label>
                  <input
                    type="number"
                    class="form-control"
                    id="paymentAmount"
                    v-model="paymentAmount"
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
                    <i class="bi bi-wallet2 me-2"></i>
                    Pay with Wallet
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

interface WalletPaymentData {
  type: 'wallet'
  amountDue: number
  walletType: string
  walletId: string
  walletBalance: number
  transactionId: string
  paymentAmount: number
  remainingBalance: number
  notes: string
  timestamp: string
}

const emit = defineEmits<{
  'payment-processed': [data: WalletPaymentData]
}>()

const amountDue = ref(0)
const walletType = ref('')
const walletId = ref('')
const walletBalance = ref(0)
const transactionId = ref('')
const paymentAmount = ref(0)
const remainingBalance = ref(0)
const notes = ref('')

const isValidPayment = computed(() => {
  return (
    walletType.value !== '' &&
    walletId.value.trim() !== '' &&
    paymentAmount.value > 0 &&
    paymentAmount.value <= walletBalance.value &&
    paymentAmount.value <= amountDue.value
  )
})

const calculateRemainingBalance = () => {
  if (paymentAmount.value > 0) {
    remainingBalance.value = Math.max(0, walletBalance.value - paymentAmount.value)
  } else {
    remainingBalance.value = walletBalance.value
  }
}

const processPayment = () => {
  const paymentData: WalletPaymentData = {
    type: 'wallet',
    amountDue: amountDue.value,
    walletType: walletType.value,
    walletId: walletId.value,
    walletBalance: walletBalance.value,
    transactionId: transactionId.value,
    paymentAmount: paymentAmount.value,
    remainingBalance: remainingBalance.value,
    notes: notes.value,
    timestamp: new Date().toISOString(),
  }

  emit('payment-processed', paymentData)
  console.log('Wallet payment processed:', paymentData)
}

const resetForm = () => {
  walletType.value = ''
  walletId.value = ''
  walletBalance.value = 0
  paymentAmount.value = 0
  remainingBalance.value = 0
  notes.value = ''
}

const generateTransactionId = () => {
  const timestamp = Date.now()
  const random = Math.floor(Math.random() * 10000)
  transactionId.value = `WALLET-${timestamp}-${random}`
}

const loadWalletData = () => {
  // Simulate loading wallet data (in real app, this would be an API call)
  if (walletId.value.trim() !== '' && walletType.value !== '') {
    walletBalance.value = 500.0
    paymentAmount.value = Math.min(amountDue.value, walletBalance.value)
    calculateRemainingBalance()
  }
}

onMounted(() => {
  // Simulate amount due (in real app, this would come from props or store)
  amountDue.value = 125.5
  generateTransactionId()
})

// Watch for changes in wallet ID or type to load wallet data
watch([walletId, walletType], loadWalletData)

// Watch for changes in payment amount to calculate remaining balance
watch(paymentAmount, calculateRemainingBalance)
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
