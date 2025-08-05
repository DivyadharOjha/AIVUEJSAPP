// Utility functions for opening shortcut screens
export const ShortcutUtils = {
  // Open Search Member screens
  openSearchMember1: () => {
    console.log('Opening Search Member 1 screen')
    return '1'
  },

  openSearchMember2: () => {
    console.log('Opening Search Member 2 screen')
    return '2'
  },

  openSearchMember3: () => {
    console.log('Opening Search Member 3 screen')
    return '3'
  },

  // Open Cash In/Out Collection screen
  openCashInOutCollection: () => {
    console.log('Opening Cash In/Out Collection screen')
    return '21'
  },

  // Open Cash In-Pay screen
  openCashInPay: () => {
    // This will be called from components that have access to the shortcut manager
    console.log('Opening Cash In-Pay screen')
    return 'cash-in-pay'
  },

  // Open Calendar Control screen
  openCalendarControl: () => {
    console.log('Opening Calendar Control screen')
    return 'calendar-control'
  },

  // Open Multi Calendar screen
  openMultiCalendar: () => {
    console.log('Opening Multi Calendar screen')
    return 'multi-calendar'
  },

  // Open Font Test screen
  openFontTest: () => {
    console.log('Opening Font Test screen')
    return 'font-test'
  },

  // Open Template Test screen
  openTemplateTest: () => {
    console.log('Opening Template Test screen')
    return 'template-test'
  },

  // Open Default screen
  openDefault: () => {
    console.log('Opening Default screen')
    return 'default'
  },
}

// Screen ID constants
export const SCREEN_IDS = {
  DEFAULT: 'default',
  SEARCH_MEMBER_1: '1',
  SEARCH_MEMBER_2: '2',
  SEARCH_MEMBER_3: '3',
  CASH_IN_OUT_COLLECTION: '21',
  CASH_IN_PAY: 'cash-in-pay',
  CALENDAR_CONTROL: 'calendar-control',
  MULTI_CALENDAR: 'multi-calendar',
  FONT_TEST: 'font-test',
  TEMPLATE_TEST: 'template-test',
} as const

// Type for screen IDs
export type ScreenId = (typeof SCREEN_IDS)[keyof typeof SCREEN_IDS]

// Function to validate screen ID
export function isValidScreenId(screenId: string): screenId is ScreenId {
  return Object.values(SCREEN_IDS).includes(screenId as ScreenId)
}

// Function to get screen label by ID
export function getScreenLabel(screenId: ScreenId): string {
  const labels: Record<ScreenId, string> = {
    [SCREEN_IDS.DEFAULT]: 'Default',
    [SCREEN_IDS.SEARCH_MEMBER_1]: 'Search Member 1',
    [SCREEN_IDS.SEARCH_MEMBER_2]: 'Search Member 2',
    [SCREEN_IDS.SEARCH_MEMBER_3]: 'Search Member 3',
    [SCREEN_IDS.CASH_IN_OUT_COLLECTION]: 'Cash In/Out Collection',
    [SCREEN_IDS.CASH_IN_PAY]: 'Cash In-Pay',
    [SCREEN_IDS.CALENDAR_CONTROL]: 'Calendar Control',
    [SCREEN_IDS.MULTI_CALENDAR]: 'Multi Calendar',
    [SCREEN_IDS.FONT_TEST]: 'Font Test',
    [SCREEN_IDS.TEMPLATE_TEST]: 'Template Test',
  }
  return labels[screenId] || 'Unknown'
}
