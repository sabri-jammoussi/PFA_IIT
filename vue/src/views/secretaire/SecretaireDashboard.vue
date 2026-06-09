<script setup>
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const handleNewPatient = () => {
  router.push({ name: 'patients', query: { add: 'true' } })
}
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    <!-- Header -->
    <div class="bg-white rounded-2xl border border-slate-200/65 shadow-sm p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-6 relative overflow-hidden">
      <div class="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-sky-500/5 to-transparent rounded-full -mr-16 -mt-16 pointer-events-none"></div>
      <div>
        <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-indigo-50 text-indigo-700 border border-indigo-100 text-[10px] font-bold uppercase tracking-wider">
          Accueil & Secrétariat
        </span>
        <h1 class="text-xl font-extrabold text-slate-900 tracking-tight mt-3">
          Bonjour, {{ authStore.fullName }}
        </h1>
        <p class="text-xs text-slate-500 mt-1">Gestion des admissions, planification de l'agenda et encaissements des honoraires.</p>
      </div>
      <button 
        @click="handleNewPatient"
        class="px-4 py-2.5 bg-slate-900 hover:bg-slate-800 text-white text-xs font-semibold rounded-xl transition-all shadow-md shadow-slate-900/10 cursor-pointer flex-shrink-0 flex items-center gap-1.5"
      >
        <i class="pi pi-user-plus text-xs"></i>
        <span>Nouveau Patient</span>
      </button>
    </div>

    <!-- Core administrative panels -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
      <!-- Waiting Room -->
      <div class="bg-white p-6 rounded-xl border border-slate-200/65 shadow-sm">
        <h3 class="text-xs font-extrabold text-slate-850 uppercase tracking-wider mb-4 border-b border-slate-100 pb-3 flex items-center gap-2">
          <i class="pi pi-clock text-slate-400"></i>
          <span>Salle d'attente (3 Patients)</span>
        </h3>
        <div class="space-y-3">
          <div class="flex justify-between items-center p-3 bg-slate-50 rounded-xl border border-slate-100 text-xs font-semibold">
            <span class="text-slate-800">Sophie Martin</span>
            <span class="text-[9px] text-amber-600 font-bold bg-amber-50 px-2 py-0.5 rounded border border-amber-100">Arrivé (Attente)</span>
          </div>
          <div class="flex justify-between items-center p-3 bg-slate-50 rounded-xl border border-slate-100 text-xs font-semibold">
            <span class="text-slate-800">Marc Lefevre</span>
            <span class="text-[9px] text-amber-600 font-bold bg-amber-50 px-2 py-0.5 rounded border border-amber-100">Arrivé (Attente)</span>
          </div>
          <div class="flex justify-between items-center p-3 bg-slate-50 rounded-xl border border-slate-100 text-xs font-semibold">
            <span class="text-slate-800">Amine Ben Ali</span>
            <span class="text-[9px] text-emerald-600 font-bold bg-emerald-50 px-2 py-0.5 rounded border border-emerald-100">En cours de soin</span>
          </div>
        </div>
      </div>

      <!-- Financial shortcuts -->
      <div class="bg-white p-6 rounded-xl border border-slate-200/65 shadow-sm flex flex-col justify-between">
        <div>
          <h3 class="text-xs font-extrabold text-slate-850 uppercase tracking-wider mb-4 border-b border-slate-100 pb-3 flex items-center gap-2">
            <i class="pi pi-wallet text-slate-400"></i>
            <span>Derniers Impayés & Règlements</span>
          </h3>
          <p class="text-xs text-slate-500 font-medium leading-relaxed">
            Toutes les factures de la journée courante ont été encaissées en totalité ou réglées en partiel. Aucun dossier bloquant en attente d'encaissement immédiat.
          </p>
        </div>
        
        <div class="mt-6 pt-4 border-t border-slate-100">
          <router-link 
            :to="{ name: 'billing' }"
            class="text-[10px] text-sky-600 hover:text-sky-700 font-bold block uppercase tracking-wider cursor-pointer"
          >
            Consulter le grand livre comptable
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>
