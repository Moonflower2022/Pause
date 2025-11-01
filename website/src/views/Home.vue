<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const showIntro = ref(true)
const textFadingOut = ref(false)
const blackFadingOut = ref(false)
const showContent = ref(false)
const typedText = ref('')
const typingComplete = ref(false)
const showScrollHint = ref(false)

const fullText = `When was the last time you actually stopped?

No notifications. No tabs. No distractions.

Just you. Just now.

You never pause.`

const goToInstall = () => {
  router.push('/install')
}

const typeText = () => {
  let index = 0
  const typingSpeed = 70 // milliseconds per character

  const typeInterval = setInterval(() => {
    if (index < fullText.length) {
      typedText.value += fullText[index]
      index++
    } else {
      clearInterval(typeInterval)
      typingComplete.value = true
      // Show scroll hint after typing completes
      setTimeout(() => {
        showScrollHint.value = true
      }, 1000)
    }
  }, typingSpeed)
}

const handleScroll = (e: Event) => {
  if (typingComplete.value && !textFadingOut.value) {
    e.preventDefault()
    // Stage 1: Fade out text (1s)
    textFadingOut.value = true
    // Stage 2: After 1s, fade out black background (1s)
    setTimeout(() => {
      blackFadingOut.value = true
      // Remove intro after black fade completes (1s)
      setTimeout(() => {
        showIntro.value = false
      }, 1000)
    }, 1000)
  }
}

onMounted(() => {
  // Start typing after a brief delay
  setTimeout(() => {
    typeText()
  }, 500)

  // Add scroll listener
  window.addEventListener('wheel', handleScroll)
  window.addEventListener('touchmove', handleScroll)
})

onUnmounted(() => {
  window.removeEventListener('wheel', handleScroll)
  window.removeEventListener('touchmove', handleScroll)
})
</script>

<template>
  <div class="home">
    <!-- Main content (always rendered) -->
    <div class="content">
      <div class="container">
        <h1 class="title">Pause</h1>
        <p class="tagline">Breathe. Reset. Stay Mindful.</p>
        <p class="description">
          A meditation app for macOS that helps you take regular breathing breaks throughout your day.
        </p>
        <button @click="goToInstall" class="cta-button">Get Started</button>
      </div>
    </div>

    <!-- Black intro screen (overlay) -->
    <div v-if="showIntro" class="intro-screen" :class="{ 'black-fading-out': blackFadingOut }">
      <div class="intro-content" :class="{ 'text-fading-out': textFadingOut }">
        <p class="intro-text">{{ typedText }}<span class="cursor">|</span></p>
        <div v-if="showScrollHint" class="scroll-hint">
          <p>↓ scroll to continue</p>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.home {
  height: 100vh;
  overflow: hidden;
  position: relative;
}

/* Intro screen - black with white text */
.intro-screen {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: #000;
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10;
  opacity: 1;
  transition: opacity 1s ease-out;
}

.intro-screen.black-fading-out {
  opacity: 0;
}

.intro-content {
  opacity: 1;
  transition: opacity 1s ease-out;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.intro-content.text-fading-out {
  opacity: 0;
}

.intro-text {
  color: white;
  font-size: 1.8rem;
  font-weight: 400;
  line-height: 1.8;
  text-align: left;
  max-width: 800px;
  padding: 2rem;
  white-space: pre-wrap;
  font-family: 'Courier New', 'Courier', monospace;
  letter-spacing: 0.05em;
}

.cursor {
  opacity: 1;
  animation: blink 0.7s infinite;
}

@keyframes blink {
  0%, 50% {
    opacity: 1;
  }
  51%, 100% {
    opacity: 0;
  }
}

.scroll-hint {
  position: absolute;
  bottom: 3rem;
  left: 50%;
  transform: translateX(-50%);
  color: rgba(255, 255, 255, 0.5);
  font-size: 1rem;
  font-weight: 300;
  animation: fadeInHint 1s ease-out, bounce 2s ease-in-out infinite;
}

@keyframes fadeInHint {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

@keyframes bounce {
  0%, 100% {
    transform: translateX(-50%) translateY(0);
  }
  50% {
    transform: translateX(-50%) translateY(10px);
  }
}

@keyframes fadeInText {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@keyframes fadeOut {
  to {
    opacity: 0;
    visibility: hidden;
  }
}

/* Main content */
.content {
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, rgb(151, 187, 101), rgb(198, 225, 116), rgb(215, 225, 199), rgb(198, 225, 116), rgb(151, 187, 101));
  background-size: 400% 400%;
  animation: gradientShift 15s ease infinite, fadeIn 1s ease-out;
  color: white;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

@keyframes gradientShift {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}

.container {
  text-align: center;
  padding: 2rem;
  max-width: 800px;
}

.title {
  font-size: 6rem;
  font-weight: 700;
  margin-bottom: 1rem;
  letter-spacing: -0.02em;
  animation: fadeInUp 0.8s ease-out;
  text-shadow: 2px 2px 8px rgba(0, 0, 0, 0.3);
}

.tagline {
  font-size: 2rem;
  font-weight: 300;
  margin-bottom: 1.5rem;
  opacity: 0.95;
  animation: fadeInUp 0.8s ease-out 0.2s backwards;
  text-shadow: 2px 2px 6px rgba(0, 0, 0, 0.3);
}

.description {
  font-size: 1.25rem;
  margin-bottom: 3rem;
  opacity: 0.9;
  line-height: 1.7;
  max-width: 600px;
  margin-left: auto;
  margin-right: auto;
  animation: fadeInUp 0.8s ease-out 0.4s backwards;
  text-shadow: 1px 1px 4px rgba(0, 0, 0, 0.3);
}

.cta-button {
  background: white;
  color: rgb(151, 187, 101);
  padding: 1.25rem 3rem;
  font-size: 1.25rem;
  font-weight: 600;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
  animation: fadeInUp 0.8s ease-out 0.6s backwards;
}

.cta-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

@media (max-width: 768px) {
  .title {
    font-size: 3.5rem;
  }

  .tagline {
    font-size: 1.5rem;
  }

  .description {
    font-size: 1.1rem;
  }

  .cta-button {
    font-size: 1.1rem;
    padding: 1rem 2rem;
  }
}
</style>
