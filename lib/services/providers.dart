import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import '../data/dummy_data.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

final screenshotControllerProvider = Provider((ref) => ScreenshotController());

final isUserPremiumProvider = StateProvider<bool>((ref) => false);

final categoriesProvider = Provider<List<Category>>((ref) {
  return dummyCategories;
});

final quotesProvider = Provider<List<Quote>>((ref) {
  return dummyQuotes;
});

final templatesProvider = Provider<List<TemplateModel>>((ref) {
  return dummyTemplates;
});

final selectedTemplateProvider = StateProvider<TemplateModel>((ref) {
  final templates = ref.watch(templatesProvider);
  return templates[0];
});

// Changed to StateProvider to allow live editing
final userProfileProvider = StateProvider<UserProfile>((ref) {
  return dummyUser;
});

final selectedCategoryIdProvider = StateProvider<String>((ref) => 'all');

final quotesByCategoryProvider = Provider.family<List<Quote>, String>((ref, categoryId) {
  final allQuotes = ref.watch(quotesProvider);
  if (categoryId == 'all') return allQuotes;
  return allQuotes.where((quote) => quote.categoryId == categoryId).toList();
});

final templatesByCategoryProvider = Provider.family<List<TemplateModel>, String>((ref, categoryId) {
  final allTemplates = ref.watch(templatesProvider);
  if (categoryId == 'all') return allTemplates;
  return allTemplates
      .where((template) => template.categoryId == categoryId || template.categoryId == 'all')
      .toList();
});

// Editor State Provider for Quote styling (font size, etc.)
class EditorSettings {
  final double fontSize;
  final int backgroundColorValue;

  EditorSettings({required this.fontSize, required this.backgroundColorValue});

  EditorSettings copyWith({double? fontSize, int? backgroundColorValue}) {
    return EditorSettings(
      fontSize: fontSize ?? this.fontSize,
      backgroundColorValue: backgroundColorValue ?? this.backgroundColorValue,
    );
  }
}

class EditorNotifier extends StateNotifier<EditorSettings> {
  EditorNotifier()
      : super(EditorSettings(
          fontSize: AppTheme.defaultFontSize,
          backgroundColorValue: AppTheme.editorColors[0],
        ));

  void updateFontSize(double size) {
    // Bounds checking
    final validatedSize = size.clamp(AppTheme.minFontSize, AppTheme.maxFontSize);
    state = state.copyWith(fontSize: validatedSize);
  }

  void updateColor(int colorValue) {
    // Validate that color exists in our allowed palette
    if (AppTheme.editorColors.contains(colorValue)) {
      state = state.copyWith(backgroundColorValue: colorValue);
    }
  }
}

final editorProvider = StateNotifierProvider<EditorNotifier, EditorSettings>((ref) {
  return EditorNotifier();
});

// Infinite scroll pagination for quotes list
const int _quotesPageSize = 10;

final quotesPageCountProvider = StateProvider.autoDispose<int>((ref) => _quotesPageSize);
final isLoadingMoreQuotesProvider = StateProvider.autoDispose<bool>((ref) => false);

final paginatedQuotesProvider = Provider.autoDispose.family<List<Quote>, String>((ref, categoryId) {
  final pageCount = ref.watch(quotesPageCountProvider);
  // Generate a pool of 100 quotes by cycling through dummy data
  final allQuotes = generateExpandedQuotes(100);

  if (categoryId == 'all') {
    return allQuotes.take(pageCount).toList();
  }

  final filtered = allQuotes.where((q) => q.categoryId == categoryId).toList();
  return filtered.take(pageCount).toList();
});
