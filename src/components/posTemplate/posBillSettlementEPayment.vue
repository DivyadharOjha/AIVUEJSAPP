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
              </div>
              <div class="col-md-4">
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
                    <i class="bi bi-credit-card me-2"></i>
                    Pay EPayment
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
                            <th>Payment Method</th>
                            <th>Account Number</th>
                            <th>IFSC Code</th>
                            <th>Amount</th>
                            <th>Transaction ID</th>
                            <th>Status</th>
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
                            <td>{{ record.paymentMethod }}</td>
                            <td>{{ maskAccountNumber(record.accountNumber) }}</td>
                            <td>{{ record.ifscCode }}</td>
                            <td>${{ record.amount.toFixed(2) }}</td>
                            <td>{{ record.transactionId }}</td>
                            <td>
                              <span :class="getStatusClass(record.paymentStatus)">
                                {{ record.paymentStatus }}
                              </span>
                            </td>
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

interface EPaymentRecord {
  id: string
  type: 'ePayment'
  paymentMethod: string
  accountNumber: string
  ifscCode: string
  amount: number
  transactionId: string
  referenceNumber: string
  paymentStatus: string
  notes: string
  timestamp: string
}

// Removed emit since we're not using it anymore

const amountDue = ref(0)
const amountReceive = ref(0)
const transactionId = ref('')
const referenceNumber = ref('')
const notes = ref('')
const paymentRecords = ref<EPaymentRecord[]>([])
const editingIndex = ref<number | null>(null)

const isValidPayment = computed(() => {
  return amountReceive.value > 0 && referenceNumber.value.trim() !== ''
})

const processPayment = () => {
  const paymentRecord: EPaymentRecord = {
    id: generateId(),
    type: 'ePayment',
    paymentMethod: 'bank_transfer',
    accountNumber: 'N/A',
    ifscCode: 'N/A',
    amount: amountReceive.value,
    transactionId: transactionId.value,
    referenceNumber: referenceNumber.value,
    paymentStatus: 'completed',
    notes: notes.value,
    timestamp: new Date().toISOString(),
  }

  paymentRecords.value.push(paymentRecord)

  // Recalculate amount due
  recalculateAmountDue()

  // Reset form and generate new transaction ID
  resetForm()
  generateTransactionId()

  console.log('E-Payment record added:', paymentRecord)
}

const editRecord = (index: number) => {
  const record = paymentRecords.value[index]
  amountReceive.value = record.amount
  transactionId.value = record.transactionId
  referenceNumber.value = record.referenceNumber
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
    return sum + record.amount
  }, 0)

  // Update amount due (assuming original amount due is stored somewhere)
  // For now, we'll use a fixed original amount
  const originalAmount = 125.5 // This should come from props or store
  amountDue.value = Math.max(0, originalAmount - totalPaid)
}

const resetForm = () => {
  amountReceive.value = 0
  referenceNumber.value = ''
  notes.value = ''
  editingIndex.value = null
}

const generateId = () => {
  return Date.now().toString(36) + Math.random().toString(36).substr(2)
}

const formatTimestamp = (timestamp: string) => {
  return new Date(timestamp).toLocaleString()
}

const maskAccountNumber = (accountNumber: string) => {
  if (accountNumber.length >= 4) {
    return `****${accountNumber.slice(-4)}`
  }
  return accountNumber
}

const getStatusClass = (status: string) => {
  switch (status.toLowerCase()) {
    case 'completed':
      return 'badge bg-success'
    case 'pending':
      return 'badge bg-warning'
    case 'failed':
      return 'badge bg-danger'
    default:
      return 'badge bg-secondary'
  }
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
