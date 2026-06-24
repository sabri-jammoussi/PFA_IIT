<script setup>
import { useAuthStore } from '@/stores/auth'
import { toast } from 'vue3-toastify'
import { ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import api from '@/services/api'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()


const username = ref('')
const password = ref('')
const loginError = ref('')

const isReset = ref(false)
const matricule = ref('')
const loadingReset = ref(false)
const requestError = ref('')

const handleLogin = async () => {
  if (!username.value || !password.value) {
    loginError.value = "Veuillez remplir tous les champs."
    toast.warning(`Champs requis\nLe nom d'utilisateur et le mot de passe sont obligatoires.`, { autoClose: 3000 })
    return
  }

  loginError.value = ''
  
  const result = await authStore.login(username.value, password.value)
  
  if (result.success) {
    toast.success(`Connexion réussie\nBienvenue, ${authStore.fullName}`, { autoClose: 3000 })
    
    // Redirect to the path they tried to access, or dashboard.
    // Only allow internal relative paths to prevent open-redirect attacks
    // (e.g. ?redirect=https://evil.com or //evil.com).
    const requested = route.query.redirect
    const isSafeInternalPath =
      typeof requested === 'string' &&
      requested.startsWith('/') &&
      !requested.startsWith('//') &&
      !requested.startsWith('/\\')
    router.push(isSafeInternalPath ? requested : '/')
  } else {
    loginError.value = result.error
    toast.error(`Échec de connexion\n${result.error}`, { autoClose: 4000 })
  }
}

const handleForgetPassword = async () => {
  if (!matricule.value) {
    requestError.value = "Veuillez saisir votre adresse email ou matricule."
    toast.warning(`Champ requis\nL'adresse email ou matricule est obligatoire.`, { autoClose: 3000 })
    return
  }

  requestError.value = ''
  loadingReset.value = true
  
  try {
    const payload = {
      matriculeOrEmail: matricule.value,
      host: window.location.origin
    }
    await api.post('/auth/forget-password', payload)
    
    toast.success(`Demande envoyée\nSi un compte est associé à ce matricule, un email a été envoyé.`, { autoClose: 4000 })
    
    setTimeout(() => {
        isReset.value = false
    }, 2000)
    
  } catch (error) {
    console.error('Erreur lors de la récupération du compte:', error)
    requestError.value = "Une erreur est survenue lors de l'envoi de l'email."
    toast.error(`Échec de la demande\n${requestError.value}`, { autoClose: 4000 })
  } finally {
    loadingReset.value = false
  }
}
</script>

<template>
  <div class="min-h-screen w-full flex flex-col md:flex-row bg-slate-50 select-none overflow-hidden font-sans">
    
    <!-- LEFT PANEL: Hero Area (60% width) -->
    <div class="relative hidden md:flex md:w-3/5 bg-slate-900 flex-col justify-between p-12 lg:p-20 text-white overflow-hidden">
      <!-- Ambient Gradient Backdrop -->
      <div class="absolute inset-0 bg-gradient-to-tr from-slate-950 via-slate-900 to-sky-950/40 z-0"></div>
      
      <!-- Subtle Decorative Grid Pattern -->
      <div class="absolute inset-0 opacity-[0.03] bg-[linear-gradient(to_right,#808080_1px,transparent_1px),linear-gradient(to_bottom,#808080_1px,transparent_1px)] bg-[size:24px_24px] z-0"></div>
      
      <!-- Abstract Tech Light Glow -->
      <div class="absolute top-[20%] right-[-10%] w-[500px] h-[500px] rounded-full bg-sky-500/10 blur-[120px] pointer-events-none z-0"></div>
      <div class="absolute bottom-[-10%] left-[-10%] w-[400px] h-[400px] rounded-full bg-indigo-500/10 blur-[100px] pointer-events-none z-0"></div>

      <!-- Header: Logo & Name -->
      <div class="relative z-10 flex items-center gap-3">
        <img 
          src="@/assets/logo-removebg-preview.png" 
          alt="DentiFlow Logo" 
          class="w-10 h-10 object-contain rounded-xl bg-white/10 p-1 flex-shrink-0 shadow-lg"
        />
        <div>
          <h2 class="text-xl font-bold tracking-wider uppercase font-sans">DentiFlow</h2>
          <p class="text-[10px] text-sky-400 tracking-widest font-semibold uppercase">Workspace Clinique</p>
        </div>
      </div>

      <!-- Center: Main Copy & Graphic -->
      <div class="relative z-10 my-auto py-12 max-w-xl">
        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-sky-500/10 text-sky-400 text-xs font-semibold border border-sky-500/20 mb-6">
          <span class="w-1.5 h-1.5 rounded-full bg-sky-400 animate-pulse"></span>
          Version Enterprise 4.0
        </span>
        <h1 class="text-4xl lg:text-5xl font-bold tracking-tight text-white leading-tight font-sans">
          La gestion clinique dentaire réinventée.
        </h1>
        <p class="text-slate-400 text-base mt-4 font-normal leading-relaxed">
          Un écosystème hautement sécurisé conçu pour les cabinets modernes, unifiant planification avancée, imagerie clinique et facturation.
        </p>

        <!-- Feature List -->
        <div class="mt-8 space-y-4">
          <div class="flex items-start gap-3">
            <span class="w-6 h-6 rounded-lg bg-sky-500/10 border border-sky-500/20 flex items-center justify-center text-sky-400 mt-0.5">
              <i class="pi pi-check text-[10px] font-bold"></i>
            </span>
            <div>
              <h4 class="text-sm font-semibold text-slate-200">Dossier Médical Unique & FDI Schema</h4>
              <p class="text-xs text-slate-400 mt-0.5">Suivi en temps réel de la dentition et historique clinique complet.</p>
            </div>
          </div>
          <div class="flex items-start gap-3">
            <span class="w-6 h-6 rounded-lg bg-sky-500/10 border border-sky-500/20 flex items-center justify-center text-sky-400 mt-0.5">
              <i class="pi pi-clock text-[10px] font-bold"></i>
            </span>
            <div>
              <h4 class="text-sm font-semibold text-slate-200">Planification Intelligente</h4>
              <p class="text-xs text-slate-400 mt-0.5">Grille d'agenda interactive avec alertes automatisées de rappel par SMS/Email.</p>
            </div>
          </div>
          <div class="flex items-start gap-3">
            <span class="w-6 h-6 rounded-lg bg-sky-500/10 border border-sky-500/20 flex items-center justify-center text-sky-400 mt-0.5">
              <i class="pi pi-lock text-[10px] font-bold"></i>
            </span>
            <div>
              <h4 class="text-sm font-semibold text-slate-200">Conformité de Données Médicales</h4>
              <p class="text-xs text-slate-400 mt-0.5">Chiffrement de bout en bout et hébergement agréé données de santé.</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer Info -->
      <div class="relative z-10 flex items-center justify-between text-xs text-slate-500 border-t border-slate-800/60 pt-6">
        <p>&copy; 2026 Cabinet Dentaire intelligent</p>
        <div class="flex items-center gap-3">
          <a href="#" class="hover:text-slate-300 transition-colors">Politique de sécurité</a>
          <span>&bull;</span>
          <a href="#" class="hover:text-slate-300 transition-colors">Support</a>
        </div>
      </div>
    </div>

    <!-- RIGHT PANEL: Auth Card Form (40% width) -->
    <div class="flex-1 flex flex-col justify-center items-center px-6 py-12 md:p-12 lg:p-24 bg-slate-50 relative">
      <!-- Background Ambient Details for Mobile/Tablet -->
      <div class="md:hidden absolute top-[10%] left-[10%] w-[200px] h-[200px] rounded-full bg-sky-500/5 blur-[50px] pointer-events-none"></div>

      <!-- Main Login Container (Soft Entrance Animation) -->
      <div class="w-full max-w-md bg-white border border-slate-200/60 shadow-xl rounded-2xl p-8 transition-all duration-300 relative z-10">
        
        <!-- Clinic Branding for Mobile Header -->
        <div class="flex md:hidden items-center justify-center gap-2 mb-6">
          <img 
            src="@/assets/logo.png" 
            alt="DentiFlow Logo" 
            class="w-8 h-8 object-contain rounded-lg flex-shrink-0"
          />
          <span class="text-lg font-bold text-slate-900 tracking-tight">DentiFlow</span>
        </div>

        <!-- Section Title -->
        <div class="text-center md:text-left mb-6" v-if="!isReset" key="login-header">
          <h2 class="text-2xl font-bold text-slate-900 tracking-tight font-sans">Espace Sécurisé</h2>
          <p class="text-slate-500 text-xs mt-1.5 font-medium">Connectez-vous pour gérer votre clinique dentaire.</p>
        </div>
        <div class="text-center md:text-left mb-6" v-else key="reset-header">
          <h2 class="text-2xl font-bold text-slate-900 tracking-tight font-sans">Mot de passe oublié</h2>
          <p class="text-slate-500 text-xs mt-1.5 font-medium">Veuillez saisir votre email ou matricule pour la récupération de votre compte.</p>
        </div>

        <!-- Error Alert (Low vibrancy muted red state) -->
        <div 
          v-if="!isReset && loginError" 
          class="mb-5 p-3.5 bg-rose-50 border border-rose-200/60 rounded-xl flex items-start gap-2.5 text-rose-700 animate-shake"
        >
          <i class="pi pi-exclamation-circle text-base mt-0.5"></i>
          <div class="text-xs font-semibold leading-relaxed">
            {{ loginError }}
          </div>
        </div>
        <div 
          v-if="isReset && requestError" 
          class="mb-5 p-3.5 bg-rose-50 border border-rose-200/60 rounded-xl flex items-start gap-2.5 text-rose-700 animate-shake"
        >
          <i class="pi pi-exclamation-circle text-base mt-0.5"></i>
          <div class="text-xs font-semibold leading-relaxed">
            {{ requestError }}
          </div>
        </div>

        <!-- Login Form -->
        <form v-if="!isReset" @submit.prevent="handleLogin" class="space-y-5" key="login-form">
          <!-- Input Username -->
          <div class="space-y-1.5">
            <label for="username" class="text-xs font-bold text-slate-700 uppercase tracking-wider">Nom d'utilisateur</label>
            <div class="relative">
              <span class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400">
                <i class="pi pi-user text-sm"></i>
              </span>
              <PInputText 
                id="username"
                v-model="username" 
                type="text" 
                placeholder="Ex: dr.martin" 
                class="w-full py-3.5 pl-10 pr-4 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl transition-all duration-200 text-slate-800 text-sm outline-none bg-slate-50/50 hover:bg-slate-50 focus:bg-white font-medium"
              />
            </div>
          </div>

          <!-- Input Password -->
          <div class="space-y-1.5">
            <div class="flex justify-between items-center">
              <label for="password" class="text-xs font-bold text-slate-700 uppercase tracking-wider">Mot de passe</label>
              <a href="#" @click.prevent="isReset = true" class="text-xs text-sky-600 hover:text-sky-700 font-semibold transition-colors">Mot de passe oublié ?</a>
            </div>
            <div class="relative">
              <span class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400 z-10">
                <i class="pi pi-lock text-sm"></i>
              </span>
              <PPassword 
                id="password"
                v-model="password" 
                :feedback="false"
                toggleMask
                placeholder="Saisissez votre mot de passe" 
                class="w-full"
                inputClass="w-full py-3.5 pl-10 pr-10 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl transition-all duration-200 text-slate-800 text-sm outline-none bg-slate-50/50 hover:bg-slate-50 focus:bg-white font-medium"
              />
            </div>
          </div>

          <!-- Stay Logged In Checkbox -->
          <div class="flex items-center">
            <input 
              id="remember_me" 
              name="remember_me" 
              type="checkbox" 
              class="h-4 w-4 text-sky-600 focus:ring-sky-500 border-slate-300 rounded cursor-pointer"
            />
            <label for="remember_me" class="ml-2 block text-xs text-slate-500 font-semibold cursor-pointer">
              Maintenir ma session active
            </label>
          </div>

          <!-- Submit Button (Glacier Blue Accent) -->
          <PButton 
            type="submit" 
            :loading="authStore.loading" 
            :icon="authStore.loading ? 'pi pi-spin pi-spinner' : 'pi pi-sign-in'"
            :label="authStore.loading ? 'Connexion en cours...' : 'Se connecter'"
            class="w-full py-3.5 bg-slate-900 hover:bg-slate-800 text-white font-semibold rounded-xl text-sm transition-all duration-200 shadow-md shadow-slate-900/10 hover:shadow-lg flex items-center justify-center gap-2 cursor-pointer border-none"
          />

          <!-- Onboarding registration link -->
          <div class="text-center mt-5 pt-3 border-t border-slate-100 text-xs">
            <span class="text-slate-500 font-medium">Nouveau praticien ? </span>
            <router-link :to="{ name: 'register' }" class="text-sky-600 hover:text-sky-700 font-extrabold transition-colors">
              Créer un compte cabinet &rarr;
            </router-link>
          </div>
        </form>

        <!-- Forget Password Form -->
        <form v-else @submit.prevent="handleForgetPassword" class="space-y-5" key="reset-form">
          <!-- Input Username -->
          <div class="space-y-1.5">
            <label for="matricule" class="text-xs font-bold text-slate-700 uppercase tracking-wider">Email ou Matricule</label>
            <div class="relative">
              <span class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-slate-400 z-10">
                <i class="pi pi-envelope text-sm"></i>
              </span>
              <PInputText 
                id="matricule"
                v-model="matricule" 
                type="text" 
                placeholder="Ex: dr.martin@clinique.com" 
                class="w-full py-3.5 pl-10 pr-4 border border-slate-200 focus:border-sky-500 focus:ring-1 focus:ring-sky-500 rounded-xl transition-all duration-200 text-slate-800 text-sm outline-none bg-slate-50/50 hover:bg-slate-50 focus:bg-white font-medium"
              />
            </div>
          </div>

          <!-- Submit Button (Glacier Blue Accent) -->
          <PButton 
            type="submit" 
            :loading="loadingReset" 
            :icon="loadingReset ? 'pi pi-spin pi-spinner' : 'pi pi-send'"
            :label="loadingReset ? 'Envoi en cours...' : 'Envoyer un email'"
            class="w-full py-3.5 bg-sky-600 hover:bg-sky-700 text-white font-semibold rounded-xl text-sm transition-all duration-200 shadow-md shadow-sky-600/20 hover:shadow-lg flex items-center justify-center gap-2 cursor-pointer border-none mt-6"
          />

          <!-- Retour login -->
          <PButton 
            type="button" 
            label="Retour à la connexion"
            @click="isReset = false"
            class="w-full py-3.5 bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold rounded-xl text-sm transition-all duration-200 flex items-center justify-center cursor-pointer border-none"
          />
        </form>
      </div>

      <!-- Technical Compliance Badges (Sterile Clinic Aesthetics) -->
      <div class="mt-8 flex flex-wrap justify-center gap-4 text-[10px] text-slate-400 font-bold uppercase tracking-wider relative z-10">
        <span class="flex items-center gap-1">
          <i class="pi pi-verified text-emerald-500"></i>
          RGPD Compliant
        </span>
        <span class="text-slate-300">&bull;</span>
        <span class="flex items-center gap-1">
          <i class="pi pi-lock text-sky-500"></i>
          SSL 256-bit
        </span>
        <span class="text-slate-300">&bull;</span>
        <span class="flex items-center gap-1">
          <i class="pi pi-server text-indigo-500"></i>
          Hébergement HDS
        </span>
      </div>
    </div>
  </div>
</template>

<style>
/* Smooth slide and shake keyframes for low candidacy error events */
@keyframes shake {
  0%, 100% { transform: translateX(0); }
  10%, 30%, 50%, 70%, 90% { transform: translateX(-4px); }
  20%, 40%, 60%, 80% { transform: translateX(4px); }
}
.animate-shake {
  animation: shake 0.4s ease-in-out;
}

/* Custom override to style the internal primevue password wrapper structure cleanly */
.p-password {
  display: block !important;
}
.p-password-input {
  width: 100% !important;
}
</style>
