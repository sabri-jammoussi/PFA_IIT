<script setup>
import { ref, computed, watch, defineProps, defineEmits } from 'vue'

const props = defineProps({
  visible: {
    type: Boolean,
    required: true
  },
  article: {
    type: Object,
    default: null
  },
  saving: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['save', 'close'])

const isEdit = computed(() => !!props.article?.id)

const emptyForm = () => ({
  id: null,
  nom: '',
  description: '',
  quantiteEnStock: null,
  seuilAlerte: null,
  unite: 'Unité'
})

const form = ref(emptyForm())

const uniteOptions = ['Unité', 'Boîte', 'Flacon', 'Seringue', 'Paire', 'Sachet', 'Tube', 'Cartouche']

watch(() => props.visible, (newVal) => {
  if (newVal) {
    if (props.article) {
      form.value = {
        id: props.article.id,
        nom: props.article.nom || '',
        description: props.article.description || '',
        quantiteEnStock: props.article.quantiteEnStock ?? null,
        seuilAlerte: props.article.seuilAlerte ?? null,
        unite: props.article.unite || 'Unité'
      }
    } else {
      form.value = emptyForm()
    }
  }
}, { immediate: true })

const handleSubmit = () => {
  emit('save', { ...form.value })
}

const handleClose = () => {
  emit('close')
}
</script>

<template>
  <div
    v-if="visible"
    class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4 animate-fade-in font-sans"
  >
    <div class="bg-white border border-slate-200 rounded-2xl shadow-2xl max-w-md w-full overflow-hidden">
      <!-- Header -->
      <div class="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50/50">
        <h3 class="text-sm font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
          <i class="pi pi-box text-sky-500"></i>
          {{ isEdit ? "Modifier l'Article" : 'Nouvel Article' }}
        </h3>
        <button
          type="button"
          @click="handleClose"
          class="w-8 h-8 rounded-lg hover:bg-slate-100 flex items-center justify-center text-slate-400 hover:text-slate-700 cursor-pointer transition-colors"
        >
          <i class="pi pi-times text-xs"></i>
        </button>
      </div>

      <!-- Form fields -->
      <form @submit.prevent="handleSubmit" class="p-6 space-y-4">
        <!-- Nom -->
        <div class="space-y-1">
          <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Nom de l'article *</label>
          <input
            v-model="form.nom"
            type="text"
            required
            placeholder="Ex: Anesthésique Septodont Articaine"
            class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800 transition-all"
          />
        </div>

        <!-- Description -->
        <div class="space-y-1">
          <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Description</label>
          <textarea
            v-model="form.description"
            rows="2"
            placeholder="Description ou référence fournisseur..."
            class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800 resize-none transition-all"
          ></textarea>
        </div>

        <div class="grid grid-cols-3 gap-3">
          <!-- Quantité en Stock -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Qté initiale *</label>
            <input
              v-model.number="form.quantiteEnStock"
              type="number"
              required
              min="0"
              placeholder="50"
              :disabled="isEdit"
              class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
            />
          </div>
          <!-- Seuil d'Alerte -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Seuil Alerte *</label>
            <input
              v-model.number="form.seuilAlerte"
              type="number"
              required
              min="0"
              placeholder="10"
              class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800 transition-all"
            />
          </div>
          <!-- Unité -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Unité</label>
            <select
              v-model="form.unite"
              class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800 cursor-pointer transition-all"
            >
              <option v-for="opt in uniteOptions" :key="opt" :value="opt">{{ opt }}</option>
            </select>
          </div>
        </div>

        <!-- Note for edit mode -->
        <p v-if="isEdit" class="text-[10px] text-amber-600 font-semibold bg-amber-50 px-3 py-2 rounded-lg border border-amber-100">
          <i class="pi pi-info-circle mr-1"></i>
          Pour modifier la quantité en stock, utilisez le bouton « Approvisionner » sur la page principale.
        </p>

        <!-- Actions -->
        <div class="flex justify-end gap-3 pt-3 border-t border-slate-100">
          <button
            type="button"
            @click="handleClose"
            class="px-4 py-2 border border-slate-200 text-xs font-semibold text-slate-600 hover:bg-slate-50 rounded-xl transition-all cursor-pointer"
          >
            Annuler
          </button>
          <button
            type="submit"
            :disabled="saving"
            class="px-4 py-2 bg-slate-950 hover:bg-slate-800 disabled:bg-slate-250 text-white text-xs font-semibold rounded-xl transition-all cursor-pointer shadow-md shadow-slate-900/10 disabled:cursor-not-allowed flex items-center gap-1.5"
          >
            <i v-if="saving" class="pi pi-spin pi-spinner"></i>
            <span>{{ isEdit ? 'Mettre à jour' : 'Enregistrer' }}</span>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>
