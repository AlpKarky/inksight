import 'package:flutter_test/flutter_test.dart';
import 'package:inksight/main.dart';

void main() {
  testWidgets('InkSight home screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('InkSight'), findsOneWidget);
    expect(find.text('Analyze Your Handwriting'), findsOneWidget);
    expect(find.text('Analyze Handwriting'), findsOneWidget);
  });
}
