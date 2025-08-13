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
            <div class="row mt-4" v-if="discountVoucherRecords.length > 0">
              <div class="col-12">
                <div class="card">
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
                          <tr v-for="(record, index) in discountVoucherRecords" :key="record.id">
                            <td>
                              <div class="btn-group" role="group">
                                <button
                                  type="button"
                                  class="btn btn-sm btn-outline-primary"
                                  @click="editRecord(index)"
                                  title="Edit"
                                >
                                  <i class="bi bi-pencil-fill"></i>
                                  <span class="ms-1 d-none d-sm-inline">Edit</span>
                                </button>
                                <button
                                  type="button"
                                  class="btn btn-sm btn-outline-danger"
                                  @click="deleteRecord(index)"
                                  title="Delete"
                                >
                                  <i class="bi bi-trash-fill"></i>
                                  <span class="ms-1 d-none d-sm-inline">Delete</span>
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
import { ref, computed, onMounted } from 'vue'
import { usePaymentStore, type DiscountVoucherPaymentRecord } from '../../stores/paymentStore'

const emit = defineEmits<{
  'payment-record-added': [record: { id: string; type: string; amount: number }]
  'payment-record-removed': [recordId: string]
}>()

// Use the payment store
const paymentStore = usePaymentStore()

const voucherCode = ref('')
const discountValue = ref(0)
const amountReceive = ref(0)
const validUntil = ref('')
const notes = ref('')
const editingIndex = ref<number | null>(null)

// Get amount due from store
const amountDue = computed(() => paymentStore.currentAmountDue)

const isValidPayment = computed(() => {
  return voucherCode.value.trim() !== '' && discountValue.value > 0 && amountReceive.value > 0
})

// Type guard function to check if record is a discount voucher payment
const isDiscountVoucherRecord = (record: unknown): record is DiscountVoucherPaymentRecord => {
  return Boolean(
    record &&
      typeof record === 'object' &&
      record !== null &&
      'type' in record &&
      (record as { type: string }).type === 'discountVoucher',
  )
}

// Computed property for filtered discount voucher records
const discountVoucherRecords = computed(() => {
  return paymentStore.componentRecords.discountVoucher.filter(isDiscountVoucherRecord)
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

  // Add to store directly
  paymentStore.componentRecords.discountVoucher.push(paymentRecord)

  // Emit the payment record to parent
  emit('payment-record-added', {
    id: paymentRecord.id,
    type: 'discountVoucher',
    amount: paymentRecord.discountAmount,
  })

  // Clear amount field for next payment
  amountReceive.value = 0

  console.log('Discount voucher payment record added:', paymentRecord)
}

const editRecord = (index: number) => {
  const record = paymentStore.componentRecords.discountVoucher[index]

  if (isDiscountVoucherRecord(record)) {
    voucherCode.value = record.voucherCode
    discountValue.value = record.discountValue
    amountReceive.value = record.discountAmount
    validUntil.value = record.validUntil
    notes.value = record.notes
    editingIndex.value = index

    // Emit removal event
    emit('payment-record-removed', record.id)

    // Remove the record from store
    paymentStore.componentRecords.discountVoucher.splice(index, 1)
  }
}

const deleteRecord = (index: number) => {
  const record = paymentStore.componentRecords.discountVoucher[index]

  if (isDiscountVoucherRecord(record)) {
    // Emit removal event
    emit('payment-record-removed', record.id)

    // Remove from store
    paymentStore.componentRecords.discountVoucher.splice(index, 1)
  }
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

onMounted(() => {
  // Load existing records from store
  const existingRecords = paymentStore.getComponentRecords('discountVoucher')
  if (existingRecords.length > 0) {
    // Filter and validate only discount voucher records
    const validDiscountVoucherRecords = existingRecords
      .filter(isDiscountVoucherRecord)
      .map((record) => ({
        id: record.id || generateId(),
        type: 'discountVoucher' as const,
        voucherCode: record.voucherCode || '',
        discountValue: record.discountValue || 0,
        discountAmount: record.discountAmount || 0,
        finalAmount: record.finalAmount || 0,
        validUntil: record.validUntil || '',
        notes: record.notes || '',
        timestamp: record.timestamp || new Date().toISOString(),
      }))

    paymentStore.componentRecords.discountVoucher = validDiscountVoucherRecords
  }
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

/* Scrollbar styles */
.card-body {
  overflow-y: auto;
  max-height: calc(100vh - 200px);
}

.card-body::-webkit-scrollbar {
  width: 8px;
}

.card-body::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.card-body::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 4px;
}

.card-body::-webkit-scrollbar-thumb:hover {
  background: #555;
}

/* Firefox scrollbar styles */
.card-body {
  scrollbar-width: thin;
  scrollbar-color: #888 #f1f1f1;
}

/* Action buttons styling */
.btn-group .btn {
  margin-right: 2px;
  min-width: 32px;
  height: 32px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.btn-group .btn:last-child {
  margin-right: 0;
}

.btn-group .btn i {
  font-size: 14px;
}

/* Ensure buttons are visible */
.btn-outline-primary,
.btn-outline-danger {
  border-width: 1px;
  font-weight: 500;
}

.btn-outline-primary:hover {
  background-color: #0d6efd;
  border-color: #0d6efd;
  color: white;
}

.btn-outline-danger:hover {
  background-color: #dc3545;
  border-color: #dc3545;
  color: white;
}
</style>
