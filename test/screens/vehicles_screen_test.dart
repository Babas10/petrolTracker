import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/screens/vehicles_screen.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';

void main() {
  group('VehiclesScreen', () {
    late List<VehicleModel> testVehicles;

    setUp(() {
      testVehicles = [
        VehicleModel(
          id: 1,
          name: 'Test Car',
          initialKm: 10000,
          createdAt: DateTime.now(),
        ),
        VehicleModel(
          id: 2,
          name: 'Test Truck',
          initialKm: 50000,
          createdAt: DateTime.now(),
        ),
      ];
    });

    Widget createTestWidget({
      List<Override> overrides = const [],
    }) {
      return ProviderScope(
        overrides: [
          vehiclesNotifierProvider.overrideWith(() {
            return MockVehiclesNotifier(testVehicles);
          }),
          vehicleCountProvider.overrideWith((ref) async => testVehicles.length),
          fuelEntriesNotifierProvider.overrideWith(() {
            return MockFuelEntriesNotifier();
          }),
          ...overrides,
        ],
        child: const MaterialApp(
          home: VehiclesScreen(),
        ),
      );
    }

    testWidgets('should build without errors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(VehiclesScreen), findsOneWidget);
      expect(find.text('Vehicles'), findsOneWidget);
    });

    testWidgets('should display vehicles list', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show vehicle statistics
      expect(find.text('Total Vehicles'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);

      // Should show vehicles in list
      expect(find.text('Test Car'), findsOneWidget);
      expect(find.text('Test Truck'), findsOneWidget);
    });

    testWidgets('should display empty state when no vehicles', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            vehiclesNotifierProvider.overrideWith(() {
              return MockVehiclesNotifier([]);
            }),
            vehicleCountProvider.overrideWith((ref) async => 0),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Vehicles Yet'), findsOneWidget);
      expect(find.text('Add First Vehicle'), findsOneWidget);
    });

    testWidgets('should show add vehicle dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap FAB to open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should show add vehicle dialog
      expect(find.text('Add New Vehicle'), findsOneWidget);
      expect(find.text('Vehicle Name'), findsOneWidget);
      expect(find.text('Initial Kilometers'), findsOneWidget);
    });

    testWidgets('should validate add vehicle form', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open add vehicle dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.text('Add Vehicle'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter a vehicle name'), findsOneWidget);
      expect(find.text('Please enter initial kilometers'), findsOneWidget);
    });

    testWidgets('should add vehicle with valid data', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open add vehicle dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill form with valid data
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Vehicle Name').first,
        'New Car',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Initial Kilometers').first,
        '15000',
      );

      // Submit form
      await tester.tap(find.text('Add Vehicle'));
      await tester.pumpAndSettle();

      // Dialog should close (verify by checking it's no longer present)
      expect(find.text('Add New Vehicle'), findsNothing);
    });

    testWidgets('should show error state with retry option', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            vehiclesNotifierProvider.overrideWith(() {
              return MockVehiclesNotifierWithError();
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Should show error state
      expect(find.text('Error Loading Vehicles'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should show database error state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            vehiclesNotifierProvider.overrideWith(() {
              return MockVehiclesNotifierDatabaseError();
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Should show database error state
      expect(find.text('Database Connection Issue'), findsOneWidget);
      expect(find.text('Help'), findsOneWidget);
      expect(find.byIcon(Icons.storage_outlined), findsOneWidget);
    });

    testWidgets('should show loading state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            vehiclesNotifierProvider.overrideWith(() {
              return MockVehiclesNotifierLoading();
            }),
          ],
        ),
      );
      await tester.pump(); // Don't settle to catch loading state

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading vehicles...'), findsOneWidget);
    });

    testWidgets('should show pull to refresh', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find the RefreshIndicator
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Trigger pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pump();

      // Should show refresh indicator
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('should show vehicle menu options', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on vehicle menu
      await tester.tap(find.byType(PopupMenuButton).first);
      await tester.pumpAndSettle();

      // Should show menu options
      expect(find.text('View Entries'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should show edit vehicle dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open vehicle menu and select edit
      await tester.tap(find.byType(PopupMenuButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Should show edit dialog with current values
      expect(find.text('Edit Vehicle'), findsOneWidget);
      expect(find.text('Test Car'), findsOneWidget);
    });

    testWidgets('should show delete confirmation dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open vehicle menu and select delete
      await tester.tap(find.byType(PopupMenuButton).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Should show delete confirmation
      expect(find.text('Delete Vehicle'), findsOneWidget);
      expect(find.text('Are you sure you want to delete "Test Car"?'), findsOneWidget);
    });

    testWidgets('should show operation in progress state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            vehiclesNotifierProvider.overrideWith(() {
              return MockVehiclesNotifierOperationInProgress();
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Should show operation in progress
      expect(find.text('Adding vehicle...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display floating action button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNWidgets(2)); // FAB + AppBar
    });
  });
}

// Mock implementations for testing
class MockVehiclesNotifier extends VehiclesNotifier {
  final List<VehicleModel> vehicles;

  MockVehiclesNotifier(this.vehicles);

  @override
  Future<VehicleState> build() async {
    return VehicleState(
      vehicles: vehicles,
      isDatabaseReady: true,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<void> addVehicle(VehicleModel vehicle) async {
    vehicles.add(vehicle.copyWith(id: vehicles.length + 1));
    state = AsyncValue.data(VehicleState(
      vehicles: vehicles,
      isDatabaseReady: true,
      lastUpdated: DateTime.now(),
    ));
  }

  @override
  Future<void> deleteVehicle(int vehicleId) async {
    vehicles.removeWhere((v) => v.id == vehicleId);
    state = AsyncValue.data(VehicleState(
      vehicles: vehicles,
      isDatabaseReady: true,
      lastUpdated: DateTime.now(),
    ));
  }
}

class MockVehiclesNotifierWithError extends VehiclesNotifier {
  @override
  Future<VehicleState> build() async {
    return const VehicleState(
      error: 'Test error occurred',
      isDatabaseReady: true,
    );
  }
}

class MockVehiclesNotifierDatabaseError extends VehiclesNotifier {
  @override
  Future<VehicleState> build() async {
    return const VehicleState(
      error: 'Database connection failed',
      isDatabaseReady: false,
    );
  }
}

class MockVehiclesNotifierLoading extends VehiclesNotifier {
  @override
  Future<VehicleState> build() async {
    // Never complete to simulate loading state
    return Future.delayed(const Duration(seconds: 10), () {
      return const VehicleState();
    });
  }
}

class MockVehiclesNotifierOperationInProgress extends VehiclesNotifier {
  @override
  Future<VehicleState> build() async {
    return const VehicleState(
      vehicles: [],
      currentOperation: VehicleOperation.adding,
      isDatabaseReady: true,
    );
  }
}

class MockFuelEntriesNotifier extends FuelEntriesNotifier {
  @override
  Future<FuelEntryState> build() async {
    return const FuelEntryState(entries: []);
  }
}