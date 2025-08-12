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
              </div>
              <div class="col-md-4">
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
            <div class="row mt-4" v-if="creditNoteRecords.length > 0">
              <div class="col-12">
                <div class="card">
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
                          <tr v-for="(record, index) in creditNoteRecords" :key="record.id">
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
import { ref, computed, onMounted } from 'vue'
import { usePaymentStore, type CreditNotePaymentRecord } from '../../stores/paymentStore'

const emit = defineEmits<{
  'payment-record-added': [record: { id: string; type: string; amount: number }]
  'payment-record-removed': [recordId: string]
}>()

// Use the payment store
const paymentStore = usePaymentStore()

const creditNoteNumber = ref('')
const creditNoteAmount = ref(0)
const remainingBalance = ref(0)
const customerName = ref('')
const issueDate = ref('')
const expiryDate = ref('')
const notes = ref('')
const editingIndex = ref<number | null>(null)

// Get amount due from store
const amountDue = computed(() => paymentStore.currentAmountDue)

const isValidPayment = computed(() => {
  return (
    creditNoteNumber.value.trim() !== '' &&
    creditNoteAmount.value > 0 &&
    customerName.value.trim() !== '' &&
    issueDate.value !== '' &&
    expiryDate.value !== ''
  )
})

// Type guard function to check if record is a credit note payment
const isCreditNoteRecord = (record: unknown): record is CreditNotePaymentRecord => {
  return Boolean(
    record &&
      typeof record === 'object' &&
      record !== null &&
      'type' in record &&
      (record as { type: string }).type === 'creditNote',
  )
}

// Computed property for filtered credit note records
const creditNoteRecords = computed(() => {
  return paymentStore.componentRecords.creditNote.filter(isCreditNoteRecord)
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

  // Add to store directly
  paymentStore.componentRecords.creditNote.push(paymentRecord)

  // Emit the payment record to parent
  emit('payment-record-added', {
    id: paymentRecord.id,
    type: 'creditNote',
    amount: paymentRecord.appliedAmount,
  })

  console.log('Credit note payment record added:', paymentRecord)
}

const editRecord = (index: number) => {
  const record = paymentStore.componentRecords.creditNote[index]

  if (isCreditNoteRecord(record)) {
    creditNoteNumber.value = record.creditNoteNumber
    creditNoteAmount.value = record.creditNoteAmount
    remainingBalance.value = record.remainingBalance
    customerName.value = record.customerName
    issueDate.value = record.issueDate
    expiryDate.value = record.expiryDate
    notes.value = record.notes
    editingIndex.value = index

    // Emit removal event
    emit('payment-record-removed', record.id)

    // Remove the record from store
    paymentStore.componentRecords.creditNote.splice(index, 1)
  }
}

const deleteRecord = (index: number) => {
  const record = paymentStore.componentRecords.creditNote[index]

  if (isCreditNoteRecord(record)) {
    // Emit removal event
    emit('payment-record-removed', record.id)

    // Remove from store
    paymentStore.componentRecords.creditNote.splice(index, 1)
  }
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
  // Load existing records from store
  const existingRecords = paymentStore.getComponentRecords('creditNote')
  if (existingRecords.length > 0) {
    // Filter and validate only credit note records
    const validCreditNoteRecords = existingRecords.filter(isCreditNoteRecord).map((record) => ({
      id: record.id || generateId(),
      type: 'creditNote' as const,
      creditNoteNumber: record.creditNoteNumber || '',
      creditNoteAmount: record.creditNoteAmount || 0,
      appliedAmount: record.appliedAmount || 0,
      remainingBalance: record.remainingBalance || 0,
      customerName: record.customerName || '',
      issueDate: record.issueDate || '',
      expiryDate: record.expiryDate || '',
      notes: record.notes || '',
      timestamp: record.timestamp || new Date().toISOString(),
    }))

    paymentStore.componentRecords.creditNote = validCreditNoteRecords
  }

  // Set default dates
  const today = new Date()
  issueDate.value = today.toISOString().split('T')[0]
  const expiry = new Date()
  expiry.setFullYear(expiry.getFullYear() + 1)
  expiryDate.value = expiry.toISOString().split('T')[0]
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
