import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gutlog/view/pages/login_page.dart';

void main() {
  testWidgets('LoginPage renders login button', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    expect(find.text('Login'), findsOneWidget);
  });
}
