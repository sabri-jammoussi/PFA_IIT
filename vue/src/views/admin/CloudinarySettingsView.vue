<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useToast } from 'primevue/usetoast'
import api from '@/services/api'

const route = useRoute()
const toast = useToast()
const loading = ref(false)
const saving = ref(false)

const form = ref({
  name: '',
  key: '',
  secret: '',
  folder: ''
})

const hasStoredSecret = ref(false)

const fetchCloudinarySettings = async () => {
  loading.value = true
  try {
    const res = await api.get('/options/cloudinary')
    if (res.data) {
      form.value.name = res.data.name || ''
      form.value.key = res.data.key || ''
      form.value.folder = res.data.folder || ''
      form.value.secret = ''
      hasStoredSecret.value = res.data.hasSecret || false
    }
  } catch (error) {
    console.error('[API Error] fetchCloudinarySettings failed:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur',
      detail: 'Impossible de charger les paramètres Cloudinary.',
      life: 5000
    })
  } finally {
    loading.value = false
  }
}

const saveCloudinarySettings = async () => {
  saving.value = true
  try {
    const payload = {
      name: form.value.name,
      key: form.value.key,
      secret: form.value.secret || null,
      folder: form.value.folder
    }
    
    await api.post('/options/cloudinary', payload)
    toast.add({
      severity: 'success',
      summary: 'Succès',
      detail: 'Configuration Cloudinary mise à jour avec succès.',
      life: 3000
    })
    fetchCloudinarySettings()
  } catch (error) {
    console.error('[API Error] saveCloudinarySettings failed:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur de sauvegarde',
      detail: 'Impossible de sauvegarder les paramètres Cloudinary.',
      life: 5000
    })
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  fetchCloudinarySettings()
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    <!-- Page Header -->
    <div class="bg-white rounded-2xl border border-slate-200/65 shadow-sm p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4 relative overflow-hidden">
      <div class="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-sky-500/5 to-transparent rounded-full -mr-16 -mt-16 pointer-events-none"></div>
      <div class="flex items-center gap-4">
        <div class="w-12 h-12 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center flex-shrink-0 shadow-sm">
          <i class="pi pi-images text-xl"></i>
        </div>
        <div>
          <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-slate-900 text-white text-[10px] font-bold uppercase tracking-wider">
            Configuration Système
          </span>
          <h1 class="text-xl font-extrabold text-slate-900 tracking-tight mt-1.5">
            Stockage Cloudinary
          </h1>
          <p class="text-xs text-slate-500 mt-0.5">
            Configurez l'hébergement cloud pour les photos de profil, radios dentaires et documents cliniques.
          </p>
        </div>
      </div>
    </div>

    <!-- Settings Sub-Navigation Tabs -->
    <div class="flex border-b border-slate-200/80 gap-6 text-xs font-bold uppercase tracking-wider pb-px bg-white p-4 rounded-xl border border-slate-200/65 shadow-sm">
      <router-link 
        :to="{ name: 'AdminSmtpSettings' }" 
        class="pb-2 px-1 transition-all border-b-2 flex items-center gap-2"
        :class="route.name === 'AdminSmtpSettings' ? 'border-sky-500 text-sky-600' : 'border-transparent text-slate-400 hover:text-slate-600'"
      >
        <i class="pi pi-envelope text-sm"></i>
        <span>Messagerie (SMTP)</span>
      </router-link>
      <router-link 
        :to="{ name: 'AdminCloudinarySettings' }" 
        class="pb-2 px-1 transition-all border-b-2 flex items-center gap-2"
        :class="route.name === 'AdminCloudinarySettings' ? 'border-sky-500 text-sky-600' : 'border-transparent text-slate-400 hover:text-slate-600'"
      >
        <i class="pi pi-images text-sm"></i>
        <span>Stockage Cloudinary</span>
      </router-link>
      <router-link 
        :to="{ name: 'AdminStorageSettings' }" 
        class="pb-2 px-1 transition-all border-b-2 flex items-center gap-2"
        :class="route.name === 'AdminStorageSettings' ? 'border-sky-500 text-sky-600' : 'border-transparent text-slate-400 hover:text-slate-600'"
      >
        <i class="pi pi-database text-sm"></i>
        <span>Espace Stockage</span>
      </router-link>
    </div>

    <!-- Configuration Card -->
    <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6">
      <div v-if="loading" class="py-12 flex flex-col items-center justify-center text-slate-400 gap-2">
        <i class="pi pi-spin pi-spinner text-3xl text-indigo-500"></i>
        <span class="text-xs font-semibold">Chargement des paramètres Cloudinary...</span>
      </div>

      <div v-else class="space-y-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Cloud Name -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">
              Cloud Name
            </label>
            <input 
              v-model="form.name"
              type="text" 
              placeholder="ex. mon-cloudinary"
              class="w-full px-3.5 py-2.5 border border-slate-200 rounded-lg text-xs font-semibold focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500/50 outline-none text-slate-800 transition-all"
            />
          </div>

          <!-- API Key -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">
              API Key
            </label>
            <input 
              v-model="form.key"
              type="text" 
              placeholder="ex. 123456789012345"
              class="w-full px-3.5 py-2.5 border border-slate-200 rounded-lg text-xs font-semibold focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500/50 outline-none text-slate-800 transition-all"
            />
          </div>

          <!-- API Secret -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">
              API Secret
            </label>
            <input 
              v-model="form.secret"
              type="password"
              :placeholder="hasStoredSecret ? '•••••••• (Laisser vide pour ne pas modifier)' : 'Entrer le secret'"
              class="w-full px-3.5 py-2.5 border border-slate-200 rounded-lg text-xs font-semibold focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500/50 outline-none text-slate-800 transition-all"
            />
          </div>

          <!-- Dossier racine -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">
              Dossier Racine (Folder)
            </label>
            <input 
              v-model="form.folder"
              type="text" 
              placeholder="ex. dentiste"
              class="w-full px-3.5 py-2.5 border border-slate-200 rounded-lg text-xs font-semibold focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500/50 outline-none text-slate-800 transition-all"
            />
          </div>
        </div>

        <!-- Form Actions -->
        <div class="flex items-center justify-end border-t border-slate-100 pt-5 gap-3">
          <button 
            @click="fetchCloudinarySettings"
            :disabled="saving"
            class="px-4 py-2 border border-slate-200 hover:bg-slate-50 text-slate-755 rounded-lg text-xs font-bold transition-all cursor-pointer disabled:opacity-50"
          >
            Réinitialiser
          </button>
          <button 
            @click="saveCloudinarySettings"
            :disabled="saving"
            class="px-5 py-2 bg-slate-900 hover:bg-slate-800 text-white rounded-lg text-xs font-bold transition-all shadow-sm flex items-center gap-2 cursor-pointer disabled:opacity-50"
          >
            <i v-if="saving" class="pi pi-spin pi-spinner text-xs"></i>
            Enregistrer les modifications
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
