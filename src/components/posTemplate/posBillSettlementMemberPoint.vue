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
              </div>
              <div class="col-md-4">
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
              </div>
              <div class="col-md-4">
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
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="pointsToRedeem" class="form-label">Points to Redeem</label>
                  <input
                    type="number"
                    class="form-control"
                    id="pointsToRedeem"
                    v-model="pointsToRedeem"
                    placeholder="0"
                    @keyup.enter="calculateRedeemedAmount"
                    @blur="calculateRedeemedAmount"
                    title="Enter points to redeem. Press Enter or click outside to calculate amount."
                  />
                </div>
              </div>
              <div class="col-md-4">
                <div class="mb-3">
                  <label for="redeemedAmount" class="form-label">Amount Receive</label>
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
                    :title="
                      !memberId.trim()
                        ? 'Please enter member ID'
                        : !pointsToRedeem
                          ? 'Please enter points to redeem'
                          : pointsToRedeem > availablePoints
                            ? 'Points to redeem cannot exceed available points'
                            : 'Process payment'
                    "
                    style="padding: 10px; width: fit-content"
                  >
                    <i class="bi bi-star me-2"></i>
                    Pay Point(s)
                  </button>
                </div>
              </div>
            </div>
            <!-- Payment Records Table -->
            <div class="row mt-4" v-if="memberPointRecords.length > 0">
              <div class="col-12">
                <div class="card">
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
                          <tr v-for="(record, index) in memberPointRecords" :key="record.id">
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
import { usePaymentStore, type MemberPointPaymentRecord } from '../../stores/paymentStore'

const emit = defineEmits<{
  'payment-record-added': [record: { id: string; type: string; amount: number }]
  'payment-record-removed': [recordId: string]
}>()

// Use the payment store
const paymentStore = usePaymentStore()

const memberId = ref('')
const memberName = ref('')
const availablePoints = ref(0)
const pointsToRedeem = ref(0)
const pointValue = ref(0.01)
const redeemedAmount = ref(0)
const remainingAmount = ref(0)
const editingIndex = ref<number | null>(null)

// Get amount due from store
const amountDue = computed(() => paymentStore.currentAmountDue)

const isValidPayment = computed(() => {
  const hasMemberId = memberId.value.trim() !== ''
  const hasPoints = pointsToRedeem.value > 0
  const pointsValid = pointsToRedeem.value <= availablePoints.value

  const isValid = hasMemberId && hasPoints && pointsValid

  console.log('Member point validation:', {
    memberId: memberId.value,
    hasMemberId: hasMemberId,
    pointsToRedeem: pointsToRedeem.value,
    hasPoints: hasPoints,
    availablePoints: availablePoints.value,
    pointsValid: pointsValid,
    isValid: isValid,
  })

  return isValid
})

// Type guard function to check if record is a member point payment
const isMemberPointRecord = (record: unknown): record is MemberPointPaymentRecord => {
  return Boolean(
    record &&
      typeof record === 'object' &&
      record !== null &&
      'type' in record &&
      (record as { type: string }).type === 'memberPoint',
  )
}

// Computed property for filtered member point records
const memberPointRecords = computed(() => {
  const allRecords = paymentStore.componentRecords.memberPoint
  const filteredRecords = allRecords
    .filter(isMemberPointRecord)
    .filter(
      (record) => record.memberId && record.memberId.trim() !== '' && record.redeemedAmount > 0,
    )

  console.log('Member point records computed:', {
    allRecords: allRecords,
    filteredRecords: filteredRecords,
    totalRecords: allRecords.length,
    filteredCount: filteredRecords.length,
  })

  return filteredRecords
})

const calculateRedeemedAmount = () => {
  console.log('Calculating redeemed amount:', {
    pointsToRedeem: pointsToRedeem.value,
    pointValue: pointValue.value,
    amountDue: amountDue.value,
  })

  redeemedAmount.value = pointsToRedeem.value * pointValue.value
  remainingAmount.value = Math.max(0, amountDue.value - redeemedAmount.value)

  console.log('Calculated values:', {
    redeemedAmount: redeemedAmount.value,
    remainingAmount: remainingAmount.value,
  })
}

const processPayment = () => {
  console.log('Processing member point payment:', {
    memberId: memberId.value,
    pointsToRedeem: pointsToRedeem.value,
    redeemedAmount: redeemedAmount.value,
    isValid:
      memberId.value.trim() !== '' &&
      pointsToRedeem.value > 0 &&
      pointsToRedeem.value <= availablePoints.value,
  })

  // Additional validation to prevent empty records
  if (
    !memberId.value.trim() ||
    pointsToRedeem.value <= 0 ||
    pointsToRedeem.value > availablePoints.value
  ) {
    console.warn('Invalid payment data: Required fields are missing or invalid')
    return
  }

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
    notes: '', // Add empty notes field
    timestamp: new Date().toISOString(),
  }

  // Add to store directly
  paymentStore.componentRecords.memberPoint.push(paymentRecord)

  // Emit the payment record to parent
  const emitData = {
    id: paymentRecord.id,
    type: 'memberPoint',
    amount: paymentRecord.redeemedAmount,
  }

  console.log('Emitting member point data:', emitData)
  emit('payment-record-added', emitData)

  // Clear amount field for next payment
  pointsToRedeem.value = 0

  console.log('Member point payment record added:', paymentRecord)
  console.log('Store records after adding:', paymentStore.componentRecords.memberPoint)
}

// Watch for changes in points to redeem to automatically calculate amounts
watch(pointsToRedeem, () => {
  calculateRedeemedAmount()
})

// Watch for changes in point value to recalculate amounts
watch(pointValue, () => {
  calculateRedeemedAmount()
})

// Watch for changes in member ID to load member data
watch(memberId, () => {
  loadMemberData()
})

// Watch for changes in member point records
watch(
  () => paymentStore.componentRecords.memberPoint,
  (newRecords) => {
    console.log('Member point records changed:', newRecords)
  },
  { deep: true },
)

const editRecord = (index: number) => {
  const record = paymentStore.componentRecords.memberPoint[index]

  if (isMemberPointRecord(record)) {
    memberId.value = record.memberId
    memberName.value = record.memberName
    availablePoints.value = record.availablePoints
    pointsToRedeem.value = record.pointsToRedeem
    pointValue.value = record.pointValue
    redeemedAmount.value = record.redeemedAmount
    remainingAmount.value = record.remainingAmount
    editingIndex.value = index

    // Emit removal event
    emit('payment-record-removed', record.id)

    // Remove the record from store
    paymentStore.componentRecords.memberPoint.splice(index, 1)
  }
}

const deleteRecord = (index: number) => {
  const record = paymentStore.componentRecords.memberPoint[index]

  if (isMemberPointRecord(record)) {
    // Emit removal event
    emit('payment-record-removed', record.id)

    // Remove from store
    paymentStore.componentRecords.memberPoint.splice(index, 1)
  }
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
    // Simulate different member data based on member ID
    if (memberId.value === 'M001') {
      memberName.value = 'John Doe'
      availablePoints.value = 2500
      pointValue.value = 0.01
    } else if (memberId.value === 'M002') {
      memberName.value = 'Jane Smith'
      availablePoints.value = 1800
      pointValue.value = 0.01
    } else {
      memberName.value = 'Unknown Member'
      availablePoints.value = 0
      pointValue.value = 0.01
    }
  } else {
    // Clear member data if member ID is empty
    memberName.value = ''
    availablePoints.value = 0
    pointValue.value = 0.01
  }

  // Recalculate amounts after loading member data
  calculateRedeemedAmount()
}

onMounted(() => {
  // Clean any invalid records from the store
  paymentStore.cleanInvalidRecords()

  // Load existing records from store
  const existingRecords = paymentStore.getComponentRecords('memberPoint')
  if (existingRecords.length > 0) {
    // Filter and validate only member point records with valid data
    const validMemberPointRecords = existingRecords
      .filter(isMemberPointRecord)
      .filter(
        (record) => record.memberId && record.memberId.trim() !== '' && record.redeemedAmount > 0,
      )
      .map((record) => ({
        id: record.id || generateId(),
        type: 'memberPoint' as const,
        memberId: record.memberId || '',
        memberName: record.memberName || '',
        availablePoints: record.availablePoints || 0,
        pointsToRedeem: record.pointsToRedeem || 0,
        pointValue: record.pointValue || 0.01,
        redeemedAmount: record.redeemedAmount || 0,
        remainingAmount: record.remainingAmount || 0,
        notes: record.notes || '',
        timestamp: record.timestamp || new Date().toISOString(),
      }))

    paymentStore.componentRecords.memberPoint = validMemberPointRecords
  }

  // Set default member ID for testing
  memberId.value = 'M001'

  // Load member data
  loadMemberData()

  console.log('Member Point component mounted:', {
    amountDue: amountDue.value,
    memberId: memberId.value,
    memberName: memberName.value,
    availablePoints: availablePoints.value,
  })
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

/* Ensure all form controls are visible */
.form-control {
  display: block !important;
  visibility: visible !important;
}

.form-label {
  display: block !important;
  visibility: visible !important;
}

/* Debug styles to ensure layout is working */
.row {
  display: flex !important;
  flex-wrap: wrap !important;
}

.col-md-4 {
  flex: 0 0 33.333333% !important;
  max-width: 33.333333% !important;
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
