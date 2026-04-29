<template>
  <AuthCard title="Welcome to NolePark">
    <form @submit.prevent="handleLogin" class="login-form">
      <div class="input-group">
        <input v-model="email" type="email" placeholder="FSU Email" required />
        <input v-model="password" type="password" placeholder="Password" required />
      </div>

      <button type="submit" class="login-btn">Login</button>
    </form>

    <p class="signup-text">
      Don't Have an Account? 
      <router-link to="/signup" class="signup-link">Sign up!</router-link>
    </p>
  </AuthCard>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import AuthCard from '@/components/AuthCard.vue';
import authApi from '@/api/auth';
import userApi from '@/api/users';
import { useRouter } from 'vue-router';

const email = ref('');
const password = ref('');
const router = useRouter();

const handleLogin = async () => {
  try {
    const res = await authApi.login({ email: email.value, password: password.value });
    
    if (res.success) {
      localStorage.setItem('active_user_id', res.user_id.toString());
      
      // 1. Fetch the profile immediately to find the role
      const profile = await userApi.getUserProfile(res.user_id); 
      
      // 2. Direct them to the right "front door"
      if (profile.user_role === 'admin') {
        router.push({ name: 'AdminLots' });
      } else if (profile.permit_type === 'None') {
        router.push({ name: 'Settings' });
      } else {
        router.push({ name: 'Home' });
      }
    }
  } catch (err) {
    alert("Invalid credentials or server error");
    console.error("Login failed", err);
  }
};

</script>

<style scoped>
/* Only keep the CSS specific to the form/inputs here */
.input-group {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-bottom: 1.5rem;
}
input {
  padding: 0.8rem;
  border: 1px solid #ddd;
  border-radius: 4px;
}
.login-btn {
  width: 100%;
  padding: 0.8rem;
  background-color: var(--fsu-garnet);
  color: white;
  border: none;
  cursor: pointer;
}
.signup-link {
  color: var(--fsu-gold);
  font-weight: bold;
}
</style>