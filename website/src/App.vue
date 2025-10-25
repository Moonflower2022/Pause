<script setup lang="ts">
import { ref } from 'vue'

interface Feature {
  icon: string
  title: string
  description: string
}

const features: Feature[] = [
  {
    icon: '🎯',
    title: 'Instant Access',
    description: 'Press ⌘⇧P from anywhere on macOS to start a breathing session instantly.'
  },
  {
    icon: '⏰',
    title: 'Smart Automation',
    description: 'Three independent activation modes: repeated intervals, random timing, and scheduled sessions.'
  },
  {
    icon: '🎵',
    title: 'Calming Audio',
    description: 'Seven ambient sounds with independent volume controls and gentle start/end cues.'
  },
  {
    icon: '📊',
    title: 'Session Tracking',
    description: 'Monitor your meditation practice with completed session counts and total time invested.'
  },
  {
    icon: '🎨',
    title: 'Customizable',
    description: 'Personalize duration, display text, audio, hotkeys, and more to fit your workflow.'
  },
  {
    icon: '💻',
    title: 'Native macOS',
    description: 'Built with SwiftUI for seamless integration with macOS 13+.'
  }
]

const testimonials = [
  {
    quote: "Pause has transformed how I work. The automatic sessions remind me to breathe when I'm deep in code.",
    author: "Sarah Chen",
    role: "Software Engineer"
  },
  {
    quote: "Simple, elegant, and exactly what I needed. The scheduled sessions help me maintain a healthy work rhythm.",
    author: "Marcus Rodriguez",
    role: "Product Designer"
  },
  {
    quote: "I love the random activation mode—it catches me when I need it most without feeling intrusive.",
    author: "Emily Thompson",
    role: "Technical Writer"
  }
]

const activationModes = [
  {
    title: 'Repeated',
    description: 'Fixed intervals from 30 seconds to 10 hours',
    example: 'Perfect for hourly breaks'
  },
  {
    title: 'Random',
    description: 'Unpredictable intervals within your range',
    example: 'Keeps your practice fresh'
  },
  {
    title: 'Scheduled',
    description: 'Specific daily times with custom labels',
    example: 'Morning and afternoon resets'
  }
]

const currentYear = new Date().getFullYear()
</script>

<template>
  <div class="app">
    <!-- Hero Section -->
    <header class="hero">
      <div class="container">
        <div class="hero-content">
          <h1 class="hero-title">Pause</h1>
          <p class="hero-subtitle">Breathe. Reset. Stay Mindful.</p>
          <p class="hero-description">
            A beautiful macOS meditation app that helps you take regular breathing breaks throughout your day.
          </p>
          <div class="hero-buttons">
            <a href="#download" class="btn btn-primary">Download for macOS</a>
            <a href="#features" class="btn btn-secondary">Learn More</a>
          </div>
          <p class="hero-requirement">Requires macOS 13.0 (Ventura) or later</p>
        </div>
        <div class="hero-visual">
          <div class="breathing-circle"></div>
        </div>
      </div>
    </header>

    <!-- Features Section -->
    <section id="features" class="features">
      <div class="container">
        <h2 class="section-title">Features</h2>
        <p class="section-subtitle">Everything you need for mindful work</p>
        <div class="features-grid">
          <div v-for="feature in features" :key="feature.title" class="feature-card">
            <div class="feature-icon">{{ feature.icon }}</div>
            <h3 class="feature-title">{{ feature.title }}</h3>
            <p class="feature-description">{{ feature.description }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Activation Modes Section -->
    <section class="activation-modes">
      <div class="container">
        <h2 class="section-title">Flexible Automation</h2>
        <p class="section-subtitle">All three modes can run simultaneously</p>
        <div class="modes-grid">
          <div v-for="mode in activationModes" :key="mode.title" class="mode-card">
            <h3 class="mode-title">{{ mode.title }}</h3>
            <p class="mode-description">{{ mode.description }}</p>
            <p class="mode-example">{{ mode.example }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- How It Works Section -->
    <section class="how-it-works">
      <div class="container">
        <h2 class="section-title">How It Works</h2>
        <div class="steps">
          <div class="step">
            <div class="step-number">1</div>
            <h3 class="step-title">Install & Configure</h3>
            <p class="step-description">Download Pause, set your preferences, and customize your experience.</p>
          </div>
          <div class="step">
            <div class="step-number">2</div>
            <h3 class="step-title">Press ⌘⇧P</h3>
            <p class="step-description">Trigger a session from anywhere with your global hotkey.</p>
          </div>
          <div class="step">
            <div class="step-number">3</div>
            <h3 class="step-title">Breathe & Reset</h3>
            <p class="step-description">Enjoy a fullscreen breathing session with calming audio.</p>
          </div>
          <div class="step">
            <div class="step-number">4</div>
            <h3 class="step-title">Track Progress</h3>
            <p class="step-description">Watch your meditation practice grow with session statistics.</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Testimonials Section -->
    <section class="testimonials">
      <div class="container">
        <h2 class="section-title">Loved by Mindful Creators</h2>
        <div class="testimonials-grid">
          <div v-for="(testimonial, index) in testimonials" :key="index" class="testimonial-card">
            <p class="testimonial-quote">"{{ testimonial.quote }}"</p>
            <div class="testimonial-author">
              <p class="author-name">{{ testimonial.author }}</p>
              <p class="author-role">{{ testimonial.role }}</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Download Section -->
    <section id="download" class="download">
      <div class="container">
        <div class="download-content">
          <h2 class="download-title">Ready to Start?</h2>
          <p class="download-description">
            Download Pause for macOS and begin your mindfulness journey today.
          </p>
          <a href="https://github.com/yourusername/Pause/releases" class="btn btn-download">
            Download Pause
          </a>
          <p class="download-note">Free and open source • macOS 13.0+ required</p>
          <div class="download-instructions">
            <h3>Installation</h3>
            <ol>
              <li>Download the latest release</li>
              <li>Drag Pause.app to your Applications folder</li>
              <li>Launch Pause and grant accessibility permissions</li>
              <li>Configure your preferences and start breathing</li>
            </ol>
          </div>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
      <div class="container">
        <div class="footer-content">
          <div class="footer-section">
            <h3 class="footer-title">Pause</h3>
            <p class="footer-description">A meditation app for mindful macOS users.</p>
          </div>
          <div class="footer-section">
            <h4 class="footer-heading">Resources</h4>
            <ul class="footer-links">
              <li><a href="https://github.com/yourusername/Pause">GitHub</a></li>
              <li><a href="https://github.com/yourusername/Pause/releases">Releases</a></li>
              <li><a href="https://github.com/yourusername/Pause/issues">Report Issue</a></li>
              <li><a href="https://github.com/yourusername/Pause/discussions">Discussions</a></li>
            </ul>
          </div>
          <div class="footer-section">
            <h4 class="footer-heading">Community</h4>
            <ul class="footer-links">
              <li><a href="#features">Features</a></li>
              <li><a href="#download">Download</a></li>
              <li><a href="https://github.com/yourusername/Pause#contributing">Contributing</a></li>
            </ul>
          </div>
        </div>
        <div class="footer-bottom">
          <p>&copy; {{ currentYear }} Pause. Built with ❤️ for macOS.</p>
        </div>
      </div>
    </footer>
  </div>
</template>

<style scoped>
/* Global Styles */
* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
}

body {
  margin: 0;
  padding: 0;
}

.app {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
  color: #1a1a1a;
  line-height: 1.6;
  margin: 0;
  padding: 0;
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 2rem;
}

/* Hero Section */
.hero {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 8rem 0;
  text-align: center;
  position: relative;
  overflow: hidden;
}

.hero-content {
  position: relative;
  z-index: 2;
}

.hero-title {
  font-size: 5rem;
  font-weight: 700;
  margin-bottom: 1rem;
  letter-spacing: -0.02em;
}

.hero-subtitle {
  font-size: 2rem;
  font-weight: 300;
  margin-bottom: 1.5rem;
  opacity: 0.95;
}

.hero-description {
  font-size: 1.25rem;
  max-width: 600px;
  margin: 0 auto 2.5rem;
  opacity: 0.9;
  line-height: 1.7;
}

.hero-buttons {
  display: flex;
  gap: 1rem;
  justify-content: center;
  margin-bottom: 1.5rem;
}

.btn {
  padding: 1rem 2.5rem;
  border-radius: 8px;
  text-decoration: none;
  font-weight: 600;
  font-size: 1.1rem;
  transition: all 0.3s ease;
  display: inline-block;
}

.btn-primary {
  background: white;
  color: #667eea;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.2);
  color: white;
  border: 2px solid white;
}

.btn-secondary:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-2px);
}

.hero-requirement {
  font-size: 0.9rem;
  opacity: 0.8;
}

.hero-visual {
  margin-top: 4rem;
  display: flex;
  justify-content: center;
}

.breathing-circle {
  width: 200px;
  height: 200px;
  background: rgba(255, 255, 255, 0.3);
  border-radius: 50%;
  animation: breathe 4s ease-in-out infinite;
}

@keyframes breathe {
  0%, 100% {
    transform: scale(1);
    opacity: 0.7;
  }
  50% {
    transform: scale(1.2);
    opacity: 1;
  }
}

/* Features Section */
.features {
  padding: 6rem 0;
  background: #f8f9fa;
}

.section-title {
  font-size: 3rem;
  text-align: center;
  margin-bottom: 1rem;
  font-weight: 700;
}

.section-subtitle {
  font-size: 1.25rem;
  text-align: center;
  color: #666;
  margin-bottom: 4rem;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
}

.feature-card {
  background: white;
  padding: 2.5rem;
  border-radius: 12px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
  transition: transform 0.3s ease, box-shadow 0.3s ease;
}

.feature-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
}

.feature-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.feature-title {
  font-size: 1.5rem;
  font-weight: 600;
  margin-bottom: 0.75rem;
}

.feature-description {
  color: #666;
  line-height: 1.7;
}

/* Activation Modes */
.activation-modes {
  padding: 6rem 0;
  background: white;
}

.modes-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 2rem;
}

.mode-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 2.5rem;
  border-radius: 12px;
  text-align: center;
  transition: transform 0.3s ease;
}

.mode-card:hover {
  transform: scale(1.05);
}

.mode-title {
  font-size: 1.75rem;
  font-weight: 600;
  margin-bottom: 1rem;
}

.mode-description {
  font-size: 1.1rem;
  margin-bottom: 1rem;
  opacity: 0.95;
}

.mode-example {
  font-size: 0.95rem;
  opacity: 0.8;
  font-style: italic;
}

/* How It Works */
.how-it-works {
  padding: 6rem 0;
  background: #f8f9fa;
}

.steps {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 3rem;
  margin-top: 3rem;
}

.step {
  text-align: center;
}

.step-number {
  width: 60px;
  height: 60px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.75rem;
  font-weight: 700;
  margin: 0 auto 1.5rem;
}

.step-title {
  font-size: 1.5rem;
  font-weight: 600;
  margin-bottom: 0.75rem;
}

.step-description {
  color: #666;
  line-height: 1.7;
}

/* Testimonials */
.testimonials {
  padding: 6rem 0;
  background: white;
}

.testimonials-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  margin-top: 3rem;
}

.testimonial-card {
  background: #f8f9fa;
  padding: 2.5rem;
  border-radius: 12px;
  border-left: 4px solid #667eea;
}

.testimonial-quote {
  font-size: 1.1rem;
  line-height: 1.7;
  margin-bottom: 1.5rem;
  color: #333;
  font-style: italic;
}

.testimonial-author {
  border-top: 1px solid #ddd;
  padding-top: 1rem;
}

.author-name {
  font-weight: 600;
  color: #1a1a1a;
}

.author-role {
  color: #666;
  font-size: 0.9rem;
}

/* Download Section */
.download {
  padding: 6rem 0;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  text-align: center;
}

.download-title {
  font-size: 3rem;
  font-weight: 700;
  margin-bottom: 1.5rem;
}

.download-description {
  font-size: 1.25rem;
  max-width: 600px;
  margin: 0 auto 2.5rem;
  opacity: 0.95;
}

.btn-download {
  background: white;
  color: #667eea;
  padding: 1.25rem 3rem;
  font-size: 1.25rem;
  border-radius: 8px;
  text-decoration: none;
  font-weight: 700;
  display: inline-block;
  transition: all 0.3s ease;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
}

.btn-download:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
}

.download-note {
  margin-top: 1.5rem;
  font-size: 0.95rem;
  opacity: 0.85;
}

.download-instructions {
  max-width: 600px;
  margin: 3rem auto 0;
  background: rgba(255, 255, 255, 0.1);
  padding: 2rem;
  border-radius: 12px;
  text-align: left;
}

.download-instructions h3 {
  font-size: 1.5rem;
  margin-bottom: 1rem;
  text-align: center;
}

.download-instructions ol {
  margin-left: 1.5rem;
  line-height: 2;
}

.download-instructions li {
  font-size: 1.05rem;
}

/* Footer */
.footer {
  background: #1a1a1a;
  color: white;
  padding: 4rem 0 2rem;
}

.footer-content {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 3rem;
  margin-bottom: 3rem;
}

.footer-title {
  font-size: 1.75rem;
  font-weight: 700;
  margin-bottom: 0.75rem;
}

.footer-description {
  color: #999;
  line-height: 1.7;
}

.footer-heading {
  font-size: 1.1rem;
  font-weight: 600;
  margin-bottom: 1rem;
}

.footer-links {
  list-style: none;
}

.footer-links li {
  margin-bottom: 0.5rem;
}

.footer-links a {
  color: #999;
  text-decoration: none;
  transition: color 0.3s ease;
}

.footer-links a:hover {
  color: white;
}

.footer-bottom {
  border-top: 1px solid #333;
  padding-top: 2rem;
  text-align: center;
  color: #999;
}

/* Responsive */
@media (max-width: 768px) {
  .hero-title {
    font-size: 3rem;
  }

  .hero-subtitle {
    font-size: 1.5rem;
  }

  .hero-buttons {
    flex-direction: column;
    align-items: center;
  }

  .section-title {
    font-size: 2rem;
  }

  .features-grid,
  .modes-grid,
  .steps,
  .testimonials-grid {
    grid-template-columns: 1fr;
  }
}
</style>
