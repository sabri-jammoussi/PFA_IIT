<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useToast } from 'primevue/usetoast'
import api from '@/services/api'
import StockDialog from './StockDialog.vue'
import RestockDialog from './RestockDialog.vue'
import ConfirmationDialog from '@/components/ConfirmationDialog.vue'

const authStore = useAuthStore()
const toast = useToast()

const loading = ref(false)
const saving = ref(false)
const articles = ref([])
const searchTerm = ref('')

// Add / edit dialog
const showDialog = ref(false)
const selectedArticle = ref(null)

// Restock dialog
const showRestockDialog = ref(false)
const restockArticle = ref(null)

// Delete confirmation
const showDeleteConfirm = ref(false)
const articleIdToDelete = ref(null)

// Computed
const lowStockCount = computed(() => articles.value.filter(a => a.quantiteEnStock <= a.seuilAlerte).length)

const filteredArticles = computed(() => {
  if (!searchTerm.value.trim()) return articles.value
  const term = searchTerm.value.trim().toLowerCase()
  return articles.value.filter(a =>
    a.nom.toLowerCase().includes(term) ||
    (a.description && a.description.toLowerCase().includes(term)) ||
    a.unite.toLowerCase().includes(term)
  )
})

const fetchArticles = async () => {
  loading.value = true
  console.log('[API Request] GET /articles')
  try {
    const res = await api.get('/articles', { params: { pageSize: 200 } })
    console.log(`[API Response] GET /articles | Status: ${res.status}`, res.data)
    articles.value = res.data?.items || res.data || []
  } catch (error) {
    console.error("[API Error] fetchArticles failed:", error)
    toast.add({ severity: 'error', summary: 'Erreur de chargement', detail: 'Impossible de charger la liste des articles.', life: 3000 })
  } finally {
    loading.value = false
  }
}

const openCreate = () => {
  selectedArticle.value = null
  showDialog.value = true
}

const openEdit = (article) => {
  selectedArticle.value = { ...article }
  showDialog.value = true
}

const closeDialog = () => {
  showDialog.value = false
  selectedArticle.value = null
}

const openRestock = (article) => {
  restockArticle.value = { ...article }
  showRestockDialog.value = true
}

const closeRestockDialog = () => {
  showRestockDialog.value = false
  restockArticle.value = null
}

const handleSave = async (formData) => {
  saving.value = true
  const isEdit = !!formData.id
  const payload = {
    nom: formData.nom,
    description: formData.description || null,
    quantiteEnStock: Number(formData.quantiteEnStock) || 0,
    seuilAlerte: Number(formData.seuilAlerte) || 0,
    unite: formData.unite || 'Unité'
  }

  try {
    if (isEdit) {
      console.log(`[API Request] PUT /articles/${formData.id}`, payload)
      const res = await api.put(`/articles/${formData.id}`, { id: formData.id, ...payload })
      console.log(`[API Response] PUT /articles/${formData.id} | Status: ${res.status}`)
      toast.add({ severity: 'success', summary: 'Article mis à jour', detail: "Les informations de l'article ont été modifiées.", life: 3000 })
    } else {
      console.log('[API Request] POST /articles', payload)
      const res = await api.post('/articles', payload)
      console.log(`[API Response] POST /articles | Status: ${res.status}`, res.data)
      toast.add({ severity: 'success', summary: 'Article créé', detail: "Le nouvel article a été ajouté au catalogue de stock.", life: 3000 })
    }
    closeDialog()
    fetchArticles()
  } catch (error) {
    console.error("[API Error] save article failed:", error)
    toast.add({ severity: 'error', summary: 'Erreur d\'enregistrement', detail: 'Impossible d\'enregistrer les modifications.', life: 3000 })
  } finally {
    saving.value = false
  }
}

const handleRestock = async ({ id, quantiteAjoutee }) => {
  saving.value = true
  try {
    console.log(`[API Request] PATCH /articles/${id}/restock`, { id, quantiteAjoutee })
    const res = await api.patch(`/articles/${id}/restock`, { id, quantiteAjoutee })
    console.log(`[API Response] PATCH /articles/${id}/restock | Status: ${res.status}`)
    toast.add({ severity: 'success', summary: 'Stock mis à jour', detail: `+${quantiteAjoutee} unités ajoutées au stock.`, life: 3000 })
    closeRestockDialog()
    fetchArticles()
  } catch (error) {
    console.error("[API Error] restock failed:", error)
    toast.add({ severity: 'error', summary: 'Erreur de ravitaillement', detail: 'Impossible de mettre à jour la quantité en stock.', life: 3000 })
  } finally {
    saving.value = false
  }
}

const requestDelete = (id) => {
  articleIdToDelete.value = id
  showDeleteConfirm.value = true
}

const confirmDelete = async () => {
  showDeleteConfirm.value = false
  const id = articleIdToDelete.value
  if (!id) return

  try {
    console.log(`[API Request] DELETE /articles/${id}`)
    const res = await api.delete(`/articles/${id}`)
    console.log(`[API Response] DELETE /articles/${id} | Status: ${res.status}`)
    toast.add({ severity: 'success', summary: 'Article supprimé', detail: "L'article a été retiré du stock.", life: 3000 })
    fetchArticles()
  } catch (error) {
    console.error("[API Error] delete article failed:", error)
    toast.add({ severity: 'error', summary: 'Erreur de suppression', detail: 'Impossible de supprimer l\'article.', life: 3000 })
  } finally {
    articleIdToDelete.value = null
  }
}

onMounted(() => {
  fetchArticles()
})
</script>

<template>
  <div class="space-y-6 animate-fade-in font-sans">

    <!-- Header Controls -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div>
        <h1 class="text-xl font-extrabold text-slate-900 tracking-tight">Gestion des Stocks</h1>
        <p class="text-xs text-slate-500 mt-1">Catalogue d'inventaire, approvisionnement et alertes de seuil critique.</p>
      </div>

      <button
        @click="openCreate"
        class="flex items-center justify-center gap-2 px-4 py-2.5 bg-slate-900 hover:bg-slate-800 text-white text-xs font-semibold rounded-xl transition-all shadow-md shadow-slate-900/10 cursor-pointer"
      >
        <i class="pi pi-plus text-xs"></i>
        <span>Nouvel Article</span>
      </button>
    </div>

    <!-- Low Stock Alert Banner -->
    <div
      v-if="lowStockCount > 0 && !loading"
      class="bg-gradient-to-r from-rose-50 to-amber-50 border border-rose-200/60 rounded-xl p-4 flex items-center gap-4 shadow-sm"
    >
      <div class="w-10 h-10 rounded-xl bg-rose-100 flex items-center justify-center flex-shrink-0">
        <i class="pi pi-exclamation-triangle text-rose-600 text-lg animate-pulse"></i>
      </div>
      <div class="flex-1 min-w-0">
        <p class="text-xs font-extrabold text-rose-800">
          {{ lowStockCount }} article{{ lowStockCount > 1 ? 's' : '' }} en rupture ou sous le seuil d'alerte
        </p>
        <p class="text-[10px] text-rose-600/80 font-semibold mt-0.5">
          Ces consommables doivent être réapprovisionnés en urgence pour garantir la continuité des soins.
        </p>
      </div>
      <span class="flex-shrink-0 px-3 py-1.5 bg-rose-600 text-white text-[10px] font-extrabold rounded-lg uppercase tracking-wider animate-pulse shadow-lg shadow-rose-600/20">
        Critique
      </span>
    </div>

    <!-- Search Bar -->
    <div class="relative" v-if="!loading && articles.length > 0">
      <i class="pi pi-search absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-xs"></i>
      <input
        v-model="searchTerm"
        type="text"
        placeholder="Rechercher un article par nom, description ou unité..."
        class="w-full py-2.5 pl-9 pr-4 text-xs bg-white border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl outline-none text-slate-800 transition-all shadow-sm"
      />
    </div>

    <!-- Data Table Card -->
    <div class="bg-white rounded-xl border border-slate-200/65 shadow-sm overflow-hidden">

      <div v-if="loading" class="py-20 flex flex-col items-center justify-center text-slate-400 gap-2">
        <i class="pi pi-spin pi-spinner text-3xl text-sky-500"></i>
        <span class="text-xs font-semibold">Chargement de l'inventaire...</span>
      </div>

      <div v-else-if="filteredArticles.length === 0" class="py-20 text-center text-slate-400 text-xs font-medium">
        <i class="pi pi-box text-3xl text-slate-300 block mb-3"></i>
        {{ searchTerm.trim() ? 'Aucun article trouvé pour cette recherche.' : 'Aucun article enregistré dans le stock.' }}
      </div>

      <div v-else class="divide-y divide-slate-100">
        <!-- Header -->
        <div class="hidden md:flex items-center px-6 py-3 bg-slate-50/50 text-[10px] font-bold text-slate-400 uppercase tracking-wider">
          <div class="w-[30%]">Article</div>
          <div class="w-[20%]">Description</div>
          <div class="w-[12%] text-center">Qté en Stock</div>
          <div class="w-[10%] text-center">Seuil</div>
          <div class="w-[10%] text-center">Unité</div>
          <div class="w-[18%] text-right">Actions</div>
        </div>

        <!-- Rows -->
        <div
          v-for="article in filteredArticles"
          :key="article.id"
          class="flex flex-col md:flex-row md:items-center px-6 py-4 hover:bg-slate-50/50 transition-all text-xs font-semibold text-slate-700 gap-2 md:gap-0 border-l-[3px]"
          :class="[
            article.quantiteEnStock <= article.seuilAlerte
              ? 'border-l-rose-400 bg-rose-50/30'
              : 'border-l-transparent'
          ]"
        >
          <!-- Nom -->
          <div class="w-full md:w-[30%]">
            <div class="flex items-center gap-2">
              <span
                v-if="article.quantiteEnStock <= article.seuilAlerte"
                class="w-2 h-2 rounded-full bg-rose-500 animate-pulse flex-shrink-0"
              ></span>
              <span class="font-extrabold text-slate-900">{{ article.nom }}</span>
            </div>
          </div>

          <!-- Description -->
          <div class="w-full md:w-[20%] text-slate-500 truncate">
            {{ article.description || '—' }}
          </div>

          <!-- Qté en Stock -->
          <div class="w-full md:w-[12%] text-center">
            <span
              class="inline-flex items-center justify-center px-2.5 py-1 rounded-lg font-extrabold text-xs min-w-[3rem]"
              :class="[
                article.quantiteEnStock <= 0
                  ? 'bg-rose-100 text-rose-700 border border-rose-200'
                  : article.quantiteEnStock <= article.seuilAlerte
                    ? 'bg-amber-100 text-amber-700 border border-amber-200'
                    : 'bg-emerald-50 text-emerald-700 border border-emerald-100'
              ]"
            >
              {{ article.quantiteEnStock }}
            </span>
          </div>

          <!-- Seuil -->
          <div class="w-full md:w-[10%] text-center text-slate-400 font-bold">
            {{ article.seuilAlerte }}
          </div>

          <!-- Unité -->
          <div class="w-full md:w-[10%] text-center">
            <span class="px-2 py-0.5 bg-slate-100 text-slate-600 rounded text-[10px] font-bold">
              {{ article.unite }}
            </span>
          </div>

          <!-- Actions -->
          <div class="w-full md:w-[18%] flex items-center justify-end gap-1.5 mt-2 md:mt-0">
            <button
              @click="openRestock(article)"
              title="Approvisionner"
              class="px-2 py-1.5 bg-emerald-50 hover:bg-emerald-100 text-emerald-600 hover:text-emerald-700 rounded-lg border border-emerald-200 flex items-center justify-center gap-1 transition-all cursor-pointer text-[10px] font-bold"
            >
              <i class="pi pi-plus text-[9px]"></i>
              <span class="hidden lg:inline">Stock</span>
            </button>
            <button
              @click="openEdit(article)"
              title="Modifier l'article"
              class="p-1.5 bg-white hover:bg-slate-100 text-slate-500 hover:text-slate-800 rounded-lg border border-slate-200 flex items-center justify-center transition-all cursor-pointer shadow-sm"
            >
              <i class="pi pi-pencil text-xs"></i>
            </button>
            <button
              @click="requestDelete(article.id)"
              title="Supprimer l'article"
              class="p-1.5 bg-white hover:bg-rose-50 text-slate-400 hover:text-rose-600 rounded-lg border border-slate-200 flex items-center justify-center transition-all cursor-pointer shadow-sm hover:border-rose-200"
            >
              <i class="pi pi-trash text-xs"></i>
            </button>
          </div>
        </div>

      </div>

    </div>

    <!-- Summary footer -->
    <div v-if="!loading && articles.length > 0" class="flex items-center justify-between text-[10px] text-slate-400 font-bold uppercase tracking-wider px-1">
      <span>{{ articles.length }} article{{ articles.length > 1 ? 's' : '' }} référencé{{ articles.length > 1 ? 's' : '' }}</span>
      <span v-if="lowStockCount > 0" class="text-rose-500">
        <i class="pi pi-exclamation-circle mr-1"></i>
        {{ lowStockCount }} en alerte
      </span>
    </div>

    <!-- Add / Edit Dialog -->
    <StockDialog
      :visible="showDialog"
      :article="selectedArticle"
      :saving="saving"
      @save="handleSave"
      @close="closeDialog"
    />

    <!-- Restock Dialog -->
    <RestockDialog
      :visible="showRestockDialog"
      :article="restockArticle"
      :saving="saving"
      @restock="handleRestock"
      @close="closeRestockDialog"
    />

    <!-- Delete Confirmation -->
    <ConfirmationDialog
      :visible="showDeleteConfirm"
      title="Supprimer l'Article"
      message="Voulez-vous vraiment supprimer cet article du catalogue de stock ? Cette action est définitive et les recettes associées seront également supprimées."
      confirm-label="Supprimer"
      cancel-label="Annuler"
      @confirm="confirmDelete"
      @cancel="showDeleteConfirm = false"
    />

  </div>
</template>
