# Fonts Directory

This directory is for storing custom TTF font files.

## How to Add Times New Roman TTF Files

If you want to use custom Times New Roman TTF files instead of system fonts:

### 1. Download TTF Files

Place your Times New Roman TTF files here with these exact names:

- `times-new-roman.ttf` (Regular)
- `times-new-roman-bold.ttf` (Bold)
- `times-new-roman-italic.ttf` (Italic)
- `times-new-roman-bold-italic.ttf` (Bold Italic)

### 2. Enable Custom Fonts

After adding the TTF files, go to `src/assets/fonts.css` and uncomment the @font-face rules.

### 3. Where to Get TTF Files

- **System Fonts**: Copy from your Windows/Fonts directory
- **Microsoft Office**: Included with Office installation
- **Free Alternatives**: Font Squirrel, Google Fonts (similar fonts)

### 4. Licensing Note

Ensure you have proper licensing rights for any TTF files you add here.

## Current Setup

The project is currently configured to use system Times New Roman fonts, which should work on most devices without needing custom TTF files.
