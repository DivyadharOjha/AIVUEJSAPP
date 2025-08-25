<template>
  <div class="product-group-container">
    <div class="product-group-navigation" id="divProductGroupNavigation">
      <!-- Left Navigation Button -->
      <button
        class="nav-button nav-left"
        @click="scrollLeft"
        :disabled="!canScrollLeft"
        aria-label="Scroll left"
      >
        <svg
          width="22"
          height="22"
          viewBox="0 0 24 24"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <circle cx="12" cy="12" r="11" stroke="#fff" stroke-width="2" fill="#1976d2" />
          <path
            d="M14.5 8L10.5 12L14.5 16"
            stroke="#fff"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          />
        </svg>
      </button>

      <!-- Product Groups Container -->
      <div class="product-groups-wrapper">
        <div class="product-group-grid" ref="scrollContainer">
          <div
            v-for="(group, index) in productGroups"
            :key="group.ProductGroupId"
            class="product-group-card"
            :class="{ active: internalSelectedGroupId === group.ProductGroupId }"
            :style="{ background: randomColors[index], color: '#ffffff' }"
            @click="selectProductGroup(group)"
          >
            <div class="product-group-info">
              <h3 class="product-group-name">{{ group.ProductGroupText }}</h3>
            </div>
          </div>
        </div>
      </div>

      <!-- Right Navigation Button -->
      <button
        class="nav-button nav-right"
        @click="scrollRight"
        :disabled="!canScrollRight"
        aria-label="Scroll right"
      >
        <svg
          width="22"
          height="22"
          viewBox="0 0 24 24"
          fill="none"
          xmlns="http://www.w3.org/2000/svg"
        >
          <circle cx="12" cy="12" r="11" stroke="#fff" stroke-width="2" fill="#1976d2" />
          <path
            d="M9.5 8L13.5 12L9.5 16"
            stroke="#fff"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
          />
        </svg>
      </button>
    </div>

    <div v-if="productGroups.length === 0" class="no-results">
      <p>No product groups available.</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, nextTick, defineEmits, watch } from 'vue'
import { productGroupData, type ProductGroup } from '../posApi/productGroup'

const props = defineProps<{
  selectedGroupId?: number | null
}>()

const emit = defineEmits(['product-group-selected'])

const scrollContainer = ref<HTMLElement>()
const canScrollLeft = ref(false)
const canScrollRight = ref(false)
const internalSelectedGroupId = ref<number | null>(null)

// Use the product group data directly
const productGroups = computed(() => productGroupData)

// Watch for changes in the selected group ID from parent
watch(
  () => props.selectedGroupId,
  (newValue) => {
    if (newValue !== undefined) {
      internalSelectedGroupId.value = newValue
    }
  },
  { immediate: true },
)

// Array of colors for product group buttons
const darkColors = [
  '#2e8b57', // Sea Green
  '#4b0082', // Indigo
  '#8b4513', // Saddle Brown
  '#2f4f4f', // Dark Slate Gray
  'rgb(25, 170, 195)', // Light Blue
  'rgb(241, 23, 83)', // Pink Red
]

// Computed property for random colors
const randomColors = computed(() => {
  return productGroups.value.map((_, index) => darkColors[index % darkColors.length])
})

function selectProductGroup(group: ProductGroup) {
  console.log('Product group clicked:', group)
  console.log('Setting internalSelectedGroupId to:', group.ProductGroupId)
  internalSelectedGroupId.value = group.ProductGroupId
  console.log('Emitting product-group-selected event with group:', group)
  emit('product-group-selected', group)
}

// Method to programmatically select the first group
function selectFirstGroup() {
  console.log('selectFirstGroup called in posMainScreenProductGroup')
  console.log('productGroups.value.length:', productGroups.value.length)

  if (productGroups.value.length > 0) {
    const firstGroup = productGroups.value[0]
    console.log('First group found:', firstGroup)
    selectProductGroup(firstGroup)
    console.log('selectProductGroup called with first group')
  } else {
    console.warn('No product groups available')
  }
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
  console.log('posMainScreenProductGroup mounted')
  console.log('productGroups.value:', productGroups.value)
  console.log('productGroups.value.length:', productGroups.value.length)

  nextTick(() => {
    console.log('posMainScreenProductGroup nextTick - updating scroll buttons')
    updateScrollButtons()
    if (scrollContainer.value) {
      scrollContainer.value.addEventListener('scroll', updateScrollButtons)
      console.log('Scroll event listener added')
    } else {
      console.warn('scrollContainer.value is null')
    }
  })
})

// Expose methods to parent component
defineExpose({
  selectFirstGroup,
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
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 0 4px;
  box-sizing: border-box;
  position: relative;
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
}

.nav-button:hover:not(:disabled) {
  background: #1565c0;
  transform: scale(1.05);
  box-shadow: 0 2px 8px rgba(25, 118, 210, 0.3);
}

.nav-button:disabled {
  background: #ccc;
  cursor: not-allowed;
  opacity: 0.5;
  transform: none;
}

.nav-button:focus {
  outline: 2px solid #1976d2;
  outline-offset: 2px;
}

.product-groups-wrapper {
  flex: 1;
  min-width: 0;
  position: relative;
  overflow: hidden;
}

.product-group-grid {
  display: flex;
  gap: 8px;
  overflow-x: auto;
  padding: 4px 0;
  height: 52px;
  align-items: center;
  scrollbar-width: none;
  -ms-overflow-style: none;
  scroll-behavior: smooth;
}

.product-group-grid::-webkit-scrollbar {
  display: none;
}

.product-group-card {
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
  height: 44px;
  position: relative;
}

.product-group-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
  border-color: #ffffff;
}

.product-group-card.active {
  border-color: #ffffff;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
  transform: translateY(-2px);
}

.product-group-card:focus {
  outline: 2px solid #ffffff;
  outline-offset: 2px;
}

.product-group-info {
  flex: 1;
  min-width: 0;
}

.product-group-name {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
  color: #ffffff;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  line-height: 1.2;
}

.product-group-card.active .product-group-name {
  color: #ffffff;
  font-weight: 700;
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

/* Responsive Design */
@media (max-width: 768px) {
  .product-group-navigation {
    height: 56px;
    gap: 4px;
    padding: 0 2px;
  }

  .nav-button {
    width: 36px;
    height: 36px;
  }

  .product-group-grid {
    height: 48px;
    gap: 6px;
  }

  .product-group-card {
    min-width: 100px;
    height: 40px;
    padding: 6px 10px;
  }

  .product-group-name {
    font-size: 13px;
  }
}

@media (max-width: 576px) {
  .product-group-navigation {
    height: 52px;
    gap: 2px;
  }

  .nav-button {
    width: 32px;
    height: 32px;
  }

  .product-group-grid {
    height: 44px;
    gap: 4px;
  }

  .product-group-card {
    min-width: 90px;
    height: 36px;
    padding: 4px 8px;
  }

  .product-group-name {
    font-size: 12px;
  }
}

@media (max-width: 480px) {
  .product-group-card {
    min-width: 80px;
  }

  .product-group-name {
    font-size: 11px;
  }
}

/* High contrast mode support */
@media (prefers-contrast: high) {
  .nav-button {
    border: 2px solid #ffffff;
  }

  .product-group-card {
    border-width: 2px;
  }
}

/* Reduced motion support */
@media (prefers-reduced-motion: reduce) {
  .nav-button,
  .product-group-card {
    transition: none;
  }

  .product-group-grid {
    scroll-behavior: auto;
  }
}
</style>
