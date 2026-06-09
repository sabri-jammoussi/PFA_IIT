<script setup>
import { defineProps, defineEmits } from 'vue'

const props = defineProps({
  visible: {
    type: Boolean,
    required: true
  },
  title: {
    type: String,
    default: 'Confirmation'
  },
  message: {
    type: String,
    required: true
  },
  confirmLabel: {
    type: String,
    default: 'Valider'
  },
  cancelLabel: {
    type: String,
    default: 'Annuler'
  }
})

const emit = defineEmits(['confirm', 'cancel'])

const handleConfirm = () => {
  emit('confirm')
}

const handleCancel = () => {
  emit('cancel')
}
</script>

<template>
  <div 
    v-if="visible" 
    class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-50 flex items-center justify-center p-4 animate-fade-in font-sans"
  >
    <div class="bg-white border border-slate-200 rounded-2xl shadow-2xl max-w-sm w-full overflow-hidden animate-slide-in">
      <!-- Header -->
      <div class="px-5 py-3.5 border-b border-slate-100 flex justify-between items-center bg-slate-50/50">
        <h3 class="text-xs font-extrabold text-slate-900 uppercase tracking-wider flex items-center gap-2">
          <i class="pi pi-exclamation-triangle text-amber-500 text-sm"></i>
          <span>{{ title }}</span>
        </h3>
        <button 
          @click="handleCancel" 
          class="w-7 h-7 rounded-lg hover:bg-slate-150 flex items-center justify-center text-slate-400 hover:text-slate-700 cursor-pointer"
        >
          <i class="pi pi-times text-[10px]"></i>
        </button>
      </div>

      <!-- Body -->
      <div class="p-5">
        <p class="text-xs text-slate-650 leading-relaxed font-semibold">
          {{ message }}
        </p>
      </div>

      <!-- Actions -->
      <div class="px-5 py-3.5 bg-slate-50/40 border-t border-slate-100 flex justify-end gap-2.5">
        <button 
          @click="handleCancel"
          class="px-3 py-1.5 border border-slate-200 text-[11px] font-bold text-slate-600 hover:bg-slate-50 rounded-lg transition-all cursor-pointer"
        >
          {{ cancelLabel }}
        </button>
        <button 
          @click="handleConfirm"
          class="px-3.5 py-1.5 bg-slate-900 hover:bg-slate-800 text-[11px] font-bold text-white rounded-lg transition-all cursor-pointer shadow-sm shadow-slate-900/10"
        >
          {{ confirmLabel }}
        </button>
      </div>
    </div>
  </div>
</template>
