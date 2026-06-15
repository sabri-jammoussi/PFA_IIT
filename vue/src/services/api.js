import axios from 'axios'
import router from '@/router'

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5094/api',
  headers: {
    'Content-Type': 'application/json'
  }
})

// Request Interceptor: Attach JWT Token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('denti_token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Response Interceptor: Handle 401 Unauthorized
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response && error.response.status === 401) {
      // Clear auth tokens
      localStorage.removeItem('denti_token')
      
      // Redirect to login if not already there
      if (router.currentRoute.value.path !== '/login') {
        router.push({ name: 'login', query: { redirect: router.currentRoute.value.fullPath } })
      }
    }
    if (error.response && error.response.status === 402) {
      // Redirect to subscription-expired if not already there
      if (router.currentRoute.value.path !== '/subscription-expired') {
        router.push({ name: 'SubscriptionExpired' })
      }
    }
    return Promise.reject(error)
  }
)

export default api
