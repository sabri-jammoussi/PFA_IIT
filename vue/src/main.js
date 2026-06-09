import './assets/main.css'
import 'primeicons/primeicons.css'

import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'

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

// Configure PrimeVue with Aura Theme Preset and Tailwind Interoperability
app.use(PrimeVue, {
  theme: {
    preset: Aura,
    options: {
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
