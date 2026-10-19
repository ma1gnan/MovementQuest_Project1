import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_workout_partner/main.dart';

void main() {
  testWidgets('Movement Quest dashboard loads correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MovementQuestApp());

    // Verify the application title.
    expect(find.text('Movement Quest'), findsOneWidget);

    // Verify the welcome message.
    expect(find.text('Welcome to Movement Quest!'), findsOneWidget);

    // Verify the first workout.
    expect(find.text('Full Body Basics'), findsOneWidget);

    // Scroll until the second workout appears.
    await tester.scrollUntilVisible(
      find.text('Upper Body Quest'),
      150.0,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Upper Body Quest'), findsOneWidget);

    // Scroll until the third workout appears.
    await tester.scrollUntilVisible(
      find.text('Core Challenge'),
      150.0,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Core Challenge'), findsOneWidget);

    // Scroll back to the top.
    await tester.drag(find.byType(ListView), const Offset(0, 1000));
    await tester.pumpAndSettle();

    // Verify that the equipment filter exists.
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
  });
}
