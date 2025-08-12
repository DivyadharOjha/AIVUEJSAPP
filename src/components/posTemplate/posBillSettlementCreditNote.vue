<template>
  <div class="h-100">
    <div class="row h-100">
      <div class="col-12">
        <div class="card h-100">
          <div class="card-header bg-success text-white">
            <h4 class="mb-0">Credit Note Payment</h4>
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
                  <label for="creditNoteNumber" class="form-label">Credit Note Number</label>
                  <input
                    type="text"
                    class="form-control"
                    id="creditNoteNumber"
                    v-model="creditNoteNumber"
                    placeholder="CN-2024-001"
                  />
                </div>
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="creditNoteAmount" class="form-label">Amount Receive</label>
                  <input
                    type="number"
                    class="form-control"
                    id="creditNoteAmount"
                    v-model="creditNoteAmount"
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
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="customerName" class="form-label">Customer Name</label>
                  <input
                    type="text"
                    class="form-control"
                    id="customerName"
                    v-model="customerName"
                    placeholder="Customer Name"
                  />
                </div>
                <div class="mb-3">
                  <label for="issueDate" class="form-label">Issue Date</label>
                  <input type="date" class="form-control" id="issueDate" v-model="issueDate" />
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
                    class="btn btn-success"
                    @click="processPayment"
                    :disabled="!isValidPayment"
                    style="padding: 10px; width: fit-content"
                  >
                    <i class="bi bi-receipt me-2"></i>
                    Pay with Credit Note
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
                            <th>Credit Note Number</th>
                            <th>Customer Name</th>
                            <th>Credit Note Amount</th>
                            <th>Applied Amount</th>
                            <th>Remaining Balance</th>
                            <th>Issue Date</th>
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
                            <td>{{ record.creditNoteNumber }}</td>
                            <td>{{ record.customerName }}</td>
                            <td>${{ record.creditNoteAmount.toFixed(2) }}</td>
                            <td>${{ record.appliedAmount.toFixed(2) }}</td>
                            <td>${{ record.remainingBalance.toFixed(2) }}</td>
                            <td>{{ formatDate(record.issueDate) }}</td>
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

interface CreditNotePaymentRecord {
  id: string
  type: 'creditNote'
  creditNoteNumber: string
  creditNoteAmount: number
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
const creditNoteNumber = ref('')
const creditNoteAmount = ref(0)
const remainingBalance = ref(0)
const customerName = ref('')
const issueDate = ref('')
const expiryDate = ref('')
const notes = ref('')
const paymentRecords = ref<CreditNotePaymentRecord[]>([])
const editingIndex = ref<number | null>(null)

const isValidPayment = computed(() => {
  return (
    creditNoteNumber.value.trim() !== '' &&
    creditNoteAmount.value > 0 &&
    customerName.value.trim() !== '' &&
    issueDate.value !== '' &&
    expiryDate.value !== ''
  )
})

const calculateRemainingBalance = () => {
  if (creditNoteAmount.value > 0) {
    remainingBalance.value = Math.max(0, creditNoteAmount.value - amountDue.value)
  } else {
    remainingBalance.value = 0
  }
}

const processPayment = () => {
  const appliedAmount = Math.min(creditNoteAmount.value, amountDue.value)

  const paymentRecord: CreditNotePaymentRecord = {
    id: generateId(),
    type: 'creditNote',
    creditNoteNumber: creditNoteNumber.value,
    creditNoteAmount: creditNoteAmount.value,
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

  console.log('Credit note payment record added:', paymentRecord)
}

const editRecord = (index: number) => {
  const record = paymentRecords.value[index]
  creditNoteNumber.value = record.creditNoteNumber
  creditNoteAmount.value = record.creditNoteAmount
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
  creditNoteNumber.value = ''
  creditNoteAmount.value = 0
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

const formatTimestamp = (timestamp: string) => {
  return new Date(timestamp).toLocaleString()
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString()
}

onMounted(() => {
  // Simulate amount due (in real app, this would come from props or store)
  amountDue.value = 125.5
  // Set default dates
  const today = new Date()
  issueDate.value = today.toISOString().split('T')[0]
  const expiry = new Date()
  expiry.setFullYear(expiry.getFullYear() + 1)
  expiryDate.value = expiry.toISOString().split('T')[0]
})

// Watch for changes in credit note amount to calculate remaining balance
watch(creditNoteAmount, calculateRemainingBalance)
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
