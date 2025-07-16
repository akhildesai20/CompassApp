// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:minimalist_compass/main.dart';   // ← make sure this matches your package name

void main() {
  testWidgets('Compass renders cardinal labels', (tester) async {
    await tester.pumpWidget(const CompassApp());

    // N-label should be on screen
    expect(find.text('N'), findsOneWidget);
  });
}
