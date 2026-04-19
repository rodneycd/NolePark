<script setup lang="ts">
import { reactive, watch } from 'vue';
import type { LotSearchParams } from '@/types';

// Using the most compatible Interface-based emit definition
interface SidebarEmits {
  (e: 'filter-change', filters: LotSearchParams): void;
}

const emit = defineEmits<SidebarEmits>();

const filters = reactive<LotSearchParams>({
  name: '',
  lot_type: '',      
  spot_type: '',     
  occupancy_percent: 100,
  available: 0
});

// Watch for changes and emit the updated filter object
watch(filters, (newFilters) => {
  // Pass a plain object copy to avoid reactive side-effects in parent
  emit('filter-change', { ...newFilters });
}, { deep: true });

const resetFilters = () => {
  filters.name = '';
  filters.lot_type = '';
  filters.spot_type = '';
  filters.occupancy_percent = 100;
  filters.available = 0;
};
</script>

<template>
  <aside class="filter-sidebar">
    <div class="sidebar-header">
      <h2>Filters</h2>
      <button @click="resetFilters" class="reset-btn">Reset</button>
    </div>

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
input[type="text"], select {
  padding: 0.6rem;
  border-radius: 4px;
  border: none;
}
label { font-size: 0.8rem; font-weight: bold; color: #aaa; }
</style>