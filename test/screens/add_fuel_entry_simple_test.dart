import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/screens/add_fuel_entry_screen.dart';

void main() {
  group('AddFuelEntryScreen Simple Tests', () {
    testWidgets('should build without errors', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddFuelEntryScreen(),
          ),
        ),
      );

      expect(find.byType(AddFuelEntryScreen), findsOneWidget);
    });

    testWidgets('should display form title', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddFuelEntryScreen(),
          ),
        ),
      );

      expect(find.text('Add Fuel Entry'), findsOneWidget);
    });

    testWidgets('should display required form fields', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddFuelEntryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for form field labels
      expect(find.text('Vehicle *'), findsOneWidget);
      expect(find.text('Date *'), findsOneWidget);
      expect(find.text('Current Odometer Reading *'), findsOneWidget);
      expect(find.text('Fuel Amount *'), findsOneWidget);
      expect(find.text('Total Price *'), findsOneWidget);
      expect(find.text('Price per Liter *'), findsOneWidget);
      expect(find.text('Country *'), findsOneWidget);
    });

    testWidgets('should display save button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddFuelEntryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Save Fuel Entry'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget); // In app bar
    });

    testWidgets('should display auto-calculate switch', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddFuelEntryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Auto-calculate'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should have proper form structure', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AddFuelEntryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have a form
      expect(find.byType(Form), findsOneWidget);
      
      // Should have text form fields
      expect(find.byType(TextFormField), findsWidgets);
      
      // Should have dropdown fields
      expect(find.byType(DropdownButtonFormField), findsWidgets);
    });
  });
}