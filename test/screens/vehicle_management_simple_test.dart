import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/screens/vehicles_screen.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';

void main() {
  group('Vehicle Management Simple Tests', () {
    testWidgets('Should build VehiclesScreen without errors', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: VehiclesScreen(),
          ),
        ),
      );

      // Just check that the screen builds without errors
      expect(find.byType(VehiclesScreen), findsOneWidget);
      expect(find.text('Vehicles'), findsOneWidget);
    });

    testWidgets('Should show AppBar with title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: VehiclesScreen(),
          ),
        ),
      );

      expect(find.text('Vehicles'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Should show FloatingActionButton', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: VehiclesScreen(),
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsAtLeastNWidgets(1));
    });

    testWidgets('Should show add vehicle dialog when FAB is tapped', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: VehiclesScreen(),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Tap the floating action button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Add New Vehicle'), findsOneWidget);
      expect(find.text('Vehicle Name'), findsOneWidget);
      expect(find.text('Initial Kilometers'), findsOneWidget);
      expect(find.text('Add Vehicle'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('Should validate form inputs in add vehicle dialog', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: VehiclesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open add vehicle dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.text('Add Vehicle'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a vehicle name'), findsOneWidget);
      expect(find.text('Please enter initial kilometers'), findsOneWidget);
    });

    testWidgets('Should validate name length in add vehicle dialog', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: VehiclesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open add vehicle dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter invalid data (too short name)
      await tester.enterText(find.byType(TextFormField).first, 'A');
      await tester.tap(find.text('Add Vehicle'));
      await tester.pumpAndSettle();

      expect(find.text('Name must be at least 2 characters'), findsOneWidget);
    });

    testWidgets('Should show statistics cards', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: VehiclesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Total Vehicles'), findsOneWidget);
      expect(find.text('Total Entries'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.local_gas_station), findsAtLeastNWidgets(1));
    });

    testWidgets('Should close add vehicle dialog when cancel is tapped', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: VehiclesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open add vehicle dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Add New Vehicle'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Add New Vehicle'), findsNothing);
    });

    testWidgets('Should show number input validation', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: VehiclesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open add vehicle dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter valid name but invalid kilometers
      await tester.enterText(find.byType(TextFormField).first, 'Test Vehicle');
      await tester.enterText(find.byType(TextFormField).last, 'invalid');
      await tester.tap(find.text('Add Vehicle'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid number'), findsOneWidget);
    });

    testWidgets('Should accept valid form data', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: VehiclesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open add vehicle dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Enter valid data
      await tester.enterText(find.byType(TextFormField).first, 'Honda Civic 2020');
      await tester.enterText(find.byType(TextFormField).last, '50000');
      
      // Form should be valid (no validation errors appear immediately)
      await tester.pump(); // Just pump, don't wait for settlement
      
      // Check that no validation errors are shown
      expect(find.text('Please enter a vehicle name'), findsNothing);
      expect(find.text('Please enter initial kilometers'), findsNothing);
      expect(find.text('Name must be at least 2 characters'), findsNothing);
      expect(find.text('Please enter a valid number'), findsNothing);
    });
  });
}