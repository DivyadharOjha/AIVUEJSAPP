<template>
  <div v-if="isVisible" class="member-popup-overlay" @click="closePopup">
    <div class="member-popup" :style="popupStyle" @click.stop>
      <!-- Popup Header -->
      <div class="popup-header">
        <h6 class="popup-title mb-0">
          <i class="fas fa-user me-2"></i>
          Member Information
        </h6>
        <button class="popup-close-btn" @click="closePopup">
          <i class="fas fa-times"></i>
        </button>
      </div>

      <!-- Popup Content -->
      <div class="popup-content">
        <div v-if="memberInfo" class="member-details">
          <!-- Member Avatar -->
          <div class="member-avatar">
            <img
              :src="memberInfo.avatar || 'https://cdn-icons-png.flaticon.com/512/1946/1946429.png'"
              :alt="memberInfo.name"
              @error="handleImageError"
            />
          </div>

          <!-- Member Info -->
          <div class="member-info">
            <div class="info-row">
              <span class="info-label">Name:</span>
              <span class="info-value">{{ memberInfo.name }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">ID:</span>
              <span class="info-value">{{ memberInfo.id }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">Phone:</span>
              <span class="info-value">{{ memberInfo.phone }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">Email:</span>
              <span class="info-value">{{ memberInfo.email }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">Status:</span>
              <span class="info-value">
                <span :class="['status-badge', memberInfo.status.toLowerCase()]">
                  {{ memberInfo.status }}
                </span>
              </span>
            </div>
            <div class="info-row">
              <span class="info-label">Points:</span>
              <span class="info-value">{{ memberInfo.points || 0 }}</span>
            </div>
          </div>

          <!-- Quick Actions -->
          <div class="quick-actions">
            <button class="action-btn primary" @click="selectMember">
              <i class="fas fa-check me-1"></i>
              Select Member
            </button>
            <button class="action-btn secondary" @click="editMember">
              <i class="fas fa-edit me-1"></i>
              Edit
            </button>
          </div>
        </div>

        <!-- Loading State -->
        <div v-else-if="loading" class="loading-state">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Loading...</span>
          </div>
          <p class="mt-2 mb-0">Loading member information...</p>
        </div>

        <!-- Error State -->
        <div v-else class="error-state">
          <i class="fas fa-exclamation-triangle text-warning"></i>
          <p class="mt-2 mb-0">Failed to load member information</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'

// Props
interface Props {
  isVisible: boolean
  memberId?: string | number
  position?: { x: number; y: number }
}

const props = withDefaults(defineProps<Props>(), {
  isVisible: false,
  memberId: undefined,
  position: () => ({ x: 0, y: 0 }),
})

// Emits
const emit = defineEmits<{
  close: []
  'select-member': [memberId: string | number]
  'edit-member': [memberId: string | number]
}>()

// Reactive state
const loading = ref(false)
const memberInfo = ref<{
  id: string | number
  name: string
  phone: string
  email: string
  status: string
  points: number
  avatar?: string
} | null>(null)

// Computed popup position
const popupStyle = computed(() => {
  if (!props.position) return {}

  // Popup dimensions
  const popupWidth = 320 // min-width of popup
  const popupHalfWidth = popupWidth / 2
  const margin = 10
  const windowWidth = window.innerWidth

  // Calculate initial left position (center of icon)
  let leftPosition = props.position.x - popupHalfWidth

  // Ensure popup doesn't overflow on the right
  if (leftPosition + popupWidth > windowWidth - margin) {
    leftPosition = windowWidth - popupWidth - margin
  }

  // Ensure popup doesn't overflow on the left
  if (leftPosition < margin) {
    leftPosition = margin
  }

  return {
    position: 'absolute' as const,
    left: `${leftPosition}px`,
    top: `${props.position.y}px`,
    zIndex: 1000,
  }
})

// Methods
function closePopup() {
  emit('close')
}

function selectMember() {
  if (props.memberId) {
    emit('select-member', props.memberId)
  }
  closePopup()
}

function editMember() {
  if (props.memberId) {
    emit('edit-member', props.memberId)
  }
  closePopup()
}

function handleImageError(event: Event) {
  const target = event.target as HTMLImageElement
  target.src = 'https://cdn-icons-png.flaticon.com/512/1946/1946429.png'
}

// Load member data when memberId changes
watch(
  () => props.memberId,
  async (newMemberId) => {
    if (newMemberId && props.isVisible) {
      await loadMemberInfo(newMemberId)
    }
  },
  { immediate: true },
)

// Load member data when popup becomes visible
watch(
  () => props.isVisible,
  async (isVisible) => {
    if (isVisible && props.memberId) {
      await loadMemberInfo(props.memberId)
    }
  },
)

async function loadMemberInfo(memberId: string | number) {
  loading.value = true
  memberInfo.value = null

  try {
    // Simulate API call - replace with actual API call
    await new Promise((resolve) => setTimeout(resolve, 500))

    // Mock member data - replace with actual API response
    memberInfo.value = {
      id: memberId,
      name: 'John Doe',
      phone: '+1 (555) 123-4567',
      email: 'john.doe@example.com',
      status: 'Active',
      points: 1250,
      avatar:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
    }
  } catch (error) {
    console.error('Failed to load member info:', error)
  } finally {
    loading.value = false
  }
}

// Expose methods for parent component
defineExpose({
  loadMemberInfo,
})
</script>

<style scoped>
.member-popup-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.3);
  z-index: 999;
  display: flex;
  align-items: flex-start;
  justify-content: center;
}

.member-popup {
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  min-width: 320px;
  max-width: 400px;
  max-height: 80vh;
  overflow: hidden;
  animation: popup-slide-in 0.2s ease-out;
}

@keyframes popup-slide-in {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.popup-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 16px;
  background: #f8f9fa;
  border-bottom: 1px solid #e9ecef;
}

.popup-title {
  font-size: 1rem;
  font-weight: 600;
  color: #495057;
}

.popup-close-btn {
  background: none;
  border: none;
  color: #6c757d;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  transition: all 0.2s;
}

.popup-close-btn:hover {
  background: #e9ecef;
  color: #495057;
}

.popup-content {
  padding: 16px;
}

.member-details {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.member-avatar {
  display: flex;
  justify-content: center;
}

.member-avatar img {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  object-fit: cover;
  border: 3px solid #e9ecef;
}

.member-info {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 4px 0;
}

.info-label {
  font-weight: 600;
  color: #6c757d;
  font-size: 0.9rem;
}

.info-value {
  color: #495057;
  font-size: 0.9rem;
}

.status-badge {
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
}

.status-badge.active {
  background: #d4edda;
  color: #155724;
}

.status-badge.inactive {
  background: #f8d7da;
  color: #721c24;
}

.status-badge.pending {
  background: #fff3cd;
  color: #856404;
}

.quick-actions {
  display: flex;
  gap: 8px;
  margin-top: 8px;
}

.action-btn {
  flex: 1;
  padding: 8px 12px;
  border: none;
  border-radius: 6px;
  font-size: 0.85rem;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.action-btn.primary {
  background: #007bff;
  color: white;
}

.action-btn.primary:hover {
  background: #0056b3;
}

.action-btn.secondary {
  background: #6c757d;
  color: white;
}

.action-btn.secondary:hover {
  background: #545b62;
}

.loading-state,
.error-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 32px 16px;
  text-align: center;
}

.loading-state .spinner-border {
  width: 2rem;
  height: 2rem;
}

.error-state i {
  font-size: 2rem;
}

/* Responsive adjustments */
@media (max-width: 576px) {
  .member-popup {
    min-width: 280px;
    margin: 16px;
  }

  .popup-content {
    padding: 12px;
  }

  .quick-actions {
    flex-direction: column;
  }
}
</style>
