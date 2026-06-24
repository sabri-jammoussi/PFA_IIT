<script setup>
import { ref, onMounted } from 'vue'
import { toast } from 'vue3-toastify'
import api from '@/services/api'


const loading = ref(false)
const saving = ref(false)

const form = ref({
  smtpHost: '',
  smtpPort: '',
  smtpUsername: '',
  smtpPassword: '',
  smtpEnableSsl: true,
  senderName: ''
})

const hasStoredPassword = ref(false)

const fetchCabinetSettings = async () => {
  loading.value = true
  try {
    const res = await api.get('/cabinet/settings/smtp')
    if (res.data) {
      form.value.smtpHost = res.data.smtpHost || ''
      form.value.smtpPort = res.data.smtpPort || ''
      form.value.smtpUsername = res.data.smtpUsername || ''
      form.value.smtpEnableSsl = res.data.smtpEnableSsl ?? true;
      form.value.senderName = res.data.senderName || ''
      form.value.smtpPassword = ''
      hasStoredPassword.value = !!res.data.smtpUsername // Treat as configured if email exists
    }
  } catch (error) {
    console.error('[API Error] fetchCabinetSettings failed:', error)
    toast.error(`Erreur\nImpossible de charger les paramètres SMTP du cabinet.`, { autoClose: 5000 })
  } finally {
    loading.value = false
  }
}

const saveCabinetSettings = async () => {
  saving.value = true
  try {
    const payload = {
      smtpHost: form.value.smtpHost,
      smtpPort: form.value.smtpPort ? parseInt(form.value.smtpPort) : null,
      smtpUsername: form.value.smtpUsername,
      smtpPassword: form.value.smtpPassword || null,
      smtpEnableSsl: form.value.smtpEnableSsl,
      senderName: form.value.senderName
    }
    
    await api.post('/cabinet/settings/smtp', payload)
    toast.success(`Succès\nConfiguration SMTP du cabinet mise à jour avec succès.`, { autoClose: 3000 })
    fetchCabinetSettings()
  } catch (error) {
    console.error('[API Error] saveCabinetSettings failed:', error)
    toast.error(`Erreur de sauvegarde\nImpossible de sauvegarder la configuration du cabinet.`, { autoClose: 5000 })
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  fetchCabinetSettings()
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    <!-- Page Header -->
    <div class="bg-white rounded-2xl border border-slate-200/65 shadow-sm p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4 relative overflow-hidden">
      <div class="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-indigo-500/5 to-transparent rounded-full -mr-16 -mt-16 pointer-events-none"></div>
      <div class="flex items-center gap-4">
        <div class="w-12 h-12 rounded-xl bg-indigo-50 text-indigo-650 flex items-center justify-center flex-shrink-0 shadow-sm">
          <i class="pi pi-building text-xl"></i>
        </div>
        <div>
          <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-slate-900 text-white text-[10px] font-bold uppercase tracking-wider">
            Espace Cabinet Dentaire
          </span>
          <h1 class="text-xl font-extrabold text-slate-900 tracking-tight mt-1.5">
            Paramètres Privés du Cabinet
          </h1>
          <p class="text-xs text-slate-500 mt-0.5">
            Configurez le serveur SMTP de votre cabinet pour l'envoi de vos rappels et ordonnances.
          </p>
        </div>
      </div>
    </div>

    <!-- Configuration Card -->
    <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6">
      <div v-if="loading" class="py-12 flex flex-col items-center justify-center text-slate-400 gap-2">
        <i class="pi pi-spin pi-spinner text-3xl text-indigo-500"></i>
        <span class="text-xs font-semibold">Chargement de la configuration du cabinet...</span>
      </div>

      <div v-else class="space-y-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Nom de l'expéditeur -->
          <div class="md:col-span-2">
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">
              Nom d'affichage de l'expéditeur (Sender Name)
            </label>
            <input 
              v-model="form.senderName"
              type="text" 
              placeholder="ex. Cabinet Dentaire Sfax - Dr. Dupont"
              class="w-full px-3.5 py-2.5 border border-slate-200 rounded-lg text-xs font-semibold focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500/50 outline-none text-slate-800 transition-all"
            />
          </div>

          <!-- Hôte SMTP -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">
              Hôte SMTP
            </label>
            <input 
              v-model="form.smtpHost"
              type="text" 
              placeholder="ex. smtp.gmail.com"
              class="w-full px-3.5 py-2.5 border border-slate-200 rounded-lg text-xs font-semibold focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500/50 outline-none text-slate-800 transition-all"
            />
          </div>

          <!-- Port SMTP -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">
              Port SMTP
            </label>
            <input 
              v-model="form.smtpPort"
              type="text" 
              placeholder="ex. 587"
              class="w-full px-3.5 py-2.5 border border-slate-200 rounded-lg text-xs font-semibold focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500/50 outline-none text-slate-800 transition-all"
            />
          </div>

          <!-- Email Utilisateur -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">
              Nom d'utilisateur SMTP (Email de connexion)
            </label>
            <input 
              v-model="form.smtpUsername"
              type="email" 
              placeholder="ex. cabinet.dupont@pro.com"
              class="w-full px-3.5 py-2.5 border border-slate-200 rounded-lg text-xs font-semibold focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500/50 outline-none text-slate-800 transition-all"
            />
          </div>

          <!-- Mot de passe -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-2">
              Mot de passe SMTP / Clé d'application
            </label>
            <input 
              v-model="form.smtpPassword"
              type="password"
              :placeholder="hasStoredPassword ? '•••••••• (Laisser vide pour ne pas modifier)' : 'Entrer le mot de passe'"
              class="w-full px-3.5 py-2.5 border border-slate-200 rounded-lg text-xs font-semibold focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500/50 outline-none text-slate-800 transition-all"
            />
          </div>
        </div>

        <!-- SSL / TLS checkbox -->
        <div class="flex items-center gap-2.5 py-2">
          <input 
            id="smtp-ssl"
            v-model="form.smtpEnableSsl"
            type="checkbox"
            class="h-4.5 w-4.5 text-indigo-650 focus:ring-indigo-500 border-slate-300 rounded cursor-pointer"
          />
          <label for="smtp-ssl" class="text-xs font-semibold text-slate-700 select-none cursor-pointer">
            Activer la connexion sécurisée SSL / TLS (recommandé)
          </label>
        </div>

        <!-- Form Actions -->
        <div class="flex items-center justify-end border-t border-slate-100 pt-5 gap-3">
          <button 
            @click="fetchCabinetSettings"
            :disabled="saving"
            class="px-4 py-2 border border-slate-200 hover:bg-slate-50 text-slate-700 rounded-lg text-xs font-bold transition-all cursor-pointer disabled:opacity-50"
          >
            Réinitialiser
          </button>
          <button 
            @click="saveCabinetSettings"
            :disabled="saving"
            class="px-5 py-2 bg-slate-900 hover:bg-slate-800 text-white rounded-lg text-xs font-bold transition-all shadow-sm flex items-center gap-2 cursor-pointer disabled:opacity-50"
          >
            <i v-if="saving" class="pi pi-spin pi-spinner text-xs"></i>
            Enregistrer la configuration
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
