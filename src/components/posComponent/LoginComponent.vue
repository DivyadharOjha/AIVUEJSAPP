<template>
  <div>
    <template v-if="!loggedIn">
      <div class="d-flex justify-content-center align-items-center vh-100">
        <div class="card p-4 shadow" style="min-width: 320px;">
          <h3 class="text-center mb-4">Login</h3>
          <form @submit.prevent="handleLogin">
            <div class="mb-3">
              <label for="login" class="form-label">Login</label>
              <input
                type="text"
                id="login"
                v-model="login"
                :class="['form-control', loginBorderClass]"
                @focus="loginFocused = true"
                @blur="onLoginBlur"
                placeholder="Enter login"
                required
              />
            </div>
            <div class="mb-3">
              <label for="password" class="form-label">Password</label>
              <input type="password" id="password" v-model="password" :class="['form-control', passwordBorderClass]"
                @focus="passwordFocused = true" @blur="onPasswordBlur" placeholder="Enter password" required />
            </div>
            <button type="submit" class="btn btn-primary w-100">Login</button>
          </form>
        </div>
      </div>
    </template>
    <template v-else>
      <PosMainScreen />
    </template>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import PosMainScreen from './posMainScreen.vue';

const login = ref('');
const password = ref('');
const loginFocused = ref(false);
const passwordFocused = ref(false);
const loginTouched = ref(false);
const passwordTouched = ref(false);
const loggedIn = ref(false);

const loginBorderClass = computed(() => {
  if (loginFocused.value) {
    return 'border-blue';
  } else if (loginTouched.value && login.value.length <= 0) {
    return 'border-red';
  } else {
    return 'border-gray';
  }
});

const passwordBorderClass = computed(() => {
  if (passwordFocused.value) {
    return 'border-blue';
  } else if (passwordTouched.value && password.value.length <= 0) {
    return 'border-red';
  } else {
    return 'border-gray';
  }
});

function handleLogin() {
  // You can add real authentication logic here
  loggedIn.value = true;
}

function onLoginBlur() {
  loginFocused.value = false;
  loginTouched.value = true;
}

function onPasswordBlur() {
  passwordFocused.value = false;
  passwordTouched.value = true;
}
</script>

<style scoped>
.border-gray {
  border: 1px solid gray !important;
}
.border-blue {
  border: 1px solid blue !important;
}
.border-red {
  border: 1px solid red !important;
}
</style>
