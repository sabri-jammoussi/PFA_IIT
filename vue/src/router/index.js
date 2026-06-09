import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes = [
  {
    path: '/',
    component: () => import('@/components/MainLayout.vue'),
    meta: { requiresAuth: true },
    children: [
      {
        path: '',
        name: 'home',
        component: () => import('@/views/DashboardView.vue')
      },
      {
        path: 'admin',
        name: 'AdminDashboard',
        component: () => import('@/views/admin/AdminDashboard.vue'),
        meta: { roles: ['Admin'] }
      },
      {
        path: 'dentiste',
        name: 'DentistDashboard',
        component: () => import('@/views/dentiste/DentistDashboard.vue'),
        meta: { roles: ['Dentiste'] }
      },
      {
        path: 'secretaire',
        name: 'SecretaireDashboard',
        component: () => import('@/views/secretaire/SecretaireDashboard.vue'),
        meta: { roles: ['Secretaire'] }
      },
      {
        path: 'appointments',
        name: 'appointments',
        component: () => import('@/views/appointments/AppointmentsView.vue'),
        meta: { roles: ['Admin', 'Dentiste', 'Secretaire'] }
      },
      {
        path: 'patients',
        name: 'patients',
        component: () => import('@/views/patients/PatientsView.vue'),
        meta: { roles: ['Dentiste', 'Secretaire'] }
      },
      {
        path: 'patients/:id',
        name: 'patient-profile',
        component: () => import('@/views/PatientProfileView.vue'),
        meta: { roles: ['Dentiste', 'Secretaire'] }
      },
      {
        path: 'billing',
        name: 'billing',
        component: () => import('@/views/BillingView.vue'),
        meta: { roles: ['Admin', 'Secretaire'] }
      },
      {
        path: 'medical-acts',
        name: 'medical-acts',
        component: () => import('@/views/MedicalActsView.vue'),
        meta: { roles: ['Admin', 'Dentiste'] }
      },
      {
        path: 'profile',
        name: 'profile',
        component: () => import('@/views/ProfileView.vue'),
        meta: { roles: ['Admin', 'Dentiste', 'Secretaire'] }
      },
      {
        path: 'settings',
        name: 'settings',
        component: () => import('@/views/SettingsView.vue'),
        meta: { roles: ['Admin', 'Dentiste', 'Secretaire'] }
      },
      {
        path: 'unauthorized',
        name: 'Unauthorized',
        component: () => import('@/views/shared/UnauthorizedView.vue')
      }
    ]
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('../views/LoginView.vue'),
    meta: { guestOnly: true }
  },
  // Redirect any unknown route to login or root
  {
    path: '/:pathMatch(.*)*',
    redirect: '/'
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

// 2. Navigation Guard (Role redirection logic)
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  
  const isAuthenticated = authStore.isAuthenticated
  const userRole = authStore.role

  // Case 1: Route requires authentication and user is not logged in
  if (to.meta.requiresAuth !== false && !isAuthenticated && to.name !== 'login') {
    return next({ name: 'login', query: { redirect: to.fullPath } })
  }

  // Case 2: User is logged in and tries to access the Login page
  if (to.name === 'login' && isAuthenticated) {
    return redirectBasedOnRole(userRole, next)
  }

  // Case 3: Root access "/" redirects to specific dashboard based on role
  if (to.path === '/' && isAuthenticated) {
    return redirectBasedOnRole(userRole, next)
  }

  // Case 4: Route has role-based restrictions and user is not allowed
  if (to.meta.roles && !to.meta.roles.includes(userRole)) {
    return next({ name: 'Unauthorized' })
  }

  // Default path continue
  next()
})

// Helper routing director based on role
export function redirectBasedOnRole(role, next) {
  switch (role) {
    case 'Admin':
      next({ name: 'AdminDashboard' })
      break
    case 'Dentiste':
      next({ name: 'DentistDashboard' })
      break
    case 'Secretaire':
      next({ name: 'SecretaireDashboard' })
      break
    default:
      next() // Proceed safely without redirect loop
  }
}

export default router
