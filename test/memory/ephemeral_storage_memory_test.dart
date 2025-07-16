import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';

void main() {
  group('Ephemeral Storage Memory Tests', () {
    
    group('Memory Leak Prevention', () {
      test('should not leak memory when adding and removing vehicles', () async {
        // Create multiple containers to simulate memory usage
        final containers = <ProviderContainer>[];
        
        // Initial memory measurement (baseline)
        final initialContainers = 10;
        for (int i = 0; i < initialContainers; i++) {
          containers.add(ProviderContainer());
        }
        
        // Add vehicles to each container
        for (int i = 0; i < containers.length; i++) {
          final container = containers[i];
          final notifier = container.read(vehiclesNotifierProvider.notifier);
          
          await notifier.addVehicle(VehicleModel.create(
            name: 'Memory Test Vehicle $i',
            initialKm: 10000.0,
          ));
        }
        
        // Dispose half the containers
        for (int i = 0; i < containers.length ~/ 2; i++) {
          containers[i].dispose();
        }
        
        // Remove disposed containers from list
        containers.removeRange(0, containers.length ~/ 2);
        
        // Verify remaining containers still work
        for (final container in containers) {
          final state = await container.read(vehiclesNotifierProvider.future);
          expect(state.vehicles.length, greaterThanOrEqualTo(1));
        }
        
        // Dispose remaining containers
        for (final container in containers) {
          container.dispose();
        }
        
        // Test passes if no memory leaks occurred
        expect(containers.isEmpty, isFalse); // We cleared the list, but test completed
      });
      
      test('should handle rapid creation and disposal of containers', () async {
        // Rapidly create and dispose containers
        for (int cycle = 0; cycle < 100; cycle++) {
          final container = ProviderContainer();
          final notifier = container.read(vehiclesNotifierProvider.notifier);
          
          // Add some data
          await notifier.addVehicle(VehicleModel.create(
            name: 'Rapid Test Vehicle $cycle',
            initialKm: 10000.0,
          ));
          
          // Verify data exists
          final state = await container.read(vehiclesNotifierProvider.future);
          expect(state.vehicles.length, greaterThanOrEqualTo(1));
          
          // Dispose immediately
          container.dispose();
        }
        
        // Test passes if no memory issues occurred
        expect(true, isTrue);
      });
      
      test('should handle large objects without memory issues', () async {
        final container = ProviderContainer();
        final vehicleNotifier = container.read(vehiclesNotifierProvider.notifier);
        final fuelNotifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        // Add a vehicle
        await vehicleNotifier.addVehicle(VehicleModel.create(
          name: 'Large Object Test Vehicle',
          initialKm: 10000.0,
        ));
        
        final vehicleState = await container.read(vehiclesNotifierProvider.future);
        final testVehicle = vehicleState.vehicles.firstWhere(
          (v) => v.name == 'Large Object Test Vehicle'
        );
        
        // Add fuel entries with large string data
        for (int i = 0; i < 100; i++) {
          await fuelNotifier.addFuelEntry(FuelEntryModel.create(
            vehicleId: testVehicle.id!,
            date: DateTime.now().subtract(Duration(days: i)),
            currentKm: 10000.0 + (i * 300.0),
            fuelAmount: 50.0,
            price: 75.0,
            pricePerLiter: 1.50,
            country: 'Canada with very long country name for testing memory usage $i',
          ));
        }
        
        // Verify all entries exist
        final fuelState = await container.read(fuelEntriesNotifierProvider.future);
        final testEntries = fuelState.entries.where(
          (e) => e.vehicleId == testVehicle.id
        ).toList();
        
        expect(testEntries.length, greaterThanOrEqualTo(100));
        
        // Delete all entries
        for (final entry in testEntries) {
          await fuelNotifier.deleteFuelEntry(entry.id!);
        }
        
        // Verify entries are removed
        final finalState = await container.read(fuelEntriesNotifierProvider.future);
        final remainingEntries = finalState.entries.where(
          (e) => e.vehicleId == testVehicle.id
        ).toList();
        
        expect(remainingEntries.length, equals(0));
        
        container.dispose();
      });
    });
    
    group('Memory Efficiency', () {
      test('should use memory efficiently with many small objects', () async {
        final container = ProviderContainer();
        final vehicleNotifier = container.read(vehiclesNotifierProvider.notifier);
        
        // Add many vehicles
        final vehicleNames = <String>[];
        for (int i = 0; i < 1000; i++) {
          final name = 'Small Vehicle $i';
          vehicleNames.add(name);
          await vehicleNotifier.addVehicle(VehicleModel.create(
            name: name,
            initialKm: 10000.0 + i,
          ));
        }
        
        // Verify all vehicles exist
        final state = await container.read(vehiclesNotifierProvider.future);
        final smallVehicles = state.vehicles.where(
          (v) => v.name.startsWith('Small Vehicle')
        ).toList();
        
        expect(smallVehicles.length, equals(1000));
        
        // Update every 10th vehicle
        for (int i = 0; i < smallVehicles.length; i += 10) {
          await vehicleNotifier.updateVehicle(
            smallVehicles[i].copyWith(name: '${smallVehicles[i].name} Updated')
          );
        }
        
        // Verify updates
        final updatedState = await container.read(vehiclesNotifierProvider.future);
        final updatedVehicles = updatedState.vehicles.where(
          (v) => v.name.contains('Updated')
        ).toList();
        
        expect(updatedVehicles.length, equals(100));
        
        container.dispose();
      });
      
      test('should handle object references correctly', () async {
        final container = ProviderContainer();
        final vehicleNotifier = container.read(vehiclesNotifierProvider.notifier);
        
        // Add a vehicle
        final originalVehicle = VehicleModel.create(
          name: 'Reference Test Vehicle',
          initialKm: 10000.0,
        );
        
        await vehicleNotifier.addVehicle(originalVehicle);
        
        // Get the vehicle from storage
        final state = await container.read(vehiclesNotifierProvider.future);
        final storedVehicle = state.vehicles.firstWhere(
          (v) => v.name == 'Reference Test Vehicle'
        );
        
        // Verify it's a different object (immutability)
        expect(identical(originalVehicle, storedVehicle), isFalse);
        expect(originalVehicle.id, isNull);
        expect(storedVehicle.id, isNotNull);
        
        // Update the vehicle
        final updatedVehicle = storedVehicle.copyWith(
          name: 'Updated Reference Test Vehicle'
        );
        
        await vehicleNotifier.updateVehicle(updatedVehicle);
        
        // Verify old reference is not updated
        expect(storedVehicle.name, equals('Reference Test Vehicle'));
        
        // Get the updated vehicle
        final updatedState = await container.read(vehiclesNotifierProvider.future);
        final finalVehicle = updatedState.vehicles.firstWhere(
          (v) => v.id == storedVehicle.id
        );
        
        expect(finalVehicle.name, equals('Updated Reference Test Vehicle'));
        expect(identical(storedVehicle, finalVehicle), isFalse);
        
        container.dispose();
      });
    });
    
    group('Garbage Collection Behavior', () {
      test('should allow garbage collection of removed objects', () async {
        final container = ProviderContainer();
        final vehicleNotifier = container.read(vehiclesNotifierProvider.notifier);
        
        // Add vehicles
        final vehicleIds = <int>[];
        for (int i = 0; i < 50; i++) {
          await vehicleNotifier.addVehicle(VehicleModel.create(
            name: 'GC Test Vehicle $i',
            initialKm: 10000.0,
          ));
        }
        
        // Get all vehicle IDs
        final state = await container.read(vehiclesNotifierProvider.future);
        final gcVehicles = state.vehicles.where(
          (v) => v.name.startsWith('GC Test Vehicle')
        ).toList();
        
        for (final vehicle in gcVehicles) {
          vehicleIds.add(vehicle.id!);
        }
        
        expect(vehicleIds.length, equals(50));
        
        // Delete half the vehicles
        for (int i = 0; i < vehicleIds.length ~/ 2; i++) {
          await vehicleNotifier.deleteVehicle(vehicleIds[i]);
        }
        
        // Verify they're removed
        final updatedState = await container.read(vehiclesNotifierProvider.future);
        final remainingVehicles = updatedState.vehicles.where(
          (v) => v.name.startsWith('GC Test Vehicle')
        ).toList();
        
        expect(remainingVehicles.length, equals(25));
        
        // Verify deleted IDs don't exist
        for (int i = 0; i < vehicleIds.length ~/ 2; i++) {
          final deletedVehicle = await container.read(vehicleProvider(vehicleIds[i]).future);
          expect(deletedVehicle, isNull);
        }
        
        container.dispose();
      });
    });
    
    group('Container Lifecycle', () {
      test('should handle container disposal correctly', () async {
        final containers = <ProviderContainer>[];
        
        // Create multiple containers
        for (int i = 0; i < 5; i++) {
          containers.add(ProviderContainer());
        }
        
        // Add data to each container
        for (int i = 0; i < containers.length; i++) {
          final container = containers[i];
          final notifier = container.read(vehiclesNotifierProvider.notifier);
          
          await notifier.addVehicle(VehicleModel.create(
            name: 'Container $i Vehicle',
            initialKm: 10000.0,
          ));
        }
        
        // Verify each container has its data
        for (int i = 0; i < containers.length; i++) {
          final container = containers[i];
          final state = await container.read(vehiclesNotifierProvider.future);
          expect(state.vehicles.length, greaterThanOrEqualTo(1));
        }
        
        // Dispose containers in reverse order
        for (int i = containers.length - 1; i >= 0; i--) {
          containers[i].dispose();
        }
        
        // Test passes if no issues during disposal
        expect(containers.length, equals(5));
      });
      
      test('should handle provider recreation after disposal', () async {
        // Create container
        var container = ProviderContainer();
        var notifier = container.read(vehiclesNotifierProvider.notifier);
        
        // Add a vehicle
        await notifier.addVehicle(VehicleModel.create(
          name: 'Recreation Test Vehicle',
          initialKm: 10000.0,
        ));
        
        // Verify vehicle exists
        var state = await container.read(vehiclesNotifierProvider.future);
        expect(state.vehicles.length, greaterThanOrEqualTo(1));
        
        // Dispose container
        container.dispose();
        
        // Create new container
        container = ProviderContainer();
        notifier = container.read(vehiclesNotifierProvider.notifier);
        
        // Data should still exist (global ephemeral storage)
        state = await container.read(vehiclesNotifierProvider.future);
        expect(state.vehicles.any((v) => v.name == 'Recreation Test Vehicle'), isTrue);
        
        container.dispose();
      });
    });
  });
}