<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import api from '@/services/api'

const authStore = useAuthStore()
const loading = ref(false)
const auditLogsCount = ref(0)
const activeUsersCount = ref(4)

const fetchAdminData = async () => {
  loading.value = true
  console.log('[API Request] GET /users')
  try {
    const res = await api.get('/users')
    console.log(`[API Response] GET /users | Status: ${res.status}`)
    const users = res.data?.items || res.data || []
    activeUsersCount.value = users.filter(u => u.isActive).length
  } catch (error) {
    console.warn("[API Error] fetchAdminData failed. Using mock stats:", error)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchAdminData()
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    <!-- Header -->
    <div class="bg-white rounded-2xl border border-slate-200/65 shadow-sm p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-6 relative overflow-hidden">
      <div class="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-sky-500/5 to-transparent rounded-full -mr-16 -mt-16 pointer-events-none"></div>
      <div>
        <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-slate-900 text-white border border-slate-800 text-[10px] font-bold uppercase tracking-wider">
          Espace Administrateur
        </span>
        <h1 class="text-xl font-extrabold text-slate-900 tracking-tight mt-3">
          Console d'Administration
        </h1>
        <p class="text-xs text-slate-500 mt-1">Supervision de la sécurité, gestion du personnel et configuration des tarifs des actes médicaux.</p>
      </div>
      <div class="bg-slate-900 text-white px-4 py-2 rounded-xl text-xs font-bold shadow-md flex-shrink-0">
        Console Active
      </div>
    </div>

    <!-- KPI Cards -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <!-- Active staff count -->
      <div class="bg-white p-6 rounded-xl border border-slate-200/65 shadow-sm flex items-center justify-between hover:shadow-md transition-shadow">
        <div>
          <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Praticiens & Staff Actifs</span>
          <div class="text-3xl font-extrabold text-slate-900 tracking-tight mt-2">{{ activeUsersCount }}</div>
        </div>
        <div class="w-10 h-10 rounded-xl bg-sky-50 border border-sky-100/50 flex items-center justify-center text-sky-600 shadow-inner">
          <i class="pi pi-users text-base"></i>
        </div>
      </div>
      
      <!-- Catalog acts count -->
      <div class="bg-white p-6 rounded-xl border border-slate-200/65 shadow-sm flex items-center justify-between hover:shadow-md transition-shadow">
        <div>
          <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Actes Cliniques Catalogués</span>
          <div class="text-3xl font-extrabold text-slate-900 tracking-tight mt-2">8</div>
        </div>
        <div class="w-10 h-10 rounded-xl bg-indigo-50 border border-indigo-100/50 flex items-center justify-center text-indigo-600 shadow-inner">
          <i class="pi pi-book text-base"></i>
        </div>
      </div>

      <!-- Security audits -->
      <div class="bg-white p-6 rounded-xl border border-slate-200/65 shadow-sm flex items-center justify-between hover:shadow-md transition-shadow">
        <div>
          <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Alertes Audit Système</span>
          <div class="text-3xl font-extrabold text-emerald-600 tracking-tight mt-2">0</div>
        </div>
        <div class="w-10 h-10 rounded-xl bg-emerald-50 border border-emerald-100/50 flex items-center justify-center text-emerald-600 shadow-inner">
          <i class="pi pi-verified text-base"></i>
        </div>
      </div>
    </div>

    <!-- Administrative Quick Links -->
    <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6">
      <h3 class="text-xs font-extrabold text-slate-800 uppercase tracking-wider mb-4 border-b border-slate-100 pb-3">Raccourcis de Gestion</h3>
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <!-- Medical acts tariff configuration -->
        <router-link 
          :to="{ name: 'medical-acts' }" 
          class="p-4 bg-slate-50 hover:bg-sky-50/20 border border-slate-100 hover:border-sky-200 rounded-xl transition-all flex items-center gap-3 cursor-pointer"
        >
          <div class="w-9 h-9 rounded-lg bg-sky-50 text-sky-600 flex items-center justify-center flex-shrink-0">
            <i class="pi pi-pencil text-sm"></i>
          </div>
          <div>
            <h4 class="text-xs font-bold text-slate-800">Tarifs & Actes</h4>
            <p class="text-[10px] text-slate-400 mt-0.5">Modifier la nomenclature de base des soins.</p>
          </div>
        </router-link>

        <!-- Profile configuration -->
        <router-link 
          :to="{ name: 'settings' }" 
          class="p-4 bg-slate-50 hover:bg-slate-100 border border-slate-100 hover:border-slate-300 rounded-xl transition-all flex items-center gap-3 cursor-pointer"
        >
          <div class="w-9 h-9 rounded-lg bg-slate-100 text-slate-650 flex items-center justify-center flex-shrink-0">
            <i class="pi pi-lock text-sm"></i>
          </div>
          <div>
            <h4 class="text-xs font-bold text-slate-800">Sécurité & Clés JWT</h4>
            <p class="text-[10px] text-slate-400 mt-0.5">Vérifier les durées de sessions et mots de passe.</p>
          </div>
        </router-link>
      </div>
    </div>
  </div>
</template>
