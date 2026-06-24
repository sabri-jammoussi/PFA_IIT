<script setup>
import { ref, onMounted } from 'vue'
import { toast } from 'vue3-toastify'
import api from '@/services/api'
import { useAuthStore } from '@/stores/auth'


const authStore = useAuthStore()

const loading = ref(false)
const secretaires = ref([])

// Filtering & Search
const search = ref('')
const page = ref(1)
const pageSize = ref(10)
const totalCount = ref(0)

// Dialog states
const showDialog = ref(false)
const isEditMode = ref(false)
const saving = ref(false)

const form = ref({
  id: null,
  username: '',
  email: '',
  password: '',
  nom: '',
  prenom: '',
  roleId: 3, // Role Secretary
  isActive: true
})

const fetchSecretaires = async () => {
  loading.value = true
  try {
    const params = {
      page: page.value,
      pageSize: pageSize.value,
      search: search.value || undefined,
      roleId: 3 // Filter by Secretary only
    }
    const res = await api.get('/users', { params })
    if (res.data) {
      secretaires.value = res.data.items || []
      totalCount.value = res.data.totalCount || 0
    }
  } catch (error) {
    console.error('Failed to fetch secretaries:', error)
    toast.error(`Erreur\nImpossible de charger la liste des secrétaires.`, { autoClose: 5000 })
  } finally {
    loading.value = false
  }
}

// Generate a random temporary password
const generatePassword = () => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*'
  let pass = ''
  for (let i = 0; i < 10; i++) {
    pass += chars.charAt(Math.floor(Math.random() * chars.length))
  }
  form.value.password = pass
}

// Open Dialog for Add
const openAddDialog = () => {
  isEditMode.value = false
  form.value = {
    id: null,
    username: '',
    email: '',
    password: '',
    nom: '',
    prenom: '',
    roleId: 3,
    isActive: true
  }
  generatePassword() // pre-generate temporary password
  showDialog.value = true
}

// Open Dialog for Edit
const openEditDialog = (sec) => {
  isEditMode.value = true
  form.value = {
    id: sec.id,
    username: sec.username,
    email: sec.email,
    password: '', // blank password unless modifying
    nom: sec.nom,
    prenom: sec.prenom,
    roleId: 3,
    isActive: sec.isActive
  }
  showDialog.value = true
}

// Save (Create or Update)
const saveSecretaire = async () => {
  if (!form.value.nom || !form.value.prenom || !form.value.email || (!isEditMode.value && !form.value.password)) {
    toast.warning(`Champs requis\nVeuillez remplir tous les champs obligatoires.`, { autoClose: 3000 })
    return
  }

  saving.value = true
  try {
    if (isEditMode.value) {
      const payload = {
        id: form.value.id,
        username: form.value.username || form.value.email,
        email: form.value.email,
        nom: form.value.nom,
        prenom: form.value.prenom,
        isActive: form.value.isActive,
        roleId: 3,
        password: form.value.password || undefined
      }
      await api.put(`/users/${form.value.id}`, payload)
      toast.success(`Secrétaire modifiée\nLe profil de ${form.value.prenom} ${form.value.nom} a été mis à jour.`, { autoClose: 3000 })
    } else {
      const payload = {
        username: form.value.username || form.value.email,
        email: form.value.email,
        password: form.value.password,
        nom: form.value.nom,
        prenom: form.value.prenom,
        roleId: 3
      }
      await api.post('/users', payload)
      toast.success(`Secrétaire ajoutée\nLe compte a été créé. Un e-mail d'invitation avec les identifiants a été envoyé à ${form.value.email}.`, { autoClose: 5000 })
    }
    showDialog.value = false
    fetchSecretaires()
  } catch (error) {
    console.error('Failed to save secretary:', error)
    const errorMsg = error.response?.data?.error || 'Une erreur est survenue lors de l\'enregistrement.'
    toast.error(`Erreur\n${errorMsg}`, { autoClose: 4000 })
  } finally {
    saving.value = false
  }
}

// Delete Secretary account
const deleteSecretaire = async (sec) => {
  if (confirm(`Êtes-vous sûr de vouloir supprimer définitivement le compte de ${sec.prenom} ${sec.nom} ?`)) {
    try {
      await api.delete(`/users/${sec.id}`)
      toast.success(`Compte supprimé\nLe compte de la secrétaire a été supprimé avec succès.`, { autoClose: 3000 })
      fetchSecretaires()
    } catch (error) {
      console.error('Failed to delete secretary:', error)
      toast.error(`Erreur\nImpossible de supprimer ce compte.`, { autoClose: 3000 })
    }
  }
}

onMounted(() => {
  fetchSecretaires()
})
</script>

<template>
  <div class="space-y-6 animate-slide-in">
    <!-- Page Header & Action -->
    <div class="flex flex-col sm:flex-row justify-between sm:items-center gap-4 bg-white p-6 rounded-2xl border border-slate-200/60 shadow-sm">
      <div>
        <h1 class="text-xl font-extrabold text-slate-800">Gestion des Secrétaires</h1>
        <p class="text-xs text-slate-400 mt-1">Gérez les comptes d'accès opérationnels pour le secrétariat de votre cabinet.</p>
      </div>

      <button 
        @click="openAddDialog"
        class="px-5 py-3 bg-sky-500 hover:bg-sky-600 text-white font-bold text-xs rounded-xl shadow-md hover:shadow-sky-500/15 transition-all flex items-center gap-2 cursor-pointer self-start sm:self-auto"
      >
        <i class="pi pi-user-plus text-xs"></i>
        <span>Ajouter une Secrétaire</span>
      </button>
    </div>

    <!-- Search bar -->
    <div class="bg-white p-4 rounded-xl border border-slate-200/60 shadow-sm flex items-center gap-3">
      <div class="relative flex-1">
        <i class="pi pi-search absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-sm"></i>
        <input 
          type="text" 
          v-model="search"
          placeholder="Rechercher par nom, prénom, email ou nom d'utilisateur..." 
          @input="fetchSecretaires"
          class="w-full pl-10 pr-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl text-xs focus:outline-none focus:border-sky-500 focus:bg-white transition-all"
        />
      </div>
    </div>

    <!-- Table or Empty state -->
    <div v-if="loading" class="flex flex-col items-center justify-center py-20 gap-3 bg-white border border-slate-200/60 rounded-2xl shadow-sm">
      <i class="pi pi-spin pi-spinner text-3xl text-sky-500"></i>
      <span class="text-xs font-semibold text-slate-500">Chargement des secrétaires...</span>
    </div>

    <div v-else>
      <div v-if="!secretaires.length" class="text-center py-20 bg-white border border-dashed border-slate-200 rounded-2xl">
        <i class="pi pi-users text-4xl text-slate-300"></i>
        <p class="text-sm font-bold text-slate-500 mt-4">Aucune secrétaire enregistrée dans votre cabinet.</p>
        <p class="text-xs text-slate-400 mt-1">Cliquez sur le bouton ci-dessus pour ajouter une secrétaire et lui envoyer ses identifiants.</p>
      </div>

      <div v-else class="overflow-x-auto border border-slate-200/60 rounded-2xl bg-white shadow-sm">
        <table class="w-full text-left border-collapse text-xs">
          <thead>
            <tr class="bg-slate-50/50 text-slate-400 font-extrabold uppercase tracking-wider border-b border-slate-100">
              <th class="p-4">Nom complet</th>
              <th class="p-4">Nom d'utilisateur</th>
              <th class="p-4">E-mail</th>
              <th class="p-4">Date de création</th>
              <th class="p-4 text-center">État</th>
              <th class="p-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            <tr v-for="sec in secretaires" :key="sec.id" class="hover:bg-slate-50/50">
              <td class="p-4 font-bold text-slate-800">
                <div class="flex items-center gap-2.5">
                  <div class="w-7 h-7 rounded-lg bg-sky-50 text-sky-600 font-bold flex items-center justify-center text-[10px] border border-sky-100 uppercase">
                    {{ sec.prenom?.charAt(0) }}{{ sec.nom?.charAt(0) }}
                  </div>
                  <span>{{ sec.prenom }} {{ sec.nom }}</span>
                </div>
              </td>
              <td class="p-4 text-slate-600 font-mono">{{ sec.username }}</td>
              <td class="p-4 text-slate-500">{{ sec.email }}</td>
              <td class="p-4 text-slate-500">
                {{ new Date(sec.createdAt).toLocaleDateString('fr-FR') }}
              </td>
              <td class="p-4 text-center">
                <span 
                  class="px-2 py-0.5 text-[9px] font-extrabold uppercase tracking-wider rounded border inline-block"
                  :class="[sec.isActive ? 'bg-emerald-50 text-emerald-600 border-emerald-100' : 'bg-slate-50 text-slate-400 border-slate-200']"
                >
                  {{ sec.isActive ? 'Actif' : 'Inactif' }}
                </span>
              </td>
              <td class="p-4 text-right">
                <div class="flex justify-end gap-2">
                  <button 
                    @click="openEditDialog(sec)"
                    class="p-2 hover:bg-slate-100 text-slate-500 hover:text-slate-700 rounded-lg transition-colors cursor-pointer border border-slate-100"
                    title="Modifier le compte"
                  >
                    <i class="pi pi-pencil text-xs"></i>
                  </button>
                  <button 
                    @click="deleteSecretaire(sec)"
                    class="p-2 hover:bg-rose-50 text-rose-400 hover:text-rose-600 rounded-lg transition-colors cursor-pointer border border-slate-100"
                    title="Supprimer définitivement"
                  >
                    <i class="pi pi-trash text-xs"></i>
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- DIALOG: Add / Edit Secretary -->
    <Teleport to="body">
      <div v-if="showDialog" class="fixed inset-0 w-screen h-screen bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4 animate-fade-in font-sans">
        <div class="bg-white border border-slate-200 rounded-2xl shadow-2xl max-w-lg w-full overflow-hidden animate-slide-in">
          <!-- Header -->
          <div class="px-6 py-4 border-b border-sky-100/50 flex justify-between items-center bg-sky-50/30">
            <h3 class="text-sm font-extrabold text-sky-950 tracking-tight">
              {{ isEditMode ? 'Modifier Secrétaire' : 'Ajouter une Secrétaire' }}
            </h3>
            <button 
              type="button"
              @click="showDialog = false" 
              class="w-8 h-8 rounded-lg hover:bg-slate-100 flex items-center justify-center text-slate-400 hover:text-slate-700 cursor-pointer"
            >
              <i class="pi pi-times text-xs"></i>
            </button>
          </div>

          <form @submit.prevent="saveSecretaire" class="p-6 space-y-4">
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-1">
                <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Prénom *</label>
                <input 
                  type="text" 
                  v-model="form.prenom"
                  required
                  placeholder="Ex: Fatma"
                  class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
                />
              </div>
              <div class="space-y-1">
                <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Nom *</label>
                <input 
                  type="text" 
                  v-model="form.nom"
                  required
                  placeholder="Ex: Ben Ali"
                  class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
                />
              </div>
            </div>

            <div class="space-y-1">
              <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Adresse E-mail *</label>
              <input 
                type="email" 
                v-model="form.email"
                required
                placeholder="Ex: secretaire@cabinet.com"
                class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
              />
            </div>

            <div class="space-y-1">
              <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Nom d'utilisateur (Optionnel)</label>
              <input 
                type="text" 
                v-model="form.username"
                placeholder="Laissez vide pour utiliser l'adresse email"
                class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
              />
            </div>

            <div class="space-y-1">
              <div class="flex justify-between items-center mb-1">
                <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">
                  {{ isEditMode ? 'Mot de passe (Laisser vide si inchangé)' : 'Mot de passe temporaire d\'invitation *' }}
                </label>
                <button 
                  type="button" 
                  @click="generatePassword" 
                  class="text-[10px] text-sky-650 hover:text-sky-750 font-bold uppercase cursor-pointer"
                >
                  Générer
                </button>
              </div>
              <input 
                type="text" 
                v-model="form.password"
                :required="!isEditMode"
                placeholder="Saisissez ou générez un mot de passe"
                class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
              />
            </div>

            <!-- Active status toggle (Edit mode only) -->
            <div v-if="isEditMode" class="flex items-center gap-2.5 py-1.5">
              <input 
                type="checkbox" 
                id="isActive"
                v-model="form.isActive"
                class="h-4 w-4 text-sky-600 focus:ring-sky-500 border-slate-300 rounded cursor-pointer"
              />
              <label for="isActive" class="text-xs font-semibold text-slate-700 select-none cursor-pointer">Compte actif</label>
            </div>

            <!-- Info warning -->
            <div class="p-3 bg-sky-50/50 border border-sky-100 rounded-xl flex items-start gap-2.5 text-[10px] text-slate-650 leading-normal" v-if="!isEditMode">
              <span class="text-sky-500 font-bold">ℹ️</span>
              <span>En cliquant sur Enregistrer, le compte de la secrétaire sera automatiquement créé pour votre cabinet, et un email d'invitation avec ses identifiants lui sera envoyé immédiatement.</span>
            </div>

            <!-- Action Buttons -->
            <div class="flex justify-end gap-3 pt-3 border-t border-slate-100">
              <button 
                type="button" 
                @click="showDialog = false"
                class="px-4 py-2 border border-slate-200 text-xs font-semibold text-slate-600 hover:bg-slate-50 rounded-xl transition-all cursor-pointer"
              >
                Annuler
              </button>
              <button 
                type="submit" 
                :disabled="saving"
                class="px-4 py-2 bg-sky-500 hover:bg-sky-600 disabled:bg-slate-200 text-white text-xs font-semibold rounded-xl transition-all cursor-pointer shadow-md shadow-sky-500/10 disabled:cursor-not-allowed flex items-center gap-1.5"
              >
                <i v-if="saving" class="pi pi-spin pi-spinner"></i>
                <span>{{ isEditMode ? 'Mettre à jour' : 'Enregistrer' }}</span>
              </button>
            </div>
          </form>
        </div>
      </div>
    </Teleport>
  </div>
</template>
