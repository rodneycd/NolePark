<template>
  <div class="stats-ribbon">
    <div v-for="stat in stats" :key="stat.label" class="stat-card">
      <div class="stat-icon">{{ stat.icon }}</div>
      <div class="stat-info">
        <p class="stat-label">{{ stat.label }}</p>
        <h3 class="stat-value">{{ stat.value }}</h3>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  stats: Array // Expecting data from v_active_sessions and v_occupancy_summary
});
</script>

<style scoped>
.stats-ribbon {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: white;
  padding: 20px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  box-shadow: 0 2px 10px rgba(0,0,0,0.05);
}

.stat-icon {
  font-size: 2rem;
  margin-right: 15px;
  background: #f8f9fa;
  padding: 10px;
  border-radius: 8px;
}

.stat-label {
  color: #666;
  font-size: 0.85rem;
  margin: 0;
}

.stat-value {
  margin: 5px 0 0;
  font-size: 1.5rem;
  color: #782435; /* FSU Garnet */
}
</style>