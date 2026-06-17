<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useToast } from 'primevue/usetoast'
import api from '@/services/api'
import UserProfilePicture from '@/components/UserProfilePicture.vue'

const authStore = useAuthStore()
const toast = useToast()

const loading = ref(false)
const saving = ref(false)
const userProfile = ref({
  id: null,
  username: '',
  email: '',
  nom: '',
  prenom: '',
  roleId: null,
  roleName: '',
  isActive: true,
  createdAt: ''
})

const fetchProfile = async () => {
  if (!authStore.user?.id) return
  loading.value = true
  const url = `/users/${authStore.user.id}`
  console.log(`[API Request] GET ${url}`)
  try {
    const res = await api.get(url)
    console.log(`[API Response] GET ${url} | Status: ${res.status}`, res.data)
    userProfile.value = res.data
  } catch (error) {
    console.warn("[API Error] fetchProfile failed. Using local storage values:", error)
    // Fallback to local storage auth user
    userProfile.value = {
      id: authStore.user.id,
      username: authStore.user.username,
      email: authStore.user.email,
      nom: authStore.user.nom,
      prenom: authStore.user.prenom,
      roleId: authStore.user.roleId,
      roleName: authStore.roleName,
      isActive: authStore.user.isActive,
      createdAt: authStore.user.createdAt || new Date().toISOString()
    }
  } finally {
    loading.value = false
  }
}

const handleSaveProfile = async () => {
  saving.value = true
  const url = `/users/${userProfile.value.id}`
  const payload = {
    id: userProfile.value.id,
    username: userProfile.value.username,
    email: userProfile.value.email,
    nom: userProfile.value.nom,
    prenom: userProfile.value.prenom,
    isActive: userProfile.value.isActive,
    roleId: userProfile.value.roleId
  }
  
  console.log(`[API Request] PUT ${url} | Payload:`, payload)
  try {
    const res = await api.put(url, payload)
    console.log(`[API Response] PUT ${url} | Status: ${res.status}`)
    
    // Update local storage auth user data
    const updatedUser = {
      ...authStore.user,
      nom: userProfile.value.nom,
      prenom: userProfile.value.prenom,
      email: userProfile.value.email
    }
    authStore.user = updatedUser

    toast.add({
      severity: 'success',
      summary: 'Profil mis à jour',
      detail: 'Vos modifications ont été enregistrées avec succès.',
      life: 3000
    })
  } catch (error) {
    console.error("[API Error] handleSaveProfile failed:", error)
    toast.add({
      severity: 'error',
      summary: 'Erreur',
      detail: error.response?.data?.error || 'Impossible de mettre à jour le profil.',
      life: 4000
    })
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  fetchProfile()
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    <div>
      <h1 class="text-xl font-extrabold text-slate-900 tracking-tight">Mon Profil</h1>
      <p class="text-xs text-slate-500 mt-1">Gérez vos informations personnelles et identifiants de session clinique.</p>
    </div>

    <div v-if="loading" class="py-20 flex flex-col items-center justify-center text-slate-400 gap-2 bg-white rounded-xl border border-slate-200/65 shadow-sm">
      <i class="pi pi-spin pi-spinner text-3xl text-sky-500"></i>
      <span class="text-xs font-semibold">Chargement de votre profil...</span>
    </div>

    <div v-else class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <!-- Left Column: User Summary Card -->
      <div class="space-y-6">
        <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6 flex flex-col items-center text-center relative overflow-hidden">
          <div class="absolute top-0 inset-x-0 h-24 bg-gradient-to-r from-slate-900 via-slate-800 to-sky-950/40"></div>
          
          <!-- Profile Picture with Edit capability -->
          <div class="relative mt-8 z-10">
            <UserProfilePicture
              v-if="userProfile.id"
              :userId="userProfile.id"
              :shortNameUser="(userProfile.prenom?.charAt(0) || '') + (userProfile.nom?.charAt(0) || '')"
              :avatarColeur="'#4f46e5'"
              :allowEdit="true"
              size="96px"
              :refreshPic="authStore.userImageVersion"
            />
          </div>

          <h3 class="text-base font-extrabold text-slate-900 tracking-tight mt-4">
            {{ userProfile.prenom }} {{ userProfile.nom }}
          </h3>
          <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-sky-50 text-sky-700 border border-sky-100 text-[10px] font-bold uppercase tracking-wider mt-2">
            {{ userProfile.roleName || authStore.roleName }}
          </span>

          <div class="w-full border-t border-slate-100 mt-6 pt-5 space-y-3.5 text-left text-xs text-slate-650 font-semibold">
            <div class="flex justify-between">
              <span class="text-slate-400 font-bold uppercase text-[9px] tracking-wider">Nom d'utilisateur</span>
              <span class="text-slate-800">{{ userProfile.username }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-400 font-bold uppercase text-[9px] tracking-wider">Identifiant Interne</span>
              <span class="text-slate-800">#{{ userProfile.id }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-slate-400 font-bold uppercase text-[9px] tracking-wider">Date d'inscription</span>
              <span class="text-slate-800">{{ new Date(userProfile.createdAt).toLocaleDateString('fr-FR') }}</span>
            </div>
            <div class="flex justify-between items-center">
              <span class="text-slate-400 font-bold uppercase text-[9px] tracking-wider">État du compte</span>
              <span class="px-2 py-0.5 rounded text-[9px] font-bold" :class="[userProfile.isActive ? 'bg-emerald-50 text-emerald-700' : 'bg-rose-50 text-rose-700']">
                {{ userProfile.isActive ? 'Actif' : 'Désactivé' }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Right Column: Edit Profile Form -->
      <div class="lg:col-span-2 bg-white rounded-xl border border-slate-200/65 shadow-sm p-6">
        <h2 class="text-sm font-extrabold text-slate-900 uppercase tracking-wider mb-4 border-b border-slate-100 pb-3">Informations Personnelles</h2>
        
        <form @submit.prevent="handleSaveProfile" class="space-y-5">
          <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <!-- Prénom -->
            <div class="space-y-1.5">
              <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Prénom</label>
              <input 
                v-model="userProfile.prenom"
                type="text" 
                required
                class="w-full py-2.5 px-3.5 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl outline-none text-slate-850 font-medium"
              />
            </div>
            <!-- Nom -->
            <div class="space-y-1.5">
              <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Nom</label>
              <input 
                v-model="userProfile.nom"
                type="text" 
                required
                class="w-full py-2.5 px-3.5 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl outline-none text-slate-850 font-medium"
              />
            </div>
          </div>

          <!-- Email -->
          <div class="space-y-1.5">
            <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Adresse e-mail</label>
            <input 
              v-model="userProfile.email"
              type="email" 
              required
              class="w-full py-2.5 px-3.5 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl outline-none text-slate-850 font-medium"
            />
          </div>

          <!-- Role (Disabled) -->
          <div class="space-y-1.5">
            <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Rôle assigné</label>
            <input 
              :value="userProfile.roleName || authStore.roleName"
              type="text" 
              disabled
              class="w-full py-2.5 px-3.5 text-xs bg-slate-100 border border-slate-200 rounded-xl text-slate-500 cursor-not-allowed font-medium"
            />
            <p class="text-[10px] text-slate-400">Le rôle de votre compte est géré par la direction informatique et ne peut pas être modifié.</p>
          </div>

          <!-- Save Button -->
          <div class="flex justify-end pt-4 border-t border-slate-100">
            <button 
              type="submit" 
              :disabled="saving"
              class="px-5 py-2.5 bg-slate-900 hover:bg-slate-800 disabled:bg-slate-250 text-white text-xs font-semibold rounded-xl transition-all shadow-md shadow-slate-900/10 cursor-pointer disabled:cursor-not-allowed flex items-center gap-1.5"
            >
              <i v-if="saving" class="pi pi-spin pi-spinner"></i>
              <i v-else class="pi pi-save"></i>
              <span>Enregistrer les modifications</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
