<template>
  <div class="table-wrapper">
    <table class="table">
      <thead :style="{ background: headerColor }">
        <tr>
          <th class="col-serial">Serial Number</th>
          <th class="col-product">Product Name</th>
          <th class="col-code">Product Code</th>
          <th class="col-quantity">Quantity</th>
          <th class="col-rate">Rate</th>
          <th class="col-gross">Gross</th>
          <!-- Dynamic Fields -->
          <th v-for="field in dynamicFields" :key="field.FieldId" class="col-dynamic">
            {{ field.FieldName }}
          </th>
          <th class="col-nett">Nett</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(item, index) in tableItems" :key="item.id" class="table-row">
          <td class="col-serial">{{ index + 1 }}</td>
          <td class="col-product">{{ item.productName }}</td>
          <td class="col-code">{{ item.productCode }}</td>
          <td class="col-quantity">
            <div class="quantity-controls">
              <button @click="decreaseQuantity(item)" class="qty-btn">-</button>
              <span class="qty-value">{{ item.quantity }}</span>
              <button @click="increaseQuantity(item)" class="qty-btn">+</button>
            </div>
          </td>
          <td class="col-rate">₹{{ item.rate.toFixed(2) }}</td>
          <td class="col-gross">₹{{ (item.rate * item.quantity).toFixed(2) }}</td>
          <!-- Dynamic Field Inputs -->
          <td v-for="field in dynamicFields" :key="field.FieldId" class="col-dynamic">
            <input
              type="number"
              v-model="item.dynamicFields[field.FieldId]"
              class="dynamic-input"
              @input="updateItemDynamicField(item, field.FieldId)"
              min="0"
              step="0.01"
            />
          </td>
          <td class="col-nett">₹{{ calculateNett(item).toFixed(2) }}</td>
        </tr>
      </tbody>
      <tfoot :style="{ background: footerColor }">
        <tr class="summary-row">
          <td class="col-serial"></td>
          <td class="col-product"></td>
          <td class="col-code"></td>
          <td class="col-quantity">Total: {{ totalQuantity }}</td>
          <td class="col-rate"></td>
          <td class="col-gross">₹{{ totalGross.toFixed(2) }}</td>
          <!-- Dynamic Field Totals -->
          <td v-for="field in dynamicFields" :key="field.FieldId" class="col-dynamic">
            ₹{{ getDynamicFieldTotal(field.FieldId).toFixed(2) }}
          </td>
          <td class="col-nett">₹{{ totalNett.toFixed(2) }}</td>
        </tr>
      </tfoot>
    </table>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, defineEmits, onMounted } from 'vue'
import { useMainScreen } from '../../stores/posMainScreenStore'

// Props
interface TableItem {
  id: number
  productName: string
  productCode: string
  quantity: number
  rate: number
  discount: number
  dynamicFields: { [key: number]: number }
}

interface Props {
  items?: TableItem[]
  taxRate?: number
}

const props = withDefaults(defineProps<Props>(), {
  items: () => [],
  taxRate: 8.5,
})

// Emits
const emit = defineEmits(['item-updated', 'item-removed', 'totals-updated'])

// Reactive data
const tableItems = ref<TableItem[]>(props.items)

// Array of dark colors for header and footer (unused - keeping for future use)
// const darkColors = [
//   'rgb(33, 33, 33)', // Dark Gray
//   'rgb(55, 71, 79)', // Blue Gray
//   'rgb(69, 39, 160)', // Deep Purple
//   'rgb(49, 27, 146)', // Indigo
//   'rgb(27, 94, 32)', // Dark Green
//   'rgb(183, 28, 28)', // Dark Red
//   'rgb(230, 81, 0)', // Deep Orange
//   'rgb(245, 124, 0)', // Orange
//   'rgb(194, 24, 91)', // Pink
//   'rgb(156, 39, 176)', // Purple
//   'rgb(0, 96, 100)', // Teal
//   'rgb(0, 87, 255)', // Blue
//   'rgb(0, 150, 136)', // Cyan
//   'rgb(76, 175, 80)', // Green
//   'rgb(255, 152, 0)', // Amber
//   'rgb(255, 87, 34)', // Deep Orange
//   'rgb(121, 85, 72)', // Brown
//   'rgb(96, 125, 139)', // Blue Gray
//   'rgb(158, 158, 158)', // Gray
//   'rgb(244, 67, 54)', // Red
// ]

// Stable colors that don't change on every render
const headerColor = ref('')
const footerColor = ref('')

// Initialize colors on component mount
onMounted(() => {
  headerColor.value = 'rgb(76, 175, 80)' // Specific green color for header
  footerColor.value = 'rgb(76, 175, 80)' // Specific green color for footer
})

// Computed properties
const totalGross = computed(() => {
  return tableItems.value.reduce((total, item) => {
    return total + item.rate * item.quantity
  }, 0)
})

const totalDiscount = computed(() => {
  return tableItems.value.reduce((total, item) => {
    return total + item.discount
  }, 0)
})

const totalNett = computed(() => {
  return totalGross.value - totalDiscount.value
})

const totalTax = computed(() => {
  return totalNett.value * (props.taxRate / 100)
})

const grandTotal = computed(() => {
  return totalNett.value + totalTax.value
})

const totalQuantity = computed(() => {
  return tableItems.value.reduce((total, item) => {
    return total + item.quantity
  }, 0)
})

// Store for dynamic fields
const mainScreenStore = useMainScreen()

// Computed property for dynamic fields
const dynamicFields = computed(() => mainScreenStore.DynamicLineWiseField)

// Methods
function increaseQuantity(item: TableItem) {
  item.quantity++
  emit('item-updated', item)
  emit('totals-updated', {
    gross: totalGross.value,
    discount: totalDiscount.value,
    nett: totalNett.value,
    tax: totalTax.value,
    grandTotal: grandTotal.value,
  })
}

function decreaseQuantity(item: TableItem) {
  if (item.quantity > 1) {
    item.quantity--
    emit('item-updated', item)
  } else {
    // Remove item if quantity becomes 0
    const index = tableItems.value.findIndex((tableItem) => tableItem.id === item.id)
    if (index > -1) {
      tableItems.value.splice(index, 1)
      emit('item-removed', item)
    }
  }
  emit('totals-updated', {
    gross: totalGross.value,
    discount: totalDiscount.value,
    nett: totalNett.value,
    tax: totalTax.value,
    grandTotal: grandTotal.value,
  })
}

// function updateItemDiscount(item: TableItem) {
//   if (item.discount < 0) {
//     item.discount = 0
//   }
//   const maxDiscount = item.rate * item.quantity
//   if (item.discount > maxDiscount) {
//     item.discount = maxDiscount
//   }
//   emit('item-updated', item)
//   emit('totals-updated', {
//     gross: totalGross.value,
//     discount: totalDiscount.value,
//     nett: totalNett.value,
//     tax: totalTax.value,
//     grandTotal: grandTotal.value,
//   })
// }

function updateItemDynamicField(item: TableItem, fieldId: number) {
  if (item.dynamicFields[fieldId] < 0) {
    item.dynamicFields[fieldId] = 0
  }
  emit('item-updated', item)
  emit('totals-updated', {
    gross: totalGross.value,
    discount: totalDiscount.value,
    nett: totalNett.value,
    tax: totalTax.value,
    grandTotal: grandTotal.value,
  })
}

function calculateNett(item: TableItem) {
  const gross = item.rate * item.quantity
  const totalDynamicFields = Object.values(item.dynamicFields).reduce(
    (sum, value) => sum + value,
    0,
  )
  return gross - totalDynamicFields
}

function getDynamicFieldTotal(fieldId: number) {
  return tableItems.value.reduce((total, item) => {
    return total + (item.dynamicFields[fieldId] || 0)
  }, 0)
}

// Add item to table (to be called from parent)
function addItem(product: {
  ProductId: number
  ProductName: string
  ProductCode: string
  ProductRate: number
}) {
  const existingItem = tableItems.value.find((item) => item.productCode === product.ProductCode)

  if (existingItem) {
    existingItem.quantity++
  } else {
    // Initialize dynamic fields for new item
    const dynamicFields: { [key: number]: number } = {}
    mainScreenStore.DynamicLineWiseField.forEach((field) => {
      dynamicFields[field.FieldId] = 0
    })

    tableItems.value.push({
      id: product.ProductId,
      productName: product.ProductName,
      productCode: product.ProductCode,
      quantity: 1,
      rate: product.ProductRate,
      discount: 0,
      dynamicFields: dynamicFields,
    })
  }

  emit('totals-updated', {
    gross: totalGross.value,
    discount: totalDiscount.value,
    nett: totalNett.value,
    tax: totalTax.value,
    grandTotal: grandTotal.value,
  })
}

// Clear table
function clearTable() {
  tableItems.value = []
  emit('totals-updated', {
    gross: 0,
    discount: 0,
    nett: 0,
    tax: 0,
    grandTotal: 0,
  })
}

// Expose methods for parent component
defineExpose({
  addItem,
  clearTable,
  getItems: () => tableItems.value,
  getTotals: () => ({
    gross: totalGross.value,
    discount: totalDiscount.value,
    nett: totalNett.value,
    tax: totalTax.value,
    grandTotal: grandTotal.value,
  }),
})
</script>

<style scoped>
.table-wrapper {
  width: 100%;
  height: 100%;
  background: white;
  border: 1px solid #e9ecef;
  border-radius: 6px;
  overflow-x: auto; /* Only horizontal scroll on wrapper */
  overflow-y: hidden; /* No vertical scroll on wrapper */
  display: flex;
  flex-direction: column;
}

.table {
  border-collapse: collapse;
  font-size: 13px;
  table-layout: fixed;
  min-width: 1200px;
  width: max-content;
  background: white;
  height: 100%;
  display: flex;
  flex-direction: column;
  margin: 0;
}

.table thead {
  border-bottom: 2px solid #dee2e6;
  height: 40px;
  position: sticky;
  top: 0;
  z-index: 10;
  flex-shrink: 0;
}

.table tbody {
  background: white;
  flex: 1;
  overflow-y: auto; /* Vertical scroll on tbody */
  overflow-x: hidden; /* No horizontal scroll on tbody */
  min-height: 0;
  max-height: calc(100% - 80px); /* Account for thead and tfoot heights */
}

.table tfoot {
  border-top: 2px solid #dee2e6;
  height: 40px;
  position: sticky;
  bottom: 0;
  z-index: 10;
  flex-shrink: 0;
}

/* Common styles for all table cells */
.table th,
.table td {
  padding: 6px 4px;
  border-bottom: 1px solid #f1f3f4;
  vertical-align: middle;
  box-sizing: border-box;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  height: 40px;
  text-align: center;
  margin: 0;
}

/* Header specific styles */
.table th {
  text-align: center;
  font-weight: 600;
  color: #ffffff !important;
  background: inherit;
}

/* Footer specific styles */
.table tfoot td {
  color: #ffffff !important;
  background: inherit;
  font-weight: 600;
  text-align: center;
}

/* Row hover effect */
.table-row:hover {
  background: #f8f9fa;
}

/* Column width definitions - EXACTLY THE SAME FOR ALL SECTIONS */
.col-serial {
  width: 80px !important;
  min-width: 80px !important;
}

.col-product {
  width: 200px !important;
  min-width: 200px !important;
}

.col-code {
  width: 120px !important;
  min-width: 120px !important;
}

.col-quantity {
  width: 100px !important;
  min-width: 100px !important;
}

.col-rate {
  width: 100px !important;
  min-width: 100px !important;
}

.col-gross {
  width: 100px !important;
  min-width: 100px !important;
}

.col-discount {
  width: 100px !important;
  min-width: 100px !important;
}

.col-dynamic {
  width: 100px !important;
  min-width: 100px !important;
}

.col-nett {
  width: 100px !important;
  min-width: 100px !important;
  font-weight: 600;
}

/* Quantity controls */
.quantity-controls {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 4px;
}

.qty-btn {
  width: 20px;
  height: 20px;
  border: 1px solid #dee2e6;
  background: white;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 11px;
  font-weight: 600;
  transition: all 0.2s ease;
}

.qty-btn:hover {
  background: #f8f9fa;
  border-color: #007bff;
}

.qty-value {
  font-size: 13px;
  font-weight: 500;
  min-width: 20px;
  text-align: center;
}

/* Discount input */
.discount-input {
  width: 50px;
  padding: 2px 4px;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  font-size: 11px;
  text-align: center;
}

.discount-input:focus {
  border-color: #007bff;
  outline: 0;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

/* Dynamic field input */
.dynamic-input {
  width: 50px;
  padding: 2px 4px;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  font-size: 11px;
  text-align: center;
}

.dynamic-input:focus {
  border-color: #007bff;
  outline: 0;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

/* Custom scrollbar for table wrapper (horizontal) */
.table-wrapper::-webkit-scrollbar {
  height: 12px;
}

.table-wrapper::-webkit-scrollbar-track {
  background: #e9ecef;
  border-radius: 6px;
}

.table-wrapper::-webkit-scrollbar-thumb {
  background: #6c757d;
  border-radius: 6px;
  border: 2px solid #e9ecef;
}

.table-wrapper::-webkit-scrollbar-thumb:hover {
  background: #495057;
}

/* Custom scrollbar for table body (vertical) */
.table tbody::-webkit-scrollbar {
  width: 12px;
}

.table tbody::-webkit-scrollbar-track {
  background: #e9ecef;
  border-radius: 6px;
}

.table tbody::-webkit-scrollbar-thumb {
  background: #6c757d;
  border-radius: 6px;
  border: 2px solid #e9ecef;
}

.table tbody::-webkit-scrollbar-thumb:hover {
  background: #495057;
}

/* Firefox scrollbar */
.table-wrapper {
  scrollbar-width: auto;
  scrollbar-color: #6c757d #e9ecef;
}

.table tbody {
  scrollbar-width: auto;
  scrollbar-color: #6c757d #e9ecef;
}

/* Responsive design */
@media (max-width: 1200px) {
  .table {
    font-size: 12px;
    min-width: 700px;
  }

  .table th,
  .table td {
    padding: 8px 6px;
  }
}

@media (max-width: 768px) {
  .table-wrapper {
    border-radius: 0;
  }

  .table {
    font-size: 11px;
    min-width: 600px;
  }

  .table th,
  .table td {
    padding: 6px 4px;
  }

  .qty-btn {
    width: 20px;
    height: 20px;
    font-size: 10px;
  }

  .discount-input {
    width: 50px;
    font-size: 11px;
  }
}

@media (max-width: 576px) {
  .table {
    min-width: 500px;
  }
}
</style>
