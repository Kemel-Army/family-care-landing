<template>
  <div>
    <!-- 1. Hero — эмоциональный хук -->
    <LandingFamilyHeroSection />

    <!-- 2. Знакомые проблемы (4 боли) -->
    <LandingFamilyEmotionSection />

    <!-- 3. Что даёт приложение (3 экрана) -->
    <LandingFamilyAppShowcaseSection />

    <!-- 4. День с приложением (24h timeline) -->
    <LandingFamilyDayInLifeSection />

    <!-- 5. Вакцинация (щит иммунитета) -->
    <LandingFamilyVaccinationSection />

    <!-- 6. Как подключиться + FAQ -->
    <LandingFamilyOnboardingSection />
    <LandingFamilyFaqSection />

    <!-- 7. CTA для семей -->
    <LandingFamilyCtaSection />
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'landing' })

useSeoMeta({
  title: 'UMAI Health для родителей — всё о малыше в одном приложении',
  ogTitle: 'UMAI Health для родителей — всё о малыше в одном приложении',
  description: 'Маршрут ребёнка, напоминания о витаминах, прививки, анализы — бесплатно от вашей клиники.',
  ogDescription: 'Маршрут ребёнка, напоминания о витаминах, прививки, анализы — бесплатно от вашей клиники.',
})
</script>
