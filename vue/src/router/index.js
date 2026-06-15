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
      // === Space Platform (SuperAdmin - Role 1) ===
      {
        path: 'admin/analytics',
        name: 'AdminAnalytics',
        component: () => import('@/views/admin/AdminDashboard.vue'),
        meta: { roles: [1] }
      },
      {
        path: 'admin/cabinets',
        name: 'CabinetsManagement',
        component: () => import('@/views/admin/CabinetsManagementView.vue'),
        meta: { roles: [1] }
      },
      {
        path: 'admin/settings/smtp',
        name: 'AdminSmtpSettings',
        component: () => import('@/views/admin/SmtpSettingsView.vue'),
        meta: { roles: [1] }
      },
      {
        path: 'admin/settings/cloudinary',
        name: 'AdminCloudinarySettings',
        component: () => import('@/views/admin/CloudinarySettingsView.vue'),
        meta: { roles: [1] }
      },
      {
        path: 'admin/settings/storage',
        name: 'AdminStorageSettings',
        component: () => import('@/views/admin/StorageSettingsView.vue'),
        meta: { roles: [1] }
      },
      // === Space Dentist (Role 2) ===
      {
        path: 'dentiste',
        name: 'DentistDashboard',
        component: () => import('@/views/dentiste/DentistDashboard.vue'),
        meta: { roles: [2] }
      },
      {
        path: 'dentiste/patients',
        name: 'DentistPatients',
        component: () => import('@/views/patients/PatientsView.vue'),
        meta: { roles: [2] }
      },
      {
        path: 'dentiste/patients/:id',
        name: 'DentistPatientProfile',
        component: () => import('@/views/PatientProfileView.vue'),
        meta: { roles: [2, 3] }
      },
      {
        path: 'patient-profile/:id',
        name: 'patient-profile',
        redirect: to => ({ name: 'DentistPatientProfile', params: { id: to.params.id } })
      },
      {
        path: 'dentiste/consultation',
        name: 'DentistConsultation',
        component: () => import('@/views/dentiste/ConsultationView.vue'),
        meta: { roles: [2] }
      },
      {
        path: 'dentiste/acts',
        name: 'DentistActs',
        component: () => import('@/views/MedicalActsView.vue'),
        meta: { roles: [2] }
      },
      {
        path: 'dentiste/secretaires',
        name: 'DentistSecretaires',
        component: () => import('@/views/dentiste/SecretairesView.vue'),
        meta: { roles: [2] }
      },
      {
        path: 'dentiste/settings/cabinet',
        name: 'CabinetSettings',
        component: () => import('@/views/dentiste/CabinetSettingsView.vue'),
        meta: { roles: [2] }
      },
      // === Space Secretary (Role 3) ===
      {
        path: 'secretaire',
        name: 'SecretaireDashboard',
        component: () => import('@/views/secretaire/SecretaireDashboard.vue'),
        meta: { roles: [3] }
      },
      {
        path: 'secretaire/agenda',
        name: 'SecretaireAgenda',
        component: () => import('@/views/appointments/AppointmentsView.vue'),
        meta: { roles: [3] }
      },
      {
        path: 'secretaire/demandes',
        name: 'SecretairePendingRequests',
        component: () => import('@/views/secretaire/PendingRequestsView.vue'),
        meta: { roles: [3] }
      },
      {
        path: 'secretaire/admissions',
        name: 'SecretaireAdmissions',
        component: () => import('@/views/patients/PatientsView.vue'),
        meta: { roles: [3] }
      },
      {
        path: 'secretaire/billing',
        name: 'SecretaireBilling',
        component: () => import('@/views/BillingView.vue'),
        meta: { roles: [3] }
      },
      {
        path: 'secretaire/stock',
        name: 'SecretaireStock',
        component: () => import('@/views/stock/StockView.vue'),
        meta: { roles: [3] }
      },
      // === Space Patient (Role 4) ===
      {
        path: 'patient/dashboard',
        name: 'PatientDashboard',
        component: () => import('@/views/patient/PatientDashboard.vue'),
        meta: { roles: [4] }
      },
      // === Shared Pages ===
      {
        path: 'profile',
        name: 'profile',
        component: () => import('@/views/ProfileView.vue'),
        meta: { roles: [1, 2, 3, 4] }
      },
      {
        path: 'settings',
        name: 'settings',
        component: () => import('@/views/SettingsView.vue'),
        meta: { roles: [1, 2, 3, 4] }
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
    meta: { guestOnly: true, requiresAuth: false }
  },
  {
    path: '/register',
    name: 'register',
    component: () => import('../views/RegisterClinicView.vue'),
    meta: { guestOnly: true, requiresAuth: false }
  },
  {
    path: '/subscription-expired',
    name: 'SubscriptionExpired',
    component: () => import('../views/shared/SubscriptionExpiredView.vue'),
    meta: { requiresAuth: true }
  },
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
    case 1:
      next({ name: 'AdminAnalytics' })
      break
    case 2:
      next({ name: 'DentistDashboard' })
      break
    case 3:
      next({ name: 'SecretaireDashboard' })
      break
    case 4:
      next({ name: 'PatientDashboard' })
      break
    default:
      next() // Proceed safely without redirect loop
  }
}

export default router
