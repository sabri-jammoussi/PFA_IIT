<script setup>
import { ref, onMounted } from 'vue'
import api from '@/services/api'

const loading = ref(false)
const acts = ref([])

const fetchActs = async () => {
  loading.value = true
  console.log('[API Request] GET /actes-medicaux')
  try {
    const res = await api.get('/actes-medicaux')
    console.log(`[API Response] GET /actes-medicaux | Status: ${res.status}`, res.data)
    acts.value = res.data?.items || res.data || []
  } catch (error) {
    console.warn("[API Error] fetchActs failed, falling back to mockups:", error)
    loadMockActs()
  } finally {
    loading.value = false
  }
}

const loadMockActs = () => {
  acts.value = [
    { id: 1, codeNomenclature: "C", libelle: "Consultation générale & Diagnostic buccal", tarifDeBase: 50.00 },
    { id: 2, codeNomenclature: "SC12", libelle: "Détartrage, nettoyage prophylactique et polissage", tarifDeBase: 80.00 },
    { id: 3, codeNomenclature: "SC20", libelle: "Restauration carie composite direct (1 face)", tarifDeBase: 90.00 },
    { id: 4, codeNomenclature: "HB04", libelle: "Traitement endodontique canalaire (dent antérieure)", tarifDeBase: 150.00 },
    { id: 5, codeNomenclature: "HB08", libelle: "Traitement endodontique canalaire (dent postérieure)", tarifDeBase: 220.00 },
    { id: 6, codeNomenclature: "HB12", libelle: "Extraction dentaire simple non chirurgicale", tarifDeBase: 100.00 },
    { id: 7, codeNomenclature: "SPR50", libelle: "Pose de couronne unitaire céramo-métallique", tarifDeBase: 650.00 },
    { id: 8, codeNomenclature: "SPR75", libelle: "Implant dentaire titane de base (hors couronne)", tarifDeBase: 1200.00 }
  ]
}

onMounted(() => {
  fetchActs()
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    
    <div>
      <h1 class="text-xl font-extrabold text-slate-900 tracking-tight">Catalogue des Actes Médicaux</h1>
      <p class="text-xs text-slate-500 mt-1">Guide de nomenclature clinique de référence et tarifs de base applicables.</p>
    </div>

    <!-- Data List -->
    <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm overflow-hidden">
      
      <div v-if="loading" class="py-20 flex flex-col items-center justify-center text-slate-400 gap-2">
        <i class="pi pi-spin pi-spinner text-3xl text-sky-500"></i>
        <span class="text-xs font-semibold">Chargement de la nomenclature...</span>
      </div>

      <div v-else class="divide-y divide-slate-100">
        <!-- Header -->
        <div class="hidden md:flex items-center px-6 py-3 bg-slate-50/50 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
          <div class="w-1/6">Code Nomenclature</div>
          <div class="w-7/12">Libellé de l'Acte Clinique</div>
          <div class="w-1/6 text-right">Tarif de Base</div>
        </div>

        <!-- Rows -->
        <div 
          v-for="act in acts" 
          :key="act.id"
          class="flex flex-col md:flex-row md:items-center px-6 py-4 hover:bg-slate-50/50 transition-colors text-xs font-semibold text-slate-700 gap-2 md:gap-0"
        >
          <div class="w-full md:w-1/6">
            <span class="px-2 py-1 bg-slate-100 text-slate-800 rounded font-mono font-extrabold">
              {{ act.codeNomenclature || 'N/A' }}
            </span>
          </div>
          <div class="w-full md:w-7/12 font-extrabold text-slate-900">
            {{ act.libelle }}
          </div>
          <div class="w-full md:w-1/6 text-right font-extrabold text-slate-950">
            {{ act.tarifDeBase.toFixed(2) }} DT
          </div>
        </div>

      </div>

    </div>

  </div>
</template>
