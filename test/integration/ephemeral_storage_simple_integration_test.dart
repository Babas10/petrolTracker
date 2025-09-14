import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';

void main() {
  group('Ephemeral Storage Integration Tests', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });
    
    group('Vehicle and Fuel Entry Integration', () {
      test('should add vehicle and fuel entries successfully', () async {
        final vehicleNotifier = container.read(vehiclesProvider.notifier);
        final fuelNotifier = container.read(fuelEntriesProvider.notifier);
        
        // Add a vehicle
        final vehicle = VehicleModel.create(
          name: 'Integration Test Vehicle ${DateTime.now().millisecondsSinceEpoch}',
          initialKm: 10000.0,
        );
        await vehicleNotifier.addVehicle(vehicle);
        
        // Get the added vehicle
        final vehicleState = await container.read(vehiclesProvider.future);
        final addedVehicle = vehicleState.vehicles.lastWhere(
          (v) => v.name.contains('Integration Test Vehicle')
        );
        
        expect(addedVehicle.name, contains('Integration Test Vehicle'));
        expect(addedVehicle.id, isNotNull);
        
        // Add fuel entries for this vehicle
        await fuelNotifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: addedVehicle.id!,
          date: DateTime.now().subtract(const Duration(days: 1)),
          currentKm: 10300.0,
          fuelAmount: 50.0,
          price: 75.0,
          pricePerLiter: 1.50,
          country: 'Canada',
        ));
        
        // Verify fuel entries exist for the vehicle
        final vehicleFuelEntries = await container.read(
          fuelEntriesByVehicleProvider(addedVehicle.id!).future,
        );
        
        expect(vehicleFuelEntries.length, greaterThanOrEqualTo(1));
        expect(vehicleFuelEntries.first.vehicleId, equals(addedVehicle.id));
      });
      
      test('should handle concurrent operations', () async {
        final vehicleNotifier = container.read(vehiclesProvider.notifier);
        final fuelNotifier = container.read(fuelEntriesProvider.notifier);
        
        // Add multiple vehicles
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final vehicles = [
          VehicleModel.create(name: 'Concurrent Vehicle A $timestamp', initialKm: 10000.0),
          VehicleModel.create(name: 'Concurrent Vehicle B $timestamp', initialKm: 20000.0),
          VehicleModel.create(name: 'Concurrent Vehicle C $timestamp', initialKm: 30000.0),
        ];
        
        await Future.wait(vehicles.map((v) => vehicleNotifier.addVehicle(v)));
        
        final vehicleState = await container.read(vehiclesProvider.future);
        final addedVehicles = vehicleState.vehicles.where(
          (v) => v.name.contains('Concurrent Vehicle') && v.name.contains('$timestamp')
        ).toList();
        
        expect(addedVehicles.length, equals(3));
        
        // Add fuel entries for each vehicle
        for (final vehicle in addedVehicles) {
          await fuelNotifier.addFuelEntry(FuelEntryModel.create(
            vehicleId: vehicle.id!,
            date: DateTime.now(),
            currentKm: vehicle.initialKm + 500.0,
            fuelAmount: 50.0,
            price: 75.0,
            pricePerLiter: 1.50,
            country: 'Canada',
          ));
        }
        
        // Verify each vehicle has its fuel entry
        for (final vehicle in addedVehicles) {
          final vehicleFuelEntries = await container.read(
            fuelEntriesByVehicleProvider(vehicle.id!).future,
          );
          expect(vehicleFuelEntries.length, greaterThanOrEqualTo(1));
          expect(vehicleFuelEntries.first.vehicleId, equals(vehicle.id));
        }
      });
    });
    
    group('Data Persistence', () {
      test('should persist data across container instances', () async {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        
        // Add data with first container
        final vehicleNotifier = container.read(vehiclesProvider.notifier);
        await vehicleNotifier.addVehicle(VehicleModel.create(
          name: 'Persistent Vehicle $timestamp',
          initialKm: 10000.0,
        ));
        
        // Create second container and verify data persists
        final container2 = ProviderContainer();
        final vehicleState2 = await container2.read(vehiclesProvider.future);
        
        final persistentVehicle = vehicleState2.vehicles.where(
          (v) => v.name == 'Persistent Vehicle $timestamp'
        ).toList();
        
        expect(persistentVehicle.length, equals(1));
        expect(persistentVehicle.first.name, equals('Persistent Vehicle $timestamp'));
        
        container2.dispose();
      });
      
      test('should handle provider refresh', () async {
        final vehicleNotifier = container.read(vehiclesProvider.notifier);
        final fuelNotifier = container.read(fuelEntriesProvider.notifier);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        
        // Add test data
        final vehicle = VehicleModel.create(
          name: 'Refresh Test Vehicle $timestamp',
          initialKm: 10000.0,
        );
        await vehicleNotifier.addVehicle(vehicle);
        
        final vehicleState = await container.read(vehiclesProvider.future);
        final addedVehicle = vehicleState.vehicles.where(
          (v) => v.name == 'Refresh Test Vehicle $timestamp'
        ).first;
        
        await fuelNotifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: addedVehicle.id!,
          date: DateTime.now(),
          currentKm: 10300.0,
          fuelAmount: 50.0,
          price: 75.0,
          pricePerLiter: 1.50,
          country: 'Canada',
        ));
        
        // Refresh both providers
        await vehicleNotifier.refresh();
        await fuelNotifier.refresh();
        
        // Verify data consistency
        final refreshedVehicleState = await container.read(vehiclesProvider.future);
        final refreshedFuelState = await container.read(fuelEntriesProvider.future);
        
        expect(refreshedVehicleState.vehicles.any((v) => v.id == addedVehicle.id), isTrue);
        expect(refreshedFuelState.entries.any((e) => e.vehicleId == addedVehicle.id), isTrue);
      });
    });
    
    group('Provider Functionality', () {
      test('should handle vehicle operations correctly', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        
        // Add a vehicle
        final vehicle = VehicleModel.create(
          name: 'Provider Test Vehicle $timestamp',
          initialKm: 10000.0,
        );
        await notifier.addVehicle(vehicle);
        
        // Get the added vehicle
        final vehicleState = await container.read(vehiclesProvider.future);
        final addedVehicle = vehicleState.vehicles.where(
          (v) => v.name == 'Provider Test Vehicle $timestamp'
        ).first;
        
        // Test vehicle provider
        final retrievedVehicle = await container.read(vehicleProvider(addedVehicle.id!).future);
        expect(retrievedVehicle, isNotNull);
        expect(retrievedVehicle!.name, equals('Provider Test Vehicle $timestamp'));
        
        // Test vehicle name exists
        final nameExists = await container.read(
          vehicleNameExistsProvider('Provider Test Vehicle $timestamp').future,
        );
        expect(nameExists, isTrue);
        
        // Test update
        final updatedVehicle = addedVehicle.copyWith(
          name: 'Updated Provider Test Vehicle $timestamp',
          initialKm: 15000.0,
        );
        await notifier.updateVehicle(updatedVehicle);
        
        final updatedState = await container.read(vehiclesProvider.future);
        final finalVehicle = updatedState.vehicles.where(
          (v) => v.id == addedVehicle.id
        ).first;
        
        expect(finalVehicle.name, equals('Updated Provider Test Vehicle $timestamp'));
        expect(finalVehicle.initialKm, equals(15000.0));
      });
      
      test('should handle fuel entry operations correctly', () async {
        final vehicleNotifier = container.read(vehiclesProvider.notifier);
        final fuelNotifier = container.read(fuelEntriesProvider.notifier);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        
        // Add a vehicle
        final vehicle = VehicleModel.create(
          name: 'Fuel Test Vehicle $timestamp',
          initialKm: 10000.0,
        );
        await vehicleNotifier.addVehicle(vehicle);
        
        final vehicleState = await container.read(vehiclesProvider.future);
        final addedVehicle = vehicleState.vehicles.where(
          (v) => v.name == 'Fuel Test Vehicle $timestamp'
        ).first;
        
        // Add fuel entry
        await fuelNotifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: addedVehicle.id!,
          date: DateTime.now(),
          currentKm: 10300.0,
          fuelAmount: 50.0,
          price: 75.0,
          pricePerLiter: 1.50,
          country: 'Canada',
        ));
        
        // Test fuel entry providers
        final vehicleFuelEntries = await container.read(
          fuelEntriesByVehicleProvider(addedVehicle.id!).future,
        );
        expect(vehicleFuelEntries.length, greaterThanOrEqualTo(1));
        
        final latestEntry = await container.read(
          latestFuelEntryForVehicleProvider(addedVehicle.id!).future,
        );
        expect(latestEntry, isNotNull);
        expect(latestEntry!.vehicleId, equals(addedVehicle.id));
        
        final fuelEntryCount = await container.read(
          fuelEntryCountForVehicleProvider(addedVehicle.id!).future,
        );
        expect(fuelEntryCount, greaterThanOrEqualTo(1));
      });
    });
  });
}