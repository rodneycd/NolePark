import { createRouter, createWebHistory } from 'vue-router';
import LoginView from '../views/LoginView.vue';
import SignupView from '../views/SignupView.vue';
import SettingsView from '@/views/SettingsView.vue';
import HomeView from '@/views/HomeDashView.vue';
import user from '../api/users'
import AdminLayout from '@/layouts/AdminLayout.vue';
import LotManagement from '@/views/admin/LotManagement.vue';
import ActiveSessions from '@/views/admin/ActiveSessions.vue';

const routes = [
  {
    path: '/admin',
    component: AdminLayout,
    children: [
      {
        path: 'lots',
        name: 'AdminLots',
        component: LotManagement,
      },
      {
         path: 'sessions',
         name: 'ActiveSessions',
         component: ActiveSessions
      },
    ]
  },
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
  },
  {
    path: '/search',
    name: 'Search',
    component: () => import('@/views/SearchView.vue')
  },
  {
    path: '/sessions',
    name: 'Sessions',
    component: () => import('@/views/SessionsView.vue')
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

router.beforeEach(async (to, from, next) => {
  const userId = localStorage.getItem('active_user_id');

  // Guard 1: No user? Go to Login
  if (!userId && to.name !== 'Login' && to.name !== 'Signup') {
    return next({ name: 'Login' });
  }

  if (userId) {
    try {
      const profile = await user.getUserProfile(Number(userId));
      const isAdmin = profile.user_role === 'admin';

      // Guard 2: Logic for Login/Signup redirection
      if (to.name === 'Login' || to.name === 'Signup') {
        // If admin, push to lots. If student, push to home.
        return isAdmin ? next({ name: 'AdminLots' }) : next({ name: 'Home' });
      }

      // Guard 3: Prevent students from manually typing /admin URLs
      if (to.path.startsWith('/admin') && !isAdmin) {
        return next({ name: 'Home' });
      }

      // Guard 4: Existing incomplete profile check for students
      if (!isAdmin && profile.permit_type === 'None') {
        if (to.name === 'Settings') return next();
        return next({ name: 'Settings' });
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