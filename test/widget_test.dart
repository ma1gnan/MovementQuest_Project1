import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_workout_partner/main.dart';

void main() {
  testWidgets('Movement Quest dashboard starts correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MovementQuestApp());

    // Verify the app bar appears immediately.
    expect(find.text('Movement Quest'), findsOneWidget);

    // The dashboard initially displays a loading indicator
    // while it reads workout data from SQLite.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
