import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/database_providers.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/database/database_service.dart';
import 'package:petrol_tracker/database/database.dart';

void main() {
  group('Fuel Entry Providers Tests', () {
    late ProviderContainer container;
    late AppDatabase testDatabase;
    late int testVehicleId;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      testDatabase = AppDatabase.memory();
      await testDatabase.clearAllData();

      // Create container without overrides for now - use in-memory database
      container = ProviderContainer();

      // Create a test vehicle for fuel entries
      final vehicleRepository = container.read(vehicleRepositoryProvider);
      final vehicle = VehicleModel.create(
        name: 'Test Vehicle',
        initialKm: 50000.0,
      );
      testVehicleId = await vehicleRepository.insertVehicle(vehicle);
    });

    tearDown(() async {
      container.dispose();
      await testDatabase.close();
    });

    group('FuelEntryState', () {
      test('default constructor creates empty state', () {
        const state = FuelEntryState();
        expect(state.entries, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('copyWith updates fields correctly', () {
        const state = FuelEntryState();
        final entry = FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 1000,
          fuelAmount: 40,
          price: 60,
          country: 'Canada',
          pricePerLiter: 1.5,
        );
        
        final newState = state.copyWith(
          entries: [entry],
          isLoading: true,
          error: 'test error',
        );

        expect(newState.entries, hasLength(1));
        expect(newState.isLoading, isTrue);
        expect(newState.error, equals('test error'));
      });

      test('equality works correctly', () {
        const state1 = FuelEntryState();
        const state2 = FuelEntryState();
        const state3 = FuelEntryState(isLoading: true);

        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });
    });

    group('FuelEntriesNotifier', () {
      test('initial build loads empty entries list', () async {
        final state = await container.read(fuelEntriesNotifierProvider.future);

        expect(state.entries, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('addFuelEntry adds entry to state', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        final entry = FuelEntryModel.create(
          vehicleId: testVehicleId,
          date: DateTime(2024, 1, 15),
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          country: 'Canada',
          pricePerLiter: 1.45,
        );

        await notifier.addFuelEntry(entry);
        final state = await container.read(fuelEntriesNotifierProvider.future);

        expect(state.entries, hasLength(1));
        expect(state.entries.first.vehicleId, equals(testVehicleId));
        expect(state.entries.first.fuelAmount, equals(40.0));
        expect(state.entries.first.country, equals('Canada'));
        expect(state.entries.first.id, isNotNull);
        expect(state.error, isNull);
      });

      test('updateFuelEntry updates existing entry', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        // Add an entry first
        final entry = FuelEntryModel.create(
          vehicleId: testVehicleId,
          date: DateTime(2024, 1, 15),
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          country: 'Canada',
          pricePerLiter: 1.45,
        );
        await notifier.addFuelEntry(entry);
        
        var state = await container.read(fuelEntriesNotifierProvider.future);
        final addedEntry = state.entries.first;

        // Update the entry
        final updatedEntry = addedEntry.copyWith(fuelAmount: 45.0);
        await notifier.updateFuelEntry(updatedEntry);

        state = await container.read(fuelEntriesNotifierProvider.future);
        expect(state.entries, hasLength(1));
        expect(state.entries.first.fuelAmount, equals(45.0));
        expect(state.entries.first.id, equals(addedEntry.id));
      });

      test('updateFuelEntry throws error for entry without ID', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        final entry = FuelEntryModel.create(
          vehicleId: testVehicleId,
          date: DateTime.now(),
          currentKm: 1000,
          fuelAmount: 40,
          price: 60,
          country: 'Canada',
          pricePerLiter: 1.5,
        );

        expect(
          () => notifier.updateFuelEntry(entry),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('deleteFuelEntry removes entry from state', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        // Add an entry first
        final entry = FuelEntryModel.create(
          vehicleId: testVehicleId,
          date: DateTime(2024, 1, 15),
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          country: 'Canada',
          pricePerLiter: 1.45,
        );
        await notifier.addFuelEntry(entry);
        
        var state = await container.read(fuelEntriesNotifierProvider.future);
        final addedEntry = state.entries.first;

        // Delete the entry
        await notifier.deleteFuelEntry(addedEntry.id!);

        state = await container.read(fuelEntriesNotifierProvider.future);
        expect(state.entries, isEmpty);
      });

      test('refresh reloads entries from repository', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        final repository = container.read(fuelEntryRepositoryProvider);
        
        // Add entry directly to repository
        final entry = FuelEntryModel.create(
          vehicleId: testVehicleId,
          date: DateTime(2024, 1, 15),
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          country: 'Direct Insert',
          pricePerLiter: 1.45,
        );
        await repository.insertEntry(entry);

        // Refresh should load the directly inserted entry
        await notifier.refresh();
        final state = await container.read(fuelEntriesNotifierProvider.future);

        expect(state.entries, hasLength(1));
        expect(state.entries.first.country, equals('Direct Insert'));
      });

      test('clearError removes error from state', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        // Simulate error state
        const errorState = FuelEntryState(error: 'Test error');
        container.read(fuelEntriesNotifierProvider.notifier).state = 
            AsyncValue.data(errorState);

        notifier.clearError();
        final state = await container.read(fuelEntriesNotifierProvider.future);
        expect(state.error, isNull);
      });
    });

    group('Individual Fuel Entry Providers', () {
      late int entryId1, entryId2;

      setUp(() async {
        final repository = container.read(fuelEntryRepositoryProvider);
        
        // Add test entries
        final entry1 = FuelEntryModel.create(
          vehicleId: testVehicleId,
          date: DateTime(2024, 1, 15),
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          country: 'Canada',
          pricePerLiter: 1.45,
        );
        
        final entry2 = FuelEntryModel.create(
          vehicleId: testVehicleId,
          date: DateTime(2024, 1, 20),
          currentKm: 50600.0,
          fuelAmount: 42.0,
          price: 61.0,
          country: 'USA',
          pricePerLiter: 1.5,
        );

        entryId1 = await repository.insertEntry(entry1);
        entryId2 = await repository.insertEntry(entry2);
      });

      test('fuelEntriesByVehicle returns entries for specific vehicle', () async {
        final entries = await container.read(
          fuelEntriesByVehicleProvider(testVehicleId).future,
        );

        expect(entries, hasLength(2));
        expect(entries.every((e) => e.vehicleId == testVehicleId), isTrue);
      });

      test('fuelEntriesByDateRange filters by date correctly', () async {
        final entries = await container.read(
          fuelEntriesByDateRangeProvider(
            DateTime(2024, 1, 14),
            DateTime(2024, 1, 16),
          ).future,
        );

        expect(entries, hasLength(1));
        expect(entries.first.date.day, equals(15));
      });

      test('fuelEntriesByVehicleAndDateRange filters by both vehicle and date', () async {
        final entries = await container.read(
          fuelEntriesByVehicleAndDateRangeProvider(
            testVehicleId,
            DateTime(2024, 1, 19),
            DateTime(2024, 1, 21),
          ).future,
        );

        expect(entries, hasLength(1));
        expect(entries.first.date.day, equals(20));
        expect(entries.first.vehicleId, equals(testVehicleId));
      });

      test('latestFuelEntryForVehicle returns most recent entry', () async {
        final latestEntry = await container.read(
          latestFuelEntryForVehicleProvider(testVehicleId).future,
        );

        expect(latestEntry, isNotNull);
        expect(latestEntry!.date.day, equals(20)); // Most recent
        expect(latestEntry.currentKm, equals(50600.0));
      });

      test('fuelEntry returns specific entry by ID', () async {
        final entry = await container.read(fuelEntryProvider(entryId1).future);

        expect(entry, isNotNull);
        expect(entry!.id, equals(entryId1));
        expect(entry.country, equals('Canada'));
      });

      test('fuelEntryCount returns correct count', () async {
        final count = await container.read(fuelEntryCountProvider.future);
        expect(count, equals(2));
      });

      test('fuelEntryCountForVehicle returns correct count for vehicle', () async {
        final count = await container.read(
          fuelEntryCountForVehicleProvider(testVehicleId).future,
        );
        expect(count, equals(2));
      });

      test('fuelEntriesGroupedByCountry groups entries correctly', () async {
        final grouped = await container.read(
          fuelEntriesGroupedByCountryProvider.future,
        );

        expect(grouped.keys, containsAll(['Canada', 'USA']));
        expect(grouped['Canada'], hasLength(1));
        expect(grouped['USA'], hasLength(1));
      });

      test('averageConsumptionForVehicle calculates average correctly', () async {
        final avgConsumption = await container.read(
          averageConsumptionForVehicleProvider(testVehicleId).future,
        );

        expect(avgConsumption, isNotNull);
        // With the test data: 42L for 400km = 10.5 L/100km average
        expect(avgConsumption, closeTo(10.5, 0.1));
      });
    });
  });
}