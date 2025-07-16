import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';

void main() {
  group('Ephemeral Fuel Entry Providers', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });
    
    group('FuelEntriesNotifier', () {
      test('should start with empty state', () async {
        final state = await container.read(fuelEntriesNotifierProvider.future);
        
        expect(state.entries, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });
      
      test('should add fuel entry to ephemeral storage', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        final entry = FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 10500.0,
          fuelAmount: 50.0,
          price: 72.50, // 50.0 * 1.45
          pricePerLiter: 1.45,
          country: 'Canada',
        );
        
        await notifier.addFuelEntry(entry);
        final state = await container.read(fuelEntriesNotifierProvider.future);
        
        expect(state.entries, hasLength(1));
        expect(state.entries.first.vehicleId, equals(1));
        expect(state.entries.first.fuelAmount, equals(50.0));
        expect(state.entries.first.id, isNotNull);
      });
      
      test('should update fuel entry in ephemeral storage', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        final entry = FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 10500.0,
          fuelAmount: 50.0,
          price: 72.50, // 50.0 * 1.45
          pricePerLiter: 1.45,
          country: 'Canada',
        );
        
        await notifier.addFuelEntry(entry);
        final state = await container.read(fuelEntriesNotifierProvider.future);
        final addedEntry = state.entries.first;
        
        final updatedEntry = addedEntry.copyWith(
          fuelAmount: 60.0,
          price: 90.00, // 60.0 * 1.50
          pricePerLiter: 1.50,
        );
        
        await notifier.updateFuelEntry(updatedEntry);
        final updatedState = await container.read(fuelEntriesNotifierProvider.future);
        
        expect(updatedState.entries, hasLength(1));
        expect(updatedState.entries.first.fuelAmount, equals(60.0));
        expect(updatedState.entries.first.pricePerLiter, equals(1.50));
        expect(updatedState.entries.first.id, equals(addedEntry.id));
      });
      
      test('should delete fuel entry from ephemeral storage', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        final entry = FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 10500.0,
          fuelAmount: 50.0,
          price: 72.50, // 50.0 * 1.45
          pricePerLiter: 1.45,
          country: 'Canada',
        );
        
        await notifier.addFuelEntry(entry);
        final state = await container.read(fuelEntriesNotifierProvider.future);
        final addedEntry = state.entries.first;
        
        await notifier.deleteFuelEntry(addedEntry.id!);
        final updatedState = await container.read(fuelEntriesNotifierProvider.future);
        
        expect(updatedState.entries, isEmpty);
      });
      
      test('should handle multiple fuel entries', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        final now = DateTime.now();
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 1,
          date: now.subtract(const Duration(days: 2)),
          currentKm: 10500.0,
          fuelAmount: 50.0,
          price: 72.50, // 50.0 * 1.45
          pricePerLiter: 1.45,
          country: 'Canada',
        ));
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 1,
          date: now.subtract(const Duration(days: 1)),
          currentKm: 10800.0,
          fuelAmount: 45.0,
          price: 67.50, // 45.0 * 1.50
          pricePerLiter: 1.50,
          country: 'Canada',
        ));
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 2,
          date: now,
          currentKm: 20000.0,
          fuelAmount: 60.0,
          price: 84.00, // 60.0 * 1.40
          pricePerLiter: 1.40,
          country: 'USA',
        ));
        
        final state = await container.read(fuelEntriesNotifierProvider.future);
        
        expect(state.entries, hasLength(3));
        
        // Should be sorted by date descending (newest first)
        expect(state.entries.first.date, equals(now));
        expect(state.entries.last.date, equals(now.subtract(const Duration(days: 2))));
      });
      
      test('should refresh fuel entries list', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 10500.0,
          fuelAmount: 50.0,
          price: 72.50, // 50.0 * 1.45
          pricePerLiter: 1.45,
          country: 'Canada',
        ));
        
        await notifier.refresh();
        final state = await container.read(fuelEntriesNotifierProvider.future);
        
        expect(state.entries, hasLength(1));
        expect(state.entries.first.vehicleId, equals(1));
      });
    });
    
    group('Individual Fuel Entry Providers', () {
      test('fuelEntriesByVehicle should filter by vehicle ID', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        final now = DateTime.now();
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 1,
          date: now,
          currentKm: 10500.0,
          fuelAmount: 50.0,
          price: 72.50, // 50.0 * 1.45
          pricePerLiter: 1.45,
          country: 'Canada',
        ));
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 2,
          date: now,
          currentKm: 20000.0,
          fuelAmount: 60.0,
          price: 84.00, // 60.0 * 1.40
          pricePerLiter: 1.40,
          country: 'USA',
        ));
        
        final vehicle1Entries = await container.read(
          fuelEntriesByVehicleProvider(1).future,
        );
        final vehicle2Entries = await container.read(
          fuelEntriesByVehicleProvider(2).future,
        );
        
        expect(vehicle1Entries, hasLength(1));
        expect(vehicle1Entries.first.vehicleId, equals(1));
        
        expect(vehicle2Entries, hasLength(1));
        expect(vehicle2Entries.first.vehicleId, equals(2));
      });
      
      test('fuelEntriesByDateRange should filter by date range', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        final twoDaysAgo = now.subtract(const Duration(days: 2));
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 1,
          date: twoDaysAgo,
          currentKm: 10500.0,
          fuelAmount: 50.0,
          price: 72.50, // 50.0 * 1.45
          pricePerLiter: 1.45,
          country: 'Canada',
        ));
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 1,
          date: yesterday,
          currentKm: 10800.0,
          fuelAmount: 45.0,
          price: 67.50, // 45.0 * 1.50
          pricePerLiter: 1.50,
          country: 'Canada',
        ));
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 1,
          date: now,
          currentKm: 11000.0,
          fuelAmount: 40.0,
          price: 62.00, // 40.0 * 1.55
          pricePerLiter: 1.55,
          country: 'Canada',
        ));
        
        final recentEntries = await container.read(
          fuelEntriesByDateRangeProvider(yesterday, now).future,
        );
        
        expect(recentEntries, hasLength(2));
        expect(recentEntries.every((e) => e.date.isAfter(twoDaysAgo)), isTrue);
      });
      
      test('fuelEntriesByVehicleAndDateRange should filter by both vehicle and date', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 1,
          date: yesterday,
          currentKm: 10500.0,
          fuelAmount: 50.0,
          price: 72.50, // 50.0 * 1.45
          pricePerLiter: 1.45,
          country: 'Canada',
        ));
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 1,
          date: now,
          currentKm: 10800.0,
          fuelAmount: 45.0,
          price: 67.50, // 45.0 * 1.50
          pricePerLiter: 1.50,
          country: 'Canada',
        ));
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 2,
          date: now,
          currentKm: 20000.0,
          fuelAmount: 60.0,
          price: 84.00, // 60.0 * 1.40
          pricePerLiter: 1.40,
          country: 'USA',
        ));
        
        final filteredEntries = await container.read(
          fuelEntriesByVehicleAndDateRangeProvider(1, yesterday, now).future,
        );
        
        expect(filteredEntries, hasLength(2));
        expect(filteredEntries.every((e) => e.vehicleId == 1), isTrue);
      });
      
      test('latestFuelEntryForVehicle should return most recent entry', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 1,
          date: yesterday,
          currentKm: 10500.0,
          fuelAmount: 50.0,
          price: 72.50, // 50.0 * 1.45
          pricePerLiter: 1.45,
          country: 'Canada',
        ));
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 1,
          date: now,
          currentKm: 10800.0,
          fuelAmount: 45.0,
          price: 67.50, // 45.0 * 1.50
          pricePerLiter: 1.50,
          country: 'Canada',
        ));
        
        final latestEntry = await container.read(
          latestFuelEntryForVehicleProvider(1).future,
        );
        
        expect(latestEntry, isNotNull);
        expect(latestEntry!.date, equals(now));
        expect(latestEntry.currentKm, equals(10800.0));
      });
      
      test('latestFuelEntryForVehicle should return null for non-existent vehicle', () async {
        final latestEntry = await container.read(
          latestFuelEntryForVehicleProvider(999).future,
        );
        
        expect(latestEntry, isNull);
      });
      
      test('fuelEntry should return entry by ID', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        final entry = FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 10500.0,
          fuelAmount: 50.0,
          price: 72.50, // 50.0 * 1.45
          pricePerLiter: 1.45,
          country: 'Canada',
        );
        
        await notifier.addFuelEntry(entry);
        final state = await container.read(fuelEntriesNotifierProvider.future);
        final addedEntry = state.entries.first;
        
        final retrievedEntry = await container.read(
          fuelEntryProvider(addedEntry.id!).future,
        );
        
        expect(retrievedEntry, isNotNull);
        expect(retrievedEntry!.vehicleId, equals(1));
        expect(retrievedEntry.id, equals(addedEntry.id));
      });
      
      test('fuelEntryCount should return correct count', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        expect(await container.read(fuelEntryCountProvider.future), equals(0));
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 10500.0,
          fuelAmount: 50.0,
          price: 72.50, // 50.0 * 1.45
          pricePerLiter: 1.45,
          country: 'Canada',
        ));
        
        expect(await container.read(fuelEntryCountProvider.future), equals(1));
      });
      
      test('fuelEntryCountForVehicle should return count for specific vehicle', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 10500.0,
          fuelAmount: 50.0,
          price: 72.50, // 50.0 * 1.45
          pricePerLiter: 1.45,
          country: 'Canada',
        ));
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 2,
          date: DateTime.now(),
          currentKm: 20000.0,
          fuelAmount: 60.0,
          price: 84.00, // 60.0 * 1.40
          pricePerLiter: 1.40,
          country: 'USA',
        ));
        
        expect(await container.read(fuelEntryCountForVehicleProvider(1).future), equals(1));
        expect(await container.read(fuelEntryCountForVehicleProvider(2).future), equals(1));
        expect(await container.read(fuelEntryCountForVehicleProvider(999).future), equals(0));
      });
      
      test('fuelEntriesGroupedByCountry should group entries by country', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 10500.0,
          fuelAmount: 50.0,
          price: 72.50, // 50.0 * 1.45
          pricePerLiter: 1.45,
          country: 'Canada',
        ));
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 10800.0,
          fuelAmount: 45.0,
          price: 67.50, // 45.0 * 1.50
          pricePerLiter: 1.50,
          country: 'Canada',
        ));
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 2,
          date: DateTime.now(),
          currentKm: 20000.0,
          fuelAmount: 60.0,
          price: 84.00, // 60.0 * 1.40
          pricePerLiter: 1.40,
          country: 'USA',
        ));
        
        final groupedEntries = await container.read(
          fuelEntriesGroupedByCountryProvider.future,
        );
        
        expect(groupedEntries.keys, containsAll(['Canada', 'USA']));
        expect(groupedEntries['Canada'], hasLength(2));
        expect(groupedEntries['USA'], hasLength(1));
      });
      
      test('averageConsumptionForVehicle should calculate average consumption', () async {
        final notifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 10500.0,
          fuelAmount: 50.0,
          price: 72.50, // 50.0 * 1.45
          pricePerLiter: 1.45,
          country: 'Canada',
          consumption: 7.5,
        ));
        
        await notifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 10800.0,
          fuelAmount: 45.0,
          price: 67.50, // 45.0 * 1.50
          pricePerLiter: 1.50,
          country: 'Canada',
          consumption: 8.0,
        ));
        
        final averageConsumption = await container.read(
          averageConsumptionForVehicleProvider(1).future,
        );
        
        expect(averageConsumption, equals(7.75)); // (7.5 + 8.0) / 2
      });
      
      test('averageConsumptionForVehicle should return null for no entries', () async {
        final averageConsumption = await container.read(
          averageConsumptionForVehicleProvider(999).future,
        );
        
        expect(averageConsumption, isNull);
      });
    });
  });
}