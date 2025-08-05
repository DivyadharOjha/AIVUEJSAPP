# Shortcut System Usage Guide

## Overview

The shortcut system provides a centralized way to manage and open different screens in the application. It consists of several components and utilities that work together to provide a seamless experience.

## Components

### 1. posShortcutManager.vue

A utility component that manages the state of shortcut screens.

**Features:**

- Manages current active screen
- Provides functions to open/close screens
- Validates screen IDs
- Provides reactive state

### 2. posShortcutButton.vue

A reusable button component that can open any shortcut screen.

**Usage:**

```vue
<template>
  <!-- Basic usage -->
  <posShortcutButton screen-id="cash-in-pay" />

  <!-- With custom label and description -->
  <posShortcutButton
    screen-id="calendar-control"
    label="Open Calendar"
    description="Open the calendar control screen"
    variant="success"
    size="lg"
  />

  <!-- With slot content -->
  <posShortcutButton screen-id="font-test" variant="warning">
    <span>🎨</span> Font Test
  </posShortcutButton>
</template>
```

### 3. useShortcutManager.ts

A composable that provides access to shortcut management functions.

**Usage:**

```vue
<script setup lang="ts">
import { useShortcutManager } from '@/composables/useShortcutManager'

const { openShortcutScreen, closeShortcutScreen, isScreenActive, currentScreen, isShortcutActive } =
  useShortcutManager()

// Open a screen
function openCashInPay() {
  openShortcutScreen('cash-in-pay')
}

// Check if a screen is active
const isCashInPayActive = isScreenActive('cash-in-pay')

// Close current screen
function closeCurrentScreen() {
  closeShortcutScreen()
}
</script>
```

## Available Screens

| Screen ID          | Label            | Description                 |
| ------------------ | ---------------- | --------------------------- |
| `default`          | Default          | Welcome screen              |
| `cash-in-pay`      | Cash In-Pay      | Cash In-Pay Details Form    |
| `calendar-control` | Calendar Control | Single calendar input       |
| `multi-calendar`   | Multi Calendar   | Multi-calendar system       |
| `font-test`        | Font Test        | Times New Roman TTF testing |
| `template-test`    | Template Test    | Template testing component  |

## Utility Functions

### ShortcutUtils

```typescript
import { ShortcutUtils } from '@/utils/shortcutUtils'

// Get screen ID for Cash In-Pay
const cashInPayId = ShortcutUtils.openCashInPay() // Returns 'cash-in-pay'

// Get screen ID for Calendar Control
const calendarId = ShortcutUtils.openCalendarControl() // Returns 'calendar-control'
```

### SCREEN_IDS Constants

```typescript
import { SCREEN_IDS } from '@/utils/shortcutUtils'

// Use constants for type safety
openShortcutScreen(SCREEN_IDS.CASH_IN_PAY)
openShortcutScreen(SCREEN_IDS.CALENDAR_CONTROL)
```

### Validation Functions

```typescript
import { isValidScreenId, getScreenLabel } from '@/utils/shortcutUtils'

// Validate a screen ID
if (isValidScreenId('cash-in-pay')) {
  // Screen ID is valid
}

// Get label for a screen
const label = getScreenLabel('cash-in-pay') // Returns 'Cash In-Pay'
```

## Integration with Main Screen

The main screen (`posMainScreen.vue`) includes the shortcut manager and handles screen switching:

```vue
<template>
  <!-- Shortcut Manager (invisible utility component) -->
  <posShortcutManager ref="shortcutManagerRef" />

  <!-- Dynamic screen content -->
  <div v-if="showShortcutScreen" class="shortcut-screen-container">
    <div v-if="selectedShortcutScreen === 'cash-in-pay'" class="screen-content">
      <posCashInOutColl />
    </div>
    <!-- Other screens... -->
  </div>
</template>

<script setup lang="ts">
import posShortcutManager from './posShortcutManager.vue'

const shortcutManagerRef = ref()

function handleShortcutScreenSelected(screenId: string): void {
  // Use the shortcut manager to open the screen
  if (shortcutManagerRef.value) {
    shortcutManagerRef.value.openShortcutScreen(screenId)
  }
  selectedShortcutScreen.value = screenId
  showShortcutModal.value = false
}
</script>
```

## Best Practices

### 1. Use Constants for Screen IDs

```typescript
// ✅ Good
openShortcutScreen(SCREEN_IDS.CASH_IN_PAY)

// ❌ Avoid
openShortcutScreen('cash-in-pay')
```

### 2. Validate Screen IDs

```typescript
// ✅ Good
if (isValidScreenId(screenId)) {
  openShortcutScreen(screenId)
}

// ❌ Avoid
openShortcutScreen(screenId) // No validation
```

### 3. Use the Composable for State Management

```typescript
// ✅ Good
const { currentScreen, isShortcutActive } = useShortcutManager()

// ❌ Avoid
// Directly accessing refs without the composable
```

### 4. Handle Missing Manager Gracefully

```typescript
// ✅ Good
const { openShortcutScreen } = useShortcutManager()
// The composable provides fallback functions if manager is not available

// ❌ Avoid
// Assuming the manager is always available
```

## Example: Adding a New Screen

1. **Add the screen ID to constants:**

```typescript
// In utils/shortcutUtils.ts
export const SCREEN_IDS = {
  // ... existing screens
  NEW_SCREEN: 'new-screen',
} as const
```

2. **Add the screen to the manager:**

```typescript
// In posShortcutManager.vue
export const availableShortcutScreens: ShortcutScreen[] = [
  // ... existing screens
  { id: 'new-screen', label: 'New Screen', description: 'New screen description' },
]
```

3. **Add the screen content to main screen:**

```vue
<!-- In posMainScreen.vue -->
<div v-if="selectedShortcutScreen === 'new-screen'" class="screen-content">
  <posNewScreen />
</div>
```

4. **Create a button to open it:**

```vue
<posShortcutButton screen-id="new-screen" label="New Screen" />
```

## Troubleshooting

### Common Issues

1. **Screen not opening:**

   - Check if `posShortcutManager` is mounted in the parent component
   - Verify the screen ID is valid using `isValidScreenId()`
   - Check console for error messages

2. **Manager not found:**

   - Ensure `posShortcutManager` is imported and used in the parent component
   - Check that the composable is used within the component tree

3. **Screen content not showing:**
   - Verify the screen ID matches between the manager and the template
   - Check that the component for the screen is imported and available

### Debug Mode

Enable debug logging by checking the console for:

- `Shortcut screen opened: [screenId]`
- `Shortcut screen closed`
- `Shortcut button clicked: [screenId]`

This system provides a robust, type-safe way to manage shortcut screens throughout the application.
