<template>
  <div class="search-member-container">
    <!-- First Row - Search Input -->
    <div class="row search-row">
      <div class="col-12">
        <div class="search-input-container">
          <input
            type="text"
            class="form-control search-input"
            placeholder="Search by Name, Code, Alias..."
            v-model="searchQuery"
            @input="handleSearch"
            @keyup.enter="handleSearch"
          />
          <button class="btn btn-primary search-btn" type="button" @click="handleSearch">
            Search
          </button>
        </div>
      </div>
    </div>

    <!-- Second Row - Results Table -->
    <div class="row table-row">
      <div class="col-12">
        <div class="table-responsive">
          <table class="table table-striped table-hover">
            <thead class="table-dark">
              <tr>
                <th scope="col" class="text-center">S.No.</th>
                <th scope="col">Name</th>
                <th scope="col">Code</th>
                <th scope="col">Alias</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(member, index) in filteredMembers"
                :key="member.id"
                @click="selectMember(member)"
                :class="{ 'table-primary': selectedMember?.id === member.id }"
                class="member-row"
              >
                <td class="text-center">{{ index + 1 }}</td>
                <td>{{ member.name }}</td>
                <td>{{ member.code }}</td>
                <td>{{ member.alias }}</td>
              </tr>
              <tr v-if="filteredMembers.length === 0">
                <td colspan="4" class="text-center text-muted py-4">
                  <i class="fas fa-search me-2"></i>
                  No members found matching your search criteria
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Third Row - Action Buttons -->
    <div class="row action-row">
      <div class="col-12 d-flex justify-content-between gap-2">
        <button type="button" class="btn btn-outline-secondary" @click="handleBack">
          <i class="fas fa-arrow-left me-2"></i>
          Back
        </button>
        <div class="d-flex gap-2">
          <button
            type="button"
            class="btn btn-success"
            @click="handleOk"
            :disabled="!selectedMember"
          >
            <i class="fas fa-check me-2"></i>
            OK
          </button>
          <button type="button" class="btn btn-secondary" @click="handleClose">
            <i class="fas fa-times me-2"></i>
            Close
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'

// Member interface
interface Member {
  id: number
  name: string
  code: string
  alias: string
}

// Props
interface Props {
  initialSearch?: string
}

const props = withDefaults(defineProps<Props>(), {
  initialSearch: '',
})

// Emits
const emit = defineEmits<{
  'member-selected': [member: Member]
  close: []
}>()

// Reactive data
const searchQuery = ref(props.initialSearch)
const selectedMember = ref<Member | null>(null)

// Sample member data (replace with actual data source)
const members = ref<Member[]>([
  { id: 1, name: 'John Doe', code: 'M001', alias: 'JD' },
  { id: 2, name: 'Jane Smith', code: 'M002', alias: 'JS' },
  { id: 3, name: 'Mike Johnson', code: 'M003', alias: 'MJ' },
  { id: 4, name: 'Sarah Wilson', code: 'M004', alias: 'SW' },
  { id: 5, name: 'David Brown', code: 'M005', alias: 'DB' },
  { id: 6, name: 'Lisa Davis', code: 'M006', alias: 'LD' },
  { id: 7, name: 'Robert Miller', code: 'M007', alias: 'RM' },
  { id: 8, name: 'Emily Garcia', code: 'M008', alias: 'EG' },
  { id: 9, name: 'James Rodriguez', code: 'M009', alias: 'JR' },
  { id: 10, name: 'Maria Martinez', code: 'M010', alias: 'MM' },
])

// Computed properties
const filteredMembers = computed(() => {
  if (!searchQuery.value.trim()) {
    return members.value
  }

  const query = searchQuery.value.toLowerCase().trim()
  return members.value.filter(
    (member) =>
      member.name.toLowerCase().includes(query) ||
      member.code.toLowerCase().includes(query) ||
      member.alias.toLowerCase().includes(query),
  )
})

// Methods
function handleSearch(): void {
  // Reset selection when searching
  selectedMember.value = null
  console.log('Searching for:', searchQuery.value)
}

function selectMember(member: Member): void {
  selectedMember.value = member
  console.log('Selected member:', member)
}

function handleOk(): void {
  if (selectedMember.value) {
    emit('member-selected', selectedMember.value)
    console.log('OK clicked - Member selected:', selectedMember.value)
  }
}

function handleClose(): void {
  emit('close')
  console.log('Close clicked')
}

function handleBack(): void {
  emit('close')
  console.log('Back button clicked - returning to previous screen')
}

// Lifecycle
onMounted(() => {
  if (props.initialSearch) {
    handleSearch()
  }
})
</script>

<style scoped>
.search-member-container {
  height: 100%;
  width: 100%;
  padding: 20px;
  background: #ffffff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
}

.search-row {
  flex-shrink: 0;
  margin-bottom: 16px;
}

.table-row {
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
}

.action-row {
  flex-shrink: 0;
  margin-top: 16px;
}

.member-row {
  cursor: pointer;
  transition: background-color 0.2s ease;
}

.member-row:hover {
  background-color: #f8f9fa !important;
}

.member-row.table-primary {
  background-color: #cce7ff !important;
}

.member-row.table-primary:hover {
  background-color: #b3d9ff !important;
}

/* Custom styling for better visual hierarchy */
.table-responsive {
  border-radius: 6px;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 0;
}

.table {
  margin-bottom: 0;
  width: 100%;
  table-layout: fixed;
  border-collapse: collapse;
}

.table thead {
  position: sticky;
  top: 0;
  z-index: 1;
  background-color: #343a40;
}

.table th {
  font-weight: 600;
  border-bottom: 2px solid #dee2e6;
  padding: 12px 8px;
  text-align: center;
  color: white;
  width: 25%;
}

.table td {
  vertical-align: middle;
  border-bottom: 1px solid #dee2e6;
  padding: 12px 8px;
  text-align: center;
  width: 25%;
}

.table tbody {
  max-height: calc(100vh - 300px);
  overflow-y: auto;
}

/* Search input styling */
.search-input-container {
  display: flex;
  gap: 10px;
  align-items: center;
}

.search-input {
  flex: 1;
  border: 1px solid #ced4da;
  border-radius: 6px;
  padding: 10px 12px;
  font-size: 14px;
}

.search-input:focus {
  border-color: #007bff;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
  outline: none;
}

.search-btn {
  padding: 10px 20px;
  border-radius: 6px;
  font-weight: 500;
  white-space: nowrap;
}

/* Button styling */
.btn {
  font-weight: 500;
  transition: all 0.2s ease;
}

.btn:hover {
  transform: translateY(-1px);
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Responsive design */
@media (max-width: 768px) {
  .search-member-container {
    padding: 16px;
  }

  .table-responsive {
    font-size: 14px;
  }

  .btn {
    padding: 8px 16px;
    font-size: 14px;
  }
}

@media (max-width: 576px) {
  .input-group {
    flex-direction: column;
  }

  .input-group-text {
    border-radius: 6px 6px 0 0 !important;
  }

  .form-control {
    border-radius: 0 !important;
  }

  .btn {
    border-radius: 0 0 6px 6px !important;
  }
}
</style>
