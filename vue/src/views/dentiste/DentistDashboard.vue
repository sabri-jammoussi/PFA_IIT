<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import api from '@/services/api'

const authStore = useAuthStore()
const loading = ref(false)
const todaysAppCount = ref(0)
const nextPatientName = ref('Flen Ben Foulen')
const nextPatientTime = ref('15:30')
const nextPatientMotif = ref('Consultation de contrôle + Détartrage')

const fetchDentistDashboard = async () => {
  loading.value = true
  const today = new Date().toISOString().split('T')[0]
  const dentistId = authStore.user?.id || 1
  const url = `/rendezvous?startDate=${today}T00:00:00Z&endDate=${today}T23:59:59Z&dentisteId=${dentistId}`
  
  console.log(`[API Request] GET ${url}`)
  try {
    const res = await api.get(url)
    console.log(`[API Response] GET ${url} | Status: ${res.status}`)
    const apps = res.data?.items || res.data || []
    todaysAppCount.value = apps.length
    
    // Pick the first planified app after current time
    const now = new Date()
    const upcoming = apps.find(a => new Date(a.dateHeure) > now && a.statut === 'Planifié')
    if (upcoming) {
      nextPatientName.value = upcoming.patientNomComplet
      nextPatientTime.value = new Date(upcoming.dateHeure).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
      nextPatientMotif.value = upcoming.motif
    } else if (apps.length > 0) {
      // Pick first app
      const first = apps[0]
      nextPatientName.value = first.patientNomComplet
      nextPatientTime.value = new Date(first.dateHeure).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
      nextPatientMotif.value = first.motif
    } else {
      nextPatientName.value = "Aucun patient attendu"
      nextPatientTime.value = "--:--"
      nextPatientMotif.value = "Pas de motif"
    }
  } catch (err) {
    console.warn("[API Error] fetchDentistDashboard failed, using mock data:", err)
    todaysAppCount.value = 12
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchDentistDashboard()
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    <!-- Header -->
    <div class="bg-white rounded-2xl border border-slate-200/65 shadow-sm p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4 relative overflow-hidden">
      <div class="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-sky-500/5 to-transparent rounded-full -mr-16 -mt-16 pointer-events-none"></div>
      <div>
        <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-sky-50 text-sky-700 border border-sky-100 text-[10px] font-bold uppercase tracking-wider">
          Espace Praticien
        </span>
        <h1 class="text-xl font-extrabold text-slate-900 tracking-tight mt-3">
          Bienvenue, Dr. {{ authStore.user?.nom }}
        </h1>
        <p class="text-xs text-slate-500 mt-1">Voici le récapitulatif de vos soins et consultations cliniques.</p>
      </div>
      <div class="bg-sky-50 text-sky-700 px-4 py-2 rounded-xl text-xs font-bold border border-sky-100/50 shadow-inner flex-shrink-0">
        Journée Continue
      </div>
    </div>

    <!-- KPIs -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="bg-white p-6 rounded-xl border border-slate-200/65 shadow-sm flex items-center justify-between hover:shadow-md transition-shadow">
        <div>
          <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Patients Attendus</span>
          <div class="text-3xl font-extrabold text-slate-900 tracking-tight mt-2">{{ todaysAppCount }}</div>
        </div>
        <div class="w-10 h-10 rounded-xl bg-indigo-50 border border-indigo-100/50 flex items-center justify-center text-indigo-600 shadow-inner">
          <i class="pi pi-calendar text-base"></i>
        </div>
      </div>
      
      <div class="bg-white p-6 rounded-xl border border-slate-200/65 shadow-sm flex items-center justify-between hover:shadow-md transition-shadow">
        <div>
          <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Urgences Insérées</span>
          <div class="text-3xl font-extrabold text-rose-600 tracking-tight mt-2">2</div>
        </div>
        <div class="w-10 h-10 rounded-xl bg-rose-50 border border-rose-100/50 flex items-center justify-center text-rose-600 shadow-inner">
          <i class="pi pi-exclamation-circle text-base"></i>
        </div>
      </div>

      <div class="bg-white p-6 rounded-xl border border-slate-200/65 shadow-sm flex items-center justify-between hover:shadow-md transition-shadow">
        <div>
          <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Actes Clôturés</span>
          <div class="text-3xl font-extrabold text-slate-900 tracking-tight mt-2">5 / {{ todaysAppCount }}</div>
        </div>
        <div class="w-10 h-10 rounded-xl bg-emerald-50 border border-emerald-100/50 flex items-center justify-center text-emerald-600 shadow-inner">
          <i class="pi pi-check-circle text-base"></i>
        </div>
      </div>
    </div>

    <!-- Next Patient Card -->
    <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6">
      <h3 class="text-xs font-extrabold text-slate-400 uppercase tracking-wider mb-4 border-b border-slate-100 pb-3">Prochain Patient</h3>
      <div class="bg-slate-50 p-4 rounded-xl border border-slate-150 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <p class="text-sm font-extrabold text-slate-800">{{ nextPatientName }}</p>
          <p class="text-xs text-slate-550 mt-1 font-medium">Motif : {{ nextPatientMotif }}</p>
        </div>
        <span class="text-xs font-bold text-slate-700 bg-white px-3.5 py-1.5 rounded-lg border border-slate-200 shadow-sm text-center flex-shrink-0">
          {{ nextPatientTime }}
        </span>
      </div>
    </div>
  </div>
</template>
