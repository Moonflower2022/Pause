import { createRouter, createWebHistory } from 'vue-router'
import Home from '../views/Home.vue'
import Install from '../views/Install.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home
    },
    {
      path: '/install',
      name: 'install',
      component: Install
    }
  ]
})

export default router
