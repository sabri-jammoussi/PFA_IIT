<script setup>
import { ref, computed, watch, defineProps, defineEmits } from 'vue'

const props = defineProps({
  visible: {
    type: Boolean,
    required: true
  },
  act: {
    type: Object,
    default: null
  },
  saving: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['save', 'close'])

const isEdit = computed(() => !!props.act?.id)

const emptyForm = () => ({
  id: null,
  libelle: '',
  codeNomenclature: '',
  tarifDeBase: null
})

const form = ref(emptyForm())

watch(() => props.visible, (newVal) => {
  if (newVal) {
    if (props.act) {
      form.value = {
        id: props.act.id,
        libelle: props.act.libelle || '',
        codeNomenclature: props.act.codeNomenclature || '',
        tarifDeBase: props.act.tarifDeBase ?? null
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
        <h3 class="text-sm font-extrabold text-slate-900 tracking-tight">
          {{ isEdit ? "Modifier l'Acte Médical" : 'Nouvel Acte Médical' }}
        </h3>
        <button
          type="button"
          @click="handleClose"
          class="w-8 h-8 rounded-lg hover:bg-slate-100 flex items-center justify-center text-slate-400 hover:text-slate-700 cursor-pointer"
        >
          <i class="pi pi-times text-xs"></i>
        </button>
      </div>

      <!-- Form fields -->
      <form @submit.prevent="handleSubmit" class="p-6 space-y-4">
        <!-- Libellé -->
        <div class="space-y-1">
          <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Libellé de l'Acte *</label>
          <input
            v-model="form.libelle"
            type="text"
            required
            placeholder="Ex: Détartrage, nettoyage prophylactique et polissage"
            class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
          />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <!-- Code Nomenclature -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Code Nomenclature</label>
            <input
              v-model="form.codeNomenclature"
              type="text"
              placeholder="Ex: SC12"
              class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800 font-mono"
            />
          </div>
          <!-- Tarif de Base -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Tarif de Base (DT) *</label>
            <input
              v-model.number="form.tarifDeBase"
              type="number"
              required
              min="0"
              step="0.01"
              placeholder="Ex: 80.00"
              class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
            />
          </div>
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
