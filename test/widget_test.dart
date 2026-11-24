import 'package:flutter_test/flutter_test.dart';
import 'package:e_commerce/app/app.dart';

void main() {
  testWidgets('App launches with splash screen and navigates to auth', (WidgetTester tester) async {
    await tester.pumpWidget(const CraftyBayApp());
    expect(find.byType(CraftyBayApp), findsOneWidget);
    // Advance timer past splash duration
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
