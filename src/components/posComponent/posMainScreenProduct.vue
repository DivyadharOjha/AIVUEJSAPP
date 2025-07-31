<template>
  <div class="product-main-screen h-100 d-flex flex-column" style="min-height: 0; overflow: hidden">
    <!-- Product Grid -->
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
              class="product-grid-container"
              :class="{ 'with-pagination': showPagination, 'without-pagination': !showPagination }"
              :style="productGridStyle"
            >
              <div v-for="(row, rowIndex) in productGrid" :key="rowIndex" class="product-row">
                <div v-for="(product, colIndex) in row" :key="colIndex" class="product-col">
                  <div
                    v-if="product"
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
                    @click="selectProduct(product)"
                  >
                    <div class="row g-0 flex-column h-100" style="height: 100%; min-height: 0">
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
                          style="width: 100%; max-width: 100%; height: 35px; object-fit: contain"
                          @error="onImgError"
                        />
                      </div>
                      <!-- Product Name -->
                      <div class="col-12 text-center product-name-row">
                        <span class="product-name">{{ product.ProductName }}</span>
                      </div>
                      <!-- Product Quantity Row -->
                      <div class="col-12 text-center product-qty-row">
                        <span class="product-qty-value">Qty: {{ product.ProductQuantity }}</span>
                      </div>
                      <!-- Product Rate Row -->
                      <div class="col-12 text-center product-rate-row">
                        <span class="product-rate">₹{{ product.ProductRate.toFixed(2) }}</span>
                      </div>
                    </div>
                  </div>
                  <div v-else class="product-col-placeholder"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- No Products Message -->
    <div
      v-else
      class="product-list-placeholder flex-grow-1 d-flex align-items-center justify-content-center"
      style="min-height: 40px; overflow: auto"
    >
      <div class="text-center">
        <p class="text-muted mb-0">No products to display.</p>
        <small class="text-muted">Please select a product group to view products.</small>
      </div>
    </div>

    <!-- Pagination Footer -->
    <div v-if="showPagination" class="product-pagination-footer">
      <posPageNavigation
        :currentPage="currentPage"
        :totalPages="totalPages"
        :totalRecords="products.length"
        @first-click="goToFirstPage"
        @previous-click="prevPage"
        @next-click="nextPage"
        @last-click="goToLastPage"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import type { Product } from '../posDataStruct/posProduct'
import posPageNavigation from '../posTemplate/posPageNavigation.vue'

const props = defineProps<{
  products: Product[]
  group?: { ProductGroupId: number; ProductGroupText: string } | null
}>()

const emit = defineEmits(['product-selected'])

const products = computed(() => props.products || [])
const hasProducts = computed(() => products.value && products.value.length > 0)
const showPagination = computed(() => hasProducts.value && products.value.length > 20)

const currentPage = ref(1)
const pageSize = 20
const totalPages = computed(() => Math.ceil((products.value?.length || 0) / pageSize))

// Compute a 2D array for the product grid (5 rows x 4 columns)
const productGrid = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  const pageProducts = products.value?.slice(start, start + pageSize) || []
  const grid: (Product | null)[][] = []

  for (let i = 0; i < 5; i++) {
    const row: (Product | null)[] = []
    for (let j = 0; j < 4; j++) {
      const product = pageProducts[i * 4 + j]
      // Always add a slot, even if empty, to maintain grid structure
      row.push(product || null)
    }
    grid.push(row)
  }
  return grid
})

// Dynamic height calculation for divRightPanelProduct
const divRightPanelProduct = ref<HTMLElement | null>(null)

function prevPage() {
  if (currentPage.value > 1) currentPage.value--
}

function nextPage() {
  if (currentPage.value < totalPages.value) currentPage.value++
}

function goToFirstPage() {
  currentPage.value = 1
}

function goToLastPage() {
  currentPage.value = totalPages.value
}

function selectProduct(product: Product) {
  console.log('Product selected:', product)
  console.log('Product details:', {
    name: product.ProductName,
    quantity: product.ProductQuantity,
    rate: product.ProductRate,
  })
  emit('product-selected', product)
}

function onImgError(e: Event) {
  const target = e.target as HTMLImageElement
  if (target) {
    target.src = 'https://via.placeholder.com/80x80?text=No+Image'
  }
}

// Reset page when products change
watch(
  () => products.value.length,
  () => {
    currentPage.value = 1
  },
)

const productGridStyle = computed(() => {
  return {
    minHeight: 0,
    overflow: 'hidden',
    flexBasis: 0,
    flexGrow: 1,
    padding: '4px',
    display: 'flex',
    flexDirection: 'column' as const,
    height: '100%',
  }
})
</script>

<style scoped>
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

.product-list-placeholder {
  color: #888;
  font-size: 1rem;
  padding: 16px;
  border: 1px dashed #ccc;
  border-radius: 6px;
  background: transparent;
}

.product-grid-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  min-height: 0;
  overflow: hidden;
  gap: 3px;
  scrollbar-width: none;
  -ms-overflow-style: none;
  padding: 4px;
}

/* Spacing adjustments based on pagination visibility */
.product-grid-container.with-pagination {
  padding-bottom: 8px;
}

.product-grid-container.without-pagination {
  padding-bottom: 4px;
}

.product-grid-container::-webkit-scrollbar {
  display: none;
}

.product-row {
  display: flex;
  flex: 1;
  min-height: 0;
  gap: 4px;
  width: 100%;
  overflow: hidden;
}

.product-col {
  flex: 0 0 24.5%;
  min-width: 0;
  min-height: 0;
  padding: 2px;
  width: 24.5%;
  max-width: 24.5%;
  overflow: hidden;
}

.product-col-placeholder {
  flex: 0 0 24.5%;
  min-width: 0;
  min-height: 0;
  padding: 2px;
  width: 24.5%;
  max-width: 24.5%;
  overflow: hidden;
}

.product-card {
  border: 1px solid #e9ecef;
  border-radius: 6px;
  transition: all 0.2s ease;
  cursor: pointer;
  background: white;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  height: 100%;
  min-height: 0;
  width: 100%;
  max-width: 100%;
  overflow: hidden;
  box-sizing: border-box;
  margin: 0;
}

.product-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  border-color: #1976d2;
  z-index: 1;
  position: relative;
}

.product-card-compact {
  padding: 4px;
}

.product-img-row {
  height: 35px;
  min-height: 35px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.product-name-row {
  height: 25px;
  min-height: 25px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1px 2px;
}

.product-qty-row {
  height: 20px;
  min-height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 4px;
}

.product-rate-row {
  height: 20px;
  min-height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0 4px;
}

.product-name {
  font-size: 12px;
  font-weight: 600;
  color: #2c3e50;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  line-height: 1.2;
  max-width: 100%;
  width: 100%;
  word-wrap: break-word;
}

.product-qty-value {
  font-size: 11px;
  color: #6c757d;
  font-weight: 500;
  text-align: center;
}

.product-rate {
  font-size: 13px;
  font-weight: 700;
  color: #28a745;
  text-align: center;
  background: #f8f9fa;
  border-radius: 4px;
  padding: 2px 6px;
  border: 1px solid #e9ecef;
}

.product-img {
  max-height: 35px;
  object-fit: contain;
}

.product-pagination-footer {
  height: 50px;
  min-height: 50px;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

/* Responsive design with horizontal scroll */
@media (max-width: 1200px) {
  .product-grid-container {
    overflow-x: auto;
    overflow-y: hidden;
  }

  .product-row {
    min-width: 800px; /* Minimum width to prevent squashing */
    flex-wrap: nowrap;
  }

  .product-col {
    flex: 0 0 200px; /* Fixed width for better scrolling */
    min-width: 200px;
    width: 200px;
    max-width: 200px;
  }

  .product-col-placeholder {
    flex: 0 0 200px;
    min-width: 200px;
    width: 200px;
    max-width: 200px;
  }

  /* Custom horizontal scrollbar */
  .product-grid-container::-webkit-scrollbar {
    display: block;
    height: 8px;
  }

  .product-grid-container::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 4px;
  }

  .product-grid-container::-webkit-scrollbar-thumb {
    background: #c1c1c1;
    border-radius: 4px;
  }

  .product-grid-container::-webkit-scrollbar-thumb:hover {
    background: #a8a8a8;
  }

  /* Firefox scrollbar */
  .product-grid-container {
    scrollbar-width: thin;
    scrollbar-color: #c1c1c1 #f1f1f1;
  }
}

@media (max-width: 768px) {
  .product-grid-container {
    overflow-x: auto;
    overflow-y: hidden;
  }

  .product-row {
    min-width: 600px;
  }

  .product-col {
    flex: 0 0 150px;
    min-width: 150px;
    width: 150px;
    max-width: 150px;
  }

  .product-col-placeholder {
    flex: 0 0 150px;
    min-width: 150px;
    width: 150px;
    max-width: 150px;
  }

  .product-name {
    font-size: 11px;
  }

  .product-qty-value,
  .product-rate {
    font-size: 10px;
  }

  .product-grid-container.with-pagination {
    padding-bottom: 6px;
  }
}

@media (max-width: 576px) {
  .product-grid-container {
    overflow-x: auto;
    overflow-y: hidden;
  }

  .product-row {
    min-width: 400px;
  }

  .product-col {
    flex: 0 0 120px;
    min-width: 120px;
    width: 120px;
    max-width: 120px;
  }

  .product-col-placeholder {
    flex: 0 0 120px;
    min-width: 120px;
    width: 120px;
    max-width: 120px;
  }

  .product-name {
    font-size: 10px;
  }

  .product-qty-value,
  .product-rate {
    font-size: 9px;
  }

  .product-grid-container.with-pagination {
    padding-bottom: 4px;
  }
}
</style>
