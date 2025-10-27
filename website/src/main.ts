import { createApp } from 'vue'
import App from './App.vue'
import router from './router'

// Global styles to remove black borders
const style = document.createElement('style')
style.textContent = `
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }
  html, body {
    margin: 0;
    padding: 0;
    overflow-x: hidden;
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
  }
  #app {
    margin: 0;
    padding: 0;
  }
`
document.head.appendChild(style)

createApp(App).use(router).mount('#app')
