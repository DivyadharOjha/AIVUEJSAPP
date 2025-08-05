<template>
  <div class="shortcut-manager">
    <!-- This component doesn't render anything visible -->
    <!-- It's a utility component for managing shortcut screens -->
  </div>
</template>

<script setup lang="ts">
import { ref, provide } from 'vue'

// Available shortcut screens
interface ShortcutScreen {
  id: string
  label: string
  description?: string
}

const availableShortcutScreens: ShortcutScreen[] = [
  { id: 'default', label: 'Default', description: 'Welcome screen' },
  { id: '1', label: 'Search Member 1', description: 'Member search screen' },
  { id: '2', label: 'Search Member 2', description: 'Member search screen' },
  { id: '3', label: 'Search Member 3', description: 'Member search screen' },
  { id: '21', label: 'Cash In/Out Collection', description: 'Cash In/Out Collection Form' },
  { id: 'cash-in-pay', label: 'Cash In-Pay', description: 'Cash In-Pay Details Form' },
  { id: 'calendar-control', label: 'Calendar Control', description: 'Single calendar input' },
  { id: 'multi-calendar', label: 'Multi Calendar', description: 'Multi-calendar system' },
  { id: 'font-test', label: 'Font Test', description: 'Times New Roman TTF testing' },
  { id: 'template-test', label: 'Template Test', description: 'Template testing component' },
]

// Reactive state
const currentScreen = ref<string>('default')
const isShortcutActive = ref(false)

// Provide these values to child components
provide('shortcutManager', {
  currentScreen,
  isShortcutActive,
  availableShortcutScreens,
  openShortcutScreen,
  closeShortcutScreen,
  getCurrentScreen,
  isScreenActive,
})

// Function to open a shortcut screen by ID
function openShortcutScreen(screenId: string): void {
  if (availableShortcutScreens.find((screen) => screen.id === screenId)) {
    currentScreen.value = screenId
    isShortcutActive.value = true
    console.log(`Shortcut screen opened: ${screenId}`)
  } else {
    console.warn(`Shortcut screen not found: ${screenId}`)
  }
}

// Function to close shortcut screen
function closeShortcutScreen(): void {
  isShortcutActive.value = false
  currentScreen.value = 'default'
  console.log('Shortcut screen closed')
}

// Function to get current screen
function getCurrentScreen(): string {
  return currentScreen.value
}

// Function to check if a specific screen is active
function isScreenActive(screenId: string): boolean {
  return currentScreen.value === screenId && isShortcutActive.value
}

// Function to get screen info by ID
function getScreenInfo(screenId: string): ShortcutScreen | undefined {
  return availableShortcutScreens.find((screen) => screen.id === screenId)
}

// Function to get all available screens
function getAllScreens(): ShortcutScreen[] {
  return availableShortcutScreens
}

// Expose functions for external use
defineExpose({
  openShortcutScreen,
  closeShortcutScreen,
  getCurrentScreen,
  isScreenActive,
  getScreenInfo,
  getAllScreens,
  currentScreen,
  isShortcutActive,
})
</script>

<style scoped>
.shortcut-manager {
  /* This component doesn't render anything visible */
  display: none;
}
</style>
