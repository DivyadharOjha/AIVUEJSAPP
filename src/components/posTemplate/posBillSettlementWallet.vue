<template>
  <div class="h-100">
    <div class="row h-100">
      <div class="col-12">
        <div class="card h-100">
          <div class="card-header bg-success text-white">
            <h4 class="mb-0">Digital Wallet Payment</h4>
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
                  <label for="memberId" class="form-label">Member ID</label>
                  <input
                    type="text"
                    class="form-control"
                    id="memberId"
                    v-model="memberId"
                    placeholder="M001"
                  />
                </div>
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="memberName" class="form-label">Member Name</label>
                  <input
                    type="text"
                    class="form-control"
                    id="memberName"
                    v-model="memberName"
                    placeholder="Member Name"
                    readonly
                  />
                </div>
                <div class="mb-3">
                  <label for="walletBalance" class="form-label">Wallet Available Balance</label>
                  <input
                    type="number"
                    class="form-control"
                    id="walletBalance"
                    v-model="walletBalance"
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
            </div>
            <div class="row">
              <div class="col-12">
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
                    <i class="bi bi-wallet2 me-2"></i>
                    Pay Wallet
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
                            <th>Wallet Type</th>
                            <th>Wallet Number</th>
                            <th>Wallet Balance</th>
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
                            <td>{{ record.walletType }}</td>
                            <td>{{ maskWalletNumber(record.walletId) }}</td>
                            <td>${{ record.walletBalance.toFixed(2) }}</td>
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
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'

interface WalletPaymentRecord {
  id: string
  type: 'wallet'
  walletType: string
  walletId: string
  walletBalance: number
  amount: number
  transactionId: string
  remainingBalance: number
  notes: string
  timestamp: string
}

// Removed emit since we're not using it anymore

const amountDue = ref(0)
const memberId = ref('')
const memberName = ref('')
const walletBalance = ref(0)
const amountReceive = ref(0)
const transactionId = ref('')
const notes = ref('')
const paymentRecords = ref<WalletPaymentRecord[]>([])
const editingIndex = ref<number | null>(null)

const isValidPayment = computed(() => {
  return (
    memberId.value.trim() !== '' &&
    amountReceive.value > 0 &&
    amountReceive.value <= walletBalance.value &&
    amountReceive.value <= amountDue.value
  )
})

const calculateRemainingBalance = () => {
  if (amountReceive.value > 0) {
    return Math.max(0, walletBalance.value - amountReceive.value)
  } else {
    return walletBalance.value
  }
}

const processPayment = () => {
  const remainingBalance = calculateRemainingBalance()

  const paymentRecord: WalletPaymentRecord = {
    id: generateId(),
    type: 'wallet',
    walletType: 'digital',
    walletId: memberId.value,
    walletBalance: walletBalance.value,
    amount: amountReceive.value,
    transactionId: transactionId.value,
    remainingBalance: remainingBalance,
    notes: notes.value,
    timestamp: new Date().toISOString(),
  }

  paymentRecords.value.push(paymentRecord)

  // Recalculate amount due
  recalculateAmountDue()

  // Reset form and generate new transaction ID
  resetForm()
  generateTransactionId()

  console.log('Wallet payment record added:', paymentRecord)
}

const editRecord = (index: number) => {
  const record = paymentRecords.value[index]
  memberId.value = record.walletId
  memberName.value = 'Member Name' // This would be loaded from API
  walletBalance.value = record.walletBalance
  amountReceive.value = record.amount
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
  memberId.value = ''
  memberName.value = ''
  walletBalance.value = 0
  amountReceive.value = 0
  notes.value = ''
  editingIndex.value = null
}

const generateId = () => {
  return Date.now().toString(36) + Math.random().toString(36).substr(2)
}

const formatTimestamp = (timestamp: string) => {
  return new Date(timestamp).toLocaleString()
}

const maskWalletNumber = (walletNumber: string) => {
  if (walletNumber.length >= 4) {
    return `****${walletNumber.slice(-4)}`
  }
  return walletNumber
}

const generateTransactionId = () => {
  const timestamp = Date.now()
  const random = Math.floor(Math.random() * 10000)
  transactionId.value = `WALLET-${timestamp}-${random}`
}

const loadWalletData = () => {
  // Simulate loading wallet data (in real app, this would be an API call)
  if (memberId.value.trim() !== '') {
    // Simulate different member data based on member ID
    if (memberId.value === 'M001') {
      memberName.value = 'John Doe'
      walletBalance.value = 500.0
    } else if (memberId.value === 'M002') {
      memberName.value = 'Jane Smith'
      walletBalance.value = 750.0
    } else {
      memberName.value = 'Unknown Member'
      walletBalance.value = 0
    }
    amountReceive.value = Math.min(amountDue.value, walletBalance.value)
  } else {
    // Clear member data if member ID is empty
    memberName.value = ''
    walletBalance.value = 0
    amountReceive.value = 0
  }
}

onMounted(() => {
  // Simulate amount due (in real app, this would come from props or store)
  amountDue.value = 125.5
  generateTransactionId()
})

onUnmounted(() => {
  // Clean up any potential memory leaks or references
  paymentRecords.value = []
  editingIndex.value = null
})

// Watch for changes in member ID to load wallet data
watch(memberId, () => {
  loadWalletData()
})

// Watch for changes in amount receive to calculate remaining balance
watch(amountReceive, () => {
  // This will trigger recalculation when amount receive changes
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
