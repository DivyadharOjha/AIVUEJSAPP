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
        :placeholder="placeholder"
        readonly
        @focus="handleFocus"
        @blur="handleBlur"
      />
      <div class="calendar-icon" @click.stop="toggleDropdown">📅</div>
    </div>

    <!-- Calendar Dropdown -->
    <div v-if="showDropdown" class="calendar-dropdown">
      <!-- Calendar Type Selector -->
      <div class="calendar-type-selector">
        <select
          v-model="selectedCalendarType"
          @change="changeCalendarType"
          class="calendar-type-dropdown"
        >
          <option value="gregorian">Gregorian</option>
          <option value="hijri">Hijri</option>
          <option value="shamshi">Shamshi</option>
          <option value="bikram">Bikram</option>
        </select>
      </div>

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
        <h6 class="month-title">{{ currentMonthYear }}</h6>
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
// @ts-expect-error - moment-hijri doesn't have TypeScript definitions
import moment from 'moment-hijri'
// @ts-expect-error - moment-jalaali doesn't have TypeScript definitions
import momentJalaali from 'moment-jalaali'
// @ts-expect-error - nepali-date doesn't have TypeScript definitions
import NepaliDate from 'nepali-date'

// Interfaces
interface Props {
  modelValue?: Date | null
  placeholder?: string
  format?: string
  initialCalendarType?: 'gregorian' | 'hijri' | 'shamshi' | 'bikram'
}

interface CalendarDay {
  key: string
  dayNumber: number
  date: Date
  isCurrentMonth: boolean
  isToday: boolean
  isSelected: boolean
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: null,
  placeholder: 'Select date...',
  format: 'DD/MM/YYYY',
  initialCalendarType: 'gregorian',
})

// Emits
const emit = defineEmits<{
  'update:modelValue': [date: Date | null]
  'date-selected': [date: Date]
  'calendar-type-changed': [calendarType: string]
}>()

// Reactive data
const textboxRef = ref<HTMLInputElement>()
const isFocused = ref(false)
const showDropdown = ref(false)
const currentDate = ref(new Date())
const selectedYear = ref(new Date().getFullYear())
const selectedCalendarType = ref(props.initialCalendarType)

// Calendar configuration
const dayHeadersConfig = {
  gregorian: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
  hijri: ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'],
  shamshi: ['یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنج‌شنبه', 'جمعه', 'شنبه'],
  bikram: ['आइत', 'सोम', 'मंगल', 'बुध', 'बिहि', 'शुक्र', 'शनि'],
}

const calendarConfigs = {
  gregorian: {
    name: 'Gregorian',
    months: [
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
    ],
  },
  hijri: {
    name: 'Hijri',
    months: [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الثاني',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ],
  },
  shamshi: {
    name: 'Shamshi',
    months: [
      'فروردین',
      'اردیبهشت',
      'خرداد',
      'تیر',
      'مرداد',
      'شهریور',
      'مهر',
      'آبان',
      'آذر',
      'دی',
      'بهمن',
      'اسفند',
    ],
  },
  bikram: {
    name: 'Bikram',
    months: [
      'बैशाख',
      'जेठ',
      'असार',
      'श्रावण',
      'भदौ',
      'असोज',
      'कार्तिक',
      'मंसिर',
      'पुष',
      'माघ',
      'फाल्गुन',
      'चैत',
    ],
  },
}

// Multi-Calendar Conversion Functions
// =================================

// 1. HIJRI CALENDAR (Lunar Calendar) - Using moment-hijri
function gregorianToHijri(date: Date): { year: number; month: number; day: number } {
  try {
    const hijriMoment = moment(date).format('iYYYY/iM/iD')
    const [year, month, day] = hijriMoment.split('/').map(Number)
    console.log(`moment-hijri conversion: ${date.toDateString()} -> ${hijriMoment}`)
    return { year, month, day }
  } catch (error) {
    console.error('Error in gregorianToHijri:', error)
    return { year: 1447, month: 1, day: 1 } // Fallback
  }
}

// 2. SHAMSHI/PERSIAN CALENDAR (Solar Calendar) - Using moment-jalaali
function gregorianToShamshi(date: Date): { year: number; month: number; day: number } {
  try {
    const jalaaliMoment = momentJalaali(date)
    const jalaaliYear = jalaaliMoment.jYear()
    const jalaaliMonth = jalaaliMoment.jMonth() + 1 // moment-jalaali months are 0-based
    const jalaaliDay = jalaaliMoment.jDate()
    console.log(
      `moment-jalaali conversion: ${date.toDateString()} -> ${jalaaliYear}/${jalaaliMonth}/${jalaaliDay}`,
    )
    return {
      year: jalaaliYear,
      month: jalaaliMonth,
      day: jalaaliDay,
    }
  } catch (error) {
    console.error('Error in gregorianToShamshi:', error)
    return { year: 1404, month: 1, day: 1 } // Fallback
  }
}

// 3. BIKRAM SAMBAT CALENDAR (Solar Calendar) - Using nepali-date
function gregorianToBikram(date: Date): { year: number; month: number; day: number } {
  try {
    const nepaliDate = new NepaliDate(date)
    const bikramYear = nepaliDate.getYear()
    const bikramMonth = nepaliDate.getMonth() + 1 // nepali-date months are 0-based
    const bikramDay = nepaliDate.getDate()
    console.log(
      `nepali-date conversion: ${date.toDateString()} -> ${bikramYear}/${bikramMonth}/${bikramDay}`,
    )
    return {
      year: bikramYear,
      month: bikramMonth,
      day: bikramDay,
    }
  } catch (error) {
    console.error('Error in gregorianToBikram:', error)
    return { year: 2082, month: 1, day: 1 } // Fallback
  }
}

// Computed properties
const dayHeaders = computed(() => {
  return dayHeadersConfig[selectedCalendarType.value]
})

const currentMonthYear = computed(() => {
  const config = calendarConfigs[selectedCalendarType.value]
  let month: string
  let year: number

  switch (selectedCalendarType.value) {
    case 'hijri': {
      const hijriDate = gregorianToHijri(currentDate.value)
      month = config.months[hijriDate.month - 1]
      year = hijriDate.year
      break
    }
    case 'shamshi': {
      const shamshiDate = gregorianToShamshi(currentDate.value)
      month = config.months[shamshiDate.month - 1]
      year = shamshiDate.year
      break
    }
    case 'bikram': {
      const bikramDate = gregorianToBikram(currentDate.value)
      month = config.months[bikramDate.month - 1]
      year = bikramDate.year
      break
    }
    default: {
      // Gregorian calendar
      month = config.months[currentDate.value.getMonth()]
      year = currentDate.value.getFullYear()
      break
    }
  }

  return `${month} ${year}`
})

const displayValue = computed(() => {
  if (!props.modelValue) return ''
  return formatDate(props.modelValue)
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

  const days: CalendarDay[] = []

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
  const day = date.getDate()
  const month = date.getMonth() + 1
  const year = date.getFullYear()

  switch (selectedCalendarType.value) {
    case 'hijri': {
      const hijriDate = gregorianToHijri(date)
      const hijriMonthName = calendarConfigs.hijri.months[hijriDate.month - 1]
      return `${hijriDate.day}/${hijriMonthName}/${hijriDate.year}`
    }
    case 'shamshi': {
      const shamshiDate = gregorianToShamshi(date)
      const shamshiMonthName = calendarConfigs.shamshi.months[shamshiDate.month - 1]
      return `${shamshiDate.day}/${shamshiMonthName}/${shamshiDate.year}`
    }
    case 'bikram': {
      const bikramDate = gregorianToBikram(date)
      const bikramMonthName = calendarConfigs.bikram.months[bikramDate.month - 1]
      return `${bikramDate.day}/${bikramMonthName}/${bikramDate.year}`
    }
    default: {
      const monthName = calendarConfigs.gregorian.months[month - 1]
      return `${day}/${monthName}/${year}`
    }
  }
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

function changeCalendarType(): void {
  console.log('Calendar type changed to:', selectedCalendarType.value)
  emit('calendar-type-changed', selectedCalendarType.value)
}

function previousMonth(): void {
  try {
    if (selectedCalendarType.value === 'hijri') {
      // For Hijri calendar, navigate based on Hijri months
      const currentHijri = gregorianToHijri(currentDate.value)
      const previousHijriMonth = currentHijri.month === 1 ? 12 : currentHijri.month - 1
      const previousHijriYear = currentHijri.month === 1 ? currentHijri.year - 1 : currentHijri.year

      // Convert back to Gregorian for display
      const hijriMoment = moment(
        `${previousHijriYear}-${previousHijriMonth.toString().padStart(2, '0')}-01`,
        'iYYYY-iM-iD',
      )
      currentDate.value = hijriMoment.toDate()
    } else if (selectedCalendarType.value === 'shamshi') {
      // For Shamshi calendar, navigate based on Jalali months using moment-jalaali
      const currentShamshi = gregorianToShamshi(currentDate.value)
      const previousShamshiMonth = currentShamshi.month === 1 ? 12 : currentShamshi.month - 1
      const previousShamshiYear =
        currentShamshi.month === 1 ? currentShamshi.year - 1 : currentShamshi.year

      // Convert back to Gregorian for display using moment-jalaali
      const jalaaliMoment = momentJalaali.jMoment(
        `${previousShamshiYear}/${previousShamshiMonth}/01`,
        'jYYYY/jM/jD',
      )
      currentDate.value = jalaaliMoment.toDate()
    } else if (selectedCalendarType.value === 'bikram') {
      // For Bikram calendar, navigate based on Nepali months using nepali-date
      const currentBikram = gregorianToBikram(currentDate.value)
      const previousBikramMonth = currentBikram.month === 1 ? 12 : currentBikram.month - 1
      const previousBikramYear =
        currentBikram.month === 1 ? currentBikram.year - 1 : currentBikram.year

      // Convert back to Gregorian for display using nepali-date
      const nepaliDate = new NepaliDate(previousBikramYear, previousBikramMonth - 1, 1)
      currentDate.value = nepaliDate.toJsDate()
    } else {
      // For other calendars, use Gregorian navigation
      currentDate.value = new Date(
        currentDate.value.getFullYear(),
        currentDate.value.getMonth() - 1,
        1,
      )
    }
    selectedYear.value = currentDate.value.getFullYear()
  } catch (error) {
    console.error('Error in previousMonth:', error)
    // Fallback to simple Gregorian navigation
    currentDate.value = new Date(
      currentDate.value.getFullYear(),
      currentDate.value.getMonth() - 1,
      1,
    )
    selectedYear.value = currentDate.value.getFullYear()
  }
}

function nextMonth(): void {
  try {
    if (selectedCalendarType.value === 'hijri') {
      // For Hijri calendar, navigate based on Hijri months
      const currentHijri = gregorianToHijri(currentDate.value)
      const nextHijriMonth = currentHijri.month === 12 ? 1 : currentHijri.month + 1
      const nextHijriYear = currentHijri.month === 12 ? currentHijri.year + 1 : currentHijri.year

      // Convert back to Gregorian for display
      const hijriMoment = moment(
        `${nextHijriYear}-${nextHijriMonth.toString().padStart(2, '0')}-01`,
        'iYYYY-iM-iD',
      )
      currentDate.value = hijriMoment.toDate()
    } else if (selectedCalendarType.value === 'shamshi') {
      // For Shamshi calendar, navigate based on Jalali months using moment-jalaali
      const currentShamshi = gregorianToShamshi(currentDate.value)
      const nextShamshiMonth = currentShamshi.month === 12 ? 1 : currentShamshi.month + 1
      const nextShamshiYear =
        currentShamshi.month === 12 ? currentShamshi.year + 1 : currentShamshi.year

      // Convert back to Gregorian for display using moment-jalaali
      const jalaaliMoment = momentJalaali.jMoment(
        `${nextShamshiYear}/${nextShamshiMonth}/01`,
        'jYYYY/jM/jD',
      )
      currentDate.value = jalaaliMoment.toDate()
    } else if (selectedCalendarType.value === 'bikram') {
      // For Bikram calendar, navigate based on Nepali months using nepali-date
      const currentBikram = gregorianToBikram(currentDate.value)
      const nextBikramMonth = currentBikram.month === 12 ? 1 : currentBikram.month + 1
      const nextBikramYear =
        currentBikram.month === 12 ? currentBikram.year + 1 : currentBikram.year

      // Convert back to Gregorian for display using nepali-date
      const nepaliDate = new NepaliDate(nextBikramYear, nextBikramMonth - 1, 1)
      currentDate.value = nepaliDate.toJsDate()
    } else {
      // For other calendars, use Gregorian navigation
      currentDate.value = new Date(
        currentDate.value.getFullYear(),
        currentDate.value.getMonth() + 1,
        1,
      )
    }
    selectedYear.value = currentDate.value.getFullYear()
  } catch (error) {
    console.error('Error in nextMonth:', error)
    // Fallback to simple Gregorian navigation
    currentDate.value = new Date(
      currentDate.value.getFullYear(),
      currentDate.value.getMonth() + 1,
      1,
    )
    selectedYear.value = currentDate.value.getFullYear()
  }
}

function changeYear(): void {
  currentDate.value = new Date(selectedYear.value, currentDate.value.getMonth(), 1)
}

function selectDate(day: CalendarDay): void {
  if (!day.isCurrentMonth) return

  const selectedDate = new Date(day.date)
  emit('update:modelValue', selectedDate)
  emit('date-selected', selectedDate)
  closeDropdown()
}

function goToToday(): void {
  try {
    const today = new Date()

    if (selectedCalendarType.value === 'hijri') {
      // For Hijri calendar, set to first day of current Hijri month
      const todayHijri = gregorianToHijri(today)
      const hijriMoment = moment(
        `${todayHijri.year}-${todayHijri.month.toString().padStart(2, '0')}-01`,
        'iYYYY-iM-iD',
      )
      currentDate.value = hijriMoment.toDate()
    } else if (selectedCalendarType.value === 'shamshi') {
      // For Shamshi calendar, set to first day of current Jalali month using moment-jalaali
      const todayShamshi = gregorianToShamshi(today)
      const jalaaliMoment = momentJalaali.jMoment(
        `${todayShamshi.year}/${todayShamshi.month}/01`,
        'jYYYY/jM/jD',
      )
      currentDate.value = jalaaliMoment.toDate()
    } else if (selectedCalendarType.value === 'bikram') {
      // For Bikram calendar, set to first day of current Nepali month using nepali-date
      const todayBikram = gregorianToBikram(today)
      const nepaliDate = new NepaliDate(todayBikram.year, todayBikram.month - 1, 1)
      currentDate.value = nepaliDate.toJsDate()
    } else {
      // For other calendars, set to first day of current Gregorian month
      currentDate.value = new Date(today.getFullYear(), today.getMonth(), 1)
    }

    selectedYear.value = currentDate.value.getFullYear()

    // Set selected date to today
    emit('update:modelValue', today)
    emit('date-selected', today)
    closeDropdown()
  } catch (error) {
    console.error('Error in goToToday:', error)
    // Fallback to simple Gregorian navigation
    const today = new Date()
    currentDate.value = new Date(today.getFullYear(), today.getMonth(), 1)
    selectedYear.value = today.getFullYear()
    emit('update:modelValue', today)
    emit('date-selected', today)
    closeDropdown()
  }
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
  width: 100%;
  background: #fff;
  border: 1px solid #ced4da;
  border-radius: 6px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  z-index: 1000;
  margin-top: 4px;
}

.calendar-type-selector {
  padding: 8px 12px;
  border-bottom: 1px solid #e9ecef;
  background: #f8f9fa;
}

.calendar-type-dropdown {
  width: 100%;
  border: 1px solid #ced4da;
  border-radius: 4px;
  padding: 6px 30px 6px 8px; /* Added right padding for arrow spacing */
  background: #fff;
  font-size: 14px;
  cursor: pointer;
  appearance: none; /* Remove default browser styling */
  background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6,9 12,15 18,9'%3e%3c/polyline%3e%3c/svg%3e");
  background-repeat: no-repeat;
  background-position: right 8px center;
  background-size: 16px;
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
  padding: 0;
  cursor: pointer;
  color: #6c757d;
  transition: all 0.2s ease;
  font-size: 23px;
  font-weight: bold;
  min-width: 36px;
  height: 36px;
  display: flex;
  align-items: center;
  justify-content: center;
  line-height: 1;
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
  padding: 6px 30px 6px 8px; /* Added right padding for arrow spacing */
  background: #fff;
  font-size: 14px;
  cursor: pointer;
  min-width: 80px;
  appearance: none; /* Remove default browser styling */
  background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6,9 12,15 18,9'%3e%3c/polyline%3e%3c/svg%3e");
  background-repeat: no-repeat;
  background-position: right 8px center;
  background-size: 16px;
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
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  max-width: 100%;
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
    min-width: 280px;
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
