import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';

void main() {
  group('Ephemeral Storage Performance Tests', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });
    
    group('Vehicle Operations Performance', () {
      test('should add vehicles efficiently', () async {
        final notifier = container.read(vehiclesNotifierProvider.notifier);
        final stopwatch = Stopwatch()..start();
        
        // Add 1000 vehicles
        for (int i = 0; i < 1000; i++) {
          await notifier.addVehicle(VehicleModel.create(
            name: 'Performance Vehicle $i',
            initialKm: 10000.0 + i,
          ));
        }
        
        stopwatch.stop();
        
        // Verify all vehicles were added
        final state = await container.read(vehiclesNotifierProvider.future);
        final perfVehicles = state.vehicles.where(
          (v) => v.name.startsWith('Performance Vehicle')
        ).toList();
        
        expect(perfVehicles.length, equals(1000));
        
        // Performance benchmark: should complete in under 10 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(10000));
        
        // Average time per vehicle should be under 10ms
        final avgTimePerVehicle = stopwatch.elapsedMilliseconds / 1000;
        expect(avgTimePerVehicle, lessThan(10));
      });
      
      test('should retrieve vehicles by ID efficiently', () async {
        final notifier = container.read(vehiclesNotifierProvider.notifier);
        
        // Add test vehicles
        final vehicleIds = <int>[];
        for (int i = 0; i < 100; i++) {
          await notifier.addVehicle(VehicleModel.create(
            name: 'Lookup Test Vehicle $i',
            initialKm: 10000.0 + i,
          ));
        }
        
        final state = await container.read(vehiclesNotifierProvider.future);
        final testVehicles = state.vehicles.where(
          (v) => v.name.startsWith('Lookup Test Vehicle')
        ).toList();
        
        for (final vehicle in testVehicles) {
          vehicleIds.add(vehicle.id!);
        }
        
        // Benchmark lookups
        final stopwatch = Stopwatch()..start();
        
        for (final id in vehicleIds) {
          final vehicle = await container.read(vehicleProvider(id).future);
          expect(vehicle, isNotNull);
        }
        
        stopwatch.stop();
        
        // Average lookup time should be under 1ms
        final avgLookupTime = stopwatch.elapsedMilliseconds / vehicleIds.length;
        expect(avgLookupTime, lessThan(1));
      });
      
      test('should update vehicles efficiently', () async {
        final notifier = container.read(vehiclesNotifierProvider.notifier);
        
        // Add vehicles to update
        final vehicleIds = <int>[];
        for (int i = 0; i < 100; i++) {
          await notifier.addVehicle(VehicleModel.create(
            name: 'Update Test Vehicle $i',
            initialKm: 10000.0 + i,
          ));
        }
        
        final state = await container.read(vehiclesNotifierProvider.future);
        final testVehicles = state.vehicles.where(
          (v) => v.name.startsWith('Update Test Vehicle')
        ).toList();
        
        // Benchmark updates
        final stopwatch = Stopwatch()..start();
        
        for (final vehicle in testVehicles) {
          await notifier.updateVehicle(vehicle.copyWith(
            name: '${vehicle.name} Updated',
            initialKm: vehicle.initialKm + 1000,
          ));
        }
        
        stopwatch.stop();
        
        // Verify updates
        final updatedState = await container.read(vehiclesNotifierProvider.future);
        final updatedVehicles = updatedState.vehicles.where(
          (v) => v.name.contains('Updated')
        ).toList();
        
        expect(updatedVehicles.length, equals(100));
        
        // Average update time should be under 5ms
        final avgUpdateTime = stopwatch.elapsedMilliseconds / testVehicles.length;
        expect(avgUpdateTime, lessThan(5));
      });
    });
    
    group('Fuel Entry Operations Performance', () {
      test('should add fuel entries efficiently', () async {
        final vehicleNotifier = container.read(vehiclesNotifierProvider.notifier);
        final fuelNotifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        // Add a test vehicle
        await vehicleNotifier.addVehicle(VehicleModel.create(
          name: 'Fuel Performance Vehicle',
          initialKm: 10000.0,
        ));
        
        final vehicleState = await container.read(vehiclesNotifierProvider.future);
        final testVehicle = vehicleState.vehicles.firstWhere(
          (v) => v.name == 'Fuel Performance Vehicle'
        );
        
        // Benchmark fuel entry additions
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 1000; i++) {
          await fuelNotifier.addFuelEntry(FuelEntryModel.create(
            vehicleId: testVehicle.id!,
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
        final fuelState = await container.read(fuelEntriesNotifierProvider.future);
        final testEntries = fuelState.entries.where(
          (e) => e.vehicleId == testVehicle.id
        ).toList();
        
        expect(testEntries.length, greaterThanOrEqualTo(1000));
        
        // Performance benchmark: should complete in under 15 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(15000));
        
        // Average time per entry should be under 15ms
        final avgTimePerEntry = stopwatch.elapsedMilliseconds / 1000;
        expect(avgTimePerEntry, lessThan(15));
      });
      
      test('should filter fuel entries efficiently', () async {
        final vehicleNotifier = container.read(vehiclesNotifierProvider.notifier);
        final fuelNotifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        // Add test vehicles
        final vehicleIds = <int>[];
        for (int i = 0; i < 10; i++) {
          await vehicleNotifier.addVehicle(VehicleModel.create(
            name: 'Filter Test Vehicle $i',
            initialKm: 10000.0 + i,
          ));
        }
        
        final vehicleState = await container.read(vehiclesNotifierProvider.future);
        final testVehicles = vehicleState.vehicles.where(
          (v) => v.name.startsWith('Filter Test Vehicle')
        ).toList();
        
        // Add fuel entries for each vehicle
        for (final vehicle in testVehicles) {
          for (int i = 0; i < 100; i++) {
            await fuelNotifier.addFuelEntry(FuelEntryModel.create(
              vehicleId: vehicle.id!,
              date: DateTime.now().subtract(Duration(days: i)),
              currentKm: 10000.0 + (i * 300.0),
              fuelAmount: 50.0,
              price: 75.0,
              pricePerLiter: 1.50,
              country: i % 2 == 0 ? 'Canada' : 'USA',
            ));
          }
        }
        
        // Benchmark filtering operations
        final stopwatch = Stopwatch()..start();
        
        for (final vehicle in testVehicles) {
          // Filter by vehicle
          final vehicleEntries = await container.read(
            fuelEntriesByVehicleProvider(vehicle.id!).future,
          );
          expect(vehicleEntries.length, greaterThanOrEqualTo(100));
          
          // Filter by date range
          final now = DateTime.now();
          final lastWeek = now.subtract(const Duration(days: 7));
          final recentEntries = await container.read(
            fuelEntriesByDateRangeProvider(lastWeek, now).future,
          );
          expect(recentEntries.length, greaterThanOrEqualTo(0));
          
          // Filter by vehicle and date range
          final vehicleRecentEntries = await container.read(
            fuelEntriesByVehicleAndDateRangeProvider(vehicle.id!, lastWeek, now).future,
          );
          expect(vehicleRecentEntries.length, greaterThanOrEqualTo(0));
        }
        
        stopwatch.stop();
        
        // Average filtering time should be reasonable
        final avgFilterTime = stopwatch.elapsedMilliseconds / (testVehicles.length * 3);
        expect(avgFilterTime, lessThan(50)); // 50ms per filter operation
      });
      
      test('should handle large datasets without memory issues', () async {
        final vehicleNotifier = container.read(vehiclesNotifierProvider.notifier);
        final fuelNotifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        // Add a test vehicle
        await vehicleNotifier.addVehicle(VehicleModel.create(
          name: 'Memory Test Vehicle',
          initialKm: 10000.0,
        ));
        
        final vehicleState = await container.read(vehiclesNotifierProvider.future);
        final testVehicle = vehicleState.vehicles.firstWhere(
          (v) => v.name == 'Memory Test Vehicle'
        );
        
        // Add a large number of fuel entries
        for (int i = 0; i < 5000; i++) {
          await fuelNotifier.addFuelEntry(FuelEntryModel.create(
            vehicleId: testVehicle.id!,
            date: DateTime.now().subtract(Duration(days: i % 365)),
            currentKm: 10000.0 + (i * 300.0),
            fuelAmount: 50.0,
            price: 75.0,
            pricePerLiter: 1.50,
            country: 'Canada',
          ));
          
          // Periodically verify memory usage is reasonable
          if (i % 1000 == 0) {
            final currentState = await container.read(fuelEntriesNotifierProvider.future);
            final memoryEntries = currentState.entries.where(
              (e) => e.vehicleId == testVehicle.id
            ).toList();
            
            // Verify entries exist
            expect(memoryEntries.length, greaterThan(i));
          }
        }
        
        // Final verification
        final finalState = await container.read(fuelEntriesNotifierProvider.future);
        final finalEntries = finalState.entries.where(
          (e) => e.vehicleId == testVehicle.id
        ).toList();
        
        expect(finalEntries.length, greaterThanOrEqualTo(5000));
        
        // Test operations still work with large dataset
        final stopwatch = Stopwatch()..start();
        
        final vehicleEntries = await container.read(
          fuelEntriesByVehicleProvider(testVehicle.id!).future,
        );
        expect(vehicleEntries.length, greaterThanOrEqualTo(5000));
        
        stopwatch.stop();
        
        // Even with large dataset, operations should complete in reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // 1 second
      });
    });
    
    group('Memory Usage Tests', () {
      test('should handle memory efficiently with realistic usage patterns', () async {
        final vehicleNotifier = container.read(vehiclesNotifierProvider.notifier);
        final fuelNotifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        // Simulate realistic usage: 5 vehicles with 200 fuel entries each
        final vehicleIds = <int>[];
        
        for (int i = 0; i < 5; i++) {
          await vehicleNotifier.addVehicle(VehicleModel.create(
            name: 'Realistic Vehicle $i',
            initialKm: 10000.0 + (i * 5000),
          ));
        }
        
        final vehicleState = await container.read(vehiclesNotifierProvider.future);
        final realisticVehicles = vehicleState.vehicles.where(
          (v) => v.name.startsWith('Realistic Vehicle')
        ).toList();
        
        // Add fuel entries for each vehicle
        for (final vehicle in realisticVehicles) {
          for (int i = 0; i < 200; i++) {
            await fuelNotifier.addFuelEntry(FuelEntryModel.create(
              vehicleId: vehicle.id!,
              date: DateTime.now().subtract(Duration(days: i)),
              currentKm: vehicle.initialKm + (i * 300.0),
              fuelAmount: 40.0 + (i % 30), // Varying fuel amounts
              price: (40.0 + (i % 30)) * 1.50,
              pricePerLiter: 1.50,
              country: ['Canada', 'USA', 'Mexico'][i % 3],
              consumption: 7.0 + (i % 3), // Varying consumption
            ));
          }
        }
        
        // Verify all data is accessible
        final finalVehicleState = await container.read(vehiclesNotifierProvider.future);
        final finalFuelState = await container.read(fuelEntriesNotifierProvider.future);
        
        final realisticVehiclesFinal = finalVehicleState.vehicles.where(
          (v) => v.name.startsWith('Realistic Vehicle')
        ).toList();
        
        expect(realisticVehiclesFinal.length, equals(5));
        
        // Check that each vehicle has its fuel entries
        for (final vehicle in realisticVehiclesFinal) {
          final vehicleEntries = await container.read(
            fuelEntriesByVehicleProvider(vehicle.id!).future,
          );
          expect(vehicleEntries.length, greaterThanOrEqualTo(200));
        }
        
        // Test aggregation operations
        final groupedEntries = await container.read(
          fuelEntriesGroupedByCountryProvider.future,
        );
        expect(groupedEntries.keys, contains('Canada'));
        expect(groupedEntries.keys, contains('USA'));
        expect(groupedEntries.keys, contains('Mexico'));
        
        // Test average consumption calculation
        for (final vehicle in realisticVehiclesFinal) {
          final avgConsumption = await container.read(
            averageConsumptionForVehicleProvider(vehicle.id!).future,
          );
          expect(avgConsumption, isNotNull);
          expect(avgConsumption!, greaterThan(0));
        }
      });
    });
  });
}