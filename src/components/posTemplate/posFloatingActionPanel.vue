<template>
  <div class="position-fixed bottom-0 end-0 p-3" style="z-index: 1000">
    <div class="card shadow-lg border-0">
      <div class="card-body p-3">
        <div class="d-flex gap-2 align-items-center">
          <!-- Pre-payment controls -->
          <div v-if="!paymentProcessed" class="d-flex gap-2">
            <button type="button" class="btn btn-outline-secondary btn-sm" @click="onReset">
              <i class="bi bi-arrow-clockwise me-1"></i>Reset
            </button>
            <button
              type="button"
              class="btn btn-success btn-sm"
              @click="onProcessPayment"
              :disabled="!isValidPayment"
            >
              <i :class="paymentIcon + ' me-1'"></i>{{ paymentButtonText }}
            </button>
          </div>

          <!-- Post-payment controls -->
          <div v-if="paymentProcessed" class="d-flex gap-2">
            <button type="button" class="btn btn-outline-primary btn-sm" @click="onPrintReceipt">
              <i class="bi bi-printer me-1"></i>Print
            </button>
            <button type="button" class="btn btn-outline-success btn-sm" @click="onEmailReceipt">
              <i class="bi bi-envelope me-1"></i>Email
            </button>
            <button type="button" class="btn btn-outline-info btn-sm" @click="onSendSMS">
              <i class="bi bi-chat me-1"></i>SMS
            </button>
            <button type="button" class="btn btn-outline-warning btn-sm" @click="onNewTransaction">
              <i class="bi bi-plus-circle me-1"></i>New
            </button>
            <button type="button" class="btn btn-outline-secondary btn-sm" @click="onClosePayment">
              <i class="bi bi-x-circle me-1"></i>Close
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { defineProps, defineEmits } from 'vue'

interface Props {
  paymentProcessed: boolean
  isValidPayment: boolean
  paymentButtonText: string
  paymentIcon: string
}

interface Emits {
  reset: []
  processPayment: []
  printReceipt: []
  emailReceipt: []
  sendSMS: []
  newTransaction: []
  closePayment: []
}

const props = defineProps<Props>()
const emit = defineEmits<Emits>()

const onReset = () => emit('reset')
const onProcessPayment = () => emit('processPayment')
const onPrintReceipt = () => emit('printReceipt')
const onEmailReceipt = () => emit('emailReceipt')
const onSendSMS = () => emit('sendSMS')
const onNewTransaction = () => emit('newTransaction')
const onClosePayment = () => emit('closePayment')
</script>

<style scoped>
.card {
  min-width: 300px;
}

.btn-sm {
  font-size: 0.875rem;
  padding: 0.375rem 0.75rem;
}
</style>
