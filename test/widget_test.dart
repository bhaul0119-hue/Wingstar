import 'package:flutter_test/flutter_test.dart';
import 'package:wingstar/main.dart';

void main() {
  testWidgets('Wingstar app launches', (WidgetTester tester) async {
    await tester.pumpWidget(const WingstarApp());
    expect(find.text('WINGSTAR'), findsOneWidget);
  });
}
