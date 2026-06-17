<script setup>
import { ref, onMounted } from 'vue'
import { useToast } from 'primevue/usetoast'
import api from '@/services/api'

const toast = useToast()
const loading = ref(false)
const processing = ref(null) // ID of cabinet currently being processed
const cabinets = ref([])

const fetchCabinets = async () => {
  loading.value = true
  console.log('[API Request] GET /cabinet')
  try {
    const res = await api.get('/cabinet')
    cabinets.value = res.data || []
  } catch (error) {
    console.error("Failed to load cabinets list:", error)
    toast.add({
      severity: 'error',
      summary: 'Erreur',
      detail: 'Impossible de charger la liste des cabinets clients.',
      life: 5000
    })
  } finally {
    loading.value = false
  }
}

const toggleSubscription = async (cabinet) => {
  processing.value = cabinet.id
  const targetStatus = !cabinet.isSubscriptionActive
  
  console.log(`[API Request] PUT /cabinet/${cabinet.id}/subscription | Status: ${targetStatus}`)
  try {
    await api.put(`/cabinet/${cabinet.id}/subscription`, { isActive: targetStatus })
    
    cabinet.isSubscriptionActive = targetStatus
    toast.add({
      severity: 'success',
      summary: targetStatus ? 'Licence activée' : 'Licence suspendue',
      detail: `La souscription de ${cabinet.nomCabinet} a été mise à jour.`,
      life: 3000
    })
  } catch (error) {
    console.error("Failed to update subscription status:", error)
    toast.add({
      severity: 'error',
      summary: 'Erreur de mise à jour',
      detail: 'Impossible de modifier la licence du cabinet.',
      life: 4000
    })
  } finally {
    processing.value = null
  }
}

onMounted(() => {
  fetchCabinets()
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    
    <!-- Header -->
    <div class="bg-white rounded-2xl border border-slate-200/65 shadow-sm p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4 relative overflow-hidden">
      <div class="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-slate-900/5 to-transparent rounded-full -mr-16 -mt-16 pointer-events-none"></div>
      <div class="flex items-center gap-4">
        <div class="w-12 h-12 rounded-xl bg-slate-900 text-white flex items-center justify-center flex-shrink-0 shadow-sm">
          <i class="pi pi-building text-xl"></i>
        </div>
        <div>
          <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-slate-900 text-white text-[10px] font-bold uppercase tracking-wider">
            SaaS Controller
          </span>
          <h1 class="text-xl font-extrabold text-slate-900 tracking-tight mt-1.5">
            Gestion des Cabinets & Licences
          </h1>
          <p class="text-xs text-slate-500 mt-0.5">
            Gérez les autorisations d'accès, activez de nouvelles cliniques ou suspendez les abonnements impayés.
          </p>
        </div>
      </div>
    </div>

    <!-- Cabinets Table -->
    <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm overflow-hidden">
      <div class="px-6 py-4 bg-slate-50/50 border-b border-slate-100 flex justify-between items-center">
        <h3 class="text-xs font-extrabold text-slate-800 uppercase tracking-wider">Cabinets Cliniques Clientèle ({{ cabinets.length }})</h3>
        <button 
          @click="fetchCabinets"
          class="w-7 h-7 rounded-lg border border-slate-200 hover:bg-slate-100 flex items-center justify-center text-slate-500 transition-colors cursor-pointer"
        >
          <i class="pi pi-refresh text-xs" :class="{ 'pi-spin': loading }"></i>
        </button>
      </div>

      <div v-if="loading" class="py-20 flex flex-col items-center justify-center text-slate-400 gap-2">
        <i class="pi pi-spin pi-spinner text-3xl text-sky-500"></i>
        <span class="text-xs font-semibold">Chargement des cabinets...</span>
      </div>

      <div v-else-if="cabinets.length === 0" class="py-20 text-center text-slate-400 text-xs font-semibold">
        Aucun cabinet enregistré sur la plateforme.
      </div>

      <div v-else class="divide-y divide-slate-100">
        <!-- Header -->
        <div class="hidden md:flex items-center px-6 py-3 bg-slate-50/50 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
          <div class="w-1/12">ID</div>
          <div class="w-1/4">Cabinet</div>
          <div class="w-1/4">Adresse</div>
          <div class="w-1/6">Téléphone</div>
          <div class="w-1/8 text-center">État Licence</div>
          <div class="w-1/12 text-right">Action</div>
        </div>

        <!-- Rows -->
        <div 
          v-for="cab in cabinets" 
          :key="cab.id"
          class="flex flex-col md:flex-row md:items-center px-6 py-4 hover:bg-slate-50/50 transition-colors text-xs font-semibold text-slate-700 gap-2 md:gap-0"
        >
          <div class="w-full md:w-1/12 font-bold text-slate-400">
            #{{ cab.id }}
          </div>
          <div class="w-full md:w-1/4 font-extrabold text-slate-900">
            {{ cab.nomCabinet }}
          </div>
          <div class="w-full md:w-1/4 text-slate-550">
            {{ cab.adresse || '—' }}
          </div>
          <div class="w-full md:w-1/6 text-slate-500">
            {{ cab.telephoneCorporate || '—' }}
          </div>
          <div class="w-full md:w-1/8 text-center">
            <span 
              class="px-2.5 py-1 text-[9px] font-bold rounded-full uppercase tracking-wider border"
              :class="[
                cab.isSubscriptionActive 
                  ? 'bg-emerald-50 text-emerald-700 border-emerald-100' 
                  : 'bg-rose-50 text-rose-700 border-rose-100'
              ]"
            >
              {{ cab.isSubscriptionActive ? 'Actif' : 'Suspendu' }}
            </span>
          </div>
          <div class="w-full md:w-1/12 flex justify-end">
            <button 
              @click="toggleSubscription(cab)"
              :disabled="processing === cab.id"
              class="px-2.5 py-1.5 text-[10px] font-bold rounded-lg border transition-all cursor-pointer shadow-sm flex items-center gap-1"
              :class="[
                cab.isSubscriptionActive
                  ? 'border-rose-200 hover:bg-rose-50 text-rose-600'
                  : 'bg-slate-950 hover:bg-slate-800 text-white'
              ]"
            >
              <i v-if="processing === cab.id" class="pi pi-spin pi-spinner text-[9px]"></i>
              <span v-else>{{ cab.isSubscriptionActive ? 'Suspendre' : 'Activer' }}</span>
            </button>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>
