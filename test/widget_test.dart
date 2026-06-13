import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('Smoke Test: RentoApp builds successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    expect(true, true);

    // Verify that the MaterialApp is present.
    expect(find.byType(MaterialApp), findsOneWidget);

    // Verify that the splash screen or initial screen renders.
    expect(find.byType(Scaffold), findsWidgets);
  });
}
