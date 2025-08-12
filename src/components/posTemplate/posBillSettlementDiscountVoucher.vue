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
                  <label for="voucherCode" class="form-label">Discount Voucher Number</label>
                  <input
                    type="text"
                    class="form-control"
                    id="voucherCode"
                    v-model="voucherCode"
                    placeholder="SAVE20"
                  />
                </div>
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="discountValue" class="form-label">Discount Voucher Value</label>
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
                <div class="mb-3">
                  <label for="amountReceive" class="form-label">Amount Receive</label>
                  <input
                    type="number"
                    class="form-control"
                    id="amountReceive"
                    v-model="amountReceive"
                    placeholder="0.00"
                    step="0.01"
                  />
                </div>
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="validUntil" class="form-label">Valid Till</label>
                  <input
                    type="date"
                    class="form-control"
                    id="validUntil"
                    v-model="validUntil"
                    readonly
                  />
                </div>
                <div class="mb-3">
                  <label for="notes" class="form-label">Note(s)</label>
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
                    <i class="bi bi-tag me-2"></i>
                    Pay Discount Voucher
                  </button>
                </div>
              </div>
            </div>
            <!-- Payment Records Table -->
            <div class="row mt-4" v-if="paymentRecords.length > 0">
              <div class="col-12">
                <div class="card">
                  <div class="card-header">
                    <h5 class="mb-0">Payment Records</h5>
                  </div>
                  <div class="card-body">
                    <div class="table-responsive">
                      <table class="table table-striped table-hover">
                        <thead class="table-dark">
                          <tr>
                            <th width="100">Actions</th>
                            <th>Voucher Code</th>
                            <th>Discount Value</th>
                            <th>Discount Amount</th>
                            <th>Final Amount</th>
                            <th>Valid Until</th>
                            <th>Notes</th>
                            <th>Timestamp</th>
                          </tr>
                        </thead>
                        <tbody>
                          <tr v-for="(record, index) in paymentRecords" :key="record.id">
                            <td>
                              <div class="btn-group" role="group">
                                <button
                                  type="button"
                                  class="btn btn-sm btn-outline-primary"
                                  @click="editRecord(index)"
                                  title="Edit"
                                >
                                  <i class="bi bi-pencil"></i>
                                </button>
                                <button
                                  type="button"
                                  class="btn btn-sm btn-outline-danger"
                                  @click="deleteRecord(index)"
                                  title="Delete"
                                >
                                  <i class="bi bi-trash"></i>
                                </button>
                              </div>
                            </td>
                            <td>{{ record.voucherCode }}</td>
                            <td>${{ record.discountValue.toFixed(2) }}</td>
                            <td>${{ record.discountAmount.toFixed(2) }}</td>
                            <td>${{ record.finalAmount.toFixed(2) }}</td>
                            <td>{{ formatDate(record.validUntil) }}</td>
                            <td>{{ record.notes || '-' }}</td>
                            <td>{{ formatTimestamp(record.timestamp) }}</td>
                          </tr>
                        </tbody>
                      </table>
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
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'

interface DiscountVoucherPaymentRecord {
  id: string
  type: 'discountVoucher'
  voucherCode: string
  discountValue: number
  discountAmount: number
  finalAmount: number
  validUntil: string
  notes: string
  timestamp: string
}

// Removed emit since we're not using it anymore

const amountDue = ref(0)
const voucherCode = ref('')
const discountValue = ref(0)
const amountReceive = ref(0)
const validUntil = ref('')
const notes = ref('')
const paymentRecords = ref<DiscountVoucherPaymentRecord[]>([])
const editingIndex = ref<number | null>(null)

const isValidPayment = computed(() => {
  return voucherCode.value.trim() !== '' && discountValue.value > 0 && amountReceive.value > 0
})

const calculateDiscount = () => {
  // Calculate discount based on amount receive
  const discountAmount = Math.min(discountValue.value, amountReceive.value)
  const finalAmount = Math.max(0, amountReceive.value - discountAmount)
  return { discountAmount, finalAmount }
}

const processPayment = () => {
  const { discountAmount, finalAmount } = calculateDiscount()

  const paymentRecord: DiscountVoucherPaymentRecord = {
    id: generateId(),
    type: 'discountVoucher',
    voucherCode: voucherCode.value,
    discountValue: discountValue.value,
    discountAmount: discountAmount,
    finalAmount: finalAmount,
    validUntil: validUntil.value,
    notes: notes.value,
    timestamp: new Date().toISOString(),
  }

  paymentRecords.value.push(paymentRecord)

  // Recalculate amount due
  recalculateAmountDue()

  // Reset form
  resetForm()

  console.log('Discount voucher payment record added:', paymentRecord)
}

const editRecord = (index: number) => {
  const record = paymentRecords.value[index]
  voucherCode.value = record.voucherCode
  discountValue.value = record.discountValue
  amountReceive.value = record.discountAmount
  validUntil.value = record.validUntil
  notes.value = record.notes
  editingIndex.value = index

  // Remove the record from table
  paymentRecords.value.splice(index, 1)

  // Recalculate amount due
  recalculateAmountDue()
}

const deleteRecord = (index: number) => {
  paymentRecords.value.splice(index, 1)

  // Recalculate amount due
  recalculateAmountDue()
}

const recalculateAmountDue = () => {
  // Calculate total amount from all records
  const totalPaid = paymentRecords.value.reduce((sum, record) => {
    return sum + record.discountAmount
  }, 0)

  // Update amount due (assuming original amount due is stored somewhere)
  // For now, we'll use a fixed original amount
  const originalAmount = 125.5 // This should come from props or store
  amountDue.value = Math.max(0, originalAmount - totalPaid)
}

const resetForm = () => {
  voucherCode.value = ''
  discountValue.value = 0
  amountReceive.value = 0
  validUntil.value = ''
  notes.value = ''
  editingIndex.value = null
}

const generateId = () => {
  return Date.now().toString(36) + Math.random().toString(36).substr(2)
}

const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString()
}

const formatTimestamp = (timestamp: string) => {
  const date = new Date(timestamp)
  return date.toLocaleString()
}

const loadVoucherData = () => {
  // Simulate loading voucher data (in real app, this would be an API call)
  if (voucherCode.value.trim() !== '') {
    // Simulate different voucher data based on voucher code
    if (voucherCode.value === 'SAVE20') {
      discountValue.value = 20
      validUntil.value = '2024-12-31'
    } else if (voucherCode.value === 'SAVE10') {
      discountValue.value = 10
      validUntil.value = '2024-12-31'
    } else {
      discountValue.value = 5
      validUntil.value = '2024-12-31'
    }
  }
}

onMounted(() => {
  // Simulate amount due (in real app, this would come from props or store)
  amountDue.value = 125.5
})

onUnmounted(() => {
  // Clean up any potential memory leaks or references
  paymentRecords.value = []
  editingIndex.value = null
})

// Watch for changes in voucher code to load voucher data
watch(voucherCode, () => {
  loadVoucherData()
})

// Watch for changes in discount value to calculate amounts
watch(discountValue, () => {
  // This will trigger recalculation when discount value changes
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

.table-responsive {
  max-height: 400px;
  overflow-y: auto;
}

.btn-group .btn {
  margin-right: 2px;
}

.btn-group .btn:last-child {
  margin-right: 0;
}
</style>
