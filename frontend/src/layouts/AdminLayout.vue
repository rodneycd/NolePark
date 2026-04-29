<template>
  <div class="admin-layout">
    <aside class="sidebar">
      <div class="sidebar-brand">
        <span class="gold-text">NOLE</span>PARK <span class="admin-badge">ADMIN</span>
      </div>
      <nav class="sidebar-nav">
        <router-link to="/admin/lots" class="nav-link">
          <i class="icon-map"></i> Lot Management
        </router-link>
        <router-link to="/admin/sessions" class="nav-link">
          <i class="icon-clock"></i> Active Sessions
        </router-link>
      </nav>
    </aside>

    <div class="main-content">
      <header class="admin-header">
        <div class="breadcrumb">Campus Infrastructure / Lot Management</div>
        <div class="admin-profile">Admin User</div>
      </header>
      
      <div class="view-container">
        <router-view />
      </div>
    </div>
  </div>
</template>

<style scoped>
.admin-layout {
  display: flex;
  height: 100vh;
  width: 100vw;
  overflow: hidden;
  font-family: 'Inter', sans-serif;
}

.sidebar {
  width: 260px;
  background: #1a1a1a;
  color: white;
  display: flex;
  flex-direction: column;
}

.sidebar-brand {
  padding: 30px 25px;
  font-size: 1.2rem;
  font-weight: 800;
  border-bottom: 1px solid #333;
}

.gold-text { color: #ceb888; }
.admin-badge {
  font-size: 0.7rem;
  background: #782435;
  padding: 2px 6px;
  border-radius: 4px;
  vertical-align: middle;
}

/* Update these specific classes in your <style> section */

.sidebar-nav {
  display: flex;
  flex-direction: column; /* Force links to stack vertically */
  padding-top: 20px;
}

.nav-link {
  display: block;          /* CRITICAL: Makes the link take up the full width */
  padding: 15px 25px;      /* Gives the text breathing room */
  color: #aaa;
  text-decoration: none;
  transition: all 0.2s;
  border-left: 4px solid transparent;
  width: 100%;             /* Ensures it fills the sidebar */
  box-sizing: border-box;  /* Prevents padding from breaking the width */
}

/* This will fix the overlapping text you see in the screenshot */
.nav-link + .nav-link {
  margin-top: 5px;         /* Optional: tiny gap between items */
}

.nav-link:hover, .router-link-active {
  color: white;
  background: #252525;
  border-left-color: #782435;
}

.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  background: #f4f6f8;
}

.admin-header {
  height: 60px;
  background: white;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 40px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.05);
}

.view-container {
  padding: 40px;
  overflow-y: auto;
  flex: 1;
}
</style>