<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'
import { useAuthStore } from '@/stores/auth'
import { useToast } from 'primevue/usetoast'

const authStore = useAuthStore()
const toast = useToast()

const loading = ref(true)
const records = ref({
  patientInfo: {},
  consultations: [],
  prescriptions: [],
  invoices: []
})
const appointments = ref([])

// Booking Request State
const showBookModal = ref(false)
const bookingLoading = ref(false)
const bookingForm = ref({
  dateHeure: '',
  motif: '',
  note: ''
})

const dentists = ref([])
const selectedDentistId = ref(null)
const selectedDate = ref('')
const availabilitySlots = ref([])
const loadingSlots = ref(false)
const selectedSlot = ref(null)

const activeTab = ref('appointments')

const fetchPortalData = async () => {
  loading.value = true
  try {
    const recordRes = await api.get('/my/appointments/medical-record')
    records.value = recordRes.data

    const apptRes = await api.get('/my/appointments')
    appointments.value = apptRes.data
  } catch (error) {
    console.error('Failed to load patient portal data:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur de chargement',
      detail: 'Impossible de charger vos données médicales.',
      life: 5000
    })
  } finally {
    loading.value = false
  }
}

const fetchDentists = async () => {
  try {
    const res = await api.get('/users/dentists')
    dentists.value = res.data || []
  } catch (error) {
    console.error('Failed to load dentists:', error)
  }
}

const fetchAvailability = async () => {
  if (!selectedDentistId.value || !selectedDate.value) {
    availabilitySlots.value = []
    return
  }
  loadingSlots.value = true
  selectedSlot.value = null
  bookingForm.value.dateHeure = ''
  try {
    const res = await api.get('/my/appointments/availability', {
      params: {
        date: selectedDate.value,
        dentistId: selectedDentistId.value
      }
    })
    availabilitySlots.value = res.data || []
  } catch (error) {
    console.error('Failed to load slot availability:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur',
      detail: 'Impossible de charger les disponibilités du praticien.',
      life: 4000
    })
  } finally {
    loadingSlots.value = false
  }
}

const selectSlot = (slot) => {
  if (!slot.isAvailable) return
  selectedSlot.value = slot
  bookingForm.value.dateHeure = slot.dateTime
}

const resetBookingForm = () => {
  selectedDentistId.value = null
  selectedDate.value = ''
  availabilitySlots.value = []
  selectedSlot.value = null
  bookingForm.value = { dateHeure: '', motif: '', note: '' }
}

const handleRequestAppointment = async () => {
  if (!bookingForm.value.dateHeure || !bookingForm.value.motif || !selectedDentistId.value) {
    toast.add({
      severity: 'warn',
      summary: 'Formulaire incomplet',
      detail: 'Veuillez sélectionner un dentiste, un jour, une heure et saisir le motif.',
      life: 3000
    })
    return
  }

  bookingLoading.value = true
  try {
    await api.post('/my/appointments/request', {
      dateHeure: new Date(bookingForm.value.dateHeure).toISOString(),
      motif: bookingForm.value.motif,
      note: bookingForm.value.note || '',
      dentisteId: selectedDentistId.value
    })

    toast.add({
      severity: 'success',
      summary: 'Demande envoyée',
      detail: 'Votre demande de rendez-vous a été soumise au secrétariat.',
      life: 4000
    })
    showBookModal.value = false
    resetBookingForm()
    await fetchPortalData()
  } catch (error) {
    console.error('Failed to submit appointment request:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur',
      detail: 'Impossible d\'envoyer votre demande de rendez-vous.',
      life: 4000
    })
  } finally {
    bookingLoading.value = false
  }
}

// Prescription print modal
const selectedPrescription = ref(null)
const showPrintPrescription = ref(false)

const openPrescription = (presc) => {
  selectedPrescription.value = presc
  showPrintPrescription.value = true
}

const printPrescriptionContent = () => {
  window.print()
}

onMounted(() => {
  fetchPortalData()
  fetchDentists()
})
</script>

<template>
  <div class="space-y-8 animate-slide-in">
    <!-- Header Block -->
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-gradient-to-r from-brand-mintDark to-brand-mint text-white p-8 rounded-3xl shadow-xl relative overflow-hidden">
      <!-- Background pattern -->
      <div class="absolute inset-0 bg-[radial-gradient(circle_at_30%_20%,rgba(56,189,248,0.15),transparent_40%)]"></div>
      
      <div class="flex items-center gap-5 z-10">
        <div class="w-16 h-16 rounded-2xl bg-white/10 backdrop-blur-md flex items-center justify-center text-3xl shadow-inner border border-white/10">
          🧬
        </div>
        <div>
          <h1 class="text-2xl md:text-3xl font-extrabold tracking-tight">Bonjour, {{ authStore.fullName }}</h1>
          <p class="text-brand-mintLight text-sm mt-1">Bienvenue dans votre Espace de Santé Patient DentiFlow.</p>
        </div>
      </div>

      <button
        @click="showBookModal = true"
        class="z-10 px-6 py-3.5 bg-white hover:bg-slate-50 text-brand-mintDark font-extrabold text-sm rounded-2xl shadow-lg hover:shadow-white/20 transition-all flex items-center gap-2.5 cursor-pointer self-start md:self-auto"
      >
        <i class="pi pi-calendar-plus text-base"></i>
        <span>Demander un Rendez-vous</span>
      </button>
    </div>

    <!-- Quick KPIs Cards Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
      <!-- Card: Next Appointment -->
      <div class="bg-white p-6 rounded-2xl border border-slate-200/60 shadow-sm flex items-center gap-4">
        <div class="w-12 h-12 rounded-xl bg-sky-50 flex items-center justify-center text-sky-600 text-xl border border-sky-100">
          <i class="pi pi-calendar"></i>
        </div>
        <div>
          <span class="text-slate-400 text-xs font-bold uppercase tracking-wider">Prochain RDV</span>
          <p class="text-sm font-bold text-slate-800 mt-1 truncate max-w-[170px]">
            {{ appointments.find(a => a.statut === 'Confirmé' || a.statut === 'Planifié')?.dateHeure 
               ? new Date(appointments.find(a => a.statut === 'Confirmé' || a.statut === 'Planifié').dateHeure).toLocaleDateString('fr-FR', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' })
               : 'Aucun planifié' }}
          </p>
        </div>
      </div>

      <!-- Card: Total Consults -->
      <div class="bg-white p-6 rounded-2xl border border-slate-200/60 shadow-sm flex items-center gap-4">
        <div class="w-12 h-12 rounded-xl bg-emerald-50 flex items-center justify-center text-emerald-600 text-xl border border-emerald-100">
          <i class="pi pi-file-o"></i>
        </div>
        <div>
          <span class="text-slate-400 text-xs font-bold uppercase tracking-wider">Consultations</span>
          <p class="text-lg font-extrabold text-slate-800 mt-1">
            {{ records.consultations?.length || 0 }} séances
          </p>
        </div>
      </div>

      <!-- Card: Active Prescriptions -->
      <div class="bg-white p-6 rounded-2xl border border-slate-200/60 shadow-sm flex items-center gap-4">
        <div class="w-12 h-12 rounded-xl bg-purple-50 flex items-center justify-center text-purple-600 text-xl border border-purple-100">
          <i class="pi pi-paperclip"></i>
        </div>
        <div>
          <span class="text-slate-400 text-xs font-bold uppercase tracking-wider">Ordonnances</span>
          <p class="text-lg font-extrabold text-slate-800 mt-1">
            {{ records.prescriptions?.length || 0 }} disponibles
          </p>
        </div>
      </div>

      <!-- Card: Billing Status -->
      <div class="bg-white p-6 rounded-2xl border border-slate-200/60 shadow-sm flex items-center gap-4">
        <div class="w-12 h-12 rounded-xl bg-amber-50 flex items-center justify-center text-amber-600 text-xl border border-amber-100">
          <i class="pi pi-wallet"></i>
        </div>
        <div>
          <span class="text-slate-400 text-xs font-bold uppercase tracking-wider">Solde Total</span>
          <p class="text-lg font-extrabold text-slate-800 mt-1">
            {{ records.invoices?.reduce((sum, i) => sum + (i.montantTotal - i.montantPaye), 0).toFixed(2) }} DT
          </p>
        </div>
      </div>
    </div>

    <!-- Main Navigation Tabs -->
    <div class="bg-white border border-slate-200/60 rounded-3xl shadow-sm overflow-hidden">
      <!-- Tabs Headers -->
      <div class="flex border-b border-slate-100 bg-slate-50/50 p-2 gap-2">
        <button
          @click="activeTab = 'appointments'"
          class="flex items-center gap-2 px-5 py-3 rounded-xl text-xs font-bold uppercase tracking-wider transition-all cursor-pointer"
          :class="[activeTab === 'appointments' ? 'bg-white text-brand-mint shadow-sm border border-slate-200/60' : 'text-slate-500 hover:text-slate-800 hover:bg-slate-200/20']"
        >
          <i class="pi pi-calendar-times"></i>
          <span>Mes Rendez-vous</span>
        </button>

        <button
          @click="activeTab = 'medical'"
          class="flex items-center gap-2 px-5 py-3 rounded-xl text-xs font-bold uppercase tracking-wider transition-all cursor-pointer"
          :class="[activeTab === 'medical' ? 'bg-white text-brand-mint shadow-sm border border-slate-200/60' : 'text-slate-500 hover:text-slate-800 hover:bg-slate-200/20']"
        >
          <i class="pi pi-shield"></i>
          <span>Soins & Consultations</span>
        </button>

        <button
          @click="activeTab = 'prescriptions'"
          class="flex items-center gap-2 px-5 py-3 rounded-xl text-xs font-bold uppercase tracking-wider transition-all cursor-pointer"
          :class="[activeTab === 'prescriptions' ? 'bg-white text-brand-mint shadow-sm border border-slate-200/60' : 'text-slate-500 hover:text-slate-800 hover:bg-slate-200/20']"
        >
          <i class="pi pi-paperclip"></i>
          <span>Ordonnances</span>
        </button>

        <button
          @click="activeTab = 'billing'"
          class="flex items-center gap-2 px-5 py-3 rounded-xl text-xs font-bold uppercase tracking-wider transition-all cursor-pointer"
          :class="[activeTab === 'billing' ? 'bg-white text-brand-mint shadow-sm border border-slate-200/60' : 'text-slate-500 hover:text-slate-800 hover:bg-slate-200/20']"
        >
          <i class="pi pi-dollar"></i>
          <span>Facturation</span>
        </button>
      </div>

      <!-- Tab Content Area -->
      <div class="p-6 md:p-8">
        <div v-if="loading" class="flex flex-col items-center justify-center py-20 gap-3">
          <i class="pi pi-spin pi-spinner text-3xl text-sky-500"></i>
          <span class="text-sm font-semibold text-slate-500">Chargement de votre dossier...</span>
        </div>

        <div v-else>
          <!-- TAB 1: Appointments -->
          <div v-if="activeTab === 'appointments'" class="space-y-6">
            <div class="flex justify-between items-center">
              <h3 class="text-base font-extrabold text-slate-800 uppercase tracking-wide">Historique des Visites</h3>
              <span class="text-xs text-slate-400 font-bold uppercase">{{ appointments.length }} rendez-vous enregistrés</span>
            </div>

            <div v-if="!appointments.length" class="text-center py-16 border border-dashed border-slate-200 rounded-2xl bg-slate-50/50">
              <i class="pi pi-calendar-times text-3xl text-slate-300"></i>
              <p class="text-sm font-bold text-slate-500 mt-3">Aucun rendez-vous planifié dans ce cabinet.</p>
            </div>

            <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div 
                v-for="appt in appointments" 
                :key="appt.id" 
                class="p-5 border border-slate-200/60 rounded-2xl flex justify-between items-start gap-3 hover:shadow-md transition-all bg-white"
              >
                <div class="space-y-1">
                  <p class="text-sm font-extrabold text-slate-800">
                    {{ new Date(appt.dateHeure).toLocaleDateString('fr-FR', { weekday: 'long', day: '2-digit', month: 'long', year: 'numeric' }) }}
                  </p>
                  <p class="text-xs font-semibold text-sky-600">
                    Heure : {{ new Date(appt.dateHeure).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }) }}
                  </p>
                  <p class="text-xs font-bold text-slate-500 mt-2">
                    <span class="font-semibold text-slate-400">Motif :</span> {{ appt.motif }}
                  </p>
                  <p class="text-[11px] text-slate-400 mt-1">
                    Praticien : {{ appt.dentisteNomComplet }}
                  </p>
                </div>
                <!-- Status Badge -->
                <span 
                  class="px-3 py-1 text-[9px] font-extrabold uppercase tracking-widest rounded-lg"
                  :class="[
                    appt.statut === 'Confirmé' ? 'bg-sky-50 text-sky-600 border border-sky-100' :
                    appt.statut === 'Terminé' ? 'bg-emerald-50 text-emerald-600 border border-emerald-100' :
                    appt.statut === 'Annulé' ? 'bg-rose-50 text-rose-600 border border-rose-100' :
                    'bg-slate-50 text-slate-500 border border-slate-100'
                  ]"
                >
                  {{ appt.statut }}
                </span>
              </div>
            </div>
          </div>

          <!-- TAB 2: Consultations & Care -->
          <div v-if="activeTab === 'medical'" class="space-y-6">
            <h3 class="text-base font-extrabold text-slate-800 uppercase tracking-wide">Journal des Soins</h3>

            <div v-if="!records.consultations?.length" class="text-center py-16 border border-dashed border-slate-200 rounded-2xl bg-slate-50/50">
              <i class="pi pi-shield text-3xl text-slate-300"></i>
              <p class="text-sm font-bold text-slate-500 mt-3">Aucun soin clinique enregistré pour le moment.</p>
            </div>

            <div v-else class="space-y-6">
              <div 
                v-for="consult in records.consultations" 
                :key="consult.id"
                class="border border-slate-200/60 rounded-2xl overflow-hidden shadow-sm bg-white"
              >
                <!-- Header -->
                <div class="px-5 py-4 bg-slate-50 border-b border-slate-100 flex justify-between items-center">
                  <div>
                    <span class="text-xs text-slate-400 font-bold uppercase tracking-wide">Séance clinique</span>
                    <h4 class="text-sm font-extrabold text-slate-800">
                      {{ new Date(consult.dateConsultation).toLocaleDateString('fr-FR', { weekday: 'long', day: '2-digit', month: 'long', year: 'numeric' }) }}
                    </h4>
                  </div>
                  <span class="text-[11px] text-slate-500 font-bold uppercase">Dr. {{ consult.dentisteNomComplet }}</span>
                </div>
                <!-- Observations -->
                <div class="p-5 border-b border-slate-100" v-if="consult.notesObservations">
                  <span class="text-[10px] text-slate-400 font-extrabold uppercase tracking-wide">Observations Cliniques :</span>
                  <p class="text-xs text-slate-600 leading-relaxed mt-1.5">{{ consult.notesObservations }}</p>
                </div>
                <!-- Acts performed -->
                <div class="p-5 bg-slate-50/20">
                  <span class="text-[10px] text-slate-400 font-extrabold uppercase tracking-wide">Soins effectués lors de la séance :</span>
                  <div v-if="!consult.soins?.length" class="text-xs text-slate-500 italic mt-1.5">Aucun acte saisi.</div>
                  <div v-else class="grid grid-cols-1 sm:grid-cols-2 gap-3 mt-2">
                    <div 
                      v-for="soin in consult.soins" 
                      :key="soin.id"
                      class="px-4 py-2.5 bg-white border border-slate-200/60 rounded-xl flex items-center justify-between text-xs"
                    >
                      <div class="flex items-center gap-2">
                        <span class="w-6 h-6 rounded-md bg-sky-50 text-sky-600 flex items-center justify-center font-bold text-[10px]">
                          {{ soin.numeroDent || 'G' }}
                        </span>
                        <div>
                          <p class="font-bold text-slate-800">{{ soin.acteLibelle }}</p>
                          <p class="text-[10px] text-slate-400 uppercase tracking-wide" v-if="soin.faceDentaire">Face : {{ soin.faceDentaire }}</p>
                        </div>
                      </div>
                      <span class="font-extrabold text-slate-700">{{ soin.prixApplique.toFixed(2) }} DT</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- TAB 3: Prescriptions -->
          <div v-if="activeTab === 'prescriptions'" class="space-y-6">
            <h3 class="text-base font-extrabold text-slate-800 uppercase tracking-wide">Ordonnances Médicales</h3>

            <div v-if="!records.prescriptions?.length" class="text-center py-16 border border-dashed border-slate-200 rounded-2xl bg-slate-50/50">
              <i class="pi pi-paperclip text-3xl text-slate-300"></i>
              <p class="text-sm font-bold text-slate-500 mt-3">Aucune ordonnance émise.</p>
            </div>

            <div v-else class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div 
                v-for="presc in records.prescriptions" 
                :key="presc.id"
                class="p-5 border border-slate-200/60 rounded-2xl bg-white flex justify-between items-center hover:shadow-md transition-all"
              >
                <div>
                  <h4 class="text-sm font-extrabold text-slate-800">Ordonnance du {{ new Date(presc.dateEmission).toLocaleDateString('fr-FR') }}</h4>
                  <p class="text-xs text-slate-500 mt-1">Prescrit par : Dr. {{ presc.dentisteNomComplet }}</p>
                  <p class="text-[11px] text-slate-400 mt-2 truncate max-w-[260px]">{{ presc.traitement }}</p>
                </div>

                <button 
                  @click="openPrescription(presc)"
                  class="px-4 py-2.5 bg-sky-50 hover:bg-sky-100 text-sky-600 rounded-xl font-bold text-xs flex items-center gap-1.5 transition-colors cursor-pointer border border-sky-100"
                >
                  <i class="pi pi-eye"></i>
                  <span>Visualiser</span>
                </button>
              </div>
            </div>
          </div>

          <!-- TAB 4: Billing -->
          <div v-if="activeTab === 'billing'" class="space-y-6">
            <h3 class="text-base font-extrabold text-slate-800 uppercase tracking-wide">Suivi des Factures</h3>

            <div v-if="!records.invoices?.length" class="text-center py-16 border border-dashed border-slate-200 rounded-2xl bg-slate-50/50">
              <i class="pi pi-dollar text-3xl text-slate-300"></i>
              <p class="text-sm font-bold text-slate-500 mt-3">Aucune facture enregistrée pour le moment.</p>
            </div>

            <div v-else class="overflow-x-auto border border-slate-200/60 rounded-2xl bg-white shadow-sm">
              <table class="w-full text-left border-collapse text-xs">
                <thead>
                  <tr class="bg-slate-50/50 text-slate-400 font-extrabold uppercase tracking-wider border-b border-slate-100">
                    <th class="p-4">Numéro</th>
                    <th class="p-4">Date d'émission</th>
                    <th class="p-4 text-right">Montant Total</th>
                    <th class="p-4 text-right">Montant Réglé</th>
                    <th class="p-4 text-right">Reste à payer</th>
                    <th class="p-4 text-center">Statut</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                  <tr v-for="inv in records.invoices" :key="inv.id" class="hover:bg-slate-50/50">
                    <td class="p-4 font-bold text-slate-800">{{ inv.numeroFacture }}</td>
                    <td class="p-4 text-slate-500">{{ new Date(inv.dateEmission).toLocaleDateString('fr-FR') }}</td>
                    <td class="p-4 text-right font-semibold text-slate-700">{{ inv.montantTotal.toFixed(2) }} DT</td>
                    <td class="p-4 text-right font-semibold text-emerald-600">{{ inv.montantPaye.toFixed(2) }} DT</td>
                    <td class="p-4 text-right font-extrabold text-rose-500">
                      {{ (inv.montantTotal - inv.montantPaye).toFixed(2) }} DT
                    </td>
                    <td class="p-4 text-center">
                      <span 
                        class="px-2.5 py-1 text-[9px] font-extrabold uppercase tracking-widest rounded-lg border inline-block"
                        :class="[
                          inv.statutPaiement === 'Payé' ? 'bg-emerald-50 text-emerald-600 border-emerald-100' :
                          inv.statutPaiement === 'Partiel' ? 'bg-amber-50 text-amber-600 border-amber-100' :
                          'bg-rose-50 text-rose-600 border-rose-100'
                        ]"
                      >
                        {{ inv.statutPaiement }}
                      </span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- MODAL 1: Request Appointment -->
    <Teleport to="body">
      <div v-if="showBookModal" class="fixed inset-0 w-screen h-screen bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4 animate-fade-in font-sans">
        <div class="bg-white border border-slate-200 rounded-2xl shadow-2xl max-w-lg w-full overflow-hidden animate-slide-in">
          <!-- Header -->
          <div class="px-6 py-4 border-b border-sky-100/50 flex justify-between items-center bg-sky-50/30">
            <h3 class="text-sm font-extrabold text-sky-950 tracking-tight uppercase">Demander un Rendez-vous</h3>
            <button 
              type="button"
              @click="showBookModal = false" 
              class="w-8 h-8 rounded-lg hover:bg-slate-100 flex items-center justify-center text-slate-400 hover:text-slate-700 cursor-pointer"
            >
              <i class="pi pi-times text-xs"></i>
            </button>
          </div>

          <form @submit.prevent="handleRequestAppointment" class="p-6 space-y-4">
            <div>
              <label class="block text-[10px] font-bold text-slate-600 uppercase tracking-wide mb-1">Choisissez un praticien (Dentiste) *</label>
              <select 
                v-model="selectedDentistId"
                @change="fetchAvailability"
                required
                class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800 transition-all cursor-pointer"
              >
                <option :value="null">Sélectionner un dentiste</option>
                <option v-for="d in dentists" :key="d.id" :value="d.id">
                  Dr. {{ d.prenom }} {{ d.nom }}
                </option>
              </select>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div class="space-y-1">
                <label class="block text-[10px] font-bold text-slate-600 uppercase tracking-wide mb-1">Date souhaitée *</label>
                <input 
                  type="date" 
                  v-model="selectedDate"
                  @change="fetchAvailability"
                  :disabled="!selectedDentistId"
                  required
                  class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800 transition-all disabled:opacity-50"
                />
              </div>

              <!-- Selected slot view -->
              <div class="space-y-1">
                <label class="block text-[10px] font-bold text-slate-600 uppercase tracking-wide mb-1">Heure sélectionnée *</label>
                <input 
                  type="text" 
                  :value="selectedSlot ? selectedSlot.time : 'Non sélectionnée'"
                  disabled
                  class="w-full py-2 px-3 text-xs bg-slate-100 border border-slate-200 rounded-lg text-slate-550 font-bold"
                />
              </div>
            </div>

            <!-- Availability slots visual picker -->
            <div v-if="selectedDentistId && selectedDate" class="space-y-1">
              <label class="block text-[10px] font-bold text-slate-600 uppercase tracking-wide mb-1.5">Créneaux horaires disponibles</label>
              
              <div v-if="loadingSlots" class="flex items-center gap-2 py-3 justify-center text-slate-400">
                <i class="pi pi-spin pi-spinner text-xs"></i>
                <span class="text-[11px]">Recherche des créneaux...</span>
              </div>
              
              <div v-else-if="!availabilitySlots.length" class="text-xs text-rose-500 bg-rose-50/50 border border-rose-100 p-2.5 rounded-xl text-center">
                Aucun créneau disponible pour ce jour ou ce praticien.
              </div>
              
              <div v-else class="grid grid-cols-4 gap-2 max-h-[130px] overflow-y-auto p-1 border border-slate-150 rounded-xl bg-slate-50/50">
                <button
                  v-for="slot in availabilitySlots"
                  :key="slot.time"
                  type="button"
                  :disabled="!slot.isAvailable"
                  @click="selectSlot(slot)"
                  class="px-2 py-1.5 rounded-lg text-xs font-bold border transition-all cursor-pointer text-center"
                  :class="[
                    !slot.isAvailable ? 'bg-slate-100 border-slate-200 text-slate-350 cursor-not-allowed line-through' :
                    selectedSlot?.time === slot.time ? 'bg-sky-500 border-sky-500 text-white shadow-md' :
                    'bg-white border-slate-200 hover:border-sky-500 text-slate-700 hover:bg-sky-50/30'
                  ]"
                >
                  {{ slot.time }}
                </button>
              </div>
            </div>

            <div class="space-y-1">
              <label class="block text-[10px] font-bold text-slate-600 uppercase tracking-wide mb-1">Motif de consultation *</label>
              <input 
                type="text" 
                v-model="bookingForm.motif"
                placeholder="Ex: Contrôle annuel, Rage de dent, Détartrage..."
                required
                class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800 transition-all"
              />
            </div>

            <div class="space-y-1">
              <label class="block text-[10px] font-bold text-slate-600 uppercase tracking-wide mb-1">Notes ou précisions (Optionnel)</label>
              <textarea 
                v-model="bookingForm.note"
                placeholder="Saisissez des détails supplémentaires..."
                rows="2"
                class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800 transition-all resize-none"
              ></textarea>
            </div>

            <!-- Action Buttons -->
            <div class="flex justify-end gap-3 pt-3 border-t border-slate-100">
              <button 
                type="button" 
                @click="showBookModal = false"
                class="px-4 py-2 border border-slate-200 text-xs font-semibold text-slate-600 hover:bg-slate-50 rounded-xl transition-all cursor-pointer"
              >
                Annuler
              </button>
              <button 
                type="submit" 
                :disabled="bookingLoading || !bookingForm.dateHeure"
                class="px-4 py-2 bg-sky-500 hover:bg-sky-600 disabled:bg-slate-200 text-white text-xs font-semibold rounded-xl transition-all cursor-pointer shadow-md shadow-sky-500/10 disabled:cursor-not-allowed flex items-center gap-1.5"
              >
                <i v-if="bookingLoading" class="pi pi-spin pi-spinner text-xs"></i>
                <span>{{ bookingLoading ? 'Envoi...' : 'Envoyer la demande' }}</span>
              </button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>

    <!-- MODAL 2: Visualise Prescription -->
    <Teleport to="body">
      <div v-if="showPrintPrescription && selectedPrescription" class="fixed inset-0 w-screen h-screen bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4 animate-fade-in font-sans">
        <div class="bg-white border border-slate-200 rounded-2xl shadow-2xl max-w-2xl w-full overflow-hidden flex flex-col max-h-[90vh] animate-slide-in">
          <!-- Controls -->
          <div class="px-6 py-4 border-b border-sky-100/50 flex justify-between items-center bg-sky-50/30">
            <h3 class="text-sm font-extrabold text-sky-950 tracking-tight uppercase">Ordonnance Médicale</h3>
            <div class="flex items-center gap-2">
              <button 
                @click="printPrescriptionContent"
                class="px-3 py-1.5 bg-sky-500 hover:bg-sky-600 text-white font-bold text-xs rounded-lg flex items-center gap-1.5 transition-all cursor-pointer shadow-md shadow-sky-500/10"
              >
                <i class="pi pi-print"></i>
                <span>Imprimer</span>
              </button>
              <button 
                type="button"
                @click="showPrintPrescription = false" 
                class="w-8 h-8 rounded-lg hover:bg-slate-100 flex items-center justify-center text-slate-400 hover:text-slate-700 cursor-pointer"
              >
                <i class="pi pi-times text-xs"></i>
              </button>
            </div>
          </div>

          <!-- Printable Document Area -->
          <div class="p-8 md:p-12 overflow-y-auto flex-grow bg-slate-50">
            <div class="bg-white p-8 md:p-12 border border-slate-200 rounded-xl shadow-inner max-w-lg mx-auto font-serif" id="print-area">
              <!-- Header Clinic -->
              <div class="text-center border-b-2 border-slate-800 pb-5">
                <h2 class="text-lg font-bold text-slate-900 uppercase tracking-wider">{{ authStore.user?.cabinetName || 'Clinique Dentaire DentiFlow' }}</h2>
                <p class="text-xs text-slate-500 mt-1 italic">Médecine & Soins Bucco-Dentaires</p>
                <p class="text-[10px] text-slate-400 uppercase mt-0.5 font-sans">Responsable : Dr. {{ selectedPrescription.dentisteNomComplet }}</p>
              </div>

              <!-- Date & Patient Info -->
              <div class="my-6 space-y-2 text-xs">
                <div class="flex justify-between">
                  <span>Tunis, le : <strong>{{ new Date(selectedPrescription.dateEmission).toLocaleDateString('fr-FR') }}</strong></span>
                </div>
                <p class="text-sm">Patient : <strong>{{ authStore.fullName }}</strong></p>
              </div>

              <!-- Content -->
              <div class="min-h-[250px] border-b border-slate-200 pb-5">
                <span class="text-lg font-bold block mb-4">Ordonnance :</span>
                <p class="text-sm text-slate-800 leading-loose whitespace-pre-line font-medium">{{ selectedPrescription.traitement }}</p>
              </div>

              <!-- Footer Signature -->
              <div class="mt-8 flex flex-col items-end">
                <span class="text-[10px] text-slate-400 uppercase tracking-wider font-sans">Signature et Cachet :</span>
                <div class="w-32 h-16 border-b border-dashed border-slate-300 mt-2"></div>
                <span class="text-xs font-bold text-slate-700 mt-1">Dr. {{ selectedPrescription.dentisteNomComplet }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </Teleport>
  </div>
</template>

<style scoped>
@media print {
  body * {
    visibility: hidden;
  }
  #print-area, #print-area * {
    visibility: visible;
  }
  #print-area {
    position: absolute;
    left: 0;
    top: 0;
    width: 100%;
    border: none;
    box-shadow: none;
    padding: 0;
    margin: 0;
  }
}
</style>
