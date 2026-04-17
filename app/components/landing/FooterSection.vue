<template>
  <footer class="footer">
    <div class="landing-container">
      <div class="footer-grid">
        <!-- Brand -->
        <div class="footer-brand">
          <div class="footer-logo">
            <span class="logo-icon">
              <Icon name="lucide:heart-pulse" size="20" />
            </span>
            <span class="logo-text font-display">UMAI Health</span>
          </div>
          <p class="footer-desc">
            Под покровительством Умай — цифровой маршрут заботы от зачатия до 2 лет. Платформа для частных клиник под вашим брендом.
          </p>
        </div>

        <!-- Navigation -->
        <div class="footer-col">
          <h4 class="footer-heading font-heading">Платформа</h4>
          <ul class="footer-list">
            <li><NuxtLink to="/#what-is">О платформе</NuxtLink></li>
            <li><NuxtLink to="/#modules">Модули</NuxtLink></li>
            <li><NuxtLink to="/#how-it-works">Как это работает</NuxtLink></li>
          </ul>
        </div>

        <div class="footer-col">
          <h4 class="footer-heading font-heading">Страницы</h4>
          <ul class="footer-list">
            <li><NuxtLink to="/for-clinics">Для клиник</NuxtLink></li>
            <li><NuxtLink to="/for-families">Для родителей</NuxtLink></li>
            <li><NuxtLink to="/demo">Попробовать демо</NuxtLink></li>
          </ul>
        </div>

        <!-- Contact -->
        <div class="footer-col">
          <h4 class="footer-heading font-heading">Контакты</h4>
          <ul class="footer-list footer-contacts">
            <li>
              <Icon name="lucide:mail" size="16" />
              <a href="mailto:info@umai-health.kz">info@umai-health.kz</a>
            </li>
            <li>
              <Icon name="lucide:map-pin" size="16" />
              <span>Алматы, Казахстан</span>
            </li>
          </ul>
        </div>
      </div>

      <div class="footer-bottom">
        <p class="footer-copy">
          © {{ currentYear }} UMAI Health. Сделано с заботой в Казахстане.
        </p>
        <div class="footer-legal">
          <NuxtLink to="/privacy">Политика конфиденциальности</NuxtLink>
          <span class="footer-dot">·</span>
          <NuxtLink to="/terms">Условия использования</NuxtLink>
        </div>
      </div>
    </div>
  </footer>
</template>

<script setup lang="ts">
const currentYear = new Date().getFullYear()
</script>

<style scoped>
.footer {
  background: var(--color-bg-alt);
  border-top: 1px solid var(--color-border-light);
  padding: 64px 0 32px;
}

.footer-grid {
  display: grid;
  grid-template-columns: 1.5fr 1fr 1fr 1.2fr;
  gap: 48px;
}

/* Brand */
.footer-brand {
  max-width: 280px;
}

.footer-logo {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 16px;
}

.logo-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  border-radius: var(--radius-sm);
  background: var(--gradient-cta);
  color: white;
}

.logo-text {
  font-size: 18px;
  font-weight: 700;
  color: var(--color-text-primary);
  letter-spacing: -0.01em;
}

.footer-desc {
  font-size: 14px;
  line-height: 1.6;
  color: var(--color-text-secondary);
}

/* Columns */
.footer-heading {
  font-size: 14px;
  font-weight: 700;
  color: var(--color-text-primary);
  margin: 0 0 16px;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.footer-list {
  list-style: none;
  padding: 0;
  margin: 0;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.footer-list a,
.footer-list span {
  font-size: 14px;
  color: var(--color-text-secondary);
  text-decoration: none;
  transition: color var(--transition-fast);
}

.footer-list a:hover {
  color: var(--color-primary);
}

.footer-contacts li {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--color-text-muted);
}

/* Bottom */
.footer-bottom {
  margin-top: 48px;
  padding-top: 24px;
  border-top: 1px solid var(--color-border-light);
}

.footer-copy {
  font-size: 13px;
  color: var(--color-text-muted);
  text-align: center;
  margin: 0;
}

/* Responsive */
@media (max-width: 768px) {
  .footer-grid {
    grid-template-columns: 1fr 1fr;
    gap: 32px;
  }

  .footer-brand {
    grid-column: 1 / -1;
    max-width: 100%;
  }
}

@media (max-width: 480px) {
  .footer-grid {
    grid-template-columns: 1fr;
    gap: 28px;
  }
}
</style>
