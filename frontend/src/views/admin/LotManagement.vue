<script setup>
import { ref, onMounted } from 'vue';
import AdminStats from '@/components/AdminStats.vue';
import AddLotModal from '@/components/AddLotModal.vue';
import ManageLotModal from '@/components/ManageLotModal.vue'; // New component
import apiClient from '@/api';

const showAddModal = ref(false); 
const showManageModal = ref(false);
const selectedLotId = ref(null);
const lots = ref([]);
const dashboardStats = ref([]);

async function fetchInventory() {
  try {
    const invRes = await apiClient.get('/admin/inventory');
    lots.value = invRes.data;
    const statsRes = await apiClient.get('/admin/dashboard-stats');
    dashboardStats.value = statsRes.data;
  } catch (err) {
    console.error("Fetch error:", err);
  }
}

// Opens the command hub for a specific lot
function openManage(lotId) {
  console.log("Open manage for lot ID: ", lotId)
  selectedLotId.value = lotId;
  showManageModal.value = true;
}

onMounted(fetchInventory);
</script>

<template>
  <div class="admin-dashboard">
    <AdminStats :stats="dashboardStats" />

    <div class="lot-management">
      <div class="action-header">
        <h2>Infrastructure Inventory</h2>
        <button class="btn-garnet" @click="showAddModal = true">+ Add New Lot</button>
      </div>

      <table class="nole-table">
        <thead>
          <tr>
            <th>Lot / Garage Name</th>
            <th>Type</th>
            <th>Structure</th>
            <th>Occupancy</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="lot in lots" :key="lot.lot_id">
            <td class="name-cell">
              <span class="type-icon">{{ lot.levels > 1 ? '🏢' : '🅿️' }}</span>
              <strong>{{ lot.name }}</strong>
            </td>
            <td>
              <span :class="['badge', (lot.levels > 1 ? 'garage' : 'surface')]">
                {{ lot.levels > 1 ? 'Garage' : 'Surface' }}
              </span>
            </td>
            <td class="text-secondary">
              {{ lot.levels }} Levels | {{ lot.total_spots }} Spots
            </td>
            <td>
              <div class="occupancy-wrapper">
                <div class="mini-bar">
                  <div class="fill" :style="{ width: (lot.occupied / lot.total_spots * 100) + '%' }"></div>
                </div>
                <span class="count">{{ lot.occupied }}/{{ lot.total_spots }}</span>
              </div>
            </td>
            <td>
              <button class="btn-text" @click="openManage(lot.lot_id)">Manage Infrastructure</button>
            </td>
          </tr>
        </tbody>
      </table>

      <AddLotModal v-if="showAddModal" @close="showAddModal = false" @refresh="fetchInventory" />
      
      <ManageLotModal 
        v-if="showManageModal" 
        :lotId="selectedLotId" 
        @close="showManageModal = false" 
        @refresh="fetchInventory" 
      />
    </div>
  </div>
</template>
<style scoped>
.lot-management {
  background: white;
  padding: 24px;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0,0,0,0.05);
  margin-top: 20px;
}

.action-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.name-cell {
  display: flex;
  align-items: center;
  gap: 12px;
}

.type-icon {
  font-size: 1.2rem;
}

.badge {
  padding: 4px 10px;
  border-radius: 4px;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
}
.badge.garage { background: #e3f2fd; color: #1976d2; }
.badge.surface { background: #e8f5e9; color: #388e3c; }

.mini-bar {
  width: 80px;
  height: 6px;
  background: #eee;
  border-radius: 3px;
  overflow: hidden;
  display: inline-block;
  margin-right: 8px;
}

.fill {
  height: 100%;
  background: #782435;
}

.btn-garnet {
  background: #782435;
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 600;
}

.nole-table {
  width: 100%;
  border-collapse: collapse;
}

.nole-table th {
  text-align: left;
  padding: 12px;
  color: #666;
  font-size: 0.85rem;
  border-bottom: 2px solid #eee;
}

.nole-table td {
  padding: 16px 12px;
  border-bottom: 1px solid #eee;
}

.nole-table tr:hover {
  background-color: #fcfaf9;
}

.btn-text {
  background: transparent;
  border: 1px solid #782435;
  color: #782435;
  padding: 6px 12px;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.85rem;
}

.btn-text:hover {
  background: #782435;
  color: white;
}
</style>