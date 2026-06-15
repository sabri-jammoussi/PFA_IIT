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
  type: 'Desactiver',
  token: '',
  path: '',
  account: ''
})

const hasStoredToken = ref(false)

const fetchStorageSettings = async () => {
  loading.value = true
  try {
    const res = await api.get('/options/storage')
    if (res.data) {
      form.value.type = res.data.type || 'Desactiver'
      form.value.path = res.data.path || ''
      form.value.account = res.data.account || ''
      form.value.token = ''
      hasStoredToken.value = res.data.hasToken || false
    }
  } catch (error) {
    console.error('[API Error] fetchStorageSettings failed:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur',
      detail: 'Impossible de charger les paramètres de stockage.',
      life: 5000
    })
  } finally {
    loading.value = false
  }
}

const saveStorageSettings = async () => {
  saving.value = true
  try {
    const payload = {
      type: form.value.type,
      token: form.value.token || null,
      path: form.value.path,
      account: form.value.account
    }
    
    await api.post('/options/storage', payload)
    toast.add({
      severity: 'success',
      summary: 'Succès',
      detail: 'Configuration du stockage mise à jour avec succès.',
      life: 3000
    })
    fetchStorageSettings()
  } catch (error) {
    console.error('[API Error] saveStorageSettings failed:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur de sauvegarde',
      detail: 'Impossible de sauvegarder les paramètres de stockage.',
      life: 5000
    })
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  fetchStorageSettings()
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    <!-- Page Header -->
    <div class="bg-white rounded-2xl border border-slate-200/65 shadow-sm p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4 relative overflow-hidden">
      <div class="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-sky-500/5 to-transparent rounded-full -mr-16 -mt-16 pointer-events-none"></div>
      <div class="flex items-center gap-4">
        <div class="w-12 h-12 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center flex-shrink-0 shadow-sm">
          <i class="pi pi-database text-xl"></i>
        </div>
        <div>
          <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-slate-900 text-white text-[10px] font-bold uppercase tracking-wider">
            Configuration Système
          </span>
          <h1 class="text-xl font-extrabold text-slate-900 tracking-tight mt-1.5">
            Espace de Stockage Fichiers
          </h1>
          <p class="text-xs text-slate-500 mt-0.5">
            Gérez le répertoire local d'archivage ou configurez les connecteurs cloud de sauvegarde.
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
        <i class="pi pi-spin pi-spinner text-3xl text-emerald-500"></i>
        <span class="text-xs font-semibold">Chargement des paramètres de stockage...</span>
      </div>

      <div v-else class="space-y-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Type de Stockage -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">
              Type de Stockage
            </label>
            <select 
              v-model="form.type"
              class="w-full px-3.5 py-2.5 border border-slate-200 rounded-lg text-xs font-semibold focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500/50 outline-none text-slate-800 transition-all cursor-pointer"
            >
              <option value="Desactiver">Désactivé</option>
              <option value="Local">Stockage Local</option>
              <option value="Google">Google Drive</option>
              <option value="Microsoft">OneDrive (Microsoft)</option>
            </select>
          </div>

          <!-- Chemin Local -->
          <div v-if="form.type === 'Local'">
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">
              Chemin Absolu Répertoire Local
            </label>
            <input 
              v-model="form.path"
              type="text" 
              placeholder="ex. C:\DentisteApp\Storage"
              class="w-full px-3.5 py-2.5 border border-slate-200 rounded-lg text-xs font-semibold focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500/50 outline-none text-slate-800 transition-all"
            />
          </div>

          <!-- Compte Cloud Connecté -->
          <div v-if="form.type === 'Google' || form.type === 'Microsoft'">
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">
              Compte Cloud (Email)
            </label>
            <input 
              v-model="form.account"
              type="email" 
              placeholder="ex. dental.cabinet@gmail.com"
              class="w-full px-3.5 py-2.5 border border-slate-200 rounded-lg text-xs font-semibold focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500/50 outline-none text-slate-800 transition-all"
            />
          </div>

          <!-- Token d'authentification Cloud -->
          <div v-if="form.type === 'Google' || form.type === 'Microsoft'">
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">
              Token OAuth / API Key
            </label>
            <input 
              v-model="form.token"
              type="password"
              :placeholder="hasStoredToken ? '•••••••• (Laisser vide pour ne pas modifier)' : 'Entrer le token'"
              class="w-full px-3.5 py-2.5 border border-slate-200 rounded-lg text-xs font-semibold focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500/50 outline-none text-slate-800 transition-all"
            />
          </div>
        </div>

        <!-- Form Actions -->
        <div class="flex items-center justify-end border-t border-slate-100 pt-5 gap-3">
          <button 
            @click="fetchStorageSettings"
            :disabled="saving"
            class="px-4 py-2 border border-slate-200 hover:bg-slate-50 text-slate-755 rounded-lg text-xs font-bold transition-all cursor-pointer disabled:opacity-50"
          >
            Réinitialiser
          </button>
          <button 
            @click="saveStorageSettings"
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
