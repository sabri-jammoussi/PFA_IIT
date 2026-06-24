<script setup>
import { ref, onMounted } from 'vue'
import { toast } from 'vue3-toastify'
import api from '@/services/api'


const loading = ref(false)
const requests = ref([])
const dentists = ref([])

// Selection state for validation modal
const selectedRdv = ref(null)
const showModal = ref(false)
const validating = ref(false)

const form = ref({
  dateHeure: '',
  dentisteId: null,
  dureeEstimee: '00:30:00',
  note: ''
})

const durationOptions = [
  { value: '00:15:00', label: '15 minutes' },
  { value: '00:30:00', label: '30 minutes' },
  { value: '00:45:00', label: '45 minutes' },
  { value: '01:00:00', label: '1 heure' }
]

const fetchPendingRequests = async () => {
  loading.value = true
  try {
    const res = await api.get('/rendezvous/pending')
    requests.value = res.data || []
  } catch (error) {
    console.error('[API Error] fetchPendingRequests failed:', error)
    toast.error(`Erreur\nImpossible de charger les demandes en attente.`, { autoClose: 5000 })
  } finally {
    loading.value = false
  }
}

const fetchDentists = async () => {
  try {
    const res = await api.get('/users/dentists')
    dentists.value = res.data || []
  } catch (error) {
    console.error('[API Error] fetchDentists failed:', error)
  }
}

const openAcceptModal = (rdv) => {
  selectedRdv.value = rdv
  form.value.dateHeure = rdv.dateHeure ? rdv.dateHeure.substring(0, 16) : ''
  form.value.dentisteId = rdv.dentisteId
  form.value.dureeEstimee = '00:30:00'
  form.value.note = 'Demande validée par le secrétariat'
  showModal.value = true
}

const closeAcceptModal = () => {
  showModal.value = false
  selectedRdv.value = null
}

const handleAccept = async () => {
  validating.value = true
  try {
    const payload = {
      id: selectedRdv.value.id,
      dateHeure: form.value.dateHeure,
      dureeEstimee: form.value.dureeEstimee,
      statut: 'Planifie',
      motif: selectedRdv.value.motif || 'Consultation',
      note: form.value.note,
      patientId: selectedRdv.value.patientId,
      dentisteId: form.value.dentisteId
    }

    await api.put(`/rendezvous/${selectedRdv.value.id}`, payload)
    toast.success(`Rendez-vous planifié\nLa demande a été acceptée et planifiée avec succès.`, { autoClose: 3000 })
    closeAcceptModal()
    fetchPendingRequests()
  } catch (error) {
    console.error('[API Error] handleAccept failed:', error)
    toast.error(`Erreur\nImpossible d'enregistrer la planification.`, { autoClose: 5000 })
  } finally {
    validating.value = false
  }
}

const handleReject = async (rdv) => {
  if (!confirm(`Voulez-vous rejeter la demande de rendez-vous de ${rdv.patientNomComplet} ?`)) {
    return
  }
  try {
    // Delete or update status to Annule
    const payload = {
      id: rdv.id,
      dateHeure: rdv.dateHeure,
      dureeEstimee: '00:30:00',
      statut: 'Annule',
      motif: rdv.motif,
      note: 'Rejeté par le secrétariat (créneau indisponible)',
      patientId: rdv.patientId,
      dentisteId: rdv.dentisteId
    }
    await api.put(`/rendezvous/${rdv.id}`, payload)
    toast.info(`Demande rejetée\nLa demande de rendez-vous a été annulée.`, { autoClose: 3000 })
    fetchPendingRequests()
  } catch (error) {
    console.error('[API Error] handleReject failed:', error)
    toast.error(`Erreur\nImpossible de rejeter la demande.`, { autoClose: 5000 })
  }
}

onMounted(() => {
  fetchPendingRequests()
  fetchDentists()
})
</script>

<template>
  <div class="space-y-4">
    <!-- List container -->
    <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm overflow-hidden">
      <div class="px-6 py-4 bg-slate-50/50 border-b border-slate-100 flex items-center justify-between">
        <h3 class="text-xs font-extrabold text-slate-800 uppercase tracking-wider flex items-center gap-2">
          <i class="pi pi-bell text-sky-500 animate-pulse"></i>
          <span>Demandes de Rendez-vous Patients ({{ requests.length }})</span>
        </h3>
        <button 
          @click="fetchPendingRequests"
          class="w-7 h-7 rounded-lg border border-slate-200 hover:bg-slate-100 flex items-center justify-center text-slate-500 transition-colors cursor-pointer"
        >
          <i class="pi pi-refresh text-xs" :class="{ 'pi-spin': loading }"></i>
        </button>
      </div>

      <div v-if="loading" class="py-12 flex flex-col items-center justify-center text-slate-400 gap-2">
        <i class="pi pi-spin pi-spinner text-2xl text-sky-500"></i>
        <span class="text-[11px] font-semibold">Récupération des demandes...</span>
      </div>

      <div v-else-if="requests.length === 0" class="py-12 flex flex-col items-center justify-center text-slate-450 gap-2">
        <i class="pi pi-check-circle text-2xl text-emerald-500"></i>
        <span class="text-[11px] font-bold text-slate-500">Aucune demande en attente de validation</span>
      </div>

      <div v-else class="divide-y divide-slate-100">
        <!-- Table Header -->
        <div class="hidden md:flex items-center px-6 py-2.5 bg-slate-50 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
          <div class="w-1/4">Patient</div>
          <div class="w-1/4">Date Souhaitée</div>
          <div class="w-1/4">Motif de Consultation</div>
          <div class="w-1/4 text-right">Actions</div>
        </div>

        <!-- Table Rows -->
        <div 
          v-for="rdv in requests" 
          :key="rdv.id"
          class="flex flex-col md:flex-row md:items-center px-6 py-4 hover:bg-slate-50/30 transition-colors text-xs font-semibold text-slate-700 gap-2 md:gap-0"
        >
          <!-- Patient -->
          <div class="w-full md:w-1/4 flex items-center gap-2.5">
            <div class="w-8 h-8 rounded-full bg-slate-100 border border-slate-200 text-slate-700 flex items-center justify-center font-bold text-xs uppercase">
              {{ rdv.patientNomComplet ? rdv.patientNomComplet.charAt(0) : 'P' }}
            </div>
            <div>
              <p class="font-extrabold text-slate-900 leading-tight">{{ rdv.patientNomComplet }}</p>
              <p class="text-[10px] text-slate-400">ID Patient: #{{ rdv.patientId }}</p>
            </div>
          </div>

          <!-- Date -->
          <div class="w-full md:w-1/4 text-slate-650">
            <p class="font-extrabold text-slate-800">
              {{ new Date(rdv.dateHeure).toLocaleDateString('fr-FR', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }) }}
            </p>
            <p class="text-[10px] text-slate-400">
              Heure : {{ new Date(rdv.dateHeure).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }) }}
            </p>
          </div>

          <!-- Motif -->
          <div class="w-full md:w-1/4">
            <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-slate-100 text-slate-700 text-[10px] font-bold border border-slate-200/50">
              {{ rdv.motif || 'Non spécifié' }}
            </span>
          </div>

          <!-- Actions -->
          <div class="w-full md:w-1/4 flex justify-end items-center gap-2">
            <button 
              @click="handleReject(rdv)"
              class="px-2.5 py-1.5 border border-rose-200 hover:bg-rose-50 text-rose-600 rounded-lg text-[10px] font-bold transition-all cursor-pointer shadow-sm"
            >
              Proposer autre / Rejeter
            </button>
            <button 
              @click="openAcceptModal(rdv)"
              class="px-3 py-1.5 bg-slate-900 hover:bg-slate-800 text-white rounded-lg text-[10px] font-bold transition-all cursor-pointer shadow-sm flex items-center gap-1"
            >
              <i class="pi pi-check text-[9px]"></i>
              Accepter & Planifier
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Quick Approve Modal -->
    <div 
      v-if="showModal" 
      class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4 animate-fade-in font-sans"
    >
      <div class="bg-white border border-slate-200 rounded-2xl shadow-2xl max-w-md w-full overflow-hidden">
        <!-- Header -->
        <div class="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50/50">
          <div>
            <h3 class="text-sm font-extrabold text-slate-900 tracking-tight">Valider la demande de RDV</h3>
            <p class="text-[10px] text-slate-450 font-semibold mt-0.5">Patient: {{ selectedRdv?.patientNomComplet }}</p>
          </div>
          <button 
            type="button" 
            @click="closeAcceptModal" 
            class="w-8 h-8 rounded-lg hover:bg-slate-100 flex items-center justify-center text-slate-400 hover:text-slate-700 cursor-pointer"
          >
            <i class="pi pi-times text-xs"></i>
          </button>
        </div>

        <!-- Form Body -->
        <form @submit.prevent="handleAccept" class="p-6 space-y-4 text-xs">
          <!-- Date / Time -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Date & Heure Confirmées</label>
            <input 
              v-model="form.dateHeure"
              type="datetime-local" 
              required
              class="w-full py-2.5 px-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-850 font-medium"
            />
          </div>

          <!-- Dentist Selection -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Médecin traitant (Dentiste)</label>
            <select 
              v-model="form.dentisteId"
              required
              class="w-full py-2.5 px-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-850 font-medium cursor-pointer"
            >
              <option :value="null">Sélectionner un praticien</option>
              <option 
                v-for="d in dentists" 
                :key="d.id" 
                :value="d.id"
              >
                Dr. {{ d.prenom }} {{ d.nom }}
              </option>
            </select>
          </div>

          <!-- Duration selection -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Durée Estimée</label>
            <select 
              v-model="form.dureeEstimee"
              required
              class="w-full py-2.5 px-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-850 font-medium cursor-pointer"
            >
              <option 
                v-for="opt in durationOptions" 
                :key="opt.value" 
                :value="opt.value"
              >
                {{ opt.label }}
              </option>
            </select>
          </div>

          <!-- Note -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Note / Annotation</label>
            <textarea 
              v-model="form.note"
              rows="2"
              class="w-full py-2 px-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-850 resize-none font-medium"
            ></textarea>
          </div>

          <!-- Footer Buttons -->
          <div class="flex justify-end gap-3 pt-3 border-t border-slate-100">
            <button 
              type="button" 
              @click="closeAcceptModal"
              class="px-4 py-2 border border-slate-200 text-xs font-semibold text-slate-650 hover:bg-slate-50 rounded-xl transition-all cursor-pointer"
            >
              Annuler
            </button>
            <button 
              type="submit" 
              :disabled="validating"
              class="px-4 py-2 bg-slate-900 hover:bg-slate-800 disabled:bg-slate-250 text-white text-xs font-semibold rounded-xl transition-all cursor-pointer shadow-md flex items-center gap-1.5"
            >
              <i v-if="validating" class="pi pi-spin pi-spinner"></i>
              Planifier le RDV
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
