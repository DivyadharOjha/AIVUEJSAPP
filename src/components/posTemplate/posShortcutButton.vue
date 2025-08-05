<template>
  <button
    @click="handleClick"
    class="shortcut-button"
    :class="{ active: isActive }"
    :title="description"
  >
    <slot>{{ label }}</slot>
  </button>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useShortcutManager } from '../../composables/useShortcutManager'
import { getScreenLabel } from '../../utils/shortcutUtils'

// Props
interface Props {
  screenId: string
  label?: string
  description?: string
  variant?: 'primary' | 'secondary' | 'success' | 'warning' | 'danger'
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<Props>(), {
  label: '',
  description: '',
  variant: 'primary',
  size: 'md',
})

// Emits
const emit = defineEmits<{
  'screen-opened': [screenId: string]
}>()

// Use shortcut manager
const { openShortcutScreen, isScreenActive } = useShortcutManager()

// Computed
const buttonLabel = computed(() => {
  return props.label || getScreenLabel(props.screenId as any)
})

const isActive = computed(() => {
  return isScreenActive(props.screenId)
})

// Methods
function handleClick(): void {
  openShortcutScreen(props.screenId)
  emit('screen-opened', props.screenId)
  console.log(`Shortcut button clicked: ${props.screenId}`)
}
</script>

<style scoped>
.shortcut-button {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.shortcut-button:hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.shortcut-button.active {
  box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.5);
}

/* Variants */
.shortcut-button.primary {
  background-color: #007bff;
  color: white;
}

.shortcut-button.primary:hover {
  background-color: #0056b3;
}

.shortcut-button.secondary {
  background-color: #6c757d;
  color: white;
}

.shortcut-button.secondary:hover {
  background-color: #545b62;
}

.shortcut-button.success {
  background-color: #28a745;
  color: white;
}

.shortcut-button.success:hover {
  background-color: #1e7e34;
}

.shortcut-button.warning {
  background-color: #ffc107;
  color: #212529;
}

.shortcut-button.warning:hover {
  background-color: #e0a800;
}

.shortcut-button.danger {
  background-color: #dc3545;
  color: white;
}

.shortcut-button.danger:hover {
  background-color: #c82333;
}

/* Sizes */
.shortcut-button.sm {
  padding: 4px 8px;
  font-size: 12px;
}

.shortcut-button.lg {
  padding: 12px 24px;
  font-size: 16px;
}
</style>
