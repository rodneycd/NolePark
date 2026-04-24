<script setup lang="ts">
import type { ParkingSession } from '@/types';

defineProps<{
  session: ParkingSession
}>();

defineEmits(['end']);
</script>

<template>
  <div class="active-session-card">
    <div class="card-header">
      <span class="live-indicator">● LIVE SESSION</span>
      <h2>{{ session.lot_name }}</h2>
    </div>

    <div class="session-details">
      <div class="detail-item">
        <span class="label">Spot Number</span>
        <span class="value">{{ session.spot_number }}</span>
      </div>
      
      <div class="detail-item">
        <span class="label">Vehicle</span>
        <span class="value">{{ session.vehicle_make }} {{ session.vehicle_model }}</span>
        <span class="sub-value">{{ session.vehicle_plate }}</span>
      </div>

      <div class="detail-item">
        <span class="label">Started At</span>
        <span class="value">{{ session.start_time }}</span>
      </div>
    </div>

    <button class="btn-end-session" @click="$emit('end')">
      End Session
    </button>
  </div>
</template>

<style scoped>
.active-session-card {
  background: white;
  width: 100%;
  max-width: 450px;
  padding: 2rem;
  border-radius: 12px;
  border-top: 6px solid var(--primary);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  text-align: center;
}

.live-indicator {
  color: #27ae60;
  font-size: 0.75rem;
  font-weight: 800;
  letter-spacing: 1px;
  display: block;
  margin-bottom: 0.5rem;
}

.card-header h2 {
  color: var(--text-main);
  margin: 0;
}

.session-details {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  margin: 2rem 0;
}

.detail-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  background-color: var(--bg-light);
  padding: 1rem;
  border-radius: 8px;
}

.label {
  font-size: 0.75rem;
  text-transform: uppercase;
  color: #666;
  font-weight: 700;
  margin-bottom: 4px;
}

.value {
  font-size: 1.1rem;
  font-weight: 600;
  color: var(--text-main);
}

.sub-value {
  font-size: 0.85rem;
  color: #666;
}

.btn-end-session {
  width: 100%;
  padding: 14px;
  background-color: transparent;
  color: #e74c3c;
  border: 2px solid #e74c3c;
  border-radius: 8px;
  font-weight: bold;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-end-session:hover {
  background-color: #e74c3c;
  color: white;
}
</style>