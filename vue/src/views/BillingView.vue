<script setup>
import { ref, onMounted } from 'vue'
import { useToast } from 'primevue/usetoast'
import api from '@/services/api'

const toast = useToast()
const loading = ref(false)
const factures = ref([])

const fetchFactures = async () => {
  loading.value = true
  console.log('[API Request] GET /factures')
  try {
    const res = await api.get('/factures')
    console.log(`[API Response] GET /factures | Status: ${res.status}`, res.data)
    factures.value = res.data?.items || res.data || []
  } catch (error) {
    console.warn("[API Error] fetchFactures failed, falling back to mockups:", error)
    loadMockBilling()
  } finally {
    loading.value = false
  }
}

const loadMockBilling = () => {
  factures.value = [
    { id: 401, numeroFacture: "FAC-2026-001", dateEmission: "2026-02-14", montantTotal: 90.00, montantPaye: 90.00, statutPaiement: "Payé", patientNomComplet: "Sophie Martin" },
    { id: 402, numeroFacture: "FAC-2026-002", dateEmission: "2026-03-22", montantTotal: 150.00, montantPaye: 50.00, statutPaiement: "Partiel", patientNomComplet: "Luc Durand" },
    { id: 403, numeroFacture: "FAC-2026-003", dateEmission: "2026-05-18", montantTotal: 80.00, montantPaye: 0.00, statutPaiement: "Impayé", patientNomComplet: "Marc Lefevre" },
    { id: 404, numeroFacture: "FAC-2026-004", dateEmission: "2026-06-05", montantTotal: 650.00, montantPaye: 650.00, statutPaiement: "Payé", patientNomComplet: "Amine Ben Ali" }
  ]
}

const payInvoice = (facture) => {
  facture.montantPaye = facture.montantTotal
  facture.statutPaiement = "Payé"
  toast.add({
    severity: 'success',
    summary: 'Règlement validé',
    detail: `La facture ${facture.numeroFacture} a été réglée en totalité.`,
    life: 3000
  })
}

onMounted(() => {
  fetchFactures()
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    
    <div>
      <h1 class="text-xl font-extrabold text-slate-900 tracking-tight">Facturation & Honoraires</h1>
      <p class="text-xs text-slate-500 mt-1">Générez et suivez les règlements des patients.</p>
    </div>

    <!-- Data Table Card -->
    <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm overflow-hidden">
      
      <div v-if="loading" class="py-20 flex flex-col items-center justify-center text-slate-400 gap-2">
        <i class="pi pi-spin pi-spinner text-3xl text-sky-500"></i>
        <span class="text-xs font-semibold">Récupération des factures...</span>
      </div>

      <div v-else class="divide-y divide-slate-100">
        <!-- Header -->
        <div class="hidden md:flex items-center px-6 py-3 bg-slate-50/50 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
          <div class="w-1/6">Date Émission</div>
          <div class="w-1/6">N° Facture</div>
          <div class="w-1/4">Patient</div>
          <div class="w-1/6 text-right">Montant Total</div>
          <div class="w-1/6 text-center">Statut</div>
          <div class="w-1/8 text-right">Action</div>
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
          <div class="w-full md:w-1/6 text-right font-extrabold text-slate-950">
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
          <div class="w-full md:w-1/8 flex justify-end">
            <button 
              v-if="fac.statutPaiement !== 'Payé'"
              @click="payInvoice(fac)"
              class="px-2.5 py-1 bg-slate-900 hover:bg-slate-800 text-white rounded-lg text-[10px] font-bold transition-all shadow-sm cursor-pointer"
            >
              Encaisser
            </button>
            <span v-else class="text-[10px] text-slate-400 font-bold italic">Régler</span>
          </div>
        </div>

      </div>

    </div>

  </div>
</template>
