<template>
  <div class="cash-inout-container">
    <!-- Times New Roman Test Section -->
    <div class="font-test-section">
      <h3 class="section-title">Times New Roman TTF Font Testing</h3>
      <TimesNewRomanTest />
    </div>
  </div>
</template>

<script setup lang="ts">
import TimesNewRomanTest from '../posComponent/TimesNewRomanTest.vue'

// Interfaces
interface Transaction {
  date: Date
  amount: number
  type: 'cash-in' | 'cash-out'
  description: string
  timestamp: Date
}

// Emits
defineEmits<{
  'date-selected': [date: Date, calendarType: string, formattedDate: string]
  'calendar-type-changed': [calendarType: string]
  'transaction-saved': [transaction: Transaction]
  'transaction-cancelled': []
}>()
</script>

<style scoped>
.cash-inout-container {
  background: #ffffff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  padding: 20px;
  max-width: 100%;
  min-height: 800px;
  height: auto;
}

.font-test-section {
  margin-top: 20px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
  border: 1px solid #e9ecef;
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
