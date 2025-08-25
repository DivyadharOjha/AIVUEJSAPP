<template>
  <div class="pagination-container">
    <div class="row">
      <div class="col-12">
        <div class="d-flex justify-content-center align-items-center h-100">
          <!-- First Button -->
          <button
            class="btn btn-outline-primary btn-sm me-2"
            @click="handleFirstClick"
            :disabled="currentPage === 1"
            title="Go to first page"
          >
            First
          </button>

          <!-- Previous Button -->
          <button
            class="btn btn-outline-primary btn-sm me-2"
            @click="handlePreviousClick"
            :disabled="currentPage === 1"
            title="Go to previous page"
          >
            Previous
          </button>

          <!-- Page Count Label -->
          <span class="page-count-label mx-3">
            Page {{ currentPage }} of {{ totalPages }}
            <span v-if="totalRecords > 0" class="record-count"> ({{ totalRecords }} records) </span>
          </span>

          <!-- Next Button -->
          <button
            class="btn btn-outline-primary btn-sm ms-2"
            @click="handleNextClick"
            :disabled="currentPage === totalPages"
            title="Go to next page"
          >
            Next
          </button>

          <!-- Last Button -->
          <button
            class="btn btn-outline-primary btn-sm ms-2"
            @click="handleLastClick"
            :disabled="currentPage === totalPages"
            title="Go to last page"
          >
            Last
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Props for parent component to set
defineProps<{
  currentPage: number
  totalPages: number
  totalRecords: number
}>()

// Emit events for parent component to handle
const emit = defineEmits<{
  'first-click': []
  'previous-click': []
  'next-click': []
  'last-click': []
}>()

// Event handlers
function handleFirstClick() {
  emit('first-click')
}

function handlePreviousClick() {
  emit('previous-click')
}

function handleNextClick() {
  emit('next-click')
}

function handleLastClick() {
  emit('last-click')
}
</script>

<style scoped>
.pagination-container {
  padding: 8px 0;
  border-top: 1px solid #e9ecef;
  border-radius: 0 0 6px 6px;
}

.page-count-label {
  font-size: 0.95rem;
  font-weight: 500;
  color: #495057;
  min-width: 120px;
  text-align: center;
}

.record-count {
  font-size: 0.85rem;
  color: #6c757d;
  font-weight: 400;
}

.btn {
  min-width: 80px;
  font-weight: 500;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn:not(:disabled):hover {
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

@media (max-width: 576px) {
  .page-count-label {
    font-size: 0.85rem;
    min-width: 100px;
  }

  .record-count {
    display: none;
  }

  .btn {
    min-width: 70px;
    font-size: 0.85rem;
  }
}
</style>
