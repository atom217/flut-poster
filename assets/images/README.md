# App Icon Assets

This directory contains app icon files for the Jai Ram Status Maker app.

## Required Icon Files

1. **app_icon.png** (1024×1024 PNG)
   - Main app icon used on all platforms
   - Design: Indigo (#3F51B5) filled circle with white bold "JB" text centered and an open book icon beneath
   - Used for: Android, iOS, Web

2. **app_icon_foreground.png** (1024×1024 PNG)
   - Android adaptive icon foreground layer
   - Same design as app_icon.png with transparent background
   - Content should be in center 66% of canvas (safe zone for masking)
   - The background color is set in pubspec.yaml (indigo #3F51B5)

## Design Recommendations

- **Style**: Simple, bold, professional
- **Colors**: Indigo (#3F51B5) as primary color, White as text/accent
- **Elements**:
  - "JB" initials (representing Jai Ram)
  - Open book icon (representing education and Dr. B.R. Ambedkar's constitution)
  - Circle shape for app_icon_foreground (for adaptive icon masking)

## How to Generate Icons

After creating the icon files, run:

```bash
cd /Users/hb-2558/hornblower/flut-poster
flutter pub get
dart run flutter_launcher_icons
```

This will automatically generate:
- Android icons (all densities): `android/app/src/main/res/mipmap-*/`
- iOS icons: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Web icons: `web/icons/` and `web/favicon.png`

## Tools to Create Icons

- **Figma**: Free online design tool (figma.com)
- **Illustrator**: Adobe tool
- **Photoshop**: Adobe tool
- **GIMP**: Free alternative
- **Inkscape**: Free vector graphics editor
- **Online Icon Generators**: Tools that convert text/shapes to icons

## Placeholder Note

If placeholder PNG files are present, the build may generate icons, but they won't reflect your actual design until you replace them with proper icon files.
