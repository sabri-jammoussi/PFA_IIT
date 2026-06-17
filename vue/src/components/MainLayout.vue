<script setup>
import { useAuthStore } from '@/stores/auth'
import { useToast } from 'primevue/usetoast'
import { computed, ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useNotificationsStore } from '@/stores/notifications'
import NotificationsSidebar from '@/components/Notifications/NotificationsSidebar.vue'
import UserProfilePicture from '@/components/UserProfilePicture.vue'


const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()
const toast = useToast()

const sidebarOpen = ref(true)
const userDropdownOpen = ref(false)
const notificationDropdownOpen = ref(false)

const userFullName = computed(() => authStore.fullName)
const userRole = computed(() => {
  const role = authStore.role
  if (role === 1) return 'Administrateur'
  if (role === 2) return 'Dr. ' + (authStore.user?.nom || '')
  if (role === 3) return 'Secrétaire'
  if (role === 4) return 'Patient'
  return 'Inconnu'
})

const notificationsStore = useNotificationsStore()
const unreadCount = computed(() => notificationsStore.notificationsCount)
const notificationsSidebarVisible = ref(false)

onMounted(async () => {
  if (authStore.isAuthenticated) {
    await notificationsStore.refreshNotifications()
  }
})

const sidebarHeader = computed(() => {
  const role = authStore.role
  const cabinetName = authStore.user?.cabinetName || 'Cabinet'
  if (role === 1) return '🌐 DENTIFLOW SAAS CONTROLLER'
  if (role === 2) return `⚙️ CLINIQUE DENTIFLOW [${cabinetName}]`
  if (role === 3) return `🏢 LOGISTIQUE DENTIFLOW [${cabinetName}]`
  if (role === 4) return `🦷 ESPACE PATIENT [${cabinetName}]`
  return 'DentiFlow'
})

const menuItems = computed(() => {
  const allItems = [
    // Dentist Space (Role 2)
    {
      label: "Vue d'ensemble",
      icon: 'pi pi-chart-bar',
      routeName: 'DentistDashboard',
      roles: [2]
    },
    {
      label: 'Dossiers Patients',
      icon: 'pi pi-users',
      routeName: 'DentistPatients',
      roles: [2]
    },
    {
      label: 'Schéma Dentaire',
      icon: 'pi pi-shield',
      routeName: 'DentistConsultation',
      roles: [2]
    },
    {
      label: 'Catalogue des Actes',
      icon: 'pi pi-book',
      routeName: 'DentistActs',
      roles: [2]
    },
    {
      label: 'Gestion Secrétaires',
      icon: 'pi pi-user-edit',
      routeName: 'DentistSecretaires',
      roles: [2]
    },
    {
      label: 'Paramètres du Cabinet',
      icon: 'pi pi-cog',
      routeName: 'CabinetSettings',
      roles: [2]
    },

    // Secretary Space (Role 3)
    {
      label: 'Agenda Global',
      icon: 'pi pi-calendar',
      routeName: 'SecretaireAgenda',
      roles: [3]
    },
    {
      label: 'Liste des Demandes',
      icon: 'pi pi-bell',
      routeName: 'SecretairePendingRequests',
      roles: [3]
    },
    {
      label: 'Admissions Patients',
      icon: 'pi pi-user-plus',
      routeName: 'SecretaireAdmissions',
      roles: [3]
    },
    {
      label: 'Facturation & Invoices',
      icon: 'pi pi-wallet',
      routeName: 'SecretaireBilling',
      roles: [3]
    },
    {
      label: 'Gestion des Stocks',
      icon: 'pi pi-box',
      routeName: 'SecretaireStock',
      roles: [3]
    },

    // Patient Space (Role 4)
    {
      label: 'Mon Espace Santé',
      icon: 'pi pi-heart',
      routeName: 'PatientDashboard',
      roles: [4]
    },

    // Platform Space (SuperAdmin - Role 1)
    {
      label: 'Performances Plateforme',
      icon: 'pi pi-chart-line',
      routeName: 'AdminAnalytics',
      roles: [1]
    },
    {
      label: 'Gestion des Cabinets',
      icon: 'pi pi-building',
      routeName: 'CabinetsManagement',
      roles: [1]
    },
    {
      label: 'Variables Système',
      icon: 'pi pi-sliders-h',
      routeName: 'AdminSmtpSettings',
      roles: [1]
    }
  ]

  const userRoleName = authStore.role
  return allItems.filter(item => item.roles.includes(userRoleName))
})

const handleLogout = async () => {
  try {
    await authStore.logout()
    toast.add({
      severity: 'info',
      summary: 'Déconnexion',
      detail: 'Session fermée avec succès.',
      life: 3000
    })
    router.push({ name: 'login' })
  } catch (error) {
    toast.add({
      severity: 'error',
      summary: 'Erreur',
      detail: 'Erreur lors de la déconnexion.',
      life: 3000
    })
  }
}

const toggleSidebar = () => {
  sidebarOpen.value = !sidebarOpen.value
}

const isRouteActive = (routeName) => {
  if (routeName === 'home' && route.name === 'home') return true
  if (routeName !== 'home' && route.name && route.name.toString().startsWith(routeName)) return true
  return false
}

const currentBreadcrumb = computed(() => {
  const name = route.name?.toString() || ''
  if (name === 'home' || name === 'AdminAnalytics' || name === 'DentistDashboard' || name === 'SecretaireDashboard' || name === 'PatientDashboard') return 'Tableau de bord'
  if (name === 'AdminSmtpSettings') return 'Configuration SMTP'
  if (name === 'AdminCloudinarySettings') return 'Stockage Cloudinary'
  if (name === 'AdminStorageSettings') return 'Espace de Stockage'
  if (name === 'CabinetsManagement') return 'Gestion des Cabinets'
  
  if (name === 'SecretaireAgenda') return 'Agenda Global'
  if (name === 'SecretairePendingRequests') return 'Liste des Demandes'
  if (name === 'SecretaireAdmissions') return 'Admissions Patients'
  
  if (name === 'DentistPatients') return 'Dossiers Patients'
  if (name === 'DentistPatientProfile') return 'Dossier Clinique Patient'
  
  if (name === 'SecretaireBilling') return 'Facturation & Invoices'
  if (name === 'DentistActs') return 'Catalogue des Actes'
  if (name === 'SecretaireStock') return 'Gestion des Stocks'
  if (name === 'DentistConsultation') return 'Consultation Synchrone'
  
  if (name === 'profile') return 'Mon Profil'
  if (name === 'settings') return 'Paramètres'
  if (name === 'CabinetSettings') return 'Paramètres du Cabinet'
  if (name === 'DentistSecretaires') return 'Gestion Secrétaires'
  if (name === 'Unauthorized') return 'Accès Restreint'
  return ''
})

const markAllNotificationsRead = () => {
  notifications.value.forEach(n => n.unread = false)
}
</script>

<template>
  <div class="min-h-screen flex bg-slate-100 font-sans text-slate-800 relative">

    <!-- Notifications Sidebar Drawer -->
    <NotificationsSidebar v-model:visible="notificationsSidebarVisible" />

    <!-- Left Sidebar (Slate Navy) -->
    <aside 
      class="fixed inset-y-0 left-0 bg-slate-900 text-white z-30 transition-all duration-300 flex flex-col justify-between border-r border-slate-800 shadow-xl"
      :class="[sidebarOpen ? 'w-64' : 'w-20']"
    >
      <!-- Brand/Logo Section -->
      <div>
        <div class="h-16 flex items-center px-5 border-b border-slate-800 gap-3 overflow-hidden">
          <img 
            src="@/assets/logo-removebg-preview.png" 
            alt="DentiFlow Logo" 
            class="w-10 h-10 object-contain rounded-xl bg-slate-800/30 p-1 flex-shrink-0 shadow-lg"
          />
          <div v-show="sidebarOpen" class="flex flex-col transition-all duration-300">
            <span class="text-base font-bold tracking-tight text-white leading-tight">DentiFlow</span>
            <span class="text-[9px] text-sky-400 font-bold uppercase tracking-widest mt-0.5">Cabinet Intuitif</span>
          </div>
        </div>

        <!-- Dynamic SaaS Workspace Header -->
        <div v-show="sidebarOpen" class="px-5 py-2.5 bg-slate-950/45 border-b border-slate-800/60 text-[9px] font-extrabold tracking-wider text-sky-400 uppercase leading-normal truncate">
          {{ sidebarHeader }}
        </div>

        <!-- Navigation Menu -->
        <nav class="p-3 space-y-1.5 mt-4">
          <router-link
            v-for="item in menuItems"
            :key="item.routeName"
            :to="{ name: item.routeName }"
            class="flex items-center gap-3.5 px-3.5 py-3 rounded-xl transition-all duration-200 group relative cursor-pointer"
            :class="[
              isRouteActive(item.routeName) 
                ? 'bg-sky-500/10 text-sky-400 border-l-2 border-sky-400 font-semibold' 
                : 'text-slate-400 hover:text-white hover:bg-slate-800/50'
            ]"
          >
            <!-- Icon -->
            <i 
              :class="[item.icon, isRouteActive(item.routeName) ? 'text-sky-400' : 'text-slate-400 group-hover:text-slate-100']"
              class="text-lg transition-colors"
            ></i>
            
            <!-- Label -->
            <span 
              v-show="sidebarOpen" 
              class="text-sm tracking-wide transition-opacity duration-300"
            >
              {{ item.label }}
            </span>

            <!-- Tooltip when collapsed -->
            <span 
              v-show="!sidebarOpen" 
              class="absolute left-full ml-4 px-2 py-1 bg-slate-950 text-xs text-white rounded opacity-0 group-hover:opacity-100 pointer-events-none transition-opacity duration-200 whitespace-nowrap shadow-md z-50 border border-slate-800"
            >
              {{ item.label }}
            </span>
          </router-link>
        </nav>
      </div>

      <!-- Sidebar Footer (User identity or Collapse toggle) -->
      <div class="border-t border-slate-800 p-3 bg-slate-950/40">
        <!-- Collapse Trigger Button -->
        <button 
          @click="toggleSidebar"
          class="hidden md:flex items-center justify-center w-full py-2 hover:bg-slate-800/80 rounded-lg text-slate-400 hover:text-white transition-colors cursor-pointer mb-2"
        >
          <i :class="[sidebarOpen ? 'pi pi-chevron-left' : 'pi pi-chevron-right']" class="text-sm"></i>
          <span v-show="sidebarOpen" class="text-xs font-semibold ml-2">Réduire le menu</span>
        </button>

        <!-- Session Badge -->
        <div class="flex items-center gap-3 p-2 rounded-lg">
          <UserProfilePicture
            v-if="authStore.user?.id"
            :userId="authStore.user.id"
            :shortNameUser="(authStore.user.prenom?.charAt(0) || '') + (authStore.user.nom?.charAt(0) || '')"
            :avatarColeur="'#334155'"
            :allowEdit="false"
            size="32px"
            :refreshPic="authStore.userImageVersion"
          />
          <div v-show="sidebarOpen" class="overflow-hidden flex-1 min-w-0">
            <p class="text-xs font-bold text-slate-200 truncate leading-normal">{{ userFullName }}</p>
            <p class="text-[10px] text-slate-500 font-bold truncate tracking-wider uppercase mt-0.5">{{ authStore.roleName }}</p>
          </div>
        </div>
      </div>
    </aside>

    <!-- RIGHT CONTAINER (Adjusts margin based on sidebar state) -->
    <div 
      class="flex-1 flex flex-col min-h-screen transition-all duration-300"
      :class="[sidebarOpen ? 'md:ml-64 ml-0' : 'md:ml-20 ml-0']"
    >
      
      <!-- Top Header Bar -->
      <header class="h-16 bg-white border-b border-slate-200/60 px-6 flex justify-between items-center sticky top-0 z-20 shadow-sm">
        
        <!-- Left: Collapse toggle + Breadcrumbs -->
        <div class="flex items-center gap-4">
          <!-- Mobile Menu Toggle -->
          <button 
            @click="sidebarOpen = !sidebarOpen"
            class="md:hidden p-1.5 hover:bg-slate-100 rounded-lg text-slate-600 transition-colors cursor-pointer"
          >
            <i class="pi pi-bars text-lg"></i>
          </button>
          
          <!-- Breadcrumbs -->
          <div class="flex items-center gap-2 text-xs font-semibold text-slate-400 uppercase tracking-wider">
            <span>DentiFlow</span>
            <i class="pi pi-chevron-right text-[8px] text-slate-300"></i>
            <span class="text-slate-700">{{ currentBreadcrumb }}</span>
          </div>
        </div>

        <!-- Right: Actions & User Dropdown -->
        <div class="flex items-center gap-4 relative">
          
          <!-- Cabinet Name dynamic display -->
          <div v-if="authStore.user?.cabinetName" class="hidden md:flex items-center gap-2 px-3.5 py-1.5 bg-slate-50 border border-slate-200/60 rounded-xl text-xs font-extrabold text-slate-700 shadow-sm">
            <i class="pi pi-building text-sky-500"></i>
            <span>{{ authStore.user.cabinetName }} &bull; {{ userRole }}</span>
          </div>
          
          <!-- Notifications Bell -->
          <div class="relative">
            <button 
              @click="notificationsSidebarVisible = true; userDropdownOpen = false"
              class="w-9 h-9 rounded-lg hover:bg-slate-100 flex items-center justify-center text-slate-600 border border-slate-100 transition-colors cursor-pointer"
            >
              <i class="pi pi-bell text-base"></i>
              <span 
                v-if="unreadCount > 0" 
                class="absolute -top-1.5 -right-1.5 w-5 h-5 bg-rose-500 text-white text-[9px] font-extrabold rounded-full flex items-center justify-center shadow-md border border-white"
              >
                {{ unreadCount }}
              </span>
            </button>
          </div>

          <!-- User dropdown block -->
          <div class="relative">
            <button 
              @click="userDropdownOpen = !userDropdownOpen; notificationDropdownOpen = false"
              class="flex items-center gap-2 px-2 py-1.5 rounded-lg border border-slate-100 hover:bg-slate-50 transition-colors cursor-pointer"
            >
              <UserProfilePicture
                v-if="authStore.user?.id"
                :userId="authStore.user.id"
                :shortNameUser="(authStore.user.prenom?.charAt(0) || '') + (authStore.user.nom?.charAt(0) || '')"
                :avatarColeur="'#e0f2fe'"
                :allowEdit="false"
                size="32px"
                :refreshPic="authStore.userImageVersion"
              />
              <div class="hidden sm:flex flex-col text-left">
                <span class="text-xs font-bold text-slate-800 leading-none">{{ userFullName }}</span>
                <span class="text-[9px] text-slate-400 font-bold uppercase mt-1 leading-none">{{ userRole }}</span>
              </div>
              <i class="pi pi-chevron-down text-[10px] text-slate-400 ml-1"></i>
            </button>

            <!-- User Dropdown Menu -->
            <div 
              v-show="userDropdownOpen"
              class="absolute right-0 mt-2.5 w-52 bg-white border border-slate-200/65 rounded-xl shadow-xl z-50 py-1.5 text-xs text-slate-700 divide-y divide-slate-100 animate-slide-in"
            >
              <div class="px-4 py-2 bg-slate-50/50">
                <p class="font-bold text-slate-900 leading-normal">{{ userFullName }}</p>
                <p class="text-[10px] text-slate-400 font-bold uppercase mt-0.5">{{ authStore.user?.email }}</p>
              </div>
              <div class="py-1">
                <router-link :to="{ name: 'profile' }" class="flex items-center gap-2.5 px-4 py-2 hover:bg-slate-50 transition-colors">
                  <i class="pi pi-user text-slate-400"></i>
                  <span>Mon Profil</span>
                </router-link>
                <router-link :to="{ name: 'settings' }" class="flex items-center gap-2.5 px-4 py-2 hover:bg-slate-50 transition-colors">
                  <i class="pi pi-cog text-slate-400"></i>
                  <span>Paramètres</span>
                </router-link>
              </div>
              <div class="py-1">
                <button 
                  @click="handleLogout" 
                  class="w-full flex items-center gap-2.5 px-4 py-2 text-rose-600 hover:bg-rose-50 transition-colors text-left cursor-pointer font-semibold"
                >
                  <i class="pi pi-sign-out text-rose-400"></i>
                  <span>Se déconnecter</span>
                </button>
              </div>
            </div>
          </div>

        </div>
      </header>

      <!-- Main Portal Body (sterile background #F8FAFC) -->
      <main class="flex-grow p-6 md:p-8 bg-slate-50 max-w-7xl w-full mx-auto">
        <!-- Render page modules here -->
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </main>

      <!-- Clinical Footer -->
      <footer class="h-12 bg-white border-t border-slate-200/60 px-6 flex justify-between items-center text-[10px] text-slate-400 font-bold uppercase tracking-wider">
        <span>© 2026 DentiFlow Dental portal</span>
        <span class="flex items-center gap-1.5 text-emerald-600 bg-emerald-50 border border-emerald-100 rounded-md px-2 py-0.5">
          <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
          Système Sécurisé HDS
        </span>
      </footer>
    </div>
  </div>
</template>

<style>
/* Utility animations */
@keyframes slideIn {
  from { opacity: 0; transform: translateY(8px); }
  to { opacity: 1; transform: translateY(0); }
}
.animate-slide-in {
  animation: slideIn 0.2s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}

/* Page transitions */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.15s ease;
}
.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>
