<template>
  <div class="h-100">
    <div class="row h-100">
      <div class="col-12">
        <div class="card h-100">
          <div class="card-header bg-success text-white">
            <h4 class="mb-0">Debit Card Payment</h4>
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
                  <label for="amountReceive" class="form-label">Amount Receive</label>
                  <input
                    type="number"
                    class="form-control"
                    id="amountReceive"
                    v-model="amountReceive"
                    placeholder="Enter amount"
                    step="0.01"
                  />
                </div>
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="cardNumber" class="form-label">Card Number</label>
                  <input
                    type="text"
                    class="form-control"
                    id="cardNumber"
                    v-model="cardNumber"
                    placeholder="1234 5678 9012 3456"
                    maxlength="19"
                  />
                </div>
              </div>
            </div>
            <div class="row">
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="expiryDate" class="form-label">Expiry Date</label>
                  <input
                    type="text"
                    class="form-control"
                    id="expiryDate"
                    v-model="expiryDate"
                    placeholder="MM/YY"
                    maxlength="5"
                  />
                </div>
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="cvv" class="form-label">CVV</label>
                  <input
                    type="password"
                    class="form-control"
                    id="cvv"
                    v-model="cvv"
                    placeholder="123"
                    maxlength="4"
                  />
                </div>
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="cardholderName" class="form-label">Cardholder Name</label>
                  <input
                    type="text"
                    class="form-control"
                    id="cardholderName"
                    v-model="cardholderName"
                    placeholder="John Doe"
                  />
                </div>
              </div>
            </div>
            <div class="row">
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
                    <i class="bi bi-credit-card me-2"></i>
                    Pay Card
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
                            <th>Card Number</th>
                            <th>Cardholder Name</th>
                            <th>Amount</th>
                            <th>Transaction ID</th>
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
                            <td>{{ maskCardNumber(record.cardNumber) }}</td>
                            <td>{{ record.cardholderName }}</td>
                            <td>${{ record.amount.toFixed(2) }}</td>
                            <td>{{ record.transactionId }}</td>
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

interface DebitCardPaymentRecord {
  id: string
  type: 'debitCard'
  cardNumber: string
  expiryDate: string
  cvv: string
  cardholderName: string
  transactionId: string
  amount: number
  notes: string
  timestamp: string
}

// Removed emit since we're not using it anymore

const amountDue = ref(0)
const amountReceive = ref(0)
const cardNumber = ref('')
const expiryDate = ref('')
const cvv = ref('')
const cardholderName = ref('')
const transactionId = ref('')
const notes = ref('')
const paymentRecords = ref<DebitCardPaymentRecord[]>([])
const editingIndex = ref<number | null>(null)

const isValidPayment = computed(() => {
  return (
    amountReceive.value > 0 &&
    cardNumber.value.length >= 16 &&
    expiryDate.value.length === 5 &&
    cvv.value.length >= 3 &&
    cardholderName.value.trim() !== ''
  )
})

const processPayment = () => {
  const paymentRecord: DebitCardPaymentRecord = {
    id: generateId(),
    type: 'debitCard',
    cardNumber: cardNumber.value.replace(/\s/g, ''),
    expiryDate: expiryDate.value,
    cvv: cvv.value,
    cardholderName: cardholderName.value,
    transactionId: transactionId.value,
    amount: amountReceive.value,
    notes: notes.value,
    timestamp: new Date().toISOString(),
  }

  paymentRecords.value.push(paymentRecord)

  // Recalculate amount due
  recalculateAmountDue()

  // Reset form and generate new transaction ID
  resetForm()
  generateTransactionId()

  console.log('Debit card payment record added:', paymentRecord)
}

const editRecord = (index: number) => {
  const record = paymentRecords.value[index]
  amountReceive.value = record.amount
  cardNumber.value = record.cardNumber
  expiryDate.value = record.expiryDate
  cvv.value = record.cvv
  cardholderName.value = record.cardholderName
  transactionId.value = record.transactionId
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
  cardNumber.value = ''
  expiryDate.value = ''
  cvv.value = ''
  cardholderName.value = ''
  notes.value = ''
  editingIndex.value = null
}

const generateTransactionId = () => {
  const timestamp = Date.now()
  const random = Math.floor(Math.random() * 10000)
  transactionId.value = `DC-${timestamp}-${random}`
}

const generateId = () => {
  return Date.now().toString(36) + Math.random().toString(36).substr(2)
}

const formatTimestamp = (timestamp: string) => {
  return new Date(timestamp).toLocaleString()
}

const maskCardNumber = (cardNumber: string) => {
  if (cardNumber.length >= 4) {
    return `**** **** **** ${cardNumber.slice(-4)}`
  }
  return cardNumber
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
</style>
