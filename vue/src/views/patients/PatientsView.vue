<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { toast } from 'vue3-toastify'
import api from '@/services/api'
import PatientAddDialog from './PatientAddDialog.vue'
import PatientUpdateDialog from './PatientUpdateDialog.vue'
import ConfirmationDialog from '@/components/ConfirmationDialog.vue'

const router = useRouter()
const route = useRoute()


const loading = ref(false)
const patients = ref([])
const totalCount = ref(0)
const page = ref(1)
const pageSize = ref(10)
const search = ref(route.query.search || '')

// Dialog and state variables
const showAddDialog = ref(false)
const showUpdateDialog = ref(false)
const savingPatient = ref(false)

const selectedPatientToEdit = ref(null)

// Confirmation dialog state
const showArchiveConfirmation = ref(false)
const patientIdToArchive = ref(null)

const fetchPatients = async () => {
  loading.value = true
  console.log(`[API Request] GET /patients | Page: ${page.value}, Search: "${search.value}"`)
  try {
    const response = await api.get('/patients', {
      params: {
        page: page.value,
        pageSize: pageSize.value,
        search: search.value || null
      }
    })
    console.log(`[API Response] GET /patients | Status: ${response.status}`, response.data)
    patients.value = response.data?.items || response.data || []
    totalCount.value = response.data?.totalCount || patients.value.length
  } catch (error) {
    console.error('[API Error] fetchPatients failed:', error)
    toast.error(`Erreur de chargement\nImpossible de charger la liste des patients.`, { autoClose: 5000 })
  } finally {
    loading.value = false
  }
}

const handleCreatePatient = async (formData) => {
  savingPatient.value = true
  const { invite, ...patientData } = formData
  const url = invite ? '/patients/invite' : '/patients'
  console.log(`[API Request] POST ${url}`, patientData)
  try {
    const res = await api.post(url, patientData)
    console.log(`[API Response] POST ${url} | Status: ${res.status}`, res.data)
    toast.success(`${invite ? 'Patient créé & invité' : 'Patient créé'}\n${invite ? 'Le patient a été créé et l\'invitation e-mail a été envoyée.' : 'La nouvelle fiche patient a été ajoutée.'}`, { autoClose: 3000 })
    showAddDialog.value = false
    fetchPatients()
  } catch (error) {
    console.error(`[API Error] handleCreatePatient failed:`, error)
    toast.error(`Erreur\nImpossible d'enregistrer la fiche patient.`, { autoClose: 5000 })
  } finally {
    savingPatient.value = false
  }
}

const handleUpdatePatient = async (formData) => {
  savingPatient.value = true
  const id = formData.id
  console.log(`[API Request] PUT /patients/${id}`, formData)
  try {
    const res = await api.put(`/patients/${id}`, formData)
    console.log(`[API Response] PUT /patients/${id} | Status: ${res.status}`)
    toast.success(`Patient mis à jour\nLes modifications ont été enregistrées.`, { autoClose: 3000 })
    showUpdateDialog.value = false
    fetchPatients()
  } catch (error) {
    console.error('[API Error] handleUpdatePatient failed:', error)
    toast.error(`Erreur de mise à jour\nImpossible de mettre à jour la fiche patient.`, { autoClose: 5000 })
  } finally {
    savingPatient.value = false
  }
}

const startEdit = (patient) => {
  selectedPatientToEdit.value = patient
  showUpdateDialog.value = true
}

const requestArchive = (id) => {
  patientIdToArchive.value = id
  showArchiveConfirmation.value = true
}

const confirmArchive = async () => {
  showArchiveConfirmation.value = false
  const id = patientIdToArchive.value
  if (!id) return

  try {
    console.log(`[API Request] DELETE /patients/${id}`)
    const res = await api.delete(`/patients/${id}`)
    console.log(`[API Response] DELETE /patients/${id} | Status: ${res.status}`)
    toast.success(`Succès\nLe dossier patient a été archivé.`, { autoClose: 3000 })
    fetchPatients()
  } catch (error) {
    console.error('[API Error] confirmArchive failed:', error)
    toast.error(`Erreur d'archivage\nImpossible d'archiver ce dossier patient.`, { autoClose: 5000 })
  } finally {
    patientIdToArchive.value = null
  }
}

const viewPatientProfile = (id) => {
  router.push({ name: 'DentistPatientProfile', params: { id } })
}

// Watchers
watch(search, () => {
  page.value = 1
  fetchPatients()
})

onMounted(() => {
  fetchPatients()
  // Trigger open new modal if query param is set
  if (route.query.add === 'true') {
    showAddDialog.value = true
  }
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    
    <!-- Header Controls -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div>
        <h1 class="text-xl font-extrabold text-slate-900 tracking-tight">Répertoire des Patients</h1>
        <p class="text-xs text-slate-500 mt-1">Créez, modifiez ou accédez aux dossiers cliniques dentaires.</p>
      </div>
      
      <button 
        @click="showAddDialog = true"
        class="bg-brand-mint hover:bg-brand-mintDark text-white font-semibold px-4 py-2 rounded-lg text-sm transition-all flex items-center gap-2 shadow-sm"
      >
        <i class="pi pi-plus"></i> Nouveau Patient
      </button>
    </div>

    <!-- Filter Bar Card -->
    <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-4 flex flex-col md:flex-row md:items-center justify-between gap-4">
      <!-- Search Input -->
      <div class="relative w-full max-w-md">
        <span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
          <i class="pi pi-search text-xs"></i>
        </span>
        <input 
          v-model="search"
          type="text" 
          placeholder="Rechercher par nom, prénom ou téléphone..." 
          class="w-full py-2.5 pl-9 pr-4 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl outline-none transition-all duration-200 text-slate-800 placeholder-slate-400 font-medium"
        />
      </div>
      
      <!-- Counter Badge -->
      <div class="text-xs text-slate-400 font-bold uppercase tracking-wider bg-slate-50 border border-slate-100 px-3 py-1.5 rounded-lg flex-shrink-0">
        {{ totalCount }} dossiers trouvés
      </div>
    </div>

    <!-- Patients Data List (Choice C styled) -->
    <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm overflow-hidden">
      
      <div v-if="loading" class="py-20 flex flex-col items-center justify-center text-slate-400 gap-2">
        <i class="pi pi-spin pi-spinner text-3xl text-sky-500"></i>
        <span class="text-xs font-semibold">Chargement des dossiers patients...</span>
      </div>

      <div v-else-if="patients.length === 0" class="py-20 text-center text-slate-400 text-xs font-medium">
        Aucun patient trouvé correspondant à la recherche.
      </div>

      <div v-else class="divide-y divide-slate-100">
        <!-- Table Header (hidden on mobile) -->
        <div class="hidden md:flex items-center px-6 py-3 bg-slate-50/50 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
          <div class="w-1/3">Patient</div>
          <div class="w-1/4">Coordonnées</div>
          <div class="w-1/4">Groupe Sanguin & Antécédents</div>
          <div class="w-1/6 text-right">Actions</div>
        </div>

        <!-- Patients Rows -->
        <div 
          v-for="patient in patients" 
          :key="patient.id"
          class="flex flex-col md:flex-row md:items-center px-6 py-4 hover:bg-slate-50/60 transition-colors gap-3 md:gap-0"
        >
          <!-- Cell 1: Patient Identity -->
          <div class="w-full md:w-1/3 flex items-center gap-3">
            <div class="w-9 h-9 rounded-xl bg-indigo-50 border border-indigo-100/30 flex items-center justify-center text-indigo-600 font-bold text-xs uppercase flex-shrink-0">
              {{ patient.prenom?.charAt(0) || '' }}{{ patient.nom?.charAt(0) || '' }}
            </div>
            <div class="min-w-0">
              <button 
                @click="viewPatientProfile(patient.id)"
                class="text-sm font-extrabold text-slate-800 hover:text-sky-600 transition-colors text-left block w-full focus:outline-none cursor-pointer"
              >
                {{ patient.prenom }} {{ patient.nom }}
              </button>
              <span class="text-[10px] text-slate-400 font-bold uppercase mt-0.5 block">
                Né(e) le {{ patient.dateNaissance ? new Date(patient.dateNaissance).toLocaleDateString('fr-FR') : 'Non renseigné' }}
              </span>
            </div>
          </div>

          <!-- Cell 2: Contact Details -->
          <div class="w-full md:w-1/4 flex flex-col text-xs font-semibold text-slate-600">
            <div class="flex items-center gap-2">
              <i class="pi pi-phone text-[10px] text-slate-400"></i>
              <span>{{ patient.telephone }}</span>
            </div>
            <div class="flex items-center gap-2 mt-1">
              <i class="pi pi-envelope text-[10px] text-slate-400"></i>
              <span class="truncate">{{ patient.email || 'Pas de courriel' }}</span>
            </div>
          </div>

          <!-- Cell 3: Medical Notes -->
          <div class="w-full md:w-1/4 flex flex-col justify-center gap-1">
            <div class="flex items-center gap-1.5">
              <span 
                v-if="patient.groupSanguin"
                class="px-1.5 py-0.5 rounded bg-rose-50 text-rose-700 border border-rose-100 text-[9px] font-bold"
              >
                Gr. {{ patient.groupSanguin }}
              </span>
              <span v-else class="text-[9px] text-slate-400 font-semibold italic">Groupe inconnu</span>
            </div>
            <p class="text-xs text-slate-500 leading-normal truncate" :title="patient.antecedentsMedicaux">
              <span class="font-bold text-slate-600">Alerte: </span>
              {{ patient.antecedentsMedicaux || 'Aucun antécédent majeur' }}
            </p>
          </div>

          <!-- Cell 4: Action buttons -->
          <div class="w-full md:w-1/6 flex items-center justify-end gap-2 mt-2 md:mt-0">
            <button 
              @click="viewPatientProfile(patient.id)"
              title="Dossier Clinique"
              class="px-2.5 py-1.5 bg-slate-900 hover:bg-slate-800 text-white rounded-lg text-xs font-bold transition-all shadow-sm cursor-pointer flex items-center gap-1.5"
            >
              <i class="pi pi-folder text-[10px]"></i>
              <span>Fiche</span>
            </button>
            <button 
              @click="startEdit(patient)"
              title="Modifier"
              class="p-1.5 bg-white hover:bg-slate-100 text-slate-500 hover:text-slate-800 rounded-lg border border-slate-200 flex items-center justify-center transition-all cursor-pointer shadow-sm"
            >
              <i class="pi pi-pencil text-xs"></i>
            </button>
            <button 
              @click="requestArchive(patient.id)"
              title="Supprimer"
              class="p-1.5 bg-white hover:bg-rose-50 text-slate-400 hover:text-rose-600 rounded-lg border border-slate-200 flex items-center justify-center transition-all cursor-pointer shadow-sm hover:border-rose-200"
            >
              <i class="pi pi-trash text-xs"></i>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Patient Creation Dialog -->
    <PatientAddDialog 
      :visible="showAddDialog"
      :saving="savingPatient"
      @save="handleCreatePatient"
      @close="showAddDialog = false"
    />

    <!-- Patient Editing Dialog -->
    <PatientUpdateDialog 
      :visible="showUpdateDialog"
      :patient="selectedPatientToEdit"
      :saving="savingPatient"
      @save="handleUpdatePatient"
      @close="showUpdateDialog = false; selectedPatientToEdit = null"
    />

    <!-- Confirmation Dialog for Archiving -->
    <ConfirmationDialog 
      :visible="showArchiveConfirmation"
      title="Archiver le Patient"
      message="Voulez-vous vraiment archiver ce dossier patient ?"
      confirm-label="Archiver"
      cancel-label="Annuler"
      @confirm="confirmArchive"
      @cancel="showArchiveConfirmation = false"
    />

  </div>
</template>
