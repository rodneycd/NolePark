<script setup lang="ts">
import { ref, watch, onMounted } from 'vue';
import lotApi from '@/api/lots';
import sessionApi from '@/api/sessions';
import userApi from '@/api/users'
import type { Vehicle, StartSessionPayload } from '@/types';

const props = defineProps<{
  userId: number
}>();
const emit = defineEmits(['cancel', 'started']);

const vehicles = ref<Vehicle[]>([]);
const lotSearch = ref('');
const suggestions = ref<{lot_id: number, lot_name: string}[]>([]);
const isSelecting = ref(false);


const form = ref<StartSessionPayload>({
  license_plate: '',
  lot_id: 0,
  spot_number: ''
});

onMounted(async () => {
    loadVehicles()
    console.log(props.userId)
});

watch(lotSearch, async (query) => {
  if (isSelecting.value) {
    isSelecting.value = false; // Reset for the next time the user types
    return;
  }
  if (query.length < 2) {
    suggestions.value = [];
    return;
  }
  suggestions.value = await lotApi.suggestLots(query);
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

const selectLot = (lot: {lot_id: number, lot_name: string}) => {
  isSelecting.value = true;
  form.value.lot_id = lot.lot_id;
  lotSearch.value = lot.lot_name;
  suggestions.value = [];
};

const submitSession = async () => {
  if (!form.value.license_plate || !form.value.lot_id || !form.value.spot_number) {
    alert("Please fill in all fields.");
    return;
  }

  try {
    await sessionApi.startSession(props.userId, form.value);
    emit('started');
  } catch (err: any) {
    alert(err.response?.data?.error || "Could not start session");
  }
};
</script>

<template>
  <div class="form-card">
    <div class="form-content">
      <select v-model="form.license_plate" class="theme-input">
        <option value="" disabled>Select Vehicle</option>
        <option v-for="v in vehicles" :key="v.license_plate" :value="v.license_plate">
          {{ v.make }} {{ v.model }} ({{ v.license_plate }})
        </option>
      </select>

      <div class="autocomplete">
        <input 
          v-model="lotSearch"
          placeholder="Search Lot Name" 
          class="theme-input"
        />
        <ul v-if="suggestions.length" class="suggestions-dropdown">
          <li v-for="lot in suggestions" :key="lot.lot_id" @click="selectLot(lot)">
            {{ lot.lot_name }}
          </li>
        </ul>
      </div>

      <input 
        v-model="form.spot_number" 
        type="text" 
        placeholder="Spot Number" 
        class="theme-input"
      />

      <button class="btn-primary start-btn" @click="submitSession">Start Session</button>
      <button class="btn-cancel" @click="$emit('cancel')">Cancel</button>
    </div>
  </div>
</template>

<style scoped>
/* Styles remain identical to previous theme-consistent blocks */
.form-card {
  background: white;
  padding: 40px; /* More generous padding like your mockup */
  border-radius: 20px;
  border-top: 6px solid var(--accent);
  width: 100%;
  max-width: 420px;
  box-shadow: 0 15px 35px rgba(0, 0, 0, 0.05); /* Softer shadow */
  display: flex;
  flex-direction: column;
  gap: 20px; /* Even spacing between all elements */
}
.form-content { display: flex; flex-direction: column; gap: 1.2rem; }
.theme-input {
  width: 100%;
  padding: 16px;
  border: 1.5px solid #e0e0e0;
  border-radius: 12px;
  font-size: 16px;
  transition: border-color 0.2s;
  box-sizing: border-box; /* Prevents width overflow */
  color: var(--text-main);
}
.theme-input:focus { outline: none; border-color: var(--primary); }
.autocomplete { position: relative; }
.suggestions-dropdown {
  position: absolute;
  top: 100%; left: 0; right: 0;
  background: white; border: 1px solid #ccc;
  z-index: 10; list-style: none; padding: 0; margin: 0;
}
.suggestions-dropdown li { padding: 10px 14px; cursor: pointer; }
.suggestions-dropdown li:hover { background-color: var(--bg-light); }
.btn-primary { width: 100%; font-weight: bold;}
.btn-cancel { background: none; border: none; color: #666; text-decoration: underline; cursor: pointer; padding: 10px; }
</style>