<template>
  <div class="lot-card">
    <div v-if="isPrediction && rank === 1" class="best-badge">Best Option</div>

    <div class="icon-wrapper">
      <img
        :src="lotType === 'garage' ? garageIcon : surfaceIcon"
        :alt="lotType"
        class="type-icon"
      />
    </div>

    <div class="card-details">
      <h3 class="lot-name">{{ name }}</h3>

      <p v-if="isPrediction && levelNumber !== undefined" class="level-text">
        Level {{ levelNumber }}
      </p>

      <div class="spots-info">
        <span class="count">{{ available }}</span>
        <span class="label">
          {{ isPrediction ? 'Predicted Spots Available' : 'Spots Available' }}
        </span>
      </div>

      <p v-if="isPrediction && congestionLabel" class="prediction-note">
        {{ congestionLabel }}
      </p>
    </div>

    <div class="occupancy-container">
      <div class="progress-bar">
        <div
          class="progress-fill"
          :style="{ width: percent + '%', backgroundColor: getStatusColor }"
        ></div>
      </div>
      <span class="percent-text">
        {{ isPrediction ? 'Predicted ' : '' }}{{ percent }}% Full
      </span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import garageIcon from '@/assets/icons/garage-icon.png';
import surfaceIcon from '@/assets/icons/surface-icon.png';

const props = defineProps<{
  name: string;
  available: number;
  percent: number;
  lotType: 'garage' | 'surface';
  isPrediction?: boolean;
  levelNumber?: number;
  congestionLabel?: string;
  rank?: number;
}>();

const getStatusColor = computed(() => {
  if (props.percent > 85) return 'var(--fsu-garnet)';
  if (props.percent > 60) return 'var(--fsu-gold)';
  return '#2E7D32';
});
</script>

<style scoped>
.lot-card {
  position: relative;
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
}

.best-badge {
  position: absolute;
  top: 12px;
  right: 12px;
  background: var(--fsu-gold);
  color: var(--fsu-black);
  padding: 4px 10px;
  border-radius: 999px;
  font-size: 0.75rem;
  font-weight: bold;
}

.icon-wrapper {
  background: var(--bg-light);
  padding: 12px;
  border-radius: 10px;
  margin-right: 15px;
}

.type-icon {
  width: 64px;
  height: 64px;
}

.card-details {
  flex-grow: 1;
}

.lot-name {
  color: var(--fsu-black);
  margin: 0.5rem 0;
  font-size: 1.2rem;
}

.level-text {
  margin: 0 0 0.5rem 0;
  color: #666;
  font-weight: 600;
}

.spots-info {
  margin-bottom: 0.75rem;
}

.count {
  font-size: 1.5rem;
  font-weight: bold;
  display: block;
  color: var(--primary);
}

.label {
  font-size: 0.8rem;
  color: #666;
  text-transform: uppercase;
}

.prediction-note {
  font-size: 0.9rem;
  font-weight: 600;
  color: #444;
  margin-bottom: 1rem;
}

.occupancy-container {
  width: 100%;
}

.progress-bar {
  width: 100%;
  height: 8px;
  background-color: #eee;
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 0.5rem;
}

.progress-fill {
  height: 100%;
  transition: width 0.5s ease;
}

.percent-text {
  font-size: 0.85rem;
  font-weight: 600;
}
</style>