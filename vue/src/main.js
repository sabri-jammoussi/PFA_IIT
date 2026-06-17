import './assets/main.css'
import 'primeicons/primeicons.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'

// Vue3Toastify import
import Vue3Toastify from 'vue3-toastify'
import 'vue3-toastify/dist/index.css'

// PrimeVue imports
import PrimeVue from 'primevue/config'
import Aura from '@primeuix/themes/aura'
import ToastService from 'primevue/toastservice'

// PrimeVue components
import Button from 'primevue/button'
import InputText from 'primevue/inputtext'
import Password from 'primevue/password'
import Toast from 'primevue/toast'
import Select from 'primevue/select'

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(Vue3Toastify, {
  autoClose: 5000,
  position: 'top-center'
})

// Hydrate authentication state from storage at startup
import { useAuthStore } from '@/stores/auth'
const authStore = useAuthStore()
authStore.loadFromStorage()

// Configure PrimeVue with Aura Theme Preset and Tailwind Interoperability
app.use(PrimeVue, {
  theme: {
    preset: Aura,
    options: {
      // Never auto-switch to dark: '.app-dark' is never applied, so PrimeVue
      // overlays (Select panels, etc.) always render light to match the app.
      darkModeSelector: '.app-dark',
      cssLayer: {
        name: 'primevue',
        order: 'tailwind-base, primevue, tailwind-utilities'
      }
    }
  }
})
app.use(ToastService)

// Global component registration
app.component('PButton', Button)
app.component('PInputText', InputText)
app.component('PPassword', Password)
app.component('PToast', Toast)
app.component('Select', Select)
app.component('Dropdown', Select)

app.mount('#app')
