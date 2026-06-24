<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { toast } from 'vue3-toastify'
import api from '@/services/api'

const router = useRouter()


const step = ref(1) // Steps: 1 = Clinic Details, 2 = Doctor Details, 3 = Success
const loading = ref(false)
const errorMessage = ref('')

const form = ref({
  nomCabinet: '',
  adresse: '',
  doctorEmail: '',
  doctorPassword: '',
  doctorNom: '',
  doctorPrenom: ''
})

const nextStep = () => {
  if (step.value === 1) {
    if (!form.value.nomCabinet) {
      errorMessage.value = "Le nom du cabinet est obligatoire."
      return
    }
    errorMessage.value = ''
    step.value = 2
  }
}

const prevStep = () => {
  errorMessage.value = ''
  step.value = 1
}

const handleRegister = async () => {
  if (!form.value.doctorEmail || !form.value.doctorPassword || !form.value.doctorNom || !form.value.doctorPrenom) {
    errorMessage.value = "Tous les champs du médecin sont obligatoires."
    return
  }
  
  loading.value = true
  errorMessage.value = ''
  
  try {
    const payload = {
      nomCabinet: form.value.nomCabinet,
      adresse: form.value.adresse || null,
      doctorEmail: form.value.doctorEmail,
      doctorPassword: form.value.doctorPassword,
      doctorNom: form.value.doctorNom,
      doctorPrenom: form.value.doctorPrenom
    }
    
    await api.post('/saas/register', payload)
    
    toast.success(`Inscription réussie\nVotre cabinet a été créé avec succès.`, { autoClose: 5000 })
    
    step.value = 3
  } catch (error) {
    console.error('[API Error] Clinic registration failed:', error)
    errorMessage.value = error.response?.data?.error || "Une erreur s'est produite lors de l'enregistrement de votre cabinet."
    toast.error(`Échec de l'inscription\n${errorMessage.value}`, { autoClose: 5000 })
  } finally {
    loading.value = false
  }
}

const goToLogin = () => {
  router.push('/login')
}
</script>

<template>
  <div class="min-h-screen w-full flex flex-col md:flex-row bg-slate-50 select-none overflow-hidden font-sans">
    
    <!-- LEFT PANEL: SaaS Marketing/Intro Hero -->
    <div class="relative hidden md:flex md:w-2/5 bg-slate-900 flex-col justify-between p-12 lg:p-16 text-white overflow-hidden">
      <!-- Ambient Backdrop -->
      <div class="absolute inset-0 bg-gradient-to-tr from-slate-950 via-slate-900 to-sky-950/40 z-0"></div>
      <div class="absolute inset-0 opacity-[0.03] bg-[linear-gradient(to_right,#808080_1px,transparent_1px),linear-gradient(to_bottom,#808080_1px,transparent_1px)] bg-[size:24px_24px] z-0"></div>
      
      <!-- Tech Light Glow -->
      <div class="absolute top-[20%] right-[-10%] w-[400px] h-[400px] rounded-full bg-sky-500/10 blur-[100px] pointer-events-none z-0"></div>
      <div class="absolute bottom-[-10%] left-[-10%] w-[300px] h-[300px] rounded-full bg-indigo-500/10 blur-[80px] pointer-events-none z-0"></div>

      <!-- Header Logo -->
      <div class="relative z-10 flex items-center gap-3">
        <img 
          src="@/assets/logo-removebg-preview.png" 
          alt="DentiFlow Logo" 
          class="w-10 h-10 object-contain rounded-xl bg-white/10 p-1 flex-shrink-0 shadow-lg"
        />
        <div>
          <h2 class="text-lg font-bold tracking-wider uppercase font-sans">DentiFlow</h2>
          <p class="text-[9px] text-sky-400 tracking-widest font-semibold uppercase">Cloud SaaS Platform</p>
        </div>
      </div>

      <!-- Center copy -->
      <div class="relative z-10 my-auto py-8 max-w-md">
        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-sky-500/10 text-sky-400 text-xs font-semibold border border-sky-500/20 mb-6">
          <span class="w-1.5 h-1.5 rounded-full bg-sky-400 animate-pulse"></span>
          Déploiement Instantané
        </span>
        <h1 class="text-3xl lg:text-4xl font-extrabold tracking-tight text-white leading-tight font-sans">
          Rejoignez la révolution DentiFlow.
        </h1>
        <p class="text-slate-400 text-sm mt-4 font-normal leading-relaxed">
          Enregistrez votre clinique en moins de 2 minutes et accédez immédiatement à un espace de travail cloud isolé et sécurisé pour votre cabinet et votre équipe.
        </p>

        <!-- Dynamic List -->
        <div class="mt-8 space-y-4 text-xs font-semibold">
          <div class="flex items-start gap-3">
            <span class="w-6 h-6 rounded-lg bg-sky-500/10 border border-sky-500/20 flex items-center justify-center text-sky-400 mt-0.5">
              <i class="pi pi-check text-[9px] font-bold"></i>
            </span>
            <div>
              <h3 class="text-white">Base de Données Dédiée</h3>
              <p class="text-slate-400 text-[11px] font-normal mt-0.5">Isolation totale de vos dossiers patients et de votre comptabilité.</p>
            </div>
          </div>
          <div class="flex items-start gap-3">
            <span class="w-6 h-6 rounded-lg bg-sky-500/10 border border-sky-500/20 flex items-center justify-center text-sky-400 mt-0.5">
              <i class="pi pi-check text-[9px] font-bold"></i>
            </span>
            <div>
              <h3 class="text-white">Collaborateurs Illimités</h3>
              <p class="text-slate-400 text-[11px] font-normal mt-0.5">Invitez vos secrétaires et dentistes associés sans frais supplémentaires.</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer Branding -->
      <div class="relative z-10 text-[10px] text-slate-500 flex items-center justify-between border-t border-slate-800/60 pt-4">
        <span>© 2026 DentiFlow SaaS.</span>
        <span>Secure Multi-Tenancy</span>
      </div>
    </div>

    <!-- RIGHT PANEL: Onboarding wizard form -->
    <div class="w-full md:w-3/5 flex flex-col justify-center items-center p-6 sm:p-12 lg:p-20 relative bg-white">
      <!-- Glow decoration (mobile focus) -->
      <div class="absolute top-0 right-0 w-48 h-48 bg-sky-500/5 rounded-full blur-3xl pointer-events-none md:hidden"></div>
      
      <div class="w-full max-w-md space-y-8">
        <!-- Back Link -->
        <div v-if="step < 3" class="flex justify-between items-center text-xs">
          <button 
            @click="router.push('/login')" 
            class="text-slate-500 hover:text-slate-800 transition-colors flex items-center gap-1.5 font-bold cursor-pointer"
          >
            <i class="pi pi-arrow-left text-[10px]"></i>
            <span>Retour à la connexion</span>
          </button>
          <span class="text-slate-400 font-bold">Étape {{ step }} sur 2</span>
        </div>

        <!-- Wizard Progress Bar -->
        <div v-if="step < 3" class="w-full bg-slate-100 h-1.5 rounded-full overflow-hidden">
          <div 
            class="bg-gradient-to-r from-sky-500 to-indigo-500 h-full transition-all duration-300"
            :style="{ width: step === 1 ? '50%' : '100%' }"
          ></div>
        </div>

        <!-- Step 1: Clinic details -->
        <div v-if="step === 1" class="space-y-6">
          <div class="space-y-2">
            <h2 class="text-2xl font-black text-slate-900 tracking-tight">Créez votre Cabinet</h2>
            <p class="text-xs text-slate-400 font-semibold">Commencez par renseigner les informations de base de votre structure.</p>
          </div>

          <div v-if="errorMessage" class="p-3 bg-rose-50 border border-rose-200 text-rose-700 rounded-xl text-xs font-semibold flex items-center gap-2 animate-fade-in">
            <i class="pi pi-exclamation-circle"></i>
            <span>{{ errorMessage }}</span>
          </div>

          <div class="space-y-4 text-xs font-semibold text-slate-700">
            <!-- Nom Cabinet -->
            <div class="space-y-1.5">
              <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Nom du Cabinet *</label>
              <div class="relative">
                <span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                  <i class="pi pi-building text-xs"></i>
                </span>
                <input 
                  v-model="form.nomCabinet"
                  type="text" 
                  required
                  placeholder="Ex: Clinique Dentaire Jasmin"
                  class="w-full pl-9 pr-3 py-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl outline-none text-slate-800 transition-all font-semibold"
                />
              </div>
            </div>

            <!-- Adresse -->
            <div class="space-y-1.5">
              <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Adresse (Optionnelle)</label>
              <div class="relative">
                <span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                  <i class="pi pi-map-marker text-xs"></i>
                </span>
                <input 
                  v-model="form.adresse"
                  type="text" 
                  placeholder="Ex: Route de Téniour, Sfax"
                  class="w-full pl-9 pr-3 py-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl outline-none text-slate-800 transition-all font-semibold"
                />
              </div>
            </div>
          </div>

          <button 
            @click="nextStep"
            class="w-full py-3 px-4 bg-slate-950 hover:bg-slate-850 text-white rounded-xl text-xs font-bold transition-all shadow-lg hover:shadow-xl cursor-pointer flex items-center justify-center gap-1.5"
          >
            <span>Continuer</span>
            <i class="pi pi-chevron-right text-[10px]"></i>
          </button>
        </div>

        <!-- Step 2: Doctor details -->
        <div v-if="step === 2" class="space-y-6">
          <div class="space-y-2">
            <h2 class="text-2xl font-black text-slate-900 tracking-tight">Compte Propriétaire</h2>
            <p class="text-xs text-slate-400 font-semibold">Renseignez vos informations de médecin pour créer vos accès administrateur.</p>
          </div>

          <div v-if="errorMessage" class="p-3 bg-rose-50 border border-rose-200 text-rose-700 rounded-xl text-xs font-semibold flex items-center gap-2 animate-fade-in">
            <i class="pi pi-exclamation-circle"></i>
            <span>{{ errorMessage }}</span>
          </div>

          <div class="space-y-4 text-xs font-semibold text-slate-700">
            <!-- Doctor Names -->
            <div class="grid grid-cols-2 gap-4">
              <div class="space-y-1.5">
                <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Nom *</label>
                <input 
                  v-model="form.doctorNom"
                  type="text" 
                  required
                  placeholder="Ex: Ben Ali"
                  class="w-full px-3 py-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl outline-none text-slate-800 font-semibold"
                />
              </div>
              <div class="space-y-1.5">
                <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Prénom *</label>
                <input 
                  v-model="form.doctorPrenom"
                  type="text" 
                  required
                  placeholder="Ex: Ahmed"
                  class="w-full px-3 py-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl outline-none text-slate-800 font-semibold"
                />
              </div>
            </div>

            <!-- Doctor Email -->
            <div class="space-y-1.5">
              <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Adresse Email *</label>
              <div class="relative">
                <span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                  <i class="pi pi-envelope text-xs"></i>
                </span>
                <input 
                  v-model="form.doctorEmail"
                  type="email" 
                  required
                  placeholder="Ex: dr.ahmed@cabinet.tn"
                  class="w-full pl-9 pr-3 py-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl outline-none text-slate-800 transition-all font-semibold"
                />
              </div>
            </div>

            <!-- Doctor Password -->
            <div class="space-y-1.5">
              <label class="text-[10px] font-bold text-slate-500 uppercase tracking-wide">Mot de passe *</label>
              <div class="relative">
                <span class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                  <i class="pi pi-lock text-xs"></i>
                </span>
                <input 
                  v-model="form.doctorPassword"
                  type="password" 
                  required
                  placeholder="Minimum 8 caractères"
                  class="w-full pl-9 pr-3 py-3 bg-slate-50 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl outline-none text-slate-800 transition-all font-semibold"
                />
              </div>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex gap-4">
            <button 
              @click="prevStep"
              :disabled="loading"
              class="w-1/3 py-3 border border-slate-200 text-xs font-bold text-slate-700 hover:bg-slate-50 rounded-xl transition-all cursor-pointer disabled:opacity-50"
            >
              Retour
            </button>
            <button 
              @click="handleRegister"
              :disabled="loading"
              class="w-2/3 py-3 px-4 bg-slate-950 hover:bg-slate-850 text-white rounded-xl text-xs font-bold transition-all shadow-lg hover:shadow-xl cursor-pointer flex items-center justify-center gap-1.5 disabled:opacity-50"
            >
              <i v-if="loading" class="pi pi-spin pi-spinner"></i>
              <span>Créer le Cabinet</span>
            </button>
          </div>
        </div>

        <!-- Step 3: Success message -->
        <div v-if="step === 3" class="space-y-6 text-center animate-fade-in">
          <div class="w-16 h-16 bg-emerald-50 text-emerald-600 rounded-full flex items-center justify-center mx-auto shadow-sm">
            <i class="pi pi-check text-2xl font-bold"></i>
          </div>

          <div class="space-y-2">
            <h2 class="text-2xl font-black text-slate-900 tracking-tight">Félicitations !</h2>
            <p class="text-xs text-slate-500 font-semibold">
              Le cabinet <strong>{{ form.nomCabinet }}</strong> a été configuré avec succès et le compte de <strong>Dr. {{ form.doctorPrenom }} {{ form.doctorNom }}</strong> est actif.
            </p>
          </div>

          <div class="p-4 bg-slate-50 rounded-xl border border-slate-100 text-left text-xs font-semibold text-slate-600 space-y-2">
            <p class="font-bold text-slate-800 text-center border-b border-slate-200 pb-2 mb-2">Vos informations de connexion</p>
            <p><strong>Identifiant / Email :</strong> {{ form.doctorEmail }}</p>
            <p><strong>Rôle :</strong> Dentiste (Directeur du Cabinet)</p>
          </div>

          <button 
            @click="goToLogin"
            class="w-full py-3 bg-slate-950 hover:bg-slate-850 text-white rounded-xl text-xs font-bold transition-all shadow-lg cursor-pointer"
          >
            Se connecter à DentiFlow
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.animate-fade-in {
  animation: fadeIn 0.25s ease-out forwards;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(4px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
