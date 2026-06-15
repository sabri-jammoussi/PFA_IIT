<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useToast } from 'primevue/usetoast'
import api from '@/services/api'
import MedicalActDialog from './MedicalActDialog.vue'
import ConfirmationDialog from '@/components/ConfirmationDialog.vue'

const authStore = useAuthStore()
const toast = useToast()

const loading = ref(false)
const saving = ref(false)
const acts = ref([])

// Only the Dentiste may mutate the catalog — the backend gates POST/PUT/DELETE
// on /actes-medicaux to the Dentiste role, so others see it read-only.
const canManage = computed(() => authStore.isDentist)

// Add / edit dialog
const showDialog = ref(false)
const selectedAct = ref(null)

// Delete confirmation
const showDeleteConfirm = ref(false)
const actIdToDelete = ref(null)

const fetchActs = async () => {
  loading.value = true
  console.log('[API Request] GET /actes-medicaux')
  try {
    const res = await api.get('/actes-medicaux')
    console.log(`[API Response] GET /actes-medicaux | Status: ${res.status}`, res.data)
    acts.value = res.data?.items || res.data || []
  } catch (error) {
    console.error('[API Error] fetchActs failed:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur de chargement',
      detail: 'Impossible de récupérer le catalogue des actes médicaux.',
      life: 5000
    })
  } finally {
    loading.value = false
  }
}

const openCreate = () => {
  selectedAct.value = null
  showDialog.value = true
}

const openEdit = (act) => {
  selectedAct.value = { ...act }
  showDialog.value = true
}

const closeDialog = () => {
  showDialog.value = false
  selectedAct.value = null
}

const handleSave = async (formData) => {
  saving.value = true
  const isEdit = !!formData.id
  const payload = {
    libelle: formData.libelle,
    tarifDeBase: Number(formData.tarifDeBase),
    codeNomenclature: formData.codeNomenclature || null
  }

  try {
    if (isEdit) {
      console.log(`[API Request] PUT /actes-medicaux/${formData.id}`, payload)
      const res = await api.put(`/actes-medicaux/${formData.id}`, { id: formData.id, ...payload })
      console.log(`[API Response] PUT /actes-medicaux/${formData.id} | Status: ${res.status}`)
      toast.add({ severity: 'success', summary: 'Acte mis à jour', detail: "L'acte médical a été modifié.", life: 3000 })
    } else {
      console.log('[API Request] POST /actes-medicaux', payload)
      const res = await api.post('/actes-medicaux', payload)
      console.log(`[API Response] POST /actes-medicaux | Status: ${res.status}`, res.data)
      toast.add({ severity: 'success', summary: 'Acte créé', detail: "Le nouvel acte a été ajouté au catalogue.", life: 3000 })
    }
    closeDialog()
    fetchActs()
  } catch (error) {
    console.error('[API Error] save act failed:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur de sauvegarde',
      detail: isEdit ? "Impossible de modifier l'acte médical." : "Impossible de créer le nouvel acte médical.",
      life: 5000
    })
  } finally {
    saving.value = false
  }
}

const requestDelete = (id) => {
  actIdToDelete.value = id
  showDeleteConfirm.value = true
}

const confirmDelete = async () => {
  showDeleteConfirm.value = false
  const id = actIdToDelete.value
  if (!id) return

  try {
    console.log(`[API Request] DELETE /actes-medicaux/${id}`)
    const res = await api.delete(`/actes-medicaux/${id}`)
    console.log(`[API Response] DELETE /actes-medicaux/${id} | Status: ${res.status}`)
    toast.add({ severity: 'success', summary: 'Acte supprimé', detail: "L'acte a été retiré du catalogue.", life: 3000 })
    fetchActs()
  } catch (error) {
    console.error('[API Error] delete act failed:', error)
    toast.add({
      severity: 'error',
      summary: 'Erreur de suppression',
      detail: "Impossible de supprimer l'acte médical.",
      life: 5000
    })
  } finally {
    actIdToDelete.value = null
  }
}

onMounted(() => {
  fetchActs()
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">

    <!-- Header Controls -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div>
        <h1 class="text-xl font-extrabold text-slate-900 tracking-tight">Catalogue des Actes Médicaux</h1>
        <p class="text-xs text-slate-500 mt-1">Guide de nomenclature clinique de référence et tarifs de base applicables.</p>
      </div>

      <button
        v-if="canManage"
        @click="openCreate"
        class="flex items-center justify-center gap-2 px-4 py-2.5 bg-slate-900 hover:bg-slate-800 text-white text-xs font-semibold rounded-xl transition-all shadow-md shadow-slate-900/10 cursor-pointer"
      >
        <i class="pi pi-plus text-xs"></i>
        <span>Nouvel acte</span>
      </button>
    </div>

    <!-- Data List -->
    <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm overflow-hidden">

      <div v-if="loading" class="py-20 flex flex-col items-center justify-center text-slate-400 gap-2">
        <i class="pi pi-spin pi-spinner text-3xl text-sky-500"></i>
        <span class="text-xs font-semibold">Chargement de la nomenclature...</span>
      </div>

      <div v-else-if="acts.length === 0" class="py-20 text-center text-slate-400 text-xs font-medium">
        Aucun acte médical enregistré dans le catalogue.
      </div>

      <div v-else class="divide-y divide-slate-100">
        <!-- Header -->
        <div class="hidden md:flex items-center px-6 py-3 bg-slate-50/50 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
          <div class="w-1/6">Code Nomenclature</div>
          <div :class="canManage ? 'w-1/2' : 'w-7/12'">Libellé de l'Acte Clinique</div>
          <div class="w-1/6 text-right">Tarif de Base</div>
          <div v-if="canManage" class="w-1/6 text-right">Actions</div>
        </div>

        <!-- Rows -->
        <div
          v-for="act in acts"
          :key="act.id"
          class="flex flex-col md:flex-row md:items-center px-6 py-4 hover:bg-slate-50/50 transition-colors text-xs font-semibold text-slate-700 gap-2 md:gap-0"
        >
          <div class="w-full md:w-1/6">
            <span class="px-2 py-1 bg-slate-100 text-slate-800 rounded font-mono font-extrabold">
              {{ act.codeNomenclature || 'N/A' }}
            </span>
          </div>
          <div :class="canManage ? 'md:w-1/2' : 'md:w-7/12'" class="w-full font-extrabold text-slate-900">
            {{ act.libelle }}
          </div>
          <div class="w-full md:w-1/6 text-right font-extrabold text-slate-950">
            {{ Number(act.tarifDeBase).toFixed(2) }} DT
          </div>

          <!-- Actions -->
          <div v-if="canManage" class="w-full md:w-1/6 flex items-center justify-end gap-2 mt-2 md:mt-0">
            <button
              @click="openEdit(act)"
              title="Modifier l'acte"
              class="p-1.5 bg-white hover:bg-slate-100 text-slate-500 hover:text-slate-800 rounded-lg border border-slate-200 flex items-center justify-center transition-all cursor-pointer shadow-sm"
            >
              <i class="pi pi-pencil text-xs"></i>
            </button>
            <button
              @click="requestDelete(act.id)"
              title="Supprimer l'acte"
              class="p-1.5 bg-white hover:bg-rose-50 text-slate-400 hover:text-rose-600 rounded-lg border border-slate-200 flex items-center justify-center transition-all cursor-pointer shadow-sm hover:border-rose-200"
            >
              <i class="pi pi-trash text-xs"></i>
            </button>
          </div>
        </div>

      </div>

    </div>

    <!-- Add / Edit Dialog -->
    <MedicalActDialog
      :visible="showDialog"
      :act="selectedAct"
      :saving="saving"
      @save="handleSave"
      @close="closeDialog"
    />

    <!-- Delete Confirmation -->
    <ConfirmationDialog
      :visible="showDeleteConfirm"
      title="Supprimer l'Acte"
      message="Voulez-vous vraiment retirer cet acte du catalogue ? Cette action est définitive."
      confirm-label="Supprimer"
      cancel-label="Annuler"
      @confirm="confirmDelete"
      @cancel="showDeleteConfirm = false"
    />

  </div>
</template>
