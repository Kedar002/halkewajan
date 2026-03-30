import 'package:flutter_test/flutter_test.dart';
import 'package:halkewajan/main.dart';

void main() {
  testWidgets('App renders home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const HalkeWajanApp());
    expect(find.textContaining('morning').evaluate().isNotEmpty ||
           find.textContaining('afternoon').evaluate().isNotEmpty ||
           find.textContaining('evening').evaluate().isNotEmpty, true);
  });
}
