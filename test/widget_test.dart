import 'package:flutter_test/flutter_test.dart';
import 'package:digital_gate_pass/main.dart';

void main() {
  testWidgets('App renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GatePassApp());
    expect(find.text('Gate Pass System'), findsOneWidget);
  });
}
