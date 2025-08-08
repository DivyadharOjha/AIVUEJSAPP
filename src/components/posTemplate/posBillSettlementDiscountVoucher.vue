<template>
  <div class="h-100">
    <div class="row h-100">
      <div class="col-12">
        <div class="card h-100">
          <div class="card-header bg-success text-white">
            <h4 class="mb-0">Discount Voucher Payment</h4>
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
                  <label for="voucherCode" class="form-label">Discount Code</label>
                  <input
                    type="text"
                    class="form-control"
                    id="voucherCode"
                    v-model="voucherCode"
                    placeholder="SAVE20"
                  />
                </div>
                <div class="mb-3">
                  <label for="discountType" class="form-label">Discount Type</label>
                  <select class="form-control" id="discountType" v-model="discountType" readonly>
                    <option value="percentage">Percentage</option>
                    <option value="fixed">Fixed Amount</option>
                  </select>
                </div>
                <div class="mb-3">
                  <label for="discountValue" class="form-label">Discount Value</label>
                  <input
                    type="number"
                    class="form-control"
                    id="discountValue"
                    v-model="discountValue"
                    readonly
                    placeholder="0.00"
                    step="0.01"
                  />
                </div>
              </div>
              <div class="col-md-6">
                <div class="mb-3">
                  <label for="discountAmount" class="form-label">Discount Amount</label>
                  <input
                    type="number"
                    class="form-control"
                    id="discountAmount"
                    v-model="discountAmount"
                    readonly
                    placeholder="0.00"
                  />
                </div>
                <div class="mb-3">
                  <label for="finalAmount" class="form-label">Final Amount</label>
                  <input
                    type="number"
                    class="form-control"
                    id="finalAmount"
                    v-model="finalAmount"
                    readonly
                    placeholder="0.00"
                  />
                </div>
                <div class="mb-3">
                  <label for="validUntil" class="form-label">Valid Until</label>
                  <input
                    type="date"
                    class="form-control"
                    id="validUntil"
                    v-model="validUntil"
                    readonly
                  />
                </div>
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
                    <i class="bi bi-tag me-2"></i>
                    Apply Discount Voucher
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

interface DiscountVoucherPaymentData {
  type: 'discountVoucher'
  amountDue: number
  voucherCode: string
  discountType: 'percentage' | 'fixed'
  discountValue: number
  discountAmount: number
  finalAmount: number
  validUntil: string
  notes: string
  timestamp: string
}

const emit = defineEmits<{
  'payment-processed': [data: DiscountVoucherPaymentData]
}>()

const amountDue = ref(0)
const voucherCode = ref('')
const discountType = ref('percentage')
const discountValue = ref(0)
const discountAmount = ref(0)
const finalAmount = ref(0)
const validUntil = ref('')
const notes = ref('')

const isValidPayment = computed(() => {
  return voucherCode.value.trim() !== '' && discountValue.value > 0
})

const calculateDiscount = () => {
  if (discountType.value === 'percentage') {
    discountAmount.value = (amountDue.value * discountValue.value) / 100
  } else {
    discountAmount.value = Math.min(discountValue.value, amountDue.value)
  }
  finalAmount.value = Math.max(0, amountDue.value - discountAmount.value)
}

const processPayment = () => {
  const paymentData: DiscountVoucherPaymentData = {
    type: 'discountVoucher',
    amountDue: amountDue.value,
    voucherCode: voucherCode.value,
    discountType: discountType.value as 'percentage' | 'fixed',
    discountValue: discountValue.value,
    discountAmount: discountAmount.value,
    finalAmount: finalAmount.value,
    validUntil: validUntil.value,
    notes: notes.value,
    timestamp: new Date().toISOString(),
  }

  emit('payment-processed', paymentData)
  console.log('Discount voucher payment processed:', paymentData)
}

const resetForm = () => {
  voucherCode.value = ''
  discountType.value = 'percentage'
  discountValue.value = 0
  discountAmount.value = 0
  finalAmount.value = 0
  validUntil.value = ''
  notes.value = ''
}

const loadVoucherData = () => {
  // Simulate loading voucher data (in real app, this would be an API call)
  if (voucherCode.value.trim() !== '') {
    discountType.value = 'percentage'
    discountValue.value = 20
    validUntil.value = '2024-12-31'
    calculateDiscount()
  }
}

onMounted(() => {
  // Simulate amount due (in real app, this would come from props or store)
  amountDue.value = 125.5
})

// Watch for changes in voucher code to load voucher data
watch(voucherCode, loadVoucherData)

// Watch for changes in discount value to calculate amounts
watch([discountValue, discountType], calculateDiscount)
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
