<script setup>
import { ref, onMounted } from 'vue'
import { toast } from 'vue3-toastify'
import api from '@/services/api'


const isOpen = ref(false)
const isEditing = ref(false)
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
      form.value.secret = '' // Clear input
      hasStoredSecret.value = res.data.hasSecret || false
    }
  } catch (error) {
    console.error('[API Error] fetchCloudinarySettings failed:', error)
    toast.error(`Erreur\nImpossible de charger les paramètres Cloudinary.`, { autoClose: 5000 })
  } finally {
    loading.value = false
  }
}

const toggleEdit = () => {
  if (isEditing.value) {
    // Cancel edit
    isEditing.value = false
    fetchCloudinarySettings()
  } else {
    isEditing.value = true
  }
}

const saveCloudinarySettings = async () => {
  saving.value = true
  try {
    const payload = {
      name: form.value.name,
      key: form.value.key,
      secret: form.value.secret || null, // null/empty means don't change
      folder: form.value.folder
    }
    
    await api.post('/options/cloudinary', payload)
    toast.success(`Succès\nConfiguration Cloudinary mise à jour avec succès.`, { autoClose: 3000 })
    isEditing.value = false
    fetchCloudinarySettings()
  } catch (error) {
    console.error('[API Error] saveCloudinarySettings failed:', error)
    toast.error(`Erreur de sauvegarde\nImpossible de sauvegarder les paramètres Cloudinary.`, { autoClose: 5000 })
  } finally {
    saving.value = false
  }
}

onMounted(() => {
  fetchCloudinarySettings()
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
        <div class="w-8 h-8 rounded-lg bg-indigo-50 text-indigo-600 flex items-center justify-center">
          <i class="pi pi-images text-sm"></i>
        </div>
        <div>
          <h3 class="text-sm font-extrabold text-slate-800">Stockage Cloudinary</h3>
          <p class="text-[11px] text-slate-500">Configurez l'hébergement cloud pour les photos et documents cliniques.</p>
        </div>
      </div>
      <div class="flex items-center gap-3">
        <span 
          v-if="form.name" 
          class="px-2 py-0.5 rounded text-[10px] font-bold border bg-indigo-50 text-indigo-700 border-indigo-100"
        >
          {{ form.name }}
        </span>
        <i class="pi text-slate-400 transition-transform duration-200 text-xs" :class="isOpen ? 'pi-chevron-up' : 'pi-chevron-down'"></i>
      </div>
    </div>

    <!-- Panel Body (Collapsible) -->
    <div v-show="isOpen" class="p-6 transition-all duration-300">
      <div v-if="loading" class="py-6 flex items-center justify-center text-slate-400 gap-2 text-xs">
        <i class="pi pi-spin pi-spinner text-indigo-500"></i>
        Chargement de la configuration Cloudinary...
      </div>

      <div v-else class="space-y-5">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <!-- Cloud Name -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">
              Cloud Name
            </label>
            <input 
              v-model="form.name"
              :disabled="!isEditing"
              type="text" 
              placeholder="ex. mon-cloudinary"
              class="w-full px-3 py-2 border rounded-lg text-xs font-semibold transition-all"
              :class="isEditing ? 'border-slate-300 focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500/50 outline-none text-slate-800' : 'border-slate-100 bg-slate-50 text-slate-500 cursor-not-allowed'"
            />
          </div>

          <!-- API Key -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">
              API Key
            </label>
            <input 
              v-model="form.key"
              :disabled="!isEditing"
              type="text" 
              placeholder="ex. 123456789012345"
              class="w-full px-3 py-2 border rounded-lg text-xs font-semibold transition-all"
              :class="isEditing ? 'border-slate-300 focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500/50 outline-none text-slate-800' : 'border-slate-100 bg-slate-50 text-slate-500 cursor-not-allowed'"
            />
          </div>

          <!-- API Secret -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">
              API Secret
            </label>
            <input 
              v-model="form.secret"
              :disabled="!isEditing"
              :type="isEditing ? 'password' : 'text'"
              :placeholder="isEditing ? (hasStoredSecret ? 'Laisser vide pour ne pas modifier' : 'Entrer le secret') : (hasStoredSecret ? '••••••••••••••••' : 'Non configuré')"
              class="w-full px-3 py-2 border rounded-lg text-xs font-semibold transition-all"
              :class="isEditing ? 'border-slate-300 focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500/50 outline-none text-slate-800' : 'border-slate-100 bg-slate-50 text-slate-500 cursor-not-allowed'"
            />
          </div>

          <!-- Dossier Racine -->
          <div>
            <label class="block text-[11px] font-bold text-slate-500 uppercase tracking-wider mb-1.5">
              Dossier racine (Folder)
            </label>
            <input 
              v-model="form.folder"
              :disabled="!isEditing"
              type="text" 
              placeholder="ex. dentiste"
              class="w-full px-3 py-2 border rounded-lg text-xs font-semibold transition-all"
              :class="isEditing ? 'border-slate-300 focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500/50 outline-none text-slate-800' : 'border-slate-100 bg-slate-50 text-slate-500 cursor-not-allowed'"
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
              @click="saveCloudinarySettings"
              :disabled="saving"
              class="px-4 py-1.5 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg text-xs font-bold transition-all shadow-sm flex items-center gap-2 cursor-pointer disabled:opacity-50"
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
