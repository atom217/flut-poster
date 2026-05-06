import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jai_bhim_status_maker/main.dart';

void main() {
  testWidgets('App loads and shows main UI elements', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Verify that our app bar title is shown.
    expect(find.text('Jai Ram'), findsOneWidget);

    // Verify that categories are present.
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Good Morning'), findsOneWidget);

    // Verify that the "Get Premium" button is present.
    expect(find.text('Get Premium'), findsOneWidget);

    // Verify that action buttons are present.
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
  });
}
