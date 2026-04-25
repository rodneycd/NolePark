<template>
  <div id="app">
    <main :class="{ 'has-nav': showNav }">
      <router-view />
    </main>

    <BottomNav v-if="showNav" />
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { useRoute } from 'vue-router';
import BottomNav from '@/components/BottomNavBar.vue';

const route = useRoute();

// Only show nav if we aren't on the auth pages
const showNav = computed(() => {
  return route.name !== 'Login' && route.name !== 'Signup' && !route.path.startsWith('/admin');
});
</script>

<style>
/* Add padding to the bottom so the nav doesn't cover content */
.has-nav {
  padding-bottom: 75px;
}

body {
  margin: 0;
  background-color: var(--bg-light);
  font-family: sans-serif;
}
</style>