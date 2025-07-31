<template>
  <div class="container-fluid pos-main-screen d-flex flex-column p-0 vh-100">
    <!-- Header Row -->
    <div class="row flex-shrink-0 header-row align-items-center" style="height: 40px">
      <div class="col d-flex align-items-center justify-content-start gap-2" style="height: 40px">
        <h2 class="mb-0" style="font-size: 1.5rem; line-height: 40px; height: 40px">Focus</h2>
        <img
          src="https://www.focussoftnet.com/focus-logo-white-new.png"
          alt="Focus POS"
          style="height: 35px; width: 110px"
        />
      </div>
      <div class="col d-flex justify-content-end align-items-center gap-3" style="height: 40px">
        <span title="Home" @click="handleHomeClick" style="cursor: pointer">
          <img
            src="https://cdn-icons-png.flaticon.com/512/1946/1946488.png"
            alt="Home"
            style="width: 22px; height: 22px"
          />
        </span>
        <span title="Member">
          <img
            src="https://cdn-icons-png.flaticon.com/512/1946/1946429.png"
            alt="Member"
            style="width: 22px; height: 22px"
          />
        </span>
        <span title="Employee">
          <img
            src="https://cdn-icons-png.flaticon.com/512/1946/1946406.png"
            alt="Employee"
            style="width: 22px; height: 22px"
          />
        </span>
        <span title="Setting">
          <img
            src="https://cdn-icons-png.flaticon.com/512/2099/2099058.png"
            alt="Setting"
            style="width: 22px; height: 22px"
          />
        </span>
        <span title="Logout">
          <img
            src="https://cdn-icons-png.flaticon.com/512/1828/1828479.png"
            alt="Logout"
            style="width: 22px; height: 22px"
          />
        </span>
      </div>
    </div>

    <!-- Body Row -->
    <div class="row flex-grow-1 body-row align-items-stretch body-row-gap" style="min-height: 0">
      <div class="col body-col h-100 me-3">
        <!-- Left body content -->
        <posMainScreenLeftPanel
          ref="leftPanelComponent"
          @item-updated="handleItemUpdated"
          @item-removed="handleItemRemoved"
          @totals-updated="handleTotalsUpdated"
        />
      </div>
      <div
        class="col body-col h-100 d-flex flex-column"
        style="min-width: 0; flex: 1; height: 100%; min-height: 0"
      >
        <!-- Right body content -->
        <div class="row mb-2 align-items-center" style="height: 40px; min-height: 0">
          <!-- Top row content -->
          <div class="col">
            <input type="text" class="form-control" placeholder="Textbox 1" />
          </div>
          <div class="col">
            <input type="text" class="form-control" placeholder="Textbox 2" />
          </div>
        </div>
        <div class="row flex-grow-1" style="height: calc(100% - 40px); min-height: 0">
          <!-- Bottom row content -->
          <div class="col h-100" style="min-height: 0">
            <div
              id="divPOSMainScreenBodyLeftPanelSecondRow"
              style="
                width: 100%;
                height: 100%;
                border-radius: 8px;
                min-height: 0;
                display: flex;
                flex-direction: column;
              "
            >
              <template v-if="selectedFooterBtn">
                <div style="height: 100%; min-height: 0; display: flex; flex-direction: column">
                  <posMainScreenFooterShortcut
                    :selectedButton="selectedFooterBtn"
                    style="height: 100%; min-height: 0"
                  />
                </div>
              </template>
              <template v-else>
                <div class="row" style="height: 60px; flex-shrink: 0; min-height: 0">
                  <div
                    class="col-12"
                    id="divPOSMainScreenBodyLeftPanelSecondRowTop"
                    style="overflow: hidden; height: 100%; min-height: 0"
                  >
                    <posMainScreenProductGroup
                      ref="productGroupComponent"
                      :selectedGroupId="selectedProductGroup?.ProductGroupId"
                      @product-group-selected="handleProductGroupSelected"
                    />
                  </div>
                </div>
                <div class="row" style="height: calc(100% - 60px); min-height: 0">
                  <div
                    class="col-12 h-100"
                    id="divPOSMainScreenBodyLeftPanelSecondRowBottom"
                    style="min-height: 0"
                  >
                    <posMainScreenProduct
                      v-if="selectedProductGroup"
                      :group="selectedProductGroup"
                      :products="selectedProducts"
                      @product-selected="handleProductSelected"
                      style="height: 100%; min-height: 0"
                    />
                    <div v-else class="d-flex align-items-center justify-content-center h-100">
                      <p class="text-muted">Please select a product group to view products.</p>
                    </div>
                  </div>
                </div>
              </template>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Footer Row -->
    <div class="row flex-shrink-0 footer-row" style="height: 60px">
      <div class="col">
        <posMainScreenFooter @footerBtnClick="handleFooterBtnClick" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue'
import posMainScreenFooter from './posMainScreenFooter.vue'
import posMainScreenFooterShortcut from './posMainScreenFooterShortcut.vue'
import posMainScreenProductGroup from './posMainScreenProductGroup.vue'
import posMainScreenProduct from './posMainScreenProduct.vue'
import posMainScreenLeftPanel from './posMainScreenLeftPanel.vue'
import { electronicsProducts } from '../posData/electronics'
import { clothingAndApparelProducts } from '../posData/clothingAndApparel'
import { homeAndGardenProducts } from '../posData/homeAndGarden'
import { sportsAndOutdoorProducts } from '../posData/sportsAndOutdoor'
import { booksAndMediaProducts } from '../posData/booksAndMedia'
import { automotiveProducts } from '../posData/automotive'
import { healthAndBeautyProducts } from '../posData/healthAndBeauty'
import { toysAndGamesProducts } from '../posData/toysAndGames'
import { foodAndBeveragesProducts } from '../posData/foodAndBeverages'
import { officeSuppliesProducts } from '../posData/officeSupplies'

const selectedFooterBtn = ref('Member')
const selectedProductGroup = ref<{ ProductGroupId: number; ProductGroupText: string } | null>(null)
import type { Product } from '../posDataStruct/posProduct'
const selectedProducts = ref<Product[]>([])

// Left panel component reference
const leftPanelComponent = ref()
// Product group component reference
const productGroupComponent = ref()

// TypeScript interfaces for event handlers
interface TableItem {
  id: number
  productName: string
  productCode: string
  quantity: number
  rate: number
  discount: number
}

interface TotalsData {
  gross: number
  discount: number
  nett: number
  tax: number
  grandTotal: number
}

const productDataMap = {
  Electronics: electronicsProducts,
  'Clothing & Apparel': clothingAndApparelProducts,
  'Home & Garden': homeAndGardenProducts,
  'Sports & Outdoor': sportsAndOutdoorProducts,
  'Books & Media': booksAndMediaProducts,
  Automotive: automotiveProducts,
  'Health & Beauty': healthAndBeautyProducts,
  'Toys & Games': toysAndGamesProducts,
  'Food & Beverages': foodAndBeveragesProducts,
  'Office Supplies': officeSuppliesProducts,
}

// Debug logging
console.log('Product data map keys:', Object.keys(productDataMap))

// Initialize the first product group when component mounts
onMounted(() => {
  // Automatically select the first product group (Electronics)
  const firstProductGroup = {
    ProductGroupId: 1,
    ProductGroupText: 'Electronics',
  }
  selectedProductGroup.value = firstProductGroup

  // Load the first product group's data
  const products = productDataMap[firstProductGroup.ProductGroupText as keyof typeof productDataMap]
  selectedProducts.value = products || []

  // Call selectFirstGroup on the ProductGroup component to highlight the button
  // Use nextTick to ensure the component is fully mounted
  nextTick(() => {
    if (productGroupComponent.value) {
      productGroupComponent.value.selectFirstGroup()
    }
  })

  console.log(
    'Component mounted - Auto-selected Electronics with',
    selectedProducts.value.length,
    'products',
  )
})

function handleFooterBtnClick(btn: string) {
  selectedFooterBtn.value = btn
}

function handleHomeClick() {
  selectedFooterBtn.value = ''
  // Automatically select the first product group (Electronics)
  const firstProductGroup = {
    ProductGroupId: 1,
    ProductGroupText: 'Electronics',
  }
  selectedProductGroup.value = firstProductGroup

  // Load the first product group's data
  const products = productDataMap[firstProductGroup.ProductGroupText as keyof typeof productDataMap]
  selectedProducts.value = products || []

  // Call selectFirstGroup on the ProductGroup component to highlight the button
  if (productGroupComponent.value) {
    productGroupComponent.value.selectFirstGroup()
  }

  console.log(
    'Home clicked - Auto-selected Electronics with',
    selectedProducts.value.length,
    'products',
  )
}

function handleProductGroupSelected(group: { ProductGroupId: number; ProductGroupText: string }) {
  console.log('Product group selected:', group)
  selectedProductGroup.value = group

  // Get products from the data map with type safety
  const products = productDataMap[group.ProductGroupText as keyof typeof productDataMap]
  selectedProducts.value = products || []

  console.log(
    `Loaded ${selectedProducts.value.length} products for group: ${group.ProductGroupText}`,
  )
}

function handleProductSelected(product: Product) {
  console.log('Product selected:', product)
  // Add the selected product to the left panel table
  addProductToLeftPanel(product)
}

// Left panel event handlers
function handleItemUpdated(item: TableItem) {
  console.log('Item updated in left panel:', item)
}

function handleItemRemoved(item: TableItem) {
  console.log('Item removed from left panel:', item)
}

function handleTotalsUpdated(totals: TotalsData) {
  console.log('Totals updated in left panel:', totals)
}

// Method to add product to left panel table
function addProductToLeftPanel(product: Product) {
  if (leftPanelComponent.value) {
    leftPanelComponent.value.addToTable({
      ProductId: product.ProductId,
      ProductName: product.ProductName,
      ProductCode: product.ProductCode,
      ProductRate: product.ProductRate,
    })
  }
}
</script>

<style scoped>
.body-row-gap > .col:not(:last-child) {
  margin-right: 15px;
}
.pos-main-screen {
  display: flex;
  flex-direction: column;
  height: 100vh;
  width: 100vw;
  position: fixed;
  top: 0;
  left: 0;
  background: transparent !important;
  overflow: hidden;
  box-sizing: border-box;
  padding: 10px;
}
.header-row {
  padding: 10px !important;
}
.body-row {
  padding: 15px !important;
  flex: 1 1 auto;
  min-height: 0;
  display: flex;
}
.footer-row {
  padding: 10px !important;
}
.body-col {
  border: 1px solid gray !important;
  border-radius: 6px;
  background: #fff;
  padding: 10px;
  height: 100%;
  box-sizing: border-box;
  min-width: 0;
  flex-shrink: 0;
}
</style>
