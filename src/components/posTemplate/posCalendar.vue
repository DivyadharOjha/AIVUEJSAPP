<template>
  <div class="calendar-container">
    <!-- Calendar Header -->
    <div class="calendar-header">
      <div class="calendar-controls">
        <button
          class="btn btn-outline-secondary btn-sm"
          @click="previousMonth"
          title="Previous Month"
        >
          <i class="fas fa-chevron-left"></i>
        </button>

        <div class="calendar-title">
          <h5 class="mb-0">{{ currentMonthYear }}</h5>
          <small class="text-muted">{{ currentCalendarType }}</small>
        </div>

        <button class="btn btn-outline-secondary btn-sm" @click="nextMonth" title="Next Month">
          <i class="fas fa-chevron-right"></i>
        </button>
      </div>

      <!-- Calendar Type Selector -->
      <div class="calendar-type-selector">
        <select
          v-model="selectedCalendarType"
          @change="changeCalendarType"
          class="form-select form-select-sm"
        >
          <option value="gregorian">Gregorian</option>
          <option value="hijri">Hijri</option>
          <option value="shamshi">Shamshi</option>
          <option value="bikram">Bikram</option>
        </select>
      </div>
    </div>

    <!-- Calendar Grid -->
    <div class="calendar-grid">
      <!-- Day Headers -->
      <div class="calendar-days-header">
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
              'has-events': day.hasEvents,
            },
          ]"
          @click="selectDate(day)"
        >
          <span class="day-number">{{ day.dayNumber }}</span>
          <div v-if="day.hasEvents" class="event-indicator">
            <i class="fas fa-circle"></i>
          </div>
        </div>
      </div>
    </div>

    <!-- Selected Date Info -->
    <div v-if="selectedDate" class="selected-date-info">
      <div class="selected-date-header">
        <h6 class="mb-1">Selected Date</h6>
        <button class="btn btn-sm btn-outline-danger" @click="clearSelection">
          <i class="fas fa-times"></i>
        </button>
      </div>
      <div class="selected-date-details">
        <div class="date-info-row">
          <span class="info-label">Gregorian:</span>
          <span class="info-value">{{ selectedDate.gregorian }}</span>
        </div>
        <div class="date-info-row">
          <span class="info-label">{{ getCalendarTypeLabel() }}:</span>
          <span class="info-value">{{ selectedDate.currentCalendar }}</span>
        </div>
      </div>
    </div>

    <!-- Quick Actions -->
    <div class="calendar-actions">
      <button class="btn btn-primary btn-sm" @click="goToToday">
        <i class="fas fa-calendar-day me-1"></i>
        Today
      </button>
      <button
        class="btn btn-outline-primary btn-sm"
        @click="emitSelectedDate"
        :disabled="!selectedDate"
      >
        <i class="fas fa-check me-1"></i>
        Select Date
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, nextTick } from 'vue'
// @ts-expect-error - moment-hijri doesn't have TypeScript definitions
import moment from 'moment-hijri'
// @ts-expect-error - moment-jalaali doesn't have TypeScript definitions
import momentJalaali from 'moment-jalaali'
// @ts-expect-error - nepali-date doesn't have TypeScript definitions
import NepaliDate from 'nepali-date'

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

// Reactive data
const currentDate = ref(props.initialDate)
const selectedCalendarType = ref(props.initialCalendarType)
const selectedDate = ref<{
  date: Date
  gregorian: string
  currentCalendar: string
} | null>(null)

// Calendar configuration
const dayHeadersConfig = {
  gregorian: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
  hijri: ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'],
  shamshi: ['یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنج‌شنبه', 'جمعه', 'شنبه'],
  bikram: ['आइत', 'सोम', 'मंगल', 'बुध', 'बिहि', 'शुक्र', 'शनि'],
}

const dayHeaders = computed(() => {
  return dayHeadersConfig[selectedCalendarType.value]
})

// Calendar type configurations
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
// ===================================

// 1. HIJRI CALENDAR (Lunar Calendar) - Using moment-hijri
// ========================================================
function gregorianToHijri(date: Date): { year: number; month: number; day: number } {
  const hijriMoment = moment(date).format('iYYYY/iM/iD')
  const [year, month, day] = hijriMoment.split('/').map(Number)

  console.log(`moment-hijri conversion: ${date.toDateString()} -> ${hijriMoment}`)

  return { year, month, day }
}

// 2. SHAMSHI/PERSIAN CALENDAR (Solar Calendar) - Using moment-jalaali
// ====================================================================
function gregorianToShamshi(date: Date): { year: number; month: number; day: number } {
  try {
    // Convert Gregorian to Jalali using moment-jalaali
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
    // Fallback to a simple conversion for debugging
    return {
      year: 1404,
      month: 1,
      day: 1,
    }
  }
}

// 3. BIKRAM SAMBAT CALENDAR (Solar Calendar) - Using nepali-date
// ================================================================
function gregorianToBikram(date: Date): { year: number; month: number; day: number } {
  try {
    // Convert Gregorian to Nepali using nepali-date
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
    // Fallback to a simple conversion for debugging
    return {
      year: 2082,
      month: 1,
      day: 1,
    }
  }
}

// Computed properties
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

const currentCalendarType = computed(() => {
  return calendarConfigs[selectedCalendarType.value].name
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
      hasEvents: hasEvents(date),
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
      hasEvents: hasEvents(date),
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
      hasEvents: hasEvents(date),
    })
  }

  return days
})

// Methods

function isToday(date: Date): boolean {
  const today = new Date()
  return date.toDateString() === today.toDateString()
}

function isSelectedDate(date: Date): boolean {
  if (!selectedDate.value) return false
  const isSelected = date.toDateString() === selectedDate.value.date.toDateString()
  console.log('isSelectedDate check:', {
    date: date.toDateString(),
    selectedDate: selectedDate.value.date.toDateString(),
    isSelected,
  })
  return isSelected
}

function hasEvents(date: Date): boolean {
  // Mock events - in real app, this would check actual events
  console.log('hasEvents', date)
  return Math.random() > 0.8 // 20% chance of having events
}

interface CalendarDay {
  key: string
  dayNumber: number
  date: Date
  isCurrentMonth: boolean
  isToday: boolean
  isSelected: boolean
  hasEvents: boolean
}

function selectDate(day: CalendarDay): void {
  console.log('selectDate called:', {
    day: day.date.toDateString(),
    calendarType: selectedCalendarType.value,
    dayNumber: day.dayNumber,
    isCurrentMonth: day.isCurrentMonth,
  })

  const gregorianFormatted = formatDate(day.date, 'gregorian')
  const currentCalendarFormatted = formatDate(day.date, selectedCalendarType.value)

  console.log('Formatted dates:', {
    gregorian: gregorianFormatted,
    currentCalendar: currentCalendarFormatted,
  })

  selectedDate.value = {
    date: day.date,
    gregorian: gregorianFormatted,
    currentCalendar: currentCalendarFormatted,
  }

  console.log('selectedDate.value set to:', selectedDate.value)
  console.log('Calendar type for emit:', selectedCalendarType.value)

  // Force reactivity update
  nextTick(() => {
    console.log('After nextTick - selectedDate.value:', selectedDate.value)
  })

  // Emit the selected date with proper conversion
  let convertedYear: number
  let convertedMonth: number
  let convertedDay: number

  switch (selectedCalendarType.value) {
    case 'hijri': {
      const hijriDate = gregorianToHijri(day.date)
      convertedYear = hijriDate.year
      convertedMonth = hijriDate.month
      convertedDay = hijriDate.day
      break
    }
    case 'shamshi': {
      const shamshiDate = gregorianToShamshi(day.date)
      convertedYear = shamshiDate.year
      convertedMonth = shamshiDate.month
      convertedDay = shamshiDate.day
      break
    }
    case 'bikram': {
      const bikramDate = gregorianToBikram(day.date)
      convertedYear = bikramDate.year
      convertedMonth = bikramDate.month
      convertedDay = bikramDate.day
      break
    }
    default: {
      convertedYear = day.date.getFullYear()
      convertedMonth = day.date.getMonth() + 1
      convertedDay = day.date.getDate()
      break
    }
  }

  // For Hijri, Shamshi, and Bikram calendars, don't create a new Date object as it would be invalid
  // Instead, emit the original date with the converted information
  if (
    selectedCalendarType.value === 'hijri' ||
    selectedCalendarType.value === 'shamshi' ||
    selectedCalendarType.value === 'bikram'
  ) {
    emit('date-selected', day.date, selectedCalendarType.value, currentCalendarFormatted)
  } else {
    // For other calendars, create a new date object for the converted calendar
    const convertedDate = new Date(convertedYear, convertedMonth - 1, convertedDay)
    emit('date-selected', convertedDate, selectedCalendarType.value, currentCalendarFormatted)
  }
}

function formatDate(date: Date, calendarType: string): string {
  const day = date.getDate()
  const month = date.getMonth() + 1
  const year = date.getFullYear()

  switch (calendarType) {
    case 'hijri': {
      const hijriDate = gregorianToHijri(date)
      const hijriMonthName = calendarConfigs.hijri.months[hijriDate.month - 1]
      console.log(
        `formatDate - Gregorian: ${day}/${month}/${year} -> Hijri: ${hijriDate.day}/${hijriMonthName}/${hijriDate.year}`,
      )
      // Format: Day/Month/Year (e.g., 7/صفر/1447)
      const formatted = `${hijriDate.day}/${hijriMonthName}/${hijriDate.year}`
      console.log(`formatDate - Final Hijri format: ${formatted}`)
      return formatted
    }
    case 'shamshi': {
      const shamshiDate = gregorianToShamshi(date)
      console.log('Shamshi conversion result:', shamshiDate)

      const shamshiMonthName = calendarConfigs.shamshi.months[shamshiDate.month - 1]
      console.log('Shamshi month lookup:', {
        month: shamshiDate.month,
        monthName: shamshiMonthName,
        availableMonths: calendarConfigs.shamshi.months.length,
      })

      console.log(
        `formatDate - Gregorian: ${day}/${month}/${year} -> Shamshi: ${shamshiDate.day}/${shamshiMonthName}/${shamshiDate.year}`,
      )
      // Format: Day/Month/Year (e.g., 15/فروردین/1404)
      const formatted = `${shamshiDate.day}/${shamshiMonthName}/${shamshiDate.year}`
      console.log(`formatDate - Final Shamshi format: ${formatted}`)
      return formatted
    }
    case 'bikram': {
      const bikramDate = gregorianToBikram(date)
      console.log('Bikram conversion result:', bikramDate)

      const bikramMonthName = calendarConfigs.bikram.months[bikramDate.month - 1]
      console.log('Bikram month lookup:', {
        month: bikramDate.month,
        monthName: bikramMonthName,
        availableMonths: calendarConfigs.bikram.months.length,
      })

      console.log(
        `formatDate - Gregorian: ${day}/${month}/${year} -> Bikram: ${bikramDate.day}/${bikramMonthName}/${bikramDate.year}`,
      )
      // Format: Day/Month/Year (e.g., 15/बैशाख/2082)
      const formatted = `${bikramDate.day}/${bikramMonthName}/${bikramDate.year}`
      console.log(`formatDate - Final Bikram format: ${formatted}`)
      return formatted
    }
    default: {
      const monthName = calendarConfigs.gregorian.months[month - 1]
      return `${day}/${monthName}/${year}`
    }
  }
}

function previousMonth(): void {
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
}

function nextMonth(): void {
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
    const nextBikramYear = currentBikram.month === 12 ? currentBikram.year + 1 : currentBikram.year

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
}

function getCalendarTypeLabel(): string {
  switch (selectedCalendarType.value) {
    case 'hijri':
      return 'Hijri'
    case 'shamshi':
      return 'Shamshi'
    case 'bikram':
      return 'Bikram'
    default:
      return 'Gregorian'
  }
}

function changeCalendarType(): void {
  console.log('changeCalendarType called:', {
    newCalendarType: selectedCalendarType.value,
    hasSelectedDate: !!selectedDate.value,
  })

  // Update the selected date information when calendar type changes
  if (selectedDate.value) {
    console.log('Before formatDate call:', {
      selectedDate: selectedDate.value.date.toDateString(),
      calendarType: selectedCalendarType.value,
    })

    const newFormattedDate = formatDate(selectedDate.value.date, selectedCalendarType.value)

    console.log('After formatDate call:', {
      newFormattedDate,
      calendarType: selectedCalendarType.value,
    })

    console.log('Updating selectedDate.currentCalendar:', {
      from: selectedDate.value.currentCalendar,
      to: newFormattedDate,
    })
    selectedDate.value.currentCalendar = newFormattedDate
  }
  emit('calendar-type-changed', selectedCalendarType.value)
}

function goToToday(): void {
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

  // Set selected date to today
  selectedDate.value = {
    date: today,
    gregorian: formatDate(today, 'gregorian'),
    currentCalendar: formatDate(today, selectedCalendarType.value),
  }

  // Emit the selected date with proper conversion
  emit(
    'date-selected',
    today,
    selectedCalendarType.value,
    formatDate(today, selectedCalendarType.value),
  )
}

function clearSelection(): void {
  selectedDate.value = null
}

function emitSelectedDate(): void {
  if (selectedDate.value) {
    emit(
      'date-selected',
      selectedDate.value.date,
      selectedCalendarType.value,
      selectedDate.value.currentCalendar,
    )
  }
}

// Initialize
onMounted(() => {
  if (props.initialDate) {
    currentDate.value = props.initialDate
  }
})
</script>

<style scoped>
.calendar-container {
  background: #ffffff;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.calendar-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 16px;
}

.calendar-controls {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.calendar-title {
  text-align: center;
  flex: 1;
}

.calendar-title h5 {
  margin: 0;
  font-weight: 600;
}

.calendar-type-selector {
  display: flex;
  justify-content: center;
}

.calendar-type-selector select {
  max-width: 150px;
  font-size: 0.875rem;
}

.calendar-grid {
  padding: 16px;
}

.calendar-days-header {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
  margin-bottom: 8px;
}

.day-header {
  text-align: center;
  font-weight: 600;
  color: #6c757d;
  font-size: 0.875rem;
  padding: 8px 4px;
}

.calendar-days {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
}

.calendar-day {
  aspect-ratio: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border-radius: 6px;
  cursor: pointer;
  position: relative;
  transition: all 0.2s ease;
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

.calendar-day.has-events .event-indicator {
  position: absolute;
  top: 2px;
  right: 2px;
  font-size: 0.5rem;
  color: #dc3545;
}

.calendar-day.today .event-indicator,
.calendar-day.selected .event-indicator {
  color: white;
}

.day-number {
  font-size: 0.875rem;
  font-weight: 500;
}

.selected-date-info {
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
  padding: 12px 16px;
}

.selected-date-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 8px;
}

.selected-date-header h6 {
  margin: 0;
  color: #495057;
}

.date-info-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 4px;
}

.info-label {
  font-weight: 500;
  color: #6c757d;
  font-size: 0.875rem;
}

.info-value {
  font-weight: 600;
  color: #495057;
  font-size: 0.875rem;
}

.calendar-actions {
  display: flex;
  gap: 8px;
  padding: 12px 16px;
  border-top: 1px solid #e9ecef;
  background: #f8f9fa;
}

.calendar-actions .btn {
  flex: 1;
}

/* Responsive design */
@media (max-width: 576px) {
  .calendar-header {
    padding: 12px;
  }

  .calendar-grid {
    padding: 12px;
  }

  .calendar-actions {
    flex-direction: column;
  }

  .day-number {
    font-size: 0.8rem;
  }
}
</style>
