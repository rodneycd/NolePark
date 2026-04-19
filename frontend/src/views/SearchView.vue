<template>
  <div class="search-page">
    <FilterSidebar @filter-change="handleFilterChange" />

    <main class="results-main">
      <header class="results-header">
        <h1>Find Parking</h1>
        <p v-if="!isLoading">{{ lots.length }} Lots Available</p>
      </header>

      <div class="scroll-view">
        <div v-if="isLoading" class="loading-box">Searching...</div>
        
        <template v-else-if="lots.length > 0">
          <LotCard 
            v-for="lot in lots" 
            :key="lot.lot_id" 
            class="clickable-card"
            :name="lot.lot_name"
            :available="lot.user_available"
            :percent="lot.user_pct_full"
            :lotType="lot.lot_type"
            @click="openDrillDown(lot)"
          />
        </template>

        <div v-else class="no-results">
          No lots match your filters.
        </div>
      </div>
    </main>

    <Teleport to="body">
      <div v-if="selectedLot" class="overlay-backdrop" @click.self="closeDrillDown">
        <div class="drill-down-modal">
          <header class="modal-header">
            <div>
              <h2>{{ selectedLot.lot_name }}</h2>
              <p class="modal-subtitle">Level-by-level occupancy</p>
            </div>
            <button class="close-modal-btn" @click="closeDrillDown">✕</button>
          </header>

          <div v-if="isDetailLoading" class="loading-state">
            <div class="spinner"></div>
            <p>Updating live counts...</p>
          </div>
          
          <table v-else class="level-table">
            <thead>
              <tr>
                <th>Level</th>
                <th>Permit</th>
                <th>Available</th>
                <th>Fullness</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="lvl in lotLevels" :key="lvl.level_id">
                <td class="bold">L{{ lvl.level_number }}</td>
                <td><span class="permit-tag">{{ lvl.allowed_permit_type }}</span></td>
                <td>
                  <div class="avail-count">{{ lvl.available }} / {{ lvl.total_spots }}</div>
                  <div class="spot-icons">
                    <span v-if="lvl.avail_handicap > 0" class="spot-pill handicap" title="Handicap">♿ {{ lvl.avail_handicap }}</span>
                    <span v-if="lvl.avail_motorcycle > 0" class="spot-pill motorcycle" title="Motorcycle">🏍️ {{ lvl.avail_motorcycle }}</span>
                  </div>
                </td>
                <td>
                  <div class="mini-progress-container">
                    <div 
                      class="mini-progress-bar" 
                      :style="{ width: lvl.pct_full + '%' }" 
                      :class="getProgressClass(Number(lvl.pct_full))"
                    ></div>
                  </div>
                  <span class="pct-text">{{ lvl.pct_full }}%</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue';
import FilterSidebar from '@/components/FilterSidebar.vue';
import LotCard from '@/components/LotCard.vue';
import lotApi from '@/api/lots';
import type { LotSearchResult, LotSearchParams, LotLevelDetail } from '@/types';

const lots = ref<LotSearchResult[]>([]);
const isLoading = ref(false);

// Drill-down State
const selectedLot = ref<LotSearchResult | null>(null);
const lotLevels = ref<LotLevelDetail[]>([]);
const isDetailLoading = ref(false);

const handleFilterChange = async (filters: LotSearchParams) => {
  isLoading.value = true;
  try {
    lots.value = await lotApi.searchLots(filters);
  } catch (error) {
    console.error("Search failed:", error);
  } finally {
    isLoading.value = false;
  }
};

const openDrillDown = async (lot: LotSearchResult) => {
  console.log("Card clicked for lot:", lot.lot_id);
  selectedLot.value = lot;
  isDetailLoading.value = true;
  try {
    lotLevels.value = await lotApi.getLotLevels(lot.lot_id);
  } catch (error) {
    console.log("Error fetching level details:", error);
  } finally {
    isDetailLoading.value = false;
  }
};

const closeDrillDown = () => {
  selectedLot.value = null;
  lotLevels.value = [];
};

const getProgressClass = (pct: number) => {
  if (pct >= 90) return 'bg-danger';
  if (pct >= 70) return 'bg-warning';
  return 'bg-success';
};

onMounted(() => handleFilterChange({}));
</script>

<style>
/* REMOVED scoped so Teleport works correctly */

.search-page {
  display: flex;
  flex-direction: row; /* Force sidebar and main side-by-side */
  width: 100vw;
  height: 100vh;
  overflow: hidden;
  background-color: var(--bg-light, #f5f5f5);
}

/* Sidebar Fix: Ensure it doesn't squish or push main content down */
.filter-sidebar {
  flex-shrink: 0;
  width: 300px;
  background-color: var(--sidebar-bg, #333);
}

.results-main {
  flex: 1;
  display: flex;
  flex-direction: column;
  padding: 2rem;
  overflow: hidden;
}

.results-header {
  margin-bottom: 2rem;
}

.results-header h1 {
  color: var(--primary-color, #78241c);
}

/* ScrollView Grid */
.scroll-view {
  flex: 1;
  overflow-y: auto;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 1.5rem;
  padding-bottom: 2rem;
  align-content: start;
}

.clickable-card {
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.clickable-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 15px rgba(0,0,0,0.1);
}

/* Modal & Overlay */
.overlay-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background-color: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(4px);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 10000;
}

.drill-down-modal {
  background: var(--card-bg, white);
  padding: 2.5rem;
  border-radius: 16px;
  width: 95%;
  max-width: 650px;
  max-height: 85vh;
  overflow-y: auto;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3);
  color: var(--text-main, #2c3e50);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 2rem;
}

.close-modal-btn {
  background: var(--bg-light, #f8f9fa);
  border: none;
  font-size: 1.2rem;
  width: 35px;
  height: 35px;
  border-radius: 50%;
  cursor: pointer;
}

/* Level Table Styling */
.level-table {
  width: 100%;
  border-collapse: collapse;
}

.level-table th {
  text-align: left;
  font-size: 0.8rem;
  text-transform: uppercase;
  color: var(--text-muted, #95a5a6);
  padding: 10px;
  border-bottom: 2px solid var(--border-color, #f4f7f6);
}

.level-table td {
  padding: 15px 10px;
  border-bottom: 1px solid var(--border-color, #f4f7f6);
}

.permit-tag {
  background: var(--primary-color, #78241c);
  color: white;
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: bold;
}


.spot-icons span {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 32px; 
  padding: 2px 6px;
  background: var(--bg-light);
  border-radius: 4px;
  font-weight: 600;
}

.mini-progress-container {
  width: 100px;
  height: 6px;
  background: var(--bg-light, #ecf0f1);
  border-radius: 3px;
  overflow: hidden;
}

.mini-progress-bar {
  height: 100%;
  transition: width 0.3s ease;
}

/* Status Colors */
.bg-success { background-color: var(--success-color, #27ae60); }
.bg-warning { background-color: var(--warning-color, #f1c40f); }
.bg-danger { background-color: var(--danger-color, #e74c3c); }

.pct-text {
  font-size: 0.75rem;
  color: var(--text-muted, #7f8c8d);
}

.spot-icons {
  display: flex;
  gap: 8px;
  margin-top: 6px;
}

.spot-pill {
  display: inline-flex;
  align-items: center;
  font-size: 0.75rem;
  font-weight: 600;
  padding: 2px 6px;
  border-radius: 4px;
  background-color: var(--bg-light, #f8f9fa);
  border: 1px solid var(--border-color, #e9ecef);
}

.handicap {
  color: #007bff; 
}

.motorcycle {
  color: #6c757d; 
}
</style>