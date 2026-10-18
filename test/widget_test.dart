import 'package:flutter_test/flutter_test.dart';
import 'package:watchmate/main.dart';

void main() {
  testWidgets('WatchMate shows login screen', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const WatchMateApp());

    // Verify that the login screen text is visible.
    expect(find.text('WatchMate'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });
}