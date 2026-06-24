<script setup>
import { ref, onMounted } from 'vue'
import { toast } from 'vue3-toastify'
import api from '@/services/api'


const isOpen = ref(false)
const isEditing = ref(false)
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
      form.value.token = '' // Clear input
      hasStoredToken.value = res.data.hasToken || false
    }
  } catch (error) {
    console.error('[API Error] fetchStorageSettings failed:', error)
    toast.error(`Erreur\nImpossible de charger les paramètres de stockage.`, { autoClose: 5000 })
  } finally {
    loading.value = false
  }
}

const toggleEdit = () => {
  if (isEditing.value) {
    // Cancel edit
    isEditing.value = false
    fetchStorageSettings()
  } else {
    isEditing.value = true
  }
}

const saveStorageSettings = async () => {
  saving.value = true
  try {
    const payload = {
      type: form.value.type,
      token: form.value.token || null, // null/empty means don't change
      path: form.value.path,
      account: form.value.account
    }
    
    await api.post('/options/storage', payload)
    toast.success(`Succès\nConfiguration du stockage mise à jour avec succès.`, { autoClose: 3000 })
    isEditing.value = false
    fetchStorageSettings()
  } catch (error) {
    console.error('[API Error] saveStorageSettings failed:', error)
    toast.error(`Erreur de sauvegarde\nImpossible de sauvegarder les paramètres de stockage.`, { autoClose: 5000 })
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  fetchStorageSettings()
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
        <div class="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center">
          <i class="pi pi-database text-sm"></i>
        </div>
        <div>
          <h3 class="text-sm font-extrabold text-slate-800">Espace de Stockage Fichiers</h3>
          <p class="text-[11px] text-slate-500">Gérez le répertoire local ou les connecteurs de stockage cloud.</p>
        </div>
      </div>
      <div class="flex items-center gap-3">
        <span 
          class="px-2 py-0.5 rounded text-[10px] font-bold border"
          :class="[
            form.type === 'Desactiver' 
              ? 'bg-rose-50 text-rose-700 border-rose-100' 
              : 'bg-emerald-50 text-emerald-700 border-emerald-100'
          ]"
        >
          {{ form.type === 'Desactiver' ? 'Désactivé' : `Actif: ${form.type}` }}
        </span>
        <i class="pi text-slate-400 transition-transform duration-200 text-xs" :class="isOpen ? 'pi-chevron-up' : 'pi-chevron-down'"></i>
      </div>
    </div>

    <!-- Panel Body (Collapsible) -->
    <div v-show="isOpen" class="p-6 transition-all duration-300">
      <div v-if="loading" class="py-6 flex items-center justify-center text-slate-400 gap-2 text-xs">
        <i class="pi pi-spin pi-spinner text-emerald-500"></i>
        Chargement de la configuration de stockage...
      </div>

      <div v-else class="space-y-5">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <!-- Type de Stockage -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">
              Type de Stockage
            </label>
            <select 
              v-model="form.type"
              :disabled="!isEditing"
              class="w-full px-3 py-2 border rounded-lg text-xs font-semibold transition-all cursor-pointer disabled:cursor-not-allowed"
              :class="isEditing ? 'border-slate-300 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500/50 outline-none text-slate-800' : 'border-slate-100 bg-slate-50 text-slate-500'"
            >
              <option value="Desactiver">Désactivé</option>
              <option value="Local">Stockage Local</option>
              <option value="Google">Google Drive</option>
              <option value="Microsoft">OneDrive (Microsoft)</option>
            </select>
          </div>

          <!-- Chemin Local -->
          <div v-if="form.type === 'Local'">
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">
              Chemin Absolu Répertoire Local
            </label>
            <input 
              v-model="form.path"
              :disabled="!isEditing"
              type="text" 
              placeholder="ex. C:\DentisteApp\Storage"
              class="w-full px-3 py-2 border rounded-lg text-xs font-semibold transition-all"
              :class="isEditing ? 'border-slate-300 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500/50 outline-none text-slate-800' : 'border-slate-100 bg-slate-50 text-slate-500 cursor-not-allowed'"
            />
          </div>

          <!-- Compte Cloud Connecté -->
          <div v-if="form.type === 'Google' || form.type === 'Microsoft'">
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">
              Compte Cloud (Email)
            </label>
            <input 
              v-model="form.account"
              :disabled="!isEditing"
              type="email" 
              placeholder="ex. dental.cabinet@gmail.com"
              class="w-full px-3 py-2 border rounded-lg text-xs font-semibold transition-all"
              :class="isEditing ? 'border-slate-300 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500/50 outline-none text-slate-800' : 'border-slate-100 bg-slate-50 text-slate-500 cursor-not-allowed'"
            />
          </div>

          <!-- Token d'authentification Cloud -->
          <div v-if="form.type === 'Google' || form.type === 'Microsoft'">
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">
              Token OAuth / API Key
            </label>
            <input 
              v-model="form.token"
              :disabled="!isEditing"
              :type="isEditing ? 'password' : 'text'"
              :placeholder="isEditing ? (hasStoredToken ? 'Laisser vide pour ne pas modifier' : 'Entrer le token') : (hasStoredToken ? '••••••••••••••••' : 'Non configuré')"
              class="w-full px-3 py-2 border rounded-lg text-xs font-semibold transition-all"
              :class="isEditing ? 'border-slate-300 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500/50 outline-none text-slate-800' : 'border-slate-100 bg-slate-50 text-slate-500 cursor-not-allowed'"
            />
          </div>
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
              @click="saveStorageSettings"
              :disabled="saving"
              class="px-4 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white rounded-lg text-xs font-bold transition-all shadow-sm flex items-center gap-2 cursor-pointer disabled:opacity-50"
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
