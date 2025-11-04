<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()
const hasVisited = localStorage.getItem('pauseHasVisited') === 'true'
const showIntro = ref(!hasVisited)
const textFadingOut = ref(false)
const blackFadingOut = ref(false)
const typedText = ref('')
const typingComplete = ref(false)
const showScrollHint = ref(false)
const highlightedIndex = ref(0)

const fullText = `Your brain needs breaks.

Your body needs breaks.

Your work needs breaks.

But you never pause.`

const allBenefitPoints = [
  'Brain processes work during rest',
  'Return with fresh insights',
  'Avoid mental tunneling',
  'Reduce eye strain',
  'Improve posture',
  'Better sleep quality',
  'Stay aware of time',
  'Build healthy habits',
  'Never miss meetings'
]

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

const handleScroll = (e: WheelEvent | TouchEvent) => {
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
        // Mark as visited so they don't see intro again
        localStorage.setItem('pauseHasVisited', 'true')
      }, 1000)
    }, 1000)
  }
}

const rotateHighlight = () => {
  setInterval(() => {
    let newIndex
    do {
      newIndex = Math.floor(Math.random() * allBenefitPoints.length)
    } while (newIndex === highlightedIndex.value)
    highlightedIndex.value = newIndex
  }, 3000)
}

onMounted(() => {
  // Only show intro animation if first visit
  if (!hasVisited) {
    // Start typing after a brief delay
    setTimeout(() => {
      typeText()
    }, 500)

    // Add scroll listener with passive: false to allow preventDefault
    window.addEventListener('wheel', handleScroll as EventListener, { passive: false })
    window.addEventListener('touchmove', handleScroll as EventListener, { passive: false })
  }

  // Start highlight rotation
  rotateHighlight()
})

onUnmounted(() => {
  if (!hasVisited) {
    window.removeEventListener('wheel', handleScroll as EventListener)
    window.removeEventListener('touchmove', handleScroll as EventListener)
  }
})
</script>

<template>
  <div class="home">
    <!-- Main content (always rendered) -->
    <div class="content">
      <div class="container">
        <div class="main-layout">
          <!-- Left Column: Why Breaks -->
          <div class="left-column">
            <div class="title">Why breaks?</div>
            <div class="benefit-card">
              <div class="benefit-label">🧠 Productivity</div>
              <div class="benefit-list">
                <div class="benefit-point" :class="{ 'highlighted': highlightedIndex === 0 }">Brain processes work during rest</div>
                <div class="benefit-point" :class="{ 'highlighted': highlightedIndex === 1 }">Return with fresh insights</div>
                <div class="benefit-point" :class="{ 'highlighted': highlightedIndex === 2 }">Avoid mental tunneling</div>
              </div>
            </div>
            <div class="benefit-card">
              <div class="benefit-label">💪 Health</div>
              <div class="benefit-list">
                <div class="benefit-point" :class="{ 'highlighted': highlightedIndex === 3 }">Reduce eye strain</div>
                <div class="benefit-point" :class="{ 'highlighted': highlightedIndex === 4 }">Improve posture</div>
                <div class="benefit-point" :class="{ 'highlighted': highlightedIndex === 5 }">Better sleep quality</div>
              </div>
            </div>
            <div class="benefit-card">
              <div class="benefit-label">🎯 Awareness</div>
              <div class="benefit-list">
                <div class="benefit-point" :class="{ 'highlighted': highlightedIndex === 6 }">Stay aware of time</div>
                <div class="benefit-point" :class="{ 'highlighted': highlightedIndex === 7 }">Build healthy habits</div>
                <div class="benefit-point" :class="{ 'highlighted': highlightedIndex === 8 }">Never miss meetings</div>
              </div>
            </div>
          </div>

          <!-- Center: Branding -->
          <div class="center-column">
            <!-- Top Video -->
            <div class="center-video">
              <div class="center-video-title">Launch Video!</div>
              <div class="center-video-wrapper">
                <iframe
                  src="https://www.youtube.com/embed/Pvcd4aqd_L8"
                  title="Pause Launch Video"
                  frameborder="0"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowfullscreen
                ></iframe>
              </div>
            </div>

            <div class="logo-container">
              <img src="/pause.png" alt="Pause Logo" class="logo" @click="goToInstall" />
              <div class="waitlist-pointer">
                <div class="arrow">↑</div>
                <div class="pointer-text">click me!</div>
              </div>
            </div>
            <h1 class="title">Pause</h1>
            <p class="tagline">Firmly enforces breaks. Customizable and smart.</p>
            <div class="center-badges">
              <span class="badge">Open Source</span>
              <span class="badge">macOS Native</span>
              <span class="badge">Private</span>
            </div>

            <!-- Bottom Video -->
            <div class="center-video">
              <div class="center-video-title">Quick Pitch and Demo (slightly outdated)</div>
              <div class="center-video-wrapper">
                <iframe
                  src="https://www.youtube.com/embed/O2XzWBNgfM4"
                  title="Pause Quick Pitch and Demo"
                  frameborder="0"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowfullscreen
                ></iframe>
              </div>
            </div>
          </div>

          <!-- Right Column: App Features -->
          <div class="right-column">
            <div class="title">Why Pause?</div>
            <div class="why-item">
              <div class="why-title">Can Lock</div>
              <div class="why-quotes">
                <div class="quote">"can you make it so that I can't just skip it"</div>
                <div class="quote">"but only sometimes :)"</div>
              </div>
            </div>
            <div class="why-item">
              <div class="why-title">Smart Activations</div>
              <div class="why-quotes">
                <div class="quote">"activate every 15m"</div>
                <div class="quote">"activate everytime I launch minecraft"</div>
                <div class="quote">"activate when I'm scrolling"</div>
                <div class="quote">"activate before my 6pm meeting"</div>
              </div>
            </div>
            <div class="why-item">
              <div class="why-title">Smart Anti-activations</div>
              <div class="why-quotes">
                <div class="quote">"dont activate during my 6pm meeting"</div>
                <div class="quote">"dont activate while im typing"</div>
              </div>
            </div>
            <div class="why-item">
              <div class="why-title">Customizability</div>
              <div class="why-quotes">
                <div class="quote">"make it tell me to stretch"</div>
                <div class="quote">"play the nice forest sounds"</div>
                <div class="quote">"can i activate it with just cmd + p?"</div>
                <div class="quote">"dont activate during my meeting"</div>
              </div>
            </div>
          </div>
        </div>
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

/* Center Badges */
.center-badges {
  display: flex;
  gap: 0.75rem;
  justify-content: center;
  flex-wrap: wrap;
  margin-top: 1.25rem;
  margin-bottom: 0.25rem;
}

.badge {
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 500;
  text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.2);
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
  animation: fadeInHint 1s ease-out, bounceVertical 2s ease-in-out infinite;
}

@keyframes fadeInHint {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

@keyframes bounceVertical {
  0%, 100% {
    transform: translateX(-50%) translateY(0);
  }
  50% {
    transform: translateX(-50%) translateY(10px);
  }
}

/* Main content */
.content {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, rgb(151, 187, 101), rgb(198, 225, 116), rgb(215, 225, 199), rgb(198, 225, 116), rgb(151, 187, 101));
  background-size: 400% 400%;
  animation: gradientShift 15s ease infinite, fadeIn 1s ease-out;
  color: white;
  padding: 4rem 2rem;
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
  max-width: 1300px;
  width: 100%;
  display: flex;
  flex-direction: column;
  gap: 3rem;
}

/* Center Column Videos */
.center-video {
  width: 100%;
  margin-bottom: 1.5rem;
}

.center-video:last-of-type {
  margin-top: 2rem;
  margin-bottom: 0;
}

.center-video-title {
  font-size: 0.9rem;
  font-weight: 500;
  margin-bottom: 0.75rem;
  text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.3);
  opacity: 0.95;
}

.center-video-wrapper {
  position: relative;
  width: 100%;
  padding-bottom: 56.25%; /* 16:9 aspect ratio */
  height: 0;
  overflow: hidden;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
}

.center-video-wrapper iframe {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  border-radius: 8px;
}

/* Main Three Column Layout */
.main-layout {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 2.5rem;
  align-items: start;
  animation: fadeInUp 0.8s ease-out;
}

/* Left Column - Benefits */
.left-column {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  text-align: left;
}

/* Center Column - Branding */
.center-column {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 0 1rem;
  align-self: center;
}

.logo-container {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 1.25rem;
}

.logo {
  width: 120px;
  height: 120px;
  border-radius: 30px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
  cursor: pointer;
  transition: all 0.3s ease;
}

.logo:hover {
  transform: scale(1.05);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
}

.waitlist-pointer {
  position: absolute;
  right: -110px;
  top: 50%;
  transform: translateY(-50%);
  text-align: left;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.arrow {
  font-size: 2rem;
  animation: bounce 2s ease-in-out infinite;
  opacity: 0.9;
  transform: rotate(-90deg);
}

.pointer-text {
  font-size: 1rem;
  font-weight: 500;
  opacity: 0.95;
  text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.3);
  white-space: nowrap;
}

@keyframes bounce {
  0%, 100% {
    transform: rotate(-90deg) translateX(0);
  }
  50% {
    transform: rotate(-90deg) translateX(-5px);
  }
}

.title {
  font-size: 3.5rem;
  font-weight: 700;
  margin-bottom: 0.75rem;
  letter-spacing: -0.02em;
  text-shadow: 2px 2px 8px rgba(0, 0, 0, 0.3);
}

.tagline {
  font-size: 1.15rem;
  font-weight: 400;
  opacity: 0.95;
  text-shadow: 2px 2px 6px rgba(0, 0, 0, 0.3);
  text-align: center;
  line-height: 1.5;
}

/* Right Column - Features */
.right-column {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  text-align: left;
}

.benefit-card {
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  border-radius: 12px;
  padding: 1.5rem 1.25rem;
  border: 1px solid rgba(255, 255, 255, 0.2);
  transition: all 0.3s ease;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  height: 100%;
}

.benefit-card:hover {
  transform: translateY(-2px);
  background: rgba(255, 255, 255, 0.2);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.benefit-icon {
  font-size: 2.5rem;
}

.benefit-label {
  font-size: 1.1rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  opacity: 0.95;
  margin-bottom: 0.25rem;
}

.benefit-list {
  display: flex;
  flex-direction: column;
  gap: 0.15rem;
}

.benefit-point {
  font-size: 1.05rem;
  opacity: 0.85;
  line-height: 1.5;
  text-align: left;
  padding: 0.4rem 0.5rem;
  position: relative;
  transition: all 0.4s ease;
  border-radius: 6px;
}

.benefit-point.highlighted {
  opacity: 1;
  background: rgba(255, 255, 255, 0.25);
  font-weight: 500;
  transform: translateX(4px);
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 0.6rem 0.75rem;
  margin: 0.25rem 0;
}

/* Why Items (App Features) */
.why-item {
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  border-radius: 10px;
  padding: 1.5rem 1.5rem;
  border: 1px solid rgba(255, 255, 255, 0.2);
  text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.2);
  transition: all 0.3s ease;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.why-item:hover {
  transform: translateY(-2px);
  background: rgba(255, 255, 255, 0.2);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.why-title {
  font-size: 1.3rem;
  font-weight: 700;
  margin-bottom: 0.85rem;
  letter-spacing: -0.01em;
}

.why-quotes {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.quote {
  font-size: 0.95rem;
  line-height: 1.5;
  opacity: 0.9;
  font-style: italic;
  padding-left: 0.5rem;
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

/* Responsive Design */
@media (max-width: 768px) {
  .center-video-title {
    font-size: 0.85rem;
    margin-bottom: 0.6rem;
  }

  .center-video-wrapper {
    border-radius: 6px;
  }

  .waitlist-pointer {
    position: static;
    transform: none;
    margin-top: 0.75rem;
    flex-direction: column;
    gap: 0.25rem;
  }

  .arrow {
    transform: rotate(0deg);
    font-size: 1.5rem;
  }

  @keyframes bounce {
    0%, 100% {
      transform: translateY(0);
    }
    50% {
      transform: translateY(-5px);
    }
  }

  .pointer-text {
    font-size: 0.9rem;
  }

  .logo-container {
    flex-direction: column;
  }

  /* Stack vertically on mobile */
  .main-layout {
    grid-template-columns: 1fr;
    gap: 2rem;
  }

  .center-column {
    order: -1;
    padding: 0;
    align-self: auto;
  }

  .left-column,
  .right-column {
    text-align: center;
  }

  .logo {
    width: 100px;
    height: 100px;
    margin-bottom: 1rem;
  }

  .title {
    font-size: 2.5rem;
    margin-bottom: 0.5rem;
  }

  .tagline {
    font-size: 1.1rem;
  }

  .benefit-card {
    padding: 1.25rem 1rem;
    height: auto;
  }

  .benefit-point {
    font-size: 0.95rem;
    padding: 0.35rem 0.5rem;
  }

  .benefit-point.highlighted {
    padding: 0.5rem 0.65rem;
    margin: 0.2rem 0;
  }

  .why-item {
    padding: 1.25rem 1.25rem;
    height: auto;
  }

  .why-title {
    font-size: 1.15rem;
    margin-bottom: 0.7rem;
  }

  .quote {
    font-size: 0.875rem;
  }

  .center-badges {
    margin-top: 1rem;
    margin-bottom: 0.25rem;
    gap: 0.5rem;
  }

  .badge {
    font-size: 0.8rem;
    padding: 0.45rem 0.85rem;
  }

  .cta-button-center {
    margin-top: 0.85rem;
    padding: 0.9rem 2rem;
    font-size: 1.05rem;
  }

  .container {
    gap: 1.5rem;
  }

  .content {
    padding: 3rem 1rem;
  }
}
</style>
