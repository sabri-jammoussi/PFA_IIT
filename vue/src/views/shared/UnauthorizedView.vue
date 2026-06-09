<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

const goBack = () => {
  router.go(-1)
}
</script>

<template>
  <div class="min-h-[70vh] flex flex-col items-center justify-center p-6 text-center font-sans animate-fade-in">
    <div class="w-16 h-16 bg-rose-50 border border-rose-100 rounded-2xl flex items-center justify-center text-rose-600 mb-6 shadow-sm">
      <i class="pi pi-exclamation-triangle text-2xl animate-bounce"></i>
    </div>
    <h1 class="text-lg font-extrabold text-slate-900 tracking-tight">Accès Restreint</h1>
    <p class="text-slate-500 max-w-sm mt-2.5 text-xs font-semibold leading-relaxed">
      Votre rôle d'utilisateur ne vous octroie pas les autorisations nécessaires pour consulter les données cliniques ou d'administration de cette section.
    </p>
    
    <button 
      @click="goBack" 
      class="mt-8 px-4 py-2 bg-slate-900 hover:bg-slate-800 text-white text-xs font-semibold rounded-xl shadow-md shadow-slate-900/10 cursor-pointer transition-all flex items-center gap-1.5"
    >
      <i class="pi pi-arrow-left text-[10px]"></i>
      <span>Retourner à la page précédente</span>
    </button>
  </div>
</template>
