<template>
  <div class="shortcut-panel">
    <!-- Header Section -->
    <div class="panel-header">
      <h2 class="panel-title">Shortcut Panel</h2>
      <div class="shortcut-tabs">
        <button
          v-for="tab in availableTabs"
          :key="tab.id"
          @click="selectTab(tab.id)"
          class="tab-button"
          :class="{ active: selectedTab === tab.id }"
        >
          {{ tab.label }}
        </button>
      </div>
    </div>

    <!-- Content Section -->
    <div class="panel-content">
      <!-- Cash In-Pay Details Screen -->
      <div v-if="selectedTab === 'cash-in-pay'" class="screen-content">
        <posCashInOutColl />
      </div>

      <!-- Calendar Control Screen -->
      <div v-if="selectedTab === 'calendar-control'" class="screen-content">
        <div class="calendar-section">
          <h3 class="section-title">Calendar Control</h3>
          <posCalendarControl
            v-model="selectedDate"
            placeholder="Select date..."
            @date-selected="handleCalendarDateSelected"
          />
        </div>
      </div>

      <!-- Multi Calendar Screen -->
      <div v-if="selectedTab === 'multi-calendar'" class="screen-content">
        <posCalendar
          :initial-date="new Date()"
          :initial-calendar-type="'gregorian'"
          :show-events="true"
          @date-selected="handleDateSelected"
          @calendar-type-changed="handleCalendarTypeChanged"
        />
      </div>

      <!-- Font Test Screen -->
      <div v-if="selectedTab === 'font-test'" class="screen-content">
        <div class="font-test-section">
          <h3 class="section-title">Times New Roman TTF Font Testing</h3>
          <TimesNewRomanTest />
        </div>
      </div>

      <!-- Template Test Screen -->
      <div v-if="selectedTab === 'template-test'" class="screen-content">
        <posTemplateTest />
      </div>

      <!-- Default Screen -->
      <div v-if="selectedTab === 'default'" class="screen-content">
        <div class="default-screen">
          <h3 class="section-title">Welcome to Shortcut Panel</h3>
          <p class="welcome-text">Select a tab above to view different screens and components.</p>
          <div class="feature-list">
            <h4>Available Features:</h4>
            <ul>
              <li>Cash In-Pay Details Form</li>
              <li>Calendar Control Component</li>
              <li>Multi-Calendar System</li>
              <li>Font Testing</li>
              <li>Template Testing</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import posCashInOutColl from './posCashInOutColl.vue'
import posCalendarControl from './posCalendarControl.vue'
import posCalendar from './posCalendar.vue'
import posTemplateTest from './posTemplateTest.vue'
import TimesNewRomanTest from '../posComponent/TimesNewRomanTest.vue'

// Available tabs/screens
const availableTabs = [
  { id: 'default', label: 'Default' },
  { id: 'cash-in-pay', label: 'Cash In-Pay' },
  { id: 'calendar-control', label: 'Calendar Control' },
  { id: 'multi-calendar', label: 'Multi Calendar' },
  { id: 'font-test', label: 'Font Test' },
  { id: 'template-test', label: 'Template Test' },
]

// Emits
const emit = defineEmits<{
  'screen-selected': [screenId: string]
}>()

// Reactive data
const selectedTab = ref<string>('default')
const selectedDate = ref<Date | null>(new Date())

// Tab selection function
function selectTab(tabId: string): void {
  selectedTab.value = tabId
  console.log('Selected tab:', tabId)

  // Emit event to parent component
  emit('screen-selected', tabId)
}

// Event handlers for calendar components
function handleCalendarDateSelected(date: Date): void {
  selectedDate.value = date
  console.log('Calendar date selected:', date)
}

function handleDateSelected(date: Date, calendarType: string, formattedDate: string): void {
  console.log('Date selected:', date, 'Calendar type:', calendarType, 'Formatted:', formattedDate)
}

function handleCalendarTypeChanged(calendarType: string): void {
  console.log('Calendar type changed:', calendarType)
}
</script>

<style scoped>
.shortcut-panel {
  background: #ffffff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  overflow: hidden;
  max-width: 100%;
  min-height: 600px;
  height: auto;
}

/* Header Section */
.panel-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20px;
}

.panel-title {
  font-size: 24px;
  font-weight: bold;
  margin-bottom: 16px;
  text-align: center;
}

.shortcut-tabs {
  display: flex;
  gap: 8px;
  flex-wrap: wrap;
  justify-content: center;
}

.tab-button {
  padding: 8px 16px;
  font-size: 14px;
  font-weight: 500;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 20px;
  background: transparent;
  color: white;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 120px;
}

.tab-button:hover {
  background: rgba(255, 255, 255, 0.1);
  border-color: rgba(255, 255, 255, 0.5);
  transform: translateY(-1px);
}

.tab-button.active {
  background: rgba(255, 255, 255, 0.2);
  border-color: white;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
}

/* Content Section */
.panel-content {
  padding: 20px;
  min-height: 500px;
}

.screen-content {
  width: 100%;
}

.calendar-section {
  max-width: 600px;
  margin: 0 auto;
}

.section-title {
  font-size: 18px;
  font-weight: 600;
  color: #333;
  margin-bottom: 16px;
  padding-bottom: 8px;
  border-bottom: 2px solid #e9ecef;
}

.font-test-section {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 20px;
  border: 1px solid #e9ecef;
}

/* Default Screen */
.default-screen {
  text-align: center;
  padding: 40px 20px;
}

.welcome-text {
  font-size: 16px;
  color: #666;
  margin-bottom: 24px;
  line-height: 1.6;
}

.feature-list {
  text-align: left;
  max-width: 500px;
  margin: 0 auto;
  background: #f8f9fa;
  border-radius: 8px;
  padding: 20px;
  border: 1px solid #e9ecef;
}

.feature-list h4 {
  color: #333;
  margin-bottom: 12px;
  font-weight: 600;
}

.feature-list ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.feature-list li {
  padding: 8px 0;
  border-bottom: 1px solid #e9ecef;
  color: #555;
  position: relative;
  padding-left: 20px;
}

.feature-list li:before {
  content: '✓';
  position: absolute;
  left: 0;
  color: #28a745;
  font-weight: bold;
}

.feature-list li:last-child {
  border-bottom: none;
}

/* Responsive Design */
@media (max-width: 768px) {
  .shortcut-tabs {
    flex-direction: column;
    align-items: center;
  }

  .tab-button {
    width: 200px;
    text-align: center;
  }

  .panel-header {
    padding: 16px;
  }

  .panel-content {
    padding: 16px;
  }

  .default-screen {
    padding: 20px 10px;
  }

  .feature-list {
    margin: 0 10px;
  }
}

@media (max-width: 480px) {
  .tab-button {
    width: 100%;
    max-width: 200px;
  }

  .panel-title {
    font-size: 20px;
  }
}
</style>
