import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/screens/dashboard_screen.dart';
import 'package:petrol_tracker/screens/fuel_entries_screen.dart';
import 'package:petrol_tracker/screens/add_fuel_entry_screen.dart';
import 'package:petrol_tracker/screens/vehicles_screen.dart';
import 'package:petrol_tracker/screens/settings_screen.dart';

void main() {
  group('Screen Widget Tests', () {
    Widget createTestWidget(Widget screen) {
      return ProviderScope(
        child: MaterialApp(
          home: screen,
        ),
      );
    }

    group('DashboardScreen', () {
      testWidgets('Should display dashboard content', (tester) async {
        await tester.pumpWidget(createTestWidget(const DashboardScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Welcome to Dashboard'), findsOneWidget);
        expect(find.text('Total Entries'), findsOneWidget);
        expect(find.text('Vehicles'), findsOneWidget);
        expect(find.text('Consumption Charts'), findsOneWidget);
        expect(find.text('Recent Entries'), findsOneWidget);
      });

      testWidgets('Should display empty state placeholders', (tester) async {
        await tester.pumpWidget(createTestWidget(const DashboardScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Charts will appear here'), findsOneWidget);
        expect(find.text('No recent entries'), findsOneWidget);
      });
    });

    group('FuelEntriesScreen', () {
      testWidgets('Should display fuel entries screen', (tester) async {
        await tester.pumpWidget(createTestWidget(const FuelEntriesScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Fuel Entries'), findsOneWidget);
        expect(find.byIcon(Icons.search), findsOneWidget);
        expect(find.byIcon(Icons.sort), findsOneWidget);
      });

      testWidgets('Should display empty state', (tester) async {
        await tester.pumpWidget(createTestWidget(const FuelEntriesScreen()));
        await tester.pumpAndSettle();

        expect(find.text('No Fuel Entries Yet'), findsOneWidget);
        expect(find.text('Add First Entry'), findsOneWidget);
        expect(find.text('Add Vehicle First'), findsOneWidget);
      });

      testWidgets('Should show search dialog when search button is tapped', (tester) async {
        await tester.pumpWidget(createTestWidget(const FuelEntriesScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.search));
        await tester.pumpAndSettle();

        expect(find.text('Search Entries'), findsOneWidget);
        expect(find.text('Search by vehicle, location, etc.'), findsOneWidget);
      });
    });

    group('AddFuelEntryScreen', () {
      testWidgets('Should display add fuel entry form', (tester) async {
        await tester.pumpWidget(createTestWidget(const AddFuelEntryScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Add Fuel Entry'), findsOneWidget);
        expect(find.text('Vehicle'), findsOneWidget);
        expect(find.text('Date'), findsOneWidget);
        expect(find.text('Fuel Amount'), findsOneWidget);
        expect(find.text('Total Price'), findsOneWidget);
        expect(find.text('Current Kilometers'), findsOneWidget);
        expect(find.text('Location/Country'), findsOneWidget);
        expect(find.text('Save Fuel Entry'), findsOneWidget);
      });

      testWidgets('Should show date picker when date field is tapped', (tester) async {
        await tester.pumpWidget(createTestWidget(const AddFuelEntryScreen()));
        await tester.pumpAndSettle();

        // Find and tap the date field
        await tester.tap(find.byIcon(Icons.calendar_today));
        await tester.pumpAndSettle();

        // Should show date picker
        expect(find.byType(DatePickerDialog), findsOneWidget);
      });

      testWidgets('Should validate required fields', (tester) async {
        await tester.pumpWidget(createTestWidget(const AddFuelEntryScreen()));
        await tester.pumpAndSettle();

        // Try to save without filling required fields
        await tester.tap(find.text('Save Fuel Entry'));
        await tester.pumpAndSettle();

        // Should show validation errors
        expect(find.text('Please select a vehicle'), findsOneWidget);
        expect(find.text('Please enter fuel amount'), findsOneWidget);
        expect(find.text('Please enter total price'), findsOneWidget);
        expect(find.text('Please enter current kilometers'), findsOneWidget);
        expect(find.text('Please enter location'), findsOneWidget);
      });
    });

    group('VehiclesScreen', () {
      testWidgets('Should display vehicles screen', (tester) async {
        await tester.pumpWidget(createTestWidget(const VehiclesScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Vehicles'), findsOneWidget);
        expect(find.text('Total Vehicles'), findsOneWidget);
        expect(find.text('Total Entries'), findsOneWidget);
      });

      testWidgets('Should display empty state', (tester) async {
        await tester.pumpWidget(createTestWidget(const VehiclesScreen()));
        await tester.pumpAndSettle();

        expect(find.text('No Vehicles Yet'), findsOneWidget);
        expect(find.text('Add First Vehicle'), findsOneWidget);
      });

      testWidgets('Should show add vehicle dialog when add button is tapped', (tester) async {
        await tester.pumpWidget(createTestWidget(const VehiclesScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add).first);
        await tester.pumpAndSettle();

        expect(find.text('Add New Vehicle'), findsOneWidget);
        expect(find.text('Vehicle Name'), findsOneWidget);
        expect(find.text('Initial Kilometers'), findsOneWidget);
      });
    });

    group('SettingsScreen', () {
      testWidgets('Should display settings screen', (tester) async {
        await tester.pumpWidget(createTestWidget(const SettingsScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Settings'), findsOneWidget);
        expect(find.text('Appearance'), findsOneWidget);
        expect(find.text('Units'), findsOneWidget);
        expect(find.text('Notifications'), findsOneWidget);
        expect(find.text('Data Management'), findsOneWidget);
        expect(find.text('About'), findsOneWidget);
      });

      testWidgets('Should display theme and units dropdowns', (tester) async {
        await tester.pumpWidget(createTestWidget(const SettingsScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Theme'), findsOneWidget);
        expect(find.text('Unit System'), findsOneWidget);
        expect(find.byType(DropdownButton<String>), findsNWidgets(2));
      });

      testWidgets('Should display notification and analytics switches', (tester) async {
        await tester.pumpWidget(createTestWidget(const SettingsScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Enable Notifications'), findsOneWidget);
        expect(find.text('Anonymous Analytics'), findsOneWidget);
        expect(find.byType(Switch), findsNWidgets(2));
      });

      testWidgets('Should show clear data confirmation dialog', (tester) async {
        await tester.pumpWidget(createTestWidget(const SettingsScreen()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Clear All Data'));
        await tester.pumpAndSettle();

        expect(find.text('Clear All Data'), findsNWidgets(2)); // Title and button
        expect(find.text('This will permanently delete all your vehicles'), findsOneWidget);
      });
    });
  });
}