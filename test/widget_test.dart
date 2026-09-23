import 'package:flutter_test/flutter_test.dart';
import 'package:cuproute/main.dart';

void main() {
  testWidgets('App builds and navigates through splash screen without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const CupRouteApp());
    // Advance timers and complete pending animations/futures (like splash screen check)
    await tester.pumpAndSettle();
    expect(find.byType(CupRouteApp), findsOneWidget);
  });
}
