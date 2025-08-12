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
                            <th>Cash Received</th>
                            <th>Schemes Discount</th>
                            <th>Net Amount</th>
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

interface CashPaymentRecord {
  id: string
  type: 'cash'
  cashReceived: number
  schemesDiscount: number
  notes: string
  timestamp: string
}



// Removed emit since we're not using it anymore

const amountDue = ref(0)
const cashReceived = ref(0)
const schemesDiscount = ref(0)
const notes = ref('')
const paymentRecords = ref<CashPaymentRecord[]>([])
const editingIndex = ref<number | null>(null)

const isValidPayment = computed(() => {
  const isValid = cashReceived.value > 0
  console.log('Payment validation:', {
    cashReceived: cashReceived.value,
    amountDue: amountDue.value,
    isValid: isValid,
  })
  return isValid
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

  paymentRecords.value.push(paymentRecord)

  // Recalculate amount due
  recalculateAmountDue()

  // Reset form
  resetForm()

  console.log('Cash payment record added:', paymentRecord)
}

const editRecord = (index: number) => {
  const record = paymentRecords.value[index]
  cashReceived.value = record.cashReceived
  schemesDiscount.value = record.schemesDiscount
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
    return sum + (record.cashReceived - record.schemesDiscount)
  }, 0)

  // Update amount due (assuming original amount due is stored somewhere)
  // For now, we'll use a fixed original amount
  const originalAmount = 125.5 // This should come from props or store
  amountDue.value = Math.max(0, originalAmount - totalPaid)
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
  // Simulate amount due (in real app, this would come from props or store)
  amountDue.value = 125.5
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
</style>
