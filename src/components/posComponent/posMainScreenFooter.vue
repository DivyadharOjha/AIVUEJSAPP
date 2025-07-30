<template>
  <div class="footer-btn-group">
    <button
      v-for="(btn, idx) in buttons"
      :key="btn"
      class="footer-btn"
      :style="{ background: randomColors[idx] }"
      @click="handleClick(btn)"
    >
      {{ btn }}
    </button>
  </div>
</template>

<script setup lang="ts">
import { defineEmits } from 'vue'
const emit = defineEmits(['footerBtnClick'])

const buttons = [
  'Member',
  'Item',
  'Task',
  'Transaction',
  'Sales Return',
  'Employee',
  'Pre Order',
  'Employee (Schemes)',
  'Batch Report',
]

const predefinedColors = [
  'rgb(3, 49, 57)',
  'rgb(64, 4, 86)',
  'rgb(159, 110, 44)',
  'rgb(83, 50, 103)',
  'rgb(6, 35, 80)',
]

const randomColors = buttons.map((_, index) => predefinedColors[index % predefinedColors.length])

function handleClick(btn: string) {
  emit('footerBtnClick', btn)
}
</script>

<style scoped>
.footer-btn-group {
  display: flex;
  gap: 12px;
  justify-content: flex-start;
  align-items: center;
}
.footer-btn {
  height: 40px;
  padding: 0 18px;
  border: 1px solid #bbb;
  border-radius: 6px;
  font-size: 1rem;
  color: #fff;
  cursor: pointer;
  transition:
    background 0.2s,
    color 0.2s,
    box-shadow 0.2s;
}
.footer-btn:hover {
  background: lightgreen;
  color: #fff;
  box-shadow: 0 2px 8px rgba(25, 118, 210, 0.15);
}
</style>
