<template>
  <div class="home-container">
    <header class="dashboard-header">
      <div class="title-bar">Available for Your Permit</div>
    </header>

    <div v-if="loading" class="loader">Checking availability...</div>

    <div v-else class="scroll-view">
      <p v-if="lots.length === 0" class="no-lots">
        No compatible lots found for your permit type.
      </p>
      
      <LotCard 
      v-for="lot in lots" 
      :key="lot.lot_id"
      :name="lot.lot_name"
      :available="lot.user_available"   :percent="lot.user_pct_full" 
      :lotType="lot.lot_type"
      />
    </div>
  </div>
</template>



<script setup lang="ts">
import { ref, onMounted } from 'vue';
import lotApi from '@/api/lots';
import type { ParkingLot } from '@/types'; 
import LotCard from '@/components/LotCard.vue';

const lots = ref<ParkingLot[]>([]); 
const loading = ref(true);

onMounted(async () => {
  const userId = localStorage.getItem('active_user_id');
  if (userId) {
    try {
      // Fetching only the lots the user's permit allows
      lots.value = await lotApi.getLotsForUser(Number(userId));
    } catch (err) {
      console.error("Failed to load lots", err);
    } finally {
      loading.value = false;
    }
  }
});
</script>

<style scoped>
.home-container {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.dashboard-header {
  padding: 1rem;
  background-color: var(--bg-light);
  position: sticky;
  top: 0;
  z-index: 10;
}

.title-bar {
  padding: 0.5rem;
  text-align: center;
  font-weight: bold;
}

.scroll-view {
  padding: 1rem;
  /* Ensure padding at bottom so the Nav doesn't hide the last card */
  padding-bottom: 2rem; 
}
</style>