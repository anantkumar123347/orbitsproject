import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbitsproject/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Provide the required parameters: username and password
    await tester.pumpWidget(
      const MyApp(
        isLoggedIn: false,
        username: 'testUser', // ✅ Added required argument
        password: 'testPass', // ✅ Added required argument
      ),
    );

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
