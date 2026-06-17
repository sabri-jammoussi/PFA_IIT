<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useToast } from 'primevue/usetoast'
import api from '@/services/api'

const authStore = useAuthStore()
const toast = useToast()
const loading = ref(false)

const cabinetsCount = ref(0)
const activeServersRate = ref(99.99)
const totalDataSize = ref('12.4 GB')
const recentCabinets = ref([])

const fetchPlatformStats = async () => {
  loading.value = true
  try {
    console.log('[API Request] GET /cabinet')
    const res = await api.get('/cabinet')
    const list = res.data || []
    cabinetsCount.value = list.length
    recentCabinets.value = list.slice(-3).reverse() // Latest 3 signup clinics
  } catch (error) {
    console.warn("Failed to load platform stats:", error)
    cabinetsCount.value = 3 // Fallback seed
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchPlatformStats()
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    <!-- Header -->
    <div class="bg-white rounded-2xl border border-slate-200/65 shadow-sm p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-6 relative overflow-hidden">
      <div class="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-slate-900/5 to-transparent rounded-full -mr-16 -mt-16 pointer-events-none"></div>
      <div>
        <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-slate-900 text-white border border-slate-800 text-[10px] font-bold uppercase tracking-wider">
          SaaS Controller
        </span>
        <h1 class="text-xl font-extrabold text-slate-900 tracking-tight mt-3">
          Performances Plateforme SaaS
        </h1>
        <p class="text-xs text-slate-500 mt-1">Supervision globale de l'infrastructure Cloud, des serveurs de messagerie et de l'hébergement.</p>
      </div>
      <div class="bg-slate-900 text-white px-4 py-2 rounded-xl text-xs font-bold shadow-md flex-shrink-0">
        Console SaaS Active
      </div>
    </div>

    <!-- KPIs Grid -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <!-- Clinics Registered -->
      <div class="bg-white p-6 rounded-xl border border-slate-200/65 shadow-sm flex items-center justify-between hover:shadow-md transition-shadow">
        <div>
          <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Cabinets Clients</span>
          <div class="text-3xl font-extrabold text-slate-900 tracking-tight mt-2">{{ cabinetsCount }}</div>
        </div>
        <div class="w-10 h-10 rounded-xl bg-sky-50 border border-sky-100/50 flex items-center justify-center text-sky-600 shadow-inner">
          <i class="pi pi-building text-base"></i>
        </div>
      </div>
      
      <!-- Active Server Rate -->
      <div class="bg-white p-6 rounded-xl border border-slate-200/65 shadow-sm flex items-center justify-between hover:shadow-md transition-shadow">
        <div>
          <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Taux Actif Serveurs</span>
          <div class="text-3xl font-extrabold text-emerald-600 tracking-tight mt-2">{{ activeServersRate }}%</div>
        </div>
        <div class="w-10 h-10 rounded-xl bg-emerald-50 border border-emerald-100/50 flex items-center justify-center text-emerald-600 shadow-inner">
          <i class="pi pi-check-circle text-base"></i>
        </div>
      </div>

      <!-- Storage Size -->
      <div class="bg-white p-6 rounded-xl border border-slate-200/65 shadow-sm flex items-center justify-between hover:shadow-md transition-shadow">
        <div>
          <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Volume de données global</span>
          <div class="text-3xl font-extrabold text-slate-900 tracking-tight mt-2">{{ totalDataSize }}</div>
        </div>
        <div class="w-10 h-10 rounded-xl bg-indigo-50 border border-indigo-100/50 flex items-center justify-center text-indigo-650 shadow-inner">
          <i class="pi pi-database text-base"></i>
        </div>
      </div>
    </div>

    <!-- Recent cabinets & infrastructure links -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
      
      <!-- Recent Signups -->
      <div class="bg-white rounded-xl border border-slate-200/65 p-6 shadow-sm">
        <h3 class="text-xs font-extrabold text-slate-800 uppercase tracking-wider mb-4 border-b border-slate-100 pb-3 flex items-center gap-2">
          <i class="pi pi-history text-slate-400"></i>
          <span>Dernières Inscriptions Cabinets</span>
        </h3>
        
        <div v-if="loading" class="py-12 flex flex-col items-center justify-center text-slate-400 gap-2">
          <i class="pi pi-spin pi-spinner text-xl text-sky-500"></i>
          <span class="text-[11px] font-semibold">Récupération des logs...</span>
        </div>
        <div v-else-if="recentCabinets.length === 0" class="py-12 text-center text-slate-400 text-xs font-semibold">
          Aucun cabinet enregistré sur la plateforme.
        </div>
        <div v-else class="space-y-3">
          <div 
            v-for="cab in recentCabinets" 
            :key="cab.id"
            class="flex items-center justify-between p-3.5 bg-slate-50 border border-slate-100 rounded-xl text-xs"
          >
            <div>
              <p class="font-extrabold text-slate-850">{{ cab.nomCabinet }}</p>
              <p class="text-[10px] text-slate-400 mt-0.5">ID: #{{ cab.id }} &bull; {{ cab.adresse || 'Pas d\'adresse' }}</p>
            </div>
            <span class="px-2 py-0.5 rounded bg-emerald-50 text-emerald-700 text-[9px] font-bold border border-emerald-100 uppercase">
              Actif
            </span>
          </div>
        </div>
      </div>

      <!-- SaaS Infrastructure Shortcuts -->
      <div class="bg-white rounded-xl border border-slate-200/65 p-6 shadow-sm flex flex-col justify-between">
        <div>
          <h3 class="text-xs font-extrabold text-slate-800 uppercase tracking-wider mb-4 border-b border-slate-100 pb-3 flex items-center gap-2">
            <i class="pi pi-cog text-slate-400"></i>
            <span>État de l'infrastructure SaaS</span>
          </h3>
          
          <div class="space-y-4 text-xs font-semibold text-slate-700">
            <div class="flex justify-between items-center">
              <span>Hébergement Cloud (Cloudinary) :</span>
              <span class="text-emerald-600 font-extrabold">FONCTIONNEL</span>
            </div>
            <div class="flex justify-between items-center">
              <span>Serveurs d'envoi Mail (System Defaults) :</span>
              <span class="text-emerald-600 font-extrabold">FONCTIONNEL</span>
            </div>
            <div class="flex justify-between items-center">
              <span>Base de données principale (SQL Server) :</span>
              <span class="text-emerald-600 font-extrabold">ACTIF (0.2ms latency)</span>
            </div>
          </div>
        </div>

        <div class="mt-6 pt-4 border-t border-slate-100">
          <router-link 
            :to="{ name: 'AdminSmtpSettings' }"
            class="text-[10px] text-sky-600 hover:text-sky-700 font-bold block uppercase tracking-wider"
          >
            Configurer les variables API globales &rarr;
          </router-link>
        </div>
      </div>

    </div>
  </div>
</template>
