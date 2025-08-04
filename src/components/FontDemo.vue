<template>
  <div class="font-demo">
    <h2>Times New Roman Font Demo</h2>
    
    <div class="font-examples">
      <div class="example-section">
        <h3>Regular Text</h3>
        <p class="font-times">
          This is Times New Roman regular text. It should display with the custom TTF font once you add the font files.
        </p>
      </div>

      <div class="example-section">
        <h3>Bold Text</h3>
        <p class="font-times-bold">
          This is Times New Roman bold text. Perfect for headings and emphasis.
        </p>
      </div>

      <div class="example-section">
        <h3>Italic Text</h3>
        <p class="font-times-italic">
          This is Times New Roman italic text. Great for quotes and special emphasis.
        </p>
      </div>

      <div class="example-section">
        <h3>Mixed Styles</h3>
        <p class="font-times">
          This paragraph uses <strong>bold</strong> and <em>italic</em> styles within Times New Roman font.
        </p>
      </div>
    </div>

    <div class="font-status">
      <p><strong>Font Status:</strong></p>
      <p v-if="!fontsLoaded" class="warning">
        ⚠️ TTF files not found. Please add Times New Roman TTF files to src/assets/fonts/ directory.
      </p>
      <p v-else class="success">
        ✅ Times New Roman font is loaded and active!
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'

const fontsLoaded = ref(false)

onMounted(async () => {
  // Check if the font is loaded
  try {
    await document.fonts.load('16px "Times New Roman"')
    const fontFace = [...document.fonts.values()].find(
      font => font.family === 'Times New Roman'
    )
    fontsLoaded.value = !!fontFace
  } catch (error) {
    console.warn('Font loading check failed:', error)
    fontsLoaded.value = false
  }
})
</script>

<style scoped>
.font-demo {
  padding: 2rem;
  max-width: 800px;
  margin: 0 auto;
}

.font-demo h2 {
  color: #2c3e50;
  margin-bottom: 2rem;
  text-align: center;
}

.example-section {
  margin-bottom: 2rem;
  padding: 1rem;
  border: 1px solid #e1e1e1;
  border-radius: 8px;
  background: #f9f9f9;
}

.example-section h3 {
  color: #34495e;
  margin-bottom: 1rem;
  font-size: 1.2rem;
}

.example-section p {
  font-size: 1.1rem;
  line-height: 1.6;
  margin: 0;
}

.font-status {
  margin-top: 2rem;
  padding: 1rem;
  border-radius: 8px;
  background: #f0f0f0;
}

.warning {
  color: #e74c3c;
  font-weight: bold;
}

.success {
  color: #27ae60;
  font-weight: bold;
}

/* Force Times New Roman for the entire demo */
.font-demo {
  font-family: 'Times New Roman', Times, serif;
}
</style>