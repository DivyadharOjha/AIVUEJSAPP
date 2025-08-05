import { inject, ref } from 'vue'

// Interface for shortcut manager
interface ShortcutManager {
  currentScreen: any
  isShortcutActive: any
  availableShortcutScreens: any[]
  openShortcutScreen: (screenId: string) => void
  closeShortcutScreen: () => void
  getCurrentScreen: () => string
  isScreenActive: (screenId: string) => boolean
}

// Composable function
export function useShortcutManager() {
  // Try to inject the shortcut manager
  const shortcutManager = inject<ShortcutManager>('shortcutManager')

  if (!shortcutManager) {
    console.warn('ShortcutManager not found. Make sure posShortcutManager is mounted.')
    return {
      openShortcutScreen: () => {},
      closeShortcutScreen: () => {},
      getCurrentScreen: () => 'default',
      isScreenActive: () => false,
      isShortcutActive: ref(false),
      currentScreen: ref('default'),
      availableShortcutScreens: [],
    }
  }

  return {
    // Functions
    openShortcutScreen: shortcutManager.openShortcutScreen,
    closeShortcutScreen: shortcutManager.closeShortcutScreen,
    getCurrentScreen: shortcutManager.getCurrentScreen,
    isScreenActive: shortcutManager.isScreenActive,

    // Reactive state
    isShortcutActive: shortcutManager.isShortcutActive,
    currentScreen: shortcutManager.currentScreen,
    availableShortcutScreens: shortcutManager.availableShortcutScreens,
  }
}

// Utility functions for direct screen opening
export const ShortcutScreens = {
  DEFAULT: 'default',
  CASH_IN_PAY: 'cash-in-pay',
  CALENDAR_CONTROL: 'calendar-control',
  MULTI_CALENDAR: 'multi-calendar',
  FONT_TEST: 'font-test',
  TEMPLATE_TEST: 'template-test',
} as const

// Type for screen IDs
export type ShortcutScreenId = (typeof ShortcutScreens)[keyof typeof ShortcutScreens]
