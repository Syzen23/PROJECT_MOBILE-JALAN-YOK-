import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jalanyok2/main.dart';

void main() {
  testWidgets('renders app shell smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
