import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:petrol_tracker/screens/fuel_entries_screen.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';

void main() {
  group('FuelEntriesScreen', () {
    late List<FuelEntryModel> testEntries;
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

      testEntries = [
        FuelEntryModel(
          id: 1,
          vehicleId: 1,
          date: DateTime(2024, 1, 15),
          currentKm: 15000,
          fuelAmount: 45.5,
          price: 70.50,
          country: 'Canada',
          pricePerLiter: 1.55,
          consumption: 8.5,
        ),
        FuelEntryModel(
          id: 2,
          vehicleId: 1,
          date: DateTime(2024, 1, 20),
          currentKm: 15500,
          fuelAmount: 40.0,
          price: 60.00,
          country: 'United States',
          pricePerLiter: 1.50,
          consumption: 8.0,
        ),
        FuelEntryModel(
          id: 3,
          vehicleId: 2,
          date: DateTime(2024, 1, 10),
          currentKm: 52000,
          fuelAmount: 80.0,
          price: 120.00,
          country: 'Canada',
          pricePerLiter: 1.50,
          consumption: 12.0,
        ),
      ];
    });

    Widget createTestWidget({
      List<Override> overrides = const [],
      int? vehicleFilter,
    }) {
      return ProviderScope(
        overrides: [
          fuelEntriesNotifierProvider.overrideWith(() {
            return MockFuelEntriesNotifier(testEntries);
          }),
          vehicleProvider(1).overrideWith((ref) async {
            return testVehicles.firstWhere((v) => v.id == 1);
          }),
          vehicleProvider(2).overrideWith((ref) async {
            return testVehicles.firstWhere((v) => v.id == 2);
          }),
          ...overrides,
        ],
        child: MaterialApp(
          home: FuelEntriesScreen(vehicleFilter: vehicleFilter),
        ),
      );
    }

    testWidgets('should build without errors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(FuelEntriesScreen), findsOneWidget);
      expect(find.text('Fuel Entries'), findsOneWidget);
    });

    testWidgets('should display entries list', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show all entries
      expect(find.byType(Card), findsNWidgets(3));
      expect(find.text('Test Car'), findsNWidgets(2));
      expect(find.text('Test Truck'), findsOneWidget);
    });

    testWidgets('should display empty state when no entries', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            fuelEntriesNotifierProvider.overrideWith(() {
              return MockFuelEntriesNotifier([]);
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Fuel Entries Yet'), findsOneWidget);
      expect(find.text('Add First Entry'), findsOneWidget);
    });

    testWidgets('should show search bar when search icon is tapped', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially no search bar
      expect(find.byType(TextField), findsNothing);

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search bar should appear
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search by vehicle, country, or date...'), findsOneWidget);
    });

    testWidgets('should filter entries by search query', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search for Canada
      await tester.enterText(find.byType(TextField), 'Canada');
      await tester.pumpAndSettle();

      // Should show only Canadian entries (2 entries)
      expect(find.byType(Card), findsNWidgets(2));
      expect(find.text('Canada'), findsNWidgets(2));
      expect(find.text('United States'), findsNothing);
    });

    testWidgets('should show sort options', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap sort menu
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      // Should show sort options
      expect(find.text('Sort by Date'), findsOneWidget);
      expect(find.text('Sort by Amount'), findsOneWidget);
      expect(find.text('Sort by Cost'), findsOneWidget);
      expect(find.text('Sort by Consumption'), findsOneWidget);
    });

    testWidgets('should show filter chips', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show time filter chips
      expect(find.text('This Week'), findsOneWidget);
      expect(find.text('This Month'), findsOneWidget);
      expect(find.text('This Year'), findsOneWidget);
    });

    testWidgets('should apply time filter', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on "This Month" filter
      await tester.tap(find.text('This Month'));
      await tester.pumpAndSettle();

      // Filter chip should be selected
      final thisMonthChip = tester.widget<FilterChip>(
        find.ancestor(
          of: find.text('This Month'),
          matching: find.byType(FilterChip),
        ),
      );
      expect(thisMonthChip.selected, isTrue);
    });

    testWidgets('should show filter dialog', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap filter icon
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Should show filter dialog
      expect(find.text('Filter Entries'), findsOneWidget);
      expect(find.text('Country'), findsOneWidget);
      expect(find.text('Date Range'), findsOneWidget);
    });

    testWidgets('should handle vehicle filter', (tester) async {
      await tester.pumpWidget(createTestWidget(vehicleFilter: 1));
      await tester.pumpAndSettle();

      // Should show only entries for vehicle 1 (2 entries)
      expect(find.byType(Card), findsNWidgets(2));
      expect(find.text('Test Car'), findsNWidgets(2));
      expect(find.text('Test Truck'), findsNothing);

      // Title should indicate vehicle entries
      expect(find.text('Vehicle Entries'), findsOneWidget);
    });

    testWidgets('should show entry details on tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on first entry card
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      // Should show entry details dialog
      expect(find.text('Entry Details'), findsOneWidget);
      expect(find.text('Vehicle'), findsOneWidget);
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Country'), findsOneWidget);
    });

    testWidgets('should show delete confirmation on swipe', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Swipe entry to delete
      await tester.drag(find.byType(Card).first, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Should show delete confirmation
      expect(find.text('Delete Entry'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this fuel entry?'), findsOneWidget);
    });

    testWidgets('should handle error state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            fuelEntriesNotifierProvider.overrideWith(() {
              return MockFuelEntriesNotifierWithError();
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // Should show error state
      expect(find.text('Error Loading Entries'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should handle loading state', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            fuelEntriesNotifierProvider.overrideWith(() {
              return MockFuelEntriesNotifierLoading();
            }),
          ],
        ),
      );
      await tester.pump(); // Don't settle to catch loading state

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should format dates correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show formatted dates
      expect(find.text('Jan 15, 2024'), findsOneWidget);
      expect(find.text('Jan 20, 2024'), findsOneWidget);
      expect(find.text('Jan 10, 2024'), findsOneWidget);
    });

    testWidgets('should show consumption values', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show consumption values
      expect(find.text('8.5 L/100km'), findsOneWidget);
      expect(find.text('8.0 L/100km'), findsOneWidget);
      expect(find.text('12.0 L/100km'), findsOneWidget);
    });

    testWidgets('should show price values', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show price values
      expect(find.text('\$70.50'), findsOneWidget);
      expect(find.text('\$60.00'), findsOneWidget);
      expect(find.text('\$120.00'), findsOneWidget);
    });

    testWidgets('should show floating action button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show FAB for adding new entry
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}

// Mock implementations for testing
class MockFuelEntriesNotifier extends FuelEntriesNotifier {
  final List<FuelEntryModel> entries;

  MockFuelEntriesNotifier(this.entries);

  @override
  Future<FuelEntryState> build() async {
    return FuelEntryState(entries: entries);
  }

  @override
  Future<void> deleteFuelEntry(int entryId) async {
    entries.removeWhere((entry) => entry.id == entryId);
    state = AsyncValue.data(FuelEntryState(entries: entries));
  }
}

class MockFuelEntriesNotifierWithError extends FuelEntriesNotifier {
  @override
  Future<FuelEntryState> build() async {
    throw Exception('Test error');
  }
}

class MockFuelEntriesNotifierLoading extends FuelEntriesNotifier {
  @override
  Future<FuelEntryState> build() async {
    // Never complete to simulate loading state
    return Future.delayed(const Duration(seconds: 10), () {
      return const FuelEntryState();
    });
  }
}