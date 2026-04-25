<script setup>
import { ref, computed, onMounted } from 'vue';
import apiClient from '@/api';

const sessions = ref([]);
const searchQuery = ref('');
const loading = ref(true);

// 1. Fetch data from your backend route
async function fetchActiveSessions() {
  loading.value = true;
  try {
    const response = await apiClient.get('/admin/active-sessions');
    sessions.value = response.data;
  } catch (err) {
    console.error("Monitor Error:", err);
  } finally {
    loading.value = false;
  }
}

// 2. Search filtering logic
const filteredSessions = computed(() => {
  const query = searchQuery.value.toLowerCase();
  return sessions.value.filter(s => 
    s.owner_name.toLowerCase().includes(query) ||
    s.license_plate.toLowerCase().includes(query) ||
    s.lot_name.toLowerCase().includes(query) ||
    s.spot_number.toString().includes(query)
  );
});

// Helper for dynamic colors
const getPermitClass = (type) => {
  if (!type) return 'standard';
  return type.toLowerCase().includes('faculty') ? 'faculty' : 'student';
};

onMounted(fetchActiveSessions);
</script>

<template>
  <div class="monitor-layout">
    <div class="monitor-header">
      <div class="title-group">
        <h2>Live Session Monitor</h2>
        <div class="live-status">
          <span class="pulse-dot"></span>
          LIVE DATA
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

    <div v-if="loading" class="loader">Scanning Lots...</div>

    <div v-else class="session-grid">
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
    
    <div v-if="!loading && filteredSessions.length === 0" class="empty-state">
      No active sessions found matching your search.
    </div>
  </div>
</template>

<style scoped>
.monitor-layout {
  padding: 20px;
  width: 100%;
  max-width: 100%;
  box-sizing: border-box; /* This is the key to preventing "spill" */
}

.monitor-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.05);
  margin-bottom: 2rem;
  
  /* FORCE ALIGNMENT */
  width: 100%;
  box-sizing: border-box; /* Includes padding in the 100% width */
  min-width: 0;           /* Prevents internal expansion */
}

.title-group {
  flex-shrink: 1;         /* Allows title to shrink if screen is tiny */
  min-width: 0;
}

.search-wrapper {
  position: relative;
  width: 350px;           /* Fixed width */
  flex-shrink: 0;         /* Prevents the search bar from getting squished */
}

.search-wrapper input {
  width: 100%;            /* Uses the 350px from the wrapper */
  padding: 10px 15px 10px 40px;
  border: 1px solid #ddd;
  border-radius: 25px;
  background-color: #fff;
  box-sizing: border-box; /* CRITICAL: Keeps input inside the 350px wrapper */
}

.search-wrapper input:focus {
  border-color: #782435;  /* Garnet focus ring */
  outline: none;
}

.search-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
}

.title-group h2 { margin: 0; font-weight: 700; color: #333; }

.live-status {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.75rem;
  font-weight: 800;
  color: #d32f2f;
  margin-top: 4px;
}

.pulse-dot {
  width: 8px;
  height: 8px;
  background: #d32f2f;
  border-radius: 50%;
  animation: pulse 1.5s infinite;
}

/* Grid Logic */
.session-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 20px;
}

.session-card {
  background: white;
  border-radius: 12px;
  display: flex;
  overflow: hidden;
  box-shadow: 0 4px 15px rgba(0,0,0,0.05);
  border: 1px solid #efefef;
  transition: transform 0.2s;
}

.session-card:hover { transform: translateY(-3px); }

.accent-bar { width: 8px; flex-shrink: 0; }
.accent-bar.student { background: #782435; }
.accent-bar.faculty { background: #ceb888; }

.card-main { padding: 1.25rem; flex-grow: 1; display: flex; flex-direction: column; gap: 12px; }

.header-row { display: flex; justify-content: space-between; align-items: flex-start; }

.user-meta .name { display: block; font-weight: 700; font-size: 1.1rem; }
.user-meta .fsuid { font-size: 0.8rem; color: #777; }

.permit-tag {
  font-size: 0.7rem;
  padding: 4px 8px;
  border-radius: 4px;
  font-weight: 800;
}
.permit-tag.student { background: #f8e8ea; color: #782435; }
.permit-tag.faculty { background: #fdf8e6; color: #8a733e; }

.vehicle-strip {
  background: #f8f9fa;
  padding: 10px;
  border-radius: 8px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.plate-badge {
  background: #222;
  color: white;
  padding: 3px 8px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-weight: 900;
  font-size: 0.9rem;
}

.location-box { display: flex; justify-content: space-between; align-items: center; }
.loc-path { font-size: 0.9rem; line-height: 1.2; }
.spot-id { font-weight: 900; color: #782435; font-size: 1.2rem; }

.card-footer {
  margin-top: auto;
  padding-top: 10px;
  border-top: 1px solid #eee;
  display: flex;
  justify-content: space-between;
  font-size: 0.8rem;
  color: #666;
}

.duration-badge { font-weight: 700; color: #782435; }

@keyframes pulse {
  0% { transform: scale(0.9); opacity: 1; }
  70% { transform: scale(1.2); opacity: 0.4; }
  100% { transform: scale(0.9); opacity: 1; }
}
</style>