<script setup lang="ts">
import { ref, onMounted } from 'vue';
import sessionApi from '@/api/sessions';
import type { ParkingSession } from '@/types';
import NewSessionForm from '@/components/NewSessionForm.vue';
import ActiveSessionCard from '@/components/ActiveSessionCard.vue';

const activeSession = ref<ParkingSession | null>(null);
const isCreating = ref(false);
const isLoading = ref(true);
const userId = Number(localStorage.getItem('active_user_id'))

const fetchSessionState = async () => {
  isLoading.value = true;
  activeSession.value = await sessionApi.getActiveSession(userId);
  isLoading.value = false;
};

const handleEndSession = async () => {
  if (!activeSession.value) return;
  
  if (!confirm("Are you sure you want to end your parking session?")) return;

  try {
    await sessionApi.endSession(userId, activeSession.value.session_id);
    activeSession.value = null; 
  } catch (err) {
    alert("Error ending session. Please try again.");
  }
};

onMounted(fetchSessionState);
</script>

<template>
  <div class="sessions-container">
    <div v-if="isLoading" class="loading-state">
      <p>Checking session status...</p>
    </div>
    
    <template v-else>
      <div v-if="!activeSession && !isCreating" class="empty-state">
        <button class="btn-primary new-session-btn" @click="isCreating = true">
          New Session
        </button>
      </div>

      <NewSessionForm 
        v-if="isCreating"
        :user-id="userId" 
        @cancel="isCreating = false" 
        @started="fetchSessionState(); isCreating = false;" 
      />

      <ActiveSessionCard 
        v-if="activeSession" 
        :session="activeSession" 
        @end="handleEndSession" 
      />
    </template>
  </div>
</template>

<style scoped>
.sessions-container {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: calc(100vh - 80px); /* Adjust based on navbar height */
  background-color: var(--bg-light);
  padding: 20px;
}

.new-session-btn {
  padding: 16px 48px;
  font-size: 1.2rem;
  font-weight: bold;
  box-shadow: 0 4px 12px rgba(120, 47, 64, 0.3); /* Garnet shadow */
  transition: transform 0.2s ease;
}

.new-session-btn:hover {
  transform: translateY(-2px);
}

.loading-state {
  color: var(--text-main);
  font-weight: bold;
}
</style>