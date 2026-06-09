<script setup>
import { ref, watch, defineProps, defineEmits } from 'vue'

const props = defineProps({
  visible: {
    type: Boolean,
    required: true
  },
  saving: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['save', 'close'])

const groupOptions = [
  { value: 'A+', label: 'A+' },
  { value: 'A-', label: 'A-' },
  { value: 'B+', label: 'B+' },
  { value: 'B-', label: 'B-' },
  { value: 'O+', label: 'O+' },
  { value: 'O-', label: 'O-' },
  { value: 'AB+', label: 'AB+' },
  { value: 'AB-', label: 'AB-' }
]

const form = ref({
  nom: '',
  prenom: '',
  dateNaissance: '',
  telephone: '',
  email: '',
  adresse: '',
  antecedentsMedicaux: '',
  groupSanguin: ''
})

watch(() => props.visible, (newVal) => {
  if (newVal) {
    form.value = {
      nom: '',
      prenom: '',
      dateNaissance: '',
      telephone: '',
      email: '',
      adresse: '',
      antecedentsMedicaux: '',
      groupSanguin: ''
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
    <div class="bg-white border border-slate-200 rounded-2xl shadow-2xl max-w-lg w-full overflow-hidden">
      <!-- Header -->
      <div class="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-slate-50/50">
        <h3 class="text-sm font-extrabold text-slate-900 tracking-tight">
          Créer un Nouveau Dossier Patient
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
        <div class="grid grid-cols-2 gap-4">
          <!-- Nom -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Nom *</label>
            <input 
              v-model="form.nom"
              type="text" 
              required
              placeholder="Ex: Martin"
              class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
            />
          </div>
          <!-- Prénom -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Prénom *</label>
            <input 
              v-model="form.prenom"
              type="text" 
              required
              placeholder="Ex: Sophie"
              class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
            />
          </div>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <!-- Date de naissance -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Date de Naissance</label>
            <input 
              v-model="form.dateNaissance"
              type="date" 
              class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
            />
          </div>
          <!-- Téléphone -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Téléphone *</label>
            <input 
              v-model="form.telephone"
              type="text" 
              required
              placeholder="Ex: 06 12 34 56 78"
              class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
            />
          </div>
        </div>

        <div class="grid grid-cols-3 gap-4">
          <!-- Email -->
          <div class="col-span-2 space-y-1">
            <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Email</label>
            <input 
              v-model="form.email"
              type="email" 
              placeholder="Ex: sophie.m@mail.com"
              class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
            />
          </div>
          <!-- Groupe Sanguin -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Groupe Sanguin</label>
            <Dropdown 
              v-model="form.groupSanguin"
              :options="groupOptions"
              optionLabel="label"
              optionValue="value"
              filter
              placeholder="Groupe"
              class="w-full text-xs"
            />
          </div>
        </div>

        <!-- Adresse -->
        <div class="space-y-1">
          <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Adresse Résidence</label>
          <input 
            v-model="form.adresse"
            type="text" 
            placeholder="Ex: 15 Rue de Tunis, Sfax"
            class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800"
          />
        </div>

        <!-- Antécédents Médicaux -->
        <div class="space-y-1">
          <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Antécédents Médicaux / Allergies</label>
          <textarea 
            v-model="form.antecedentsMedicaux"
            rows="3"
            placeholder="Ex: Allergique à la Pénicilline, Asthme..."
            class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-800 resize-none"
          ></textarea>
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
            <span>Enregistrer</span>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>
