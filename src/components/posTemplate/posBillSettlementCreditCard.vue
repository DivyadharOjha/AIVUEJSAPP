<template>
  <div class="h-100 d-flex flex-column">
    <!-- Row 1: Label (60px) -->
    <div class="row label-row">
      <div class="col-12">
        <div
          class="card-header bg-success text-white d-flex align-items-center justify-content-center"
        >
          <h3 class="mb-0">Credit Card Payment</h3>
        </div>
      </div>
    </div>

    <!-- Row 2: Card Type Selection (40px) -->
    <div class="row card-selection-row">
      <div class="col-12">
        <div class="card-body d-flex align-items-center justify-content-center">
          <div class="d-flex flex-wrap gap-4">
            <div class="form-check">
              <input
                class="form-check-input"
                type="radio"
                name="cardType"
                id="visa"
                value="visa"
                v-model="selectedCardType"
              />
              <label class="form-check-label fw-bold" for="visa">
                <i class="bi bi-credit-card text-primary me-2"></i>
                Visa
              </label>
            </div>
            <div class="form-check">
              <input
                class="form-check-input"
                type="radio"
                name="cardType"
                id="mastercard"
                value="mastercard"
                v-model="selectedCardType"
              />
              <label class="form-check-label fw-bold" for="mastercard">
                <i class="bi bi-credit-card text-danger me-2"></i>
                Mastercard
              </label>
            </div>
            <div class="form-check">
              <input
                class="form-check-input"
                type="radio"
                name="cardType"
                id="amex"
                value="amex"
                v-model="selectedCardType"
              />
              <label class="form-check-label fw-bold" for="amex">
                <i class="bi bi-credit-card text-success me-2"></i>
                American Express
              </label>
            </div>
            <div class="form-check">
              <input
                class="form-check-input"
                type="radio"
                name="cardType"
                id="discover"
                value="discover"
                v-model="selectedCardType"
              />
              <label class="form-check-label fw-bold" for="discover">
                <i class="bi bi-credit-card text-warning me-2"></i>
                Discover
              </label>
            </div>
            <div class="form-check">
              <input
                class="form-check-input"
                type="radio"
                name="cardType"
                id="other"
                value="other"
                v-model="selectedCardType"
              />
              <label class="form-check-label fw-bold" for="other">
                <i class="bi bi-credit-card text-secondary me-2"></i>
                Other
              </label>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Row 3: Form Controls and Buttons (Dynamic height) -->
    <div class="row form-row flex-grow-1">
      <div class="col-12">
        <div class="card-body form-container">
          <!-- Amount Information -->
          <div class="row">
            <div class="col-md-4">
              <div class="mb-2">
                <label for="amount" class="form-label fw-bold">Amount Due</label>
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
              <div class="mb-2">
                <label for="amountReceive" class="form-label fw-bold">Amount Receive</label>
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
              <div class="mb-2">
                <label for="cardNumber" class="form-label fw-bold">Card Number</label>
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
              <div class="mb-2">
                <label for="expiryDate" class="form-label fw-bold">Expiry Date</label>
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
              <div class="mb-2">
                <label for="cvv" class="form-label fw-bold">CVV</label>
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
              <div class="mb-2">
                <label for="cardholderName" class="form-label fw-bold">Cardholder Name</label>
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
              <div class="mb-2">
                <label for="transactionId" class="form-label fw-bold">Transaction ID</label>
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
              <div class="mb-2">
                <label for="notes" class="form-label fw-bold">Notes</label>
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

          <!-- Buttons moved into form row -->
          <div class="row mt-3">
            <div class="col-12">
              <div class="d-flex justify-content-end gap-4 align-items-center">
                <button type="button" class="btn btn-secondary" @click="resetForm">
                  <i class="bi bi-arrow-clockwise me-2"></i>
                  Reset
                </button>
                <button
                  type="button"
                  class="btn btn-success"
                  @click="processPayment"
                  :disabled="!isValidPayment"
                  :title="
                    !selectedCardType.trim()
                      ? 'Please select a card type'
                      : !amountReceive.value
                        ? 'Please enter an amount'
                        : 'Process payment'
                  "
                >
                  <i class="bi bi-credit-card me-2"></i>
                  Pay Card
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Row 4: Payment Records Table (Dynamic height) -->
    <div class="row table-row flex-grow-1" v-if="creditCardRecords.length > 0">
      <div class="col-12">
        <div class="card-body table-container">
          <div class="card">
            <div class="card-body table-content">
              <div class="table-responsive">
                <table class="table table-striped table-hover">
                  <thead class="table-dark">
                    <tr>
                      <th width="100">Actions</th>
                      <th>Card Type</th>
                      <th>Card Number</th>
                      <th>Cardholder Name</th>
                      <th>Amount</th>
                      <th>Transaction ID</th>
                      <th>Notes</th>
                      <th>Timestamp</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(record, index) in creditCardRecords" :key="record.id">
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
                      <td>
                        <span class="badge" :class="getCardTypeBadgeClass(record.cardType)">
                          {{
                            (record.cardType && record.cardType.trim() !== ''
                              ? record.cardType
                              : 'Unknown'
                            ).toUpperCase()
                          }}
                        </span>
                      </td>
                      <td>{{ maskCardNumber(record.cardNumber) }}</td>
                      <td>{{ record.cardholderName || '-' }}</td>
                      <td>${{ (record.amount || 0).toFixed(2) }}</td>
                      <td>{{ record.transactionId || '-' }}</td>
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
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { usePaymentStore, type CreditCardPaymentRecord } from '../../stores/paymentStore'

const emit = defineEmits<{
  'payment-record-added': [
    record: {
      id: string
      type: string
      cardType: string
      cardNumber: string
      expiryDate: string
      cvv: string
      cardholderName: string
      transactionId: string
      amount: number
      notes: string
      timestamp: string
    },
  ]
  'payment-record-removed': [recordId: string]
}>()

// Use the payment store
const paymentStore = usePaymentStore()

const selectedCardType = ref('')
const amountReceive = ref(0)
const cardNumber = ref('')
const expiryDate = ref('')
const cvv = ref('')
const cardholderName = ref('')
const transactionId = ref('')
const notes = ref('')
const editingIndex = ref<number | null>(null)

// Get amount due from store
const amountDue = computed(() => paymentStore.currentAmountDue)

const isValidPayment = computed(() => {
  return amountReceive.value > 0 && selectedCardType.value.trim() !== ''
})

// Type guard function to check if record is a credit card payment
const isCreditCardRecord = (record: unknown): record is CreditCardPaymentRecord => {
  return Boolean(
    record &&
      typeof record === 'object' &&
      record !== null &&
      'type' in record &&
      (record as { type: string }).type === 'creditCard',
  )
}

// Computed property for filtered credit card records
const creditCardRecords = computed(() => {
  return paymentStore.componentRecords.creditCard
    .filter(isCreditCardRecord)
    .filter((record) => record.cardType && record.cardType.trim() !== '' && record.amount > 0)
})

const processPayment = () => {
  console.log('Processing credit card payment:', {
    selectedCardType: selectedCardType.value,
    amountReceive: amountReceive.value,
    isValid: selectedCardType.value.trim() !== '' && amountReceive.value > 0,
  })

  // Additional validation to prevent empty records
  if (!selectedCardType.value.trim() || amountReceive.value <= 0) {
    console.warn('Invalid payment data: Card type or amount is missing')
    return
  }

  const paymentRecord: CreditCardPaymentRecord = {
    id: generateId(),
    type: 'creditCard',
    cardType: selectedCardType.value,
    cardNumber: cardNumber.value.replace(/\s/g, ''),
    expiryDate: expiryDate.value,
    cvv: cvv.value,
    cardholderName: cardholderName.value,
    transactionId: transactionId.value,
    amount: amountReceive.value,
    notes: notes.value,
    timestamp: new Date().toISOString(),
  }

  // Emit the payment record to parent (let parent handle store addition)
  emit('payment-record-added', {
    id: paymentRecord.id,
    type: 'creditCard',
    cardType: paymentRecord.cardType,
    cardNumber: paymentRecord.cardNumber,
    expiryDate: paymentRecord.expiryDate,
    cvv: paymentRecord.cvv,
    cardholderName: paymentRecord.cardholderName,
    transactionId: paymentRecord.transactionId,
    amount: paymentRecord.amount,
    notes: paymentRecord.notes,
    timestamp: paymentRecord.timestamp,
  })

  // Clear amount field for next payment
  amountReceive.value = 0

  // Generate new transaction ID for next payment
  generateTransactionId()

  console.log('Credit card payment record added:', paymentRecord)
}

const editRecord = (index: number) => {
  const record = paymentStore.componentRecords.creditCard[index]

  if (isCreditCardRecord(record)) {
    selectedCardType.value = record.cardType
    amountReceive.value = record.amount
    cardNumber.value = record.cardNumber
    expiryDate.value = record.expiryDate
    cvv.value = record.cvv
    cardholderName.value = record.cardholderName
    transactionId.value = record.transactionId
    notes.value = record.notes
    editingIndex.value = index

    // Emit removal event
    emit('payment-record-removed', record.id)

    // Remove the record from store
    paymentStore.componentRecords.creditCard.splice(index, 1)
  }
}

const deleteRecord = (index: number) => {
  const record = paymentStore.componentRecords.creditCard[index]

  if (isCreditCardRecord(record)) {
    // Emit removal event
    emit('payment-record-removed', record.id)

    // Remove from store
    paymentStore.componentRecords.creditCard.splice(index, 1)
  }
}

const resetForm = () => {
  selectedCardType.value = ''
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
  transactionId.value = `CC-${timestamp}-${random}`
}

const generateId = () => {
  return Date.now().toString(36) + Math.random().toString(36).substr(2)
}

const formatTimestamp = (timestamp: string) => {
  if (!timestamp) {
    return '-'
  }
  return new Date(timestamp).toLocaleString()
}

const maskCardNumber = (cardNumber: string) => {
  if (!cardNumber) {
    return ''
  }

  if (cardNumber.length >= 4) {
    return `**** **** **** ${cardNumber.slice(-4)}`
  }
  return cardNumber
}

const getCardTypeBadgeClass = (cardType: string) => {
  if (!cardType) {
    return 'bg-secondary'
  }

  switch (cardType.toLowerCase()) {
    case 'visa':
      return 'bg-primary'
    case 'mastercard':
      return 'bg-danger'
    case 'amex':
      return 'bg-success'
    case 'discover':
      return 'bg-warning'
    case 'other':
      return 'bg-secondary'
    default:
      return 'bg-secondary'
  }
}

onMounted(() => {
  // Clean any invalid records from the store
  paymentStore.cleanInvalidRecords()

  // Load existing records from store
  const existingRecords = paymentStore.getComponentRecords('creditCard')
  if (existingRecords.length > 0) {
    // Filter and validate only credit card records with valid data
    const validCreditCardRecords = existingRecords
      .filter(isCreditCardRecord)
      .filter((record) => record.cardType && record.cardType.trim() !== '' && record.amount > 0)
      .map((record) => ({
        id: record.id || generateId(),
        type: 'creditCard' as const,
        cardType: record.cardType || 'other',
        cardNumber: record.cardNumber || '',
        expiryDate: record.expiryDate || '',
        cvv: record.cvv || '',
        cardholderName: record.cardholderName || '',
        transactionId: record.transactionId || '',
        amount: record.amount || 0,
        notes: record.notes || '',
        timestamp: record.timestamp || new Date().toISOString(),
      }))

    paymentStore.componentRecords.creditCard = validCreditCardRecords
  }

  generateTransactionId()
})
</script>

<style scoped>
.card {
  border: none;
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
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

/* Row Layout Styles */
.label-row {
  height: 60px;
  flex-shrink: 0;
}

.card-selection-row {
  height: 40px;
  flex-shrink: 0;
}

.form-row {
  height: auto;
  min-height: 0;
  flex-shrink: 0;
}

.table-row {
  height: calc(100% - 100px - 200px); /* (100% - 60px - 40px - estimated form height) */
  min-height: 150px;
  max-height: 400px;
  overflow-y: auto;
  margin-top: 1rem;
}

/* Container Styles */
.form-container {
  height: auto;
  overflow-y: visible;
  padding: 0.5rem;
  margin-bottom: 0.25rem;
}

.table-container {
  height: 100%;
  padding: 0;
  margin-top: 0.5rem;
}

.table-content {
  height: 100%;
  overflow-y: auto;
  padding: 0;
}

/* Scrollbar styles for form container */
.form-container::-webkit-scrollbar {
  width: 8px;
}

.form-container::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.form-container::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 4px;
}

.form-container::-webkit-scrollbar-thumb:hover {
  background: #555;
}

/* Scrollbar styles for table content */
.table-content::-webkit-scrollbar {
  width: 8px;
}

.table-content::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 4px;
}

.table-content::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 4px;
}

.table-content::-webkit-scrollbar-thumb:hover {
  background: #555;
}

/* Firefox scrollbar styles */
.form-container,
.table-content {
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
