import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raaz_app/main.dart';

void main() {
  testWidgets('RAAZ app smoke test', (WidgetTester tester) async {
    // Just verify the app widget can be built
    await tester.pumpWidget(const RaazApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
