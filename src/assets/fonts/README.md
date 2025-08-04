# Font Files Instructions

## Times New Roman TTF Files Required

To use Times New Roman font in this project, you need to add the following TTF files to this directory:

### Required Files:
1. `times-new-roman.ttf` (Regular)
2. `times-new-roman-bold.ttf` (Bold)
3. `times-new-roman-italic.ttf` (Italic)
4. `times-new-roman-bold-italic.ttf` (Bold Italic)

### Where to Get Times New Roman:
1. **From Your System**: If you have Windows, you can find these files in `C:\Windows\Fonts\`
2. **Google Fonts**: Search for "Times" or similar serif fonts
3. **Font Websites**: Download from legitimate font providers

### File Names to Use:
- Regular: `times-new-roman.ttf`
- Bold: `times-new-roman-bold.ttf`
- Italic: `times-new-roman-italic.ttf`
- Bold Italic: `times-new-roman-bold-italic.ttf`

### Usage in Components:
```css
/* Use Times New Roman globally - already configured */
body {
  font-family: 'Times New Roman', Times, serif;
}

/* Or use utility classes */
.font-times {
  font-family: 'Times New Roman', Times, serif;
}

.font-times-bold {
  font-family: 'Times New Roman', Times, serif;
  font-weight: 700;
}

.font-times-italic {
  font-family: 'Times New Roman', Times, serif;
  font-style: italic;
}
```

### Note:
Once you add the TTF files to this directory, the font will be automatically available throughout your application.