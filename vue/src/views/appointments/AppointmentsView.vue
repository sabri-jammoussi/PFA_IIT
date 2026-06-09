<script setup>
import { ref, onMounted, computed, watch } from 'vue'
import { useRoute } from 'vue-router'
import { useToast } from 'primevue/usetoast'
import api from '@/services/api'
import AppointmentAddDialog from './AppointmentAddDialog.vue'
import ConfirmationDialog from '@/components/ConfirmationDialog.vue'

const route = useRoute()
const toast = useToast()

const loading = ref(false)
const appointments = ref([])
const patients = ref([])
const dentists = ref([
  { id: 1, nom: "Martin", prenom: "Jean", spec: "Chirurgien-Dentiste" },
  { id: 2, nom: "Karray", prenom: "Selim", spec: "Orthodontiste" }
])
const dentistOptions = computed(() => dentists.value.map(d => ({
  id: d.id,
  label: `Dr. ${d.prenom} ${d.nom} (${d.spec})`
})))

const selectedDate = ref(new Date().toISOString().split('T')[0])
const selectedDentist = ref(1) // Doctor Martin by default

const showAddDialog = ref(false)
const savingApp = ref(false)
const defaultSlotTime = ref('08:00')

// Confirmation Dialog state for cancellation
const showCancelConfirmation = ref(false)
const appointmentIdToCancel = ref(null)

const timeSlots = [
  '08:00', '09:00', '10:00', '11:00', '12:00', 
  '14:00', '15:00', '16:00', '17:00'
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
    console.warn("[API Error] fetchData failed, falling back to mockups:", error)
    loadMockData()
  } finally {
    loading.value = false
  }
}

const loadMockData = () => {
  const d = selectedDate.value
  
  appointments.value = [
    {
      id: 301,
      dateHeure: `${d}T09:00:00`,
      dureeEstimee: "00:45:00",
      statut: "Terminé",
      motif: "Détartrage & Polissage",
      note: "Patient sensible aux gencives",
      patientId: 1,
      patientNomComplet: "Mme. Sophie Martin",
      dentisteId: 1
    },
    {
      id: 302,
      dateHeure: `${d}T10:00:00`,
      dureeEstimee: "01:00:00",
      statut: "Terminé",
      motif: "Pose couronne céramique",
      patientId: 2,
      patientNomComplet: "M. Marc Lefevre",
      dentisteId: 1
    },
    {
      id: 303,
      dateHeure: `${d}T14:00:00`,
      dureeEstimee: "00:45:00",
      statut: "Planifié",
      motif: "Traitement de canal (dent 14)",
      patientId: 4,
      patientNomComplet: "M. Luc Durand",
      dentisteId: 1
    },
    {
      id: 304,
      dateHeure: `${d}T16:00:00`,
      dureeEstimee: "00:30:00",
      statut: "Planifié",
      motif: "Consultation générale",
      patientId: 3,
      patientNomComplet: "Mme. Amine Ben Ali",
      dentisteId: 1
    }
  ]

  patients.value = [
    { id: 1, nom: "Martin", prenom: "Sophie" },
    { id: 2, nom: "Lefevre", prenom: "Marc" },
    { id: 3, nom: "Ben Ali", prenom: "Amine" },
    { id: 4, nom: "Durand", prenom: "Luc" },
    { id: 5, nom: "Khalifa", prenom: "Sarah" }
  ]
}

// Map appointments to hour slots
const getAppointmentInSlot = (slotTime) => {
  return appointments.value.find(app => {
    if (!app.dateHeure) return false
    const parts = app.dateHeure.includes('T') ? app.dateHeure.split('T') : app.dateHeure.split(' ')
    const time = parts[1]?.substring(0, 5)
    return time === slotTime
  })
}

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
    // Local simulation fallback
    const patient = patients.value.find(p => p.id === formData.patientId)
    const newApp = {
      id: Date.now(),
      dateHeure: formData.dateHeure,
      dureeEstimee: formData.dureeEstimee,
      statut: "Planifié",
      motif: formData.motif,
      note: formData.note,
      patientId: formData.patientId,
      patientNomComplet: patient ? `${patient.prenom} ${patient.nom}` : "Patient Existant",
      dentisteId: formData.dentisteId
    }
    appointments.value.push(newApp)
    toast.add({ severity: 'success', summary: 'RDV Simulé', detail: 'Rendez-vous enregistré localement.', life: 3000 })
    showAddDialog.value = false
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
    console.warn("[API Error] cancelAppointment failed, falling back to local simulation:", error)
    appointments.value = appointments.value.filter(a => a.id !== id)
    toast.add({ severity: 'info', summary: 'Annulation locale', detail: 'Rendez-vous retiré de l\'agenda local.', life: 3000 })
  } finally {
    appointmentIdToCancel.value = null
  }
}

// Watchers to trigger re-fetch on filter changes
watch([selectedDate, selectedDentist], () => {
  fetchData()
})

onMounted(() => {
  fetchData()
  if (route.query.new === 'true') {
    openSlotDialog('08:00')
  }
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
        class="flex items-center justify-center gap-2 px-4 py-2.5 bg-slate-900 hover:bg-slate-800 text-white text-xs font-semibold rounded-xl transition-all shadow-md shadow-slate-900/10 cursor-pointer animate-fade-in"
      >
        <i class="pi pi-calendar-plus text-xs"></i>
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
      
      <!-- LEFT: Timeline Grid (Choice D) -->
      <div class="lg:col-span-2 bg-white rounded-xl border border-slate-200/65 shadow-sm p-6">
        
        <div class="flex justify-between items-center mb-6">
          <h2 class="text-sm font-extrabold text-slate-900 uppercase tracking-wider">Planning journalier</h2>
          <span class="text-xs text-slate-400 font-bold uppercase">{{ selectedDate }}</span>
        </div>

        <div v-if="loading" class="py-24 flex flex-col items-center justify-center text-slate-400 gap-2">
          <i class="pi pi-spin pi-spinner text-3xl text-sky-500"></i>
          <span class="text-xs font-semibold">Chargement du planning...</span>
        </div>

        <div v-else class="relative border-l-2 border-slate-100 pl-4 space-y-4">
          <!-- Iterate over daily slots -->
          <div 
            v-for="slot in timeSlots"
            :key="slot"
            class="relative flex items-start group min-h-[50px] gap-4"
          >
            <!-- Hour Indicator -->
            <div class="w-10 text-xs font-extrabold text-slate-400 select-none pt-0.5">
              {{ slot }}
            </div>

            <!-- Booking Card or Quick Reservation button -->
            <div class="flex-1">
              <!-- Slot Booked -->
              <div 
                v-if="getAppointmentInSlot(slot)"
                class="p-3 bg-white border border-slate-200 hover:border-slate-350 shadow-sm rounded-xl flex items-center justify-between transition-all duration-200"
              >
                <div>
                  <div class="flex items-center gap-2">
                    <span class="text-xs font-extrabold text-slate-800">{{ getAppointmentInSlot(slot).patientNomComplet }}</span>
                    <span 
                      class="px-2 py-0.5 text-[8px] font-extrabold rounded-full uppercase tracking-wider"
                      :class="[
                        getAppointmentInSlot(slot).statut === 'Terminé' 
                          ? 'bg-emerald-50 text-emerald-700' 
                          : 'bg-sky-50 text-sky-700'
                      ]"
                    >
                      {{ getAppointmentInSlot(slot).statut }}
                    </span>
                  </div>
                  <div class="text-[10px] text-slate-500 mt-1 flex items-center gap-2 font-medium">
                    <span>Motif: {{ getAppointmentInSlot(slot).motif }}</span>
                    <span>&bull;</span>
                    <span>Durée: {{ getAppointmentInSlot(slot).dureeEstimee }}</span>
                  </div>
                </div>

                <div class="flex items-center gap-1.5">
                  <button 
                    @click="requestCancel(getAppointmentInSlot(slot).id)"
                    class="w-6 h-6 rounded bg-slate-50 hover:bg-rose-50 text-slate-400 hover:text-rose-600 border border-slate-200/50 flex items-center justify-center cursor-pointer transition-colors"
                    title="Annuler le rendez-vous"
                  >
                    <i class="pi pi-trash text-[9px] font-bold"></i>
                  </button>
                </div>
              </div>

              <!-- Slot Empty: Reservation Button -->
              <div v-else>
                <button 
                  @click="openSlotDialog(slot)"
                  class="w-full text-left py-3 px-4 border border-dashed border-slate-200 hover:border-sky-300 hover:bg-sky-50/10 rounded-xl text-slate-400 hover:text-sky-600 transition-all flex items-center gap-2 text-xs font-semibold cursor-pointer group-hover:border-slate-300"
                >
                  <i class="pi pi-plus text-[10px]"></i>
                  <span>Planifier une consultation à {{ slot }}</span>
                </button>
              </div>
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
