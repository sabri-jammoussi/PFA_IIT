<script setup>
import PendingRequestsTable from './components/PendingRequestsTable.vue'
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    
    <!-- Page Header -->
    <div class="bg-white rounded-2xl border border-slate-200/65 shadow-sm p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4 relative overflow-hidden">
      <div class="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-indigo-500/5 to-transparent rounded-full -mr-16 -mt-16 pointer-events-none"></div>
      <div class="flex items-center gap-4">
        <div class="w-12 h-12 rounded-xl bg-indigo-50 text-indigo-650 flex items-center justify-center flex-shrink-0 shadow-sm animate-pulse">
          <i class="pi pi-bell text-xl"></i>
        </div>
        <div>
          <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-slate-900 text-white text-[10px] font-bold uppercase tracking-wider">
            Espace Opérationnel
          </span>
          <h1 class="text-xl font-extrabold text-slate-900 tracking-tight mt-1.5">
            Validation des Demandes Mobile
          </h1>
          <p class="text-xs text-slate-500 mt-0.5">
            Examinez, acceptez ou proposez d'autres dates pour les demandes de rendez-vous de vos patients mobiles.
          </p>
        </div>
      </div>
    </div>

    <!-- Render pending requests table -->
    <PendingRequestsTable />

  </div>
</template>
