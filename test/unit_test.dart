import 'package:flutter_test/flutter_test.dart';
import 'package:jai_bhim_status_maker/services/providers.dart';
import 'package:jai_bhim_status_maker/theme/app_theme.dart';

void main() {
  group('EditorNotifier Tests', () {
    late EditorNotifier notifier;

    setUp(() {
      notifier = EditorNotifier();
    });

    test('Initial state should be default values', () {
      expect(notifier.state.fontSize, AppTheme.defaultFontSize);
      expect(notifier.state.backgroundColorValue, AppTheme.editorColors[0]);
    });

    test('updateFontSize should respect upper bound', () {
      notifier.updateFontSize(100.0);
      expect(notifier.state.fontSize, AppTheme.maxFontSize);
    });

    test('updateFontSize should respect lower bound', () {
      notifier.updateFontSize(5.0);
      expect(notifier.state.fontSize, AppTheme.minFontSize);
    });

    test('updateColor should ignore invalid colors', () {
      const invalidColor = 0xFF123456;
      notifier.updateColor(invalidColor);
      // Should remain at default (the first color in the list)
      expect(notifier.state.backgroundColorValue, AppTheme.editorColors[0]);
    });

    test('updateColor should accept valid colors', () {
      final validColor = AppTheme.editorColors[1];
      notifier.updateColor(validColor);
      expect(notifier.state.backgroundColorValue, validColor);
    });
  });
}
