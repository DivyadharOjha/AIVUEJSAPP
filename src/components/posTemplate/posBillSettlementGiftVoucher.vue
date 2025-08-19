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
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="voucherCode" class="form-label">Voucher Code</label>
                  <input
                    type="text"
                    class="form-control"
                    id="voucherCode"
                    v-model="voucherCode"
                    placeholder="GV-2024-001"
                    @blur="loadVoucherData"
                  />
                </div>
                <div class="mb-3">
                  <label for="voucherActualAmount" class="form-label">Voucher Actual Amount</label>
                  <input
                    type="number"
                    class="form-control"
                    id="voucherActualAmount"
                    v-model="voucherActualAmount"
                    readonly
                    placeholder="0.00"
                    step="0.01"
                  />
                </div>
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="amountReceive" class="form-label">Amount Receive</label>
                  <input
                    type="number"
                    class="form-control"
                    id="amountReceive"
                    v-model="amountReceive"
                    placeholder="0.00"
                    step="0.01"
                    @keyup.enter="handleAmountReceiveChange"
                    @blur="handleAmountReceiveChange"
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
              <div class="col-md-4">
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
              </div>
              <div class="col-md-8">
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
                    <i class="bi bi-gift me-2"></i>
                    Pay Gift Voucher
                  </button>
                </div>
              </div>
            </div>
            <!-- Payment Records Table -->
            <div class="row mt-4" v-if="giftVoucherRecords.length > 0">
              <div class="col-12">
                <div class="card">
                  <div class="card-body">
                    <div class="table-responsive">
                      <table class="table table-striped table-hover">
                        <thead class="table-dark">
                          <tr>
                            <th width="100">Actions</th>
                            <th>Gift Voucher Code</th>
                            <th>Voucher Amount</th>
                            <th>Applied Amount</th>
                            <th>Remaining Balance</th>
                            <th>Valid Until</th>
                            <th>Notes</th>
                            <th>Timestamp</th>
                          </tr>
                        </thead>
                        <tbody>
                          <tr v-for="(record, index) in giftVoucherRecords" :key="record.id">
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
                            <td>
                              {{
                                record.voucherActualAmount !== undefined
                                  ? '$' + record.voucherActualAmount.toFixed(2)
                                  : '-'
                              }}
                            </td>
                            <td>
                              {{
                                record.amountReceive !== undefined
                                  ? '$' + record.amountReceive.toFixed(2)
                                  : '-'
                              }}
                            </td>
                            <td>
                              {{
                                record.remainingBalance !== undefined
                                  ? '$' + record.remainingBalance.toFixed(2)
                                  : '-'
                              }}
                            </td>
                            <td>
                              {{ record.expiryDate ? formatDate(record.expiryDate) : '-' }}
                            </td>
                            <td>{{ record.notes || '-' }}</td>
                            <td>
                              {{ record.timestamp ? formatTimestamp(record.timestamp) : '-' }}
                            </td>
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
import { usePaymentStore, type GiftVoucherPaymentRecord } from '../../stores/paymentStore'

const emit = defineEmits<{
  'payment-record-added': [record: { id: string; type: string; amount: number }]
  'payment-record-removed': [recordId: string]
}>()

// Use the payment store
const paymentStore = usePaymentStore()

// Create a reactive reference to the gift voucher records with proper typing
const giftVoucherRecordsRef = ref<GiftVoucherPaymentRecord[]>([])

// Individual reactive refs for form data
const voucherCode = ref('')
const voucherActualAmount = ref(0)
const amountReceive = ref(0)
const remainingBalance = ref(0)
const customerName = ref('')
const issueDate = ref('')
const expiryDate = ref('')
const notes = ref('')

const editingIndex = ref<number | null>(null)

// Get amount due from store
const amountDue = computed(() => paymentStore.currentAmountDue)

// Computed property for gift voucher records with explicit typing
const giftVoucherRecords = computed<GiftVoucherPaymentRecord[]>(() => {
  return giftVoucherRecordsRef.value
})

const isValidPayment = computed(() => {
  return voucherCode.value.trim() !== '' && voucherActualAmount.value > 0 && amountReceive.value > 0
})

// Type guard function to check if record is a gift voucher payment
const isGiftVoucherRecord = (record: unknown): record is GiftVoucherPaymentRecord => {
  return Boolean(
    record &&
      typeof record === 'object' &&
      record !== null &&
      'type' in record &&
      (record as { type: string }).type === 'giftVoucher',
  )
}

const calculateRemainingBalance = () => {
  if (voucherActualAmount.value > 0) {
    remainingBalance.value = Math.max(0, voucherActualAmount.value - amountReceive.value)
  } else {
    remainingBalance.value = 0
  }
}

const processPayment = () => {
  const paymentRecord: GiftVoucherPaymentRecord = {
    id: generateId(),
    type: 'giftVoucher',
    voucherCode: voucherCode.value,
    voucherActualAmount: voucherActualAmount.value,
    amountReceive: amountReceive.value,
    remainingBalance: remainingBalance.value,
    customerName: customerName.value,
    issueDate: issueDate.value,
    expiryDate: expiryDate.value,
    notes: notes.value,
    timestamp: new Date().toISOString(),
  }

  // Add to both store and local reference
  paymentStore.componentRecords.giftVoucher.push(paymentRecord)
  giftVoucherRecordsRef.value.push(paymentRecord)

  // Emit the payment record to parent
  emit('payment-record-added', {
    id: paymentRecord.id,
    type: 'giftVoucher',
    amount: paymentRecord.amountReceive,
  })

  // Clear amount field for next payment
  amountReceive.value = 0
}

const editRecord = (index: number) => {
  const record = giftVoucherRecordsRef.value[index]

  if (record) {
    voucherCode.value = record.voucherCode
    voucherActualAmount.value = record.voucherActualAmount
    amountReceive.value = record.amountReceive
    remainingBalance.value = record.remainingBalance
    customerName.value = record.customerName
    issueDate.value = record.issueDate
    expiryDate.value = record.expiryDate
    notes.value = record.notes
    editingIndex.value = index

    // Emit removal event
    emit('payment-record-removed', record.id)

    // Remove the record from both store and local reference
    paymentStore.componentRecords.giftVoucher.splice(index, 1)
    giftVoucherRecordsRef.value.splice(index, 1)
  }
}

const deleteRecord = (index: number) => {
  const record = giftVoucherRecordsRef.value[index]

  if (record) {
    // Emit removal event
    emit('payment-record-removed', record.id)

    // Remove from both store and local reference
    paymentStore.componentRecords.giftVoucher.splice(index, 1)
    giftVoucherRecordsRef.value.splice(index, 1)
  }
}

const resetForm = () => {
  voucherCode.value = ''
  voucherActualAmount.value = 0
  amountReceive.value = 0
  remainingBalance.value = 0
  customerName.value = ''
  issueDate.value = ''
  expiryDate.value = ''
  notes.value = ''
  editingIndex.value = null

  // Clear local records
  giftVoucherRecordsRef.value = []
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
  // Always set voucher actual amount to 100 regardless of voucher code
  voucherActualAmount.value = 100.0
  // Don't overwrite customer name - keep the one set in onMounted
  // customerName.value = 'Jane Smith' // Removed this line
  // Don't overwrite issue date - keep the one set in onMounted
  // issueDate.value = '2024-01-15' // Removed this line
  // Set expiry date to today's date
  const today = new Date()
  expiryDate.value = today.toISOString().split('T')[0]
  calculateRemainingBalance()
}

const handleAmountReceiveChange = () => {
  // Calculate remaining balance: (Actual Voucher Amount - Amount Receive)
  if (voucherActualAmount.value > 0) {
    remainingBalance.value = Math.max(0, voucherActualAmount.value - amountReceive.value)
  } else {
    remainingBalance.value = 0
  }
}

onMounted(() => {
  // Initialize voucher actual amount to 100
  voucherActualAmount.value = 100.0

  // Set voucher code to "GV-2001-10"
  voucherCode.value = 'GV-2001-10'

  // Set issue date to today's date
  const today = new Date()
  issueDate.value = today.toISOString().split('T')[0]

  // Set customer name to "Ojha" by default
  customerName.value = 'Ojha'

  // Load existing records from store
  const existingRecords = paymentStore.getComponentRecords('giftVoucher')
  if (existingRecords.length > 0) {
    // Filter and validate only gift voucher records
    const validGiftVoucherRecords = existingRecords.filter(isGiftVoucherRecord).map((record) => ({
      id: record.id || generateId(),
      type: 'giftVoucher' as const,
      voucherCode: record.voucherCode || '',
      voucherActualAmount: record.voucherActualAmount || 0,
      amountReceive: record.amountReceive || 0,
      remainingBalance: record.remainingBalance || 0,
      customerName: record.customerName || '',
      issueDate: record.issueDate || '',
      expiryDate: record.expiryDate || '',
      notes: record.notes || '',
      timestamp: record.timestamp || new Date().toISOString(),
    }))

    paymentStore.componentRecords.giftVoucher = validGiftVoucherRecords
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
