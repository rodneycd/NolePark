<template>
  <div class="auth-wrapper">
    <div class="login-card">
      <h2 class="title">{{ title }}</h2>
      <slot></slot> 
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{ title: string }>();
</script>

<style scoped>
.auth-wrapper {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #f4f4f4;
}
.login-card {
  width: 100%;
  max-width: 400px;
  background: white;
  padding: 2.5rem;
  border-radius: 12px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
  border-top: 6px solid var(--fsu-garnet);
  text-align: center;
}
.title {
  margin-bottom: 2rem;
  color: var(--fsu-black);
}
</style>