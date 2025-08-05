<template>
  <div class="container-fluid pos-main-screen d-flex flex-column p-0 vh-100">
    <!-- Header Row -->
    <div class="row flex-shrink-0 header-row align-items-center" style="height: 40px">
      <div class="col d-flex align-items-center justify-content-start gap-2" style="height: 40px">
        <h2 class="mb-0 pos-font-bold" style="font-size: 1.5rem; line-height: 40px; height: 40px">
          Focus
        </h2>
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
        <span title="Shortcut" @click="handleShortcutClick" style="cursor: pointer">
          <img
            src="https://cdn-icons-png.flaticon.com/512/1946/1946429.png"
            alt="Shortcut"
            style="width: 22px; height: 22px"
          />
        </span>
        <span
          title="Member"
          @click="showMemberPopup"
          ref="memberIconRef"
          style="cursor: pointer; position: relative"
        >
          <img
            src="https://cdn-icons-png.flaticon.com/512/1946/1946429.png"
            alt="Member"
            style="width: 22px; height: 22px"
          />
        </span>
        <span
          title="Employee"
          @click="showEmployeePopup"
          ref="employeeIconRef"
          style="cursor: pointer; position: relative"
        >
          <img
            src="https://cdn-icons-png.flaticon.com/512/1077/1077114.png"
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
            <input type="text" class="form-control" placeholder="Search Barcode..." />
          </div>
          <div class="col">
            <input type="text" class="form-control" placeholder="Search Product..." />
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
              <template v-if="showFooterShortcut">
                <div style="height: 100%; min-height: 0; display: flex; flex-direction: column">
                  <posMainScreenFooterShortcut
                    :selectedButton="selectedFooterBtn"
                    style="height: 100%; min-height: 0"
                  />
                </div>
              </template>
              <template v-else-if="showProductSection">
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
              <template v-else-if="showShortcutScreen">
                <div style="height: 100%; min-height: 0; display: flex; flex-direction: column">
                  <!-- Dynamic Screen Content -->
                  <div class="shortcut-screen-container">
                    <!-- Cash In-Pay Details Screen -->
                    <div v-if="selectedShortcutScreen === 'cash-in-pay'" class="screen-content">
                      <posCashInOutColl />
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

    <!-- Member Info Popup -->
    <posMemberPopup
      :isVisible="showMemberInfoPopup"
      :memberId="selectedMemberId"
      :position="popupPosition"
      @close="closeMemberPopup"
      @select-member="handleMemberSelect"
      @edit-member="handleMemberEdit"
    />

    <!-- Employee Info Popup -->
    <posEmployeePopup
      :isVisible="showEmployeeInfoPopup"
      :employeeId="selectedEmployeeId"
      :position="employeePopupPosition"
      @close="closeEmployeePopup"
      @select-employee="handleEmployeeSelect"
      @edit-employee="handleEmployeeEdit"
    />

    <!-- Cash In/Out Collection Modal -->
    <div v-if="showCashInOutModal" class="modal-overlay" @click="closeCashInOutModal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h5 class="modal-title">Cash In/Out Collection</h5>
          <button type="button" class="btn-close" @click="closeCashInOutModal">
            <span>&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <posCashInOutColl
            :initial-date="new Date()"
            :initial-calendar-type="'gregorian'"
            :show-events="true"
            @date-selected="handleDateSelected"
            @calendar-type-changed="handleCalendarTypeChanged"
          />
        </div>
      </div>
    </div>

    <!-- Shortcut Panel Modal -->
    <div v-if="showShortcutModal" class="modal-overlay" @click="closeShortcutModal">
      <div class="modal-content shortcut-modal" @click.stop>
        <div class="modal-header">
          <h5 class="modal-title">Shortcut Panel</h5>
          <button type="button" class="btn-close" @click="closeShortcutModal">
            <span>&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <posShortcutPanel @screen-selected="handleShortcutScreenSelected" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, nextTick, computed } from 'vue'
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
import posMemberPopup from '../posTemplate/posMemberPopup.vue'
import posEmployeePopup from '../posTemplate/posEmployeePopup.vue'
import posCashInOutColl from '../posTemplate/posCashInOutColl.vue'
import posShortcutPanel from '../posTemplate/posShortcutPanel.vue'

const selectedFooterBtn = ref('')
const selectedProductGroup = ref<{ ProductGroupId: number; ProductGroupText: string } | null>(null)
import type { Product } from '../posDataStruct/posProduct'
const selectedProducts = ref<Product[]>([])

// Left panel component reference
const leftPanelComponent = ref()
// Product group component reference
const productGroupComponent = ref()

// Member popup state
const showMemberInfoPopup = ref(false)
const selectedMemberId = ref<string | number>('')
const popupPosition = ref({ x: 0, y: 0 })
const memberIconRef = ref<HTMLElement>()

// Employee popup state
const showEmployeeInfoPopup = ref(false)
const selectedEmployeeId = ref<string | number>('')
const employeePopupPosition = ref({ x: 0, y: 0 })
const employeeIconRef = ref<HTMLElement>()

// Cash In/Out Collection modal state
const showCashInOutModal = ref(false)

// Shortcut Panel modal state
const showShortcutModal = ref(false)

// Shortcut screen state
const selectedShortcutScreen = ref<string>('default')

// Computed property to determine which section to show
const showProductSection = computed(() => !selectedFooterBtn.value && !selectedShortcutScreen.value)
const showFooterShortcut = computed(() => !!selectedFooterBtn.value)
const showShortcutScreen = computed(() => !!selectedShortcutScreen.value)

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

// Function to load first product group data
async function loadFirstProductGroup() {
  const firstProductGroup = {
    ProductGroupId: 1,
    ProductGroupText: 'Electronics',
  }
  selectedProductGroup.value = firstProductGroup

  // Load the first product group's data
  const products = productDataMap[firstProductGroup.ProductGroupText as keyof typeof productDataMap]
  selectedProducts.value = products || []

  // Wait for next tick to ensure child components are mounted
  await nextTick()

  // Call selectFirstGroup on the ProductGroup component to highlight the button
  if (productGroupComponent.value) {
    console.log('Calling selectFirstGroup on product group component')
    try {
      productGroupComponent.value.selectFirstGroup()
      console.log('selectFirstGroup called successfully')
    } catch (error) {
      console.error('Error calling selectFirstGroup:', error)
    }
  } else {
    console.warn('productGroupComponent.value is null - component may not be mounted yet')
  }

  console.log('Auto-loaded Electronics with', selectedProducts.value.length, 'products')
}

// Auto-load first product group when component mounts
onMounted(async () => {
  console.log('POS Main Screen mounted')

  // Wait for child components to be fully mounted
  await nextTick()

  // Add a small delay to ensure all child components are ready
  setTimeout(async () => {
    console.log('Loading first product group...')
    await loadFirstProductGroup()
  }, 200)
})

function handleFooterBtnClick(btn: string) {
  selectedFooterBtn.value = btn
}

function handleHomeClick() {
  selectedFooterBtn.value = ''
  loadFirstProductGroup()
  showCashInOutModal.value = true
}

function handleShortcutClick() {
  showShortcutModal.value = true
}

function closeShortcutModal() {
  showShortcutModal.value = false
}

function handleShortcutScreenSelected(screenId: string): void {
  selectedShortcutScreen.value = screenId
  showShortcutModal.value = false
  console.log('Shortcut screen selected:', screenId)
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
function handleItemUpdated(item: {
  ProductId: number
  ProductName: string
  ProductCode: string
  ProductRate: number
  quantity: number
  discount: number
}) {
  console.log('Item updated in left panel:', item)
}

function handleItemRemoved(item: {
  ProductId: number
  ProductName: string
  ProductCode: string
  ProductRate: number
  quantity: number
  discount: number
}) {
  console.log('Item removed from left panel:', item)
}

function handleTotalsUpdated(totals: {
  totalQuantity: number
  totalGross: number
  totalDiscount: number
  totalNett: number
}) {
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

// Member popup methods
function showMemberPopup() {
  if (memberIconRef.value) {
    const rect = memberIconRef.value.getBoundingClientRect()
    popupPosition.value = {
      x: rect.left + rect.width / 2,
      y: rect.bottom + 10, // 10px below the icon
    }
  }
  selectedMemberId.value = 'M001' // Default member ID - you can make this dynamic
  showMemberInfoPopup.value = true
}

function closeMemberPopup() {
  showMemberInfoPopup.value = false
}

function handleMemberSelect(memberId: string | number) {
  console.log('Selected member:', memberId)
  // Handle member selection logic here
  // For example, you could set the selected member in your POS system
}

function handleMemberEdit(memberId: string | number) {
  console.log('Edit member:', memberId)
  // Handle member edit logic here
  // For example, open a member edit form
}

// Employee popup methods
function showEmployeePopup() {
  if (employeeIconRef.value) {
    const rect = employeeIconRef.value.getBoundingClientRect()
    employeePopupPosition.value = {
      x: rect.left + rect.width / 2,
      y: rect.bottom + 10, // 10px below the icon
    }
  }
  selectedEmployeeId.value = 'E001' // Default employee ID - you can make this dynamic
  showEmployeeInfoPopup.value = true
}

function closeEmployeePopup() {
  showEmployeeInfoPopup.value = false
}

function handleEmployeeSelect(employeeId: string | number) {
  console.log('Selected employee:', employeeId)
  // Handle employee selection logic here
  // For example, you could set the selected employee in your POS system
}

function handleEmployeeEdit(employeeId: string | number) {
  console.log('Edit employee:', employeeId)
  // Handle employee edit logic here
  // For example, open an employee edit form
}

// Cash In/Out Collection modal methods
function closeCashInOutModal() {
  showCashInOutModal.value = false
}

function handleDateSelected(date: Date, calendarType: string, formattedDate: string) {
  console.log('Date selected:', date, calendarType, formattedDate)
  // Handle date selection logic here
}

function handleCalendarTypeChanged(calendarType: string) {
  console.log('Calendar type changed:', calendarType)
  // Handle calendar type change logic here
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

/* Modal styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1050;
}

.modal-content {
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
  width: 90%;
  max-width: 800px;
  max-height: 90vh;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid #e9ecef;
  background: #f8f9fa;
}

.modal-title {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 600;
  color: #495057;
}

.btn-close {
  background: none;
  border: none;
  font-size: 1.5rem;
  font-weight: bold;
  color: #6c757d;
  cursor: pointer;
  padding: 0;
  width: 30px;
  height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  transition: background-color 0.2s;
}

.btn-close:hover {
  background-color: #e9ecef;
  color: #495057;
}

.modal-body {
  padding: 20px;
  flex: 1;
  overflow: auto;
}

.shortcut-modal {
  width: 95%;
  max-width: 1200px;
  max-height: 95vh;
}

.shortcut-screen-container {
  height: 100%;
  overflow: auto;
  padding: 20px;
}

.screen-content {
  width: 100%;
  height: 100%;
}

.calendar-section {
  max-width: 600px;
  margin: 0 auto;
}

.section-title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin-bottom: 16px;
  padding-bottom: 8px;
  border-bottom: 2px solid #e9ecef;
}

.font-test-section {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 20px;
  border: 1px solid #e9ecef;
}

.default-screen {
  text-align: center;
  padding: 40px 20px;
}

.welcome-text {
  font-size: 16px;
  color: #666;
  margin-bottom: 24px;
  line-height: 1.6;
}

.feature-list {
  text-align: left;
  max-width: 500px;
  margin: 0 auto;
  background: #f8f9fa;
  border-radius: 8px;
  padding: 20px;
  border: 1px solid #e9ecef;
}

.feature-list h4 {
  color: #333;
  margin-bottom: 12px;
  font-weight: 600;
}

.feature-list ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.feature-list li {
  padding: 8px 0;
  border-bottom: 1px solid #e9ecef;
  color: #555;
  position: relative;
  padding-left: 20px;
}

.feature-list li:before {
  content: '✓';
  position: absolute;
  left: 0;
  color: #28a745;
  font-weight: bold;
}

.feature-list li:last-child {
  border-bottom: none;
}
</style>
