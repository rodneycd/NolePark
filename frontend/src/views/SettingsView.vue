<template>
  <div class="settings-container">
    <h1 class="header-text">Account Settings</h1>

    <section class="settings-card">
      <h2>Parking Permit</h2>
      <p class="subtitle">Select your current FSU parking permit type.</p>
      <div class="form-group">
        <select v-model="selectedPermit" class="permit-dropdown">
          <option value="" disabled>Choose a permit...</option>
          <option 
            v-for="permit in filteredPermits" 
            :key="permit.permit_type" 
            :value="permit.permit_type"
          >
            {{ permit.permit_type }}
          </option>
        </select>
        
        <button 
          @click="handleUpdatePermit" 
          class="btn-primary update-btn" 
          :disabled="isUpdating"
        >
          {{ isUpdating ? 'Saving...' : 'Update Permit' }}
        </button>
      </div>

      <p v-if="statusMessage" :class="['status-msg', { 'error': isError }]">
        {{ statusMessage }}
      </p>
    </section>

    <section class="settings-card logout-section">
      <button @click="logout" class="btn-outline">Logout of NolePark</button>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import { useRouter } from 'vue-router';
import userApi from '@/api/users';

const router = useRouter();
const allPermits = ref<{ permit_type: string }[]>([]);
const selectedPermit = ref('');
const isUpdating = ref(false);
const statusMessage = ref('');
const isError = ref(false);

const filteredPermits = computed(() => {
  return allPermits.value.filter(p => p.permit_type?.toLowerCase() !== 'none');
});

onMounted(async () => {
  try {
    const userId = localStorage.getItem('active_user_id');
    if (!userId) return;


    const [permitData, profileData] = await Promise.all([
      userApi.getPermits(),
      userApi.getUserProfile(Number(userId))
    ]);

    allPermits.value = permitData;
    
    if (profileData.permit_type !== 'None') {
      selectedPermit.value = profileData.permit_type ?? '';
    }
  } catch (err) {
    console.error("Failed to load settings data", err);
  }
});

const handleUpdatePermit = async () => {
  const userId = localStorage.getItem('active_user_id');
  if (!userId || !selectedPermit.value) return;

  isUpdating.value = true;
  isError.value = false;
  statusMessage.value = '';
  try {
    const res = await userApi.updatePermit(Number(userId), selectedPermit.value);
    
    if (res.success) {
      statusMessage.value = "Permit updated successfully!";
    } else {
      isError.value = true;
      statusMessage.value = res.message || "Failed to update.";
    }
  } catch (err) {
    isError.value = true;
    statusMessage.value = "Connection error. Please try again.";
  } finally {
    isUpdating.value = false;
    setTimeout(() => { statusMessage.value = ''; }, 3000);
  }
};

const logout = () => {
  localStorage.removeItem('active_user_id');
  router.push('/login');
};
</script>

<style scoped>
.settings-container {
  max-width: 800px;
  margin: 2rem auto;
  padding: 0 1rem;
  color: var(--text-main);
}

.header-text {
  color: var(--primary);
  margin-bottom: 1.5rem;
}

.settings-card {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  margin-bottom: 2rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05); 
  border-top: 4px solid var(--accent);
}

.permit-dropdown {
  width: 100%;
  padding: 0.8rem;
  margin: 1rem 0;
  border: 1px solid #ddd;
  border-radius: 8px;
  background-color: white;
}

.update-btn {
  width: 100%;
  cursor: pointer;
  border: none;
  font-weight: bold;
}

.status-msg {
  margin-top: 1rem;
  font-weight: 500;
  text-align: center;
}

.status-msg.error {
  color: #d32f2f;
}

.btn-outline {
  background: transparent;
  border: 2px solid var(--primary);
  color: var(--primary);
  width: 100%;
  padding: 10px;
  border-radius: 8px;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-outline:hover {
  background-color: var(--bg-light);
}
</style>