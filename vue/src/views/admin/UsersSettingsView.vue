<script setup>
import { ref, onMounted, watch } from 'vue'
import { toast } from 'vue3-toastify'
import api from '@/services/api'
import { useAuthStore } from '@/stores/auth'


const authStore = useAuthStore()
const loading = ref(false)
const users = ref([])
const cabinets = ref([])

// Pagination & Filtering
const search = ref('')
const roleId = ref(null)
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
  roleId: 3,
  cabinetId: null,
  isActive: true
})

const fetchUsers = async () => {
  loading.value = true
  try {
    const params = {
      page: page.value,
      pageSize: pageSize.value,
      search: search.value || undefined,
      roleId: roleId.value || undefined
    }
    const res = await api.get('/users', { params })
    if (res.data) {
      users.value = res.data.items || []
      totalCount.value = res.data.totalCount || 0
    }
  } catch (error) {
    console.error('[API Error] fetchUsers failed:', error)
    toast.error(`Erreur\nImpossible de charger la liste des utilisateurs.`, { autoClose: 5000 })
  } finally {
    loading.value = false
  }
}

const fetchCabinets = async () => {
  if (!authStore.isAdmin) return
  try {
    const res = await api.get('/cabinet')
    cabinets.value = res.data || []
  } catch (error) {
    console.error('[API Error] fetchCabinets failed:', error)
  }
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
    cabinetId: null,
    isActive: true
  }
  showDialog.value = true
}

// Open Dialog for Edit
const openEditDialog = (user) => {
  isEditMode.value = true
  form.value = {
    id: user.id,
    username: user.username,
    email: user.email,
    password: '',
    nom: user.nom,
    prenom: user.prenom,
    roleId: user.roleId,
    cabinetId: user.cabinetId || null,
    isActive: user.isActive
  }
  showDialog.value = true
}

// Save User (Create or Update)
const saveUser = async () => {
  saving.value = true
  try {
    if (isEditMode.value) {
      const payload = {
        id: form.value.id,
        username: form.value.username,
        email: form.value.email,
        nom: form.value.nom,
        prenom: form.value.prenom,
        isActive: form.value.isActive,
        roleId: form.value.roleId,
        password: form.value.password || undefined
      }
      await api.put(`/users/${form.value.id}`, payload)
      toast.success(`Utilisateur mis à jour\nL'utilisateur ${form.value.prenom} ${form.value.nom} a été modifié avec succès.`, { autoClose: 3000 })
    } else {
      const payload = {
        username: form.value.username,
        email: form.value.email,
        password: form.value.password,
        nom: form.value.nom,
        prenom: form.value.prenom,
        roleId: form.value.roleId,
        cabinetId: authStore.isAdmin ? form.value.cabinetId || undefined : undefined
      }
      await api.post('/users', payload)
      toast.success(`Utilisateur créé\nLe compte de ${form.value.prenom} ${form.value.nom} a été créé avec succès.`, { autoClose: 3000 })
    }
    showDialog.value = false
    fetchUsers()
  } catch (error) {
    console.error('[API Error] saveUser failed:', error)
    const errorMsg = error.response?.data?.detail || "Une erreur s'est produite lors de l'enregistrement."
    toast.error(`Erreur\n${errorMsg}`, { autoClose: 5000 })
  } finally {
    saving.value = false
  }
}

// Delete User
const deleteUser = async (user) => {
  if (!confirm(`Êtes-vous sûr de vouloir supprimer définitivement l'utilisateur ${user.prenom} ${user.nom} ?`)) {
    return
  }
  try {
    await api.delete(`/users/${user.id}`)
    toast.success(`Utilisateur supprimé\nL'utilisateur ${user.prenom} ${user.nom} a été supprimé.`, { autoClose: 3000 })
    fetchUsers()
  } catch (error) {
    console.error('[API Error] deleteUser failed:', error)
    toast.error(`Erreur\nImpossible de supprimer cet utilisateur. Il est possible qu'il soit lié à des données cliniques (rendez-vous, consultations).`, { autoClose: 5000 })
  }
}

// Watchers to trigger reload on filters
watch([search, roleId], () => {
  page.value = 1
  fetchUsers()
})

watch(page, () => {
  fetchUsers()
})

onMounted(() => {
  fetchUsers()
  fetchCabinets()
})

const getInitials = (user) => {
  const p = user.prenom ? user.prenom.charAt(0) : ''
  const n = user.nom ? user.nom.charAt(0) : ''
  return (p + n).toUpperCase() || 'U'
}

const getRoleColor = (roleName) => {
  if (!roleName) return 'bg-slate-50 text-slate-700 border-slate-100'
  const name = roleName.toLowerCase()
  if (name.includes('admin')) return 'bg-rose-50 text-rose-700 border-rose-100'
  if (name.includes('dentist')) return 'bg-sky-50 text-sky-700 border-sky-100'
  if (name.includes('secretaire') || name.includes('secrétaire')) return 'bg-amber-50 text-amber-700 border-amber-100'
  if (name.includes('patient')) return 'bg-indigo-50 text-indigo-700 border-indigo-100'
  return 'bg-slate-50 text-slate-700 border-slate-100'
}

const toggleUserStatus = async (user) => {
  try {
    const originalStatus = user.isActive
    user.isActive = !user.isActive
    
    // We update the active status via PUT /api/users/{id}
    const payload = {
      id: user.id,
      username: user.username,
      email: user.email,
      nom: user.nom,
      prenom: user.prenom,
      isActive: user.isActive,
      roleId: user.roleId
    }
    await api.put(`/users/${user.id}`, payload)
    
    toast.success(`Statut mis à jour\nLe compte de ${user.prenom} ${user.nom} a été ${user.isActive ? 'activé' : 'désactivé'}.`, { autoClose: 3000 })
  } catch (error) {
    console.error('[API Error] toggleUserStatus failed:', error)
    user.isActive = !user.isActive // rollback
    toast.error(`Erreur\nImpossible de modifier le statut de l'utilisateur.`, { autoClose: 5000 })
  }
}
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">
    <!-- Page Header -->
    <div class="bg-white rounded-2xl border border-slate-200/65 shadow-sm p-6 flex flex-col sm:flex-row sm:items-center justify-between gap-4 relative overflow-hidden">
      <div class="absolute top-0 right-0 w-64 h-64 bg-gradient-to-bl from-sky-500/5 to-transparent rounded-full -mr-16 -mt-16 pointer-events-none"></div>
      <div class="flex items-center gap-4">
        <div class="w-12 h-12 rounded-xl bg-sky-50 text-sky-600 flex items-center justify-center flex-shrink-0 shadow-sm">
          <i class="pi pi-users text-xl"></i>
        </div>
        <div>
          <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-slate-900 text-white text-[10px] font-bold uppercase tracking-wider">
            Configuration Système
          </span>
          <h1 class="text-xl font-extrabold text-slate-900 tracking-tight mt-1.5">
            Gestion des Utilisateurs
          </h1>
          <p class="text-xs text-slate-500 mt-0.5">
            Gérez les autorisations, créez, modifiez ou désactivez les comptes des collaborateurs.
          </p>
        </div>
      </div>
      <button 
        @click="openAddDialog"
        class="px-4 py-2.5 bg-slate-950 hover:bg-slate-800 text-white text-xs font-semibold rounded-xl transition-all shadow-md shadow-slate-950/10 cursor-pointer flex-shrink-0 flex items-center gap-1.5"
      >
        <i class="pi pi-user-plus text-xs"></i>
        <span>Nouveau Compte</span>
      </button>
    </div>

    <!-- User Grid and Filters -->
    <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm p-6 space-y-4">
      <div class="flex flex-col sm:flex-row sm:items-center gap-3">
        <!-- Search input -->
        <div class="relative flex-1">
          <span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
            <i class="pi pi-search text-xs"></i>
          </span>
          <input 
            v-model="search"
            type="text" 
            placeholder="Rechercher par nom, email..."
            class="w-full pl-9 pr-3 py-2 border border-slate-200 rounded-lg text-xs font-semibold focus:border-sky-500 focus:ring-1 focus:ring-sky-500/50 outline-none text-slate-800 transition-all"
          />
        </div>

        <!-- Role Select dropdown -->
        <div class="w-full sm:w-48">
          <select 
            v-model="roleId"
            class="w-full px-3 py-2 border border-slate-200 rounded-lg text-xs font-semibold cursor-pointer outline-none focus:border-sky-500 focus:ring-1 focus:ring-sky-500/50 text-slate-800 transition-all"
          >
            <option :value="null">Tous les rôles</option>
            <option v-if="authStore.isAdmin" :value="1">Admin</option>
            <option :value="2">Dentiste</option>
            <option :value="3">Secrétaire</option>
            <option :value="4">Patient</option>
          </select>
        </div>
      </div>

      <!-- Users Table -->
      <div class="border border-slate-150 rounded-lg overflow-hidden shadow-sm">
        <div v-if="loading" class="py-12 flex flex-col items-center justify-center text-slate-400 gap-2">
          <i class="pi pi-spin pi-spinner text-2xl text-sky-500"></i>
          <span class="text-[11px] font-semibold">Récupération de la liste des comptes...</span>
        </div>

        <div v-else-if="users.length === 0" class="py-12 flex flex-col items-center justify-center text-slate-400 gap-2">
          <i class="pi pi-user-minus text-2xl"></i>
          <span class="text-[11px] font-semibold">Aucun utilisateur trouvé</span>
        </div>

        <div v-else class="divide-y divide-slate-100">
          <!-- Table Header -->
          <div class="hidden md:flex items-center px-4 py-3 bg-slate-50 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
            <div :class="authStore.isAdmin ? 'w-1/4' : 'w-1/3'">Utilisateur</div>
            <div class="w-1/4">Email</div>
            <div :class="authStore.isAdmin ? 'w-1/6' : 'w-1/5'">Rôle</div>
            <div v-if="authStore.isAdmin" class="w-1/6">Cabinet</div>
            <div class="w-1/6 text-right">Actions</div>
          </div>

          <!-- Table Rows -->
          <div 
            v-for="user in users" 
            :key="user.id"
            class="flex flex-col md:flex-row md:items-center px-4 py-3.5 hover:bg-slate-50/50 transition-colors text-xs font-semibold text-slate-700 gap-2 md:gap-0"
          >
            <!-- User Avatar & Info -->
            <div class="w-full flex items-center gap-3" :class="authStore.isAdmin ? 'md:w-1/4' : 'md:w-1/3'">
              <div class="w-9 h-9 rounded-full bg-slate-100 text-slate-700 flex items-center justify-center text-xs font-bold border border-slate-205">
                {{ getInitials(user) }}
              </div>
              <div>
                <p class="font-extrabold text-slate-900 leading-tight">
                  {{ user.prenom }} {{ user.nom }}
                </p>
                <p class="text-[10px] text-slate-400">@{{ user.username }}</p>
              </div>
            </div>

            <!-- Email -->
            <div class="w-full md:w-1/4 text-slate-500 break-all md:break-normal">
              {{ user.email }}
            </div>

            <!-- Role badge -->
            <div class="w-full flex items-center" :class="authStore.isAdmin ? 'md:w-1/6' : 'md:w-1/5'">
              <span 
                class="px-2.5 py-0.5 text-[9px] font-bold rounded-full uppercase tracking-wider border"
                :class="getRoleColor(user.roleName)"
              >
                {{ user.roleName || 'Aucun' }}
              </span>
            </div>

            <!-- Cabinet name (only for system Admin) -->
            <div v-if="authStore.isAdmin" class="w-full md:w-1/6 text-slate-550 truncate">
              {{ user.cabinetName || 'Aucun' }}
            </div>

            <!-- Actions (Edit, Delete, Toggle Status) -->
            <div class="w-full md:w-1/6 flex items-center justify-between md:justify-end gap-2.5">
              <button 
                @click="toggleUserStatus(user)"
                class="px-2 py-1 rounded-md text-[10px] font-bold border transition-all cursor-pointer shadow-sm"
                :class="user.isActive 
                  ? 'bg-emerald-50/30 border-emerald-200 text-emerald-700 hover:bg-emerald-50' 
                  : 'bg-rose-50/30 border-rose-200 text-rose-700 hover:bg-rose-50'"
              >
                {{ user.isActive ? 'Actif' : 'Inactif' }}
              </button>

              <button 
                @click="openEditDialog(user)"
                class="w-7 h-7 rounded-lg border border-slate-200 hover:bg-slate-100 flex items-center justify-center text-slate-500 hover:text-slate-800 transition-colors cursor-pointer"
                title="Modifier"
              >
                <i class="pi pi-pencil text-[10px]"></i>
              </button>

              <button 
                @click="deleteUser(user)"
                class="w-7 h-7 rounded-lg border border-rose-100 hover:bg-rose-50 flex items-center justify-center text-rose-500 hover:text-rose-700 transition-colors cursor-pointer"
                title="Supprimer"
              >
                <i class="pi pi-trash text-[10px]"></i>
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Pagination Footer -->
      <div v-if="totalCount > pageSize" class="flex items-center justify-between border-t border-slate-100 pt-4 mt-2">
        <span class="text-[10px] font-semibold text-slate-400">
          Page {{ page }} sur {{ Math.ceil(totalCount / pageSize) }}
        </span>
        <div class="flex items-center gap-1.5">
          <button 
            :disabled="page === 1"
            @click="page--"
            class="p-1 px-2.5 bg-slate-100 hover:bg-slate-200 disabled:opacity-50 text-slate-700 rounded-md text-[10px] font-bold transition-all cursor-pointer"
          >
            Précédent
          </button>
          <button 
            :disabled="page >= Math.ceil(totalCount / pageSize)"
            @click="page++"
            class="p-1 px-2.5 bg-slate-100 hover:bg-slate-200 disabled:opacity-50 text-slate-700 rounded-md text-[10px] font-bold transition-all cursor-pointer"
          >
            Suivant
          </button>
        </div>
      </div>
    </div>

    <!-- User Add/Edit Dialog -->
    <div 
      v-if="showDialog" 
      class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4 animate-fade-in font-sans"
    >
      <div class="bg-white border border-slate-200 rounded-2xl shadow-2xl max-w-md w-full overflow-hidden">
        <!-- Header -->
        <div class="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50/50">
          <h3 class="text-sm font-extrabold text-slate-900 tracking-tight">
            {{ isEditMode ? 'Modifier l\'Utilisateur' : 'Créer un Nouvel Utilisateur' }}
          </h3>
          <button 
            type="button" 
            @click="showDialog = false" 
            class="w-8 h-8 rounded-lg hover:bg-slate-100 flex items-center justify-center text-slate-400 hover:text-slate-700 cursor-pointer"
          >
            <i class="pi pi-times text-xs"></i>
          </button>
        </div>

        <!-- Form Body -->
        <form @submit.prevent="saveUser" class="p-6 space-y-4 text-xs font-semibold text-slate-700">
          <div class="grid grid-cols-2 gap-4">
            <!-- Nom -->
            <div class="space-y-1">
              <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Nom *</label>
              <input 
                v-model="form.nom"
                type="text" 
                required
                placeholder="Ex: Martin"
                class="w-full py-2 px-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
              />
            </div>
            <!-- Prénom -->
            <div class="space-y-1">
              <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Prénom *</label>
              <input 
                v-model="form.prenom"
                type="text" 
                required
                placeholder="Ex: Pierre"
                class="w-full py-2 px-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
              />
            </div>
          </div>

          <!-- Nom d'utilisateur (Username) -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Nom d'utilisateur *</label>
            <input 
              v-model="form.username"
              type="text" 
              required
              placeholder="Ex: p.martin"
              class="w-full py-2 px-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
            />
          </div>

          <!-- Adresse e-mail (Email) -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">E-mail *</label>
            <input 
              v-model="form.email"
              type="email" 
              required
              placeholder="Ex: pierre.martin@cabinet.tn"
              class="w-full py-2 px-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
            />
          </div>

          <!-- Mot de passe (Password) -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">
              Mot de passe {{ isEditMode ? '' : '*' }}
            </label>
            <input 
              v-model="form.password"
              type="password" 
              :required="!isEditMode"
              :placeholder="isEditMode ? 'Laisser vide pour ne pas modifier' : '••••••••'"
              class="w-full py-2 px-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
            />
          </div>

          <!-- Rôle -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Rôle *</label>
            <select 
              v-model="form.roleId"
              required
              class="w-full py-2.5 px-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-850 cursor-pointer"
            >
              <option v-if="authStore.isAdmin" :value="1">Administrateur</option>
              <option :value="2">Dentiste</option>
              <option :value="3">Secrétaire</option>
            </select>
          </div>

          <!-- Cabinet (uniquement pour le Super-Admin lors de la création d'un collaborateur cabinet) -->
          <div v-if="authStore.isAdmin && !isEditMode && form.roleId !== 1" class="space-y-1">
            <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Cabinet d'affectation *</label>
            <select 
              v-model="form.cabinetId"
              required
              class="w-full py-2.5 px-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-850 cursor-pointer"
            >
              <option :value="null" disabled>Sélectionner un cabinet...</option>
              <option v-for="cab in cabinets" :key="cab.id" :value="cab.id">
                {{ cab.nomCabinet }}
              </option>
            </select>
          </div>

          <!-- Actif Toggle (Only if editing) -->
          <div v-if="isEditMode" class="flex items-center gap-2.5 py-1.5">
            <input 
              id="user-active"
              v-model="form.isActive"
              type="checkbox"
              class="h-4 w-4 text-sky-600 focus:ring-sky-500 border-slate-300 rounded cursor-pointer"
            />
            <label for="user-active" class="text-xs font-semibold text-slate-700 select-none cursor-pointer">
              Compte actif et autorisé à se connecter
            </label>
          </div>

          <!-- Footer Buttons -->
          <div class="flex justify-end gap-3 pt-3 border-t border-slate-100">
            <button 
              type="button" 
              @click="showDialog = false"
              class="px-4 py-2 border border-slate-200 text-xs font-semibold text-slate-650 hover:bg-slate-50 rounded-xl transition-all cursor-pointer"
            >
              Annuler
            </button>
            <button 
              type="submit" 
              :disabled="saving"
              class="px-4 py-2 bg-slate-900 hover:bg-slate-800 disabled:bg-slate-200 text-white text-xs font-semibold rounded-xl transition-all cursor-pointer shadow-md flex items-center gap-1.5"
            >
              <i v-if="saving" class="pi pi-spin pi-spinner"></i>
              <span>{{ isEditMode ? 'Enregistrer' : 'Créer le compte' }}</span>
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>
