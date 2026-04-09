<template>
  <div>
    <!-- Sticky section navigation -->
    <LandingUiSectionNav :sections="sectionNavItems" />

    <!-- 1. Hero — Воронка восстановления -->
    <LandingClinicHeroSection id="clinic-hero" />

    <!-- 2. Проблема + До/После (merged) -->
    <LandingClinicProblemsSection id="clinic-problem" />

    <!-- 3. Три рабочих стола (координатор / руководитель / врач) -->
    <LandingClinicWhatIsSection id="clinic-solution" />

    <!-- 4. ROI калькулятор -->
    <LandingClinicUnitEconomicsSection id="clinic-roi" />

    <!-- 5. Кейсы клиник — Testimonials (анонимизированные) -->
    <LandingClinicTestimonialsSection id="clinic-cases" />

    <!-- 6. Внедрение — 4 шага -->
    <LandingClinicImplementationSection id="clinic-launch" />

    <!-- 7. White-label -->
    <LandingClinicCustomizationSection id="clinic-brand" />

    <!-- 8. FAQ (+ безопасность) -->
    <LandingClinicFaqSection id="clinic-faq" />

    <!-- 9. CTA — форма -->
    <LandingClinicCtaSection id="clinic-cta" />
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'landing' })

const sectionNavItems = [
  { id: 'clinic-hero', label: 'Главная' },
  { id: 'clinic-problem', label: 'Проблема' },
  { id: 'clinic-solution', label: 'Решение' },
  { id: 'clinic-roi', label: 'ROI' },
  { id: 'clinic-cases', label: 'Кейсы' },
  { id: 'clinic-launch', label: 'Запуск' },
  { id: 'clinic-brand', label: 'Бренд' },
  { id: 'clinic-faq', label: 'FAQ' },
  { id: 'clinic-cta', label: 'Контакт' },
]

useSeoMeta({
  title: 'Family Care OS для клиник — удержание семей, рост дохода',
  ogTitle: 'Family Care OS для клиник — удержание семей, рост дохода',
  description: '67% семей уходят после родов. Платформа возвращает их. Окупаемость от 160%. Внедрение за 4 недели.',
  ogDescription: '67% семей уходят после родов. Платформа возвращает их. Окупаемость от 160%. Внедрение за 4 недели.',
})
</script>
