<script setup>
import { ref, onMounted, computed } from 'vue'
import { toast } from 'vue3-toastify'
import api from '@/services/api'


const loading = ref(false)
const processing = ref(false)
const factures = ref([])

// Payment Modal State
const showModal = ref(false)
const selectedFacture = ref(null)
const payForm = ref({
  montant: 0,
  modePaiement: 'Espèces'
})

const modeOptions = [
  { value: 'Espèces', label: '💵 Espèces' },
  { value: 'Chèque', label: '✍️ Chèque' },
  { value: 'Carte', label: '💳 Carte Bancaire' }
]

const fetchFactures = async () => {
  loading.value = true
  console.log('[API Request] GET /factures')
  try {
    const res = await api.get('/factures')
    console.log(`[API Response] GET /factures | Status: ${res.status}`, res.data)
    factures.value = res.data?.items || res.data || []
  } catch (error) {
    console.error('[API Error] fetchFactures failed:', error)
    toast.error(`Erreur de chargement\nImpossible de récupérer les factures. Vérifiez la connexion au serveur.`, { autoClose: 5000 })
  } finally {
    loading.value = false
  }
}

const openPaymentModal = (facture) => {
  selectedFacture.value = facture
  payForm.value.montant = facture.montantTotal - facture.montantPaye
  payForm.value.modePaiement = 'Espèces'
  showModal.value = true
}

const closePaymentModal = () => {
  showModal.value = false
  selectedFacture.value = null
}

const handlePayInvoice = async () => {
  if (!selectedFacture.value) return
  if (payForm.value.montant <= 0) {
    toast.warning(`Montant invalide\nVeuillez saisir un montant supérieur à 0 DT.`, { autoClose: 3000 })
    return
  }

  const remaining = selectedFacture.value.montantTotal - selectedFacture.value.montantPaye
  if (payForm.value.montant > remaining) {
    toast.warning(`Montant excessif\nLe montant ne peut dépasser le reste à payer (${remaining} DT).`, { autoClose: 3000 })
    return
  }

  processing.value = true
  console.log(`[API Request] POST /paiements | FactureId: ${selectedFacture.value.id}`)
  try {
    const payload = {
      datePaiement: new Date().toISOString(),
      montant: payForm.value.montant,
      modePaiement: payForm.value.modePaiement,
      factureId: selectedFacture.value.id
    }
    const res = await api.post('/paiements', payload)
    console.log(`[API Response] POST /paiements | Status: ${res.status}`, res.data)
    
    const isFull = payForm.value.montant === remaining
    toast.success(`Règlement enregistré\n${isFull 
        ? `La facture ${selectedFacture.value.numeroFacture} a été soldée.` 
        : `Paiement partiel enregistré pour la facture ${selectedFacture.value.numeroFacture}.`}`, { autoClose: 3000 })
    closePaymentModal()
    fetchFactures()
  } catch (error) {
    console.error('[API Error] payInvoice failed:', error)
    toast.error(`Erreur de paiement\nImpossible d'enregistrer le règlement de la facture ${selectedFacture.value.numeroFacture}.`, { autoClose: 5000 })
  } finally {
    processing.value = false
  }
}

onMounted(() => {
  fetchFactures()
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    
    <!-- Header -->
    <div class="bg-white rounded-2xl border border-slate-200/65 shadow-sm p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4 relative overflow-hidden">
      <div class="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-emerald-500/5 to-transparent rounded-full -mr-16 -mt-16 pointer-events-none"></div>
      <div>
        <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-emerald-50 text-emerald-700 border border-emerald-100 text-[10px] font-bold uppercase tracking-wider">
          Logistique & Trésorerie
        </span>
        <h1 class="text-xl font-extrabold text-slate-900 tracking-tight mt-3">
          Suivi de la Facturation
        </h1>
        <p class="text-xs text-slate-500 mt-1">Enregistrez les encaissements, gérez le reste à payer et suivez l'état des factures.</p>
      </div>
    </div>

    <!-- Data Table Card -->
    <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm overflow-hidden">
      
      <div v-if="loading" class="py-20 flex flex-col items-center justify-center text-slate-400 gap-2">
        <i class="pi pi-spin pi-spinner text-3xl text-sky-500"></i>
        <span class="text-xs font-semibold">Récupération du grand livre comptable...</span>
      </div>

      <div v-else class="divide-y divide-slate-100">
        <!-- Header -->
        <div class="hidden md:flex items-center px-6 py-3 bg-slate-50/50 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
          <div class="w-1/6">Date Émission</div>
          <div class="w-1/6">N° Facture</div>
          <div class="w-1/4">Patient</div>
          <div class="w-1/8 text-right">Reste à payer</div>
          <div class="w-1/8 text-right">Montant Total</div>
          <div class="w-1/6 text-center">Statut</div>
          <div class="w-1/12 text-right">Action</div>
        </div>

        <!-- Rows -->
        <div 
          v-for="fac in factures" 
          :key="fac.id"
          class="flex flex-col md:flex-row md:items-center px-6 py-4 hover:bg-slate-50/50 transition-colors text-xs font-semibold text-slate-700 gap-2 md:gap-0"
        >
          <div class="w-full md:w-1/6 text-slate-500">
            {{ new Date(fac.dateEmission).toLocaleDateString('fr-FR') }}
          </div>
          <div class="w-full md:w-1/6 font-extrabold text-slate-900">
            {{ fac.numeroFacture }}
          </div>
          <div class="w-full md:w-1/4 font-extrabold text-slate-800">
            {{ fac.patientNomComplet }}
          </div>
          <div class="w-full md:w-1/8 text-right font-bold text-rose-500">
            {{ (fac.montantTotal - fac.montantPaye).toFixed(2) }} DT
          </div>
          <div class="w-full md:w-1/8 text-right font-extrabold text-slate-950">
            {{ fac.montantTotal.toFixed(2) }} DT
          </div>
          <div class="w-full md:w-1/6 text-center">
            <span 
              class="px-2.5 py-1 text-[9px] font-bold rounded-full uppercase tracking-wider border"
              :class="[
                fac.statutPaiement === 'Payé' 
                  ? 'bg-emerald-50 text-emerald-700 border-emerald-100' 
                  : fac.statutPaiement === 'Partiel' 
                    ? 'bg-amber-50 text-amber-700 border-amber-100' 
                    : 'bg-rose-50 text-rose-700 border-rose-100'
              ]"
            >
              {{ fac.statutPaiement }}
            </span>
          </div>
          <div class="w-full md:w-1/12 flex justify-end">
            <button 
              v-if="fac.statutPaiement !== 'Payé'"
              @click="openPaymentModal(fac)"
              class="px-2.5 py-1 bg-slate-950 hover:bg-slate-800 text-white rounded-lg text-[10px] font-bold transition-all shadow-sm cursor-pointer"
            >
              Encaisser
            </button>
            <span v-else class="text-[10px] text-slate-400 font-bold italic">Régler</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Payment Modal Dialog -->
    <div 
      v-if="showModal" 
      class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4 animate-fade-in font-sans"
    >
      <div class="bg-white border border-slate-200 rounded-2xl shadow-2xl max-w-md w-full overflow-hidden">
        <!-- Header -->
        <div class="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50/50">
          <div>
            <h3 class="text-sm font-extrabold text-slate-900 tracking-tight">Enregistrer un Règlement</h3>
            <p class="text-[10px] text-slate-450 font-semibold mt-0.5">Facture: {{ selectedFacture?.numeroFacture }} &bull; Patient: {{ selectedFacture?.patientNomComplet }}</p>
          </div>
          <button 
            type="button" 
            @click="closePaymentModal" 
            class="w-8 h-8 rounded-lg hover:bg-slate-100 flex items-center justify-center text-slate-400 hover:text-slate-700 cursor-pointer"
          >
            <i class="pi pi-times text-xs"></i>
          </button>
        </div>

        <!-- Form Body -->
        <form @submit.prevent="handlePayInvoice" class="p-6 space-y-4 text-xs font-semibold text-slate-700">
          <!-- Remaining balance preview -->
          <div class="p-3 bg-amber-50 border border-amber-100 rounded-lg flex justify-between items-center text-amber-900">
            <span>Reste à percevoir :</span>
            <span class="text-sm font-extrabold">{{ (selectedFacture.montantTotal - selectedFacture.montantPaye).toFixed(2) }} DT</span>
          </div>

          <!-- Payment amount input -->
          <div class="space-y-1.5">
            <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Montant à Encaisser (DT) *</label>
            <input 
              v-model.number="payForm.montant"
              type="number" 
              step="0.01"
              required
              class="w-full py-2.5 px-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800 font-extrabold text-sm"
            />
          </div>

          <!-- Payment mode dropdown -->
          <div class="space-y-1.5">
            <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Mode de Règlement *</label>
            <select 
              v-model="payForm.modePaiement"
              required
              class="w-full py-2.5 px-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800 font-semibold cursor-pointer"
            >
              <option 
                v-for="opt in modeOptions" 
                :key="opt.value" 
                :value="opt.value"
              >
                {{ opt.label }}
              </option>
            </select>
          </div>

          <!-- Buttons -->
          <div class="flex justify-end gap-3 pt-3 border-t border-slate-100">
            <button 
              type="button" 
              @click="closePaymentModal"
              class="px-4 py-2 border border-slate-200 text-xs font-semibold text-slate-650 hover:bg-slate-50 rounded-xl transition-all cursor-pointer"
            >
              Annuler
            </button>
            <button 
              type="submit" 
              :disabled="processing"
              class="px-4 py-2 bg-slate-900 hover:bg-slate-800 disabled:bg-slate-250 text-white text-xs font-semibold rounded-xl transition-all cursor-pointer shadow-md flex items-center gap-1.5"
            >
              <i v-if="processing" class="pi pi-spin pi-spinner"></i>
              Valider l'encaissement
            </button>
          </div>
        </form>
      </div>
    </div>

  </div>
</template>
