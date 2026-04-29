<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import adminAPI from '@/api/admin';
import type { AdminActiveSession } from '@/types';

// --- State Management ---
const sessions = ref<AdminActiveSession[]>([]);
const loading = ref(true);

// Modal UI State
const isEndSessionModalOpen = ref(false);
const modalSearchQuery = ref('');
const searchQuery = ref('');

// --- Initialization ---
async function fetchInitialData() {
  loading.value = true;
  try {
    const sessionData = await adminAPI.getActiveSessions();
    sessions.value = sessionData;
  } catch (err) {
    console.error("Initialization Error:", err);
  } finally {
    loading.value = false;
  }
}

// --- Computed Logic ---

// 1. Main Monitor Filter (Updated to match your SQL View names)
const filteredSessions = computed(() => {
  const query = searchQuery.value.toLowerCase();
  return sessions.value.filter(s => 
    s.owner_name?.toLowerCase().includes(query) ||
    s.license_plate?.toLowerCase().includes(query) ||
    s.lot_name?.toLowerCase().includes(query) ||
    s.spot_number?.toString().includes(query)
  );
});

// 2. Modal Search Results
const modalSearchResults = computed(() => {
  const query = modalSearchQuery.value.toLowerCase();
  if (query.length < 2) return [];
  return sessions.value.filter(s => 
    s.owner_name?.toLowerCase().includes(query) ||
    s.license_plate?.toLowerCase().includes(query) ||
    s.spot_number?.toString().includes(query)
  );
});

// --- Actions ---

const endIndividualSession = async (sessionId: number) => {
  if (!confirm("Are you sure you want to end this user's session?")) return;
  try {
    await adminAPI.closeIndividualSession(sessionId);
    await fetchInitialData();
    modalSearchQuery.value = ''; 
  } catch (err) {
    alert("Failed to end session.");
  }
};

const closeModal = () => {
  isEndSessionModalOpen.value = false;
  modalSearchQuery.value = '';
};

const getPermitClass = (type: string | null | undefined) => {
  if (!type) return 'standard';
  const t = type.toLowerCase();
  if (t.includes('faculty')) return 'faculty';
  if (t.includes('student')) return 'student';
  return 'standard';
};

onMounted(fetchInitialData);
</script>

<template>
  <div class="monitor-layout">
    <div class="monitor-header">
      <div class="title-group">
        <h2>Live Session Monitor</h2>
        <div class="live-status">
          <span class="pulse-dot"></span>LIVE DATA
          <button @click="isEndSessionModalOpen = true" class="action-trigger">
            🛑 End Session
          </button>
        </div>
      </div>
    
      <div class="search-wrapper">
        <span class="search-icon">🔍</span>
        <input 
          v-model="searchQuery" 
          type="text" 
          placeholder="Search by name, plate, or spot..."
        />
      </div>
    </div>

    <!-- End Session Modal -->
    <div v-if="isEndSessionModalOpen" class="modal-overlay" @click.self="closeModal">
      <div class="end-session-modal">
        <header class="modal-header">
          <h3>End Session Control</h3>
          <button @click="closeModal" class="close-btn">✕</button>
        </header>

        <!-- Top Half: Manual Individual Close -->
        <section class="individual-section">
          <label>Find & Close Individual User</label>
          <input 
            v-model="modalSearchQuery" 
            placeholder="Type plate, name, or spot..." 
            class="modal-input"
          />
          <div v-if="modalSearchResults.length" class="modal-results">
            <div v-for="res in modalSearchResults" :key="res.session_id" class="result-row">
              <div class="res-info">
                <strong>{{ res.license_plate }}</strong> — {{ res.owner_name }}
                <br/>
                <small>{{ res.lot_name }} | Spot: {{ res.spot_number }}</small>
              </div>
              <button @click="endIndividualSession(res.session_id)" class="mini-end-btn">End</button>
            </div>
          </div>
          <div v-else-if="modalSearchQuery.length >= 2" class="no-results-msg">
            No active session matches.
          </div>
        </section>
      </div>
    </div> 

    <!-- Loading State -->
    <div v-if="loading" class="loader-container">
      <div class="loader">Scanning Lots...</div>
    </div>

    <!-- Main Grid -->
    <div v-else>
      <div class="session-grid">
        <div v-for="session in filteredSessions" :key="session.session_id" class="session-card">
          <div :class="['accent-bar', getPermitClass(session.permit_type)]"></div>
          
          <div class="card-main">
            <div class="header-row">
              <div class="user-meta">
                <span class="name">{{ session.owner_name }}</span>
                <span class="fsuid">fsuid: {{ session.fsuid || 'N/A' }}</span>
              </div>
              <span :class="['permit-tag', getPermitClass(session.permit_type)]">
                {{ session.permit_type }}
              </span>
            </div>

            <!-- Vehicle Info: Matches Backend View Property Names -->
            <div class="vehicle-strip">
              <span class="v-info">🚗 {{ session.color }} {{ session.make }} {{ session.model }}</span>
              <span class="plate-badge">{{ session.license_plate }}</span>
            </div>

            <div class="location-box">
              <div class="loc-path">
                📍 {{ session.lot_name }} <br/>
                <small>Level {{ session.level_number }}</small>
              </div>
              <div class="spot-id">Spot {{ session.spot_number }}</div>
            </div>

            <div class="card-footer">
               <span class="timestamp">Started: {{ session.start_time_fmt }}</span>
               <span class="duration-badge">🕒 {{ session.duration || 'Live' }}</span>
            </div>
          </div>
        </div>
      </div>
      
      <div v-if="filteredSessions.length === 0" class="empty-state">
        <p>No active sessions found matching your search.</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* Layout and Header Styles */
.monitor-layout { padding: 20px; width: 100%; max-width: 100%; box-sizing: border-box; }
.monitor-header {
  display: flex; justify-content: space-between; align-items: center;
  background: white; padding: 1.5rem; border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.05); margin-bottom: 2rem;
  width: 100%; box-sizing: border-box; min-width: 0;
}

.search-wrapper { position: relative; width: 350px; flex-shrink: 0; }
.search-wrapper input {
  width: 100%; padding: 10px 15px 10px 40px; border: 1px solid #ddd;
  border-radius: 25px; background-color: #fff; box-sizing: border-box;
}
.search-wrapper input:focus { border-color: #782435; outline: none; }
.search-icon { position: absolute; left: 12px; top: 50%; transform: translateY(-50%); }

.title-group h2 { margin: 0; font-weight: 700; color: #333; }
.live-status { display: flex; align-items: center; gap: 8px; font-size: 0.75rem; font-weight: 800; color: #d32f2f; margin-top: 4px; }
.pulse-dot { width: 8px; height: 8px; background: #d32f2f; border-radius: 50%; animation: pulse 1.5s infinite; }

/* Session Grid and Cards */
.session-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(400px, 1fr)); gap: 20px; }
.session-card { background: white; border-radius: 12px; display: flex; overflow: hidden; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid #efefef; transition: transform 0.2s; }
.session-card:hover { transform: translateY(-3px); }
.accent-bar { width: 8px; flex-shrink: 0; }
.accent-bar.student { background: #782435; }
.accent-bar.faculty { background: #ceb888; }
.card-main { padding: 1.25rem; flex-grow: 1; display: flex; flex-direction: column; gap: 12px; }

.header-row { display: flex; justify-content: space-between; align-items: flex-start; }
.user-meta .name { display: block; font-weight: 700; font-size: 1.1rem; }
.user-meta .fsuid { font-size: 0.8rem; color: #777; }
.permit-tag { font-size: 0.7rem; padding: 4px 8px; border-radius: 4px; font-weight: 800; }
.permit-tag.student { background: #f8e8ea; color: #782435; }
.permit-tag.faculty { background: #fdf8e6; color: #8a733e; }

.vehicle-strip { background: #f8f9fa; padding: 10px; border-radius: 8px; display: flex; justify-content: space-between; align-items: center; }
.plate-badge { background: #222; color: white; padding: 3px 8px; border-radius: 4px; font-family: 'Courier New', monospace; font-weight: 900; font-size: 0.9rem; }
.location-box { display: flex; justify-content: space-between; align-items: center; }
.loc-path { font-size: 0.9rem; line-height: 1.2; }
.spot-id { font-weight: 900; color: #782435; font-size: 1.2rem; }
.card-footer { margin-top: auto; padding-top: 10px; border-top: 1px solid #eee; display: flex; justify-content: space-between; font-size: 0.8rem; color: #666; }
.duration-badge { font-weight: 700; color: #782435; }

/* Modal and Action Styles */
.action-trigger { margin-left: 15px; background: #782435; color: white; border: none; padding: 6px 12px; border-radius: 6px; cursor: pointer; font-weight: 600; font-size: 0.8rem; }
.modal-overlay { position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.6); display: flex; align-items: center; justify-content: center; z-index: 1000; }
.end-session-modal { background: white; width: 500px; border-radius: 12px; padding: 2rem; box-shadow: 0 10px 25px rgba(0,0,0,0.2); }
.modal-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
.close-btn { background: none; border: none; font-size: 1.2rem; cursor: pointer; color: #999; }
.modal-input { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 8px; margin-top: 10px; box-sizing: border-box; }
.modal-results { background: #f9f9f9; border: 1px solid #eee; max-height: 150px; overflow-y: auto; margin-top: 5px; border-radius: 8px; }
.result-row { display: flex; justify-content: space-between; padding: 10px; border-bottom: 1px solid #eee; align-items: center; }
.mini-end-btn { background: #ffeded; color: #d32f2f; border: 1px solid #ffcccc; padding: 4px 8px; border-radius: 4px; font-size: 0.75rem; cursor: pointer; }
.no-results-msg { font-size: 0.85rem; color: #999; margin-top: 10px; text-align: center; }
.modal-divider { margin: 25px 0; border: 0; border-top: 1px solid #eee; }
.disabled-notice { font-size: 0.85rem; color: #999; font-style: italic; margin-top: 10px; }

/* Loader and Animations */
.loader-container { text-align: center; padding: 3rem; }
@keyframes pulse { 0% { transform: scale(0.9); opacity: 1; } 70% { transform: scale(1.2); opacity: 0.4; } 100% { transform: scale(0.9); opacity: 1; } }
</style>