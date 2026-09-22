import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbitsproject/main.dart';
import 'package:orbitsproject/pages/login.dart';

void main() {
  testWidgets('Shows the login page when no user is logged in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MyApp(isLoggedIn: false, username: null, password: null),
    );

    // With no stored session, the app should land on the login screen.
    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('Select Role'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
  });
}
