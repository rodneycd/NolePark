<template>
  <div class="modal-overlay">
    <div class="form-container">
      <h3>Create New Infrastructure</h3>
  
      <div class="form-grid">
        <div class="field">
          <label>Lot Name</label>
          <input v-model="form.name" type="text" placeholder="e.g. Woodward Garage">
        </div>

        <div class="field">
          <label>Spot Prefix</label>
          <input v-model="form.prefix" type="text" placeholder="e.g. WW">
        </div>

        <div class="field full-width">
          <label>Number of Levels</label>
          <input 
            v-model.number="form.level_count" 
            type="number" 
            min="1" 
            @input="syncLevelRows"
            placeholder="Enter total levels"
          >
        </div>
      </div>

      <div class="level-editor" v-if="form.level_configs.length > 0">
        <label class="section-label">Level-by-Level Breakdown</label>
        <div class="table-container">
          <table>
            <thead>
              <tr>
                <th>Lvl</th>
                <th>Permit Type</th>
                <th>Total Spots</th>
                <th>♿ HC</th>
                <th>🏍️ Moto</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(lvl, index) in form.level_configs" :key="index">
                <td>L{{ lvl.level_number }}</td>
                <td>
                  <select v-model="lvl.permit_type">
                    <option value="Student">Student</option>
                    <option value="Faculty">Faculty</option>
                    <option value="Reserved">Reserved</option>
                    <option value="Overnight">Overnight</option>
                  </select>
                </td>
                <td><input type="number" v-model.number="lvl.total_spots" class="table-input"></td>
                <td><input type="number" v-model.number="lvl.hc_count" class="table-input"></td>
                <td><input type="number" v-model.number="lvl.moto_count" class="table-input"></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="form-actions">
        <button class="btn-secondary" @click="$emit('close')">Cancel</button>
        <button class="btn-garnet" @click="submitLot" :disabled="loading || !isFormValid" >
          {{ loading ? 'Initializing...' : 'Initialize Infrastructure' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import apiClient from '@/api';

const emit = defineEmits(['close', 'refresh']);
const loading = ref(false);

const form = ref({
  name: '',
  prefix: '',
  level_count: 1,
  level_configs: [] 
});

const isFormValid = computed(() => {
  if (!form.value.name || !form.value.prefix) return false;
  
  // Check every level to ensure HC + Moto doesn't exceed Total
  return form.value.level_configs.every(lvl => {
    return (lvl.hc_count + lvl.moto_count) <= lvl.total_spots;
  });
});

// Sync logic to add/remove rows based on level_count
function syncLevelRows() {
  const current = form.value.level_configs.length;
  const target = form.value.level_count;

  if (target > current) {
    for (let i = current; i < target; i++) {
      form.value.level_configs.push({
        level_number: i + 1,
        permit_type: 'Student-V',
        total_spots: 50,
        hc_count: 0,
        moto_count: 0
      });
    }
  } else if (target < current) {
    form.value.level_configs.splice(target);
  }
}

// Ensure at least one row exists on load
onMounted(syncLevelRows);

async function submitLot() {
  if (!form.value.name || !form.value.prefix) {
    alert("Please fill in the Lot Name and Prefix.");
    return;
  }

  loading.value = true;
  try {
    // Note: ensure your backend route matches this endpoint
    await apiClient.post('/admin/create-lot-infrastructure', form.value);
    emit('refresh'); 
    emit('close');
  } catch (err) {
    console.error(err);
    alert("Error creating lot: " + (err.response?.data?.error || err.message));
  } finally {
    loading.value = false;
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0,0,0,0.6);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.form-container {
  background: white;
  padding: 2.5rem;
  border-radius: 12px;
  box-shadow: 0 10px 30px rgba(0,0,0,0.3);
  width: 95%;
  max-width: 750px;
}

h3 {
  margin-top: 0;
  margin-bottom: 1.5rem;
  color: #333;
  font-weight: 700;
}

.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.full-width {
  grid-column: span 2;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

label {
  font-size: 0.75rem;
  font-weight: 800;
  color: #666;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

input, select {
  padding: 12px;
  border: 1px solid #ddd;
  border-radius: 8px;
  font-size: 0.95rem;
  background: #fff;
}

input:focus {
  outline: none;
  border-color: #782435;
  box-shadow: 0 0 0 3px rgba(120, 36, 53, 0.1);
}

/* Table Styling */
.level-editor {
  border-top: 1px solid #eee;
  padding-top: 1.5rem;
  margin-bottom: 1.5rem;
}

.section-label {
  display: block;
  margin-bottom: 0.75rem;
  font-size: 0.85rem;
  font-weight: 700;
  color: #782435;
}

.table-container {
  max-height: 280px;
  overflow-y: auto;
  border: 1px solid #eee;
  border-radius: 8px;
}

table {
  width: 100%;
  border-collapse: collapse;
}

th {
  background: #fcfcfc;
  padding: 12px;
  font-size: 0.7rem;
  text-align: left;
  border-bottom: 2px solid #eee;
  color: #888;
}

td {
  padding: 10px;
  border-bottom: 1px solid #f5f5f5;
}

.table-input {
  width: 70px;
  padding: 6px;
  font-size: 0.85rem;
}

.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

.btn-secondary {
  background: white;
  border: 1px solid #ddd;
  padding: 12px 24px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 700;
  color: #666;
}

.btn-garnet {
  background: #782435;
  color: white;
  border: none;
  padding: 12px 24px;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 700;
}

.btn-garnet:hover {
  background: #5d1c29;
}

.btn-garnet:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>