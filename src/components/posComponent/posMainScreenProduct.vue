<template>
  <div class="product-main-screen h-100 d-flex flex-column" style="min-height: 0; overflow: hidden">
    <div
      v-if="hasProducts"
      class="flex-grow-1 d-flex flex-column h-100"
      style="min-height: 0; overflow: hidden"
    >
      <div class="container-fluid h-100 p-0" style="min-height: 0; overflow: hidden">
        <div class="row h-100" style="min-height: 0; overflow: hidden">
          <div class="col-12 h-100" style="min-height: 0; overflow: hidden">
            <div
              id="divRightPanelProduct"
              ref="divRightPanelProduct"
              class="product-grid-container flex-grow-1"
              :style="productGridStyle"
            >
              <div
                v-for="(row, rowIndex) in productGrid"
                :key="rowIndex"
                class="col-12 d-flex flex-row flex-fill product-row"
                style="flex: 1 1 0; min-height: 0; margin-bottom: 0; height: 20%"
              >
                <div
                  v-for="(product, colIndex) in row"
                  :key="colIndex"
                  class="d-flex align-items-stretch justify-content-stretch px-0 flex-fill product-col"
                  style="width: 25%; min-width: 0; min-height: 0; height: 100%"
                >
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
                          class="product-img w-100"
                          style="width: 100%; max-width: 100%; height: 48px; object-fit: contain"
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
        <div v-if="products.length > 16" class="row" style="height: 40px; min-height: 0">
          <div class="col-12 d-flex justify-content-center align-items-center" style="height: 100%">
            <button class="btn btn-outline-primary btn-sm me-2" @click="prevPage">&lt;</button>
            <span style="font-size: 0.95rem">Page {{ currentPage }} / {{ totalPages }}</span>
            <button
              class="btn btn-outline-primary btn-sm ms-2"
              :disabled="currentPage === totalPages"
              @click="nextPage"
            >
              &gt;
            </button>
          </div>
        </div>
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

const props = defineProps<{ products: Product[] }>()
const products = props.products
const hasProducts = computed(() => products && products.length > 0)
const currentPage = ref(1)
const pageSize = 16
const totalPages = computed(() => Math.ceil((products?.length || 0) / pageSize))

// Compute a 2D array for the product grid (4 rows x 4 columns)
const productGrid = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  const pageProducts = products?.slice(start, start + pageSize) || []
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
  return grid
})

// Dynamic height calculation for divRightPanelProduct
const divRightPanelProduct = ref<HTMLElement | null>(null)
const paginationVisible = computed(() => products.length > 16)
function setProductGridHeight() {
  nextTick(() => {
    const parent = divRightPanelProduct.value?.parentElement
    if (parent && divRightPanelProduct.value) {
      const parentHeight = parent.clientHeight
      const paginationHeight = paginationVisible.value ? 40 : 0
      divRightPanelProduct.value.style.height = `${parentHeight - paginationHeight}px`
    }
  })
}
onMounted(setProductGridHeight)
watch([() => products.length, paginationVisible], setProductGridHeight)

const productGridStyle = computed(() => {
  // Optionally, keep the style object for other flex/grid properties
  return { minHeight: 0, overflow: 'hidden', flexBasis: 0, flexGrow: 1 }
})

function prevPage() {
  if (currentPage.value > 1) currentPage.value--
}
function nextPage() {
  if (currentPage.value < totalPages.value) currentPage.value++
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
}

/* Make product cards fill their grid cell and stretch vertically */
.product-row {
  height: 20% !important;
  min-height: 0 !important;
  display: flex;
  gap: 8px;
}
.product-col {
  height: 100% !important;
  min-height: 0 !important;
  padding: 4px !important;
  box-sizing: border-box;
}
.product-card {
  height: 100% !important;
  min-height: 0 !important;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  align-items: stretch;
  border-radius: 8px;
  box-shadow: 0 2px 6px 0 rgba(60, 60, 60, 0.1);
  border: 1px solid #e3e6ea;
  transition:
    box-shadow 0.2s,
    border-color 0.2s,
    background 0.2s;
  background: #fff !important;
  padding: 8px 6px !important;
  margin: 0 !important;
  overflow: hidden;
}
.product-img-row {
  flex: 2 1 0;
  min-height: 0;
  padding: 4px 0;
  display: flex;
  align-items: center;
  justify-content: center;
}
.product-img {
  width: 100% !important;
  max-width: 100%;
  height: 80px !important;
  object-fit: contain;
  border-radius: 6px;
  background: transparent !important;
  border: none !important;
}
.product-name-row {
  flex: 1 1 0;
  min-height: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 3px 2px;
}
.product-name {
  font-size: 0.9rem;
  font-weight: 700;
  color: #222;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  width: 100%;
  text-align: center;
  line-height: 1.3;
}
.product-qty-rate-row {
  flex: 1 1 0;
  min-height: 0;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 3px 4px;
}
.product-qty-value {
  font-weight: 700;
  color: #1976d2;
  font-size: 0.9rem;
}
.product-rate-label {
  font-size: 0.9rem;
  color: #888;
  font-weight: 700;
}
.product-rate {
  font-size: 0.9rem;
  font-weight: 700;
  color: #1976d2;
}
</style>
