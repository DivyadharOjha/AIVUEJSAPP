<template>
  <div class="table-panel">
    <!-- Panel Header -->
    <div class="panel-header">
      <h3 class="panel-title">Table Management</h3>
      <div class="table-stats">
        <span class="stat-item">
          <i class="fas fa-chair"></i>
          Total: {{ totalTables }}
        </span>
        <span class="stat-item">
          <i class="fas fa-check-circle"></i>
          Available: {{ availableTables }}
        </span>
      </div>
    </div>

    <!-- Table Filter -->
    <div class="table-filter">
      <div class="filter-buttons">
        <button 
          v-for="filter in tableFilters" 
          :key="filter.id"
          class="filter-btn"
          :class="{ active: activeFilter === filter.id }"
          @click="setFilter(filter.id)"
        >
          <i :class="filter.icon"></i>
          <span>{{ filter.name }}</span>
          <span class="filter-count">{{ getFilterCount(filter.id) }}</span>
        </button>
      </div>
    </div>

    <!-- Table Grid -->
    <div class="table-grid">
      <div class="grid-header">
        <h4 class="grid-title">Tables</h4>
        <div class="grid-controls">
          <button class="control-btn" @click="refreshTables">
            <i class="fas fa-sync-alt"></i>
          </button>
          <button class="control-btn" @click="addNewTable">
            <i class="fas fa-plus"></i>
          </button>
        </div>
      </div>
      
      <div class="tables-container">
        <div 
          v-for="table in filteredTables" 
          :key="table.id"
          class="table-card"
          :class="[
            'status-' + table.status,
            { selected: selectedTable?.id === table.id }
          ]"
          @click="selectTable(table)"
          @dblclick="openTable(table)"
        >
          <div class="table-header">
            <div class="table-number">{{ table.number }}</div>
            <div class="table-status" :class="'status-' + table.status">
              <i :class="getStatusIcon(table.status)"></i>
            </div>
          </div>
          
          <div class="table-info">
            <div class="table-name">{{ table.name }}</div>
            <div class="table-details">
              <span class="table-capacity">
                <i class="fas fa-users"></i>
                {{ table.capacity }}
              </span>
              <span class="table-section">{{ table.section }}</span>
            </div>
          </div>
          
          <div v-if="table.order" class="table-order">
            <div class="order-info">
              <span class="order-time">{{ formatTime(table.order.startTime) }}</span>
              <span class="order-amount">₹{{ table.order.amount.toFixed(2) }}</span>
            </div>
            <div class="order-items">{{ table.order.itemCount }} items</div>
          </div>
          
          <div class="table-actions">
            <button 
              v-if="table.status === 'available'"
              class="action-btn btn-primary"
              @click.stop="assignTable(table)"
            >
              Assign
            </button>
            <button 
              v-if="table.status === 'occupied'"
              class="action-btn btn-info"
              @click.stop="viewOrder(table)"
            >
              View Order
            </button>
            <button 
              v-if="table.status === 'reserved'"
              class="action-btn btn-warning"
              @click.stop="confirmReservation(table)"
            >
              Confirm
            </button>
            <button 
              v-if="table.status === 'cleaning'"
              class="action-btn btn-success"
              @click.stop="markClean(table)"
            >
              Mark Clean
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Selected Table Details -->
    <div v-if="selectedTable" class="table-details-panel">
      <div class="details-header">
        <h4 class="details-title">Table {{ selectedTable.number }}</h4>
        <button class="close-btn" @click="selectedTable = null">
          <i class="fas fa-times"></i>
        </button>
      </div>
      
      <div class="details-content">
        <div class="detail-row">
          <span class="detail-label">Status:</span>
          <span class="detail-value" :class="'status-' + selectedTable.status">
            {{ selectedTable.status.toUpperCase() }}
          </span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Capacity:</span>
          <span class="detail-value">{{ selectedTable.capacity }} guests</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Section:</span>
          <span class="detail-value">{{ selectedTable.section }}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Server:</span>
          <span class="detail-value">{{ selectedTable.server || 'Not assigned' }}</span>
        </div>
        
        <div v-if="selectedTable.order" class="order-details">
          <h5>Current Order</h5>
          <div class="detail-row">
            <span class="detail-label">Start Time:</span>
            <span class="detail-value">{{ formatDateTime(selectedTable.order.startTime) }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Items:</span>
            <span class="detail-value">{{ selectedTable.order.itemCount }}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Amount:</span>
            <span class="detail-value">₹{{ selectedTable.order.amount.toFixed(2) }}</span>
          </div>
        </div>
        
        <div class="details-actions">
          <button 
            v-if="selectedTable.status === 'available'"
            class="details-action-btn btn-primary"
            @click="assignTable(selectedTable)"
          >
            <i class="fas fa-user-plus"></i>
            Assign Table
          </button>
          <button 
            v-if="selectedTable.status === 'occupied'"
            class="details-action-btn btn-info"
            @click="viewOrder(selectedTable)"
          >
            <i class="fas fa-receipt"></i>
            View Order
          </button>
          <button 
            v-if="selectedTable.status === 'occupied'"
            class="details-action-btn btn-success"
            @click="closeTable(selectedTable)"
          >
            <i class="fas fa-check"></i>
            Close Table
          </button>
          <button 
            class="details-action-btn btn-secondary"
            @click="editTable(selectedTable)"
          >
            <i class="fas fa-edit"></i>
            Edit Table
          </button>
        </div>
      </div>
    </div>

    <!-- Quick Stats -->
    <div class="quick-stats">
      <div class="stat-card">
        <div class="stat-icon available">
          <i class="fas fa-check-circle"></i>
        </div>
        <div class="stat-info">
          <div class="stat-number">{{ availableTables }}</div>
          <div class="stat-label">Available</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon occupied">
          <i class="fas fa-utensils"></i>
        </div>
        <div class="stat-info">
          <div class="stat-number">{{ occupiedTables }}</div>
          <div class="stat-label">Occupied</div>
        </div>
      </div>
      
      <div class="stat-card">
        <div class="stat-icon reserved">
          <i class="fas fa-clock"></i>
        </div>
        <div class="stat-info">
          <div class="stat-number">{{ reservedTables }}</div>
          <div class="stat-label">Reserved</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, defineEmits } from 'vue'

const emit = defineEmits([
  'table-selected',
  'table-assigned',
  'table-closed',
  'order-viewed',
  'table-edited',
  'reservation-confirmed'
])

// Selected table
const selectedTable = ref(null)

// Active filter
const activeFilter = ref('all')

// Table filters
const tableFilters = ref([
  { id: 'all', name: 'All', icon: 'fas fa-list' },
  { id: 'available', name: 'Available', icon: 'fas fa-check-circle' },
  { id: 'occupied', name: 'Occupied', icon: 'fas fa-utensils' },
  { id: 'reserved', name: 'Reserved', icon: 'fas fa-clock' },
  { id: 'cleaning', name: 'Cleaning', icon: 'fas fa-broom' }
])

// Sample table data
const tables = ref([
  {
    id: 1,
    number: 'T01',
    name: 'Table 1',
    capacity: 4,
    section: 'Main Hall',
    status: 'available',
    server: null,
    order: null
  },
  {
    id: 2,
    number: 'T02',
    name: 'Table 2',
    capacity: 2,
    section: 'Window Side',
    status: 'occupied',
    server: 'John Doe',
    order: {
      id: 'ORD-001',
      startTime: new Date(Date.now() - 45 * 60000), // 45 minutes ago
      itemCount: 5,
      amount: 45.50
    }
  },
  {
    id: 3,
    number: 'T03',
    name: 'Table 3',
    capacity: 6,
    section: 'Private Dining',
    status: 'reserved',
    server: 'Jane Smith',
    order: null
  },
  {
    id: 4,
    number: 'T04',
    name: 'Table 4',
    capacity: 4,
    section: 'Main Hall',
    status: 'cleaning',
    server: null,
    order: null
  },
  {
    id: 5,
    number: 'T05',
    name: 'Table 5',
    capacity: 8,
    section: 'Banquet',
    status: 'occupied',
    server: 'Mike Johnson',
    order: {
      id: 'ORD-002',
      startTime: new Date(Date.now() - 90 * 60000), // 90 minutes ago
      itemCount: 12,
      amount: 128.75
    }
  },
  {
    id: 6,
    number: 'T06',
    name: 'Table 6',
    capacity: 2,
    section: 'Bar Area',
    status: 'available',
    server: null,
    order: null
  }
])

// Computed properties
const totalTables = computed(() => tables.value.length)

const availableTables = computed(() => 
  tables.value.filter(table => table.status === 'available').length
)

const occupiedTables = computed(() => 
  tables.value.filter(table => table.status === 'occupied').length
)

const reservedTables = computed(() => 
  tables.value.filter(table => table.status === 'reserved').length
)

const filteredTables = computed(() => {
  if (activeFilter.value === 'all') {
    return tables.value
  }
  return tables.value.filter(table => table.status === activeFilter.value)
})

// Methods
function setFilter(filterId) {
  activeFilter.value = filterId
}

function getFilterCount(filterId) {
  if (filterId === 'all') {
    return tables.value.length
  }
  return tables.value.filter(table => table.status === filterId).length
}

function selectTable(table) {
  selectedTable.value = table
  emit('table-selected', table)
}

function openTable(table) {
  if (table.status === 'available') {
    assignTable(table)
  } else if (table.status === 'occupied') {
    viewOrder(table)
  }
}

function assignTable(table) {
  table.status = 'occupied'
  table.server = 'Current User'
  table.order = {
    id: `ORD-${Date.now()}`,
    startTime: new Date(),
    itemCount: 0,
    amount: 0
  }
  emit('table-assigned', table)
}

function closeTable(table) {
  table.status = 'cleaning'
  table.server = null
  table.order = null
  emit('table-closed', table)
}

function viewOrder(table) {
  emit('order-viewed', table)
}

function editTable(table) {
  emit('table-edited', table)
}

function confirmReservation(table) {
  table.status = 'occupied'
  emit('reservation-confirmed', table)
}

function markClean(table) {
  table.status = 'available'
  table.server = null
}

function refreshTables() {
  // Refresh table data from server
  console.log('Refreshing tables...')
}

function addNewTable() {
  // Add new table logic
  console.log('Adding new table...')
}

function getStatusIcon(status) {
  const icons = {
    available: 'fas fa-check-circle',
    occupied: 'fas fa-utensils',
    reserved: 'fas fa-clock',
    cleaning: 'fas fa-broom'
  }
  return icons[status] || 'fas fa-question-circle'
}

function formatTime(date) {
  if (!date) return ''
  const now = new Date()
  const diff = Math.floor((now - date) / 60000) // minutes
  
  if (diff < 60) {
    return `${diff}m`
  } else {
    const hours = Math.floor(diff / 60)
    const minutes = diff % 60
    return `${hours}h ${minutes}m`
  }
}

function formatDateTime(date) {
  if (!date) return ''
  return date.toLocaleString()
}
</script>

<style scoped>
.table-panel {
  width: 350px;
  height: 100%;
  background: #f8f9fa;
  border-right: 1px solid #e9ecef;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.panel-header {
  padding: 20px;
  background: #2c3e50;
  color: white;
  border-bottom: 1px solid #34495e;
}

.panel-title {
  margin: 0 0 10px 0;
  font-size: 18px;
  font-weight: 600;
}

.table-stats {
  display: flex;
  gap: 15px;
}

.stat-item {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 12px;
  color: #bdc3c7;
}

.table-filter {
  padding: 15px;
  border-bottom: 1px solid #e9ecef;
}

.filter-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.filter-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 12px;
  border: 1px solid #dee2e6;
  background: white;
  border-radius: 20px;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 11px;
}

.filter-btn:hover {
  background: #f8f9fa;
}

.filter-btn.active {
  background: #007bff;
  color: white;
  border-color: #007bff;
}

.filter-count {
  background: rgba(0, 0, 0, 0.1);
  padding: 2px 6px;
  border-radius: 10px;
  font-size: 10px;
  min-width: 16px;
  text-align: center;
}

.filter-btn.active .filter-count {
  background: rgba(255, 255, 255, 0.3);
}

.table-grid {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.grid-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  border-bottom: 1px solid #e9ecef;
}

.grid-title {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
  color: #495057;
}

.grid-controls {
  display: flex;
  gap: 8px;
}

.control-btn {
  width: 30px;
  height: 30px;
  border: 1px solid #dee2e6;
  background: white;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #6c757d;
  transition: all 0.2s ease;
}

.control-btn:hover {
  background: #f8f9fa;
  color: #495057;
}

.tables-container {
  flex: 1;
  overflow-y: auto;
  padding: 10px;
}

.table-card {
  background: white;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  padding: 15px;
  margin-bottom: 10px;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
}

.table-card:hover {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  transform: translateY(-1px);
}

.table-card.selected {
  border-color: #007bff;
  box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
}

.table-card.status-available {
  border-left: 4px solid #28a745;
}

.table-card.status-occupied {
  border-left: 4px solid #dc3545;
}

.table-card.status-reserved {
  border-left: 4px solid #ffc107;
}

.table-card.status-cleaning {
  border-left: 4px solid #6c757d;
}

.table-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 10px;
}

.table-number {
  font-size: 16px;
  font-weight: 600;
  color: #495057;
}

.table-status {
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 10px;
  font-weight: 500;
}

.table-status.status-available {
  background: #d4edda;
  color: #155724;
}

.table-status.status-occupied {
  background: #f8d7da;
  color: #721c24;
}

.table-status.status-reserved {
  background: #fff3cd;
  color: #856404;
}

.table-status.status-cleaning {
  background: #e2e3e5;
  color: #383d41;
}

.table-info {
  margin-bottom: 10px;
}

.table-name {
  font-size: 14px;
  font-weight: 500;
  color: #495057;
  margin-bottom: 5px;
}

.table-details {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #6c757d;
}

.table-capacity {
  display: flex;
  align-items: center;
  gap: 4px;
}

.table-order {
  background: #f8f9fa;
  padding: 8px;
  border-radius: 4px;
  margin-bottom: 10px;
  font-size: 12px;
}

.order-info {
  display: flex;
  justify-content: space-between;
  margin-bottom: 4px;
}

.order-time {
  color: #6c757d;
}

.order-amount {
  font-weight: 600;
  color: #28a745;
}

.order-items {
  color: #6c757d;
}

.table-actions {
  display: flex;
  gap: 8px;
}

.action-btn {
  flex: 1;
  padding: 6px 12px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 11px;
  font-weight: 500;
  transition: all 0.2s ease;
}

.btn-primary {
  background: #007bff;
  color: white;
}

.btn-primary:hover {
  background: #0056b3;
}

.btn-info {
  background: #17a2b8;
  color: white;
}

.btn-info:hover {
  background: #117a8b;
}

.btn-warning {
  background: #ffc107;
  color: #212529;
}

.btn-warning:hover {
  background: #e0a800;
}

.btn-success {
  background: #28a745;
  color: white;
}

.btn-success:hover {
  background: #1e7e34;
}

.btn-secondary {
  background: #6c757d;
  color: white;
}

.btn-secondary:hover {
  background: #545b62;
}

.table-details-panel {
  border-top: 1px solid #e9ecef;
  background: white;
}

.details-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px 20px;
  border-bottom: 1px solid #e9ecef;
  background: #f8f9fa;
}

.details-title {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #495057;
}

.close-btn {
  width: 24px;
  height: 24px;
  border: none;
  background: none;
  cursor: pointer;
  color: #6c757d;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-btn:hover {
  background: #e9ecef;
  color: #495057;
}

.details-content {
  padding: 20px;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 10px;
  font-size: 13px;
}

.detail-label {
  font-weight: 500;
  color: #6c757d;
}

.detail-value {
  font-weight: 500;
  color: #495057;
}

.detail-value.status-available {
  color: #28a745;
}

.detail-value.status-occupied {
  color: #dc3545;
}

.detail-value.status-reserved {
  color: #ffc107;
}

.detail-value.status-cleaning {
  color: #6c757d;
}

.order-details {
  margin-top: 15px;
  padding-top: 15px;
  border-top: 1px solid #e9ecef;
}

.order-details h5 {
  margin: 0 0 10px 0;
  font-size: 14px;
  font-weight: 600;
  color: #495057;
}

.details-actions {
  margin-top: 20px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.details-action-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 10px 15px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 13px;
  font-weight: 500;
  transition: all 0.2s ease;
}

.quick-stats {
  padding: 15px;
  display: flex;
  gap: 10px;
  border-top: 1px solid #e9ecef;
  background: white;
}

.stat-card {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px;
  background: #f8f9fa;
  border-radius: 6px;
}

.stat-icon {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
}

.stat-icon.available {
  background: #28a745;
}

.stat-icon.occupied {
  background: #dc3545;
}

.stat-icon.reserved {
  background: #ffc107;
}

.stat-info {
  flex: 1;
}

.stat-number {
  font-size: 16px;
  font-weight: 600;
  color: #495057;
}

.stat-label {
  font-size: 11px;
  color: #6c757d;
  text-transform: uppercase;
}

/* Responsive design */
@media (max-width: 1200px) {
  .table-panel {
    width: 320px;
  }
}

@media (max-width: 768px) {
  .table-panel {
    width: 100%;
    height: auto;
    border-right: none;
    border-bottom: 1px solid #e9ecef;
  }
}
</style>