import { createRouter, createWebHistory } from 'vue-router';
import LoginView from '../views/LoginView.vue';
import SignupView from '../views/SignupView.vue';
import SettingsView from '@/views/SettingsView.vue';
import HomeView from '@/views/HomeDashView.vue';
import user from '../api/users'

const routes = [
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/login',
    name: 'Login',
    component: LoginView
  },
  {
    path: '/signup',
    name: 'Signup',
    component: SignupView
  },
  {
    path: '/settings',
    name: 'Settings',
    component: SettingsView,
  },
  {
    path: '/home',
    name: 'Home',
    component: HomeView,
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

router.beforeEach(async (to, from, next) => {
  const userId = localStorage.getItem('active_user_id'); 

  // Force unauthenticated users to Login/Signup
  if (!userId && to.name !== 'Login' && to.name !== 'Signup' ){
    return next({name: 'Login'});
  }

  if (userId) {
    try {
      const profile = await user.getUserProfile(Number(userId));
      
      // Incomplete Profile check
      if (profile.user_role === 'student' && profile.permit_type === 'None'){
        if (to.name === 'Settings') return next();
        alert("Please complete your profile first.");
        return next({ name: 'Settings' });
      }

      // If they are logged in don't let them go back to Login/Signup
      if ((to.name === 'Login' || to.name === 'Signup')) {
        return next({ name: 'Home' });
      }
    } catch (err) {
      console.error("Auth check failed", err);
      localStorage.removeItem('active_user_id');
      return next({ name: 'Login' });
    }
  }
  next();
});

export default router;