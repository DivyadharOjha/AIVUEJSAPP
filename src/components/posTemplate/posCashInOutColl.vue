<template>
  <div class="cash-inout-container">
    <posCalendar
      :initial-date="props.initialDate"
      :initial-calendar-type="props.initialCalendarType"
      :show-events="props.showEvents"
      @date-selected="handleDateSelected"
      @calendar-type-changed="handleCalendarTypeChanged"
    />
  </div>
</template>

<script setup lang="ts">
import posCalendar from './posCalendar.vue'

// Props
interface Props {
  initialDate?: Date
  initialCalendarType?: 'gregorian' | 'hijri' | 'shamshi' | 'bikram'
  showEvents?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  initialDate: () => new Date(),
  initialCalendarType: 'gregorian',
  showEvents: true,
})

// Emits
const emit = defineEmits<{
  'date-selected': [date: Date, calendarType: string, formattedDate: string]
  'calendar-type-changed': [calendarType: string]
}>()

// Event handlers
function handleDateSelected(date: Date, calendarType: string, formattedDate: string): void {
  emit('date-selected', date, calendarType, formattedDate)
}

function handleCalendarTypeChanged(calendarType: string): void {
  emit('calendar-type-changed', calendarType)
}
</script>

<style scoped>
.cash-inout-container {
  background: #ffffff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  padding: 16px;
}
</style>
