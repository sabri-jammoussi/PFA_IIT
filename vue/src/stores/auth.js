import api from '@/services/api'
import { defineStore } from 'pinia'

// Utility function to decode JWT payload in the browser
function decodeJwt(token) {
  try {
    const base64Url = token.split('.')[1]
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/')
    const jsonPayload = decodeURIComponent(
      window.atob(base64)
        .split('')
        .map((c) => '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2))
        .join('')
    )
    return JSON.parse(jsonPayload)
  } catch (error) {
    console.error('Failed to decode JWT token:', error)
    return null
  }
}

// Map decoded claims to standard user object structure
function mapTokenToUser(token) {
  if (!token) return null
  const payload = decodeJwt(token)
  if (!payload) return null
  return {
    id: parseInt(payload.id || payload.sub || '0'),
    username: payload.unique_name || '',
    email: payload.email || '',
    nom: payload.nom || '',
    prenom: payload.prenom || '',
    roleName: payload.role || '',
    cabinetId: payload.cabinetId ? parseInt(payload.cabinetId) : null,
    cabinetName: payload.cabinetName || ''
  }
}

export const useAuthStore = defineStore('auth', {
  state: () => {
    const token = localStorage.getItem('denti_token') || null
    return {
      token,
      user: mapTokenToUser(token),
      loading: false,
      error: null
    }
  },

  getters: {
    isAuthenticated: (state) => !!state.token,
    role: (state) => {
      let dbRole = state.user?.roleName || null
      if (Array.isArray(dbRole)) {
        dbRole = dbRole[0]
      }
      if (dbRole === 'Administrateur' || dbRole === 'Admin' || dbRole === 1 || dbRole === '1') return 1
      if (dbRole === 'Dentiste' || dbRole === 2 || dbRole === '2') return 2
      if (dbRole === 'Assistant' || dbRole === 'Secretaire' || dbRole === 3 || dbRole === '3') return 3
      if (dbRole === 'Patient' || dbRole === 4 || dbRole === '4') return 4
      return null
    },
    roleName() {
      const r = this.role
      if (r === 1) return 'Admin'
      if (r === 2) return 'Dentiste'
      if (r === 3) return 'Secretaire'
      if (r === 4) return 'Patient'
      return 'Inconnu'
    },
    isAdmin() {
      return this.role === 1
    },
    isDentist() {
      return this.role === 2
    },
    isSecretary() {
      return this.role === 3
    },
    isPatient() {
      return this.role === 4
    },
    fullName: (state) => {
      if (!state.user) return ''
      return `${state.user.prenom} ${state.user.nom}`.trim()
    }
  },

  actions: {
    async login(username, password) {
      this.loading = true
      this.error = null
      console.log(`[API Request] POST /api/auth/login | Username: "${username}"`)
      try {
        const response = await api.post('/auth/login', { username, password })
        console.log('[API Response] POST /api/auth/login | Success:', response.data)
        const token = response.data?.token || response.data?.Token
        
        if (!token) {
          throw new Error('Réponse d\'authentification incomplète (token manquant).')
        }

        this.token = token
        this.user = mapTokenToUser(token)

        localStorage.setItem('denti_token', token)

        // SaaS storage restructure
        localStorage.setItem('auth_token', token)
        localStorage.setItem('user_role', this.roleName)
        localStorage.setItem('cabinet_id', this.user?.cabinetId || '')
        localStorage.setItem('cabinet_name', this.user?.cabinetName || '')
        
        return { success: true }
      } catch (err) {
        console.error('[API Response Error] POST /api/auth/login | Failed:', err)
        this.error = err.response?.data?.error || err.message || 'Identifiants invalides ou serveur indisponible.'
        return { success: false, error: this.error }
      } finally {
        this.loading = false
      }
    },

    async logout() {
      this.loading = true
      console.log('[API Request] POST /api/auth/logout')
      try {
        // Attempt backend logout to blacklist the JWT in Redis
        const response = await api.post('/auth/logout')
        console.log('[API Response] POST /api/auth/logout | Success:', response.data)
      } catch (err) {
        console.warn('[API Response Error] POST /api/auth/logout | Failed (likely token blacklisted/expired):', err)
      } finally {
        // Always clean local state regardless of server response
        this.token = null
        this.user = null
        localStorage.removeItem('denti_token')
        localStorage.removeItem('auth_token')
        localStorage.removeItem('user_role')
        localStorage.removeItem('cabinet_id')
        localStorage.removeItem('cabinet_name')
        this.loading = false
      }
    },

    loadFromStorage() {
      const token = localStorage.getItem('denti_token')
      if (token) {
        this.token = token
        this.user = mapTokenToUser(token)
      }
    }
  }
})

