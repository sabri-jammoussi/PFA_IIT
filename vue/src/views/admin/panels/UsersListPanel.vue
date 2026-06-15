<script setup>
import { ref, onMounted, watch } from 'vue'
import { useToast } from 'primevue/usetoast'
import api from '@/services/api'

const toast = useToast()
const isOpen = ref(false)
const loading = ref(false)
const users = ref([])

// Pagination & Filtering
const search = ref('')
const roleId = ref(null)
const page = ref(1)
const pageSize = ref(5)
const totalCount = ref(0)

const fetchUsers = async () => {
  loading.value = true
  try {
    const params = {
      page: page.value,
      pageSize: pageSize.value,
      search: search.value || undefined,
      roleId: roleId.value || undefined
    }
    const res = await api.get('/users', { params })
    if (res.data) {
      users.value = res.data.items || []
      totalCount.value = res.data.totalCount || 0
    }
  } catch (error) {
    console.error('[API Error] fetchUsers failed:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur',
      detail: 'Impossible de charger la liste des utilisateurs.',
      life: 5000
    })
  } finally {
    loading.value = false
  }
}

// Watchers to trigger reload on filters
watch([search, roleId], () => {
  page.value = 1
  fetchUsers()
})

watch(page, () => {
  fetchUsers()
})

onMounted(() => {
  fetchUsers()
})

const getInitials = (user) => {
  const p = user.prenom ? user.prenom.charAt(0) : ''
  const n = user.nom ? user.nom.charAt(0) : ''
  return (p + n).toUpperCase() || 'U'
}

const getRoleColor = (roleName) => {
  if (!roleName) return 'bg-slate-50 text-slate-700 border-slate-100'
  const name = roleName.toLowerCase()
  if (name.includes('admin')) return 'bg-rose-50 text-rose-700 border-rose-100'
  if (name.includes('dentist')) return 'bg-sky-50 text-sky-700 border-sky-100'
  return 'bg-amber-50 text-amber-700 border-amber-100' // Secretaire / other
}
</script>

<template>
  <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm overflow-hidden transition-all duration-300">
    <!-- Panel Header -->
    <div 
      @click="isOpen = !isOpen" 
      class="px-6 py-4 bg-slate-50/50 hover:bg-slate-50 flex items-center justify-between cursor-pointer select-none border-b border-slate-100"
    >
      <div class="flex items-center gap-3">
        <div class="w-8 h-8 rounded-lg bg-sky-50 text-sky-600 flex items-center justify-center">
          <i class="pi pi-users text-sm"></i>
        </div>
        <div>
          <h3 class="text-sm font-extrabold text-slate-800">Gestion des Utilisateurs</h3>
          <p class="text-[11px] text-slate-500">Visualisez et gérez les comptes du cabinet.</p>
        </div>
      </div>
      <div class="flex items-center gap-3">
        <span class="px-2 py-0.5 rounded text-[10px] font-bold border bg-slate-100 text-slate-700 border-slate-200">
          {{ totalCount }} Comptes
        </span>
        <i class="pi text-slate-400 transition-transform duration-200 text-xs" :class="isOpen ? 'pi-chevron-up' : 'pi-chevron-down'"></i>
      </div>
    </div>

    <!-- Panel Body (Collapsible) -->
    <div v-show="isOpen" class="p-6 transition-all duration-300">
      <!-- Filters and Search Bar -->
      <div class="flex flex-col sm:flex-row sm:items-center gap-3 mb-4">
        <!-- Search input -->
        <div class="relative flex-1">
          <span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
            <i class="pi pi-search text-xs"></i>
          </span>
          <input 
            v-model="search"
            type="text" 
            placeholder="Rechercher par nom, email..."
            class="w-full pl-9 pr-3 py-2 border border-slate-200 rounded-lg text-xs font-semibold focus:border-sky-500 focus:ring-1 focus:ring-sky-500/50 outline-none text-slate-800 transition-all"
          />
        </div>

        <!-- Role Select dropdown -->
        <div class="w-full sm:w-48">
          <select 
            v-model="roleId"
            class="w-full px-3 py-2 border border-slate-200 rounded-lg text-xs font-semibold cursor-pointer outline-none focus:border-sky-500 focus:ring-1 focus:ring-sky-500/50 text-slate-800 transition-all"
          >
            <option :value="null">Tous les rôles</option>
            <option :value="1">Admin</option>
            <option :value="2">Dentiste</option>
            <option :value="3">Secrétaire</option>
          </select>
        </div>
      </div>

      <!-- Users Table -->
      <div class="border border-slate-150 rounded-lg overflow-hidden shadow-sm">
        <div v-if="loading" class="py-12 flex flex-col items-center justify-center text-slate-400 gap-2">
          <i class="pi pi-spin pi-spinner text-2xl text-sky-500"></i>
          <span class="text-[11px] font-semibold">Récupération de la liste...</span>
        </div>

        <div v-else-if="users.length === 0" class="py-12 flex flex-col items-center justify-center text-slate-400 gap-2">
          <i class="pi pi-user-minus text-2xl"></i>
          <span class="text-[11px] font-semibold">Aucun utilisateur trouvé</span>
        </div>

        <div v-else class="divide-y divide-slate-100">
          <!-- Table Header -->
          <div class="hidden md:flex items-center px-4 py-2.5 bg-slate-50 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
            <div class="w-2/5">Utilisateur</div>
            <div class="w-1/4">Email</div>
            <div class="w-1/5">Rôle</div>
            <div class="w-1/6 text-right">Statut</div>
          </div>

          <!-- Table Rows -->
          <div 
            v-for="user in users" 
            :key="user.id"
            class="flex flex-col md:flex-row md:items-center px-4 py-3.5 hover:bg-slate-50/50 transition-colors text-xs font-semibold text-slate-700 gap-2 md:gap-0"
          >
            <!-- User Avatar & Info -->
            <div class="w-full md:w-2/5 flex items-center gap-3">
              <div class="w-8 h-8 rounded-full bg-slate-100 text-slate-700 flex items-center justify-center text-[10px] font-bold border border-slate-200">
                {{ getInitials(user) }}
              </div>
              <div>
                <p class="font-extrabold text-slate-900 leading-tight">
                  {{ user.prenom }} {{ user.nom }}
                </p>
                <p class="text-[10px] text-slate-400">@{{ user.username }}</p>
              </div>
            </div>

            <!-- Email -->
            <div class="w-full md:w-1/4 text-slate-500 break-all md:break-normal">
              {{ user.email }}
            </div>

            <!-- Role badge -->
            <div class="w-full md:w-1/5 flex items-center">
              <span 
                class="px-2 py-0.5 text-[9px] font-bold rounded-full uppercase tracking-wider border"
                :class="getRoleColor(user.roleName)"
              >
                {{ user.roleName || 'Aucun' }}
              </span>
            </div>

            <!-- Status -->
            <div class="w-full md:w-1/6 flex items-center justify-between md:justify-end">
              <span 
                class="px-2 py-0.5 text-[9px] font-bold rounded-full uppercase tracking-wider border"
                :class="user.isActive 
                  ? 'bg-emerald-50 text-emerald-700 border-emerald-100' 
                  : 'bg-rose-50 text-rose-700 border-rose-100'"
              >
                {{ user.isActive ? 'Actif' : 'Inactif' }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Pagination Footer -->
      <div v-if="totalCount > pageSize" class="flex items-center justify-between border-t border-slate-100 pt-4 mt-2">
        <span class="text-[10px] font-semibold text-slate-400">
          Page {{ page }} sur {{ Math.ceil(totalCount / pageSize) }}
        </span>
        <div class="flex items-center gap-1.5">
          <button 
            :disabled="page === 1"
            @click="page--"
            class="p-1 px-2.5 bg-slate-100 hover:bg-slate-200 disabled:opacity-50 text-slate-700 rounded-md text-[10px] font-bold transition-all cursor-pointer"
          >
            Précédent
          </button>
          <button 
            :disabled="page >= Math.ceil(totalCount / pageSize)"
            @click="page++"
            class="p-1 px-2.5 bg-slate-100 hover:bg-slate-200 disabled:opacity-50 text-slate-700 rounded-md text-[10px] font-bold transition-all cursor-pointer"
          >
            Suivant
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
