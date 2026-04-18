<template>
  <nav class="bottom-nav">
    <router-link to="/home" class="nav-item">
      <div class="indicator"></div>
      <span class="icon">🏠</span>
      <span class="label">Home</span>
    </router-link>

    <router-link to="/search" class="nav-item">
      <div class="indicator"></div>
      <span class="icon">🔍</span>
      <span class="label">Search</span>
    </router-link>

    <router-link to="/sessions" class="nav-item">
      <div class="indicator"></div>
      <span class="icon">🚗</span>
      <span class="label">Sessions</span>
    </router-link>

    <router-link to="/settings" class="nav-item">
      <div class="indicator"></div>
      <span class="icon">⚙️</span>
      <span class="label">Settings</span>
    </router-link>
  </nav>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import userApi from '@/api/users';

const isLocked = ref(true);

onMounted(async () => {
  const userId = localStorage.getItem('active_user_id');
  if (userId) {
    const profile = await userApi.getUserProfile(Number(userId));
    // If they have a real permit we unlock the tabs
    isLocked.value = profile.permit_type === 'None';
  }
});
</script>

<style scoped>
.bottom-nav {
  position: fixed;
  bottom: 0;
  width: 100%;
  height: 70px;
  background-color: white;
  display: flex;
  justify-content: space-around;
  border-top: 1px solid #eee;
  box-shadow: 0 -2px 10px rgba(0,0,0,0.05);
}

.nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-decoration: none;
  color: #888;
  position: relative;
  flex: 1;
  transition: color 0.3s ease;
}

/* The Indicator Bar */
.indicator {
  position: absolute;
  top: 0;
  width: 40%;
  height: 4px;
  background-color: transparent;
  border-radius: 0 0 4px 4px;
  transition: background-color 0.3s ease;
}

/* Active State Styles */
.router-link-active {
  color: var(--primary); /* FSU Garnet */
}

.router-link-active .indicator {
  background-color: var(--fsu-gold); /* FSU Gold Indicator */
}

.icon { font-size: 1.4rem; }
.label { font-size: 0.75rem; margin-top: 2px; }
</style>