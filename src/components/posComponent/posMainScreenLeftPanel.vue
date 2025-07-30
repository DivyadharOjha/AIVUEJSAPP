<template>
  <div class="left-panel">
    <!-- Panel Header -->
    <div class="panel-header">
      <h3 class="panel-title">POS System</h3>
      <div class="user-info">
        <span class="user-name">{{ currentUser.name }}</span>
        <span class="user-role">{{ currentUser.role }}</span>
      </div>
    </div>

    <!-- Navigation Menu -->
    <div class="navigation-menu">
      <h4 class="menu-title">Menu</h4>
      <ul class="menu-list">
        <li
          v-for="item in menuItems"
          :key="item.id"
          class="menu-item"
          :class="{ active: activeMenuItem === item.id }"
          @click="selectMenuItem(item)"
        >
          <div class="menu-icon">
            <i :class="item.icon"></i>
          </div>
          <span class="menu-text">{{ item.name }}</span>
          <div v-if="item.badge" class="menu-badge">{{ item.badge }}</div>
        </li>
      </ul>
    </div>

    <!-- Cart Summary -->
    <div class="cart-summary">
      <div class="cart-header">
        <h4 class="cart-title">Cart</h4>
        <span class="cart-count">{{ cartItems.length }} items</span>
      </div>

      <div class="cart-items" v-if="cartItems.length > 0">
        <div v-for="item in cartItems" :key="item.id" class="cart-item">
          <div class="item-info">
            <span class="item-name">{{ item.name }}</span>
            <span class="item-price">₹{{ item.price.toFixed(2) }}</span>
          </div>
          <div class="item-quantity">
            <button @click="decreaseQuantity(item)" class="qty-btn">-</button>
            <span class="qty-value">{{ item.quantity }}</span>
            <button @click="increaseQuantity(item)" class="qty-btn">+</button>
          </div>
        </div>
      </div>

      <div class="cart-empty" v-else>
        <p>No items in cart</p>
      </div>

      <!-- Cart Total -->
      <div class="cart-total">
        <div class="total-row">
          <span>Subtotal:</span>
          <span>₹{{ cartSubtotal.toFixed(2) }}</span>
        </div>
        <div class="total-row">
          <span>Tax ({{ taxRate }}%):</span>
          <span>₹{{ cartTax.toFixed(2) }}</span>
        </div>
        <div class="total-row total-final">
          <span>Total:</span>
          <span>₹{{ cartTotal.toFixed(2) }}</span>
        </div>
      </div>
    </div>

    <!-- Quick Actions -->
    <div class="quick-actions">
      <h4 class="actions-title">Quick Actions</h4>
      <div class="action-buttons">
        <button
          v-for="action in quickActions"
          :key="action.id"
          class="action-btn"
          :class="action.class"
          @click="performAction(action)"
          :disabled="action.disabled"
        >
          <i :class="action.icon"></i>
          <span>{{ action.name }}</span>
        </button>
      </div>
    </div>

    <!-- Panel Footer -->
    <div class="panel-footer">
      <div class="footer-info">
        <span class="store-name">{{ storeInfo.name }}</span>
        <span class="store-location">{{ storeInfo.location }}</span>
      </div>
      <div class="footer-actions">
        <button class="footer-btn" @click="openSettings">
          <i class="fas fa-cog"></i>
        </button>
        <button class="footer-btn" @click="logout">
          <i class="fas fa-sign-out-alt"></i>
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, defineEmits } from 'vue'

const emit = defineEmits([
  'menu-item-selected',
  'cart-updated',
  'action-performed',
  'settings-opened',
  'logout',
])

// Current user data
const currentUser = ref({
  name: 'John Doe',
  role: 'Cashier',
})

// Store information
const storeInfo = ref({
  name: 'Main Store',
  location: 'Downtown',
})

// Active menu item
const activeMenuItem = ref(1)

// Menu items
const menuItems = ref([
  {
    id: 1,
    name: 'Products',
    icon: 'fas fa-box',
    badge: null,
  },
  {
    id: 2,
    name: 'Orders',
    icon: 'fas fa-shopping-cart',
    badge: '3',
  },
  {
    id: 3,
    name: 'Customers',
    icon: 'fas fa-users',
    badge: null,
  },
  {
    id: 4,
    name: 'Reports',
    icon: 'fas fa-chart-bar',
    badge: null,
  },
  {
    id: 5,
    name: 'Inventory',
    icon: 'fas fa-warehouse',
    badge: '2',
  },
])

// Cart items
const cartItems = ref([
  {
    id: 1,
    name: 'Pizza Margherita',
    price: 12.99,
    quantity: 2,
  },
  {
    id: 2,
    name: 'Coca Cola',
    price: 2.5,
    quantity: 1,
  },
])

// Tax rate
const taxRate = ref(8.5)

// Quick actions
const quickActions = ref([
  {
    id: 1,
    name: 'New Sale',
    icon: 'fas fa-plus',
    class: 'btn-primary',
    disabled: false,
  },
  {
    id: 2,
    name: 'Return',
    icon: 'fas fa-undo',
    class: 'btn-warning',
    disabled: false,
  },
  {
    id: 3,
    name: 'Hold Sale',
    icon: 'fas fa-pause',
    class: 'btn-info',
    disabled: cartItems.value.length === 0,
  },
  {
    id: 4,
    name: 'Clear Cart',
    icon: 'fas fa-trash',
    class: 'btn-danger',
    disabled: cartItems.value.length === 0,
  },
])

// Computed properties
const cartSubtotal = computed(() => {
  return cartItems.value.reduce((total, item) => {
    return total + item.price * item.quantity
  }, 0)
})

const cartTax = computed(() => {
  return cartSubtotal.value * (taxRate.value / 100)
})

const cartTotal = computed(() => {
  return cartSubtotal.value + cartTax.value
})

// Methods
function selectMenuItem(item) {
  activeMenuItem.value = item.id
  emit('menu-item-selected', item)
}

function increaseQuantity(item) {
  item.quantity++
  emit('cart-updated', cartItems.value)
}

function decreaseQuantity(item) {
  if (item.quantity > 1) {
    item.quantity--
  } else {
    // Remove item if quantity becomes 0
    const index = cartItems.value.findIndex((cartItem) => cartItem.id === item.id)
    if (index > -1) {
      cartItems.value.splice(index, 1)
    }
  }
  emit('cart-updated', cartItems.value)
}

function performAction(action) {
  switch (action.id) {
    case 1: // New Sale
      clearCart()
      break
    case 2: // Return
      // Handle return logic
      break
    case 3: // Hold Sale
      // Handle hold sale logic
      break
    case 4: // Clear Cart
      clearCart()
      break
  }
  emit('action-performed', action)
}

function clearCart() {
  cartItems.value = []
  emit('cart-updated', cartItems.value)
}

function openSettings() {
  emit('settings-opened')
}

function logout() {
  emit('logout')
}

// Add item to cart (to be called from parent)
function addToCart(product) {
  const existingItem = cartItems.value.find((item) => item.id === product.ProductId)

  if (existingItem) {
    existingItem.quantity++
  } else {
    cartItems.value.push({
      id: product.ProductId,
      name: product.ProductName,
      price: product.ProductRate,
      quantity: 1,
    })
  }

  emit('cart-updated', cartItems.value)
}

// Expose methods for parent component
defineExpose({
  addToCart,
  clearCart,
})
</script>

<style scoped>
.left-panel {
  width: 300px;
  height: 100%;
  background: #f8f9fa;
  border-right: 1px solid #e9ecef;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.panel-header {
  padding: 20px;
  background: #343a40;
  color: white;
  border-bottom: 1px solid #495057;
}

.panel-title {
  margin: 0 0 10px 0;
  font-size: 18px;
  font-weight: 600;
}

.user-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.user-name {
  font-size: 14px;
  font-weight: 500;
}

.user-role {
  font-size: 12px;
  color: #adb5bd;
}

.navigation-menu {
  padding: 20px;
  border-bottom: 1px solid #e9ecef;
}

.menu-title {
  margin: 0 0 15px 0;
  font-size: 14px;
  font-weight: 600;
  color: #495057;
  text-transform: uppercase;
}

.menu-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.menu-item {
  display: flex;
  align-items: center;
  padding: 12px 15px;
  margin-bottom: 5px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
}

.menu-item:hover {
  background: #e9ecef;
}

.menu-item.active {
  background: #007bff;
  color: white;
}

.menu-icon {
  width: 20px;
  margin-right: 12px;
  text-align: center;
}

.menu-text {
  flex: 1;
  font-size: 14px;
  font-weight: 500;
}

.menu-badge {
  background: #dc3545;
  color: white;
  font-size: 10px;
  padding: 2px 6px;
  border-radius: 10px;
  min-width: 18px;
  text-align: center;
}

.menu-item.active .menu-badge {
  background: rgba(255, 255, 255, 0.3);
}

.cart-summary {
  flex: 1;
  padding: 20px;
  border-bottom: 1px solid #e9ecef;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

.cart-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}

.cart-title {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
  color: #495057;
  text-transform: uppercase;
}

.cart-count {
  font-size: 12px;
  color: #6c757d;
}

.cart-items {
  flex: 1;
  overflow-y: auto;
  margin-bottom: 15px;
}

.cart-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 0;
  border-bottom: 1px solid #f1f3f4;
}

.item-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.item-name {
  font-size: 13px;
  font-weight: 500;
  color: #495057;
}

.item-price {
  font-size: 12px;
  color: #28a745;
  font-weight: 600;
}

.item-quantity {
  display: flex;
  align-items: center;
  gap: 8px;
}

.qty-btn {
  width: 24px;
  height: 24px;
  border: 1px solid #dee2e6;
  background: white;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: 600;
}

.qty-btn:hover {
  background: #f8f9fa;
}

.qty-value {
  font-size: 13px;
  font-weight: 500;
  min-width: 20px;
  text-align: center;
}

.cart-empty {
  text-align: center;
  padding: 40px 20px;
  color: #6c757d;
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}

.cart-total {
  border-top: 1px solid #e9ecef;
  padding-top: 15px;
}

.total-row {
  display: flex;
  justify-content: space-between;
  margin-bottom: 8px;
  font-size: 13px;
}

.total-final {
  font-weight: 600;
  font-size: 15px;
  color: #495057;
  border-top: 1px solid #e9ecef;
  padding-top: 8px;
  margin-bottom: 0;
}

.quick-actions {
  padding: 20px;
  border-bottom: 1px solid #e9ecef;
}

.actions-title {
  margin: 0 0 15px 0;
  font-size: 14px;
  font-weight: 600;
  color: #495057;
  text-transform: uppercase;
}

.action-buttons {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 10px;
}

.action-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 6px;
  padding: 12px 8px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 11px;
  font-weight: 500;
}

.action-btn i {
  font-size: 16px;
}

.action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-primary {
  background: #007bff;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #0056b3;
}

.btn-warning {
  background: #ffc107;
  color: #212529;
}

.btn-warning:hover:not(:disabled) {
  background: #e0a800;
}

.btn-info {
  background: #17a2b8;
  color: white;
}

.btn-info:hover:not(:disabled) {
  background: #117a8b;
}

.btn-danger {
  background: #dc3545;
  color: white;
}

.btn-danger:hover:not(:disabled) {
  background: #c82333;
}

.panel-footer {
  padding: 15px 20px;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.footer-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.store-name {
  font-size: 12px;
  font-weight: 600;
  color: #495057;
}

.store-location {
  font-size: 11px;
  color: #6c757d;
}

.footer-actions {
  display: flex;
  gap: 8px;
}

.footer-btn {
  width: 32px;
  height: 32px;
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

.footer-btn:hover {
  background: #e9ecef;
  color: #495057;
}

/* Responsive design */
@media (max-width: 1200px) {
  .left-panel {
    width: 280px;
  }
}

@media (max-width: 768px) {
  .left-panel {
    width: 100%;
    height: auto;
    border-right: none;
    border-bottom: 1px solid #e9ecef;
  }

  .action-buttons {
    grid-template-columns: repeat(4, 1fr);
  }

  .action-btn {
    padding: 8px 4px;
    font-size: 10px;
  }
}
</style>
