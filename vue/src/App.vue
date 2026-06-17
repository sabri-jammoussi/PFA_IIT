<script setup>
import { RouterView } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useNotificationsStore } from '@/stores/notifications'
import { useToast } from 'primevue/usetoast'
import { onMounted, onBeforeUnmount } from 'vue'
import useSignalx from '@/utilities/useSignalx'
import { toast } from 'vue3-toastify'
import 'vue3-toastify/dist/index.css'

const authStore = useAuthStore()
const notificationsStore = useNotificationsStore()
const primeToast = useToast()

const { connection } = useSignalx('App', 'notif')

// Request browser notification permission on app load
const requestNotificationPermission = async () => {
  if ('Notification' in window && Notification.permission === 'default') {
    try {
      await Notification.requestPermission()
      console.log('[Notification] Permission:', Notification.permission)
    } catch (error) {
      console.error('[Notification] Error requesting permission:', error)
    }
  }
}

// Strip HTML tags and decode HTML entities for plain text display.
// Uses DOMParser (inert document) so no scripts run and no <img onerror>/resource
// loads can be triggered by untrusted notification content.
const stripHtml = (html) => {
  if (!html) return ''
  html = html.replace(/<br\s*\/?>/gi, '\n')
  const doc = new DOMParser().parseFromString(html, 'text/html')
  let text = doc.body.textContent || ''
  return text
    .split(/\n/)
    .map((line) => line.replace(/\s+/g, ' ').trim())
    .filter((line) => line.length > 0)
    .join('\n')
}

// Show toast notification as fallback using vue3-toastify (matches reference App.vue style)
const showToastNotification = (title, body) => {
  // Render as plain text only — never interpret backend content as HTML (XSS).
  toast.info(`${stripHtml(title)}\n${stripHtml(body)}`, {
    icon: '🔔',
    autoClose: 10000,
    containerId: 'notification',
    type: 'info',
    position: 'bottom-right',
    transition: 'slide',
    bodyClassName: 'custom-toast-body',
    dangerouslyHTMLString: false
  })
}

// Show native browser notification or fallback to toast
const showBrowserNotification = (title, body) => {
  if ('Notification' in window && Notification.permission === 'granted') {
    const cleanTitle = stripHtml(title)
    const cleanBody = stripHtml(body)
    const uniqueTag = 'app-notification-' + Date.now()

    const notification = new Notification(cleanTitle, {
      body: cleanBody,
      icon: '/layout/images/logo_entete.png',
      badge: '/layout/images/logo_entete.png',
      tag: uniqueTag,
      requireInteraction: false,
      silent: false
    })

    notification.onclick = () => {
      window.focus()
      notification.close()
    }
  } else {
    showToastNotification(title, body)
  }
}

// Exact receiveNotification callback structure adapted for Dentist backend domains (Rendez-vous, Factures, Patients)
const receiveNotification = async (data) => {
  console.log('[SignalR] *******SignalR*********', data)
  await notificationsStore.refreshNotifications()

  // Grab user IDs for filtering
  const currentUserId = authStore.user?.id
  const targetUserId = data.userId || data.createdTo

  // Filter 1: If notification is intended for a different user, ignore it
  if (currentUserId && targetUserId && parseInt(currentUserId) !== parseInt(targetUserId)) {
    console.log('[SignalR] receive-notification notification is for another user', { targetUserId, currentUserId })
    return
  }

  // Filter 2: Conditional filtering based on domain (RendezVous=0, Facture=1, Patient=2) and type (Creation=1, MiseAJour=2, Information=3)
  let shouldNotify = false

  if (data?.domaine == 0) { // RendezVous
    if (notificationsStore.rendezVousNotifications) {
      if (data?.type == 1 && notificationsStore.rendezVousCreation) {
        shouldNotify = true
      } else if (data?.type == 2 && notificationsStore.rendezVousMiseAJour) {
        shouldNotify = true
      } else if (data?.type == 3 && notificationsStore.rendezVousInformation) {
        shouldNotify = true
      }
    }
  } else if (data?.domaine == 1) { // Facture / Paiement
    if (notificationsStore.factureNotifications) {
      if (data?.type == 1 && notificationsStore.factureCreation) {
        shouldNotify = true
      } else if (data?.type == 2 && notificationsStore.factureMiseAJour) {
        shouldNotify = true
      } else if (data?.type == 3 && notificationsStore.factureInformation) {
        shouldNotify = true
      }
    }
  } else if (data?.domaine == 2) { // Patient
    if (notificationsStore.patientNotifications) {
      if (data?.type == 1 && notificationsStore.patientCreation) {
        shouldNotify = true
      } else if (data?.type == 2 && notificationsStore.patientMiseAJour) {
        shouldNotify = true
      } else if (data?.type == 3 && notificationsStore.patientInformation) {
        shouldNotify = true
      }
    }
  } else {
    // Default fallback for general or uncategorized notifications
    shouldNotify = true
  }

  if (shouldNotify) {
    showBrowserNotification(data?.title || 'Notification', '\n' + (data.content || data.description || ''))
  }
}

onMounted(() => {
  requestNotificationPermission()
  connection.on('ReceiveMessage', receiveNotification)
  if (authStore.isAuthenticated) {
    notificationsStore.refreshNotifications()
  }
})

onBeforeUnmount(() => {
  connection.off('ReceiveMessage', receiveNotification)
})
</script>

<template>
  <!-- Global Toast Notifications -->
  <PToast position="top-right" />
  
  <!-- Active Route View -->
  <RouterView />
</template>

<style>
#notification .custom-toast-body {
  line-height: 0.9rem;
}
</style>
