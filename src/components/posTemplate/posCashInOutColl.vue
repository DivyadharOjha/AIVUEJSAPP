<template>
  <div class="cash-inout-container">
    <!-- Previous implementation - commented out -->
    <!--
    <posCalendar
      :initial-date="props.initialDate"
      :initial-calendar-type="props.initialCalendarType"
      :show-events="props.showEvents"
      @date-selected="handleDateSelected"
      @calendar-type-changed="handleCalendarTypeChanged"
    />
    -->

    <!-- New implementation using posCalendarControl -->
    <div class="calendar-control-section">
      <!-- Date Selection -->
      <div class="form-group mb-3">
        <label class="form-label">Select Date</label>
        <posCalendarControl
          v-model="selectedDate"
          placeholder="Select date for cash in/out..."
          @date-selected="handleCalendarDateSelected"
        />
      </div>

      <!-- Amount Input - Commented out -->
      <!--
        <div class="form-group mb-3">
          <label class="form-label">Amount</label>
          <input type="number" class="form-control" placeholder="Enter amount..." v-model="amount" />
        </div>
        -->

      <!-- Type Selection - Commented out -->
      <!--
        <div class="form-group mb-3">
          <label class="form-label">Type</label>
          <select class="form-select" v-model="transactionType">
            <option value="cash-in">Cash In</option>
            <option value="cash-out">Cash Out</option>
          </select>
        </div>
        -->

      <!-- Description - Commented out -->
      <!--
        <div class="form-group mb-3">
          <label class="form-label">Description</label>
          <textarea
            class="form-control"
            rows="3"
            placeholder="Enter description..."
            v-model="description"
          ></textarea>
        </div>
        -->

      <!-- Action Buttons - Commented out -->
      <!--
        <div class="action-buttons">
          <button
            class="btn btn-primary me-2"
            @click="handleSubmit"
            :disabled="!selectedDate || !amount"
          >
            <i class="fas fa-save me-1"></i>
            Save Transaction
          </button>
          <button class="btn btn-outline-secondary" @click="handleCancel">
            <i class="fas fa-times me-1"></i>
            Cancel
          </button>
        </div>
        -->
    </div>
  </div>
</template>

<script setup lang="ts">
// Previous imports - commented out
// import posCalendar from './posCalendar.vue'

// New imports
import posCalendarControl from './posCalendarControl.vue'
import { ref } from 'vue'

// Interfaces
interface Props {
  initialDate?: Date
  initialCalendarType?: 'gregorian' | 'hijri' | 'shamshi' | 'bikram'
  showEvents?: boolean
}

interface Transaction {
  date: Date
  amount: number
  type: 'cash-in' | 'cash-out'
  description: string
  timestamp: Date
}

const props = withDefaults(defineProps<Props>(), {
  initialDate: () => new Date(),
  initialCalendarType: 'gregorian',
  showEvents: true,
})

// Emits
const emit = defineEmits<{
  'date-selected': [date: Date, calendarType: string, formattedDate: string]
  'calendar-type-changed': [calendarType: string]
  'transaction-saved': [transaction: Transaction]
  'transaction-cancelled': []
}>()

// Reactive data for new implementation
const selectedDate = ref<Date | null>(props.initialDate)
// Form fields - commented out since they're not being used
/*
const amount = ref<number | null>(null)
const transactionType = ref<'cash-in' | 'cash-out'>('cash-in')
const description = ref('')
*/

// Previous event handlers - commented out
/*
function handleDateSelected(date: Date, calendarType: string, formattedDate: string): void {
  emit('date-selected', date, calendarType, formattedDate)
}

function handleCalendarTypeChanged(calendarType: string): void {
  emit('calendar-type-changed', calendarType)
}
*/

// New event handlers
function handleCalendarDateSelected(date: Date): void {
  selectedDate.value = date
  console.log('Date selected for cash in/out:', date)

  // Emit the date selection event for backward compatibility
  emit('date-selected', date, 'gregorian', formatDate(date))
}

// handleSubmit function - commented out since form fields are commented
/*
function handleSubmit(): void {
  if (!selectedDate.value || !amount.value) {
    console.warn('Please select a date and enter an amount')
    return
  }

  const transaction = {
    date: selectedDate.value,
    amount: amount.value,
    type: transactionType.value,
    description: description.value,
    timestamp: new Date(),
  }

  console.log('Saving transaction:', transaction)
  emit('transaction-saved', transaction)

  // Reset form
  selectedDate.value = props.initialDate
  amount.value = null
  transactionType.value = 'cash-in'
  description.value = ''
}
*/

// handleCancel function - commented out since form fields are commented
/*
function handleCancel(): void {
  console.log('Transaction cancelled')
  emit('transaction-cancelled')

  // Reset form
  selectedDate.value = props.initialDate
  amount.value = null
  transactionType.value = 'cash-in'
  description.value = ''
}
*/

// Utility function
function formatDate(date: Date): string {
  const day = date.getDate().toString().padStart(2, '0')
  const month = (date.getMonth() + 1).toString().padStart(2, '0')
  const year = date.getFullYear()
  return `${day}/${month}/${year}`
}
</script>

<style scoped>
.cash-inout-container {
  background: #ffffff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  padding: 20px;
  max-width: 500px;
  min-height: 400px;
  height: 500px;
}

.calendar-control-section {
  width: 100%;
}

.section-title {
  color: #495057;
  font-weight: 600;
  border-bottom: 2px solid #e9ecef;
  padding-bottom: 8px;
}

.form-label {
  font-weight: 500;
  color: #495057;
  margin-bottom: 6px;
}

.form-control,
.form-select {
  border: 1px solid #ced4da;
  border-radius: 6px;
  padding: 8px 12px;
  font-size: 14px;
  transition: border-color 0.2s ease;
}

.form-control:focus,
.form-select:focus {
  border-color: #007bff;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
  outline: none;
}

.action-buttons {
  display: flex;
  gap: 8px;
  margin-top: 20px;
}

.btn {
  padding: 8px 16px;
  font-size: 14px;
  font-weight: 500;
  border-radius: 6px;
  transition: all 0.2s ease;
}

.btn-primary {
  background-color: #007bff;
  border-color: #007bff;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background-color: #0056b3;
  border-color: #0056b3;
}

.btn-primary:disabled {
  background-color: #6c757d;
  border-color: #6c757d;
  cursor: not-allowed;
}

.btn-outline-secondary {
  color: #6c757d;
  border-color: #6c757d;
  background-color: transparent;
}

.btn-outline-secondary:hover {
  color: white;
  background-color: #6c757d;
  border-color: #6c757d;
}

/* Responsive design */
@media (max-width: 576px) {
  .cash-inout-container {
    padding: 16px;
  }

  .action-buttons {
    flex-direction: column;
  }

  .btn {
    width: 100%;
  }
}
</style>
