<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { toast } from 'vue3-toastify'
import api from '@/services/api'

const route = useRoute()

const loading = ref(false)
const saving = ref(false)

const form = ref({
  host: '',
  port: '',
  username: '',
  password: '',
  ssl: false
})

const hasStoredPassword = ref(false)

const fetchSmtpSettings = async () => {
  loading.value = true
  try {
    const res = await api.get('/options/smtp')
    if (res.data) {
      form.value.host = res.data.host || ''
      form.value.port = res.data.port || ''
      form.value.username = res.data.username || ''
      form.value.ssl = res.data.ssl || false
      form.value.password = ''
      hasStoredPassword.value = res.data.hasPassword || false
    }
  } catch (error) {
    console.error('[API Error] fetchSmtpSettings failed:', error)
    toast.error(`Erreur\nImpossible de charger les paramètres SMTP.`, { autoClose: 5000 })
  } finally {
    loading.value = false
  }
}

const saveSmtpSettings = async () => {
  saving.value = true
  try {
    const payload = {
      host: form.value.host,
      port: form.value.port,
      username: form.value.username,
      password: form.value.password || null,
      ssl: form.value.ssl
    }
    
    await api.post('/options/smtp', payload)
    toast.success(`Succès\nConfiguration SMTP mise à jour avec succès.`, { autoClose: 3000 })
    fetchSmtpSettings()
  } catch (error) {
    console.error('[API Error] saveSmtpSettings failed:', error)
    toast.error(`Erreur de sauvegarde\nImpossible de sauvegarder les paramètres SMTP.`, { autoClose: 5000 })
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  fetchSmtpSettings()
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    <!-- Page Header -->
    <div class="bg-white rounded-2xl border border-slate-200/65 shadow-sm p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4 relative overflow-hidden">
      <div class="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-sky-500/5 to-transparent rounded-full -mr-16 -mt-16 pointer-events-none"></div>
      <div class="flex items-center gap-4">
        <div class="w-12 h-12 rounded-xl bg-sky-50 text-sky-600 flex items-center justify-center flex-shrink-0 shadow-sm">
          <i class="pi pi-envelope text-xl"></i>
        </div>
        <div>
          <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-slate-900 text-white text-[10px] font-bold uppercase tracking-wider">
            Configuration Système
          </span>
          <h1 class="text-xl font-extrabold text-slate-900 tracking-tight mt-1.5">
            Serveur de Messagerie (SMTP)
          </h1>
          <p class="text-xs text-slate-500 mt-0.5">
            Configurez l'envoi de tous les emails et notifications automatiques du cabinet.
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
        <i class="pi pi-spin pi-spinner text-3xl text-sky-500"></i>
        <span class="text-xs font-semibold">Chargement des paramètres SMTP...</span>
      </div>

      <div v-else class="space-y-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Hôte SMTP -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">
              Hôte SMTP
            </label>
            <input 
              v-model="form.host"
              type="text" 
              placeholder="ex. smtp.gmail.com"
              class="w-full px-3.5 py-2.5 border border-slate-200 rounded-lg text-xs font-semibold focus:border-sky-500 focus:ring-1 focus:ring-sky-500/50 outline-none text-slate-800 transition-all"
            />
          </div>

          <!-- Port SMTP -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">
              Port SMTP
            </label>
            <input 
              v-model="form.port"
              type="text" 
              placeholder="ex. 587"
              class="w-full px-3.5 py-2.5 border border-slate-200 rounded-lg text-xs font-semibold focus:border-sky-500 focus:ring-1 focus:ring-sky-500/50 outline-none text-slate-800 transition-all"
            />
          </div>

          <!-- Email Utilisateur -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">
              Nom d'utilisateur SMTP (Email)
            </label>
            <input 
              v-model="form.username"
              type="email" 
              placeholder="ex. cabinet.dentaire@gmail.com"
              class="w-full px-3.5 py-2.5 border border-slate-200 rounded-lg text-xs font-semibold focus:border-sky-500 focus:ring-1 focus:ring-sky-500/50 outline-none text-slate-800 transition-all"
            />
          </div>

          <!-- Mot de passe -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">
              Mot de passe
            </label>
            <input 
              v-model="form.password"
              type="password"
              :placeholder="hasStoredPassword ? '•••••••• (Laisser vide pour ne pas modifier)' : 'Entrer le mot de passe'"
              class="w-full px-3.5 py-2.5 border border-slate-200 rounded-lg text-xs font-semibold focus:border-sky-500 focus:ring-1 focus:ring-sky-500/50 outline-none text-slate-800 transition-all"
            />
          </div>
        </div>

        <!-- SSL / TLS checkbox -->
        <div class="flex items-center gap-2.5 py-2">
          <input 
            id="smtp-ssl"
            v-model="form.ssl"
            type="checkbox"
            class="h-4.5 w-4.5 text-sky-600 focus:ring-sky-500 border-slate-300 rounded cursor-pointer"
          />
          <label for="smtp-ssl" class="text-xs font-semibold text-slate-700 select-none cursor-pointer">
            Activer la connexion sécurisée SSL / TLS (recommandé)
          </label>
        </div>

        <!-- Form Actions -->
        <div class="flex items-center justify-end border-t border-slate-100 pt-5 gap-3">
          <button 
            @click="fetchSmtpSettings"
            :disabled="saving"
            class="px-4 py-2 border border-slate-200 hover:bg-slate-50 text-slate-750 rounded-lg text-xs font-bold transition-all cursor-pointer disabled:opacity-50"
          >
            Réinitialiser
          </button>
          <button 
            @click="saveSmtpSettings"
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
