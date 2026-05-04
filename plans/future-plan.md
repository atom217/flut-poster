# Plan: 7-Feature Enhancement for Jai Bhim Status Maker

## Context

The app has all user-facing text hardcoded inline across multiple files, no app icon, a non-functional burger menu, a wired-but-dead "Get Premium" button, no quote pagination, no welcome/onboarding screen, and the photo-of-self feature (already partially built) is buried and broken on Android. This plan centralizes strings for future i18n, wires up the existing premium dialog, builds a real drawer, adds infinite scroll, adds a welcome screen, and fixes photo discoverability and Android permissions.

---

## Implementation Order

1. **Feature 1** (AppStrings) — foundation; define all strings including those for new features up front
2. **Feature 6** (Welcome Screen) — establishes routing early; no dependencies
3. **Feature 4** (Get Premium logic + shared dialog) — creates `dialogs.dart`, prerequisite for drawer
4. **Feature 3** (Burger Menu / Drawer) — depends on `dialogs.dart` and photo utility from Feature 7
5. **Feature 7** (Photo of Self) — Android permission fix + `pickAndSetProfilePhoto` utility for drawer
6. **Feature 5** (Infinite Scroll) — pure provider/data work, independent
7. **Feature 2** (App Icon) — build-time tooling, no runtime code impact, done last

---

## Feature 6: Welcome Screen

### New file: `lib/screens/welcome_screen.dart`

```
Scaffold(backgroundColor: AppTheme.primaryColor)
  └── SafeArea → Column(center)
        ├── Icon(Icons.menu_book_rounded, size: 80, white)
        ├── SizedBox(24)
        ├── Text(AppStrings.appTitle, white bold 28sp)
        ├── SizedBox(8)
        ├── Text(AppStrings.welcomeTagline, white 14sp)
        ├── SizedBox(60)
        ├── ElevatedButton(AppStrings.welcomeLoginWithPhone)
        │     onPressed → SnackBar(AppStrings.welcomeAuthComingSoon)
        ├── SizedBox(16)
        └── TextButton(AppStrings.welcomeContinueAsGuest, white)
              onPressed → Navigator.pushReplacement → HomeScreen()
```

### Modify `lib/main.dart`:
- Change `home: const HomeScreen()` → `home: const WelcomeScreen()`
- Add import for `welcome_screen.dart`

---

## Feature 4: Get Premium Functionality

### New file: `lib/utils/dialogs.dart`

Extract `_showUpgradeDialog` from `HomeScreen` into a shared top-level function:

```dart
void showUpgradeDialog(BuildContext context, WidgetRef ref) {
  // same dialog content as current _showUpgradeDialog
  // BUT "Upgrade Now" button now does:
  //   Navigator.pop(context);
  //   ref.read(isUserPremiumProvider.notifier).state = true;
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text(AppStrings.upgradeSuccessDemo))
  //   );
}
```

### Modify `lib/screens/home_screen.dart`:
- Remove `_showUpgradeDialog` method; call `showUpgradeDialog(context, ref)` instead

### Modify `lib/widgets/home_app_bar.dart`:
- Convert `StatelessWidget` → `ConsumerWidget` (adds `WidgetRef ref` to build)
- Burger icon: `onPressed: () => Scaffold.of(context).openDrawer()`
- Get Premium button: `onPressed: () => showUpgradeDialog(context, ref)`
- Conditionally hide "Get Premium" when `ref.watch(isUserPremiumProvider) == true`, show "Premium Active" badge instead

---

## Feature 3: Burger Menu / Drawer

### New file: `lib/widgets/app_drawer.dart`

`AppDrawer extends ConsumerWidget`:

```
Drawer
  └── Column
        ├── DrawerHeader (background: primaryColor)
        │     └── Row:
        │           GestureDetector → pickAndSetProfilePhoto(ref, context)
        │             CircleAvatar(user.photoUrl or initials)
        │             + camera icon overlay
        │           Column: user.name (bold white), user.subtitle (white 12sp)
        ├── ListTile(Icons.home, AppStrings.drawerNavHome)
        │     → Navigator.pop + Navigator.pushReplacement(HomeScreen)
        ├── ListTile(Icons.menu_book, AppStrings.drawerNavQuotesLibrary)
        │     → Navigator.pop + push QuoteListScreen(allCategory)
        ├── Divider
        ├── ListTile(Icons.info_outline, AppStrings.drawerNavAbout)
        │     → showAboutDialog(...)
        ├── ListTile(Icons.settings, AppStrings.drawerNavSettings)
        │     → SnackBar(AppStrings.drawerSettingsComingSoon)
        ├── Divider
        └── if (!isUserPremium) → ElevatedButton(AppStrings.drawerUpgradeSection)
              → showUpgradeDialog(context, ref)
            else → ListTile(Icons.workspace_premium, AppStrings.drawerPremiumActive)
```

### Modify `lib/screens/home_screen.dart`:
- Add `drawer: const AppDrawer()` to the Scaffold

---

## Feature 7: Add Photo of Self

### Part A – Android permissions

**Modify `android/app/src/main/AndroidManifest.xml`** (add before `<application>`):
```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
    android:maxSdkVersion="32"/>
```

### Part B – Shared photo picker utility

**Add to `lib/services/providers.dart`** (or a new `lib/utils/photo_utils.dart`):

```dart
Future<void> pickAndSetProfilePhoto(WidgetRef ref, BuildContext context) async {
  final picker = ImagePicker();
  try {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      ref.read(userProfileProvider.notifier).update(
        (state) => state.copyWith(photoUrl: image.path),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.errorPickingImagePrefix}$e')),
      );
    }
  }
}
```

**Modify `lib/widgets/profile_editor.dart`**: Replace `_pickImage()` body with call to `pickAndSetProfilePhoto(ref, context)`.

The `AppDrawer` (Feature 3) already calls `pickAndSetProfilePhoto` from the tappable avatar in `DrawerHeader`.

---

## Feature 5: Infinite Scroll

### Modify `lib/data/dummy_data.dart`:

Add generator function:
```dart
List<Quote> generateExpandedQuotes(int count) {
  return List.generate(count, (i) {
    final base = dummyQuotes[i % dummyQuotes.length];
    return Quote(id: '${base.id}_$i', text: base.text,
        author: base.author, categoryId: base.categoryId);
  });
}
```

### Modify `lib/services/providers.dart`:

```dart
const _quotesPageSize = 10;

// autoDispose so count resets when QuoteListScreen is popped
final quotesPageCountProvider = StateProvider.autoDispose<int>((ref) => _quotesPageSize);
final isLoadingMoreQuotesProvider = StateProvider.autoDispose<bool>((ref) => false);

final paginatedQuotesProvider = Provider.autoDispose.family<List<Quote>, String>((ref, categoryId) {
  final pageCount = ref.watch(quotesPageCountProvider);
  final all = generateExpandedQuotes(100);
  final filtered = categoryId == 'all' ? all : all.where((q) => q.categoryId == categoryId).toList();
  return filtered.take(pageCount).toList();
});
```

### Modify `lib/screens/quote_list_screen.dart`:

- Convert `ConsumerWidget` → `ConsumerStatefulWidget`
- Add `ScrollController _scrollController` with scroll listener in `initState`
- Scroll listener triggers load-more when `pixels >= maxScrollExtent - 200` and not already loading
- Load-more: set `isLoadingMoreQuotesProvider = true` → `Future.delayed(800ms)` → increment `quotesPageCountProvider` by `_quotesPageSize` → set loading back to `false`
- `itemCount: quotes.length + 1`; last slot shows `CircularProgressIndicator` when loading, `SizedBox.shrink()` otherwise
- Switch to `paginatedQuotesProvider(category.id)`
- Dispose scroll controller in `dispose()`

---

## Feature 2: App Icon

### Modify `pubspec.yaml`:
- Uncomment/add `assets: - assets/images/` under `flutter:`
- Add dev dependency: `flutter_launcher_icons: ^0.14.1`
- Add config block at root level:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/app_icon.png"
  adaptive_icon_background: "#3F51B5"
  adaptive_icon_foreground: "assets/images/app_icon_foreground.png"
  web:
    generate: true
    image_path: "assets/images/app_icon.png"
    background_color: "#3F51B5"
    theme_color: "#3F51B5"
```

### New files needed:
- `assets/images/app_icon.png` — 1024×1024 PNG: indigo circle, white "JB" letters + open book icon beneath
- `assets/images/app_icon_foreground.png` — same design, transparent background, content in center 66%

### Run after setup:
```bash
flutter pub get && dart run flutter_launcher_icons
```

---

## Critical Files Summary

| File | Action | Features |
|------|--------|----------|
| `lib/utils/app_strings.dart` | **Create** | 1 |
| `lib/utils/dialogs.dart` | **Create** | 3, 4 |
| `lib/utils/photo_utils.dart` | **Create** | 7 |
| `lib/screens/welcome_screen.dart` | **Create** | 6 |
| `lib/widgets/app_drawer.dart` | **Create** | 3 |
| `lib/main.dart` | Modify | 1, 6 |
| `lib/widgets/home_app_bar.dart` | Modify | 1, 3, 4 |
| `lib/screens/home_screen.dart` | Modify | 1, 3, 4 |
| `lib/screens/editor_screen.dart` | Modify | 1 |
| `lib/screens/quote_list_screen.dart` | Modify | 1, 5 |
| `lib/widgets/bottom_action_row.dart` | Modify | 1 |
| `lib/widgets/poster_preview.dart` | Modify | 1 |
| `lib/widgets/profile_editor.dart` | Modify | 1, 7 |
| `lib/services/providers.dart` | Modify | 5 |
| `lib/data/dummy_data.dart` | Modify | 5 |
| `android/app/src/main/AndroidManifest.xml` | Modify | 7 |
| `pubspec.yaml` | Modify | 2 |
| `assets/images/app_icon.png` | **Create** | 2 |
| `assets/images/app_icon_foreground.png` | **Create** | 2 |

---

## Verification

```bash
# After all changes:
flutter analyze        # zero errors
flutter test           # smoke test passes

# Manual checks:
# 1. Welcome screen appears on first launch; "Continue as Guest" → HomeScreen
# 2. "Login with Phone" shows "coming soon" snackbar
# 3. Burger icon opens drawer with profile, nav items, premium section
# 4. Tapping avatar in drawer opens gallery picker, photo updates on poster
# 5. "Get Premium" in AppBar and drawer both open the upgrade dialog
# 6. "Upgrade Now" in dialog toggles premium state; premium templates unlock
# 7. QuoteListScreen scrolling loads more quotes; spinner appears at bottom
# 8. flutter build apk --debug  → no crash, icon visible on launcher
```
