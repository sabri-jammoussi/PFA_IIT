<script setup>
// ─── Sub-panel components ───────────────────────────────────────────
import SmtpPanel from './panels/SmtpPanel.vue'
import CloudinaryPanel from './panels/CloudinaryPanel.vue'
import StoragePanel from './panels/StoragePanel.vue'
import UsersListPanel from './panels/UsersListPanel.vue'
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">

    <!-- Page Header -->
    <div class="bg-white rounded-2xl border border-slate-200/65 shadow-sm p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4 relative overflow-hidden">
      <div class="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-sky-500/5 to-transparent rounded-full -mr-16 -mt-16 pointer-events-none"></div>
      <div>
        <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-slate-900 text-white text-[10px] font-bold uppercase tracking-wider">
          Administration
        </span>
        <h1 class="text-xl font-extrabold text-slate-900 tracking-tight mt-3">
          Configuration Système
        </h1>
        <p class="text-xs text-slate-500 mt-1">
          Paramètres SMTP, Cloudinary, stockage et gestion des utilisateurs.
        </p>
      </div>
      <div class="flex items-center gap-2 flex-shrink-0">
        <div class="flex items-center gap-1.5 bg-emerald-50 border border-emerald-200 text-emerald-700 px-3 py-1.5 rounded-lg text-xs font-semibold">
          <i class="pi pi-check-circle text-sm"></i> Console Système Active
        </div>
      </div>
    </div>

    <!-- Config panels -->
    <div class="space-y-4">
      <SmtpPanel />
      <CloudinaryPanel />
      <StoragePanel />
      <UsersListPanel />
    </div>

  </div>
</template>
