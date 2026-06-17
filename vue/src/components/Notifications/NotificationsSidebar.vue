<script setup>
import { computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useNotificationsStore } from '@/stores/notifications'
import { useAuthStore } from '@/stores/auth'

const props = defineProps({
  visible: {
    type: Boolean,
    required: true
  }
})

const emit = defineEmits(['update:visible', 'close'])

const router = useRouter()
const store = useNotificationsStore()
const authStore = useAuthStore()

const notifications = computed(() => store.notifications)
const count = computed(() => store.notificationsCount)

const close = () => {
  emit('update:visible', false)
  emit('close')
}

const formatDateTime = (dateStr) => {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  
  // Format to relative time or standard localized string
  const diffMs = new Date() - date
  const diffMins = Math.floor(diffMs / 60000)
  
  if (diffMins < 1) return "À l'instant"
  if (diffMins < 60) return `Il y a ${diffMins} min`
  
  const diffHours = Math.floor(diffMins / 60)
  if (diffHours < 24) return `Il y a ${diffHours} h`
  
  return date.toLocaleDateString('fr-FR', {
    day: '2-digit',
    month: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const handleNotificationClick = async (item) => {
  // Mark notification as seen
  if (!item.isSeen) {
    await store.markNotificationAsSeen(item.id)
  }
  
  close()

  const role = authStore.role

  // Route based on domaine
  if (item.domaine === 0) {
    // RendezVous
    if (role === 2) { // Dentist
      router.push({ name: 'DentistDashboard' })
    } else if (role === 3) { // Secretary
      router.push({ name: 'SecretaireAgenda' })
    } else if (role === 4) { // Patient
      router.push({ name: 'PatientDashboard' })
    }
  } else if (item.domaine === 1) {
    // Facture
    if (role === 3) { // Secretary
      router.push({ name: 'SecretaireBilling' })
    } else if (role === 4) { // Patient
      router.push({ name: 'PatientDashboard' })
    }
  } else if (item.domaine === 2) {
    // Patient
    if (role === 2 || role === 3) { // Dentist or Secretary
      router.push({ name: 'DentistPatientProfile', params: { id: item.entityId } })
    }
  }
}

const markAllAsSeen = async () => {
  await store.markAllAsSeen()
}

onMounted(() => {
  store.getNotifications()
  store.getNotificationsCount()
})
</script>

<template>
  <Transition name="slide-fade">
    <div v-if="visible" class="fixed inset-0 z-50 flex justify-end">
      <!-- Backdrop -->
      <div 
        @click="close" 
        class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm transition-opacity duration-300"
      ></div>

      <!-- Drawer Content (Slate Theme) -->
      <div class="relative w-full max-w-md bg-white h-full shadow-2xl flex flex-col z-10 border-l border-slate-200/50">
        
        <!-- Header -->
        <div class="h-16 bg-slate-900 text-white px-5 flex items-center justify-between border-b border-slate-800">
          <div class="flex items-center gap-2.5">
            <i class="pi pi-bell text-lg text-sky-400"></i>
            <span class="text-base font-bold tracking-tight">Centre de notifications</span>
          </div>
          <button 
            @click="close" 
            class="w-8 h-8 rounded-lg hover:bg-slate-800 flex items-center justify-center text-slate-400 hover:text-white transition-colors cursor-pointer"
          >
            <i class="pi pi-times text-sm"></i>
          </button>
        </div>

        <!-- Toolbar -->
        <div class="px-5 py-3.5 bg-slate-50 border-b border-slate-200/60 flex justify-between items-center text-xs font-semibold text-slate-500">
          <span v-if="count > 0">
            Vous avez <b class="text-sky-600 font-extrabold">{{ count }}</b> nouvelle(s) notification(s)
          </span>
          <span v-else>
            Aucune nouvelle notification
          </span>
          
          <button 
            v-if="count > 0" 
            @click="markAllAsSeen" 
            class="text-sky-600 hover:text-sky-700 font-bold transition-colors cursor-pointer"
          >
            Tout marquer lu
          </button>
        </div>

        <!-- Notification List -->
        <div class="flex-1 overflow-y-auto divide-y divide-slate-100">
          <div v-if="notifications.length === 0" class="h-64 flex flex-col items-center justify-center text-slate-400 gap-2">
            <i class="pi pi-inbox text-3xl opacity-50"></i>
            <span class="text-xs font-semibold">Aucune notification pour le moment</span>
          </div>
          
          <div 
            v-for="item in notifications" 
            :key="item.id"
            @click="handleNotificationClick(item)"
            class="p-4 hover:bg-slate-50 transition-colors flex gap-3.5 cursor-pointer relative"
            :class="[item.isSeen ? '' : 'bg-sky-500/5 hover:bg-sky-500/10']"
          >
            <!-- Unread status dot -->
            <span 
              v-show="!item.isSeen" 
              class="absolute left-2.5 top-5 w-2 h-2 rounded-full bg-sky-500 shadow-md shadow-sky-400"
            ></span>

            <!-- Domaine Icon Badge -->
            <div 
              class="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0 text-sm shadow-sm border border-slate-100"
              :class="[
                item.isSeen 
                  ? 'bg-slate-100 text-slate-500 border-slate-200/40' 
                  : 'bg-sky-50 text-sky-600 border-sky-100'
              ]"
            >
              <i v-if="item.domaine === 0" class="pi pi-calendar"></i>
              <i v-else-if="item.domaine === 1" class="pi pi-wallet"></i>
              <i v-else-if="item.domaine === 2" class="pi pi-users"></i>
              <i v-else class="pi pi-bell"></i>
            </div>

            <!-- Content -->
            <div class="flex-1 min-w-0">
              <div class="flex justify-between items-baseline gap-2 mb-1">
                <span class="text-xs font-semibold text-slate-800 truncate">{{ item.title }}</span>
                <span class="text-[9px] font-bold text-slate-400 uppercase tracking-wider flex-shrink-0">
                  {{ formatDateTime(item.dateRappel) }}
                </span>
              </div>
              <p class="text-xs text-slate-500 leading-normal whitespace-pre-line">{{ item.description }}</p>
            </div>
          </div>
        </div>

        <!-- Footer -->
        <div class="p-3 bg-slate-50 border-t border-slate-200/60 text-center">
          <button 
            @click="close" 
            class="w-full py-2 bg-slate-900 text-white font-semibold rounded-lg text-xs hover:bg-slate-800 transition-colors cursor-pointer shadow-md"
          >
            Fermer
          </button>
        </div>
      </div>
    </div>
  </Transition>
</template>

<style scoped>
/* Sidebar transition slide from right */
.slide-fade-enter-active,
.slide-fade-leave-active {
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

.slide-fade-enter-from,
.slide-fade-leave-to {
  transform: translateX(100%);
  opacity: 0;
}
</style>
