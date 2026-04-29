<script setup lang="ts">
import { reactive, watch, ref } from 'vue';
import type { LotSearchParams, PredictionParams } from '@/types';

// Using the most compatible Interface-based emit definition
interface SidebarEmits {
  (e: 'filter-change', filters: LotSearchParams): void;
  (e: 'predict', payload: PredictionParams): void;
  (e: 'mode-change', mode: 'live' | 'prediction'): void;
}

const emit = defineEmits<SidebarEmits>();
const mode = ref<'live' | 'prediction'>('live');

const filters = reactive<LotSearchParams>({
  name: '',
  lot_type: '',      
  spot_type: '',     
  occupancy_percent: 100,
  available: 0
});

const prediction = reactive<PredictionParams>({
  permit_type: 'Student',
  day_of_week: 2,
  arrival_time: '10:30:00'
})

// Watch for changes and emit the updated filter object
watch(filters, (newFilters) => {
  if (mode.value == 'live'){
  // Pass a plain object copy to avoid reactive side-effects in parent
  emit('filter-change', { ...newFilters });
  }
}, { deep: true });

watch(mode, (newMode) => {
  emit('mode-change', newMode);
  if (newMode === 'live') {
    emit('filter-change', { ...filters });
  }
});

const resetFilters = () => {
  filters.name = '';
  filters.lot_type = '';
  filters.spot_type = '';
  filters.occupancy_percent = 100;
  filters.available = 0;
};

const runPrediction = () => {
  emit('predict', { ...prediction });
};
</script>

<template>
  <aside class="filter-sidebar">
    <div class="sidebar-header">
      <h2>Search</h2>
      <button v-if="mode === 'live'" @click="resetFilters" class="reset-btn">Reset</button>
    </div>

    <div class="filter-group">
      <label>Mode</label>
      <select v-model="mode">
        <option value="live">Live</option>
        <option value="prediction">Prediction</option>
      </select>
    </div>

    <template v-if="mode === 'live'">
      <div class="filter-group">
        <label>Lot Name</label>
        <input v-model="filters.name" type="text" placeholder="Search lots..." />
      </div>

      <div class="filter-group">
        <label>Lot Type</label>
        <select v-model="filters.lot_type">
          <option value="">Any</option>
          <option value="garage">Garage</option>
          <option value="surface">Surface Lot</option>
        </select>
      </div>

      <div class="filter-group">
        <label>Spot Type</label>
        <select v-model="filters.spot_type">
          <option value="">Any</option>
          <option value="standard">Standard</option>
          <option value="handicap">Handicap</option>
          <option value="motorcycle">Motorcycle</option>
        </select>
      </div>

      <div class="filter-group">
        <label>Max Occupancy: {{ filters.occupancy_percent }}%</label>
        <input type="range" v-model.number="filters.occupancy_percent" min="0" max="100" />
      </div>

      <div class="filter-group">
        <label>Min. Available: {{ filters.available }}</label>
        <input type="range" v-model.number="filters.available" min="0" max="500" />
      </div>
    </template>

    <template v-else>
      <div class="prediction-box">
        <h3>Prediction Mode</h3>

        <div class="filter-group">
          <label>Permit Type</label>
          <select v-model="prediction.permit_type">
            <option value="Student">Student</option>
            <option value="Faculty">Faculty</option>
            <option value="Reserved">Reserved</option>
            <option value="Overnight">Overnight</option>
          </select>
        </div>

        <div class="filter-group">
          <label>Day Type</label>
          <select v-model.number="prediction.day_of_week">
            <option value="1">Monday</option>
            <option value="2">Tuesday</option>
            <option value="3">Wednesday</option>
            <option value="4">Thursday</option>
            <option value="5">Friday</option>
            <option value="6">Saturday</option>
            <option value="0">Sunday</option>
          </select>
        </div>

        <div class="filter-group">
          <label>Arrival Time</label>
          <input v-model="prediction.arrival_time" type="time" />
        </div>

        <button class="predict-btn" @click="runPrediction">
          Predict Best Parking
        </button>
      </div>
    </template>
  </aside>
</template>

<style scoped>
.filter-sidebar {
  width: 300px;
  background-color: #333;
  color: white;
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
  height: 100%;
}
.sidebar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.filter-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}
.reset-btn {
  background: transparent;
  border: 1px solid #666;
  color: #ccc;
  cursor: pointer;
  font-size: 0.8rem;
  padding: 2px 8px;
}
input[type="text"], input[type="time"], select {
  padding: 0.6rem;
  border-radius: 4px;
  border: none;
}
label {
  font-size: 0.8rem;
  font-weight: bold;
  color: #aaa;
}
.prediction-box {
  border-top: 1px solid #555;
  padding-top: 1rem;
}
.prediction-box h3 {
  margin: 0 0 1rem 0;
  color: white;
}
.predict-btn {
  width: 100%;
  padding: 0.8rem;
  border: none;
  border-radius: 8px;
  background: var(--primary);
  color: white;
  font-weight: bold;
  cursor: pointer;
}
.predict-btn:hover {
  background: #5e2432;
}
</style>