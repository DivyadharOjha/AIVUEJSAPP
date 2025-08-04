<template>
  <div class="font-example">
    <h1 class="times-new-roman times-3xl">Times New Roman Font Demo</h1>

    <div class="font-samples">
      <p class="font-times times-base">
        This is regular Times New Roman text (16px)
      </p>

      <p class="times-new-roman-bold times-lg">
        This is bold Times New Roman text (18px)
      </p>

      <p class="times-new-roman-italic times-base">
        This is italic Times New Roman text (16px)
      </p>

      <p class="times-new-roman-bold-italic times-xl">
        This is bold italic Times New Roman text (20px)
      </p>

      <div class="size-examples">
        <p class="font-times times-xs">Extra Small (12px)</p>
        <p class="font-times times-sm">Small (14px)</p>
        <p class="font-times times-base">Base (16px)</p>
        <p class="font-times times-lg">Large (18px)</p>
        <p class="font-times times-xl">Extra Large (20px)</p>
        <p class="font-times times-2xl">2XL (24px)</p>
        <p class="font-times times-3xl">3XL (30px)</p>
        <p class="font-times times-4xl">4XL (36px)</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// This component demonstrates how to use Times New Roman font classes
</script>

<style scoped>
.font-example {
  padding: 2rem;
  max-width: 800px;
  margin: 0 auto;
}

.font-samples {
  margin-top: 2rem;
}

.font-samples p {
  margin: 1rem 0;
  line-height: 1.6;
}

.size-examples {
  margin-top: 2rem;
  border-top: 1px solid #e5e5e5;
  padding-top: 1rem;
}

.size-examples p {
  margin: 0.5rem 0;
}

h1 {
  text-align: center;
  color: #333;
  margin-bottom: 1rem;
}
</style>
