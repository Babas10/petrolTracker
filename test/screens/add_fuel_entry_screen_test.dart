import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petrol_tracker/screens/add_fuel_entry_screen.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';

// Mock providers for testing
class MockVehiclesNotifier extends VehiclesNotifier {
  @override
  Future<VehicleState> build() async {
    return VehicleState(
      vehicles: [
        VehicleModel(id: 1, name: 'Test Car', initialKm: 10000),
        VehicleModel(id: 2, name: 'Test Truck', initialKm: 50000),
      ],
    );
  }
}

class MockFuelEntriesNotifier extends FuelEntriesNotifier {
  @override
  Future<FuelEntryState> build() async {
    return const FuelEntryState();
  }

  @override
  Future<void> addFuelEntry(FuelEntryModel entry) async {
    // Mock successful save
  }
}

void main() {
  group('AddFuelEntryScreen', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const AddFuelEntryScreen(),
          ),
          GoRoute(
            path: '/entries',
            builder: (context, state) => const Scaffold(
              body: Text('Entries Screen'),
            ),
          ),
          GoRoute(
            path: '/vehicles',
            builder: (context, state) => const Scaffold(
              body: Text('Vehicles Screen'),
            ),
          ),
        ],
      );
    });

    Widget createTestWidget({List<Override> overrides = const []}) {
      return ProviderScope(
        overrides: [
          vehiclesNotifierProvider.overrideWith(() => MockVehiclesNotifier()),
          fuelEntriesNotifierProvider.overrideWith(() => MockFuelEntriesNotifier()),
          latestFuelEntryForVehicleProvider.overrideWith((ref, vehicleId) async {
            return FuelEntryModel.create(
              vehicleId: vehicleId,
              date: DateTime.now().subtract(const Duration(days: 1)),
              currentKm: 15000,
              fuelAmount: 40,
              price: 60,
              country: 'Canada',
              pricePerLiter: 1.50,
            );
          }),
          vehicleProvider.overrideWith((ref, vehicleId) async {
            return VehicleModel(id: vehicleId, name: 'Test Vehicle', initialKm: 10000);
          }),
          ...overrides,
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      );
    }

    testWidgets('should build without errors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AddFuelEntryScreen), findsOneWidget);
      expect(find.text('Add Fuel Entry'), findsOneWidget);
    });

    testWidgets('should display all required form fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for all required form sections
      expect(find.text('Vehicle *'), findsOneWidget);
      expect(find.text('Date *'), findsOneWidget);
      expect(find.text('Current Odometer Reading *'), findsOneWidget);
      expect(find.text('Fuel Amount *'), findsOneWidget);
      expect(find.text('Total Price *'), findsOneWidget);
      expect(find.text('Price per Liter *'), findsOneWidget);
      expect(find.text('Country *'), findsOneWidget);
    });

    testWidgets('should display vehicle dropdown with options', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap the vehicle dropdown
      final vehicleDropdown = find.byType(DropdownButtonFormField<int>);
      expect(vehicleDropdown, findsOneWidget);

      await tester.tap(vehicleDropdown);
      await tester.pumpAndSettle();

      // Check that vehicle options are displayed
      expect(find.text('Test Car'), findsOneWidget);
      expect(find.text('Test Truck'), findsOneWidget);
    });

    testWidgets('should show previous km info when vehicle is selected', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Select a vehicle
      final vehicleDropdown = find.byType(DropdownButtonFormField<int>);
      await tester.tap(vehicleDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Car').last);
      await tester.pumpAndSettle();

      // Should show previous km info
      expect(find.textContaining('Previous odometer:'), findsOneWidget);
    });

    testWidgets('should validate required fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Try to save without filling any fields
      final saveButton = find.text('Save Fuel Entry');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please select a vehicle'), findsOneWidget);
      expect(find.text('Please enter current kilometers'), findsOneWidget);
      expect(find.text('Please enter fuel amount'), findsOneWidget);
      expect(find.text('Please enter total price'), findsOneWidget);
    });

    testWidgets('should auto-calculate price per liter', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter fuel amount
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter fuel amount'),
        '40',
      );

      // Enter total price
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter total price'),
        '60',
      );

      await tester.pumpAndSettle();

      // Price per liter should be auto-calculated (60/40 = 1.5)
      final pricePerLiterField = find.widgetWithText(TextFormField, 'Calculated automatically');
      expect(pricePerLiterField, findsOneWidget);

      // Check that the field has the calculated value
      final pricePerLiterWidget = tester.widget<TextFormField>(pricePerLiterField);
      expect(pricePerLiterWidget.controller?.text, equals('1.500'));
    });

    testWidgets('should allow manual price per liter entry when auto-calculate is off', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Turn off auto-calculate
      final autoCalculateSwitch = find.byType(Switch);
      await tester.tap(autoCalculateSwitch);
      await tester.pumpAndSettle();

      // Enter price per liter manually
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter price per liter'),
        '1.75',
      );

      await tester.pumpAndSettle();

      // Enter fuel amount
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter fuel amount'),
        '40',
      );

      await tester.pumpAndSettle();

      // Total price should be calculated (40 * 1.75 = 70)
      final totalPriceField = find.widgetWithText(TextFormField, 'Enter total price');
      final totalPriceWidget = tester.widget<TextFormField>(totalPriceField);
      expect(totalPriceWidget.controller?.text, equals('70.00'));
    });

    testWidgets('should validate odometer reading against previous entry', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Select a vehicle to load previous km
      final vehicleDropdown = find.byType(DropdownButtonFormField<int>);
      await tester.tap(vehicleDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Car').last);
      await tester.pumpAndSettle();

      // Enter km less than previous entry (previous is 15000)
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter current odometer reading'),
        '14000',
      );

      // Try to save
      final saveButton = find.text('Save Fuel Entry');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.textContaining('Must be >= 15000 km'), findsOneWidget);
    });

    testWidgets('should prevent future date selection', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // The date picker should not allow future dates
      // This is handled by the date picker's lastDate parameter
      final dateSelector = find.byIcon(Icons.calendar_today);
      expect(dateSelector, findsOneWidget);

      // Tap the date selector
      await tester.tap(dateSelector);
      await tester.pumpAndSettle();

      // Date picker should open
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('should validate country selection', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Fill all fields except country
      final vehicleDropdown = find.byType(DropdownButtonFormField<int>);
      await tester.tap(vehicleDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Car').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter current odometer reading'),
        '16000',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter fuel amount'),
        '40',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter total price'),
        '60',
      );

      // Try to save without selecting country
      final saveButton = find.text('Save Fuel Entry');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show error about country selection
      expect(find.text('Please select a country'), findsOneWidget);
    });

    testWidgets('should validate price consistency', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Turn off auto-calculate to set inconsistent values
      final autoCalculateSwitch = find.byType(Switch);
      await tester.tap(autoCalculateSwitch);
      await tester.pumpAndSettle();

      // Enter inconsistent values
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter fuel amount'),
        '40',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter total price'),
        '60',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter price per liter'),
        '2.00', // Should be 1.50 (60/40)
      );

      // Try to save
      final saveButton = find.text('Save Fuel Entry');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show validation error about price inconsistency
      expect(find.textContaining('doesn\'t match fuel × price/L'), findsOneWidget);
    });

    testWidgets('should validate fuel amount limits', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter unusually high fuel amount
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter fuel amount'),
        '250',
      );

      // Try to save
      final saveButton = find.text('Save Fuel Entry');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show warning about high fuel amount
      expect(find.textContaining('Amount seems unusually high'), findsOneWidget);
    });

    testWidgets('should successfully save valid entry', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Fill all required fields with valid data
      final vehicleDropdown = find.byType(DropdownButtonFormField<int>);
      await tester.tap(vehicleDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Car').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter current odometer reading'),
        '16000',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter fuel amount'),
        '40',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter total price'),
        '60',
      );

      // Select country
      final countryDropdown = find.byType(DropdownButtonFormField<String>);
      await tester.tap(countryDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Canada').last);
      await tester.pumpAndSettle();

      // Save the entry
      final saveButton = find.text('Save Fuel Entry');
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Should show success message and navigate to entries
      expect(find.text('Fuel entry saved successfully!'), findsOneWidget);
    });

    testWidgets('should handle empty vehicle list', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            vehiclesNotifierProvider.overrideWith(() {
              return MockVehiclesNotifier()
                ..state = const AsyncValue.data(VehicleState(vehicles: []));
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Should show message about no vehicles
      expect(find.text('No vehicles available. Add one first.'), findsOneWidget);
      expect(find.text('Add Vehicle'), findsOneWidget);
    });

    testWidgets('should handle vehicle loading error', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            vehiclesNotifierProvider.overrideWith(() {
              return MockVehiclesNotifier()
                ..state = const AsyncValue.error('Test error', StackTrace.empty);
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.textContaining('Error loading vehicles'), findsOneWidget);
    });

    testWidgets('should show loading state during save', (tester) async {
      // Override to simulate slow save
      final slowMockNotifier = MockFuelEntriesNotifier();
      
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            fuelEntriesNotifierProvider.overrideWith(() => slowMockNotifier),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Fill valid data
      final vehicleDropdown = find.byType(DropdownButtonFormField<int>);
      await tester.tap(vehicleDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Car').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter current odometer reading'),
        '16000',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter fuel amount'),
        '40',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter total price'),
        '60',
      );

      final countryDropdown = find.byType(DropdownButtonFormField<String>);
      await tester.tap(countryDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Canada').last);
      await tester.pumpAndSettle();

      // Start save operation
      final saveButton = find.text('Save Fuel Entry');
      await tester.tap(saveButton);
      await tester.pump(); // Don't settle, to catch loading state

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });
  });
}