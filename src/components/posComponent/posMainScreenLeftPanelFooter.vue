<template>
  <div class="left-panel-footer">
    <!-- Row 1 -->
    <div class="row mb-2 h-100">
      <div class="col-3 h-100">
        <label class="form-label">Total Product Count</label>
      </div>
      <div class="col-3 h-100">
        <input
          type="text"
          class="form-control form-control-sm h-100"
          v-model="totalProductCount"
          readonly
        />
      </div>
      <div class="col-3 h-100">
        <label class="form-label">Total Product Quantity</label>
      </div>
      <div class="col-3 h-100">
        <input
          type="text"
          class="form-control form-control-sm h-100"
          v-model="totalProductQuantity"
          readonly
        />
      </div>
    </div>

    <!-- Dynamic Fields Row -->
    <div v-for="(field, index) in dynamicFields" :key="field.FieldId" class="row mb-2 h-100">
      <div class="col-3 h-100">
        <label class="form-label">{{ field.FieldName }}</label>
      </div>
      <div class="col-3 h-100">
        <input
          type="text"
          class="form-control form-control-sm h-100"
          :value="getDynamicFieldValue(field.FieldId)"
          readonly
        />
      </div>
      <div class="col-3 h-100">
        <label class="form-label"></label>
      </div>
      <div class="col-3 h-100">
        <input type="text" class="form-control form-control-sm h-100" readonly />
      </div>
    </div>

    <!-- Row 3 -->
    <div class="row mb-2 h-100">
      <div class="col-3 h-100">
        <label class="form-label">Taxable Amount</label>
      </div>
      <div class="col-3 h-100">
        <input
          type="text"
          class="form-control form-control-sm h-100"
          v-model="taxableAmount"
          readonly
        />
      </div>
      <div class="col-3 h-100">
        <label class="form-label"></label>
      </div>
      <div class="col-3 h-100">
        <input type="text" class="form-control form-control-sm h-100" readonly />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, defineEmits, defineProps, computed } from 'vue'
import { useMainScreen } from '../../stores/posMainScreenStore'

// Props
interface Props {
  totalProductCount?: number
  totalProductQuantity?: number
  discountAmount?: number
  schemesAmount?: number
  taxableAmount?: number
}

const props = withDefaults(defineProps<Props>(), {
  totalProductCount: 0,
  totalProductQuantity: 0,
  discountAmount: 0,
  schemesAmount: 0,
  taxableAmount: 0,
})

// Emits
const emit = defineEmits([
  'update:totalProductCount',
  'update:totalProductQuantity',
  'update:discountAmount',
  'update:schemesAmount',
  'update:taxableAmount',
])

// Store for dynamic fields
const mainScreenStore = useMainScreen()

// Computed property for dynamic fields
const dynamicFields = computed(() => mainScreenStore.DynamicLineWiseField)

// Reactive data
const totalProductCount = ref(props.totalProductCount)
const totalProductQuantity = ref(props.totalProductQuantity)
const discountAmount = ref(props.discountAmount)
const schemesAmount = ref(props.schemesAmount)
const taxableAmount = ref(props.taxableAmount)

// Watch for prop changes
import { watch } from 'vue'

watch(
  () => props.totalProductCount,
  (newValue) => {
    totalProductCount.value = newValue
  },
)

watch(
  () => props.totalProductQuantity,
  (newValue) => {
    totalProductQuantity.value = newValue
  },
)

watch(
  () => props.discountAmount,
  (newValue) => {
    discountAmount.value = newValue
  },
)

watch(
  () => props.schemesAmount,
  (newValue) => {
    schemesAmount.value = newValue
  },
)

watch(
  () => props.taxableAmount,
  (newValue) => {
    taxableAmount.value = newValue
  },
)

// Function to get dynamic field value (placeholder - would need table data)
function getDynamicFieldValue(fieldId: number): number {
  // This would need to be connected to the table data
  // For now, returning 0 as placeholder
  return 0
}

// Expose methods for parent component
defineExpose({
  updateTotalProductCount: (value: number) => {
    totalProductCount.value = value
    emit('update:totalProductCount', value)
  },
  updateTotalProductQuantity: (value: number) => {
    totalProductQuantity.value = value
    emit('update:totalProductQuantity', value)
  },
  updateDiscountAmount: (value: number) => {
    discountAmount.value = value
    emit('update:discountAmount', value)
  },
  updateSchemesAmount: (value: number) => {
    schemesAmount.value = value
    emit('update:schemesAmount', value)
  },
  updateTaxableAmount: (value: number) => {
    taxableAmount.value = value
    emit('update:taxableAmount', value)
  },
})
</script>

<style scoped>
.left-panel-footer {
  padding: 15px;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
  height: 100%;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  min-height: 0;
}

.left-panel-footer .row {
  height: 33.33%;
  display: flex;
  align-items: center;
  margin-bottom: 0;
}

.left-panel-footer .col-3 {
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.form-label {
  font-size: 11px;
  font-weight: 600;
  color: #495057;
  margin-bottom: 4px;
  text-transform: uppercase;
  display: block;
  text-align: center;
}

.form-control {
  font-size: 12px;
  padding: 6px 8px;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  background-color: #fff;
  color: #495057;
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.form-control:focus {
  border-color: #007bff;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
  outline: 0;
}

.form-control-sm {
  height: 100%;
  font-size: 11px;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .left-panel-footer {
    padding: 10px;
  }

  .form-label {
    font-size: 10px;
  }

  .form-control-sm {
    font-size: 10px;
  }
}

@media (max-width: 576px) {
  .left-panel-footer {
    padding: 8px;
  }

  .form-control-sm {
    font-size: 9px;
  }

  .form-label {
    font-size: 9px;
  }
}
</style>
