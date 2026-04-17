<template>
  <div class="auth-layout">
    <!-- Animated background blobs -->
    <div class="bg-blob blob-1" />
    <div class="bg-blob blob-2" />
    <div class="bg-blob blob-3" />

    <div class="auth-container">
      <div class="auth-card">
        <div class="auth-logo">
          <div class="logo-ring">
            <Icon name="lucide:heart-pulse" size="28" />
          </div>
          <h1 class="auth-brand">UMAI Health</h1>
        </div>
        <slot />
      </div>
      <p class="auth-footer">© {{ new Date().getFullYear() }} UMAI Health · Все права защищены</p>
    </div>
  </div>
</template>

<style scoped>
.auth-layout {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #F5F0FF 0%, #FFF0F5 40%, #F0F4FF 100%);
  padding: 24px;
  position: relative;
  overflow: hidden;
}

.bg-blob {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.5;
  animation: blobFloat 12s ease-in-out infinite;
  pointer-events: none;
}

.blob-1 {
  width: 400px; height: 400px;
  background: rgba(139,126,200,0.25);
  top: -100px; left: -80px;
  animation-delay: 0s;
}

.blob-2 {
  width: 300px; height: 300px;
  background: rgba(232,160,191,0.2);
  bottom: -60px; right: -40px;
  animation-delay: -4s;
}

.blob-3 {
  width: 250px; height: 250px;
  background: rgba(168,200,232,0.2);
  top: 40%; left: 60%;
  animation-delay: -8s;
}

@keyframes blobFloat {
  0%, 100% { transform: translate(0, 0) scale(1); }
  33% { transform: translate(30px, -20px) scale(1.05); }
  66% { transform: translate(-20px, 15px) scale(0.95); }
}

.auth-container {
  width: 100%;
  max-width: 440px;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 20px;
  position: relative;
  z-index: 1;
}

.auth-card {
  width: 100%;
  background: rgba(255,255,255,0.72);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(139,126,200,0.12);
  border-radius: 20px;
  padding: 40px 32px;
  box-shadow: 0 8px 32px rgba(139,126,200,0.08), 0 1px 3px rgba(0,0,0,0.04);
}

.auth-logo {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  margin-bottom: 28px;
}

.logo-ring {
  width: 56px; height: 56px;
  border-radius: 50%;
  background: var(--gradient-cta);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 4px 16px rgba(139,126,200,0.25);
}

.auth-brand {
  font-family: var(--font-display);
  font-weight: 700;
  font-size: 1.4rem;
  background: var(--gradient-cta);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.auth-footer {
  font-size: 0.72rem;
  color: var(--color-text-muted);
}

@media (max-width: 480px) {
  .auth-card {
    padding: 32px 20px;
    border-radius: 16px;
  }
  .bg-blob { opacity: 0.3; }
}

@media (prefers-reduced-motion: reduce) {
  .bg-blob { animation: none; }
}
</style>
