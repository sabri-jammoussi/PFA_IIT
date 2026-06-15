<script setup>
import { ref, watch, defineProps, defineEmits } from 'vue'

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

const emit = defineEmits(['restock', 'close'])

const quantiteAjoutee = ref(null)

watch(() => props.visible, (newVal) => {
  if (newVal) {
    quantiteAjoutee.value = null
  }
})

const handleSubmit = () => {
  if (quantiteAjoutee.value && quantiteAjoutee.value > 0) {
    emit('restock', {
      id: props.article.id,
      quantiteAjoutee: quantiteAjoutee.value
    })
  }
}

const handleClose = () => {
  emit('close')
}
</script>

<template>
  <div
    v-if="visible && article"
    class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4 animate-fade-in font-sans"
  >
    <div class="bg-white border border-slate-200 rounded-2xl shadow-2xl max-w-sm w-full overflow-hidden">
      <!-- Header -->
      <div class="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50/50">
        <h3 class="text-sm font-extrabold text-slate-900 tracking-tight flex items-center gap-2">
          <i class="pi pi-plus-circle text-emerald-500"></i>
          Approvisionner le Stock
        </h3>
        <button
          type="button"
          @click="handleClose"
          class="w-8 h-8 rounded-lg hover:bg-slate-100 flex items-center justify-center text-slate-400 hover:text-slate-700 cursor-pointer transition-colors"
        >
          <i class="pi pi-times text-xs"></i>
        </button>
      </div>

      <!-- Content -->
      <form @submit.prevent="handleSubmit" class="p-6 space-y-5">
        <!-- Article info -->
        <div class="bg-slate-50 rounded-xl p-4 border border-slate-100">
          <p class="text-[10px] font-bold text-slate-400 uppercase tracking-wider mb-1">Article</p>
          <p class="text-sm font-extrabold text-slate-900">{{ article.nom }}</p>
          <div class="flex items-center gap-4 mt-3">
            <div>
              <p class="text-[9px] font-bold text-slate-400 uppercase tracking-wider">Stock actuel</p>
              <p class="text-lg font-black mt-0.5" :class="[article.quantiteEnStock <= article.seuilAlerte ? 'text-rose-600' : 'text-slate-900']">
                {{ article.quantiteEnStock }}
                <span class="text-[10px] font-bold text-slate-400 ml-0.5">{{ article.unite }}</span>
              </p>
            </div>
            <div>
              <p class="text-[9px] font-bold text-slate-400 uppercase tracking-wider">Seuil alerte</p>
              <p class="text-lg font-black text-amber-600 mt-0.5">
                {{ article.seuilAlerte }}
              </p>
            </div>
          </div>
        </div>

        <!-- Quantity input -->
        <div class="space-y-1.5">
          <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Quantité reçue *</label>
          <div class="relative">
            <input
              v-model.number="quantiteAjoutee"
              type="number"
              required
              min="1"
              placeholder="Saisir la quantité livrée..."
              class="w-full py-3 px-4 text-sm bg-emerald-50/50 border-2 border-emerald-200 focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500 rounded-xl outline-none text-slate-800 font-bold transition-all"
              autofocus
            />
            <span class="absolute right-3 top-1/2 -translate-y-1/2 text-[10px] font-bold text-slate-400 uppercase">{{ article.unite }}</span>
          </div>
          <p v-if="quantiteAjoutee && quantiteAjoutee > 0" class="text-[10px] text-emerald-600 font-semibold">
            → Nouveau stock : <span class="font-extrabold">{{ article.quantiteEnStock + quantiteAjoutee }} {{ article.unite }}</span>
          </p>
        </div>

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
            :disabled="saving || !quantiteAjoutee || quantiteAjoutee <= 0"
            class="px-4 py-2 bg-emerald-600 hover:bg-emerald-700 disabled:bg-slate-200 text-white text-xs font-semibold rounded-xl transition-all cursor-pointer shadow-md shadow-emerald-600/20 disabled:cursor-not-allowed disabled:text-slate-400 flex items-center gap-1.5"
          >
            <i v-if="saving" class="pi pi-spin pi-spinner"></i>
            <i v-else class="pi pi-plus text-[10px]"></i>
            <span>Confirmer la réception</span>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>
