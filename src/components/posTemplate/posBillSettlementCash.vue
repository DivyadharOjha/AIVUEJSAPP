<template>
  <div class="h-100">
    <div class="row h-100">
      <div class="col-12">
        <div class="card h-100">
          <div class="card-header bg-success text-white">
            <h4 class="mb-0">Cash Payment</h4>
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
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="cashReceived" class="form-label">Cash Amount Received</label>
                  <input
                    type="number"
                    class="form-control"
                    id="cashReceived"
                    v-model="cashReceived"
                    placeholder="Enter amount"
                    step="0.01"
                  />
                </div>
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="schemesDiscount" class="form-label">Schemes Discount</label>
                  <input
                    type="number"
                    class="form-control"
                    id="schemesDiscount"
                    v-model="schemesDiscount"
                    placeholder="0.00"
                    step="0.01"
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
                    class="btn pay-cash-btn"
                    @click="processPayment"
                    :disabled="!isValidPayment"
                    style="padding: 10px; width: fit-content"
                  >
                    <i class="bi bi-cash-coin me-2"></i>
                    Pay Cash
                  </button>
                </div>
              </div>
            </div>

            <!-- Payment Records Table -->
            <div class="row mt-4" v-if="cashRecords.length > 0">
              <div class="col-12">
                <div class="card">
                  <div class="card-body">
                    <div class="table-responsive">
                      <table class="table table-striped table-hover">
                        <thead class="table-dark">
                          <tr>
                            <th width="100">Actions</th>
                            <th>Cash Received</th>
                            <th>Schemes Discount</th>
                            <th>Net Amount</th>
                            <th>Notes</th>
                            <th>Timestamp</th>
                          </tr>
                        </thead>
                        <tbody>
                          <tr v-for="(record, index) in cashRecords" :key="record.id">
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
                            <td>${{ record.cashReceived.toFixed(2) }}</td>
                            <td>${{ record.schemesDiscount.toFixed(2) }}</td>
                            <td>
                              ${{ (record.cashReceived - record.schemesDiscount).toFixed(2) }}
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
import { usePaymentStore, type CashPaymentRecord } from '../../stores/paymentStore'

const emit = defineEmits<{
  'payment-record-added': [record: { id: string; type: string; cashReceived: number }]
  'payment-record-removed': [recordId: string]
}>()

// Use the payment store
const paymentStore = usePaymentStore()

const cashReceived = ref(0)
const schemesDiscount = ref(0)
const notes = ref('')
const editingIndex = ref<number | null>(null)

// Get amount due from store
const amountDue = computed(() => paymentStore.currentAmountDue)

const isValidPayment = computed(() => {
  const isValid = cashReceived.value > 0
  console.log('Payment validation:', {
    cashReceived: cashReceived.value,
    amountDue: amountDue.value,
    isValid: isValid,
  })
  return isValid
})

// Type guard function to check if record is a cash payment
const isCashRecord = (record: unknown): record is CashPaymentRecord => {
  return Boolean(
    record &&
      typeof record === 'object' &&
      record !== null &&
      'type' in record &&
      (record as { type: string }).type === 'cash',
  )
}

// Computed property for filtered cash records
const cashRecords = computed(() => {
  return paymentStore.componentRecords.cash.filter(isCashRecord)
})

const processPayment = () => {
  const paymentRecord: CashPaymentRecord = {
    id: generateId(),
    type: 'cash',
    cashReceived: cashReceived.value,
    schemesDiscount: schemesDiscount.value,
    notes: notes.value,
    timestamp: new Date().toISOString(),
  }

  // Add to store directly
  paymentStore.componentRecords.cash.push(paymentRecord)

  // Emit the payment record to parent
  emit('payment-record-added', {
    id: paymentRecord.id,
    type: 'cash',
    cashReceived: paymentRecord.cashReceived,
  })

  // Form will be cleared by user manually or when switching components

  console.log('Cash payment record added:', paymentRecord)
}

const editRecord = (index: number) => {
  const record = paymentStore.componentRecords.cash[index]

  if (isCashRecord(record)) {
    cashReceived.value = record.cashReceived
    schemesDiscount.value = record.schemesDiscount
    notes.value = record.notes
    editingIndex.value = index

    // Emit removal event
    emit('payment-record-removed', record.id)

    // Remove the record from store
    paymentStore.componentRecords.cash.splice(index, 1)
  }
}

const deleteRecord = (index: number) => {
  const record = paymentStore.componentRecords.cash[index]

  if (isCashRecord(record)) {
    // Emit removal event
    emit('payment-record-removed', record.id)

    // Remove from store
    paymentStore.componentRecords.cash.splice(index, 1)
  }
}

const resetForm = () => {
  cashReceived.value = 0
  schemesDiscount.value = 0
  notes.value = ''
  editingIndex.value = null
}

const generateId = () => {
  return Date.now().toString(36) + Math.random().toString(36).substr(2)
}

const formatTimestamp = (timestamp: string) => {
  return new Date(timestamp).toLocaleString()
}

onMounted(() => {
  // Load existing records from store
  const existingRecords = paymentStore.getComponentRecords('cash')
  if (existingRecords.length > 0) {
    // Filter and validate only cash records
    const validCashRecords = existingRecords.filter(isCashRecord).map((record) => ({
      id: record.id || generateId(),
      type: 'cash' as const,
      cashReceived: record.cashReceived || 0,
      schemesDiscount: record.schemesDiscount || 0,
      notes: record.notes || '',
      timestamp: record.timestamp || new Date().toISOString(),
    }))

    paymentStore.componentRecords.cash = validCashRecords
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

.pay-cash-btn {
  background-color: #5f9ea0;
  color: #f0f8ff;
  border: 1px solid #5f9ea0;
  transition: all 0.3s ease;
}

.pay-cash-btn:hover {
  background-color: #4a7c7e;
  border-color: #4a7c7e;
  color: #f0f8ff;
}

.pay-cash-btn:disabled {
  background-color: #a0a0a0;
  border-color: #a0a0a0;
  color: #d0d0d0;
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
