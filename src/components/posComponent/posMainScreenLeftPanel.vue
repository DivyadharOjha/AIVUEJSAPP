<template>
  <div class="left-panel">
    <!-- Bootstrap Rows Container -->
    <div class="rows-container">
      <!-- First Row - Table Component (60% height) -->
      <div class="row first-row">
        <div class="col-12">
          <posMainScreenLeftPanelTable
            ref="tableComponent"
            @item-updated="handleItemUpdated"
            @item-removed="handleItemRemoved"
            @totals-updated="handleTotalsUpdated"
          />
        </div>
      </div>

      <!-- Second Row - Footer Component (40% height) -->
      <div class="row second-row">
        <div class="col-12">
          <posMainScreenLeftPanelFooter
            ref="footerComponent"
            :total-product-count="totalProductCount"
            :total-product-quantity="totalProductQuantity"
            :discount-amount="totalDiscount"
            :schemes-amount="schemesAmount"
            :taxable-amount="taxableAmount"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import posMainScreenLeftPanelTable from './posMainScreenLeftPanelTable.vue'
import posMainScreenLeftPanelFooter from './posMainScreenLeftPanelFooter.vue'

// Table component reference
const tableComponent = ref()

// Footer component reference
const footerComponent = ref()

// Reactive data for footer component
const totalProductCount = ref(0)
const totalProductQuantity = ref(0)
const totalDiscount = ref(0)
const schemesAmount = ref(0)
const taxableAmount = ref(0)

// Interface for table item
interface TableItem {
  id: number
  productName: string
  productCode: string
  quantity: number
  rate: number
  discount: number
}

// Interface for totals
interface TableTotals {
  gross: number
  discount: number
  nett: number
  tax: number
  grandTotal: number
}

// Methods for table component events
function handleItemUpdated(item: TableItem) {
  console.log('Item updated:', item)
  updateFooterData()
}

function handleItemRemoved(item: TableItem) {
  console.log('Item removed:', item)
  updateFooterData()
}

function handleTotalsUpdated(totals: TableTotals) {
  console.log('Totals updated:', totals)
  updateFooterData()
}

function updateFooterData() {
  if (tableComponent.value) {
    const items = tableComponent.value.getItems()
    const totals = tableComponent.value.getTotals()

    totalProductCount.value = items.length
    totalProductQuantity.value = items.reduce(
      (sum: number, item: TableItem) => sum + item.quantity,
      0,
    )
    totalDiscount.value = totals.discount
    schemesAmount.value = 0 // Can be updated based on business logic
    taxableAmount.value = totals.nett
  }
}

// Add item to table (to be called from parent)
function addToTable(product: {
  ProductId: number
  ProductName: string
  ProductCode: string
  ProductRate: number
}) {
  if (tableComponent.value) {
    tableComponent.value.addItem(product)
  }
}

// Clear table
function clearTable() {
  if (tableComponent.value) {
    tableComponent.value.clearTable()
  }
}

// Expose methods for parent component
defineExpose({
  addToTable,
  clearTable,
  getTableItems: () => tableComponent.value?.getItems() || [],
  getTableTotals: () => tableComponent.value?.getTotals() || {},
})
</script>

<style scoped>
.left-panel {
  width: 100%;
  height: 100%;
  background: #f8f9fa;
  border-right: 1px solid #e9ecef;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.rows-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.first-row {
  height: 60%;
  min-height: 0;
}

.second-row {
  height: 40%;
  min-height: 0;
}

/* Responsive design */
@media (max-width: 768px) {
  .left-panel {
    height: auto;
    border-right: none;
    border-bottom: 1px solid #e9ecef;
  }
}
</style>
