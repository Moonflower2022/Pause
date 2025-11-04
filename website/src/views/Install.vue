<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../lib/supabase'

const router = useRouter()
const email = ref('')
const isEmailSubmitted = ref(false)
const emailError = ref('')
const emailInput = ref<HTMLInputElement | null>(null)
const isSubmitting = ref(false)

onMounted(() => {
  // Autofocus the email input when component mounts
  setTimeout(() => {
    emailInput.value?.focus()
  }, 100)
})

const validateEmail = (email: string): boolean => {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return re.test(email)
}

const handleWaitlist = async () => {
  emailError.value = ''

  if (!email.value.trim()) {
    emailError.value = 'Please enter your email address'
    return
  }

  if (!validateEmail(email.value)) {
    emailError.value = 'Please enter a valid email address'
    return
  }

  isSubmitting.value = true

  try {
    const { error } = await supabase
      .from('waitlist')
      .insert([{ email: email.value.trim().toLowerCase() }])

    if (error) {
      if (error.code === '23505') {
        // Duplicate email
        emailError.value = 'This email is already on the waitlist!'
      } else {
        emailError.value = 'Something went wrong. Please try again.'
        console.error('Supabase error:', error)
      }
      isSubmitting.value = false
      return
    }

    isEmailSubmitted.value = true
  } catch (err) {
    emailError.value = 'Something went wrong. Please try again.'
    console.error('Error:', err)
    isSubmitting.value = false
  }
}

const goHome = () => {
  router.push('/')
}
</script>

<template>
  <div class="install">
    <button @click="goHome" class="back-button">← Back</button>

    <div class="container">
      <h1 class="title">Join the Waitlist</h1>

      <div v-if="!isEmailSubmitted" class="download-section">
        <p class="subtitle">Be the first to know when Pause launches</p>

        <div class="email-form">
          <input
            ref="emailInput"
            v-model="email"
            type="email"
            placeholder="your@email.com"
            class="email-input"
            :class="{ error: emailError }"
            @keyup.enter="handleWaitlist"
          />
          <button @click="handleWaitlist" class="download-button" :disabled="isSubmitting">
            {{ isSubmitting ? 'Joining...' : 'Join Waitlist' }}
          </button>
        </div>

        <p v-if="emailError" class="error-message">{{ emailError }}</p>

        <p class="privacy-note">We'll only use your email to notify you when Pause launches.</p>
      </div>

      <div v-else class="success-section">
        <div class="success-icon">✓</div>
        <p class="success-message">You're on the list! We'll email you when Pause launches.</p>
      </div>

      <div class="info-box">
        <h2 class="info-title">What to Expect</h2>
        <ul class="info-list">
          <li>tbh just try it out lol whats the worst that can happen</li>
          <li>Early access to Pause when it launches</li>
          <li>It will launch in like two days (gosh darn apple notary system)</li>
          <li>macOS 13.0 (Ventura) or later required</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<style scoped>
.install {
  min-height: 100vh;
  height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, rgb(151, 187, 101), rgb(198, 225, 116), rgb(215, 225, 199), rgb(198, 225, 116), rgb(151, 187, 101));
  background-size: 400% 400%;
  animation: gradientShift 15s ease infinite;
  color: white;
  overflow: hidden;
  position: relative;
  padding: 2rem;
}

.back-button {
  position: absolute;
  top: 2rem;
  left: 2rem;
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 2px solid white;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.back-button:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateX(-3px);
}

.container {
  text-align: center;
  max-width: 700px;
  width: 100%;
}

.title {
  font-size: 3.5rem;
  font-weight: 700;
  margin-bottom: 2rem;
  letter-spacing: -0.02em;
  text-shadow: 2px 2px 8px rgba(0, 0, 0, 0.3);
}

.subtitle {
  font-size: 1.25rem;
  margin-bottom: 2rem;
  opacity: 0.95;
  text-shadow: 1px 1px 4px rgba(0, 0, 0, 0.3);
}

.download-section {
  margin-bottom: 3rem;
}

.email-form {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-bottom: 0.5rem;
  flex-wrap: wrap;
}

.email-input {
  flex: 1;
  min-width: 250px;
  max-width: 400px;
  padding: 1rem 1.5rem;
  font-size: 1.1rem;
  border: 2px solid white;
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.9);
  color: #333;
  transition: all 0.3s ease;
}

.email-input:focus {
  outline: none;
  background: white;
  box-shadow: 0 0 0 3px rgba(255, 255, 255, 0.3);
}

.email-input.error {
  border-color: #ff6b6b;
  background: #ffebee;
}

.download-button {
  padding: 1rem 2.5rem;
  font-size: 1.1rem;
  font-weight: 600;
  background: white;
  color: rgb(151, 187, 101);
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
  white-space: nowrap;
}

.download-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
}

.download-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.error-message {
  color: #ffebee;
  font-size: 0.95rem;
  margin-top: 0.5rem;
  font-weight: 500;
}

.privacy-note {
  font-size: 0.9rem;
  opacity: 0.8;
  margin-top: 1rem;
}

.success-section {
  margin-bottom: 3rem;
}

.success-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
  animation: scaleIn 0.5s ease-out;
}

.success-message {
  font-size: 1.25rem;
  animation: fadeIn 0.5s ease-out 0.2s backwards;
}

.info-box {
  background: rgba(255, 255, 255, 0.15);
  padding: 2rem;
  border-radius: 12px;
  margin-bottom: 2rem;
  backdrop-filter: blur(10px);
}

.info-title {
  font-size: 1.75rem;
  margin-bottom: 1.5rem;
  font-weight: 600;
  text-shadow: 1px 1px 4px rgba(0, 0, 0, 0.2);
}

.info-list {
  text-align: left;
  max-width: 500px;
  margin: 0 auto;
  line-height: 2;
  font-size: 1.05rem;
  list-style-type: none;
  padding-left: 0;
}

.info-list li {
  margin-bottom: 0.75rem;
  padding-left: 1.5rem;
  position: relative;
}

.info-list li::before {
  content: "•";
  position: absolute;
  left: 0;
  font-weight: bold;
}

@keyframes scaleIn {
  from {
    transform: scale(0);
    opacity: 0;
  }
  to {
    transform: scale(1);
    opacity: 1;
  }
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

@media (max-width: 768px) {
  .title {
    font-size: 2.5rem;
  }

  .email-form {
    flex-direction: column;
    align-items: stretch;
  }

  .email-input {
    max-width: none;
  }

  .back-button {
    top: 1rem;
    left: 1rem;
    padding: 0.5rem 1rem;
    font-size: 0.9rem;
  }

  .info-box {
    padding: 1.5rem;
  }

  .info-list {
    font-size: 1rem;
  }
}
</style>
