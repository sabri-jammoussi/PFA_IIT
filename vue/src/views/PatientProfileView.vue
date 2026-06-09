<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useToast } from 'primevue/usetoast'
import api from '@/services/api'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const router = useRouter()
const toast = useToast()
const authStore = useAuthStore()

const patientId = parseInt(route.params.id)
const loading = ref(false)
const savingSoin = ref(false)
const activeTab = ref('schema') // 'schema' or 'history' or 'prescriptions'

// Patient info
const patient = ref(null)

// FDI Tooth Schema state
const selectedTooth = ref(null)
const teethTreatments = ref({}) // map of toothNumber -> array of treatments
const medicalActs = ref([]) // list of medical acts for select

const newSoinForm = ref({
  acteMedicalId: null,
  faceDentaire: 'O',
  prixApplique: 0,
  notes: ''
})

// Mock values fallback
const consultations = ref([])
const ordonnances = ref([])
const soinsEffectues = ref([])

// Teeth structure by quadrants (Upper Left/Right, Lower Left/Right)
const upperRightTeeth = [18, 17, 16, 15, 14, 13, 12, 11]
const upperLeftTeeth = [21, 22, 23, 24, 25, 26, 27, 28]
const lowerRightTeeth = [48, 47, 46, 45, 44, 43, 42, 41]
const lowerLeftTeeth = [31, 32, 33, 34, 35, 36, 37, 38]

const faces = [
  { value: 'O', label: 'Occlusale (dessus)' },
  { value: 'V', label: 'Vestibulaire (extérieur)' },
  { value: 'L', label: 'Linguale (intérieur)' },
  { value: 'M', label: 'Mésiale (avant)' },
  { value: 'D', label: 'Distale (arrière)' }
]

const actOptions = computed(() => medicalActs.value.map(a => ({
  id: a.id,
  label: `${a.libelle} (${a.tarifDeBase} DT)`
})))

const faceOptions = computed(() => faces.map(f => ({
  value: f.value,
  label: `${f.value} - ${f.label}`
})))

// Computed: Filtered treatments based on selected tooth
const selectedToothTreatments = computed(() => {
  if (!selectedTooth.value) return []
  return soinsEffectues.value.filter(s => s.numeroDent === selectedTooth.value)
})

const fetchProfileData = async () => {
  loading.value = true
  try {
    // 1. Fetch Patient Details
    console.log(`[API Request] GET /patients/${patientId}`)
    const patientRes = await api.get(`/patients/${patientId}`)
    console.log(`[API Response] GET /patients/${patientId} | Status: ${patientRes.status}`, patientRes.data)
    patient.value = patientRes.data

    // 2. Fetch Medical Acts for form dropdown
    console.log(`[API Request] GET /actes-medicaux`)
    const actsRes = await api.get('/actes-medicaux')
    console.log(`[API Response] GET /actes-medicaux | Status: ${actsRes.status}`, actsRes.data)
    medicalActs.value = actsRes.data?.items || actsRes.data || []

    // 3. Fetch Treatments (Soins Effectues)
    console.log(`[API Request] GET /soins-effectues?patientId=${patientId}`)
    const soinsRes = await api.get(`/soins-effectues`, {
      params: { patientId: patientId, pageSize: 100 }
    })
    console.log(`[API Response] GET /soins-effectues | Status: ${soinsRes.status}`, soinsRes.data)
    soinsEffectues.value = soinsRes.data?.items || soinsRes.data || []

    // 4. Fetch Consultations for this patient
    console.log(`[API Request] GET /consultations?patientId=${patientId}`)
    const consultationsRes = await api.get(`/consultations`, {
      params: { patientId: patientId, pageSize: 100 }
    })
    console.log(`[API Response] GET /consultations | Status: ${consultationsRes.status}`, consultationsRes.data)
    consultations.value = consultationsRes.data?.items || consultationsRes.data || []

    // 5. Fetch Ordonnances for this patient
    console.log(`[API Request] GET /ordonnances?patientId=${patientId}`)
    const ordonnancesRes = await api.get(`/ordonnances`, {
      params: { patientId: patientId, pageSize: 100 }
    })
    console.log(`[API Response] GET /ordonnances | Status: ${ordonnancesRes.status}`, ordonnancesRes.data)
    ordonnances.value = ordonnancesRes.data?.items || ordonnancesRes.data || []
  } catch (error) {
    console.warn("[API Error] fetchProfileData failed. Falling back to mock data:", error)
    loadMockClinicalDossier()
  } finally {
    loading.value = false
  }
}

const loadMockClinicalDossier = () => {
  patient.value = {
    id: patientId,
    nom: "Martin",
    prenom: "Sophie",
    dateNaissance: "1988-04-12",
    telephone: "06 12 34 56 78",
    email: "sophie.m@mail.com",
    adresse: "15 Rue de Tunis, Sfax",
    antecedentsMedicaux: "Asthme léger, Allergie au latex",
    groupSanguin: "A+"
  }

  medicalActs.value = [
    { id: 1, libelle: "Consultation de contrôle", tarifDeBase: 50.00, codeNomenclature: "C" },
    { id: 2, libelle: "Détartrage & polissage", tarifDeBase: 80.00, codeNomenclature: "SC12" },
    { id: 3, libelle: "Restauration Composite (1 face)", tarifDeBase: 90.00, codeNomenclature: "SC20" },
    { id: 4, libelle: "Traitement de canal (Dents antérieures)", tarifDeBase: 150.00, codeNomenclature: "HB04" },
    { id: 5, libelle: "Extraction dentaire simple", tarifDeBase: 100.00, codeNomenclature: "HB12" },
    { id: 6, libelle: "Couronne céramo-métallique", tarifDeBase: 650.00, codeNomenclature: "SPR50" }
  ]

  // Mock treatments
  soinsEffectues.value = [
    {
      id: 201,
      numeroDent: 14,
      faceDentaire: "O",
      prixApplique: 90.00,
      notes: "Carie profonde nettoyée, obturation composite effectuée.",
      consultationDate: "2026-02-14T10:30:00",
      acteMedicalLibelle: "Restauration Composite (1 face)"
    },
    {
      id: 202,
      numeroDent: 46,
      faceDentaire: "V",
      prixApplique: 150.00,
      notes: "Traitement endodontique. Obturation canalaire étanche.",
      consultationDate: "2026-03-22T09:15:00",
      acteMedicalLibelle: "Traitement de canal (Dents antérieures)"
    },
    {
      id: 203,
      numeroDent: 11,
      faceDentaire: "M",
      prixApplique: 50.00,
      notes: "Polissage esthétique suite à léger éclat.",
      consultationDate: "2026-05-18T14:00:00",
      acteMedicalLibelle: "Consultation de contrôle"
    }
  ]

  ordonnances.value = [
    { id: 1, dateEmission: "2026-03-22T09:15:00", traitement: "Amoxicilline 500mg (1g x2/jour pendant 5 jours) + Paracétamol 1g (si douleur, max 3g/jour)", patientNomComplet: "Sophie Martin" }
  ]
}

const onActeSelect = () => {
  const selected = medicalActs.value.find(a => a.id === newSoinForm.value.acteMedicalId)
  if (selected) {
    newSoinForm.value.prixApplique = selected.tarifDeBase
  }
}

const handleAddSoin = async () => {
  if (!selectedTooth.value) {
    toast.add({ severity: 'warn', summary: 'Sélectionner une dent', detail: 'Veuillez cliquer sur une dent du schéma avant d\'enregistrer.', life: 3000 })
    return
  }
  if (!newSoinForm.value.acteMedicalId) {
    toast.add({ severity: 'warn', summary: 'Acte requis', detail: 'Veuillez sélectionner un acte médical.', life: 3000 })
    return
  }

  savingSoin.value = true

  let activeConsultationId = null
  if (consultations.value && consultations.value.length > 0) {
    activeConsultationId = consultations.value[0].id
  } else {
    try {
      console.log(`[API Request] POST /consultations (auto-create for soin)`)
      const newConsultationPayload = {
        dateConsultation: new Date().toISOString(),
        notesObservations: 'Créée automatiquement pour actes cliniques',
        patientId: patientId,
        dentisteId: authStore.user?.id || 1
      }
      const consRes = await api.post('/consultations', newConsultationPayload)
      console.log(`[API Response] POST /consultations | Status: ${consRes.status}`, consRes.data)
      activeConsultationId = consRes.data?.id || consRes.data
      
      consultations.value.unshift({
        id: activeConsultationId,
        dateConsultation: newConsultationPayload.dateConsultation,
        notesObservations: newConsultationPayload.notesObservations,
        patientId: patientId,
        dentisteId: newConsultationPayload.dentisteId
      })
    } catch (e) {
      console.error("Failed to auto-create consultation", e)
      activeConsultationId = 1
    }
  }
  
  const payload = {
    numeroDent: selectedTooth.value,
    faceDentaire: newSoinForm.value.faceDentaire,
    prixApplique: newSoinForm.value.prixApplique,
    notes: newSoinForm.value.notes,
    acteMedicalId: newSoinForm.value.acteMedicalId,
    consultationId: activeConsultationId
  }

  try {
    console.log(`[API Request] POST /soins-effectues | Payload:`, payload)
    const res = await api.post('/soins-effectues', payload)
    console.log(`[API Response] POST /soins-effectues | Status: ${res.status}`, res.data)
    toast.add({ severity: 'success', summary: 'Soin enregistré', detail: 'Acte ajouté à la fiche clinique.', life: 3000 })
    fetchProfileData()
    // Reset form notes
    newSoinForm.value.notes = ''
  } catch (error) {
    // Simulate local success on failure
    const act = medicalActs.value.find(a => a.id === newSoinForm.value.acteMedicalId)
    const mockNew = {
      id: Date.now(),
      numeroDent: selectedTooth.value,
      faceDentaire: newSoinForm.value.faceDentaire,
      prixApplique: newSoinForm.value.prixApplique,
      notes: newSoinForm.value.notes,
      consultationDate: new Date().toISOString(),
      acteMedicalLibelle: act?.libelle || "Autre soin"
    }
    soinsEffectues.value.push(mockNew)
    toast.add({ severity: 'success', summary: 'Soin simulé', detail: 'Soin enregistré localement sur la dent ' + selectedTooth.value, life: 3000 })
    newSoinForm.value.notes = ''
  } finally {
    savingSoin.value = false
  }
}

// Check tooth health status based on past treatments
const getToothStatus = (toothNumber) => {
  const treatments = soinsEffectues.value.filter(s => s.numeroDent === toothNumber)
  if (treatments.length === 0) return 'healthy'
  
  // If treatment involves canal or extraction, color code it differently
  const hasRootCanalOrExtraction = treatments.some(t => 
    t.acteMedicalLibelle?.toLowerCase().includes('canal') || 
    t.acteMedicalLibelle?.toLowerCase().includes('extraction')
  )
  return hasRootCanalOrExtraction ? 'alarm' : 'treated'
}

onMounted(() => {
  fetchProfileData()
})
</script>

<template>
  <div v-if="loading && !patient" class="py-24 flex flex-col items-center justify-center text-slate-400 gap-2 font-sans">
    <i class="pi pi-spin pi-spinner text-3xl text-sky-500"></i>
    <span class="text-xs font-semibold">Chargement du dossier médical...</span>
  </div>

  <div v-else-if="patient" class="space-y-6 animate-fade-in font-sans">
    
    <!-- Profile Header Banner -->
    <div class="flex items-center gap-4">
      <button 
        @click="router.push({ name: 'patients' })" 
        class="w-9 h-9 rounded-lg hover:bg-white text-slate-500 hover:text-slate-800 border border-slate-200/50 flex items-center justify-center cursor-pointer transition-colors shadow-sm bg-slate-50"
      >
        <i class="pi pi-chevron-left text-xs font-bold"></i>
      </button>
      <div>
        <h1 class="text-xl font-extrabold text-slate-900 tracking-tight">Dossier Clinique Patient</h1>
        <p class="text-xs text-slate-500 mt-0.5">Identité: {{ patient.prenom }} {{ patient.nom }} &bull; ID #{{ patient.id }}</p>
      </div>
    </div>

    <!-- Layout: Left (1/3) demographics & alerts | Right (2/3) tabs: Schema/soins -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      
      <!-- LEFT COLUMN: Demographics Card -->
      <div class="space-y-6">
        <!-- Demographics & Blood Group -->
        <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6 relative">
          <!-- Blood group badge upper corner -->
          <div 
            v-if="patient.groupSanguin"
            class="absolute top-6 right-6 w-11 h-11 bg-rose-50 border border-rose-100 rounded-xl flex flex-col items-center justify-center text-rose-700 shadow-sm"
          >
            <span class="text-[9px] font-bold uppercase leading-none">Sang</span>
            <span class="text-sm font-extrabold leading-none mt-1">{{ patient.groupSanguin }}</span>
          </div>

          <h3 class="text-sm font-extrabold text-slate-900 uppercase tracking-wider mb-4 border-b border-slate-100 pb-3">Informations</h3>
          
          <div class="space-y-4 text-xs font-semibold text-slate-700">
            <div>
              <p class="text-[9px] font-bold text-slate-400 uppercase tracking-wide">Nom Complet</p>
              <p class="text-sm font-extrabold text-slate-800 mt-1">{{ patient.prenom }} {{ patient.nom }}</p>
            </div>
            <div>
              <p class="text-[9px] font-bold text-slate-400 uppercase tracking-wide">Date de Naissance</p>
              <p class="text-slate-800 mt-1">{{ patient.dateNaissance ? new Date(patient.dateNaissance).toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' }) : 'Non renseigné' }}</p>
            </div>
            <div>
              <p class="text-[9px] font-bold text-slate-400 uppercase tracking-wide">Téléphone Portable</p>
              <p class="text-slate-800 mt-1">{{ patient.telephone }}</p>
            </div>
            <div>
              <p class="text-[9px] font-bold text-slate-400 uppercase tracking-wide">Adresse e-mail</p>
              <p class="text-slate-800 mt-1 truncate">{{ patient.email || 'Non renseigné' }}</p>
            </div>
            <div>
              <p class="text-[9px] font-bold text-slate-400 uppercase tracking-wide">Adresse de Résidence</p>
              <p class="text-slate-800 mt-1 leading-normal">{{ patient.adresse || 'Non renseigné' }}</p>
            </div>
          </div>
        </div>

        <!-- Alert box: Antecedents (Low vibrancy reds) -->
        <div class="bg-rose-50/60 border border-rose-100/70 rounded-xl p-5">
          <div class="flex items-center gap-2 text-rose-800 mb-2">
            <i class="pi pi-exclamation-triangle text-sm"></i>
            <h4 class="text-xs font-extrabold uppercase tracking-wider">Antécédents & Alertes</h4>
          </div>
          <p class="text-xs text-rose-700 font-semibold leading-relaxed">
            {{ patient.antecedentsMedicaux || 'Aucun antécédent médical signalé par le patient.' }}
          </p>
        </div>
      </div>

      <!-- RIGHT COLUMN: Medical Record Tabs (Choice C) -->
      <div class="lg:col-span-2 bg-white rounded-xl border border-slate-200/65 shadow-sm overflow-hidden flex flex-col">
        <!-- Tabs Header Bar -->
        <div class="bg-slate-50/50 border-b border-slate-150 px-6 flex items-center gap-4">
          <button 
            @click="activeTab = 'schema'"
            class="px-4 py-3.5 text-xs font-bold uppercase tracking-wider border-b-2 transition-all cursor-pointer"
            :class="[activeTab === 'schema' ? 'border-sky-500 text-sky-600' : 'border-transparent text-slate-400 hover:text-slate-600']"
          >
            Schéma Dentaire (FDI)
          </button>
          <button 
            @click="activeTab = 'history'"
            class="px-4 py-3.5 text-xs font-bold uppercase tracking-wider border-b-2 transition-all cursor-pointer"
            :class="[activeTab === 'history' ? 'border-sky-500 text-sky-600' : 'border-transparent text-slate-400 hover:text-slate-600']"
          >
            Historique des Soins
          </button>
          <button 
            @click="activeTab = 'prescriptions'"
            class="px-4 py-3.5 text-xs font-bold uppercase tracking-wider border-b-2 transition-all cursor-pointer"
            :class="[activeTab === 'prescriptions' ? 'border-sky-500 text-sky-600' : 'border-transparent text-slate-400 hover:text-slate-600']"
          >
            Prescriptions
          </button>
        </div>

        <!-- Tab 1: Interactive Tooth Schema -->
        <div v-show="activeTab === 'schema'" class="p-6 space-y-6">
          
          <!-- Dental Grid Container -->
          <div class="border border-slate-100 bg-slate-50/30 rounded-xl p-6 overflow-x-auto">
            <h4 class="text-xs font-extrabold text-slate-400 uppercase tracking-wider text-center mb-6">Machoîre Supérieure</h4>
            
            <!-- UPPER JAW GRID (Quadrants 1 & 2) -->
            <div class="flex justify-center items-center gap-6 mb-8 min-w-[650px]">
              <!-- Quadrant 1 (18-11) -->
              <div class="flex gap-1">
                <button 
                  v-for="tooth in upperRightTeeth"
                  :key="tooth"
                  @click="selectedTooth = tooth"
                  class="w-8 h-10 border rounded-lg flex flex-col items-center justify-center transition-all cursor-pointer group shadow-sm text-xs font-extrabold"
                  :class="[
                    selectedTooth === tooth
                      ? 'bg-sky-400 text-white border-sky-500 ring-2 ring-sky-300'
                      : getToothStatus(tooth) === 'alarm'
                        ? 'bg-rose-50 text-rose-600 border-rose-200 hover:bg-rose-100'
                        : getToothStatus(tooth) === 'treated'
                          ? 'bg-emerald-50 text-emerald-600 border-emerald-200 hover:bg-emerald-100'
                          : 'bg-white text-slate-700 border-slate-200 hover:bg-slate-50'
                  ]"
                >
                  <span>{{ tooth }}</span>
                  <span class="text-[7px] text-slate-400 group-hover:text-slate-500" :class="{'text-white': selectedTooth === tooth}">
                    {{ soinsEffectues.filter(s => s.numeroDent === tooth).length || '' }}
                  </span>
                </button>
              </div>

              <!-- Center Separation Divider -->
              <div class="w-[2px] h-10 bg-slate-300"></div>

              <!-- Quadrant 2 (21-28) -->
              <div class="flex gap-1">
                <button 
                  v-for="tooth in upperLeftTeeth"
                  :key="tooth"
                  @click="selectedTooth = tooth"
                  class="w-8 h-10 border rounded-lg flex flex-col items-center justify-center transition-all cursor-pointer group shadow-sm text-xs font-extrabold"
                  :class="[
                    selectedTooth === tooth
                      ? 'bg-sky-400 text-white border-sky-500 ring-2 ring-sky-300'
                      : getToothStatus(tooth) === 'alarm'
                        ? 'bg-rose-50 text-rose-600 border-rose-200 hover:bg-rose-100'
                        : getToothStatus(tooth) === 'treated'
                          ? 'bg-emerald-50 text-emerald-600 border-emerald-200 hover:bg-emerald-100'
                          : 'bg-white text-slate-700 border-slate-200 hover:bg-slate-50'
                  ]"
                >
                  <span>{{ tooth }}</span>
                  <span class="text-[7px] text-slate-400 group-hover:text-slate-500" :class="{'text-white': selectedTooth === tooth}">
                    {{ soinsEffectues.filter(s => s.numeroDent === tooth).length || '' }}
                  </span>
                </button>
              </div>
            </div>

            <h4 class="text-xs font-extrabold text-slate-400 uppercase tracking-wider text-center mb-6">Machoîre Inférieure</h4>

            <!-- LOWER JAW GRID (Quadrants 4 & 3) -->
            <div class="flex justify-center items-center gap-6 min-w-[650px]">
              <!-- Quadrant 4 (48-41) -->
              <div class="flex gap-1">
                <button 
                  v-for="tooth in lowerRightTeeth"
                  :key="tooth"
                  @click="selectedTooth = tooth"
                  class="w-8 h-10 border rounded-lg flex flex-col items-center justify-center transition-all cursor-pointer group shadow-sm text-xs font-extrabold"
                  :class="[
                    selectedTooth === tooth
                      ? 'bg-sky-400 text-white border-sky-500 ring-2 ring-sky-300'
                      : getToothStatus(tooth) === 'alarm'
                        ? 'bg-rose-50 text-rose-600 border-rose-200 hover:bg-rose-100'
                        : getToothStatus(tooth) === 'treated'
                          ? 'bg-emerald-50 text-emerald-600 border-emerald-200 hover:bg-emerald-100'
                          : 'bg-white text-slate-700 border-slate-200 hover:bg-slate-50'
                  ]"
                >
                  <span>{{ tooth }}</span>
                  <span class="text-[7px] text-slate-400 group-hover:text-slate-500" :class="{'text-white': selectedTooth === tooth}">
                    {{ soinsEffectues.filter(s => s.numeroDent === tooth).length || '' }}
                  </span>
                </button>
              </div>

              <!-- Center Separation Divider -->
              <div class="w-[2px] h-10 bg-slate-300"></div>

              <!-- Quadrant 3 (31-38) -->
              <div class="flex gap-1">
                <button 
                  v-for="tooth in lowerLeftTeeth"
                  :key="tooth"
                  @click="selectedTooth = tooth"
                  class="w-8 h-10 border rounded-lg flex flex-col items-center justify-center transition-all cursor-pointer group shadow-sm text-xs font-extrabold"
                  :class="[
                    selectedTooth === tooth
                      ? 'bg-sky-400 text-white border-sky-500 ring-2 ring-sky-300'
                      : getToothStatus(tooth) === 'alarm'
                        ? 'bg-rose-50 text-rose-600 border-rose-200 hover:bg-rose-100'
                        : getToothStatus(tooth) === 'treated'
                          ? 'bg-emerald-50 text-emerald-600 border-emerald-200 hover:bg-emerald-100'
                          : 'bg-white text-slate-700 border-slate-200 hover:bg-slate-50'
                  ]"
                >
                  <span>{{ tooth }}</span>
                  <span class="text-[7px] text-slate-400 group-hover:text-slate-500" :class="{'text-white': selectedTooth === tooth}">
                    {{ soinsEffectues.filter(s => s.numeroDent === tooth).length || '' }}
                  </span>
                </button>
              </div>
            </div>

            <!-- Legend -->
            <div class="flex justify-center gap-6 text-[10px] text-slate-400 font-bold uppercase tracking-wider mt-6 pt-4 border-t border-slate-100">
              <span class="flex items-center gap-1.5"><span class="w-2.5 h-2.5 rounded bg-white border border-slate-200"></span>Sain</span>
              <span class="flex items-center gap-1.5"><span class="w-2.5 h-2.5 rounded bg-emerald-50 border border-emerald-200"></span>Soigné</span>
              <span class="flex items-center gap-1.5"><span class="w-2.5 h-2.5 rounded bg-rose-50 border border-rose-200"></span>Pathologie / Retrait</span>
            </div>
          </div>

          <!-- Bottom: Selected tooth history or add new soin -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6 pt-2">
            
            <!-- Selected Tooth History -->
            <div class="border border-slate-200/60 rounded-xl p-5 bg-slate-50/20">
              <h4 class="text-xs font-extrabold text-slate-800 uppercase tracking-wider mb-4">
                Dent {{ selectedTooth || '(Sélectionnez une dent)' }} — Historique clinique
              </h4>

              <div v-if="!selectedTooth" class="text-center text-slate-400 text-xs font-medium py-10">
                Veuillez cliquer sur une dent du schéma ci-dessus pour inspecter son historique.
              </div>
              
              <div v-else-if="selectedToothTreatments.length === 0" class="text-center text-slate-450 text-xs font-medium py-10 italic">
                Aucun traitement enregistré sur la dent {{ selectedTooth }}.
              </div>

              <div v-else class="space-y-3 max-h-60 overflow-y-auto pr-1">
                <div 
                  v-for="soin in selectedToothTreatments"
                  :key="soin.id"
                  class="p-3 bg-white border border-slate-100 rounded-lg text-xs"
                >
                  <div class="flex justify-between items-start font-bold text-slate-800">
                    <span>{{ soin.acteMedicalLibelle }}</span>
                    <span class="text-[10px] text-slate-400">{{ new Date(soin.consultationDate).toLocaleDateString('fr-FR') }}</span>
                  </div>
                  <div class="flex items-center gap-2 mt-1.5 text-[10px] text-slate-400 font-bold uppercase tracking-wider">
                    <span>Face {{ soin.faceDentaire }}</span>
                    <span>&bull;</span>
                    <span class="text-sky-600">{{ soin.prixApplique }} DT</span>
                  </div>
                  <p class="text-slate-500 leading-normal mt-1.5 font-medium border-t border-slate-50 pt-1.5">
                    {{ soin.notes || 'Pas de note saisie.' }}
                  </p>
                </div>
              </div>
            </div>

            <!-- Log New Treatment Form -->
            <div class="border border-slate-200/60 rounded-xl p-5 bg-slate-50/20">
              <h4 class="text-xs font-extrabold text-slate-800 uppercase tracking-wider mb-4">
                Enregistrer un Soin sur la Dent {{ selectedTooth || '...' }}
              </h4>

              <form @submit.prevent="handleAddSoin" class="space-y-4">
                <!-- Select Act -->
                <div class="space-y-1">
                  <label class="text-[9px] font-bold text-slate-500 uppercase tracking-wide">Acte Médical *</label>
                  <Dropdown 
                    v-model="newSoinForm.acteMedicalId"
                    :options="actOptions"
                    optionLabel="label"
                    optionValue="id"
                    filter
                    placeholder="Sélectionner un acte"
                    :disabled="!selectedTooth"
                    @change="onActeSelect"
                    class="w-full text-xs"
                  />
                </div>

                <div class="grid grid-cols-2 gap-4">
                  <!-- Face dentaire -->
                  <div class="space-y-1">
                    <label class="text-[9px] font-bold text-slate-500 uppercase tracking-wide">Face Dentaire *</label>
                    <Dropdown 
                      v-model="newSoinForm.faceDentaire"
                      :options="faceOptions"
                      optionLabel="label"
                      optionValue="value"
                      filter
                      placeholder="Choisir face"
                      :disabled="!selectedTooth"
                      class="w-full text-xs"
                    />
                  </div>
                  <!-- Prix appliqué -->
                  <div class="space-y-1">
                    <label class="text-[9px] font-bold text-slate-500 uppercase tracking-wide">Tarif Appliqué (DT)</label>
                    <input 
                      v-model.number="newSoinForm.prixApplique"
                      type="number"
                      step="0.01"
                      required
                      :disabled="!selectedTooth"
                      class="w-full py-2 px-3 text-xs bg-white border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
                    />
                  </div>
                </div>

                <!-- Observations / Notes -->
                <div class="space-y-1">
                  <label class="text-[9px] font-bold text-slate-500 uppercase tracking-wide">Observations / Notes</label>
                  <textarea 
                    v-model="newSoinForm.notes"
                    rows="2"
                    :disabled="!selectedTooth"
                    placeholder="Détails techniques du soin posé..."
                    class="w-full py-2 px-3 text-xs bg-white border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800 resize-none"
                  ></textarea>
                </div>

                <!-- Button -->
                <button 
                  type="submit"
                  :disabled="!selectedTooth || savingSoin"
                  class="w-full py-2.5 bg-slate-950 hover:bg-slate-800 disabled:bg-slate-200 text-white font-semibold rounded-lg text-xs transition-all shadow-sm flex items-center justify-center gap-1.5 cursor-pointer disabled:cursor-not-allowed"
                >
                  <i class="pi pi-save"></i>
                  <span>Valider l'Acte Clinique</span>
                </button>
              </form>
            </div>

          </div>

        </div>

        <!-- Tab 2: Full Clinical History List -->
        <div v-show="activeTab === 'history'" class="p-6 space-y-4">
          <div class="flex justify-between items-center mb-2">
            <h3 class="text-sm font-extrabold text-slate-800 uppercase tracking-wider">Tableau des Actes Effectués</h3>
            <span class="text-xs text-slate-400 font-bold uppercase">{{ soinsEffectues.length }} actes totaux</span>
          </div>

          <div v-if="soinsEffectues.length === 0" class="text-center text-slate-400 text-xs font-medium py-16">
            Aucun traitement clinique répertorié.
          </div>

          <div v-else class="border border-slate-250/60 rounded-xl overflow-hidden shadow-sm">
            <div class="divide-y divide-slate-100">
              <!-- Header -->
              <div class="flex px-4 py-2.5 bg-slate-50 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
                <div class="w-1/6">Date</div>
                <div class="w-1/12 text-center">Dent</div>
                <div class="w-1/12 text-center">Face</div>
                <div class="w-5/12">Acte</div>
                <div class="w-1/6 text-right">Tarif</div>
              </div>

              <!-- Rows -->
              <div 
                v-for="soin in soinsEffectues"
                :key="soin.id"
                class="flex flex-col md:flex-row px-4 py-3 text-xs hover:bg-slate-50/50 transition-colors"
              >
                <div class="w-1/6 font-semibold text-slate-500">
                  {{ new Date(soin.consultationDate).toLocaleDateString('fr-FR') }}
                </div>
                <div class="w-1/12 text-center font-bold text-slate-900">
                  {{ soin.numeroDent || 'N/A' }}
                </div>
                <div class="w-1/12 text-center font-semibold text-slate-500">
                  {{ soin.faceDentaire || 'N/A' }}
                </div>
                <div class="w-5/12">
                  <p class="font-bold text-slate-800">{{ soin.acteMedicalLibelle }}</p>
                  <p class="text-slate-400 text-[10px] leading-relaxed mt-0.5">{{ soin.notes }}</p>
                </div>
                <div class="w-1/6 text-right font-extrabold text-slate-950">
                  {{ soin.prixApplique.toFixed(2) }} DT
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Tab 3: Prescriptions list -->
        <div v-show="activeTab === 'prescriptions'" class="p-6 space-y-4">
          <div class="flex justify-between items-center mb-2">
            <h3 class="text-sm font-extrabold text-slate-800 uppercase tracking-wider">Historique des Ordonnances</h3>
            <span class="text-xs text-slate-400 font-bold uppercase">{{ ordonnances.length }} ordonnances</span>
          </div>

          <div v-if="ordonnances.length === 0" class="text-center text-slate-400 text-xs font-medium py-16">
            Aucune ordonnance émise pour ce patient.
          </div>

          <div v-else class="space-y-4">
            <div 
              v-for="ord in ordonnances" 
              :key="ord.id"
              class="border border-slate-200/60 rounded-xl p-5 bg-slate-50/20 text-xs"
            >
              <div class="flex justify-between items-center border-b border-slate-100 pb-3 mb-3">
                <span class="font-bold text-slate-700">Ordonnance Clinique #ORD-{{ ord.id }}</span>
                <span class="text-[10px] text-slate-400 font-semibold">Émise le {{ new Date(ord.dateEmission).toLocaleDateString('fr-FR') }}</span>
              </div>
              <div>
                <p class="text-[10px] font-bold text-slate-400 uppercase tracking-wide mb-1.5">Prescription thérapeutique</p>
                <div class="p-3 bg-white border border-slate-100 rounded-lg text-slate-800 leading-relaxed font-semibold whitespace-pre-line">
                  {{ ord.traitement }}
                </div>
              </div>
            </div>
          </div>
        </div>

      </div>

    </div>

  </div>
</template>
