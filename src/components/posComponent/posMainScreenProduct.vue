<template>
  <div class="product-main-screen h-100 d-flex flex-column" style="min-height: 0; overflow: hidden">
    <div
      v-if="hasProducts"
      class="flex-grow-1 d-flex flex-column h-100"
      style="min-height: 0; overflow: hidden"
    >
      <div
        class="container-fluid h-100 p-0 d-flex flex-column"
        style="min-height: 0; overflow: hidden"
      >
        <div class="row flex-grow-1" style="min-height: 0; overflow: hidden">
          <div class="col-12 h-100" style="min-height: 0; overflow: hidden">
            <div
              id="divRightPanelProduct"
              ref="divRightPanelProduct"
              class="product-grid-container"
              :style="productGridStyle"
            >
              <div v-for="(row, rowIndex) in productGrid" :key="rowIndex" class="product-row">
                <div v-for="(product, colIndex) in row" :key="colIndex" class="product-col">
                  <div
                    :class="[
                      'card',
                      'product-card',
                      'w-100',
                      'h-100',
                      'd-flex',
                      'flex-column',
                      { 'product-card-compact': products.length > 20 },
                    ]"
                    style="height: 100%; min-height: 0; margin: 0"
                  >
                    <div
                      class="row g-0 flex-column h-100"
                      style="height: 100%; min-height: 0; width: 100%"
                    >
                      <!-- Product Image -->
                      <div
                        class="col-12 d-flex justify-content-center align-items-center product-img-row"
                      >
                        <img
                          :src="
                            product.ProductImage ||
                            'https://via.placeholder.com/80x80?text=No+Image'
                          "
                          :alt="product.ProductName"
                          class="product-img"
                          @error="onImgError"
                        />
                      </div>
                      <!-- Product Name -->
                      <div class="col-12 text-center product-name-row">
                        <span class="product-name">{{ product.ProductName }}</span>
                      </div>
                      <!-- Product Quantity and Rate in single row -->
                      <div
                        class="col-12 d-flex justify-content-between align-items-center product-qty-rate-row"
                      >
                        <span class="product-qty-value">{{ product.ProductQuantity }}</span>
                        <span class="product-rate">₹{{ product.ProductRate.toFixed(2) }}</span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <posPageNavigation
          v-if="products.length > 16"
          :current-page="currentPage"
          :total-pages="totalPages"
          :total-records="products.length"
          @first-click="firstPage"
          @previous-click="prevPage"
          @next-click="nextPage"
          @last-click="lastPage"
        />
      </div>
    </div>
    <div
      v-else
      class="product-list-placeholder flex-grow-1 d-flex align-items-center justify-content-center"
      style="min-height: 40px; overflow: auto"
    >
      <p>No products to display yet.</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, onMounted, watch, nextTick } from 'vue'
import type { Product } from '../posDataStruct/posProduct'
import posPageNavigation from '../posTemplate/posPageNavigation.vue'

const props = defineProps<{ products: Product[] }>()
const products = props.products
const hasProducts = computed(() => products && products.length > 0)

// Debug logging for products
console.log('posMainScreenProduct - Received products:', products)
console.log('posMainScreenProduct - Products length:', products?.length)
console.log('posMainScreenProduct - hasProducts:', hasProducts.value)
const currentPage = ref(1)
const pageSize = 16
const totalPages = computed(() => Math.ceil((products?.length || 0) / pageSize))

// Compute a 2D array for the product grid (4 rows x 4 columns)
const productGrid = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  const pageProducts = products?.slice(start, start + pageSize) || []

  console.log('productGrid computed - products length:', products?.length)
  console.log('productGrid computed - currentPage:', currentPage.value)
  console.log('productGrid computed - start:', start)
  console.log('productGrid computed - pageProducts length:', pageProducts.length)
  console.log('productGrid computed - first page product:', pageProducts[0])

  const grid: Product[][] = []
  for (let i = 0; i < 4; i++) {
    const row: Product[] = []
    for (let j = 0; j < 4; j++) {
      const product = pageProducts[i * 4 + j]
      if (product) {
        row.push(product)
      }
    }
    grid.push(row)
  }

  console.log('productGrid computed - grid created with rows:', grid.length)
  return grid
})

// Dynamic height calculation for divRightPanelProduct
const divRightPanelProduct = ref<HTMLElement | null>(null)
const paginationVisible = computed(() => {
  const shouldShow = products.length >= 16
  console.log('Pagination check:', { productsLength: products.length, shouldShow })
  return shouldShow
})
function setProductGridHeight() {
  nextTick(() => {
    const parent = divRightPanelProduct.value?.parentElement
    if (parent && divRightPanelProduct.value) {
      //const parentHeight = parent.clientHeight
      //const paginationHeight = paginationVisible.value ? 48 : 0 // Increased for pageNavigation component
      //const containerPadding = 16 // 8px top + 8px bottom
      //const availableHeight = parentHeight - paginationHeight - containerPadding
      //divRightPanelProduct.value.style.height = `${Math.max(availableHeight, 300)}px`
    }
  })
}
onMounted(setProductGridHeight)
watch([() => products.length, paginationVisible], setProductGridHeight)

// Watch for products changes
watch(
  () => products,
  (newProducts) => {
    console.log('posMainScreenProduct - Products changed:', newProducts)
    console.log('posMainScreenProduct - New products length:', newProducts?.length)
    console.log('posMainScreenProduct - First product:', newProducts?.[0])
    console.log('posMainScreenProduct - hasProducts computed:', hasProducts.value)

    // Reset to first page when products change
    currentPage.value = 1
    console.log('posMainScreenProduct - Reset to page 1')
  },
  { deep: true, immediate: true },
)

const productGridStyle = computed(() => {
  // Optionally, keep the style object for other flex/grid properties
  return { minHeight: 0, overflow: 'hidden', flexBasis: 0, flexGrow: 1 }
})

function firstPage() {
  currentPage.value = 1
}

function prevPage() {
  if (currentPage.value > 1) currentPage.value--
}

function nextPage() {
  if (currentPage.value < totalPages.value) currentPage.value++
}

function lastPage() {
  currentPage.value = totalPages.value
}

function onImgError(e: Event) {
  const target = e.target as HTMLImageElement
  if (target) {
    target.src = 'https://via.placeholder.com/80x80?text=No+Image'
  }
}
</script>

<style scoped>
/* Ensure the product-main-screen fills its parent height */
.product-main-screen {
  padding: 2px;
  background: transparent !important;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.04);
  height: 100%;
  min-height: 0;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.product-title {
  font-size: 1.5rem;
  font-weight: 600;
  margin-bottom: 16px;
}
.product-list-placeholder {
  color: #888;
  font-size: 1rem;
  padding: 16px;
  border: 1px dashed #ccc;
  border-radius: 6px;
  background: transparent;
}
/* Product grid container */
.product-grid-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 0;
  gap: 8px;
  padding: 8px;
  overflow: hidden;
  flex: 1;
  width: 100%;
  box-sizing: border-box;
}

/* Make product cards fill their grid cell and stretch vertically */
.product-row {
  display: flex;
  flex: 1 1 0;
  min-height: 0;
  gap: 8px;
  height: 25%;
}
.product-col {
  flex: 1 1 0;
  min-width: 0;
  max-width: 25%;
  min-height: 0;
  padding: 2px;
  box-sizing: border-box;
  display: flex;
  overflow: hidden;
}
.product-card {
  width: 100%;
  height: 100%;
  min-height: 0;
  max-width: 100%;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: stretch;
  border-radius: 4px;
  box-shadow: 0 1px 2px 0 rgba(60, 60, 60, 0.04);
  border: 1px solid #e3e6ea;
  transition:
    box-shadow 0.2s,
    border-color 0.2s,
    background 0.2s;
  background: #fff !important;
  padding: 3px 2px;
  margin: 0;
  overflow: hidden;
  box-sizing: border-box;
}
.product-card:hover {
  border-color: #4fc3f7;
  box-shadow: 0 2px 12px 2px #4fc3f733;
  background: #f4fff4 !important;
  filter: none;
}
.product-img-row {
  flex: 2 1 0;
  min-height: 0;
  padding: 0;
  display: flex;
  align-items: stretch;
  justify-content: stretch;
  width: 100%;
  height: 60px;
  overflow: hidden;
}
.product-img {
  width: 100% !important;
  max-width: 100%;
  height: 100% !important;
  object-fit: fill;
  object-position: center;
  border-radius: 2px;
  background: transparent !important;
  border: none !important;
  display: block;
  flex: 1;
  min-width: 0;
  min-height: 0;
}
.product-name-row {
  flex: 1 1 0;
  min-height: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 1px;
}
.product-name {
  font-size: 0.8rem;
  font-weight: 700;
  color: #222;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  width: 100%;
  max-width: 100%;
  text-align: center;
  word-wrap: break-word;
}
.product-qty-rate-row {
  flex: 1 1 0;
  min-height: 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 2px;
}
.product-qty-value {
  font-weight: 700;
  color: #1976d2;
  font-size: 0.8rem;
  max-width: 50%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
.product-rate-label {
  font-size: 0.8rem;
  color: #888;
  font-weight: 700;
}
.product-rate {
  font-size: 0.8rem;
  font-weight: 700;
  color: #1976d2;
  max-width: 50%;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  text-align: right;
}
/* Responsive product grid and card styles */
@media (max-width: 1200px) {
  .product-grid-container {
    gap: 6px;
    padding: 4px;
  }
  .product-row {
    gap: 6px;
    height: 25%;
  }
  .product-col {
    padding: 1px;
  }
  .product-card {
    padding: 2px 1px;
  }
  .product-img-row {
    height: 48px;
  }
  .product-img {
    height: 48px !important;
  }
  .product-name {
    font-size: 0.7rem;
  }
  .product-qty-value,
  .product-rate {
    font-size: 0.7rem;
  }
}

@media (max-width: 900px) {
  .product-grid-container {
    gap: 4px;
    padding: 2px;
  }
  .product-row {
    gap: 4px;
    height: 33%; /* 3 rows */
  }
  .product-col {
    max-width: 33%; /* 3 columns */
    padding: 1px;
  }
  .product-card {
    padding: 1px 0;
  }
  .product-img-row {
    height: 36px;
  }
  .product-img {
    height: 36px !important;
  }
  .product-name {
    font-size: 0.65rem;
  }
  .product-qty-value,
  .product-rate {
    font-size: 0.65rem;
  }
}

@media (max-width: 600px) {
  .product-grid-container {
    gap: 2px;
    padding: 1px;
  }
  .product-row {
    gap: 2px;
    height: 50%; /* 2 rows */
  }
  .product-col {
    max-width: 50%; /* 2 columns */
    padding: 0;
  }
  .product-card {
    padding: 0;
  }
  .product-img-row {
    height: 28px;
  }
  .product-img {
    height: 28px !important;
  }
  .product-name {
    font-size: 0.6rem;
  }
  .product-qty-value,
  .product-rate {
    font-size: 0.6rem;
  }
}
</style>
