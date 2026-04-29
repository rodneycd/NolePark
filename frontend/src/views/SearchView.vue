<template>
  <div class="search-page">
    <FilterSidebar
      @filter-change="handleFilterChange"
      @predict="handlePrediction"
      @mode-change="handleModeChange"
    />

    <main class="results-main">
      <header class="results-header">
        <h1>{{ mode === 'prediction' ? 'Prediction Results' : 'Find Parking' }}</h1>
        <p v-if="!isLoading">
          {{ mode === 'prediction' ? predictionLots.length : liveLots.length }}
          {{ mode === 'prediction' ? 'Recommended Options' : 'Lots Available' }}
        </p>
      </header>

      <div class="scroll-view">
        <div v-if="isLoading" class="loading-box">
          {{ mode === 'prediction' ? 'Predicting...' : 'Searching...' }}
        </div>

        <!-- LIVE MODE -->
        <template v-else-if="mode === 'live' && liveLots.length > 0">
          <LotCard
            v-for="lot in liveLots"
            :key="lot.lot_id"
            class="clickable-card"
            :name="lot.lot_name"
            :available="lot.user_available"
            :percent="lot.user_pct_full"
            :lotType="lot.lot_type"
            @click="openDrillDown(lot)"
          />
        </template>

        <!-- PREDICTION MODE -->
        <template v-else-if="mode === 'prediction' && predictionLots.length > 0">
          <LotCard
            v-for="lot in predictionLots"
            :key="`${lot.lot_id}-${lot.level_id}`"
            class="clickable-card"
            :name="lot.lot_name"
            :available="lot.predicted_available"
            :percent="lot.predicted_percent_full"
            :lotType="lot.lot_type"
            :isPrediction="true"
            :levelNumber="lot.level_number"
            :congestionLabel="lot.congestion_label"
            :rank="lot.recommendation_rank"
          />
        </template>

        <!-- NO RESULTS -->
        <div v-else class="no-results">
          {{
            mode === 'prediction'
              ? 'No prediction results found.'
              : 'No lots match your filters.'
          }}
        </div>
      </div>
    </main>

    <!-- DRILL DOWN MODAL (LIVE MODE ONLY) -->
    <Teleport to="body">
      <div v-if="selectedLot && mode === 'live'" class="overlay-backdrop" @click.self="closeDrillDown">
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
                    <span v-if="lvl.avail_handicap > 0" class="spot-pill handicap">♿ {{ lvl.avail_handicap }}</span>
                    <span v-if="lvl.avail_motorcycle > 0" class="spot-pill motorcycle">🏍️ {{ lvl.avail_motorcycle }}</span>
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
import type {
  LotSearchResult,
  LotSearchParams,
  LotLevelDetail,
  PredictionResult,
  PredictionParams
} from '@/types';

// MODE
const mode = ref<'live' | 'prediction'>('live');

// DATA
const liveLots = ref<LotSearchResult[]>([]);
const predictionLots = ref<PredictionResult[]>([]);
const isLoading = ref(false);

// DRILL DOWN STATE
const selectedLot = ref<LotSearchResult | null>(null);
const lotLevels = ref<LotLevelDetail[]>([]);
const isDetailLoading = ref(false);

// MODE CHANGE
const handleModeChange = async (newMode: 'live' | 'prediction') => {
  mode.value = newMode;
  selectedLot.value = null;
  lotLevels.value = [];

  if (newMode === 'live') {
    await handleFilterChange({});
  } else {
    predictionLots.value = [];
  }
};

// LIVE SEARCH
const handleFilterChange = async (filters: LotSearchParams) => {
  if (mode.value !== 'live') return;

  isLoading.value = true;
  try {
    liveLots.value = await lotApi.searchLots(filters);
  } catch (error) {
    console.error("Search failed:", error);
  } finally {
    isLoading.value = false;
  }
};

// PREDICTION
const handlePrediction = async (params: PredictionParams) => {
  isLoading.value = true;
  try {
    predictionLots.value = await lotApi.predictLots(params);
  } catch (error) {
    console.error("Prediction failed:", error);
    predictionLots.value = [];
  } finally {
    isLoading.value = false;
  }
};

// DRILL DOWN
const openDrillDown = async (lot: LotSearchResult) => {
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

// PROGRESS BAR COLOR
const getProgressClass = (pct: number) => {
  if (pct >= 90) return 'bg-danger';
  if (pct >= 70) return 'bg-warning';
  return 'bg-success';
};

// INITIAL LOAD
onMounted(() => handleFilterChange({}));
</script>

<style>
.search-page {
  display: flex;
  width: 100vw;
  height: 100vh;
  overflow: hidden;
  background-color: var(--bg-light, #f5f5f5);
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

.scroll-view {
  flex: 1;
  overflow-y: auto;
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
  gap: 1.5rem;
}

.clickable-card {
  cursor: pointer;
  transition: transform 0.2s ease;
}

.clickable-card:hover {
  transform: translateY(-5px);
}

.overlay-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0,0,0,0.6);
  display: flex;
  justify-content: center;
  align-items: center;
}

.drill-down-modal {
  background: white;
  padding: 2rem;
  border-radius: 16px;
  width: 600px;
}
</style>