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
      test('should maintain data consistency across vehicle and fuel entry providers', () async {
        final vehicleNotifier = container.read(vehiclesNotifierProvider.notifier);
        final fuelNotifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        // Add a vehicle
        final vehicle = VehicleModel.create(
          name: 'Integration Test Vehicle',
          initialKm: 10000.0,
        );
        await vehicleNotifier.addVehicle(vehicle);
        
        // Get the added vehicle
        final vehicleState = await container.read(vehiclesNotifierProvider.future);
        final addedVehicle = vehicleState.vehicles.where(
          (v) => v.name == 'Integration Test Vehicle'
        ).first;
        
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
        
        await fuelNotifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: addedVehicle.id!,
          date: DateTime.now(),
          currentKm: 10600.0,
          fuelAmount: 45.0,
          price: 67.50,
          pricePerLiter: 1.50,
          country: 'Canada',
        ));
        
        // Verify fuel entries exist for the vehicle
        final vehicleFuelEntries = await container.read(
          fuelEntriesByVehicleProvider(addedVehicle.id!).future,
        );
        
        expect(vehicleFuelEntries.length, greaterThanOrEqualTo(2));
        expect(vehicleFuelEntries.every((entry) => entry.vehicleId == addedVehicle.id), isTrue);
        
        // Delete the vehicle and verify orphaned fuel entries
        await vehicleNotifier.deleteVehicle(addedVehicle.id!);
        
        // Fuel entries should still exist in storage but vehicle should be gone
        final updatedVehicleState = await container.read(vehiclesNotifierProvider.future);
        expect(updatedVehicleState.vehicles.any((v) => v.id == addedVehicle.id), isFalse);
        
        final orphanedEntries = await container.read(
          fuelEntriesByVehicleProvider(addedVehicle.id!).future,
        );
        expect(orphanedEntries.length, greaterThanOrEqualTo(2));
      });
      
      test('should handle concurrent operations on different vehicles', () async {
        final vehicleNotifier = container.read(vehiclesNotifierProvider.notifier);
        final fuelNotifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        // Add multiple vehicles concurrently
        final vehicles = [
          VehicleModel.create(name: 'Vehicle A', initialKm: 10000.0),
          VehicleModel.create(name: 'Vehicle B', initialKm: 20000.0),
          VehicleModel.create(name: 'Vehicle C', initialKm: 30000.0),
        ];
        
        await Future.wait(vehicles.map((v) => vehicleNotifier.addVehicle(v)));
        
        final vehicleState = await container.read(vehiclesNotifierProvider.future);
        final addedVehicles = vehicleState.vehicles.where(
          (v) => ['Vehicle A', 'Vehicle B', 'Vehicle C'].contains(v.name)
        ).toList();
        
        expect(addedVehicles.length, greaterThanOrEqualTo(3));
        
        // Add fuel entries for each vehicle concurrently
        final fuelEntries = addedVehicles.map((vehicle) => 
          FuelEntryModel.create(
            vehicleId: vehicle.id!,
            date: DateTime.now(),
            currentKm: vehicle.initialKm + 500.0,
            fuelAmount: 50.0,
            price: 75.0,
            pricePerLiter: 1.50,
            country: 'Canada',
          )
        ).toList();
        
        await Future.wait(fuelEntries.map((entry) => fuelNotifier.addFuelEntry(entry)));
        
        // Verify each vehicle has its fuel entry
        for (final vehicle in addedVehicles) {
          final vehicleFuelEntries = await container.read(
            fuelEntriesByVehicleProvider(vehicle.id!).future,
          );
          expect(vehicleFuelEntries.length, greaterThanOrEqualTo(1));
        }
      });
    });
    
    group('Data Persistence During Session', () {
      test('should maintain data across multiple provider container instances', () async {
        // Add data with first container
        final vehicleNotifier = container.read(vehiclesNotifierProvider.notifier);
        await vehicleNotifier.addVehicle(VehicleModel.create(
          name: 'Persistent Vehicle',
          initialKm: 10000.0,
        ));
        
        // Create second container and verify data persists
        final container2 = ProviderContainer();
        final vehicleState2 = await container2.read(vehiclesNotifierProvider.future);
        
        expect(vehicleState2.vehicles.any((v) => v.name == 'Persistent Vehicle'), isTrue);
        
        container2.dispose();
      });
      
      test('should handle large datasets efficiently', () async {
        final vehicleNotifier = container.read(vehiclesNotifierProvider.notifier);
        final fuelNotifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        // Add a vehicle for testing
        final vehicle = VehicleModel.create(
          name: 'Performance Test Vehicle',
          initialKm: 10000.0,
        );
        await vehicleNotifier.addVehicle(vehicle);
        
        final vehicleState = await container.read(vehiclesNotifierProvider.future);
        final addedVehicle = vehicleState.vehicles.where(
          (v) => v.name == 'Performance Test Vehicle'
        ).first;
        
        // Add many fuel entries
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 100; i++) {
          await fuelNotifier.addFuelEntry(FuelEntryModel.create(
            vehicleId: addedVehicle.id!,
            date: DateTime.now().subtract(Duration(days: i)),
            currentKm: 10000.0 + (i * 300.0),
            fuelAmount: 50.0,
            price: 75.0,
            pricePerLiter: 1.50,
            country: 'Canada',
          ));
        }
        
        stopwatch.stop();
        
        // Verify all entries were added
        final vehicleFuelEntries = await container.read(
          fuelEntriesByVehicleProvider(addedVehicle.id!).future,
        );
        
        expect(vehicleFuelEntries.length, greaterThanOrEqualTo(100));
        
        // Performance should be reasonable (less than 5 seconds for 100 entries)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });
    });
    
    group('Error Handling and Edge Cases', () {
      test('should handle invalid vehicle references in fuel entries', () async {
        final fuelNotifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        // Add fuel entry with non-existent vehicle ID
        await fuelNotifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: 99999,
          date: DateTime.now(),
          currentKm: 10000.0,
          fuelAmount: 50.0,
          price: 75.0,
          pricePerLiter: 1.50,
          country: 'Canada',
        ));
        
        // Entry should still be added (ephemeral storage doesn't enforce referential integrity)
        final fuelState = await container.read(fuelEntriesNotifierProvider.future);
        expect(fuelState.entries.where((e) => e.vehicleId == 99999).length, greaterThanOrEqualTo(1));
        
        // But vehicle lookup should return null
        final vehicle = await container.read(vehicleProvider(99999).future);
        expect(vehicle, isNull);
      });
      
      test('should handle duplicate vehicle names gracefully', () async {
        final vehicleNotifier = container.read(vehiclesNotifierProvider.notifier);
        
        // Add two vehicles with same name
        await vehicleNotifier.addVehicle(VehicleModel.create(
          name: 'Duplicate Name',
          initialKm: 10000.0,
        ));
        
        await vehicleNotifier.addVehicle(VehicleModel.create(
          name: 'Duplicate Name',
          initialKm: 20000.0,
        ));
        
        final vehicleState = await container.read(vehiclesNotifierProvider.future);
        final duplicateVehicles = vehicleState.vehicles.where(
          (v) => v.name == 'Duplicate Name'
        ).toList();
        
        expect(duplicateVehicles.length, greaterThanOrEqualTo(2));
        expect(duplicateVehicles[0].id, isNot(equals(duplicateVehicles[1].id)));
      });
    });
    
    group('State Management', () {
      test('should maintain consistent state across refreshes', () async {
        final vehicleNotifier = container.read(vehiclesNotifierProvider.notifier);
        final fuelNotifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        // Add test data
        final vehicle = VehicleModel.create(
          name: 'Refresh Test Vehicle',
          initialKm: 10000.0,
        );
        await vehicleNotifier.addVehicle(vehicle);
        
        final vehicleState = await container.read(vehiclesNotifierProvider.future);
        final addedVehicle = vehicleState.vehicles.where(
          (v) => v.name == 'Refresh Test Vehicle'
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
        final refreshedVehicleState = await container.read(vehiclesNotifierProvider.future);
        final refreshedFuelState = await container.read(fuelEntriesNotifierProvider.future);
        
        expect(refreshedVehicleState.vehicles.any((v) => v.id == addedVehicle.id), isTrue);
        expect(refreshedFuelState.entries.any((e) => e.vehicleId == addedVehicle.id), isTrue);
      });
    });
  });
}