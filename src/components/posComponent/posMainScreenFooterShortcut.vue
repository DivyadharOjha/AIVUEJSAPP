<template>
  <div
    class="shortcut-main-screen h-100 d-flex flex-column"
    style="min-height: 0; overflow: hidden"
  >
    <!-- Shortcut Grid -->
    <div
      v-if="hasShortcuts"
      class="flex-grow-1 d-flex flex-column h-100"
      style="min-height: 0; overflow: hidden"
    >
      <div class="container-fluid h-100 p-0" style="min-height: 0; overflow: hidden">
        <div class="row h-100" style="min-height: 0; overflow: hidden">
          <div class="col-12 h-100" style="min-height: 0; overflow: hidden">
            <div
              ref="divRightPanelShortcut"
              class="shortcut-grid-container"
              :class="{ 'with-pagination': showPagination, 'without-pagination': !showPagination }"
              :style="shortcutGridStyle"
            >
              <div v-for="(row, rowIndex) in shortcutGrid" :key="rowIndex" class="shortcut-row">
                <div v-for="(item, colIndex) in row" :key="colIndex" class="shortcut-col">
                  <div
                    v-if="item"
                    :class="[
                      'card',
                      'shortcut-card',
                      'w-100',
                      'h-100',
                      'd-flex',
                      'flex-column',
                      { 'shortcut-card-compact': displayedData.length > 20 },
                    ]"
                    style="height: 100%; min-height: 0; margin: 0"
                    :style="{ background: randomColors[shortcutGrid.flat().indexOf(item)] }"
                    @click="handleShortcutClick(item)"
                  >
                    <div class="shortcut-name-row">
                      <span class="shortcut-name">{{ item.name }}</span>
                    </div>
                    <div class="shortcut-desc-row">
                      <span class="shortcut-desc">{{ item.description }}</span>
                    </div>
                  </div>
                  <div v-else class="shortcut-col-placeholder"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- No Shortcuts Message -->
    <div
      v-else
      class="shortcut-list-placeholder flex-grow-1 d-flex align-items-center justify-content-center"
      style="min-height: 40px; overflow: auto"
    >
      <div class="text-center">
        <p class="text-muted mb-0">No shortcuts to display.</p>
        <small class="text-muted">Please select a category to view shortcuts.</small>
      </div>
    </div>

    <!-- Pagination Footer -->
    <div v-if="showPagination" class="shortcut-pagination-footer">
      <div class="d-flex justify-content-center align-items-center h-100">
        <button
          class="btn btn-outline-primary btn-sm me-2"
          @click="prevPage"
          :disabled="currentPage === 1"
        >
          &lt;
        </button>
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
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { memberData, type FooterButtonData } from '../../data/memberData'
import { itemData } from '../../data/itemData'
import { taskData } from '../../data/taskData'
import { transactionData } from '../../data/transactionData'
import { salesReturnData } from '../../data/salesReturnData'
import { employeeData } from '../../data/employeeData'
import { preOrderData } from '../../data/preOrderData'
import { employeeSchemesData } from '../../data/employeeSchemesData'
import { batchReportData } from '../../data/batchReportData'

const props = defineProps<{ selectedButton: string }>()
const emit = defineEmits<{
  'shortcut-clicked': [shortcutId: string]
}>()

const displayedData = computed(() => {
  switch (props.selectedButton) {
    case 'Member':
      return memberData
    case 'Item':
      return itemData
    case 'Task':
      return taskData
    case 'Transaction':
      return transactionData
    case 'Sales Return':
      return salesReturnData
    case 'Employee':
      return employeeData
    case 'Pre Order':
      return preOrderData
    case 'Employee (Schemes)':
      return employeeSchemesData
    case 'Batch Report':
      return batchReportData
    default:
      return []
  }
})

const hasShortcuts = computed(() => displayedData.value && displayedData.value.length > 0)
const showPagination = computed(() => hasShortcuts.value && displayedData.value.length > 20)

// Pagination state
const currentPage = ref(1)
const pageSize = 20
const totalPages = computed(() => Math.ceil((displayedData.value?.length || 0) / pageSize))

// Compute a 2D array for the shortcut grid (5 rows x 4 columns) with pagination
const shortcutGrid = computed(() => {
  const start = (currentPage.value - 1) * pageSize
  const pageShortcuts = displayedData.value?.slice(start, start + pageSize) || []
  const grid: ((typeof displayedData.value)[0] | null)[][] = []

  for (let i = 0; i < 5; i++) {
    const row: ((typeof displayedData.value)[0] | null)[] = []
    for (let j = 0; j < 4; j++) {
      const item = pageShortcuts[i * 4 + j]
      // Always add a slot, even if empty, to maintain grid structure
      row.push(item || null)
    }
    grid.push(row)
  }
  return grid
})

// Pagination functions
function prevPage() {
  if (currentPage.value > 1) currentPage.value--
}

function nextPage() {
  if (currentPage.value < totalPages.value) currentPage.value++
}

// Reset page when data changes
watch(
  () => displayedData.value.length,
  () => {
    currentPage.value = 1
  },
)

const predefinedColors = [
  '#2e8b57', // Sea Green
  '#4b0082', // Indigo
  '#8b4513', // Saddle Brown
  '#2f4f4f', // Dark Slate Gray
  'rgb(25, 170, 195)', // Light Blue
  'rgb(241, 23, 83)', // Pink Red
]

const randomColors = computed(() =>
  displayedData.value.map((_, index) => predefinedColors[index % predefinedColors.length]),
)

// Dynamic height calculation for divRightPanelShortcut
const divRightPanelShortcut = ref<HTMLElement | null>(null)

const shortcutGridStyle = computed(() => {
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

// Handle shortcut button click
function handleShortcutClick(item: FooterButtonData) {
  if (item && item.id) {
    console.log(`Shortcut clicked: ${item.name} (ID: ${item.id})`)
    emit('shortcut-clicked', item.id.toString())
  }
}
</script>

<style scoped>
.shortcut-main-screen {
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

.shortcut-list-placeholder {
  color: #888;
  font-size: 1rem;
  padding: 16px;
  border: 1px dashed #ccc;
  border-radius: 6px;
  background: transparent;
}

.shortcut-grid-container {
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
.shortcut-grid-container.with-pagination {
  padding-bottom: 8px;
}

.shortcut-grid-container.without-pagination {
  padding-bottom: 4px;
}

.shortcut-grid-container::-webkit-scrollbar {
  display: none;
}

.shortcut-row {
  display: flex;
  flex: 1;
  min-height: 0;
  gap: 4px;
  width: 100%;
  overflow: hidden;
}

.shortcut-col {
  flex: 0 0 24.5%;
  min-width: 0;
  min-height: 0;
  padding: 2px;
  width: 24.5%;
  max-width: 24.5%;
  overflow: hidden;
}

.shortcut-col-placeholder {
  flex: 0 0 24.5%;
  min-width: 0;
  min-height: 0;
  padding: 2px;
  width: 24.5%;
  max-width: 24.5%;
  overflow: hidden;
}

.shortcut-card {
  border: 1px solid #e9ecef;
  border-radius: 6px;
  transition: all 0.2s ease;
  cursor: pointer;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
  height: 100%;
  min-height: 0;
  width: 100%;
  max-width: 100%;
  overflow: hidden;
  box-sizing: border-box;
  margin: 0;
  color: #fff;
  display: flex;
  flex-direction: column;
  align-items: stretch;
  justify-content: center;
}

.shortcut-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  border-color: #1976d2;
  z-index: 1;
  position: relative;
}

.shortcut-card-compact {
  padding: 4px;
}

.shortcut-name-row,
.shortcut-desc-row {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.shortcut-name {
  font-size: 12px;
  font-weight: 600;
  color: #fff;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  line-height: 1.2;
  max-width: 100%;
  width: 100%;
  word-wrap: break-word;
  text-align: center;
  display: block;
}

.shortcut-desc {
  font-size: 11px;
  color: #fff;
  font-weight: 500;
  text-align: center;
  opacity: 0.9;
  width: 100%;
  display: block;
}

.shortcut-pagination-footer {
  height: 50px;
  min-height: 50px;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

@media (max-width: 768px) {
  .shortcut-name {
    font-size: 11px;
  }

  .shortcut-desc {
    font-size: 10px;
  }

  .shortcut-grid-container.with-pagination {
    padding-bottom: 6px;
  }
}

@media (max-width: 576px) {
  .shortcut-grid-container.with-pagination {
    padding-bottom: 4px;
  }
}
</style>
