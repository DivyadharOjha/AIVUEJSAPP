<template>
  <div class="product-group-container">
    <div class="product-group-navigation row" id="divProductGroupNavigation">
      <div class="col-1 d-flex align-items-center justify-content-start">
        <button class="nav-button nav-left" @click="scrollLeft" :disabled="!canScrollLeft">
          <svg
            width="16"
            height="16"
            viewBox="0 0 24 24"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M15.41 7.41L10.83 12L15.41 16.59L14 18L8 12L14 6L15.41 7.41Z"
              fill="currentColor"
            />
          </svg>
        </button>
      </div>
      <div class="col-10 d-flex align-items-center">
        <div class="product-group-grid w-100" ref="scrollContainer">
          <div
            v-for="group in productGroups"
            :key="group.ProductGroupId"
            class="product-group-card"
            :class="{ active: selectedGroupId === group.ProductGroupId }"
            @click="selectProductGroup(group)"
          >
            <div class="product-group-info">
              <h3 class="product-group-name">{{ group.ProductGroupText }}</h3>
            </div>
          </div>
        </div>
      </div>
      <div class="col-1 d-flex align-items-center justify-content-end">
        <button class="nav-button nav-right" @click="scrollRight" :disabled="!canScrollRight">
          <svg
            width="16"
            height="16"
            viewBox="0 0 24 24"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
          >
            <path
              d="M8.59 16.59L13.17 12L8.59 7.41L10 6L16 12L10 18L8.59 16.59Z"
              fill="currentColor"
            />
          </svg>
        </button>
      </div>
    </div>

    <div v-if="productGroups.length === 0" class="no-results">
      <p>No product groups available.</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, nextTick, defineEmits } from 'vue'
import { productGroupData, type ProductGroup } from '../posApi/productGroup'

const emit = defineEmits(['product-group-selected'])

const scrollContainer = ref<HTMLElement>()
const canScrollLeft = ref(false)
const canScrollRight = ref(false)
const selectedGroupId = ref<number | null>(null)

// Use the product group data directly
const productGroups = computed(() => productGroupData)

function selectProductGroup(group: ProductGroup) {
  console.log('Product group clicked:', group)
  selectedGroupId.value = group.ProductGroupId
  emit('product-group-selected', group)
}

function updateScrollButtons() {
  if (!scrollContainer.value) return

  const { scrollLeft, scrollWidth, clientWidth } = scrollContainer.value
  canScrollLeft.value = scrollLeft > 0
  canScrollRight.value = scrollLeft < scrollWidth - clientWidth - 1
}

function scrollLeft() {
  if (scrollContainer.value) {
    scrollContainer.value.scrollBy({ left: -200, behavior: 'smooth' })
    setTimeout(updateScrollButtons, 300)
  }
}

function scrollRight() {
  if (scrollContainer.value) {
    scrollContainer.value.scrollBy({ left: 200, behavior: 'smooth' })
    setTimeout(updateScrollButtons, 300)
  }
}

onMounted(() => {
  nextTick(() => {
    updateScrollButtons()
    if (scrollContainer.value) {
      scrollContainer.value.addEventListener('scroll', updateScrollButtons)
    }
  })
})
</script>

<style scoped>
.product-group-container {
  height: 100%;
  background: transparent;
  overflow: hidden;
  max-height: 60px;
  width: 100%;
  box-sizing: border-box;
  flex-shrink: 0;
}

.product-group-navigation {
  height: 60px;
  width: 100%;
  box-sizing: border-box;
  position: relative;
  margin: 0;
  gap: 0 !important;
}

.nav-button {
  flex-shrink: 0;
  width: 40px;
  height: 40px;
  border: none;
  border-radius: 4px;
  background: #1976d2;
  color: white;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
  padding: 0;
  z-index: 2;
  margin: 0 !important;
}

.nav-left {
  margin-right: 0 !important;
}

.nav-right {
  margin-left: -20px;
}

.nav-button:hover:not(:disabled) {
  background: #1565c0;
  transform: scale(1.1);
}

.nav-button:disabled {
  background: #ccc;
  cursor: not-allowed;
  opacity: 0.5;
}

.product-group-grid {
  display: flex;
  gap: 8px;
  overflow-x: auto;
  padding-bottom: 4px;
  flex: 1;
  scrollbar-width: none;
  -ms-overflow-style: none;
  height: 60px;
  align-items: center;
  min-width: 0;
  box-sizing: border-box;
  padding-left: 0;
  padding-right: 0;
}

.product-group-grid::-webkit-scrollbar {
  display: none;
}

.product-group-card {
  background: white;
  border: 1px solid #e9ecef;
  border-radius: 4px;
  padding: 8px 12px;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  gap: 6px;
  flex-shrink: 0;
  min-width: 120px;
  height: 50px;
}

.product-group-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  border-color: #1976d2;
}

.product-group-card.active {
  background: #e3f2fd;
  border-color: #1976d2;
  color: #1976d2;
}

.product-group-info {
  flex: 1;
  min-width: 0;
}

.product-group-name {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
  color: #2c3e50;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  line-height: 1.2;
}

.product-group-card.active .product-group-name {
  color: #1976d2;
}

.no-results {
  text-align: center;
  padding: 40px 20px;
  color: #6c757d;
}

.no-results p {
  margin: 0;
  font-size: 16px;
}

.col-1 {
  padding-left: 0 !important;
  padding-right: 0 !important;
}

@media (max-width: 768px) {
  .product-group-grid {
    grid-template-columns: 1fr;
  }
}
</style>
