<script setup>
import { ref, onMounted } from 'vue'
import { useToast } from 'primevue/usetoast'
import api from '@/services/api'

const toast = useToast()
const isOpen = ref(true)
const isEditing = ref(false)
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
      form.value.password = '' // Clear input
      hasStoredPassword.value = res.data.hasPassword || false
    }
  } catch (error) {
    console.error('[API Error] fetchSmtpSettings failed:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur',
      detail: 'Impossible de charger les paramètres SMTP.',
      life: 5000
    })
  } finally {
    loading.value = false
  }
}

const toggleEdit = () => {
  if (isEditing.value) {
    // Cancel edit
    isEditing.value = false
    fetchSmtpSettings()
  } else {
    isEditing.value = true
  }
}

const saveSmtpSettings = async () => {
  saving.value = true
  try {
    const payload = {
      host: form.value.host,
      port: form.value.port,
      username: form.value.username,
      password: form.value.password || null, // null/empty means don't change
      ssl: form.value.ssl
    }
    
    await api.post('/options/smtp', payload)
    toast.add({
      severity: 'success',
      summary: 'Succès',
      detail: 'Configuration SMTP mise à jour avec succès.',
      life: 3000
    })
    isEditing.value = false
    fetchSmtpSettings()
  } catch (error) {
    console.error('[API Error] saveSmtpSettings failed:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur de sauvegarde',
      detail: 'Impossible de sauvegarder les paramètres SMTP.',
      life: 5000
    })
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  fetchSmtpSettings()
})
</script>

<template>
  <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm overflow-hidden transition-all duration-300">
    <!-- Panel Header -->
    <div 
      @click="isOpen = !isOpen" 
      class="px-6 py-4 bg-slate-50/50 hover:bg-slate-50 flex items-center justify-between cursor-pointer select-none border-b border-slate-100"
    >
      <div class="flex items-center gap-3">
        <div class="w-8 h-8 rounded-lg bg-sky-50 text-sky-600 flex items-center justify-center">
          <i class="pi pi-envelope text-sm"></i>
        </div>
        <div>
          <h3 class="text-sm font-extrabold text-slate-800">Serveur de Messagerie (SMTP)</h3>
          <p class="text-[11px] text-slate-500">Configurez l'envoi des notifications par email.</p>
        </div>
      </div>
      <div class="flex items-center gap-3">
        <span 
          v-if="form.host" 
          class="px-2 py-0.5 rounded text-[10px] font-bold border"
          :class="form.ssl ? 'bg-emerald-50 text-emerald-700 border-emerald-100' : 'bg-amber-50 text-amber-700 border-amber-100'"
        >
          {{ form.ssl ? 'SSL/TLS Activé' : 'Non Sécurisé' }}
        </span>
        <i class="pi text-slate-400 transition-transform duration-200 text-xs" :class="isOpen ? 'pi-chevron-up' : 'pi-chevron-down'"></i>
      </div>
    </div>

    <!-- Panel Body (Collapsible) -->
    <div v-show="isOpen" class="p-6 transition-all duration-300">
      <div v-if="loading" class="py-6 flex items-center justify-center text-slate-400 gap-2 text-xs">
        <i class="pi pi-spin pi-spinner text-sky-500"></i>
        Chargement de la configuration SMTP...
      </div>

      <div v-else class="space-y-5">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <!-- Hôte SMTP -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">
              Hôte SMTP
            </label>
            <input 
              v-model="form.host"
              :disabled="!isEditing"
              type="text" 
              placeholder="ex. smtp.gmail.com"
              class="w-full px-3 py-2 border rounded-lg text-xs font-semibold transition-all"
              :class="isEditing ? 'border-slate-300 focus:border-sky-500 focus:ring-1 focus:ring-sky-500/50 outline-none text-slate-800' : 'border-slate-100 bg-slate-50 text-slate-500 cursor-not-allowed'"
            />
          </div>

          <!-- Port SMTP -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">
              Port SMTP
            </label>
            <input 
              v-model="form.port"
              :disabled="!isEditing"
              type="text" 
              placeholder="ex. 587"
              class="w-full px-3 py-2 border rounded-lg text-xs font-semibold transition-all"
              :class="isEditing ? 'border-slate-300 focus:border-sky-500 focus:ring-1 focus:ring-sky-500/50 outline-none text-slate-800' : 'border-slate-100 bg-slate-50 text-slate-500 cursor-not-allowed'"
            />
          </div>

          <!-- Email Utilisateur -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">
              Email Expéditeur (Nom d'utilisateur)
            </label>
            <input 
              v-model="form.username"
              :disabled="!isEditing"
              type="email" 
              placeholder="ex. contact@moncabinet.com"
              class="w-full px-3 py-2 border rounded-lg text-xs font-semibold transition-all"
              :class="isEditing ? 'border-slate-300 focus:border-sky-500 focus:ring-1 focus:ring-sky-500/50 outline-none text-slate-800' : 'border-slate-100 bg-slate-50 text-slate-500 cursor-not-allowed'"
            />
          </div>

          <!-- Mot de passe -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">
              Mot de passe
            </label>
            <div class="relative">
              <input 
                v-model="form.password"
                :disabled="!isEditing"
                :type="isEditing ? 'password' : 'text'"
                :placeholder="isEditing ? (hasStoredPassword ? 'Laisser vide pour ne pas modifier' : 'Entrer le mot de passe') : (hasStoredPassword ? '••••••••' : 'Non configuré')"
                class="w-full px-3 py-2 border rounded-lg text-xs font-semibold transition-all"
                :class="isEditing ? 'border-slate-300 focus:border-sky-500 focus:ring-1 focus:ring-sky-500/50 outline-none text-slate-800' : 'border-slate-100 bg-slate-50 text-slate-500 cursor-not-allowed'"
              />
            </div>
          </div>
        </div>

        <!-- SSL / TLS Options -->
        <div class="flex items-center gap-2.5 py-1.5">
          <input 
            id="smtp-ssl"
            v-model="form.ssl"
            :disabled="!isEditing"
            type="checkbox"
            class="h-4 w-4 text-sky-600 focus:ring-sky-500 border-slate-300 rounded cursor-pointer disabled:cursor-not-allowed"
          />
          <label for="smtp-ssl" class="text-xs font-semibold text-slate-700 select-none cursor-pointer">
            Activer la connexion sécurisée SSL / TLS (recommandé)
          </label>
        </div>

        <!-- Actions panel -->
        <div class="flex items-center justify-end border-t border-slate-100 pt-4 gap-2">
          <template v-if="!isEditing">
            <button 
              @click="toggleEdit"
              class="px-4 py-1.5 bg-slate-900 hover:bg-slate-800 text-white rounded-lg text-xs font-bold transition-all shadow-sm cursor-pointer"
            >
              Modifier
            </button>
          </template>
          <template v-else>
            <button 
              @click="toggleEdit"
              :disabled="saving"
              class="px-4 py-1.5 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-lg text-xs font-bold transition-all cursor-pointer disabled:opacity-50"
            >
              Annuler
            </button>
            <button 
              @click="saveSmtpSettings"
              :disabled="saving"
              class="px-4 py-1.5 bg-sky-600 hover:bg-sky-700 text-white rounded-lg text-xs font-bold transition-all shadow-sm flex items-center gap-2 cursor-pointer disabled:opacity-50"
            >
              <i v-if="saving" class="pi pi-spin pi-spinner text-[10px]"></i>
              Valider
            </button>
          </template>
        </div>
      </div>
    </div>
  </div>
</template>
