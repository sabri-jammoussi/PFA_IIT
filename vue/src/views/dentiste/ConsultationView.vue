<script setup>
import { ref, onMounted, onUnmounted, computed, watch } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { toast } from 'vue3-toastify'
import api from '@/services/api'
import signalRService from '@/services/signalrService'

const authStore = useAuthStore()


const loadingPatients = ref(false)
const loadingProfile = ref(false)
const savingSoin = ref(false)
const savingNotes = ref(false)
const savingPrescription = ref(false)

const patients = ref([])
const selectedPatientId = ref(null)
const patient = ref(null)

// FDI Tooth Schema State
const selectedTooth = ref(null)
const medicalActs = ref([])
const soinsEffectues = ref([])
const consultations = ref([])
const ordonnances = ref([])

const newSoinForm = ref({
  acteMedicalId: null,
  faceDentaire: 'O',
  prixApplique: 0,
  notes: ''
})

const notesCliniques = ref('')
const prescriptionText = ref('')

// Stock consumption (manual) + invoicing
const articles = ref([])
const consommations = ref([])
const recetteSuggestions = ref([])
const savingConsommation = ref(false)
const finalizing = ref(false)
const newConsommationForm = ref({
  articleId: null,
  quantite: 1
})

// Waiting room (patients checked-in by the secretary for this doctor)
const waitingRoom = ref([])
const loadingWaiting = ref(false)

// Teeth quadrants (32 teeth FDI)
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

const patientOptions = computed(() => {
  return patients.value.map(p => ({
    id: p.id,
    label: `${p.nom.toUpperCase()} ${p.prenom} (#${p.id})`
  }))
})

const actOptions = computed(() => {
  return medicalActs.value.map(a => ({
    id: a.id,
    label: `${a.libelle} (${a.tarifDeBase} DT)`
  }))
})

const faceOptions = computed(() => {
  return faces.map(f => ({
    value: f.value,
    label: `${f.value} - ${f.label}`
  }))
})

const selectedToothTreatments = computed(() => {
  if (!selectedTooth.value) return []
  return soinsEffectues.value.filter(s => s.numeroDent === selectedTooth.value)
})

// The consultation currently being worked on (most recent for the patient).
const activeConsultationId = computed(() => consultations.value?.[0]?.id || null)

const articleOptions = computed(() => {
  return articles.value.map(a => ({
    id: a.id,
    label: `${a.nom} — stock: ${a.quantiteEnStock} ${a.unite || ''}`.trim()
  }))
})

// Total of the visit's treatments = amount the secretary will collect.
const consultationTotal = computed(() => {
  return soinsEffectues.value
    .filter(s => activeConsultationId.value && s.consultationId === activeConsultationId.value)
    .reduce((sum, s) => sum + (Number(s.prixApplique) || 0), 0)
})

const fetchPatients = async () => {
  loadingPatients.value = true
  try {
    console.log('[API Request] GET /patients')
    const res = await api.get('/patients', { params: { pageSize: 200 } })
    patients.value = res.data?.items || res.data || []
  } catch (error) {
    console.error("Failed to load patients list", error)
    toast.error(`Erreur\nImpossible de récupérer la liste des patients.`, { autoClose: 4000 })
  } finally {
    loadingPatients.value = false
  }
}

const fetchPatientClinicalData = async (patientId) => {
  if (!patientId) {
    patient.value = null
    return
  }
  loadingProfile.value = true
  selectedTooth.value = null
  notesCliniques.value = ''
  prescriptionText.value = ''
  
  try {
    // 1. Details
    const patRes = await api.get(`/patients/${patientId}`)
    patient.value = patRes.data

    // 2. Acts
    const actsRes = await api.get('/actes-medicaux')
    medicalActs.value = actsRes.data?.items || actsRes.data || []

    // 3. Past treatments
    const soinsRes = await api.get('/soins-effectues', { params: { patientId, pageSize: 100 } })
    soinsEffectues.value = soinsRes.data?.items || soinsRes.data || []

    // 4. Consultations (Notes clinical journal)
    const consRes = await api.get('/consultations', { params: { patientId, pageSize: 50 } })
    consultations.value = consRes.data?.items || consRes.data || []

    // 5. Ordonnances
    const ordRes = await api.get('/ordonnances', { params: { patientId, pageSize: 50 } })
    ordonnances.value = ordRes.data?.items || ordRes.data || []

    // 6. Articles consumed during the active consultation
    newConsommationForm.value = { articleId: null, quantite: 1 }
    recetteSuggestions.value = []
    await fetchConsommations(consultations.value?.[0]?.id || null)
  } catch (error) {
    console.error("Failed to fetch clinical records", error)
    toast.error(`Erreur\nImpossible de charger le dossier clinique.`, { autoClose: 5000 })
  } finally {
    loadingProfile.value = false
  }
}

const fetchArticles = async () => {
  try {
    const res = await api.get('/articles', { params: { pageSize: 200 } })
    articles.value = res.data?.items || res.data || []
  } catch (error) {
    console.error('Failed to load articles', error)
  }
}

const fetchConsommations = async (consultationId) => {
  if (!consultationId) {
    consommations.value = []
    return
  }
  try {
    const res = await api.get('/consommations', { params: { consultationId } })
    consommations.value = res.data || []
  } catch (error) {
    console.error('Failed to load consommations', error)
    consommations.value = []
  }
}

const fetchWaitingRoom = async () => {
  loadingWaiting.value = true
  try {
    const res = await api.get('/rendezvous/waiting-room', {
      params: { dentisteId: authStore.user?.id }
    })
    waitingRoom.value = res.data || []
  } catch (error) {
    console.error('Failed to load waiting room', error)
  } finally {
    loadingWaiting.value = false
  }
}

// Make sure a consultation exists for the active patient (created lazily, like the soin flow).
const ensureConsultation = async () => {
  if (activeConsultationId.value) return activeConsultationId.value
  const payload = {
    dateConsultation: new Date().toISOString(),
    notesObservations: 'Séance de soins',
    patientId: selectedPatientId.value,
    dentisteId: authStore.user?.id || 1
  }
  const consRes = await api.post('/consultations', payload)
  const newId = consRes.data?.id || consRes.data
  // Refresh so activeConsultationId picks it up.
  await fetchPatientClinicalData(selectedPatientId.value)
  return newId
}

const onActeSelect = async () => {
  const selected = medicalActs.value.find(a => a.id === newSoinForm.value.acteMedicalId)
  if (selected) {
    newSoinForm.value.prixApplique = selected.tarifDeBase
  }
  // Pre-fill editable stock suggestions from the act's "recipe".
  recetteSuggestions.value = []
  if (newSoinForm.value.acteMedicalId) {
    try {
      const res = await api.get(`/recettes-actes/${newSoinForm.value.acteMedicalId}`)
      recetteSuggestions.value = res.data || []
    } catch (error) {
      console.error('Failed to load recette suggestions', error)
    }
  }
}

const useSuggestion = (suggestion) => {
  newConsommationForm.value.articleId = suggestion.articleId
  newConsommationForm.value.quantite = suggestion.quantiteRequise || 1
}

const handleAddConsommation = async () => {
  if (!newConsommationForm.value.articleId) {
    toast.warning(`Article requis\nSélectionnez l'article consommé.`, { autoClose: 3000 })
    return
  }
  if (!newConsommationForm.value.quantite || newConsommationForm.value.quantite <= 0) {
    toast.warning(`Quantité invalide\nLa quantité doit être supérieure à 0.`, { autoClose: 3000 })
    return
  }

  savingConsommation.value = true
  try {
    const consultationId = await ensureConsultation()
    await api.post('/consommations', {
      consultationId,
      articleId: newConsommationForm.value.articleId,
      quantite: newConsommationForm.value.quantite
    })
    toast.success(`Consommation enregistrée\nLe stock a été décrémenté.`, { autoClose: 2500 })
    newConsommationForm.value = { articleId: null, quantite: 1 }
    await Promise.all([fetchConsommations(consultationId), fetchArticles()])
  } catch (error) {
    console.error('Failed to save consommation', error)
    toast.error(`Erreur\nImpossible d'enregistrer la consommation.`, { autoClose: 4000 })
  } finally {
    savingConsommation.value = false
  }
}

const handleDeleteConsommation = async (consommation) => {
  try {
    await api.delete(`/consommations/${consommation.id}`)
    toast.info(`Consommation annulée\nLa quantité a été remise en stock.`, { autoClose: 2500 })
    await Promise.all([fetchConsommations(activeConsultationId.value), fetchArticles()])
  } catch (error) {
    console.error('Failed to delete consommation', error)
    toast.error(`Erreur\nImpossible d'annuler la consommation.`, { autoClose: 4000 })
  }
}

const handleFinalize = async () => {
  if (!activeConsultationId.value) {
    toast.warning(`Aucune séance\nEnregistrez au moins un soin avant de clôturer.`, { autoClose: 3000 })
    return
  }
  if (!confirm(`Clôturer la consultation et générer la facture (${consultationTotal.value.toFixed(2)} DT) ? La secrétaire sera notifiée pour l'encaissement.`)) {
    return
  }

  finalizing.value = true
  try {
    const res = await api.post(`/consultations/${activeConsultationId.value}/finalize`)
    const facture = res.data
    toast.success(`Consultation clôturée\nFacture ${facture.numeroFacture} — ${Number(facture.montantTotal).toFixed(2)} DT envoyée à la caisse.`, { autoClose: 5000 })
    await fetchWaitingRoom()
  } catch (error) {
    console.error('Failed to finalize consultation', error)
    const msg = error?.response?.data || "Impossible de clôturer la consultation."
    toast.error(`Erreur\n${msg}`, { autoClose: 5000 })
  } finally {
    finalizing.value = false
  }
}

const selectWaitingPatient = (entry) => {
  selectedPatientId.value = entry.patientId
}

const handleAddSoin = async () => {
  if (!selectedTooth.value) {
    toast.warning(`Dent requise\nVeuillez cliquer sur une dent du schéma.`, { autoClose: 3000 })
    return
  }
  if (!newSoinForm.value.acteMedicalId) {
    toast.warning(`Acte requis\nVeuillez sélectionner un acte médical.`, { autoClose: 3000 })
    return
  }

  savingSoin.value = true

  let activeConsultationId = null
  if (consultations.value && consultations.value.length > 0) {
    activeConsultationId = consultations.value[0].id
  } else {
    try {
      const newConsultationPayload = {
        dateConsultation: new Date().toISOString(),
        notesObservations: 'Session ouverte pour soins cliniques',
        patientId: selectedPatientId.value,
        dentisteId: authStore.user?.id || 1
      }
      const consRes = await api.post('/consultations', newConsultationPayload)
      activeConsultationId = consRes.data?.id || consRes.data
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
    await api.post('/soins-effectues', payload)
    toast.success(`Soin enregistré\nL'acte a été posé avec succès.`, { autoClose: 3000 })
    newSoinForm.value.notes = ''
    fetchPatientClinicalData(selectedPatientId.value)
  } catch (error) {
    console.error("Failed to save soin", error)
    toast.error(`Erreur\nImpossible d'enregistrer le soin.`, { autoClose: 5000 })
  } finally {
    savingSoin.value = false
  }
}

const saveNotesCliniques = async () => {
  if (!patient.value) return
  if (!notesCliniques.value.trim()) {
    toast.warning(`Notes vides\nSaisissez des remarques cliniques.`, { autoClose: 3000 })
    return
  }

  savingNotes.value = true
  try {
    const payload = {
      dateConsultation: new Date().toISOString(),
      notesObservations: notesCliniques.value,
      patientId: patient.value.id,
      dentisteId: authStore.user?.id || 1
    }
    await api.post('/consultations', payload)
    toast.success(`Remarques enregistrées\nLe journal clinique a été mis à jour.`, { autoClose: 3000 })
    notesCliniques.value = ''
    fetchPatientClinicalData(selectedPatientId.value)
  } catch (error) {
    console.error("Failed to save consultation note", error)
    toast.error(`Erreur\nImpossible de sauvegarder le compte-rendu.`, { autoClose: 4000 })
  } finally {
    savingNotes.value = false
  }
}

const savePrescription = async () => {
  if (!patient.value) return
  if (!prescriptionText.value.trim()) {
    toast.warning(`Prescription vide\nVeuillez rédiger un traitement.`, { autoClose: 3000 })
    return
  }

  savingPrescription.value = true
  try {
    const payload = {
      dateEmission: new Date().toISOString(),
      traitement: prescriptionText.value,
      patientId: patient.value.id
    }
    await api.post('/ordonnances', payload)
    toast.success(`Ordonnance enregistrée\nSauvegardée dans l'historique du patient.`, { autoClose: 3000 })
    fetchPatientClinicalData(selectedPatientId.value)
  } catch (error) {
    console.error("Failed to save ordonnance", error)
    toast.error(`Erreur\nImpossible d'enregistrer l'ordonnance.`, { autoClose: 4000 })
  } finally {
    savingPrescription.value = false
  }
}

const printPrescription = () => {
  if (!patient.value || !prescriptionText.value.trim()) return
  const printWindow = window.open('', '_blank')
  const cabinetName = authStore.user?.cabinetName || 'Clinique Dentaire'
  const doctorName = `Dr. ${authStore.user?.nom || ''} ${authStore.user?.prenom || ''}`
  const dateStr = new Date().toLocaleDateString('fr-FR', { day: 'numeric', month: 'long', year: 'numeric' })
  
  const content = `
    <html>
      <head>
        <title>Ordonnance - ${patient.value.prenom} ${patient.value.nom}</title>
        <style>
          body { font-family: Arial, sans-serif; color: #334155; padding: 50px; line-height: 1.6; }
          .header { border-bottom: 3px double #0ea5e9; padding-bottom: 15px; margin-bottom: 40px; }
          .cabinet { font-size: 24px; font-weight: bold; color: #0369a1; margin: 0; text-transform: uppercase; }
          .details { font-size: 11px; color: #64748b; margin-top: 5px; }
          .doctor { margin-top: 10px; font-size: 14px; font-weight: bold; color: #0f172a; }
          .meta { display: flex; justify-content: space-between; margin-bottom: 40px; font-size: 13px; }
          .patient-box { border: 1px solid #cbd5e1; padding: 12px; border-radius: 6px; background-color: #f8fafc; min-width: 200px; }
          .title { text-align: center; font-size: 18px; font-weight: bold; margin-bottom: 30px; text-decoration: underline; text-transform: uppercase; letter-spacing: 0.5px; color: #0f172a; }
          .presc-text { font-size: 15px; white-space: pre-line; min-height: 220px; border-left: 3px solid #0ea5e9; padding-left: 20px; font-weight: 600; color: #1e293b; }
          .signature-box { display: flex; justify-content: flex-end; margin-top: 40px; }
          .signature { text-align: right; font-weight: bold; font-size: 13px; line-height: 1.5; }
          .footer { margin-top: 80px; font-size: 10px; color: #94a3b8; border-top: 1px solid #e2e8f0; padding-top: 15px; text-align: center; }
        </style>
      </head>
      <body>
        <div class="header">
          <h1 class="cabinet">${cabinetName}</h1>
          <div class="details">Chirurgie Dentaire &bull; Médecine Clinique &bull; Portail HDS Sécurisé</div>
          <div class="doctor">${doctorName}</div>
        </div>
        <div class="meta">
          <div class="patient-box">
            <strong>Patient :</strong> ${patient.value.prenom} ${patient.value.nom}<br/>
            <strong>Date de Naissance :</strong> ${patient.value.dateNaissance ? new Date(patient.value.dateNaissance).toLocaleDateString('fr-FR') : 'Non renseignée'}
          </div>
          <div>
            <strong>Date :</strong> ${dateStr}<br/>
            <strong>Cabinet :</strong> ${cabinetName}
          </div>
        </div>
        <div class="title">Ordonnance Médicale</div>
        <div class="presc-text">${prescriptionText.value}</div>
        <div class="signature-box">
          <div class="signature">
            Signature & Cachet Professionnel<br/><br/><br/>
            ${doctorName}
          </div>
        </div>
        <div class="footer">
          Ordonnance officielle émise via la plateforme DentiFlow SaaS.
        </div>
        <` + `script>
          window.onload = function() { window.print(); }
        </` + `script>
      </body>
    </html>
  `
  printWindow.document.write(content)
  printWindow.document.close()
}

const getToothStatus = (toothNumber) => {
  const treatments = soinsEffectues.value.filter(s => s.numeroDent === toothNumber)
  if (treatments.length === 0) return 'healthy'
  const hasRootCanalOrExtraction = treatments.some(t => 
    t.acteMedicalLibelle?.toLowerCase().includes('canal') || 
    t.acteMedicalLibelle?.toLowerCase().includes('extraction')
  )
  return hasRootCanalOrExtraction ? 'alarm' : 'treated'
}

watch(selectedPatientId, (newId) => {
  fetchPatientClinicalData(newId)
})

onMounted(() => {
  fetchPatients()
  fetchArticles()
  fetchWaitingRoom()

  // Real-time integration
  signalRService.startConnection()
  signalRService.on('NotifyPatientArrived', (payload) => {
    if (authStore.user && payload.doctorId === authStore.user.id) {
      toast.info(`Nouveau Patient Arrivé !\nLe patient ${payload.patientName} vient d'arriver en salle d'attente. (${payload.motif || 'Aucun motif précisé'})`, { autoClose: 8000 })

      // Refresh the queue and auto-switch to the new patient
      fetchWaitingRoom()
      selectedPatientId.value = payload.patientId
    }
  })
})

onUnmounted(() => {
  // Prevent memory leaks
  signalRService.off('NotifyPatientArrived')
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    
    <!-- Top Selector Bar -->
    <div class="bg-white rounded-2xl border border-slate-200/65 shadow-sm p-6 flex flex-col md:flex-row md:items-center justify-between gap-4">
      <div>
        <h1 class="text-xl font-extrabold text-slate-900 tracking-tight">Module de Consultation Synchrone</h1>
        <p class="text-xs text-slate-500 mt-0.5">Sélectionnez le patient installé sur le fauteuil pour démarrer.</p>
      </div>

      <div class="w-full md:w-80">
        <Dropdown 
          v-model="selectedPatientId"
          :options="patientOptions"
          optionLabel="label"
          optionValue="id"
          filter
          placeholder="Rechercher un patient sur le fauteuil..."
          :loading="loadingPatients"
          class="w-full text-xs font-semibold"
        />
      </div>
    </div>

    <!-- Waiting room: patients checked-in by the secretary for this doctor -->
    <div v-if="waitingRoom.length > 0" class="bg-white rounded-2xl border border-slate-200/65 shadow-sm p-5">
      <div class="flex items-center justify-between mb-3">
        <h3 class="text-xs font-extrabold text-slate-800 uppercase tracking-wider flex items-center gap-2">
          <i class="pi pi-users text-emerald-500"></i>
          <span>Salle d'attente ({{ waitingRoom.length }})</span>
        </h3>
        <button
          @click="fetchWaitingRoom"
          class="w-7 h-7 rounded-lg border border-slate-200 hover:bg-slate-100 flex items-center justify-center text-slate-500 transition-colors cursor-pointer"
        >
          <i class="pi pi-refresh text-xs" :class="{ 'pi-spin': loadingWaiting }"></i>
        </button>
      </div>
      <div class="flex gap-3 overflow-x-auto pb-1">
        <button
          v-for="entry in waitingRoom"
          :key="entry.appointmentId"
          @click="selectWaitingPatient(entry)"
          class="text-left min-w-[220px] p-3 rounded-xl border transition-all cursor-pointer shadow-sm"
          :class="selectedPatientId === entry.patientId
            ? 'bg-sky-50 border-sky-300 ring-2 ring-sky-200'
            : 'bg-white border-slate-200 hover:bg-slate-50'"
        >
          <div class="flex items-center justify-between">
            <span class="text-xs font-extrabold text-slate-900 truncate">{{ entry.patientNomComplet }}</span>
            <span class="text-[9px] font-bold text-slate-400">
              {{ entry.arrivalTime ? new Date(entry.arrivalTime).toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }) : '' }}
            </span>
          </div>
          <p class="text-[10px] text-slate-500 font-semibold mt-1 truncate">{{ entry.motif || 'Consultation' }}</p>
          <p class="text-[9px] text-slate-400 mt-1.5 truncate">
            <i class="pi pi-history mr-1"></i>
            <span v-if="entry.lastVisitDate">
              Dernière visite : {{ new Date(entry.lastVisitDate).toLocaleDateString('fr-FR') }}
            </span>
            <span v-else>Nouveau patient</span>
          </p>
        </button>
      </div>
    </div>

    <!-- Active Profile Loader state -->
    <div v-if="loadingProfile" class="py-24 flex flex-col items-center justify-center text-slate-400 gap-2">
      <i class="pi pi-spin pi-spinner text-3xl text-sky-500"></i>
      <span class="text-xs font-semibold">Chargement des fiches cliniques...</span>
    </div>

    <!-- No active patient state -->
    <div v-else-if="!patient" class="bg-white rounded-xl border border-slate-200/60 p-12 text-center max-w-xl mx-auto my-8 space-y-4">
      <div class="w-16 h-16 bg-sky-50 text-sky-600 rounded-full flex items-center justify-center mx-auto shadow-inner">
        <i class="pi pi-user text-2xl"></i>
      </div>
      <h3 class="text-sm font-extrabold text-slate-800 uppercase tracking-wider">Aucun Patient Sélectionné</h3>
      <p class="text-xs text-slate-500 leading-relaxed max-w-sm mx-auto font-medium">
        Veuillez choisir un patient dans le sélecteur ci-dessus pour accéder à son schéma dentaire interactif, ses antécédents, ses prescriptions et ses observations.
      </p>
    </div>

    <!-- Active clinical layout -->
    <div v-else class="space-y-6">
      
      <!-- Highlight critical antecedents top of screen -->
      <div class="bg-rose-50 border border-rose-200/70 rounded-xl p-5 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div class="flex items-start gap-3">
          <div class="w-9 h-9 rounded-lg bg-rose-100 border border-rose-200 text-rose-700 flex items-center justify-center flex-shrink-0 shadow-sm mt-0.5">
            <i class="pi pi-exclamation-triangle text-base"></i>
          </div>
          <div>
            <h4 class="text-xs font-extrabold text-rose-900 uppercase tracking-wider">Alerte Médicale & Antécédents Critiques</h4>
            <p class="text-xs text-rose-700 font-semibold mt-1 leading-normal">
              {{ patient.antecedentsMedicaux || 'Aucune allergie ou maladie chronique majeure signalée pour ce patient.' }}
            </p>
          </div>
        </div>
        <div class="flex items-center gap-2 bg-white/80 border border-rose-100 rounded-lg px-3 py-1.5 text-xs font-bold text-slate-700 shadow-sm">
          <span class="text-[9px] uppercase text-slate-400">Sang :</span>
          <span class="text-rose-700 text-sm font-extrabold">{{ patient.groupSanguin || 'N/A' }}</span>
        </div>
      </div>

      <!-- Main Columns: FDI Schema (Left/Top) and Notes/Prescriptions (Right/Bottom) -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        <!-- Left 2 cols: Dental grid & treatment logger -->
        <div class="lg:col-span-2 space-y-6">
          
          <!-- interactive schema container -->
          <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6 space-y-6">
            <div class="flex items-center justify-between border-b border-slate-100 pb-3">
              <h3 class="text-xs font-extrabold text-slate-800 uppercase tracking-wider">Schéma Dentaire Interactif (FDI)</h3>
              <span class="text-xs text-slate-400 font-bold uppercase">Patient: {{ patient.prenom }} {{ patient.nom }}</span>
            </div>

            <!-- Jaw schema grid -->
            <div class="bg-slate-50/40 border border-slate-100 rounded-xl p-6 overflow-x-auto">
              <h4 class="text-[9px] font-bold text-slate-400 uppercase tracking-widest text-center mb-6">Machoîre Supérieure</h4>
              
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

                <!-- Center Divider -->
                <div class="w-[2px] h-10 bg-slate-350"></div>

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

              <h4 class="text-[9px] font-bold text-slate-400 uppercase tracking-widest text-center mb-6">Machoîre Inférieure</h4>

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

                <!-- Center Divider -->
                <div class="w-[2px] h-10 bg-slate-350"></div>

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

              <!-- Legends -->
              <div class="flex justify-center gap-6 text-[10px] text-slate-400 font-bold uppercase tracking-wider mt-6 pt-4 border-t border-slate-100">
                <span class="flex items-center gap-1.5"><span class="w-2.5 h-2.5 rounded bg-white border border-slate-250"></span>Sain</span>
                <span class="flex items-center gap-1.5"><span class="w-2.5 h-2.5 rounded bg-emerald-50 border border-emerald-200"></span>Soigné</span>
                <span class="flex items-center gap-1.5"><span class="w-2.5 h-2.5 rounded bg-rose-50 border border-rose-200"></span>Pathologie / Retrait</span>
              </div>
            </div>

            <!-- Treatment logger grid split -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6 pt-2">
              <!-- Tooth history -->
              <div class="border border-slate-200/60 rounded-xl p-5 bg-slate-50/20">
                <h4 class="text-xs font-extrabold text-slate-800 uppercase tracking-wider mb-4">
                  Dent {{ selectedTooth || '(Sélectionnez...)' }} — Historique clinique
                </h4>

                <div v-if="!selectedTooth" class="text-center text-slate-400 text-xs font-medium py-12">
                  Veuillez cliquer sur une dent du schéma FDI ci-dessus pour inspecter son historique de soins.
                </div>
                <div v-else-if="selectedToothTreatments.length === 0" class="text-center text-slate-450 text-xs font-medium py-12 italic">
                  Aucun traitement clinique enregistré pour la dent {{ selectedTooth }}.
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
                    <p class="text-slate-500 leading-normal mt-1.5 font-medium border-t border-slate-5 pt-1.5">
                      {{ soin.notes || 'Pas d\'observation saisie.' }}
                    </p>
                  </div>
                </div>
              </div>

              <!-- Log new act -->
              <div class="border border-slate-200/60 rounded-xl p-5 bg-slate-50/20">
                <h4 class="text-xs font-extrabold text-slate-800 uppercase tracking-wider mb-4">
                  Enregistrer un Soin sur la Dent {{ selectedTooth || '...' }}
                </h4>

                <form @submit.prevent="handleAddSoin" class="space-y-4">
                  <!-- Act selection -->
                  <div class="space-y-1">
                    <label class="text-[9px] font-bold text-slate-500 uppercase tracking-wide">Acte Médical *</label>
                    <Dropdown 
                      v-model="newSoinForm.acteMedicalId"
                      :options="actOptions"
                      optionLabel="label"
                      optionValue="id"
                      filter
                      placeholder="Choisir l'acte"
                      :disabled="!selectedTooth"
                      @change="onActeSelect"
                      class="w-full text-xs font-semibold"
                    />
                  </div>

                  <div class="grid grid-cols-2 gap-4">
                    <!-- Face selection -->
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
                        class="w-full text-xs font-semibold"
                      />
                    </div>
                    <!-- Cost applied -->
                    <div class="space-y-1">
                      <label class="text-[9px] font-bold text-slate-500 uppercase tracking-wide">Tarif Appliqué (DT)</label>
                      <input 
                        v-model.number="newSoinForm.prixApplique"
                        type="number"
                        step="0.01"
                        required
                        :disabled="!selectedTooth"
                        class="w-full py-2 px-3 text-xs bg-white border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-850 font-semibold"
                      />
                    </div>
                  </div>

                  <!-- Notes observation -->
                  <div class="space-y-1">
                    <label class="text-[9px] font-bold text-slate-500 uppercase tracking-wide">Observations / Notes</label>
                    <textarea 
                      v-model="newSoinForm.notes"
                      rows="2"
                      :disabled="!selectedTooth"
                      placeholder="Détails cliniques de l'intervention..."
                      class="w-full py-2 px-3 text-xs bg-white border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800 resize-none font-semibold"
                    ></textarea>
                  </div>

                  <!-- Submit -->
                  <button 
                    type="submit"
                    :disabled="!selectedTooth || savingSoin"
                    class="w-full py-2.5 bg-slate-900 hover:bg-slate-800 disabled:bg-slate-200 text-white font-semibold rounded-lg text-xs transition-all shadow-sm flex items-center justify-center gap-1.5 cursor-pointer disabled:cursor-not-allowed"
                  >
                    <i class="pi pi-save"></i>
                    <span>Valider l'Acte Clinique</span>
                  </button>
                </form>
              </div>
            </div>

          </div>

        </div>

        <!-- Right 1 col: Notes journal & Prescription form -->
        <div class="space-y-6">

          <!-- Clôture & Facturation -->
          <div class="bg-slate-900 rounded-xl shadow-sm p-6 space-y-4 text-white">
            <div class="flex items-center justify-between">
              <h3 class="text-xs font-extrabold uppercase tracking-wider flex items-center gap-2">
                <i class="pi pi-flag-fill text-emerald-400"></i>
                <span>Clôture de la séance</span>
              </h3>
            </div>
            <div class="flex items-end justify-between">
              <div>
                <p class="text-[10px] uppercase tracking-wider text-slate-400 font-bold">Total des soins</p>
                <p class="text-2xl font-extrabold tracking-tight">{{ consultationTotal.toFixed(2) }} <span class="text-sm text-slate-400">DT</span></p>
              </div>
              <span class="text-[10px] text-slate-400 font-semibold">{{ consommations.length }} article(s) consommé(s)</span>
            </div>
            <button
              @click="handleFinalize"
              :disabled="finalizing || consultationTotal <= 0"
              class="w-full py-2.5 bg-emerald-500 hover:bg-emerald-600 disabled:bg-slate-700 disabled:text-slate-500 text-white font-bold rounded-lg text-xs transition-all shadow-sm flex items-center justify-center gap-1.5 cursor-pointer disabled:cursor-not-allowed"
            >
              <i v-if="finalizing" class="pi pi-spin pi-spinner"></i>
              <i v-else class="pi pi-send"></i>
              <span>Terminer & envoyer en caisse</span>
            </button>
            <p class="text-[10px] text-slate-400 leading-normal text-center">
              Génère une facture unique et notifie la secrétaire du montant à encaisser.
            </p>
          </div>

          <!-- Articles consommés (stock) -->
          <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6 space-y-4">
            <h3 class="text-xs font-extrabold text-slate-800 uppercase tracking-wider border-b border-slate-100 pb-3 flex items-center gap-2">
              <i class="pi pi-box text-amber-500"></i>
              <span>Articles consommés</span>
            </h3>

            <!-- Recipe suggestions for the selected act -->
            <div v-if="recetteSuggestions.length > 0" class="flex flex-wrap gap-1.5">
              <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wide w-full">Suggestions (acte sélectionné)</span>
              <button
                v-for="sug in recetteSuggestions"
                :key="sug.id"
                @click="useSuggestion(sug)"
                class="px-2 py-1 bg-amber-50 hover:bg-amber-100 border border-amber-200 text-amber-800 rounded-lg text-[10px] font-bold transition-all cursor-pointer"
              >
                + {{ sug.articleNom || ('Article #' + sug.articleId) }} ×{{ sug.quantiteRequise }}
              </button>
            </div>

            <!-- Add form -->
            <div class="grid grid-cols-1 gap-3">
              <Dropdown
                v-model="newConsommationForm.articleId"
                :options="articleOptions"
                optionLabel="label"
                optionValue="id"
                filter
                placeholder="Choisir un article du stock"
                class="w-full text-xs font-semibold"
              />
              <div class="flex gap-2">
                <input
                  v-model.number="newConsommationForm.quantite"
                  type="number"
                  min="1"
                  class="w-24 py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800 font-semibold"
                />
                <button
                  @click="handleAddConsommation"
                  :disabled="savingConsommation"
                  class="flex-1 py-2 bg-slate-900 hover:bg-slate-800 text-white font-semibold rounded-lg text-xs transition-all shadow-sm flex items-center justify-center gap-1.5 cursor-pointer disabled:opacity-50"
                >
                  <i v-if="savingConsommation" class="pi pi-spin pi-spinner text-xs"></i>
                  <i v-else class="pi pi-plus text-xs"></i>
                  <span>Consommer</span>
                </button>
              </div>
            </div>

            <!-- Consumed list -->
            <div class="space-y-2 pt-2 border-t border-slate-100 max-h-48 overflow-y-auto">
              <div v-if="consommations.length === 0" class="text-center text-slate-400 text-[11px] font-medium py-4 italic">
                Aucun article consommé pour cette séance.
              </div>
              <div
                v-for="c in consommations"
                :key="c.id"
                class="flex items-center justify-between p-2 bg-slate-50 rounded-lg text-[11px]"
              >
                <div class="font-semibold text-slate-700">
                  {{ c.articleNom }}
                  <span class="text-slate-400 font-bold">×{{ c.quantite }} {{ c.articleUnite || '' }}</span>
                </div>
                <button
                  @click="handleDeleteConsommation(c)"
                  class="w-6 h-6 rounded-md hover:bg-rose-50 text-rose-500 flex items-center justify-center transition-colors cursor-pointer"
                  title="Annuler (remet en stock)"
                >
                  <i class="pi pi-trash text-[10px]"></i>
                </button>
              </div>
            </div>
          </div>

          <!-- Journal des Notes Cliniques -->
          <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6 space-y-4">
            <h3 class="text-xs font-extrabold text-slate-800 uppercase tracking-wider border-b border-slate-100 pb-3 flex items-center gap-2">
              <i class="pi pi-pencil text-slate-400"></i>
              <span>Journal des Notes Cliniques</span>
            </h3>

            <textarea 
              v-model="notesCliniques"
              rows="4"
              placeholder="Rédiger le compte-rendu textuel de la séance de soin..."
              class="w-full py-2.5 px-3.5 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl outline-none text-slate-800 resize-none font-semibold leading-relaxed"
            ></textarea>

            <button 
              @click="saveNotesCliniques"
              :disabled="savingNotes"
              class="w-full py-2 bg-slate-950 hover:bg-slate-800 text-white font-semibold rounded-lg text-xs transition-all shadow-sm flex items-center justify-center gap-1.5 cursor-pointer disabled:opacity-50"
            >
              <i v-if="savingNotes" class="pi pi-spin pi-spinner text-xs"></i>
              <i v-else class="pi pi-check text-xs"></i>
              <span>Enregistrer Notes Séance</span>
            </button>

            <!-- Latest notes list -->
            <div class="space-y-2.5 pt-2 border-t border-slate-100 max-h-40 overflow-y-auto">
              <p class="text-[9px] font-bold text-slate-400 uppercase tracking-wide">Dernières consultations</p>
              <div 
                v-for="c in consultations" 
                :key="c.id" 
                class="p-2 bg-slate-50 rounded-lg text-[10px] text-slate-650"
              >
                <div class="flex justify-between font-bold text-slate-500">
                  <span>Consultation #{{ c.id }}</span>
                  <span>{{ new Date(c.dateConsultation).toLocaleDateString('fr-FR') }}</span>
                </div>
                <p class="mt-1 font-semibold text-slate-700 leading-normal">{{ c.notesObservations }}</p>
              </div>
            </div>
          </div>

          <!-- Formulaire d'Ordonnance -->
          <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6 space-y-4">
            <h3 class="text-xs font-extrabold text-slate-800 uppercase tracking-wider border-b border-slate-100 pb-3 flex items-center gap-2">
              <i class="pi pi-file-pdf text-rose-500"></i>
              <span>Formulaire d'Ordonnance</span>
            </h3>

            <textarea 
              v-model="prescriptionText"
              rows="6"
              placeholder="Ex:
1. Clamoxyl 1g (1 gélule matin et soir pendant 6 jours)
2. Doliprane 1g (1 comp toutes les 6h en cas de douleur)"
              class="w-full py-2.5 px-3.5 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl outline-none text-slate-800 resize-none font-mono font-semibold leading-relaxed"
            ></textarea>

            <div class="grid grid-cols-2 gap-3">
              <button 
                @click="savePrescription"
                :disabled="savingPrescription"
                class="py-2 px-3 border border-slate-200 hover:bg-slate-50 text-slate-700 font-semibold rounded-lg text-xs transition-all shadow-sm flex items-center justify-center gap-1 cursor-pointer disabled:opacity-50"
              >
                <i v-if="savingPrescription" class="pi pi-spin pi-spinner text-xs"></i>
                <i v-else class="pi pi-save text-xs"></i>
                <span>Enregistrer</span>
              </button>

              <button 
                @click="printPrescription"
                class="py-2 px-3 bg-rose-600 hover:bg-rose-700 text-white font-semibold rounded-lg text-xs transition-all shadow-sm flex items-center justify-center gap-1 cursor-pointer"
              >
                <i class="pi pi-print text-xs"></i>
                <span>Imprimer PDF</span>
              </button>
            </div>

            <!-- Latest ordonnances -->
            <div class="space-y-2.5 pt-2 border-t border-slate-100 max-h-40 overflow-y-auto">
              <p class="text-[9px] font-bold text-slate-400 uppercase tracking-wide">Historique Ordonnances</p>
              <div 
                v-for="o in ordonnances" 
                :key="o.id" 
                class="p-2 bg-slate-50 rounded-lg text-[10px] text-slate-650"
              >
                <div class="flex justify-between font-bold text-slate-500">
                  <span>ORD-{{ o.id }}</span>
                  <span>{{ new Date(o.dateEmission).toLocaleDateString('fr-FR') }}</span>
                </div>
                <p class="mt-1 font-semibold text-slate-750 truncate">{{ o.traitement }}</p>
              </div>
            </div>
          </div>

        </div>

      </div>

    </div>

  </div>
</template>
