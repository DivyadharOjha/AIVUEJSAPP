<template>
  <div class="left-panel-footer">
    <!-- Row 1 -->
    <div class="row mb-2">
      <div class="col-6">
        <div class="form-group">
          <label class="form-label">Total Product Count</label>
          <input
            type="text"
            class="form-control form-control-sm"
            v-model="totalProductCount"
            readonly
          />
        </div>
      </div>
      <div class="col-6">
        <div class="form-group">
          <label class="form-label">Total Product Quantity</label>
          <input
            type="text"
            class="form-control form-control-sm"
            v-model="totalProductQuantity"
            readonly
          />
        </div>
      </div>
    </div>

    <!-- Row 2 -->
    <div class="row mb-2">
      <div class="col-6">
        <div class="form-group">
          <label class="form-label">Discount Amount</label>
          <input
            type="text"
            class="form-control form-control-sm"
            v-model="discountAmount"
            readonly
          />
        </div>
      </div>
      <div class="col-6">
        <div class="form-group">
          <label class="form-label">Schemes Amount</label>
          <input
            type="text"
            class="form-control form-control-sm"
            v-model="schemesAmount"
            readonly
          />
        </div>
      </div>
    </div>

    <!-- Row 3 -->
    <div class="row mb-2">
      <div class="col-12">
        <div class="form-group">
          <label class="form-label">Taxable Amount</label>
          <input
            type="text"
            class="form-control form-control-sm"
            v-model="taxableAmount"
            readonly
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, defineEmits, defineProps } from 'vue'

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
}

.form-group {
  margin-bottom: 10px;
}

.form-label {
  font-size: 11px;
  font-weight: 600;
  color: #495057;
  margin-bottom: 4px;
  text-transform: uppercase;
}

.form-control {
  font-size: 12px;
  padding: 6px 8px;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  background-color: #fff;
  color: #495057;
}

.form-control:focus {
  border-color: #007bff;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
  outline: 0;
}

.form-control-sm {
  height: 28px;
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
    height: 24px;
    font-size: 10px;
  }
}
</style>
