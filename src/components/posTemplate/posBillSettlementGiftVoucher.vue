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
                  />
                </div>
                <div class="mb-3">
                  <label for="voucherAmount" class="form-label">Voucher Actual Amount</label>
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
            <div class="row mt-4" v-if="paymentRecords.length > 0">
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
                          <tr v-for="(record, index) in paymentRecords" :key="record.id">
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
                            <td>${{ record.voucherAmount.toFixed(2) }}</td>
                            <td>${{ record.appliedAmount.toFixed(2) }}</td>
                            <td>${{ record.remainingBalance.toFixed(2) }}</td>
                            <td>{{ formatDate(record.expiryDate) }}</td>
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
import { ref, computed, onMounted, watch } from 'vue'

interface GiftVoucherPaymentRecord {
  id: string
  type: 'giftVoucher'
  voucherCode: string
  voucherAmount: number
  appliedAmount: number
  remainingBalance: number
  customerName: string
  issueDate: string
  expiryDate: string
  notes: string
  timestamp: string
}

// Removed emit since we're not using it anymore

const amountDue = ref(0)
const voucherCode = ref('')
const voucherAmount = ref(0)
const amountReceive = ref(0)
const remainingBalance = ref(0)
const customerName = ref('')
const issueDate = ref('')
const expiryDate = ref('')
const notes = ref('')
const paymentRecords = ref<GiftVoucherPaymentRecord[]>([])
const editingIndex = ref<number | null>(null)

const isValidPayment = computed(() => {
  return voucherCode.value.trim() !== '' && voucherAmount.value > 0 && amountReceive.value > 0
})

const calculateRemainingBalance = () => {
  if (voucherAmount.value > 0) {
    remainingBalance.value = Math.max(0, voucherAmount.value - amountDue.value)
  } else {
    remainingBalance.value = 0
  }
}

const processPayment = () => {
  const appliedAmount = Math.min(voucherAmount.value, amountReceive.value)

  const paymentRecord: GiftVoucherPaymentRecord = {
    id: generateId(),
    type: 'giftVoucher',
    voucherCode: voucherCode.value,
    voucherAmount: voucherAmount.value,
    appliedAmount: appliedAmount,
    remainingBalance: remainingBalance.value,
    customerName: customerName.value,
    issueDate: issueDate.value,
    expiryDate: expiryDate.value,
    notes: notes.value,
    timestamp: new Date().toISOString(),
  }

  paymentRecords.value.push(paymentRecord)

  // Recalculate amount due
  recalculateAmountDue()

  // Reset form
  resetForm()

  console.log('Gift voucher payment record added:', paymentRecord)
}

const editRecord = (index: number) => {
  const record = paymentRecords.value[index]
  voucherCode.value = record.voucherCode
  voucherAmount.value = record.voucherAmount
  amountReceive.value = record.appliedAmount
  remainingBalance.value = record.remainingBalance
  customerName.value = record.customerName
  issueDate.value = record.issueDate
  expiryDate.value = record.expiryDate
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
    return sum + record.appliedAmount
  }, 0)

  // Update amount due (assuming original amount due is stored somewhere)
  // For now, we'll use a fixed original amount
  const originalAmount = 125.5 // This should come from props or store
  amountDue.value = Math.max(0, originalAmount - totalPaid)
}

const resetForm = () => {
  voucherCode.value = ''
  voucherAmount.value = 0
  amountReceive.value = 0
  remainingBalance.value = 0
  customerName.value = ''
  issueDate.value = ''
  expiryDate.value = ''
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
