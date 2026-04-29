<template>
    <AuthCard title="Join NolePark">
    <form @submit.prevent="handleSignup" class="login-form">
      <div class="input-group">
        <input v-model="form.name" type="text" placeholder="Full Name" required />
        <input v-model="form.fsuid" type="text" placeholder="FSU ID" required />
        <input v-model="form.email" type="email" placeholder="FSU Email" required />
        <input v-model="form.password" type="password" placeholder="Password" required />
      </div>

      <button type="submit" class="signup-btn">Create Account</button>
    </form>

    <p class="signup-text">
      Already Have an Account? 
      <router-link to="/login" class="login-link">Login!</router-link>
    </p>
  </AuthCard>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import authApi from '@/api/auth';
import AuthCard from '@/components/AuthCard.vue';

const router = useRouter();
const loading = ref(false);
const success = ref(false);

const form = ref({
  name: '',
  fsuid: '',
  email: '',
  password: ''
});

const handleSignup = async () => {
  try {
    const res = await authApi.signup(form.value);
    
    if (res.success && res.user_id) {
      localStorage.setItem('active_user_id', res.user_id.toString());
    
      alert("Welcome to NolePark! Please finish registering your vehicle in Settings.");
      
      router.push('/settings');
    }
  } catch (err: any) {
    alert(err.message);
  }
};
</script>

<style scoped>
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
.signup-btn {
  width: 100%;
  padding: 0.8rem;
  background-color: var(--fsu-garnet);
  color: white;
  border: none;
  cursor: pointer;
}
.login-link {
  color: var(--fsu-gold);
  font-weight: bold;
}
</style>