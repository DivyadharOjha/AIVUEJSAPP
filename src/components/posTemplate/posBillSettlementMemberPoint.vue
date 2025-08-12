<template>
  <div class="h-100">
    <div class="row h-100">
      <div class="col-12">
        <div class="card h-100">
          <div class="card-header bg-success text-white">
            <h4 class="mb-0">Member Point Payment</h4>
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
                  <label for="availablePoints" class="form-label">Available Point</label>
                  <input
                    type="number"
                    class="form-control"
                    id="availablePoints"
                    v-model="availablePoints"
                    readonly
                    placeholder="0"
                  />
                </div>
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="pointValue" class="form-label">Point Value</label>
                  <input
                    type="number"
                    class="form-control"
                    id="pointValue"
                    v-model="pointValue"
                    readonly
                    placeholder="0.01"
                    step="0.01"
                  />
                </div>
                <div class="mb-3">
                  <label for="redeemedAmount" class="form-label">Redeemed Amount</label>
                  <input
                    type="number"
                    class="form-control"
                    id="redeemedAmount"
                    v-model="redeemedAmount"
                    readonly
                    placeholder="0.00"
                  />
                </div>
              </div>
            </div>
            <div class="row">
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="remainingAmount" class="form-label">Remaining Amount</label>
                  <input
                    type="number"
                    class="form-control"
                    id="remainingAmount"
                    v-model="remainingAmount"
                    readonly
                    placeholder="0.00"
                  />
                </div>
              </div>
              <div class="col-md-8">
                <div class="mb-3">
                  <label for="pointsToRedeem" class="form-label">Points to Redeem</label>
                  <input
                    type="number"
                    class="form-control"
                    id="pointsToRedeem"
                    v-model="pointsToRedeem"
                    placeholder="0"
                  />
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
                    <i class="bi bi-star me-2"></i>
                    Pay Point(s)
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
                            <th>Member ID</th>
                            <th>Member Name</th>
                            <th>Points Used</th>
                            <th>Redeemed Amount</th>
                            <th>Point Value</th>
                            <th>Remaining Amount</th>
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
                            <td>{{ record.memberId }}</td>
                            <td>{{ record.memberName }}</td>
                            <td>{{ record.pointsToRedeem }}</td>
                            <td>${{ record.redeemedAmount.toFixed(2) }}</td>
                            <td>${{ record.pointValue.toFixed(2) }}</td>
                            <td>{{ record.remainingAmount.toFixed(2) }}</td>
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

interface MemberPointPaymentRecord {
  id: string
  type: 'memberPoint'
  memberId: string
  memberName: string
  availablePoints: number
  pointsToRedeem: number
  pointValue: number
  redeemedAmount: number
  remainingAmount: number
  timestamp: string
}

// Removed emit since we're not using it anymore

const amountDue = ref(0)
const memberId = ref('')
const memberName = ref('')
const availablePoints = ref(0)
const pointsToRedeem = ref(0)
const pointValue = ref(0.01)
const redeemedAmount = ref(0)
const remainingAmount = ref(0)
const paymentRecords = ref<MemberPointPaymentRecord[]>([])
const editingIndex = ref<number | null>(null)

const isValidPayment = computed(() => {
  return (
    memberId.value.trim() !== '' &&
    pointsToRedeem.value > 0 &&
    pointsToRedeem.value <= availablePoints.value
  )
})

const calculateRedeemedAmount = () => {
  redeemedAmount.value = pointsToRedeem.value * pointValue.value
  remainingAmount.value = Math.max(0, amountDue.value - redeemedAmount.value)
}

const processPayment = () => {
  const paymentRecord: MemberPointPaymentRecord = {
    id: generateId(),
    type: 'memberPoint',
    memberId: memberId.value,
    memberName: memberName.value,
    availablePoints: availablePoints.value,
    pointsToRedeem: pointsToRedeem.value,
    pointValue: pointValue.value,
    redeemedAmount: redeemedAmount.value,
    remainingAmount: remainingAmount.value,
    timestamp: new Date().toISOString(),
  }

  paymentRecords.value.push(paymentRecord)

  // Recalculate amount due
  recalculateAmountDue()

  // Reset form
  resetForm()

  console.log('Member point payment record added:', paymentRecord)
}

const editRecord = (index: number) => {
  const record = paymentRecords.value[index]
  memberId.value = record.memberId
  memberName.value = record.memberName
  availablePoints.value = record.availablePoints
  pointsToRedeem.value = record.pointsToRedeem
  pointValue.value = record.pointValue
  redeemedAmount.value = record.redeemedAmount
  remainingAmount.value = record.remainingAmount
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
    return sum + record.redeemedAmount
  }, 0)

  // Update amount due (assuming original amount due is stored somewhere)
  // For now, we'll use a fixed original amount
  const originalAmount = 125.5 // This should come from props or store
  amountDue.value = Math.max(0, originalAmount - totalPaid)
}

const resetForm = () => {
  memberId.value = ''
  memberName.value = ''
  pointsToRedeem.value = 0
  redeemedAmount.value = 0
  remainingAmount.value = 0
  editingIndex.value = null
}

const generateId = () => {
  return Date.now().toString(36) + Math.random().toString(36).substr(2)
}

const formatTimestamp = (timestamp: string) => {
  return new Date(timestamp).toLocaleString()
}

const loadMemberData = () => {
  // Simulate loading member data (in real app, this would be an API call)
  if (memberId.value.trim() !== '') {
    memberName.value = 'John Doe'
    availablePoints.value = 2500
    pointValue.value = 0.01
  }
}

onMounted(() => {
  // Simulate amount due (in real app, this would come from props or store)
  amountDue.value = 125.5
})

// Watch for changes in member ID to load member data
watch(memberId, loadMemberData)

// Watch for changes in points to redeem to calculate amounts
watch(pointsToRedeem, calculateRedeemedAmount)
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
