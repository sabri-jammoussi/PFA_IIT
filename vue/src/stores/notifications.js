import api from '@/services/api'
import { defineStore } from 'pinia'

export const useNotificationsStore = defineStore('notifications', {
  state: () => ({
    notifications: [],
    notificationsCount: 0,
    // Notification preferences matching backend domains and types
    rendezVousNotifications: true,
    rendezVousCreation: true,
    rendezVousMiseAJour: true,
    rendezVousInformation: true,

    factureNotifications: true,
    factureCreation: true,
    factureMiseAJour: true,
    factureInformation: true,

    patientNotifications: true,
    patientCreation: true,
    patientMiseAJour: true,
    patientInformation: true
  }),

  getters: {
    allNotifications: (state) => state.notifications,
    unreadCount: (state) => state.notificationsCount
  },

  actions: {
    async getNotifications() {
      try {
        const response = await api.get('/nf/notifications')
        this.notifications = response.data?.value || []
      } catch (error) {
        console.error('Error fetching notifications:', error)
      }
    },

    async getNotificationsCount() {
      try {
        const response = await api.get('/nf/notifications/count')
        this.notificationsCount = response.data?.value || 0
      } catch (error) {
        console.error('Error fetching notification count:', error)
      }
    },

    async markNotificationAsSeen(id) {
      try {
        await api.post(`/nf/notifications/seen/${id}`)
        await this.getNotifications()
        await this.getNotificationsCount()
      } catch (error) {
        console.error('Error marking notification as seen:', error)
      }
    },

    async markAllAsSeen() {
      try {
        await api.post('/nf/notifications/seen')
        await this.getNotifications()
        await this.getNotificationsCount()
      } catch (error) {
        console.error('Error marking all notifications as seen:', error)
      }
    },

    async refreshNotifications() {
      await Promise.all([this.getNotifications(), this.getNotificationsCount()])
    }
  }
})
