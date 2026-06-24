<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { toast } from 'vue3-toastify'
import api from '@/services/api'

const authStore = useAuthStore()


const savingPassword = ref(false)
const userProfile = ref(null)

const newPassword = ref('')
const confirmPassword = ref('')

// Local Settings (saved in localStorage)
const theme = ref(localStorage.getItem('denti_theme') || 'Light')
const language = ref(localStorage.getItem('denti_lang') || 'Français')
const emailNotifications = ref(localStorage.getItem('denti_notif_email') !== 'false')
const soundAlerts = ref(localStorage.getItem('denti_notif_sound') !== 'false')

const themeOptions = [
  { value: 'Light', label: 'Thème Clair (Stérile)' },
  { value: 'Dark', label: 'Thème Sombre (Nuit)' },
  { value: 'Glass', label: 'Givré (Glassmorphism)' }
]

const languageOptions = [
  { value: 'Français', label: 'Français' },
  { value: 'English', label: 'English' },
  { value: 'العربية', label: 'العربية' }
]

const fetchProfile = async () => {
  if (!authStore.user?.id) return
  const url = `/users/${authStore.user.id}`
  console.log(`[API Request] GET ${url}`)
  try {
    const res = await api.get(url)
    console.log(`[API Response] GET ${url} | Status: ${res.status}`)
    userProfile.value = res.data
  } catch (error) {
    console.warn("[API Error] fetchProfile failed in settings. Using local session data:", error)
    userProfile.value = {
      id: authStore.user.id,
      username: authStore.user.username,
      email: authStore.user.email,
      nom: authStore.user.nom,
      prenom: authStore.user.prenom,
      isActive: authStore.user.isActive,
      roleId: authStore.user.roleId
    }
  }
}

const handleChangePassword = async () => {
  if (!newPassword.value || !confirmPassword.value) {
    toast.warning(`Champs requis\nVeuillez remplir les champs de mot de passe.`, { autoClose: 3000 })
    return
  }

  if (newPassword.value !== confirmPassword.value) {
    toast.error(`Erreur de saisie\nLes mots de passe ne correspondent pas.`, { autoClose: 3000 })
    return
  }

  if (newPassword.value.length < 6) {
    toast.warning(`Sécurité faible\nLe mot de passe doit contenir au moins 6 caractères.`, { autoClose: 3000 })
    return
  }

  savingPassword.value = true
  
  if (!userProfile.value) {
    await fetchProfile()
  }

  const url = `/users/${userProfile.value.id}`
  const payload = {
    id: userProfile.value.id,
    username: userProfile.value.username,
    email: userProfile.value.email,
    nom: userProfile.value.nom,
    prenom: userProfile.value.prenom,
    isActive: userProfile.value.isActive,
    roleId: userProfile.value.roleId,
    password: newPassword.value
  }

  console.log(`[API Request] PUT ${url} (Password Update) | Payload:`, { ...payload, password: '[PROTECTED]' })
  try {
    const res = await api.put(url, payload)
    console.log(`[API Response] PUT ${url} (Password Update) | Status: ${res.status}`)
    
    toast.success(`Mot de passe mis à jour\nVotre mot de passe a été modifié avec succès.`, { autoClose: 3000 })

    newPassword.value = ''
    confirmPassword.value = ''
  } catch (error) {
    console.error("[API Error] Password update failed:", error)
    toast.error(`Échec de la modification\n${error.response?.data?.error || 'Impossible de changer le mot de passe.'}`, { autoClose: 4000 })
  } finally {
    savingPassword.value = false
  }
}

const handleSavePreferences = () => {
  localStorage.setItem('denti_theme', theme.value)
  localStorage.setItem('denti_lang', language.value)
  localStorage.setItem('denti_notif_email', emailNotifications.value.toString())
  localStorage.setItem('denti_notif_sound', soundAlerts.value.toString())
  
  toast.success(`Préférences enregistrées\nVos options de l'espace clinique ont été stockées localement.`, { autoClose: 3000 })
}

onMounted(() => {
  fetchProfile()
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    <div>
      <h1 class="text-xl font-extrabold text-slate-900 tracking-tight">Paramètres du Cabinet</h1>
      <p class="text-xs text-slate-500 mt-1">Configurez la sécurité de votre compte et vos préférences visuelles de travail.</p>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
      
      <!-- Box 1: Change Password -->
      <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6 flex flex-col justify-between">
        <div>
          <h2 class="text-sm font-extrabold text-slate-900 uppercase tracking-wider mb-4 border-b border-slate-100 pb-3 flex items-center gap-2">
            <i class="pi pi-lock text-slate-400"></i>
            <span>Sécurité du Compte</span>
          </h2>

          <form @submit.prevent="handleChangePassword" class="space-y-4">
            <!-- New Password -->
            <div class="space-y-1.5">
              <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Nouveau mot de passe</label>
              <input 
                v-model="newPassword"
                type="password" 
                required
                placeholder="Saisissez votre nouveau mot de passe"
                class="w-full py-2.5 px-3.5 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl outline-none text-slate-850 font-medium"
              />
            </div>

            <!-- Confirm Password -->
            <div class="space-y-1.5">
              <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Confirmer le mot de passe</label>
              <input 
                v-model="confirmPassword"
                type="password" 
                required
                placeholder="Répétez le mot de passe"
                class="w-full py-2.5 px-3.5 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl outline-none text-slate-850 font-medium"
              />
            </div>
            
            <p class="text-[10px] text-slate-400 leading-normal">
              Utilisez un mot de passe robuste combinant des chiffres, des lettres et des caractères spéciaux pour préserver la sécurité de vos accès aux données médicales.
            </p>
          </form>
        </div>

        <div class="flex justify-end pt-4 border-t border-slate-100 mt-6">
          <button 
            @click="handleChangePassword"
            :disabled="savingPassword"
            class="px-4 py-2.5 bg-slate-900 hover:bg-slate-800 disabled:bg-slate-250 text-white text-xs font-semibold rounded-xl transition-all shadow-md shadow-slate-900/10 cursor-pointer disabled:cursor-not-allowed flex items-center gap-1.5"
          >
            <i v-if="savingPassword" class="pi pi-spin pi-spinner"></i>
            <i v-else class="pi pi-key"></i>
            <span>Mettre à jour le mot de passe</span>
          </button>
        </div>
      </div>

      <!-- Box 2: Visual and Notification Preferences -->
      <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6 flex flex-col justify-between">
        <div>
          <h2 class="text-sm font-extrabold text-slate-900 uppercase tracking-wider mb-4 border-b border-slate-100 pb-3 flex items-center gap-2">
            <i class="pi pi-sliders-h text-slate-400"></i>
            <span>Préférences de l'Espace Clinique</span>
          </h2>

          <div class="space-y-5">
            <!-- Theme selection -->
            <div class="flex items-center justify-between">
              <div>
                <h4 class="text-xs font-bold text-slate-800">Thème Visuel</h4>
                <p class="text-[10px] text-slate-400 mt-0.5">Ajuste l'apparence générale de votre interface.</p>
              </div>
              <Dropdown
                v-model="theme"
                :options="themeOptions"
                optionLabel="label"
                optionValue="value"
                filter
                class="w-56 text-xs"
              />
            </div>

            <!-- Language selection -->
            <div class="flex items-center justify-between">
              <div>
                <h4 class="text-xs font-bold text-slate-800">Langue de l'Application</h4>
                <p class="text-[10px] text-slate-400 mt-0.5">Traductions des menus, fiches patients et diagnostics.</p>
              </div>
              <Dropdown
                v-model="language"
                :options="languageOptions"
                optionLabel="label"
                optionValue="value"
                filter
                class="w-56 text-xs"
              />
            </div>

            <!-- Notification options -->
            <div class="space-y-3 pt-2">
              <h4 class="text-[10px] font-bold text-slate-400 uppercase tracking-wide">Notifications & Alertes</h4>
              
              <!-- Email notifications toggle -->
              <div class="flex items-center justify-between">
                <span class="text-xs font-semibold text-slate-700">Activer les rapports quotidiens par e-mail</span>
                <input 
                  v-model="emailNotifications"
                  type="checkbox"
                  class="h-4.5 w-4.5 text-sky-600 focus:ring-sky-500 border-slate-350 rounded cursor-pointer"
                />
              </div>

              <!-- Sound notifications toggle -->
              <div class="flex items-center justify-between">
                <span class="text-xs font-semibold text-slate-700">Signaux sonores lors de nouveaux rendez-vous</span>
                <input 
                  v-model="soundAlerts"
                  type="checkbox"
                  class="h-4.5 w-4.5 text-sky-600 focus:ring-sky-500 border-slate-350 rounded cursor-pointer"
                />
              </div>
            </div>
          </div>
        </div>

        <div class="flex justify-end pt-4 border-t border-slate-100 mt-6">
          <button 
            @click="handleSavePreferences"
            class="px-4 py-2.5 bg-slate-900 hover:bg-slate-800 text-white text-xs font-semibold rounded-xl transition-all shadow-md shadow-slate-900/10 cursor-pointer flex items-center gap-1.5"
          >
            <i class="pi pi-check"></i>
            <span>Enregistrer les préférences</span>
          </button>
        </div>
      </div>

    </div>
  </div>
</template>
