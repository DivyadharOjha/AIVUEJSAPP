<template>
  <div class="times-test">
    <h1 class="times-custom times-4xl">🎉 Times New Roman TTF Fonts Test</h1>
    <p class="success-message">
      ✅ All Times New Roman TTF files successfully downloaded and activated!
    </p>

    <!-- System Font Examples -->
    <section class="font-section">
      <h2 class="section-title">System Times New Roman Fonts</h2>
      <div class="font-examples">
        <p class="font-times times-lg">Regular: The quick brown fox jumps over the lazy dog</p>
        <p class="times-new-roman-bold times-lg">
          Bold: The quick brown fox jumps over the lazy dog
        </p>
        <p class="times-new-roman-italic times-lg">
          Italic: The quick brown fox jumps over the lazy dog
        </p>
        <p class="times-new-roman-bold-italic times-lg">
          Bold Italic: The quick brown fox jumps over the lazy dog
        </p>
      </div>
    </section>

    <!-- Custom TTF Font Examples -->
    <section class="font-section">
      <h2 class="section-title">Custom TTF Times New Roman Fonts</h2>
      <div class="font-examples">
        <p class="times-custom times-lg" style="font-weight: 400; font-style: normal">
          Regular TTF: The quick brown fox jumps over the lazy dog
        </p>
        <p class="times-custom times-lg" style="font-weight: 700; font-style: normal">
          Bold TTF: The quick brown fox jumps over the lazy dog
        </p>
        <p class="times-custom times-lg" style="font-weight: 400; font-style: italic">
          Italic TTF: The quick brown fox jumps over the lazy dog
        </p>
        <p class="times-custom times-lg" style="font-weight: 700; font-style: italic">
          Bold Italic TTF: The quick brown fox jumps over the lazy dog
        </p>
      </div>
    </section>

    <!-- Size Examples -->
    <section class="font-section">
      <h2 class="section-title">Size Examples (Using Custom TTF)</h2>
      <div class="size-examples">
        <p class="times-custom times-xs">Extra Small (12px) - Using custom TTF font</p>
        <p class="times-custom times-sm">Small (14px) - Using custom TTF font</p>
        <p class="times-custom times-base">Base (16px) - Using custom TTF font</p>
        <p class="times-custom times-lg">Large (18px) - Using custom TTF font</p>
        <p class="times-custom times-xl">Extra Large (20px) - Using custom TTF font</p>
        <p class="times-custom times-2xl">2XL (24px) - Using custom TTF font</p>
        <p class="times-custom times-3xl">3XL (30px) - Using custom TTF font</p>
        <p class="times-custom times-4xl">4XL (36px) - Using custom TTF font</p>
      </div>
    </section>

    <!-- File Information -->
    <section class="font-section">
      <h2 class="section-title">Downloaded TTF Files</h2>
      <div class="file-info">
        <ul>
          <li>✅ <strong>times-new-roman.ttf</strong> - Regular (1.2MB)</li>
          <li>✅ <strong>times-new-roman-bold.ttf</strong> - Bold (1.1MB)</li>
          <li>✅ <strong>times-new-roman-italic.ttf</strong> - Italic (942KB)</li>
          <li>✅ <strong>times-new-roman-bold-italic.ttf</strong> - Bold Italic (883KB)</li>
        </ul>
        <p class="location">📁 Location: <code>src/assets/fonts/</code></p>
      </div>
    </section>

    <!-- Usage Instructions -->
    <section class="font-section">
      <h2 class="section-title">How to Use These Fonts</h2>
      <div class="usage-examples">
        <h3>System Fonts (Fallback):</h3>
        <pre><code>&lt;p class="font-times"&gt;Regular text&lt;/p&gt;
&lt;p class="times-new-roman-bold"&gt;Bold text&lt;/p&gt;</code></pre>

        <h3>Custom TTF Fonts:</h3>
        <pre><code>&lt;p class="times-custom"&gt;Using downloaded TTF&lt;/p&gt;
&lt;p class="times-custom times-2xl"&gt;Large TTF text&lt;/p&gt;</code></pre>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
// This component demonstrates all the Times New Roman fonts that have been downloaded
</script>

<style scoped>
.times-test {
  max-width: 1000px;
  margin: 0 auto;
  padding: 2rem;
  background: #f9f9f9;
  border-radius: 8px;
}

.success-message {
  background: #d4edda;
  color: #155724;
  padding: 1rem;
  border-radius: 5px;
  margin-bottom: 2rem;
  text-align: center;
  font-weight: bold;
}

.font-section {
  background: white;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.section-title {
  color: #333;
  border-bottom: 2px solid #007bff;
  padding-bottom: 0.5rem;
  margin-bottom: 1rem;
}

.font-examples p {
  margin: 1rem 0;
  padding: 0.5rem;
  border-left: 4px solid #007bff;
  background: #f8f9fa;
}

.size-examples p {
  margin: 0.5rem 0;
  padding: 0.25rem 0;
}

.file-info {
  background: #e9ecef;
  padding: 1rem;
  border-radius: 5px;
}

.file-info ul {
  list-style: none;
  padding: 0;
}

.file-info li {
  margin: 0.5rem 0;
  padding: 0.25rem 0;
}

.location {
  margin-top: 1rem;
  font-style: italic;
}

.usage-examples {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 5px;
}

.usage-examples h3 {
  color: #495057;
  margin-top: 1rem;
  margin-bottom: 0.5rem;
}

.usage-examples pre {
  background: #e9ecef;
  padding: 1rem;
  border-radius: 4px;
  overflow-x: auto;
  margin: 0.5rem 0;
}

.usage-examples code {
  font-family: 'Courier New', monospace;
  font-size: 0.9rem;
}

h1 {
  text-align: center;
  color: #333;
  margin-bottom: 1rem;
}
</style>
