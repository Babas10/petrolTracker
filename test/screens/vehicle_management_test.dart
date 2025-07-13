import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/screens/vehicles_screen.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';

void main() {
  group('Vehicle Management Tests', () {
    testWidgets('Should display empty state when no vehicles exist', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehiclesNotifierProvider.overrideWith(() => throw UnimplementedError()),
            vehicleCountProvider.overrideWith((ref) => Future.value(0)),
            fuelEntriesNotifierProvider.overrideWith(() => throw UnimplementedError()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VehiclesScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Vehicles Yet'), findsOneWidget);
      expect(find.text('Add your first vehicle to start tracking fuel consumption.'), findsOneWidget);
      expect(find.text('Add First Vehicle'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car_outlined), findsOneWidget);
    });

    testWidgets('Should display loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehiclesNotifierProvider.overrideWith(() => throw UnimplementedError()),
            vehicleCountProvider.overrideWith((ref) => Future.delayed(Duration(seconds: 1), () => 0)),
            fuelEntriesNotifierProvider.overrideWith(() => throw UnimplementedError()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VehiclesScreen(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Should display vehicle stats correctly', (tester) async {
      final vehicleState = VehicleState(
        vehicles: [
          VehicleModel(
            id: 1,
            name: 'Test Vehicle',
            initialKm: 50000,
            createdAt: DateTime.now(),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehiclesNotifierProvider.overrideWith((ref) => AsyncValue.data(vehicleState)),
            vehicleCountProvider.overrideWith((ref) => Future.value(1)),
            fuelEntriesNotifierProvider.overrideWith((ref) => AsyncValue.data(FuelEntryState(entries: []))),
            fuelEntriesByVehicleProvider(1).overrideWith((ref) => Future.value([])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VehiclesScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Total Vehicles'), findsOneWidget);
      expect(find.text('Total Entries'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // Vehicle count
      expect(find.text('0'), findsOneWidget); // Entry count
    });

    testWidgets('Should display vehicles list correctly', (tester) async {
      final testVehicle = VehicleModel(
        id: 1,
        name: 'Honda Civic 2020',
        initialKm: 50000,
        createdAt: DateTime.now(),
      );

      final vehicleState = VehicleState(vehicles: [testVehicle]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehiclesNotifierProvider.overrideWith((ref) => AsyncValue.data(vehicleState)),
            vehicleCountProvider.overrideWith((ref) => Future.value(1)),
            fuelEntriesNotifierProvider.overrideWith((ref) => AsyncValue.data(FuelEntryState(entries: []))),
            fuelEntriesByVehicleProvider(1).overrideWith((ref) => Future.value([])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VehiclesScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Honda Civic 2020'), findsOneWidget);
      expect(find.text('Initial KM: 50000 km'), findsOneWidget);
      expect(find.text('No entries yet'), findsOneWidget);
      expect(find.byIcon(Icons.directions_car), findsOneWidget);
    });

    testWidgets('Should show add vehicle dialog when FAB is tapped', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehiclesNotifierProvider.overrideWith((ref) => AsyncValue.data(VehicleState())),
            vehicleCountProvider.overrideWith((ref) => Future.value(0)),
            fuelEntriesNotifierProvider.overrideWith((ref) => AsyncValue.data(FuelEntryState(entries: []))),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VehiclesScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsAtLeastOneWidget);
      
      // Tap the floating action button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Add New Vehicle'), findsOneWidget);
      expect(find.text('Vehicle Name'), findsOneWidget);
      expect(find.text('Initial Kilometers'), findsOneWidget);
    });

    testWidgets('Should validate form inputs in add vehicle dialog', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehiclesNotifierProvider.overrideWith((ref) => AsyncValue.data(VehicleState())),
            vehicleCountProvider.overrideWith((ref) => Future.value(0)),
            fuelEntriesNotifierProvider.overrideWith((ref) => AsyncValue.data(FuelEntryState(entries: []))),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VehiclesScreen(),
            ),
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

      // Enter invalid data
      await tester.enterText(find.byType(TextFormField).first, 'A'); // Too short name
      await tester.enterText(find.byType(TextFormField).last, '-100'); // Negative km
      await tester.tap(find.text('Add Vehicle'));
      await tester.pumpAndSettle();

      expect(find.text('Name must be at least 2 characters'), findsOneWidget);
      expect(find.text('Please enter a valid number'), findsOneWidget);
    });

    testWidgets('Should show popup menu with options for vehicle card', (tester) async {
      final testVehicle = VehicleModel(
        id: 1,
        name: 'Test Vehicle',
        initialKm: 50000,
        createdAt: DateTime.now(),
      );

      final vehicleState = VehicleState(vehicles: [testVehicle]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehiclesNotifierProvider.overrideWith((ref) => AsyncValue.data(vehicleState)),
            vehicleCountProvider.overrideWith((ref) => Future.value(1)),
            fuelEntriesNotifierProvider.overrideWith((ref) => AsyncValue.data(FuelEntryState(entries: []))),
            fuelEntriesByVehicleProvider(1).overrideWith((ref) => Future.value([])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VehiclesScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the popup menu button
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      expect(find.text('View Entries'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('Should show delete confirmation dialog', (tester) async {
      final testVehicle = VehicleModel(
        id: 1,
        name: 'Test Vehicle',
        initialKm: 50000,
        createdAt: DateTime.now(),
      );

      final vehicleState = VehicleState(vehicles: [testVehicle]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehiclesNotifierProvider.overrideWith((ref) => AsyncValue.data(vehicleState)),
            vehicleCountProvider.overrideWith((ref) => Future.value(1)),
            fuelEntriesNotifierProvider.overrideWith((ref) => AsyncValue.data(FuelEntryState(entries: []))),
            fuelEntriesByVehicleProvider(1).overrideWith((ref) => Future.value([])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VehiclesScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open popup menu and select delete
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Vehicle'), findsOneWidget);
      expect(find.text('Are you sure you want to delete "Test Vehicle"? This action cannot be undone.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsAtLeastOneWidget);
    });

    testWidgets('Should show edit vehicle dialog', (tester) async {
      final testVehicle = VehicleModel(
        id: 1,
        name: 'Test Vehicle',
        initialKm: 50000,
        createdAt: DateTime.now(),
      );

      final vehicleState = VehicleState(vehicles: [testVehicle]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehiclesNotifierProvider.overrideWith((ref) => AsyncValue.data(vehicleState)),
            vehicleCountProvider.overrideWith((ref) => Future.value(1)),
            fuelEntriesNotifierProvider.overrideWith((ref) => AsyncValue.data(FuelEntryState(entries: []))),
            fuelEntriesByVehicleProvider(1).overrideWith((ref) => Future.value([])),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VehiclesScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open popup menu and select edit
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Vehicle'), findsOneWidget);
      expect(find.text('Update Vehicle'), findsOneWidget);
      
      // Check that fields are pre-populated
      expect(find.text('Test Vehicle'), findsOneWidget);
      expect(find.text('50000.0'), findsOneWidget);
    });

    testWidgets('Should display error state correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehiclesNotifierProvider.overrideWith((ref) => AsyncValue.error('Database error', StackTrace.current)),
            vehicleCountProvider.overrideWith((ref) => Future.value(0)),
            fuelEntriesNotifierProvider.overrideWith((ref) => AsyncValue.data(FuelEntryState(entries: []))),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VehiclesScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Error loading vehicles'), findsOneWidget);
      expect(find.text('Database error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('Should display vehicle statistics with fuel entries', (tester) async {
      final testVehicle = VehicleModel(
        id: 1,
        name: 'Test Vehicle',
        initialKm: 50000,
        createdAt: DateTime.now(),
      );

      final testEntries = [
        FuelEntryModel(
          id: 1,
          vehicleId: 1,
          currentKm: 51000,
          liters: 45.0,
          pricePerLiter: 1.50,
          totalCost: 67.50,
          country: 'Test Country',
          fuelDate: DateTime.now(),
          consumption: 9.0,
        ),
        FuelEntryModel(
          id: 2,
          vehicleId: 1,
          currentKm: 52000,
          liters: 46.0,
          pricePerLiter: 1.55,
          totalCost: 71.30,
          country: 'Test Country',
          fuelDate: DateTime.now(),
          consumption: 8.5,
        ),
      ];

      final vehicleState = VehicleState(vehicles: [testVehicle]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehiclesNotifierProvider.overrideWith((ref) => AsyncValue.data(vehicleState)),
            vehicleCountProvider.overrideWith((ref) => Future.value(1)),
            fuelEntriesNotifierProvider.overrideWith((ref) => AsyncValue.data(FuelEntryState(entries: testEntries))),
            fuelEntriesByVehicleProvider(1).overrideWith((ref) => Future.value(testEntries)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: VehiclesScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget); // Vehicle count
      expect(find.text('2'), findsOneWidget); // Entry count
      expect(find.text('Entries: 2 • Avg: 8.8L/100km'), findsOneWidget); // Average consumption
    });
  });
}