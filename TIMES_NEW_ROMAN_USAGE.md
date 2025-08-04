# Times New Roman Font Usage Guide

This guide explains how to use Times New Roman font in your Vue.js project.

## ✅ What's Already Set Up

1. **Font CSS File**: `src/assets/fonts.css` - Contains all Times New Roman font classes
2. **Font Import**: Added to `src/assets/main.css` - Automatically loaded in your app
3. **TTF Files**: All Times New Roman TTF files downloaded to `src/assets/fonts/`
4. **Demo Component**: `src/components/posComponent/FontExample.vue` - Shows usage examples
5. **Test Component**: `src/components/posComponent/TimesNewRomanTest.vue` - Tests all TTF fonts

## 🎯 How to Use Times New Roman

### 1. Basic Usage with CSS Classes

```html
<!-- Regular Times New Roman -->
<p class="font-times">This text uses Times New Roman</p>

<!-- Bold Times New Roman -->
<p class="times-new-roman-bold">This is bold text</p>

<!-- Italic Times New Roman -->
<p class="times-new-roman-italic">This is italic text</p>

<!-- Bold Italic Times New Roman -->
<p class="times-new-roman-bold-italic">This is bold italic text</p>
```

### 2. Using Size Utilities

```html
<h1 class="font-times times-4xl">Large Heading (36px)</h1>
<h2 class="font-times times-2xl">Medium Heading (24px)</h2>
<p class="font-times times-base">Regular text (16px)</p>
<small class="font-times times-sm">Small text (14px)</small>
```

### 3. Direct CSS Styling

```html
<template>
  <div class="my-component">
    <h1>This heading uses Times New Roman</h1>
    <p>This paragraph also uses Times New Roman</p>
  </div>
</template>

<style scoped>
  .my-component {
    font-family: 'Times New Roman', Times, 'Liberation Serif', serif;
  }

  .my-component h1 {
    font-weight: 700;
    font-size: 2rem;
  }
</style>
```

## 📝 Available CSS Classes

| Class Name                     | Description                      |
| ------------------------------ | -------------------------------- |
| `.font-times`                  | Regular Times New Roman          |
| `.times-new-roman`             | Regular Times New Roman (alias)  |
| `.times-new-roman-bold`        | Bold Times New Roman             |
| `.times-new-roman-italic`      | Italic Times New Roman           |
| `.times-new-roman-bold-italic` | Bold Italic Times New Roman      |
| `.font-times-bold`             | Bold Times New Roman (utility)   |
| `.font-times-italic`           | Italic Times New Roman (utility) |

## 📏 Size Utilities

| Class         | Font Size |
| ------------- | --------- |
| `.times-xs`   | 12px      |
| `.times-sm`   | 14px      |
| `.times-base` | 16px      |
| `.times-lg`   | 18px      |
| `.times-xl`   | 20px      |
| `.times-2xl`  | 24px      |
| `.times-3xl`  | 30px      |
| `.times-4xl`  | 36px      |

## 📁 Adding Custom TTF Files (Optional)

If you want to use custom Times New Roman TTF files instead of system fonts:

### Step 1: Add TTF Files

Place your TTF files in `src/assets/fonts/`:

```
src/assets/fonts/
├── times-new-roman.ttf
├── times-new-roman-bold.ttf
├── times-new-roman-italic.ttf
└── times-new-roman-bold-italic.ttf
```

### Step 2: Uncomment @font-face Rules

In `src/assets/fonts.css`, uncomment the @font-face section:

```css
@font-face {
  font-family: 'Times New Roman Custom';
  src: url('./fonts/times-new-roman.ttf') format('truetype');
  font-weight: 400;
  font-style: normal;
  font-display: swap;
}
/* ... other @font-face rules ... */
```

### Step 3: Use Custom Font Class

```html
<p class="times-custom">This uses your custom TTF files</p>
```

## 🔍 Where to Download TTF Files

If you need Times New Roman TTF files:

1. **System Fonts**: Most systems already have Times New Roman
2. **Free Font Sites**:

   - [Font Squirrel](https://www.fontsquirrel.com/)
   - [Google Fonts](https://fonts.google.com/) (similar fonts like Libre Baskerville)
   - [DaFont](https://www.dafont.com/) (check licensing)

3. **Official Sources**:
   - Microsoft Office installation
   - Adobe Creative Suite

## 🧪 Testing Your Font Setup

Use the demo component to test your font setup:

```vue
<template>
  <FontExample />
</template>

<script setup>
import FontExample from '@/components/posComponent/FontExample.vue'
</script>
```

## 💡 Best Practices

1. **Fallback Fonts**: Always include fallback fonts

   ```css
   font-family: 'Times New Roman', Times, 'Liberation Serif', serif;
   ```

2. **Performance**: System fonts load faster than custom TTF files

3. **Licensing**: Ensure you have proper licensing for custom TTF files

4. **Web Standards**: Consider using web-safe alternatives like:
   - Times (system font)
   - Liberation Serif (open source)
   - Georgia (web-safe serif)

## 🚀 Quick Start Example

```vue
<template>
  <div class="app">
    <header class="font-times times-4xl">My Application</header>

    <main class="font-times times-base">
      <p>This content uses Times New Roman font.</p>
      <p class="times-new-roman-bold">This is bold text.</p>
      <p class="times-new-roman-italic">This is italic text.</p>
    </main>
  </div>
</template>

<style scoped>
.app {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
}

header {
  text-align: center;
  margin-bottom: 2rem;
  color: #333;
}
</style>
```

That's it! Your Times New Roman font is now ready to use throughout your Vue.js application. 🎉
