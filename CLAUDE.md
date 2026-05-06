# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Jai Ram Status Maker** is a Flutter application for creating customizable status/quote posters featuring quotes by Dr. B.R. Ambedkar. Users can select templates, customize text and colors, and share their creations.

## Build & Run Commands

```bash
# Install dependencies
flutter pub get

# Run the app (on emulator or connected device)
flutter run

# Run on Chrome (web)
flutter run -d chrome

# Build for Android
flutter build apk      # Release APK
flutter build apk --debug  # Debug APK

# Build for iOS
flutter build ios

# Build for Web
flutter build web

# Clean build artifacts
flutter clean
```

## Code Quality & Testing

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/widget_test.dart

# Analyze code for issues
flutter analyze

# Format code
flutter format .

# Format and analyze in one command
flutter analyze && flutter format .
```

## Architecture

### State Management: Riverpod

The app uses **Riverpod** for state management. Key providers in `lib/services/providers.dart`:

- **Data providers**: `categoriesProvider`, `quotesProvider`, `templatesProvider` — read-only access to dummy data
- **UI state providers**: `selectedCategoryIdProvider`, `selectedTemplateProvider` — tracks user selections
- **Editor state**: `editorProvider` — StateNotifierProvider managing font size and background color for quote editing
- **User profile**: `userProfileProvider` — StateProvider for editable user profile (name, subtitle, photo)
- **Premium access**: `isUserPremiumProvider` — toggles access to premium templates
- **Screenshot controller**: `screenshotControllerProvider` — manages poster image capture

### Directory Structure

```
lib/
├── main.dart              # App entry point with MaterialApp & Riverpod ProviderScope
├── screens/               # Full-screen views
│   ├── home_screen.dart   # Main hub with template/quote selection
│   ├── editor_screen.dart # Quote editor with live preview & customization
│   └── quote_list_screen.dart
├── widgets/               # Reusable UI components
│   ├── poster_preview.dart     # Quote display widget (target for screenshot, web/mobile photo handling)
│   ├── category_tabs.dart      # Category filter tabs
│   ├── bottom_action_row.dart  # Share/download/edit buttons (web/mobile branching)
│   ├── profile_editor.dart     # User profile input (web/mobile photo handling)
│   └── home_app_bar.dart
├── models/                # Data models
│   └── models.dart        # Category, Quote, UserProfile, TemplateModel classes
├── services/              # Business logic & providers
│   └── providers.dart     # All Riverpod state management
├── data/                  # Static/dummy data
│   └── dummy_data.dart    # Sample quotes, categories, templates
├── theme/                 # UI theming
│   └── app_theme.dart     # Shared Material theme
└── utils/                 # Cross-platform utilities
    ├── file_stub.dart     # Web stub: file operations that return null/false
    └── file_io.dart       # Mobile impl: dart:io File operations
```

### Data Models

- **Quote**: text, author, categoryId
- **Category**: id, name, icon
- **TemplateModel**: colors (solid/gradient), text color, isPremium flag, categoryId for filtering
- **UserProfile**: name, subtitle, optional photoUrl (with copyWith support for state updates)

### Key UI Patterns

1. **ConsumerWidget** — screens/widgets that read Riverpod providers via `ref.watch()`
2. **StateProvider** — user selections and profile edits
3. **StateNotifierProvider** — editor settings with mutable state management
4. **Provider.family** — parameterized providers (e.g., filtered quotes/templates by category)

## Dependencies

- **flutter_riverpod**: State management
- **google_fonts**: Custom font support
- **image_picker**: Camera/gallery access for profile photos (platform-specific implementations: gallery works on web, camera is mobile-only)
- **screenshot**: Capture poster previews for sharing (works on all platforms)
- **path_provider**: File system access (mobile/desktop only, guarded by `kIsWeb` in code)
- **share_plus**: Native share functionality (mobile only, degrades to SnackBar on web)
- **universal_html**: Cross-platform HTML/web APIs (enables blob downloads on web)
- **cupertino_icons**: iOS-style icons

## Platform Support

The app supports **Android, iOS, and Web** with platform-specific code paths:

- **Web**: Uses `Image.network()` for photos (blob URLs), browser download for file save, SnackBar for share (not supported)
- **Mobile**: Uses `Image.file()` for photos, `path_provider` for file paths, native share via `share_plus`

See **Web/Mobile File Handling** section below for implementation details.

## Important Implementation Notes

- **Premium templates** are flagged with `isPremium` in TemplateModel; category filtering respects category-specific and 'all' templates
- **User profile edits** use `StateProvider` to allow live updates without requiring explicit save actions
- **Editor settings** (font size, colors) are managed via `StateNotifierProvider` with bounds validation:
  - `EditorNotifier.updateFontSize()` clamps values between `AppTheme.minFontSize` and `maxFontSize`
  - `EditorNotifier.updateColor()` validates colors against `AppTheme.editorColors` whitelist
- **Theme constants** are centralized in `app_theme.dart` (editorColors, font sizes, colors) to maintain consistency
- **File path handling** (PosterPreview, ProfileEditor): Use the `hasValidPhoto` pattern to cache file existence checks once per build, preventing redundant I/O calls
- **Screenshot capture** targets the `PosterPreview` widget; ensure layout is stable before capture
- **Dummy data** is hardcoded in `data/dummy_data.dart`; no backend integration currently

## Lint Configuration

The project uses Flutter recommended lints via `flutter_lints: ^6.0.0`. Configuration is in `analysis_options.yaml` with defaults enabled.

## Common Patterns & Gotchas

**Web/Mobile File Handling Abstraction**

To support both web (no file I/O) and mobile (uses `dart:io`), file operations are abstracted behind a conditional import pattern:

- **`lib/utils/file_stub.dart`** — Web stub that always returns null/false (never called on web)
- **`lib/utils/file_io.dart`** — Mobile implementation using `dart:io.File`

Both export the same interface:
```dart
ImageProvider? fileImageProvider(String path)  // Returns FileImage on mobile, null on web
bool fileExists(String path)                   // Returns File.existsSync() on mobile, false on web
```

Usage in widgets (e.g., `PosterPreview`, `ProfileEditor`):
```dart
import '../utils/file_stub.dart' if (dart.library.io) '../utils/file_io.dart';

final hasValidPhoto = photoUrl != null && photoUrl.isNotEmpty && 
    (kIsWeb || fileExists(photoUrl));

backgroundImage: hasValidPhoto
    ? (kIsWeb 
        ? NetworkImage(photoUrl!) 
        : fileImageProvider(photoUrl!))
    : null,
```

This pattern ensures:
- Web builds never import `dart:io` (which is unavailable on web)
- Type safety: `ImageProvider?` works across both targets
- Clean abstraction: widgets don't need to know about platform differences

**Premium Template Edge Case**
In `HomeScreen` line 92, when switching categories, the template selector attempts to default to a free template. However, if a category has only premium templates, it still returns the first (premium) template. This is acceptable for now but should be addressed if premium unlock behavior changes.

**Context Safety**
When showing SnackBars or dialogs from error handlers, always check both `mounted` and `context.mounted` before using context (see `ProfileEditor._pickImage()` for reference).

**EditorNotifier Validation**
Any changes to color values or font sizes must go through `EditorNotifier` methods (`updateFontSize()`, `updateColor()`). Direct state manipulation bypasses validation. Always use the provided methods.

**Download & Share on Web vs Mobile** (`BottomActionRow`)
- **Web**: Download uses `universal_html` blob + AnchorElement click (browser native download); Share shows SnackBar "not supported"
- **Mobile**: Download saves to temp directory; Share uses `share_plus.Share.shareXFiles()`

Both paths are already implemented with `if (kIsWeb)` guards. See `_generateImage()` and `_handleShare()` for reference.

## Testing

A widget smoke test exists at `test/widget_test.dart` that verifies app loads and displays key UI elements. Expand test coverage with:

**Unit Tests (add to test/ directory)**
- `EditorNotifier` state transitions and bounds validation:
  - `updateFontSize()` clamps to [minFontSize, maxFontSize]
  - `updateColor()` only accepts colors from `AppTheme.editorColors` whitelist
- `UserProfile.copyWith()` immutability
- Provider filtering logic (`quotesByCategoryProvider`, `templatesByCategoryProvider`)

**Widget Tests**
- Template selection and premium gating (should show upgrade dialog for premium templates when not subscribed)
- Profile editor image picking flow
- Screenshot/share/download button functionality

**Current Limitations**
- No integration tests for actual image capture or file I/O
- No tests for Riverpod provider dependencies and watch behavior
- No accessibility (a11y) tests
