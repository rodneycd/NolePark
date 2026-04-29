<template>
  <div class="modal-overlay">
    <div class="manage-container">
      <div class="manage-header">
        <div class="title-group">
          <span class="back-link" @click="$emit('close')">← Back to Inventory</span>
          <h3>Manage Infrastructure: {{ lotDetails?.name || 'Loading...' }}</h3>
        </div>
        <button class="close-x" @click="$emit('close')">&times;</button>
      </div>

      <div v-if="loading" class="loader">Gathering infrastructure data...</div>

      <div v-else class="manage-body">
        <div class="stats-grid">
          <div class="stat-card">
            <label>Total Capacity</label>
            <div class="val">{{ totalSpots }}</div>
          </div>
          <div class="stat-card">
            <label>Current Occupancy</label>
            <div class="val">{{ occupiedCount }}</div>
          </div>
          <div class="stat-card">
            <label>♿ Handicap</label>
            <div class="val">{{ getSpotCount('handicap') }}</div>
          </div>
          <div class="stat-card">
            <label>🏍️ Motorcycle</label>
            <div class="val">{{ getSpotCount('motorcycle') }}</div>
          </div>
        </div>

        <div class="config-section">
          <h4>Level-by-Level Access Control</h4>
          <p class="subtext">Update permit requirements for specific floors. Changes take effect immediately.</p>
          
          <table class="config-table">
            <thead>
              <tr>
                <th>Level</th>
                <th>Current Permit Type</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="lvl in levels" :key="lvl.level_id">
                <td><strong>Level {{ lvl.level_number }}</strong></td>
                <td>
                  <select v-model="lvl.allowed_permit_type" class="table-select">
                    <option value="Student">Student</option>
                    <option value="Faculty">Faculty</option>
                    <option value="Reserved">Reserved</option>
                    <option value="Overnight">Overnight</option>
                  </select>
                </td>
                <td>
                  <button class="btn-save-mini" @click="updateLevel(lvl)">Update</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="danger-zone">
          <div class="danger-text">
            <h5>Decommission Infrastructure</h5>
            <p>This will permanently remove this lot, all levels, and all spot data. This cannot be undone.</p>
          </div>
          <button class="btn-danger" @click="deleteLot">Delete Lot</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts"> // 1. Crucial: added lang="ts"
import { ref, onMounted, computed, watch } from 'vue';
import adminAPI from '@/api/admin';
// 2. Use 'import type' for interfaces and 'AdminLevelConfig' inside {}
import type { AdminLevelConfig, InfrastructureDetails, SpotBreakdown } from '@/types/index';

const props = defineProps<{
  lotId: number; // 3. Updated to the TS-style props definition
}>();

const emit = defineEmits(['close', 'refresh']);

const loading = ref(true);
// 4. Added explicit type safety to your refs
const levels = ref<AdminLevelConfig[]>([]);
const spotBreakdown = ref<SpotBreakdown[]>([]);
const lotDetails = ref<{ name: string } | null>(null);

watch(() => props.lotId, (newId) => {
  if (newId) fetchDetails();
});

async function fetchDetails() {
  loading.value = true;
  try {
    const data: InfrastructureDetails = await adminAPI.getInfrastructure(props.lotId);
    levels.value = data.levels;
    spotBreakdown.value = data.spots;
    lotDetails.value = {
       name: levels.value[0]?.lot_name || 'Parking Facility' 
    };
  } catch (err) {
    console.error("Infrastructure Load Error:", err);
  } finally {
    loading.value = false;
  }
}

const totalSpots = computed(() => {
  return spotBreakdown.value.reduce((acc, curr) => acc + Number(curr.count), 0);
});

const occupiedCount = computed(() => {
  return spotBreakdown.value
    .filter(s => s.status === 'occupied')
    .reduce((acc, curr) => acc + Number(curr.count), 0);
});

function getSpotCount(type: string) {
  const match = spotBreakdown.value.find(s => s.spot_type === type);
  return match ? match.count : 0;
}

// 5. Now 'lvl: AdminLevelConfig' will work because of lang="ts"
async function updateLevel(lvl: AdminLevelConfig) {
  try {
    await adminAPI.updateLevelPermit(props.lotId, lvl.level_id, lvl.allowed_permit_type);
    alert(`Level ${lvl.level_number} updated to ${lvl.allowed_permit_type}.`);
  } catch (err: any) {
    console.error("Update Error:", err);
    const message = err.response?.data?.message || "An unexpected error occurred.";
    alert(message);
  }
}

async function deleteLot() {
  if (!confirm("Are you sure? This wipes all spot data and active sessions for this lot.")) return;
  
  try {
    await adminAPI.deleteLot(props.lotId);
    emit('refresh');
    emit('close');
  } catch (err: any) {
    console.error("Delete Error:", err);
    const message = err.response?.data?.message || "An unexpected error occurred.";
    alert(message);
  }
}

onMounted(fetchDetails);
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0; left: 0; width: 100%; height: 100%;
  background: rgba(0,0,0,0.7);
  display: flex; justify-content: center; align-items: center;
  z-index: 2000;
}

.manage-container {
  background: #f8f9fa;
  width: 90%; max-width: 800px;
  border-radius: 12px; overflow: hidden;
  box-shadow: 0 20px 50px rgba(0,0,0,0.4);
}

.manage-header {
  background: white; padding: 20px 30px;
  display: flex; justify-content: space-between; align-items: center;
  border-bottom: 1px solid #eee;
}

.back-link {
  font-size: 0.8rem; color: #782435; cursor: pointer;
  font-weight: 700; text-transform: uppercase; margin-bottom: 4px; display: block;
}

.stats-grid {
  display: grid; grid-template-columns: repeat(4, 1fr);
  gap: 15px; padding: 30px; background: white;
}

.stat-card {
  background: #fcfaf9; padding: 15px; border-radius: 8px;
  border: 1px solid #eee; text-align: center;
}

.stat-card label { font-size: 0.65rem; font-weight: 800; color: #888; text-transform: uppercase; }
.stat-card .val { font-size: 1.5rem; font-weight: 700; color: #333; }

.config-section { padding: 0 30px 30px 30px; }
.subtext { font-size: 0.85rem; color: #666; margin-bottom: 20px; }

.config-table {
  width: 100%; border-collapse: collapse; background: white;
  border-radius: 8px; overflow: hidden; border: 1px solid #eee;
}

.config-table th { background: #f8f8f8; padding: 12px; text-align: left; font-size: 0.75rem; }
.config-table td { padding: 12px; border-top: 1px solid #eee; }

.table-select { padding: 6px; border-radius: 4px; border: 1px solid #ddd; width: 150px; }

.btn-save-mini {
  background: #782435; color: white; border: none;
  padding: 6px 12px; border-radius: 4px; cursor: pointer; font-size: 0.8rem;
}

.danger-zone {
  margin: 0 30px 30px 30px; padding: 20px;
  background: #fff5f5; border: 1px solid #feb2b2;
  border-radius: 8px; display: flex; justify-content: space-between; align-items: center;
}

.danger-text h5 { color: #c53030; margin: 0 0 5px 0; }
.danger-text p { font-size: 0.8rem; color: #742a2a; margin: 0; }

.btn-danger {
  background: #c53030; color: white; border: none;
  padding: 10px 20px; border-radius: 6px; font-weight: 700; cursor: pointer;
}

.close-x { background: none; border: none; font-size: 2rem; cursor: pointer; color: #ccc; }
</style>