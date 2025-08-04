<template>
  <div class="calendar-control-container">
    <!-- Control Group with Textbox and Calendar Icon -->
    <div
      class="control-group"
      :class="{ focused: isFocused, 'dropdown-open': showDropdown }"
      @click="focusTextbox"
    >
      <input
        ref="textboxRef"
        type="text"
        v-model="displayValue"
        class="calendar-textbox"
        placeholder="Select date..."
        readonly
        @focus="handleFocus"
        @blur="handleBlur"
      />
      <div class="calendar-icon" @click.stop="toggleDropdown">📅</div>
    </div>

    <!-- Calendar Dropdown -->
    <div v-if="showDropdown" class="calendar-dropdown">
      <!-- Header Row with Previous, Year Dropdown, Next -->
      <div class="calendar-header">
        <div class="calendar-nav">
          <button class="nav-btn prev-btn" @click="previousMonth" title="Previous Month">‹</button>

          <div class="year-selector">
            <select v-model="selectedYear" @change="changeYear" class="year-dropdown">
              <option v-for="year in availableYears" :key="year" :value="year">
                {{ year }}
              </option>
            </select>
          </div>

          <button class="nav-btn next-btn" @click="nextMonth" title="Next Month">›</button>
        </div>
      </div>

      <!-- Month Display -->
      <div class="month-display">
        <h6 class="month-title">{{ currentMonthName }} {{ selectedYear }}</h6>
      </div>

      <!-- Calendar Grid -->
      <div class="calendar-grid">
        <!-- Day Headers -->
        <div class="day-headers">
          <div v-for="day in dayHeaders" :key="day" class="day-header">
            {{ day }}
          </div>
        </div>

        <!-- Calendar Days -->
        <div class="calendar-days">
          <div
            v-for="day in calendarDays"
            :key="day.key"
            :class="[
              'calendar-day',
              {
                'other-month': !day.isCurrentMonth,
                today: day.isToday,
                selected: day.isSelected,
              },
            ]"
            @click="selectDate(day)"
          >
            <span class="day-number">{{ day.dayNumber }}</span>
          </div>
        </div>
      </div>

      <!-- Quick Actions -->
      <div class="calendar-actions">
        <button class="btn btn-sm btn-primary" @click="goToToday">📅 Today</button>
        <button class="btn btn-sm btn-outline-secondary" @click="closeDropdown">Close</button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, nextTick, watch } from 'vue'

// Props
interface Props {
  modelValue?: Date | null
  placeholder?: string
  format?: string
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: null,
  placeholder: 'Select date...',
  format: 'DD/MM/YYYY',
})

// Emits
const emit = defineEmits<{
  'update:modelValue': [date: Date | null]
  'date-selected': [date: Date]
}>()

// Reactive data
const textboxRef = ref<HTMLInputElement>()
const isFocused = ref(false)
const showDropdown = ref(false)
const currentDate = ref(new Date())
const selectedYear = ref(new Date().getFullYear())

// Calendar configuration
const dayHeaders = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
const monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
]

// Computed properties
const displayValue = computed(() => {
  if (!props.modelValue) return ''
  return formatDate(props.modelValue)
})

const currentMonthName = computed(() => {
  return monthNames[currentDate.value.getMonth()]
})

const availableYears = computed(() => {
  const currentYear = new Date().getFullYear()
  const years = []
  for (let i = currentYear - 10; i <= currentYear + 10; i++) {
    years.push(i)
  }
  return years
})

const calendarDays = computed(() => {
  const year = currentDate.value.getFullYear()
  const month = currentDate.value.getMonth()

  // Get first day of month and last day of month
  const firstDay = new Date(year, month, 1)
  const lastDay = new Date(year, month + 1, 0)

  // Get first day of week (0 = Sunday)
  const firstDayOfWeek = firstDay.getDay()

  // Get last day of month
  const lastDayOfMonth = lastDay.getDate()

  // Get last day of previous month
  const lastDayOfPrevMonth = new Date(year, month, 0).getDate()

  const days = []

  // Add days from previous month
  for (let i = 0; i < firstDayOfWeek; i++) {
    const dayNumber = lastDayOfPrevMonth - firstDayOfWeek + i + 1
    const date = new Date(year, month - 1, dayNumber)
    days.push({
      key: `prev-${dayNumber}`,
      dayNumber,
      date,
      isCurrentMonth: false,
      isToday: isToday(date),
      isSelected: isSelectedDate(date),
    })
  }

  // Add days from current month
  for (let dayNumber = 1; dayNumber <= lastDayOfMonth; dayNumber++) {
    const date = new Date(year, month, dayNumber)
    days.push({
      key: `current-${dayNumber}`,
      dayNumber,
      date,
      isCurrentMonth: true,
      isToday: isToday(date),
      isSelected: isSelectedDate(date),
    })
  }

  // Add days from next month to fill the grid
  const remainingDays = 42 - days.length // 6 rows * 7 days = 42
  for (let dayNumber = 1; dayNumber <= remainingDays; dayNumber++) {
    const date = new Date(year, month + 1, dayNumber)
    days.push({
      key: `next-${dayNumber}`,
      dayNumber,
      date,
      isCurrentMonth: false,
      isToday: isToday(date),
      isSelected: isSelectedDate(date),
    })
  }

  return days
})

// Methods
function formatDate(date: Date): string {
  const day = date.getDate().toString().padStart(2, '0')
  const month = (date.getMonth() + 1).toString().padStart(2, '0')
  const year = date.getFullYear()
  return `${day}/${month}/${year}`
}

function isToday(date: Date): boolean {
  const today = new Date()
  return date.toDateString() === today.toDateString()
}

function isSelectedDate(date: Date): boolean {
  if (!props.modelValue) return false
  return date.toDateString() === props.modelValue.toDateString()
}

function handleFocus(): void {
  isFocused.value = true
}

function handleBlur(): void {
  // Delay to allow dropdown clicks
  setTimeout(() => {
    isFocused.value = false
  }, 100)
}

function focusTextbox(): void {
  textboxRef.value?.focus()
}

function toggleDropdown(): void {
  showDropdown.value = !showDropdown.value
  if (showDropdown.value) {
    nextTick(() => {
      textboxRef.value?.focus()
    })
  }
}

function closeDropdown(): void {
  showDropdown.value = false
  isFocused.value = false
}

function previousMonth(): void {
  currentDate.value = new Date(currentDate.value.getFullYear(), currentDate.value.getMonth() - 1, 1)
  selectedYear.value = currentDate.value.getFullYear()
}

function nextMonth(): void {
  currentDate.value = new Date(currentDate.value.getFullYear(), currentDate.value.getMonth() + 1, 1)
  selectedYear.value = currentDate.value.getFullYear()
}

function changeYear(): void {
  currentDate.value = new Date(selectedYear.value, currentDate.value.getMonth(), 1)
}

function selectDate(day: any): void {
  if (!day.isCurrentMonth) return

  const selectedDate = new Date(day.date)
  emit('update:modelValue', selectedDate)
  emit('date-selected', selectedDate)
  closeDropdown()
}

function goToToday(): void {
  const today = new Date()
  currentDate.value = new Date(today.getFullYear(), today.getMonth(), 1)
  selectedYear.value = today.getFullYear()

  emit('update:modelValue', today)
  emit('date-selected', today)
  closeDropdown()
}

// Watch for external clicks to close dropdown
onMounted(() => {
  document.addEventListener('click', (event) => {
    const target = event.target as HTMLElement
    if (!target.closest('.calendar-control-container')) {
      closeDropdown()
    }
  })
})

// Watch for modelValue changes
watch(
  () => props.modelValue,
  (newValue) => {
    if (newValue) {
      currentDate.value = new Date(newValue.getFullYear(), newValue.getMonth(), 1)
      selectedYear.value = newValue.getFullYear()
    }
  },
)
</script>

<style scoped>
.calendar-control-container {
  position: relative;
  display: inline-block;
  width: 100%;
  max-width: 300px;
}

.control-group {
  display: flex;
  align-items: center;
  border: 1px solid #ced4da;
  border-radius: 6px;
  background-color: #fff;
  transition: all 0.2s ease;
  cursor: text;
}

.control-group:hover {
  border-color: #adb5bd;
}

.control-group.focused {
  border-color: #6c757d;
  box-shadow: 0 0 0 0.2rem rgba(108, 117, 125, 0.25);
}

.control-group.dropdown-open {
  border-color: #007bff;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.calendar-textbox {
  flex: 1;
  border: none;
  outline: none;
  padding: 8px 12px;
  font-size: 14px;
  background: transparent;
  cursor: text;
}

.calendar-textbox:focus {
  outline: none;
  border: none;
  box-shadow: none;
}

.calendar-icon {
  padding: 8px 12px;
  cursor: pointer;
  color: #6c757d;
  transition: color 0.2s ease;
  border-left: 1px solid #ced4da;
  font-size: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.calendar-icon:hover {
  color: #007bff;
}

.calendar-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  background: #fff;
  border: 1px solid #ced4da;
  border-radius: 6px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  z-index: 1000;
  margin-top: 4px;
  min-width: 280px;
}

.calendar-header {
  padding: 12px;
  border-bottom: 1px solid #e9ecef;
  background: #f8f9fa;
}

.calendar-nav {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.nav-btn {
  background: none;
  border: 1px solid #ced4da;
  border-radius: 4px;
  padding: 6px 8px;
  cursor: pointer;
  color: #6c757d;
  transition: all 0.2s ease;
  font-size: 18px;
  font-weight: bold;
  min-width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.nav-btn:hover {
  background-color: #e9ecef;
  border-color: #adb5bd;
  color: #495057;
}

.year-selector {
  flex: 1;
  display: flex;
  justify-content: center;
}

.year-dropdown {
  border: 1px solid #ced4da;
  border-radius: 4px;
  padding: 6px 8px;
  background: #fff;
  font-size: 14px;
  cursor: pointer;
  min-width: 80px;
}

.month-display {
  padding: 8px 12px;
  text-align: center;
  border-bottom: 1px solid #e9ecef;
}

.month-title {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #495057;
}

.calendar-grid {
  padding: 12px;
}

.day-headers {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 2px;
  margin-bottom: 8px;
}

.day-header {
  text-align: center;
  font-weight: 600;
  color: #6c757d;
  font-size: 12px;
  padding: 4px;
}

.calendar-days {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 2px;
}

.calendar-day {
  aspect-ratio: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 14px;
  border: 1px solid transparent;
}

.calendar-day:hover {
  background-color: #f8f9fa;
  border-color: #dee2e6;
}

.calendar-day.other-month {
  color: #adb5bd;
}

.calendar-day.today {
  background-color: #007bff;
  color: white;
  font-weight: 600;
}

.calendar-day.selected {
  background-color: #28a745;
  color: white;
  font-weight: 600;
}

.day-number {
  font-size: 14px;
  font-weight: 500;
}

.calendar-actions {
  display: flex;
  gap: 8px;
  padding: 12px;
  border-top: 1px solid #e9ecef;
  background: #f8f9fa;
}

.calendar-actions .btn {
  flex: 1;
  font-size: 12px;
}

/* Responsive design */
@media (max-width: 576px) {
  .calendar-dropdown {
    min-width: 260px;
  }

  .calendar-nav {
    gap: 4px;
  }

  .nav-btn {
    padding: 4px 6px;
  }

  .year-dropdown {
    min-width: 60px;
    font-size: 12px;
  }
}
</style>
