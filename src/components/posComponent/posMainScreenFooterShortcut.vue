<template>
  <div class="footer-data-list">
    <div class="footer-data-btn-group">
      <button
        v-for="(item, idx) in displayedData"
        :key="item.id"
        class="footer-data-btn"
        :style="{ background: randomColors[idx] }"
      >
        <span class="footer-data-btn-text">
          <strong>{{ item.name }}</strong
          >: {{ item.description }}
        </span>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { memberData } from '../../data/memberData'
import { itemData } from '../../data/itemData'
import { taskData } from '../../data/taskData'
import { transactionData } from '../../data/transactionData'
import { salesReturnData } from '../../data/salesReturnData'
import { employeeData } from '../../data/employeeData'
import { preOrderData } from '../../data/preOrderData'
import { employeeSchemesData } from '../../data/employeeSchemesData'
import { batchReportData } from '../../data/batchReportData'

const props = defineProps<{ selectedButton: string }>()

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

const predefinedColors = [
  'rgb(159, 110, 44)',
  'rgb(41, 153, 9)',
  'rgb(26, 91, 44)',
  'rgb(143, 110, 75)',
  'rgb(63, 78, 92)',
  'rgb(83, 50, 103)',
  'rgb(50, 110, 38)',
  'rgb(207, 114, 45)',
]

const randomColors = computed(() =>
  displayedData.value.map((_, index) => predefinedColors[index % predefinedColors.length]),
)
</script>

<style scoped>
.footer-btn-group {
  display: flex;
  gap: 12px;
  margin-bottom: 24px;
}
.footer-btn {
  height: 40px;
  padding: 0 18px;
  border: 1px solid #bbb;
  border-radius: 6px;
  font-size: 1rem;
  color: #fff;
  background: #333;
  cursor: pointer;
  transition:
    background 0.2s,
    color 0.2s,
    box-shadow 0.2s;
}
.footer-btn.active {
  background: #1976d2;
}
.footer-btn:hover {
  background: #1976d2;
  color: #fff;
}
.footer-data-list {
  border-radius: 8px;
}

.footer-data-btn-group {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  justify-content: flex-start;
}

.footer-data-btn {
  width: 220px;
  height: 48px;
  padding: 0 16px;
  border: 1px solid #1976d2;
  border-radius: 8px;
  font-size: 1rem;
  color: #fff;
  background: transparent;
  cursor: pointer;
  transition:
    background 0.2s,
    color 0.2s,
    box-shadow 0.2s;
  display: flex;
  align-items: center;
  justify-content: flex-start;
  overflow: hidden;
}

.footer-data-btn-text {
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  width: 100%;
}
.footer-data-btn:hover {
  background: #1976d2;
  color: #fff;
  box-shadow: 0 2px 8px rgba(25, 118, 210, 0.15);
}
</style>
