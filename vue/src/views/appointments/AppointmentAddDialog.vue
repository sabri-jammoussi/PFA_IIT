<script setup>
import { ref, watch, defineProps, defineEmits, computed } from 'vue'

const props = defineProps({
  visible: {
    type: Boolean,
    required: true
  },
  patients: {
    type: Array,
    required: true
  },
  dentists: {
    type: Array,
    required: true
  },
  defaultDate: {
    type: String,
    required: true
  },
  defaultSlotTime: {
    type: String,
    default: '08:00'
  },
  defaultDentistId: {
    type: Number,
    default: 1
  },
  saving: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['save', 'close'])

const patientOptions = computed(() => props.patients.map(p => ({
  id: p.id,
  label: `${p.prenom} ${p.nom}`
})))

const dentistOptions = computed(() => props.dentists.map(d => ({
  id: d.id,
  label: `Dr. ${d.prenom || d.nom || d.username || ''} ${d.prenom ? d.nom : ''}`.trim()
})))

const durationOptions = [
  { value: '00:15:00', label: '15 minutes' },
  { value: '00:30:00', label: '30 minutes' },
  { value: '00:45:00', label: '45 minutes' },
  { value: '01:00:00', label: '1 heure' }
]

const statusOptions = [
  { value: 'Planifie', label: 'Planifié' },
  { value: 'Annule', label: 'Annulé' },
  { value: 'Complete', label: 'Terminé' }
]

const form = ref({
  patientId: null,
  dateHeure: '',
  dureeEstimee: '00:30:00',
  motif: '',
  note: '',
  dentisteId: 1,
  statut: 'Planifie'
})

// Initialize form when dialog becomes visible or default settings change
watch(() => props.visible, (newVal) => {
  if (newVal) {
    form.value = {
      patientId: null,
      dateHeure: `${props.defaultDate}T${props.defaultSlotTime}`,
      dureeEstimee: '00:30:00',
      motif: '',
      note: '',
      dentisteId: props.defaultDentistId,
      statut: 'Planifie'
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
        <h3 class="text-sm font-extrabold text-slate-900 tracking-tight">Planification RDV</h3>
        <button 
          type="button" 
          @click="handleClose" 
          class="w-8 h-8 rounded-lg hover:bg-slate-100 flex items-center justify-center text-slate-400 hover:text-slate-700 cursor-pointer"
        >
          <i class="pi pi-times text-xs"></i>
        </button>
      </div>

      <!-- Form Fields -->
      <form @submit.prevent="handleSubmit" class="p-6 space-y-4">
        <!-- Patient Selection -->
        <div class="space-y-1">
          <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Patient *</label>
          <Dropdown 
            v-model="form.patientId"
            :options="patientOptions"
            optionLabel="label"
            optionValue="id"
            filter
            placeholder="Sélectionner le patient"
            class="w-full text-xs font-semibold"
          />
        </div>

        <!-- Date & Time Picker -->
        <div class="space-y-1">
          <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Date & Heure *</label>
          <input 
            v-model="form.dateHeure"
            type="datetime-local" 
            required
            class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-850 font-medium"
          />
        </div>

        <div class="grid grid-cols-2 gap-4">
          <!-- Duration -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Durée Estimée</label>
            <Dropdown 
              v-model="form.dureeEstimee"
              :options="durationOptions"
              optionLabel="label"
              optionValue="value"
              filter
              placeholder="Choisir la durée"
              class="w-full text-xs"
            />
          </div>
          <!-- Dentist Selection -->
          <div class="space-y-1">
            <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Assigner Praticien</label>
            <Dropdown 
              v-model="form.dentisteId"
              :options="dentistOptions"
              optionLabel="label"
              optionValue="id"
              filter
              placeholder="Choisir un médecin"
              class="w-full text-xs"
            />
          </div>
        </div>

        <!-- Statut -->
        <div class="space-y-1">
          <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Statut du Rendez-vous *</label>
          <Dropdown 
            v-model="form.statut"
            :options="statusOptions"
            optionLabel="label"
            optionValue="value"
            placeholder="Sélectionner le statut"
            class="w-full text-xs font-semibold"
          />
        </div>

        <!-- Motif -->
        <div class="space-y-1">
          <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Motif de Consultation *</label>
          <input 
            v-model="form.motif"
            type="text" 
            required
            placeholder="Ex: Détartrage, Soin carie, Urgence..."
            class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-850 font-medium"
          />
        </div>

        <!-- Notes -->
        <div class="space-y-1">
          <label class="text-[10px] font-bold text-slate-600 uppercase tracking-wide">Notes Additionnelles</label>
          <textarea 
            v-model="form.note"
            rows="2"
            placeholder="Annotations optionnelles..."
            class="w-full py-2 px-3 text-xs bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-lg outline-none text-slate-850 resize-none font-medium"
          ></textarea>
        </div>

        <!-- Action Buttons -->
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
            <span>Valider le Rendez-vous</span>
          </button>
        </div>
      </form>
    </div>
  </div>
</template>
