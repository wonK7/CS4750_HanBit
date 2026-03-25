import 'package:flutter_test/flutter_test.dart';

import 'package:hanbit/main.dart';

void main() {
  testWidgets('Login page renders', (WidgetTester tester) async {
    await tester.pumpWidget(const HanBit());

    expect(find.text('HanBit'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });
}
