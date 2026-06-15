<script setup>
import { useRouter } from 'vue-router'

const router = useRouter()

const goBack = () => {
  router.go(-1)
}
</script>

<template>
  <div class="min-h-screen w-full flex flex-col justify-center items-center p-6 bg-white font-sans animate-fade-in">
    <div class="max-w-md w-full text-center space-y-6">
      
      <!-- Lock Icon with sleek micro-animation -->
      <div class="w-20 h-20 bg-slate-50 border border-slate-100 rounded-3xl flex items-center justify-center mx-auto shadow-sm group">
        <i class="pi pi-lock text-3xl text-slate-800 transition-transform group-hover:scale-110 duration-200"></i>
      </div>

      <!-- Main Copy -->
      <div class="space-y-2">
        <h1 class="text-xl font-black text-slate-900 tracking-tight uppercase">Accès Refusé</h1>
        <p class="text-xs text-rose-500 font-extrabold uppercase tracking-widest mt-1">
          Permissions Insuffisantes
        </p>
      </div>

      <!-- Divider line -->
      <div class="w-12 h-0.5 bg-slate-200 mx-auto"></div>

      <!-- Detailed Explanation -->
      <p class="text-xs text-slate-400 font-medium leading-relaxed max-w-sm mx-auto">
        Votre compte ne possède pas les habilitations nécessaires pour accéder à cette fonctionnalité clinique ou d'administration SaaS.
      </p>

      <!-- Return back action -->
      <div class="pt-4">
        <button 
          @click="goBack"
          class="px-5 py-2.5 bg-slate-900 hover:bg-slate-800 text-white rounded-xl text-xs font-bold transition-all shadow-md hover:shadow-lg cursor-pointer flex items-center gap-2 mx-auto"
        >
          <i class="pi pi-arrow-left text-[10px]"></i>
          <span>Retourner à la page précédente</span>
        </button>
      </div>

    </div>
  </div>
</template>
