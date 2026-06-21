<script setup>
import ConfirmationDialog from '@/components/ConfirmationDialog.vue'
import api from '@/services/api'
import { useToast } from 'primevue/usetoast'
import { computed, onMounted, onUnmounted, ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import AppointmentAddDialog from './AppointmentAddDialog.vue'

const route = useRoute()
const toast = useToast()

const loading = ref(false)
const appointments = ref([])
const patients = ref([])
const dentists = ref([])

const currentTime = ref(new Date())
let timeInterval = null
const dentistOptions = computed(() => dentists.value.map(d => ({
  id: d.id,
  label: `Dr. ${d.prenom} ${d.nom} (${d.spec})`
})))

const selectedDate = ref(new Date().toISOString().split('T')[0])
const selectedDentist = ref(1) // Doctor Martin by default

const fetchDentists = async () => {
  try {
    const res = await api.get('/users/dentists')
    console.log("dataaaaaaaaaaaaaaa dentiste",res)
    const items = res.data || []
    dentists.value = items.map(u => ({
      id: u.id,
      nom: u.nom,
      prenom: u.prenom,
      spec: u.roleName === 'Dentiste' ? 'Chirurgien-Dentiste' : u.roleName
    }))
    // Set default selected dentist to the first one in the list if the current selection is invalid
    if (dentists.value.length > 0 && !dentists.value.some(d => d.id === selectedDentist.value)) {
      selectedDentist.value = dentists.value[0].id
    }
  } catch (error) {
    console.error("Failed to fetch dentists from database:", error)
    toast.add({
      severity: 'error',
      summary: 'Erreur',
      detail: 'Impossible de récupérer la liste des praticiens.',
      life: 4000
    })
  }
}

const showAddDialog = ref(false)
const savingApp = ref(false)
const defaultSlotTime = ref('08:00')

// Confirmation Dialog state for cancellation
const showCancelConfirmation = ref(false)
const appointmentIdToCancel = ref(null)

const timeSlots = [
  '08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30', 
  '12:00', '12:30', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', 
  '16:00', '16:30', '17:00', '17:30'
]

// Fetch data
const fetchData = async () => {
  loading.value = true
  const start = `${selectedDate.value}T00:00:00Z`
  const end = `${selectedDate.value}T23:59:59Z`

  console.log(`[API Request] GET /rendezvous | startDate: ${start}, endDate: ${end}, dentisteId: ${selectedDentist.value}`)
  console.log(`[API Request] GET /patients`)

  try {
    // Fetch appointments for day
    const appRes = await api.get('/rendezvous', {
      params: {
        startDate: start,
        endDate: end,
        dentisteId: selectedDentist.value
      }
    })
    console.log(`[API Response] GET /rendezvous | Status: ${appRes.status}`, appRes.data)
    appointments.value = appRes.data?.items || appRes.data || []

    // Fetch patients list for dropdown
    const patientsRes = await api.get('/patients')
    console.log(`[API Response] GET /patients | Status: ${patientsRes.status}`, patientsRes.data)
    patients.value = patientsRes.data?.items || patientsRes.data || []
  } catch (error) {
    console.error('[API Error] fetchData failed:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur de chargement',
      detail: 'Impossible de charger le planning. Vérifiez la connexion au serveur.',
      life: 5000
    })
  } finally {
    loading.value = false
  }
}

const formatTime = (dateStr) => {
  if (!dateStr) return ''
  const normalized = dateStr.replace(' ', 'T')
  const date = new Date(normalized)
  return date.toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' })
}

const formatDuration = (durationStr) => {
  if (!durationStr) return ''
  const parts = durationStr.split(':')
  const hours = parseInt(parts[0], 10)
  const minutes = parseInt(parts[1], 10)
  if (hours > 0) {
    return `${hours}h ${minutes > 0 ? minutes + 'm' : ''}`.trim()
  }
  return `${minutes} min`
}

const availableSlots = computed(() => {
  return timeSlots.filter(slot => {
    return !appointments.value.some(app => {
      if (!app.dateHeure) return false
      const parts = app.dateHeure.includes('T') ? app.dateHeure.split('T') : app.dateHeure.split(' ')
      const time = parts[1]?.substring(0, 5)
      return time === slot && app.statut !== 'Annulé' && app.statut !== 'Annule'
    })
  })
})

const openSlotDialog = (slotTime) => {
  defaultSlotTime.value = slotTime
  showAddDialog.value = true
}

const checkConflicts = computed(() => {
  // If there are multiple appointments at the exact same hour, return true
  const times = appointments.value.map(a => {
    if (!a.dateHeure) return ''
    const parts = a.dateHeure.includes('T') ? a.dateHeure.split('T') : a.dateHeure.split(' ')
    return parts[1]?.substring(0, 5) || ''
  }).filter(t => t !== '')
  const uniqueTimes = new Set(times)
  return times.length !== uniqueTimes.size
})

const handleSaveApp = async (formData) => {
  savingApp.value = true
  console.log(`[API Request] POST /rendezvous`, formData)
  try {
    const res = await api.post('/rendezvous', formData)
    console.log(`[API Response] POST /rendezvous | Status: ${res.status}`, res.data)
    toast.add({ severity: 'success', summary: 'RDV Planifié', detail: 'Le rendez-vous a été planifié.', life: 3000 })
    showAddDialog.value = false
    fetchData()
  } catch (error) {
    console.error('[API Error] handleSaveApp failed:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur de planification',
      detail: 'Impossible d\'enregistrer le rendez-vous.',
      life: 5000
    })
  } finally {
    savingApp.value = false
  }
}

const requestCancel = (id) => {
  appointmentIdToCancel.value = id
  showCancelConfirmation.value = true
}

const confirmCancel = async () => {
  showCancelConfirmation.value = false
  const id = appointmentIdToCancel.value
  if (!id) return

  console.log(`[API Request] DELETE /rendezvous/${id}`)
  try {
    const res = await api.delete(`/rendezvous/${id}`)
    console.log(`[API Response] DELETE /rendezvous/${id} | Status: ${res.status}`, res.data)
    toast.add({ severity: 'success', summary: 'Succès', detail: 'Rendez-vous annulé.', life: 3000 })
    fetchData()
  } catch (error) {
    console.error('[API Error] confirmCancel failed:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur d\'annulation',
      detail: 'Impossible d\'annuler ce rendez-vous.',
      life: 5000
    })
  } finally {
    appointmentIdToCancel.value = null
  }
}

const confirmArrival = async (id) => {
  try {
    await api.post(`/rendezvous/${id}/checkin`)
    toast.add({ severity: 'success', summary: 'Arrivée confirmée', detail: 'Le médecin a été notifié.', life: 3000 })
    fetchData()
  } catch (error) {
    console.error('[API Error] checkin failed:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur',
      detail: 'Impossible de confirmer l\'arrivée.',
      life: 5000
    })
  }
}

const isImminent = (app) => {
  if (app.statut !== 'Planifié' && app.statut !== 'Planifie') return false;
  if (!app.dateHeure) return false;
  
  const normalized = app.dateHeure.replace(' ', 'T');
  // Ensure we append Z or treat as local if needed, but assuming server sends local or UTC properly
  // Since dateHeure format is usually "YYYY-MM-DDTHH:mm:ss", we parse it directly
  const appDate = new Date(normalized + (normalized.endsWith('Z') ? '' : 'Z'));
  const now = new Date(currentTime.value.toISOString());
  
  const diffMs = appDate - now;
  const diffMinutes = Math.floor(diffMs / 60000);
  
  // Imminent if it's within the next 15 minutes or it's already past (but still 'Planifié')
  return diffMinutes <= 15 && diffMinutes >= -60;
}

// Watchers to trigger re-fetch on filter changes
watch([selectedDate, selectedDentist], () => {
  fetchData()
})

onMounted(async () => {
  timeInterval = setInterval(() => {
    currentTime.value = new Date()
  }, 10000)

  await fetchDentists()
  fetchData()
  if (route.query.new === 'true') {
    openSlotDialog('08:00')
  }
})

onUnmounted(() => {
  if (timeInterval) clearInterval(timeInterval)
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    
    <!-- Top Headers -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div>
        <h1 class="text-xl font-extrabold text-slate-900 tracking-tight">Agenda Clinique</h1>
        <p class="text-xs text-slate-500 mt-1">Gérez le planning quotidien des praticiens et évitez les conflits d'horaires.</p>
      </div>
      
      <button 
        @click="openSlotDialog('08:00')"
        class="bg-brand-mint hover:bg-brand-mintDark text-white font-semibold px-4 py-2 rounded-lg text-sm transition-all flex items-center gap-2 shadow-sm animate-fade-in"
      >
        <i class="pi pi-calendar-plus"></i>
        <span>Nouveau Rendez-vous</span>
      </button>
    </div>

    <!-- Conflict warning alert block -->
    <div 
      v-if="checkConflicts" 
      class="p-4 bg-amber-50 border border-amber-200/50 rounded-xl flex items-start gap-3 text-amber-700 animate-pulse"
    >
      <i class="pi pi-exclamation-triangle text-base mt-0.5"></i>
      <div>
        <h4 class="text-xs font-extrabold uppercase tracking-wide">Détection de surréservation</h4>
        <p class="text-[11px] font-semibold text-amber-600 mt-1">Attention, deux rendez-vous sont planifiés sur le même créneau horaire pour ce médecin.</p>
      </div>
    </div>

    <!-- Main Layout: Grid Calendar Timeline (2/3) + Sidebar Controls (1/3) -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      
      <!-- LEFT: Booked list & Available slots grid -->
      <div class="lg:col-span-2 space-y-6 animate-slide-in">
        
        <!-- Section 1: Booked Appointments of the day -->
        <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6">
          <div class="flex justify-between items-center mb-6">
            <div>
              <h2 class="text-sm font-extrabold text-slate-900 uppercase tracking-wider">Rendez-vous de la journée</h2>
              <p class="text-[11px] text-slate-400 font-medium mt-0.5">Liste chronologique des consultations planifiées.</p>
            </div>
            <span class="text-xs text-slate-400 font-bold uppercase">{{ selectedDate }}</span>
          </div>

          <div v-if="loading" class="py-12 flex flex-col items-center justify-center text-slate-400 gap-2">
            <i class="pi pi-spin pi-spinner text-3xl text-sky-500"></i>
            <span class="text-xs font-semibold">Chargement du planning...</span>
          </div>

          <div v-else>
            <!-- Check if there are active appointments -->
            <div v-if="!appointments.length" class="text-center py-12 border border-dashed border-slate-200 rounded-2xl bg-slate-50/50">
              <i class="pi pi-calendar-times text-3xl text-slate-300"></i>
              <p class="text-xs font-bold text-slate-500 mt-3">Aucun rendez-vous planifié pour cette journée.</p>
            </div>

            <div v-else class="space-y-3">
              <div 
                v-for="app in appointments"
                :key="app.id"
                class="p-4 bg-slate-50/55 hover:bg-slate-50 border border-slate-150/80 hover:border-slate-200 rounded-xl flex flex-col md:flex-row md:items-center justify-between transition-all duration-200 gap-4"
                :class="{ 'border-emerald-400 ring-1 ring-emerald-400/50 bg-emerald-50/30': isImminent(app) }"
              >
                <div class="flex items-center gap-4 min-w-0">
                  <!-- Time Badge -->
                  <div class="px-3 py-1.5 bg-sky-50 text-sky-700 rounded-lg text-xs font-extrabold tracking-wide flex-shrink-0 text-center border border-sky-100">
                    {{ formatTime(app.dateHeure) }}
                  </div>
                  <!-- Patient & Motif -->
                  <div class="min-w-0">
                    <p class="text-sm font-bold text-slate-800 truncate">
                      {{ app.patientNomComplet }}
                    </p>
                    <div class="flex flex-wrap items-center gap-2 mt-1 text-[11px] text-slate-500 font-medium">
                      <span>Motif: {{ app.motif }}</span>
                      <span>&bull;</span>
                      <span>Durée: {{ formatDuration(app.dureeEstimee) }}</span>
                    </div>
                  </div>
                </div>

                <!-- Status and Cancel Action -->
                <div class="flex items-center gap-3 flex-shrink-0">
                  <button
                    v-if="isImminent(app)"
                    @click="confirmArrival(app.id)"
                    class="px-3 py-1.5 bg-emerald-500 hover:bg-emerald-600 text-white rounded-lg text-xs font-bold transition-all shadow-sm animate-pulse flex items-center gap-2"
                  >
                    <i class="pi pi-check-circle"></i> Confirmer Arrivée
                  </button>

                  <span 
                    class="px-2.5 py-0.5 text-[9px] font-extrabold rounded-full uppercase tracking-wider border"
                    :class="[
                      app.statut === 'Terminé' 
                        ? 'bg-emerald-50 text-emerald-700 border-emerald-100' 
                        : 'bg-sky-50 text-sky-700 border-sky-100'
                    ]"
                  >
                    {{ app.statut }}
                  </span>
                  
                  <button 
                    @click="requestCancel(app.id)"
                    class="w-8 h-8 rounded-lg bg-white hover:bg-rose-50 text-slate-400 hover:text-rose-600 border border-slate-200 flex items-center justify-center cursor-pointer transition-colors shadow-sm"
                    title="Annuler le rendez-vous"
                  >
                    <i class="pi pi-trash text-xs font-bold"></i>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Section 2: Compact Available Slots Grid -->
        <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6">
          <div class="mb-4">
            <h2 class="text-sm font-extrabold text-slate-900 uppercase tracking-wider">Créneaux de consultation disponibles</h2>
            <p class="text-[11px] text-slate-400 font-medium mt-0.5">Cliquez sur un créneau libre pour planifier rapidement un rendez-vous.</p>
          </div>

          <div v-if="loading" class="py-6 flex justify-center text-slate-400">
            <i class="pi pi-spin pi-spinner text-xl text-sky-500"></i>
          </div>

          <div v-else>
            <div v-if="!availableSlots.length" class="text-center py-6 text-xs text-rose-500 bg-rose-50 border border-rose-100 rounded-xl">
              Tous les créneaux de cette journée sont complets ou indisponibles.
            </div>

            <div v-else class="grid grid-cols-3 sm:grid-cols-5 md:grid-cols-6 gap-2">
              <button
                v-for="slot in availableSlots"
                :key="slot"
                type="button"
                @click="openSlotDialog(slot)"
                class="py-2 px-2 bg-white hover:bg-sky-55/30 border border-slate-200 hover:border-sky-500 text-slate-700 hover:text-sky-600 rounded-xl text-xs font-extrabold text-center transition-all cursor-pointer shadow-sm flex items-center justify-center gap-1.5"
              >
                <i class="pi pi-plus text-[8px] font-bold opacity-60"></i>
                <span>{{ slot }}</span>
              </button>
            </div>
          </div>
        </div>

      </div>

      <!-- RIGHT: Filtering Controls (Choice D Sidebar) -->
      <div class="space-y-6">
        
        <!-- Interactive Controls Card -->
        <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6 space-y-5">
          <h3 class="text-xs font-extrabold text-slate-900 uppercase tracking-wider border-b border-slate-100 pb-3">Filtres Agenda</h3>
          
          <!-- Date Selector -->
          <div class="space-y-1.5">
            <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Sélectionner la Date</label>
            <input 
              v-model="selectedDate"
              type="date" 
              class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
            />
          </div>

          <!-- Doctor Filter -->
          <div class="space-y-1.5">
            <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Médecin Traitant</label>
            <Dropdown 
              v-model="selectedDentist"
              :options="dentistOptions"
              optionLabel="label"
              optionValue="id"
              filter
              placeholder="Sélectionner un médecin"
              class="w-full text-xs"
            />
          </div>
        </div>

      </div>

    </div>

    <!-- Appointment Form Dialog Modals -->
    <AppointmentAddDialog 
      :visible="showAddDialog"
      :patients="patients"
      :dentists="dentists"
      :default-date="selectedDate"
      :default-slot-time="defaultSlotTime"
      :default-dentist-id="selectedDentist"
      :saving="savingApp"
      @save="handleSaveApp"
      @close="showAddDialog = false"
    />

    <!-- Custom Confirmation Dialog -->
    <ConfirmationDialog 
      :visible="showCancelConfirmation"
      title="Annuler le Rendez-vous"
      message="Voulez-vous vraiment annuler ce rendez-vous de l'agenda clinique ?"
      confirm-label="Oui, annuler"
      cancel-label="Non, conserver"
      @confirm="confirmCancel"
      @cancel="showCancelConfirmation = false"
    />

  </div>
</template>
