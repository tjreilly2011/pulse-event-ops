import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulse_ops/main.dart';

void main() {
  testWidgets('App renders without crash', (WidgetTester tester) async {
    await tester.pumpWidget(const PulseOpsApp());
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
