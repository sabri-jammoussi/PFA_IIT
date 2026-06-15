<script setup>
import { ref } from 'vue'
import { useAuthStore } from '@/stores/auth'
import { useRouter } from 'vue-router'
import { useToast } from 'primevue/usetoast'
import api from '@/services/api'

const authStore = useAuthStore()
const router = useRouter()
const toast = useToast()
const reactivating = ref(false)

const handleLogout = async () => {
  try {
    await authStore.logout()
    toast.add({
      severity: 'info',
      summary: 'Déconnexion',
      detail: 'Session fermée avec succès.',
      life: 3000
    })
    router.push('/login')
  } catch (error) {
    toast.add({
      severity: 'error',
      summary: 'Erreur',
      detail: 'Erreur lors de la déconnexion.',
      life: 3000
    })
  }
}

const handleReactivate = async () => {
  reactivating.value = true
  try {
    console.log('[API Request] POST /cabinet/subscription/reactivate')
    await api.post('/cabinet/subscription/reactivate')
    
    toast.add({
      severity: 'success',
      summary: 'Abonnement Activé',
      detail: 'Le paiement de la licence a été validé. Redirection vers votre portail...',
      life: 3500
    })

    // Brief delay to let the toast render
    setTimeout(() => {
      const role = authStore.role
      if (role === 2) {
        router.push({ name: 'DentistDashboard' })
      } else if (role === 3) {
        router.push({ name: 'SecretaireDashboard' })
      } else {
        router.push('/')
      }
    }, 2500)
  } catch (error) {
    console.error('[API Error] handleReactivate failed:', error)
    toast.add({
      severity: 'error',
      summary: 'Échec de la transaction',
      detail: 'Impossible de traiter le règlement. Contactez notre support.',
      life: 5000
    })
  } finally {
    reactivating.value = false
  }
}
</script>

<template>
  <div class="min-h-screen w-full flex flex-col justify-center items-center p-6 bg-slate-900 font-sans text-white relative overflow-hidden">
    <!-- PrimeVue Toast -->
    <PToast />

    <!-- Backdrop gradient decoration -->
    <div class="absolute top-0 left-0 w-[500px] h-[500px] bg-sky-500/10 rounded-full blur-3xl -ml-64 -mt-64 pointer-events-none"></div>
    <div class="absolute bottom-0 right-0 w-[500px] h-[500px] bg-indigo-500/5 rounded-full blur-3xl -mr-64 -mb-64 pointer-events-none"></div>

    <div class="bg-slate-950 border border-slate-800 rounded-3xl shadow-2xl max-w-lg w-full p-8 text-center space-y-8 relative z-10">
      
      <!-- Critical Warning Indicator -->
      <div class="w-20 h-20 bg-rose-500/10 border border-rose-500/20 text-rose-500 rounded-3xl flex items-center justify-center mx-auto shadow-inner animate-pulse">
        <i class="pi pi-credit-card text-3xl"></i>
      </div>

      <!-- Main Copy -->
      <div class="space-y-3">
        <h1 class="text-xl font-black tracking-tight uppercase text-rose-500">Licence Suspendue</h1>
        <p class="text-xs text-slate-400 font-bold uppercase tracking-wider">
          Veuillez régulariser votre abonnement
        </p>
      </div>

      <!-- Explanation -->
      <p class="text-xs text-slate-450 leading-relaxed max-w-sm mx-auto font-medium">
        L'abonnement annuel de votre cabinet dentaire <strong>{{ authStore.user?.cabinetName || 'DentiFlow' }}</strong> est arrivé à expiration. L'accès à la fiche clinique, à l'agenda et aux stocks est temporairement restreint.
      </p>

      <!-- Checkout Simulator Box -->
      <div class="p-5 bg-slate-900/60 border border-slate-800/80 rounded-2xl text-left space-y-4">
        <div>
          <p class="text-[9px] font-bold text-sky-400 uppercase tracking-widest">Renouvellement instantané</p>
          <p class="text-xs font-bold text-white mt-1">Régularisation du solde de licence</p>
        </div>
        
        <div class="flex justify-between items-center text-xs font-semibold border-t border-slate-800/80 pt-3 text-slate-400">
          <span>Licence annuelle SaaS :</span>
          <span class="text-white font-extrabold text-sm">1,200.00 DT / an</span>
        </div>

        <button 
          @click="handleReactivate"
          :disabled="reactivating"
          class="w-full py-3 bg-sky-500 hover:bg-sky-600 disabled:bg-slate-800 text-white font-extrabold rounded-xl text-xs tracking-wide transition-all shadow-md shadow-sky-500/10 flex items-center justify-center gap-2 cursor-pointer disabled:cursor-not-allowed uppercase"
        >
          <i v-if="reactivating" class="pi pi-spin pi-spinner text-xs"></i>
          <i v-else class="pi pi-check-circle text-xs"></i>
          <span>Régler l'abonnement en ligne (Simulation)</span>
        </button>
      </div>

      <!-- Footer Actions -->
      <div class="flex flex-col sm:flex-row gap-3 pt-2">
        <button 
          @click="handleLogout"
          class="flex-1 py-2.5 border border-slate-800 hover:bg-slate-900 text-slate-400 hover:text-white rounded-xl text-xs font-bold transition-all cursor-pointer"
        >
          Changer de compte
        </button>
      </div>

    </div>
  </div>
</template>
