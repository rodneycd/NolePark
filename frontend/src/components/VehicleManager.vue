<template>
  <section class="settings-card vehicle-manager">
    <div class="header-row">
      <h2>Registered Vehicles</h2>
      <span class="count-badge" :class="{ 'limit-reached': isAtLimit }">
        {{ vehicles.length }} / 5
      </span>
    </div>

    <div class="vehicle-list">
      <div v-for="car in vehicles" :key="car.license_plate" class="vehicle-item">
        <div class="plate-section">
          <span class="plate-badge">{{ car.license_plate }}</span>
        </div>
        <div class="info-section">
          <p class="car-title">{{ car.year }} {{ car.make }} {{ car.model }}</p>
          <p class="car-sub">{{ car.color }}</p>
        </div>
        <button @click="removeVehicle(car.license_plate)" class="delete-btn">
          &times;
        </button>
      </div>

      <div v-if="vehicles.length === 0" class="empty-state">
        <p>No vehicles registered to this account.</p>
      </div>
    </div>

    <div v-if="!isAtLimit" class="add-container">
      <button v-if="!isAdding" @click="isAdding = true" class="btn-outline">
        + Add Vehicle
      </button>

      <form v-else @submit.prevent="handleRegister" class="add-form">
        <div class="grid-inputs">
          <input v-model="form.license_plate" placeholder="License Plate" required class="full-width" />
          <input v-model.number="form.year" type="number" placeholder="Year" required/>
          <input v-model="form.make" placeholder="Make" required/>
          <input v-model="form.model" placeholder="Model" required/>
          <input v-model="form.color" placeholder="Color" required/>
        </div>
        <div class="actions">
          <button type="button" @click="isAdding = false" class="btn-text">Cancel</button>
          <button type="submit" class="btn-primary" :disabled="submitting">
            {{ submitting ? 'Adding...' : 'Register Vehicle' }}
          </button>
        </div>
      </form>
    </div>
  </section>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue';
import userApi from '@/api/users';
import type { Vehicle } from '@/types';

const props = defineProps<{ userId: number }>();

const vehicles = ref<Vehicle[]>([]);
const isAdding = ref(false);
const submitting = ref(false);
const isAtLimit = computed(() => vehicles.value.length >= 5);

const form = ref<Vehicle>({
  license_plate: '',
  make: '',
  model: '',
  color: '',
  year: 2026,
  owner_id: props.userId
});

const loadVehicles = async () => {
  try {
    // Ensuring we reset to empty array on failure prevents ghost rows
    const data = await userApi.getVehicles(props.userId);
    vehicles.value = Array.isArray(data) ? data : [];
  } catch (err) {
    console.error("Vehicle load error:", err);
    vehicles.value = [];
  }
};

const handleRegister = async () => {
  submitting.value = true;
  try {
    const res = await userApi.addVehicle({ ...form.value, owner_id: props.userId });
    if (res.success) {
      await loadVehicles();
      isAdding.value = false;
      // Reset form to defaults
      form.value = { license_plate: '', make: '', model: '', color: '', year: 2026, owner_id: props.userId };
    }
  } catch (err) {
    console.error("Registration failed");
  } finally {
    submitting.value = false;
  }
};

const removeVehicle = async (plate: string) => {
  if (!confirm('Remove this vehicle?')) return;
  try {
    const res = await userApi.deleteVehicle(plate);
    await loadVehicles();
  } catch (err: any) {
    const errorMsg = err.response?.data.message || "An unexpected error occurred.";
    console.error("Delete failed");
    alert(errorMsg);
  }
};

onMounted(loadVehicles);
</script>

<style scoped>
/* Container & Header Alignment */
.vehicle-manager {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.header-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.count-badge {
  font-weight: 600;
  color: #666;
  font-size: 0.9rem;
}

.limit-reached {
  color: var(--primary);
}

/* Registered Vehicle List Styling */
.vehicle-list {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.vehicle-item {
  display: flex;
  align-items: center;
  padding: 1rem;
  background: var(--bg-light, #f9f9f9); 
  border-radius: 10px;
  border: 1px solid #e0e0e0;
}

.plate-badge {
  background: #333;
  color: #fff;
  padding: 6px 12px;
  border-radius: 4px;
  font-family: 'Monaco', 'Courier New', monospace;
  font-weight: 700;
  font-size: 1rem;
  letter-spacing: 1px;
  margin-right: 1.25rem;
  min-width: 85px;
  text-align: center;
}

.info-section {
  flex-grow: 1;
}

.car-title {
  font-weight: 700;
  color: var(--text-main, #2c3e50);
  margin: 0;
  font-size: 0.95rem;
}

.car-sub {
  color: #7f8c8d;
  font-size: 0.8rem;
  margin: 2px 0 0 0;
  text-transform: capitalize;
}


.delete-btn {
  background: #eee;
  border: none;
  color: #888;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  transition: all 0.2s ease;
}

.delete-btn:hover {
  background: var(--primary);
  color: white;
}

/* Registration Form (Dashed Box) */
.add-form {
  background: #fff;
  padding: 1.5rem;
  border-radius: 12px;
  border: 1px dashed #ccc;
  margin-top: 1rem;
  box-sizing: border-box; 
}

.grid-inputs {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.25rem;
  margin-bottom: 1.5rem;
  width: 100%;
}

.full-width {
  grid-column: span 2;
}

input {
  box-sizing: border-box; 
  width: 100%;
  padding: 0.85rem;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 0.95rem;
  margin: 0;
  background-color: white;
}

input:focus {
  outline: none;
  border-color: var(--primary);
  box-shadow: 0 0 0 2px rgba(120, 47, 64, 0.1);
}

/* Form Action Buttons */
.actions {
  display: flex;
  justify-content: flex-end;
  align-items: center;
  gap: 1.5rem;
}

.btn-primary {
  background-color: var(--primary);
  color: white;
  border: none;
  padding: 0.8rem 2rem;
  border-radius: 8px;
  font-weight: bold;
  cursor: pointer;
  min-width: 160px;
}

.btn-text {
  background: transparent;
  border: none;
  color: #666;
  font-weight: 600;
  cursor: pointer;
}

.btn-outline {
  width: 100%;
  padding: 0.85rem;
  border: 2px dashed #ccc;
  background: transparent;
  color: #666;
  font-weight: 600;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-outline:hover {
  border-color: var(--primary);
  color: var(--primary);
  background: var(--bg-light);
}

.empty-state {
  text-align: center;
  padding: 2rem;
  color: #999;
  font-style: italic;
}
</style>