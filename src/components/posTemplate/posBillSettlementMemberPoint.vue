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
                  <label for="availablePoints" class="form-label">Available Points</label>
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
                  <label for="pointsToRedeem" class="form-label">Points to Redeem</label>
                  <input
                    type="number"
                    class="form-control"
                    id="pointsToRedeem"
                    v-model="pointsToRedeem"
                    placeholder="0"
                  />
                </div>
                <div class="mb-3">
                  <label for="pointValue" class="form-label">Point Value (per point)</label>
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
            </div>
            <div class="row">
              <div class="col-md-4">
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
              <div class="col-md-4">
                <div class="mb-3">
                  <!-- Empty space to maintain 3-column layout -->
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
                    Pay with Member Points
                  </button>
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

interface MemberPointPaymentData {
  type: 'memberPoint'
  amountDue: number
  memberId: string
  memberName: string
  availablePoints: number
  pointsToRedeem: number
  pointValue: number
  redeemedAmount: number
  remainingAmount: number
  timestamp: string
}

const emit = defineEmits<{
  'payment-processed': [data: MemberPointPaymentData]
}>()

const amountDue = ref(0)
const memberId = ref('')
const memberName = ref('')
const availablePoints = ref(0)
const pointsToRedeem = ref(0)
const pointValue = ref(0.01)
const redeemedAmount = ref(0)
const remainingAmount = ref(0)

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
  const paymentData: MemberPointPaymentData = {
    type: 'memberPoint',
    amountDue: amountDue.value,
    memberId: memberId.value,
    memberName: memberName.value,
    availablePoints: availablePoints.value,
    pointsToRedeem: pointsToRedeem.value,
    pointValue: pointValue.value,
    redeemedAmount: redeemedAmount.value,
    remainingAmount: remainingAmount.value,
    timestamp: new Date().toISOString(),
  }

  emit('payment-processed', paymentData)
  console.log('Member point payment processed:', paymentData)
}

const resetForm = () => {
  memberId.value = ''
  memberName.value = ''
  pointsToRedeem.value = 0
  redeemedAmount.value = 0
  remainingAmount.value = 0
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
</style>
