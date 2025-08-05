<template>
  <div class="font-test-container">
    <div class="font-section">
      <h4 class="section-title">Times New Roman TTF Font Test</h4>

      <!-- Regular Text -->
      <div class="font-example">
        <h5>Regular Text</h5>
        <p class="font-regular">
          This is Times New Roman Regular text. The quick brown fox jumps over the lazy dog.
        </p>
      </div>

      <!-- Bold Text -->
      <div class="font-example">
        <h5>Bold Text</h5>
        <p class="font-bold">
          This is Times New Roman Bold text. The quick brown fox jumps over the lazy dog.
        </p>
      </div>

      <!-- Italic Text -->
      <div class="font-example">
        <h5>Italic Text</h5>
        <p class="font-italic">
          This is Times New Roman Italic text. The quick brown fox jumps over the lazy dog.
        </p>
      </div>

      <!-- Bold Italic Text -->
      <div class="font-example">
        <h5>Bold Italic Text</h5>
        <p class="font-bold-italic">
          This is Times New Roman Bold Italic text. The quick brown fox jumps over the lazy dog.
        </p>
      </div>

      <!-- Different Sizes -->
      <div class="font-example">
        <h5>Different Sizes</h5>
        <p class="font-size-12">12px - Times New Roman text</p>
        <p class="font-size-14">14px - Times New Roman text</p>
        <p class="font-size-16">16px - Times New Roman text</p>
        <p class="font-size-18">18px - Times New Roman text</p>
        <p class="font-size-20">20px - Times New Roman text</p>
        <p class="font-size-24">24px - Times New Roman text</p>
      </div>

      <!-- Numbers and Special Characters -->
      <div class="font-example">
        <h5>Numbers and Special Characters</h5>
        <p class="font-regular">
          1234567890 - Numbers<br />
          !@#$%^&*() - Special characters<br />
          ABCDEFGHIJKLMNOPQRSTUVWXYZ - Uppercase<br />
          abcdefghijklmnopqrstuvwxyz - Lowercase
        </p>
      </div>

      <!-- Arabic Text (if supported) -->
      <div class="font-example">
        <h5>Arabic Text Test</h5>
        <p class="font-regular arabic-text">مرحبا بالعالم - Hello World in Arabic</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// This component tests Times New Roman TTF font rendering
// No additional logic needed
</script>

<style scoped>
.font-test-container {
  padding: 20px;
  background: #ffffff;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.font-section {
  max-width: 800px;
  margin: 0 auto;
}

.section-title {
  color: #333;
  font-weight: 600;
  margin-bottom: 20px;
  padding-bottom: 10px;
  border-bottom: 2px solid #e9ecef;
  text-align: center;
}

.font-example {
  margin-bottom: 24px;
  padding: 16px;
  background: #f8f9fa;
  border-radius: 6px;
  border: 1px solid #e9ecef;
}

.font-example h5 {
  color: #495057;
  margin-bottom: 12px;
  font-weight: 600;
}

.font-example p {
  margin-bottom: 8px;
  line-height: 1.6;
}

/* Font Classes */
.font-regular {
  font-family: 'Times New Roman Custom', 'Times New Roman', Times, 'Liberation Serif', serif;
  font-weight: normal;
  font-style: normal;
}

.font-bold {
  font-family: 'Times New Roman Custom', 'Times New Roman', Times, 'Liberation Serif', serif;
  font-weight: bold;
  font-style: normal;
}

.font-italic {
  font-family: 'Times New Roman Custom', 'Times New Roman', Times, 'Liberation Serif', serif;
  font-weight: normal;
  font-style: italic;
}

.font-bold-italic {
  font-family: 'Times New Roman Custom', 'Times New Roman', Times, 'Liberation Serif', serif;
  font-weight: bold;
  font-style: italic;
}

/* Font Sizes */
.font-size-12 {
  font-family: 'Times New Roman Custom', 'Times New Roman', Times, 'Liberation Serif', serif;
  font-size: 12px;
}

.font-size-14 {
  font-family: 'Times New Roman Custom', 'Times New Roman', Times, 'Liberation Serif', serif;
  font-size: 14px;
}

.font-size-16 {
  font-family: 'Times New Roman Custom', 'Times New Roman', Times, 'Liberation Serif', serif;
  font-size: 16px;
}

.font-size-18 {
  font-family: 'Times New Roman Custom', 'Times New Roman', Times, 'Liberation Serif', serif;
  font-size: 18px;
}

.font-size-20 {
  font-family: 'Times New Roman Custom', 'Times New Roman', Times, 'Liberation Serif', serif;
  font-size: 20px;
}

.font-size-24 {
  font-family: 'Times New Roman Custom', 'Times New Roman', Times, 'Liberation Serif', serif;
  font-size: 24px;
}

.arabic-text {
  direction: rtl;
  text-align: right;
}

/* Responsive Design */
@media (max-width: 768px) {
  .font-test-container {
    padding: 16px;
  }

  .font-example {
    padding: 12px;
  }

  .font-size-24 {
    font-size: 20px;
  }
}
</style>
