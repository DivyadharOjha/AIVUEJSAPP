<template>
  <div class="cash-inout-container">
    <!-- Radio Buttons Section -->
    <div class="radio-section">
      <div class="radio-group">
        <label class="radio-label">
          <input
            type="radio"
            name="paymentType"
            value="counter"
            v-model="selectedPaymentType"
            class="radio-input"
          />
          <span class="radio-custom"></span>
          Counter
        </label>
        <label class="radio-label">
          <input
            type="radio"
            name="paymentType"
            value="account"
            v-model="selectedPaymentType"
            class="radio-input"
          />
          <span class="radio-custom"></span>
          Account
        </label>
      </div>
    </div>

    <!-- Input Fields Section -->
    <div class="input-section">
      <!-- From Counter/Account Dropdown -->
      <div class="form-row">
        <label class="form-label"
          >From {{ selectedPaymentType === 'counter' ? 'Counter' : 'Account' }}:</label
        >
        <div class="form-control-wrapper">
          <select
            v-model="selectedSource"
            class="form-select"
            :class="{ disabled: !selectedPaymentType }"
          >
            <option value="" disabled>Please select...</option>
            <option v-for="option in sourceOptions" :key="option.value" :value="option.value">
              {{ option.label }}
            </option>
          </select>
        </div>
      </div>

      <!-- Remarks Field -->
      <div class="form-row">
        <label class="form-label">Remarks:</label>
        <div class="form-control-wrapper">
          <textarea
            v-model="remarks"
            class="form-textarea"
            placeholder="Enter remarks..."
            rows="3"
          ></textarea>
        </div>
      </div>
    </div>

    <!-- Currency Details Section -->
    <div class="currency-section">
      <h3 class="section-title">Currency Details</h3>

      <div class="table-container">
        <table class="currency-table">
          <thead>
            <tr>
              <th class="sno-col">S.No.</th>
              <th class="currency-col">Currency Name</th>
              <th class="amount-col">Amount</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(currency, index) in currencies" :key="currency.id">
              <td class="sno-col">{{ index + 1 }}</td>
              <td class="currency-col">{{ currency.name }}</td>
              <td class="amount-col">
                <div class="amount-input-group">
                  <input
                    type="number"
                    v-model="currency.amount"
                    class="amount-input"
                    placeholder="0"
                    min="0"
                    step="0.01"
                  />
                  <select v-model="currency.type" class="type-select">
                    <option value="D">D</option>
                    <option value="C">C</option>
                  </select>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Action Buttons Section -->
    <div class="action-buttons">
      <button @click="handleBack" class="btn btn-action">Back</button>
      <button @click="handleSave" class="btn btn-action">Save</button>
      <button @click="handleSaveAndPrint" class="btn btn-action">Save & Print</button>
      <button @click="handleSearch" class="btn btn-action">Search</button>
      <button @click="handleClear" class="btn btn-action">Clear</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

// Reactive data
const selectedPaymentType = ref<'counter' | 'account' | null>(null)
const selectedSource = ref('')
const remarks = ref('')

// Currency data
const currencies = ref([
  { id: 1, name: 'Indian Rupees', amount: 0, type: 'D' },
  { id: 2, name: 'America (United States Dollar)', amount: 0, type: 'D' },
])

// Source options based on payment type
const sourceOptions = computed(() => {
  if (selectedPaymentType.value === 'counter') {
    return [
      { value: 'counter1', label: 'Counter 1' },
      { value: 'counter2', label: 'Counter 2' },
      { value: 'counter3', label: 'Counter 3' },
    ]
  } else if (selectedPaymentType.value === 'account') {
    return [
      { value: 'account1', label: 'Account 1' },
      { value: 'account2', label: 'Account 2' },
      { value: 'account3', label: 'Account 3' },
    ]
  }
  return []
})

// Event handlers
function handleBack(): void {
  console.log('Back button clicked')
  // Add your back logic here
}

function handleSave(): void {
  console.log('Save button clicked')
  console.log('Form data:', {
    paymentType: selectedPaymentType.value,
    source: selectedSource.value,
    remarks: remarks.value,
    currencies: currencies.value,
  })
  // Add your save logic here
}

function handleSaveAndPrint(): void {
  console.log('Save & Print button clicked')
  // Add your save and print logic here
}

function handleSearch(): void {
  console.log('Search button clicked')
  // Add your search logic here
}

function handleClear(): void {
  console.log('Clear button clicked')
  // Reset form
  selectedPaymentType.value = null
  selectedSource.value = ''
  remarks.value = ''
  currencies.value.forEach((currency) => {
    currency.amount = 0
    currency.type = 'D'
  })
}
</script>

<style scoped>
.cash-inout-container {
  background: #ffffff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  padding: 20px;
  max-width: 100%;
  min-height: 600px;
  height: auto;
}

/* Radio Buttons Section */
.radio-section {
  margin-bottom: 24px;
}

.radio-group {
  display: flex;
  gap: 24px;
  justify-content: flex-start;
  margin-bottom: 20px;
}

.radio-label {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  font-weight: 500;
  color: #333;
}

.radio-input {
  display: none;
}

.radio-custom {
  width: 18px;
  height: 18px;
  border: 2px solid #ccc;
  border-radius: 50%;
  position: relative;
  transition: all 0.2s ease;
}

.radio-input:checked + .radio-custom {
  border-color: #007bff;
  background-color: #007bff;
}

.radio-input:checked + .radio-custom::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 6px;
  height: 6px;
  background-color: white;
  border-radius: 50%;
}

/* Input Section */
.input-section {
  margin-bottom: 24px;
}

.form-row {
  display: flex;
  align-items: flex-start;
  margin-bottom: 16px;
  gap: 16px;
}

.form-label {
  min-width: 120px;
  font-weight: 500;
  color: #333;
  padding-top: 8px;
}

.form-control-wrapper {
  flex: 1;
}

.form-select {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ced4da;
  border-radius: 6px;
  font-size: 14px;
  background-color: white;
  transition: border-color 0.2s ease;
}

.form-select:focus {
  border-color: #007bff;
  outline: none;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.form-select.disabled {
  background-color: #f8f9fa;
  color: #6c757d;
}

.form-textarea {
  width: 100%;
  padding: 8px 12px;
  border: 1px solid #ced4da;
  border-radius: 6px;
  font-size: 14px;
  resize: vertical;
  min-height: 80px;
  font-family: inherit;
}

.form-textarea:focus {
  border-color: #007bff;
  outline: none;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

/* Currency Section */
.currency-section {
  margin-bottom: 24px;
}

.section-title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin-bottom: 16px;
  padding-bottom: 8px;
  border-bottom: 2px solid #e9ecef;
}

.table-container {
  overflow-x: auto;
}

.currency-table {
  width: 100%;
  border-collapse: collapse;
  background-color: white;
  border-radius: 6px;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.currency-table th {
  background-color: #495057;
  color: white;
  padding: 12px 8px;
  text-align: left;
  font-weight: 600;
  font-size: 14px;
}

.currency-table td {
  padding: 12px 8px;
  border-bottom: 1px solid #e9ecef;
  font-size: 14px;
}

.currency-table tr:hover {
  background-color: #f8f9fa;
}

.sno-col {
  width: 80px;
  text-align: center;
}

.currency-col {
  flex: 1;
}

.amount-col {
  width: 200px;
}

.amount-input-group {
  display: flex;
  gap: 8px;
  align-items: center;
}

.amount-input {
  flex: 1;
  padding: 6px 8px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 14px;
  text-align: right;
}

.amount-input:focus {
  border-color: #007bff;
  outline: none;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.type-select {
  width: 50px;
  padding: 6px 4px;
  border: 1px solid #ced4da;
  border-radius: 4px;
  font-size: 14px;
  text-align: center;
}

.type-select:focus {
  border-color: #007bff;
  outline: none;
}

/* Action Buttons */
.action-buttons {
  display: flex;
  gap: 12px;
  justify-content: center;
  flex-wrap: wrap;
}

.btn-action {
  padding: 10px 20px;
  font-size: 14px;
  font-weight: 500;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
  background-color: #6c757d;
  color: white;
  min-width: 100px;
}

.btn-action:hover {
  background-color: #5a6268;
  transform: translateY(-1px);
}

.btn-action:active {
  transform: translateY(0);
}

/* Responsive Design */
@media (max-width: 768px) {
  .form-row {
    flex-direction: column;
    gap: 8px;
  }

  .form-label {
    min-width: auto;
    padding-top: 0;
  }

  .radio-group {
    flex-direction: column;
    gap: 12px;
  }

  .action-buttons {
    flex-direction: column;
  }

  .btn-action {
    width: 100%;
  }

  .amount-input-group {
    flex-direction: column;
    gap: 4px;
  }

  .type-select {
    width: 100%;
  }
}
</style>
