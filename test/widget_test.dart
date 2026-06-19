import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pmpl_salesquote/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {

    // Build the app
    // await tester.pumpWidget(const SalesQuoteApp());
    await tester.pumpWidget(const SalesQuoteApp(isLogin: false),);
    // Verify counter starts at 0
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the + button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();


    // Verify counter increments
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}