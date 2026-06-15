<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useToast } from 'primevue/usetoast'
import api from '@/services/api'

const router = useRouter()
const authStore = useAuthStore()
const toast = useToast()

const loading = ref(false)
const appointments = ref([])
const patients = ref([])
const searchTerm = ref('')
const selectedDentistId = computed(() => authStore.user?.id || 1)

// Metrics
const totalAppointmentsCount = ref(0)
const completedAppointmentsCount = ref(0)
const totalPatientsCount = ref(0)
const totalRevenue = ref(0)

const remainingAppointmentsCount = computed(() => {
  return appointments.value.filter(app => app.statut === 'Planifié' || app.statut === 'En Attente').length
})

const fetchDashboardData = async () => {
  loading.value = true
  try {
    // 1. Fetch today's appointments
    const today = new Date().toISOString().split('T')[0]
    let appUrl = `/rendezvous?startDate=${today}T00:00:00Z&endDate=${today}T23:59:59Z`

    // If user is a dentist, filter appointments for them specifically
    if (authStore.isDentist) {
      appUrl += `&dentisteId=${selectedDentistId.value}`
    }

    console.log(`[API Request] GET ${appUrl}`)
    const appResponse = await api.get(appUrl)
    console.log(`[API Response] GET ${appUrl} | Status: ${appResponse.status}`, appResponse.data)
    appointments.value = appResponse.data?.items || appResponse.data || []

    // Sort appointments chronologically by time
    appointments.value.sort((a, b) => new Date(a.dateHeure) - new Date(b.dateHeure))

    totalAppointmentsCount.value = appointments.value.length
    completedAppointmentsCount.value = appointments.value.filter(a => a.statut === 'Confirmé' || a.statut === 'Terminé').length

    // 2. Fetch total patients
    console.log(`[API Request] GET /patients?pageSize=5`)
    const patientResponse = await api.get('/patients?pageSize=5')
    console.log(`[API Response] GET /patients?pageSize=5 | Status: ${patientResponse.status}`, patientResponse.data)
    patients.value = patientResponse.data?.items || patientResponse.data || []
    totalPatientsCount.value = patientResponse.data?.totalCount || patients.value.length

    // 3. Fetch revenue from factures (sum of montantPaye)
    console.log(`[API Request] GET /factures`)
    const facturesResponse = await api.get('/factures')
    console.log(`[API Response] GET /factures | Status: ${facturesResponse.status}`, facturesResponse.data)
    const facturesList = facturesResponse.data?.items || facturesResponse.data || []
    totalRevenue.value = facturesList.reduce((sum, f) => sum + (f.montantPaye || 0), 0)
  } catch (error) {
    console.error('[API Error] fetchDashboardData failed:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur de chargement',
      detail: 'Impossible de récupérer les données du tableau de bord.',
      life: 5000
    })
  } finally {
    loading.value = false
  }
}

const handleSearch = () => {
  if (searchTerm.value.trim()) {
    const routeName = authStore.isDentist ? 'DentistPatients' : 'SecretaireAdmissions'
    router.push({ name: routeName, query: { search: searchTerm.value } })
  }
}

const viewPatient = (id) => {
  const routeName = (authStore.isDentist || authStore.isSecretary) ? 'DentistPatientProfile' : 'home'
  router.push({ name: routeName, params: { id } })
}

const formatTime = (dateStr) => {
  const date = new Date(dateStr)
  return date.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
}

const updateAppointmentStatus = async (appId, status) => {
  try {
    const appointment = appointments.value.find(a => a.id === appId)
    if (appointment) {
      appointment.statut = status
      toast.add({
        severity: 'success',
        summary: 'Rendez-vous mis à jour',
        detail: `Le statut a été changé en '${status}'.`,
        life: 3000
      })

      console.log(`[API Request] PUT /rendezvous/${appId} | New Status: ${status}`)
      const res = await api.put(`/rendezvous/${appId}`, {
        ...appointment,
        statut: status
      })
      console.log(`[API Response] PUT /rendezvous/${appId} | Status: ${res.status}`)
    }
  } catch (error) {
    console.error('[API Error] updateAppointmentStatus failed:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur de mise à jour',
      detail: 'Impossible de mettre à jour le statut du rendez-vous.',
      life: 5000
    })
  }
}

onMounted(() => {
  fetchDashboardData()
})
</script>


<template>
  <div class="space-y-8 animate-fade-in font-sans">
    
    <!-- Welcome Header Panel -->
    <div class="bg-white rounded-2xl border border-slate-200/65 shadow-sm p-6 flex flex-col md:flex-row md:items-center justify-between gap-6 relative overflow-hidden">
      <div class="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-sky-500/5 to-transparent rounded-full -mr-16 -mt-16 pointer-events-none"></div>
      
      <div>
        <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-100 text-[10px] font-bold uppercase tracking-wider">
          <span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse"></span>
          Cabinet Connecté
        </span>
        <h1 class="text-2xl font-extrabold text-slate-900 tracking-tight mt-3">
          Bonjour, {{ authStore.fullName }}
        </h1>
        <p class="text-xs text-slate-500 mt-1.5 leading-relaxed">
          Voici le récapitulatif de l'activité clinique pour aujourd'hui, le {{ new Date().toLocaleDateString('fr-FR', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }) }}.
        </p>
      </div>

      <!-- Quick Action CTA Search -->
      <div class="flex items-center gap-3 w-full md:w-auto max-w-sm flex-shrink-0 relative">
        <div class="relative w-full">
          <span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
            <i class="pi pi-search text-xs"></i>
          </span>
          <input 
            v-model="searchTerm"
            @keyup.enter="handleSearch"
            type="text" 
            placeholder="Rechercher un dossier patient..." 
            class="w-full py-2.5 pl-9 pr-4 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl outline-none transition-all duration-200 text-slate-800 placeholder-slate-400"
          />
        </div>
        <button 
          @click="handleSearch"
          class="px-4 py-2.5 bg-slate-950 hover:bg-slate-800 text-white text-xs font-semibold rounded-xl transition-all duration-200 cursor-pointer flex-shrink-0"
        >
          Rechercher
        </button>
      </div>
    </div>

    <!-- 4 Stats Cards Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
      
      <!-- Card 1: Consultations Restantes -->
      <div class="bg-white p-6 rounded-xl border border-slate-200/65 shadow-sm flex flex-col justify-between hover:shadow-md transition-shadow">
        <div class="flex justify-between items-start">
          <div>
            <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">RDV Restants Aujourd'hui</span>
            <h3 class="text-2xl font-extrabold text-slate-900 tracking-tight mt-2.5">
              {{ remainingAppointmentsCount }}
            </h3>
          </div>
          <div class="w-10 h-10 rounded-xl bg-sky-50 border border-sky-100/50 flex items-center justify-center text-sky-600 shadow-inner">
            <i class="pi pi-clock text-base"></i>
          </div>
        </div>
        <div class="mt-4 pt-3 border-t border-slate-100 flex items-center text-[10px] text-slate-500 font-bold uppercase gap-1.5">
          <span>Sur {{ totalAppointmentsCount }} visites prévues</span>
        </div>
      </div>

      <!-- Card 2: Patients Actifs -->
      <div class="bg-white p-6 rounded-xl border border-slate-200/65 shadow-sm flex flex-col justify-between hover:shadow-md transition-shadow">
        <div class="flex justify-between items-start">
          <div>
            <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Base Patients</span>
            <h3 class="text-2xl font-extrabold text-slate-900 tracking-tight mt-2.5">
              {{ totalPatientsCount }}
            </h3>
          </div>
          <div class="w-10 h-10 rounded-xl bg-indigo-50 border border-indigo-100/50 flex items-center justify-center text-indigo-600 shadow-inner">
            <i class="pi pi-users text-base"></i>
          </div>
        </div>
        <div class="mt-4 pt-3 border-t border-slate-100 flex items-center text-[10px] text-emerald-600 font-bold uppercase gap-1">
          <i class="pi pi-arrow-up-right"></i>
          <span>+12 nouveaux ce mois</span>
        </div>
      </div>

      <!-- Card 3: Taux de Complétion -->
      <div class="bg-white p-6 rounded-xl border border-slate-200/65 shadow-sm flex flex-col justify-between hover:shadow-md transition-shadow">
        <div class="flex justify-between items-start">
          <div>
            <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Taux de Complétion</span>
            <h3 class="text-2xl font-extrabold text-slate-900 tracking-tight mt-2.5">
              {{ totalAppointmentsCount ? Math.round((completedAppointmentsCount / totalAppointmentsCount) * 100) : 0 }}%
            </h3>
          </div>
          <div class="w-10 h-10 rounded-xl bg-emerald-50 border border-emerald-100/50 flex items-center justify-center text-emerald-600 shadow-inner">
            <i class="pi pi-check-circle text-base"></i>
          </div>
        </div>
        <div class="mt-4 pt-3 border-t border-slate-100 flex items-center text-[10px] text-slate-500 font-bold uppercase gap-1.5">
          <span>{{ completedAppointmentsCount }} actes réalisés aujourd'hui</span>
        </div>
      </div>

      <!-- Card 4: Recettes Honoraires -->
      <div class="bg-white p-6 rounded-xl border border-slate-200/65 shadow-sm flex flex-col justify-between hover:shadow-md transition-shadow">
        <div class="flex justify-between items-start">
          <div>
            <span class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Recettes Estimées</span>
            <h3 class="text-2xl font-extrabold text-slate-900 tracking-tight mt-2.5">
              {{ totalRevenue.toFixed(2) }} DT
            </h3>
          </div>
          <div class="w-10 h-10 rounded-xl bg-amber-50 border border-amber-100/50 flex items-center justify-center text-amber-600 shadow-inner">
            <i class="pi pi-wallet text-base"></i>
          </div>
        </div>
        <div class="mt-4 pt-3 border-t border-slate-100 flex items-center text-[10px] text-slate-500 font-bold uppercase gap-1.5">
          <span>Règlements encaissés ce jour</span>
        </div>
      </div>
      
    </div>

    <!-- Layout Grid: Left today's queue (65%) | Right active list patients & alerts (35%) -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      
      <!-- LEFT: Today's queue table grid (Choice B) -->
      <div class="lg:col-span-2 bg-white rounded-xl border border-slate-200/65 shadow-sm p-6 flex flex-col justify-between">
        <div>
          <div class="flex justify-between items-center mb-6">
            <div>
              <h2 class="text-base font-extrabold text-slate-900 tracking-tight">File des Rendez-vous du jour</h2>
              <p class="text-[11px] text-slate-400 font-medium mt-0.5">Cliquez sur un patient pour ouvrir son dossier médical.</p>
            </div>
            <router-link 
              :to="{name: authStore.isSecretary ? 'SecretaireAgenda' : 'home'}"
              class="text-xs text-sky-600 hover:text-sky-700 font-bold flex items-center gap-1.5 cursor-pointer"
            >
              <span>Voir l'agenda complet</span>
              <i class="pi pi-arrow-right text-[10px]"></i>
            </router-link>
          </div>

          <!-- Table Content -->
          <div v-if="loading" class="py-12 flex flex-col items-center justify-center text-slate-400 gap-2">
            <i class="pi pi-spin pi-spinner text-2xl text-sky-500"></i>
            <span class="text-xs font-semibold">Récupération de l'agenda...</span>
          </div>

          <div v-else-if="appointments.length === 0" class="py-12 text-center text-slate-400 text-xs font-medium">
            Aucun rendez-vous planifié aujourd'hui.
          </div>

          <div v-else class="space-y-2.5">
            <!-- Custom Styled Rows -->
            <div 
              v-for="app in appointments"
              :key="app.id"
              class="flex flex-col sm:flex-row sm:items-center justify-between p-4 bg-slate-50/50 hover:bg-slate-50 border border-slate-100 rounded-xl transition-all duration-200 gap-4"
            >
              <!-- Time & Patient Info -->
              <div class="flex items-center gap-4 min-w-0">
                <div class="px-3 py-1.5 bg-slate-200/70 rounded-lg text-slate-800 text-xs font-extrabold tracking-wide flex-shrink-0 text-center">
                  {{ formatTime(app.dateHeure) }}
                </div>
                <div class="min-w-0">
                  <button 
                    @click="viewPatient(app.patientId)"
                    class="text-sm font-bold text-slate-800 hover:text-sky-600 text-left transition-colors truncate block w-full focus:outline-none cursor-pointer"
                  >
                    {{ app.patientNomComplet }}
                  </button>
                  <div class="flex items-center gap-2 mt-1">
                    <span class="text-xs text-slate-500 font-medium truncate">{{ app.motif }}</span>
                    <span v-if="app.note" class="text-[10px] text-indigo-500 font-bold bg-indigo-50 px-1.5 py-0.5 rounded">&bull; Note active</span>
                  </div>
                </div>
              </div>

              <!-- Status Badge & Controls -->
              <div class="flex items-center justify-between sm:justify-end gap-3 flex-shrink-0">
                <!-- Status -->
                <span 
                  class="px-2.5 py-1 text-[10px] font-bold rounded-full uppercase tracking-wider border"
                  :class="[
                    app.statut === 'Terminé' 
                      ? 'bg-emerald-50 text-emerald-700 border-emerald-100' 
                      : app.statut === 'Planifié' 
                        ? 'bg-sky-50 text-sky-700 border-sky-100' 
                        : 'bg-amber-50 text-amber-700 border-amber-100'
                  ]"
                >
                  {{ app.statut }}
                </span>

                <!-- Quick Action Buttons -->
                <div class="flex items-center gap-1.5">
                  <button 
                    v-if="app.statut === 'Planifié'"
                    @click="updateAppointmentStatus(app.id, 'Terminé')"
                    title="Marquer comme complété"
                    class="w-7 h-7 bg-white hover:bg-emerald-50 text-slate-500 hover:text-emerald-600 rounded-lg border border-slate-200 flex items-center justify-center transition-all cursor-pointer shadow-sm hover:border-emerald-200"
                  >
                    <i class="pi pi-check text-[10px] font-bold"></i>
                  </button>
                  <button 
                    @click="viewPatient(app.patientId)"
                    title="Ouvrir dossier médical"
                    class="w-7 h-7 bg-white hover:bg-slate-100 text-slate-500 hover:text-slate-800 rounded-lg border border-slate-200 flex items-center justify-center transition-all cursor-pointer shadow-sm"
                  >
                    <i class="pi pi-folder-open text-[10px] font-bold"></i>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="mt-6 pt-4 border-t border-slate-100 text-center">
          <p class="text-[10px] text-slate-400 font-medium">Les rendez-vous terminés alimentent directement les fiches patients et les factures associées.</p>
        </div>
      </div>

      <!-- RIGHT PANEL: Recent Patients and Alerts (Choice B) -->
      <div class="space-y-6">
        
        <!-- Quick Shortcuts -->
        <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6">
          <h3 class="text-sm font-extrabold text-slate-900 tracking-tight mb-4">Actions Immédiates</h3>
          <div class="grid grid-cols-2 gap-3">
            <router-link
              :to="{ name: authStore.isSecretary ? 'SecretaireAgenda' : 'home', query: { new: 'true' } }"
              class="p-4 bg-slate-50 hover:bg-sky-50/20 border border-slate-100 hover:border-sky-200 text-center rounded-xl transition-all group cursor-pointer block"
            >
              <div class="w-9 h-9 rounded-lg bg-sky-50 text-sky-600 flex items-center justify-center mx-auto mb-2.5 shadow-sm group-hover:scale-105 transition-transform">
                <i class="pi pi-calendar-plus text-sm"></i>
              </div>
              <span class="text-xs font-bold text-slate-800 block">Nouveau RDV</span>
            </router-link>

            <router-link
              :to="{ name: authStore.isDentist ? 'DentistPatients' : (authStore.isSecretary ? 'SecretaireAdmissions' : 'home'), query: { add: 'true' } }"
              class="p-4 bg-slate-50 hover:bg-indigo-50/20 border border-slate-100 hover:border-indigo-200 text-center rounded-xl transition-all group cursor-pointer block"
            >
              <div class="w-9 h-9 rounded-lg bg-indigo-50 text-indigo-600 flex items-center justify-center mx-auto mb-2.5 shadow-sm group-hover:scale-105 transition-transform">
                <i class="pi pi-user-plus text-sm"></i>
              </div>
              <span class="text-xs font-bold text-slate-800 block">Créer Patient</span>
            </router-link>
          </div>
        </div>

        <!-- Recent active patients -->
        <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6">
          <h3 class="text-sm font-extrabold text-slate-900 tracking-tight mb-4">Patients récents</h3>
          <div class="space-y-3">
            <div 
              v-for="pat in patients.slice(0, 4)" 
              :key="pat.id"
              class="flex items-center justify-between p-3 bg-slate-50/40 hover:bg-slate-50 border border-slate-100 rounded-lg transition-colors"
            >
              <div class="min-w-0">
                <p class="text-xs font-bold text-slate-800 truncate">{{ pat.prenom }} {{ pat.nom }}</p>
                <p class="text-[10px] text-slate-400 font-semibold mt-0.5">{{ pat.telephone }}</p>
              </div>
              <button 
                @click="viewPatient(pat.id)"
                class="px-2.5 py-1 bg-white hover:bg-slate-100 text-slate-600 hover:text-slate-900 border border-slate-200 rounded-lg text-[10px] font-bold transition-all shadow-sm cursor-pointer"
              >
                Ouvrir
              </button>
            </div>
          </div>
          <router-link 
            :to="{name: authStore.isDentist ? 'DentistPatients' : (authStore.isSecretary ? 'SecretaireAdmissions' : 'home')}" 
            class="text-[10px] text-sky-600 hover:text-sky-700 font-bold block text-center mt-4 uppercase tracking-wider cursor-pointer"
          >
            Afficher tous les patients
          </router-link>
        </div>

      </div>

    </div>

  </div>
</template>
