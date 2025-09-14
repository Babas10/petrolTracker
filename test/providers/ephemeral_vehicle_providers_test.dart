import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';

void main() {
  group('Ephemeral Vehicle Providers', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });
    
    group('VehiclesNotifier', () {
      test('should start with empty state', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        final state = await container.read(vehiclesProvider.future);
        
        expect(state.vehicles, isEmpty);
        expect(state.isDatabaseReady, isTrue);
        expect(state.error, isNull);
      });
      
      test('should add vehicle to ephemeral storage', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        final vehicle = VehicleModel.create(
          name: 'Test Vehicle',
          initialKm: 10000.0,
        );
        
        await notifier.addVehicle(vehicle);
        final state = await container.read(vehiclesProvider.future);
        
        expect(state.vehicles, hasLength(1));
        expect(state.vehicles.first.name, equals('Test Vehicle'));
        expect(state.vehicles.first.initialKm, equals(10000.0));
        expect(state.vehicles.first.id, isNotNull);
      });
      
      test('should update vehicle in ephemeral storage', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        final vehicle = VehicleModel.create(
          name: 'Test Vehicle',
          initialKm: 10000.0,
        );
        
        await notifier.addVehicle(vehicle);
        final state = await container.read(vehiclesProvider.future);
        final addedVehicle = state.vehicles.first;
        
        final updatedVehicle = addedVehicle.copyWith(
          name: 'Updated Vehicle',
          initialKm: 15000.0,
        );
        
        await notifier.updateVehicle(updatedVehicle);
        final updatedState = await container.read(vehiclesProvider.future);
        
        expect(updatedState.vehicles, hasLength(1));
        expect(updatedState.vehicles.first.name, equals('Updated Vehicle'));
        expect(updatedState.vehicles.first.initialKm, equals(15000.0));
        expect(updatedState.vehicles.first.id, equals(addedVehicle.id));
      });
      
      test('should delete vehicle from ephemeral storage', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        final vehicle = VehicleModel.create(
          name: 'Test Vehicle',
          initialKm: 10000.0,
        );
        
        await notifier.addVehicle(vehicle);
        final state = await container.read(vehiclesProvider.future);
        final addedVehicle = state.vehicles.first;
        
        await notifier.deleteVehicle(addedVehicle.id!);
        final updatedState = await container.read(vehiclesProvider.future);
        
        expect(updatedState.vehicles, isEmpty);
      });
      
      test('should handle multiple vehicles', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        
        await notifier.addVehicle(VehicleModel.create(
          name: 'Vehicle 1',
          initialKm: 10000.0,
        ));
        await notifier.addVehicle(VehicleModel.create(
          name: 'Vehicle 2',
          initialKm: 20000.0,
        ));
        await notifier.addVehicle(VehicleModel.create(
          name: 'Vehicle 3',
          initialKm: 30000.0,
        ));
        
        final state = await container.read(vehiclesProvider.future);
        
        expect(state.vehicles, hasLength(3));
        expect(state.vehicles.map((v) => v.name), 
               containsAll(['Vehicle 1', 'Vehicle 2', 'Vehicle 3']));
      });
      
      test('should refresh vehicle list', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        
        await notifier.addVehicle(VehicleModel.create(
          name: 'Test Vehicle',
          initialKm: 10000.0,
        ));
        
        await notifier.refresh();
        final state = await container.read(vehiclesProvider.future);
        
        expect(state.vehicles, hasLength(1));
        expect(state.vehicles.first.name, equals('Test Vehicle'));
      });
    });
    
    group('Individual Vehicle Providers', () {
      test('vehicle provider should return vehicle by ID', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        final vehicle = VehicleModel.create(
          name: 'Test Vehicle',
          initialKm: 10000.0,
        );
        
        await notifier.addVehicle(vehicle);
        final state = await container.read(vehiclesProvider.future);
        final addedVehicle = state.vehicles.first;
        
        final retrievedVehicle = await container.read(
          vehicleProvider(addedVehicle.id!).future,
        );
        
        expect(retrievedVehicle, isNotNull);
        expect(retrievedVehicle!.name, equals('Test Vehicle'));
        expect(retrievedVehicle.id, equals(addedVehicle.id));
      });
      
      test('vehicle provider should return null for non-existent ID', () async {
        final retrievedVehicle = await container.read(
          vehicleProvider(999).future,
        );
        
        expect(retrievedVehicle, isNull);
      });
      
      test('vehicleNameExists should detect existing names', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        await notifier.addVehicle(VehicleModel.create(
          name: 'Test Vehicle',
          initialKm: 10000.0,
        ));
        
        final exists = await container.read(
          vehicleNameExistsProvider('Test Vehicle').future,
        );
        final notExists = await container.read(
          vehicleNameExistsProvider('Non-existent Vehicle').future,
        );
        
        expect(exists, isTrue);
        expect(notExists, isFalse);
      });
      
      test('vehicleNameExists should be case insensitive', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        await notifier.addVehicle(VehicleModel.create(
          name: 'Test Vehicle',
          initialKm: 10000.0,
        ));
        
        final exists = await container.read(
          vehicleNameExistsProvider('test vehicle').future,
        );
        
        expect(exists, isTrue);
      });
      
      test('vehicleNameExists should exclude specified ID', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        await notifier.addVehicle(VehicleModel.create(
          name: 'Test Vehicle',
          initialKm: 10000.0,
        ));
        
        final state = await container.read(vehiclesProvider.future);
        final addedVehicle = state.vehicles.first;
        
        final exists = await container.read(
          vehicleNameExistsProvider('Test Vehicle', excludeId: addedVehicle.id).future,
        );
        
        expect(exists, isFalse);
      });
      
      test('vehicleCount should return correct count', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        
        expect(await container.read(vehicleCountProvider.future), equals(0));
        
        await notifier.addVehicle(VehicleModel.create(
          name: 'Vehicle 1',
          initialKm: 10000.0,
        ));
        
        expect(await container.read(vehicleCountProvider.future), equals(1));
        
        await notifier.addVehicle(VehicleModel.create(
          name: 'Vehicle 2',
          initialKm: 20000.0,
        ));
        
        expect(await container.read(vehicleCountProvider.future), equals(2));
      });
      
      test('vehicleStatistics should return default statistics', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        await notifier.addVehicle(VehicleModel.create(
          name: 'Test Vehicle',
          initialKm: 10000.0,
        ));
        
        final state = await container.read(vehiclesProvider.future);
        final addedVehicle = state.vehicles.first;
        
        final statistics = await container.read(
          vehicleStatisticsProvider(addedVehicle.id!).future,
        );
        
        expect(statistics.totalDistanceTraveled, equals(0.0));
        expect(statistics.totalFuelConsumed, equals(0.0));
        expect(statistics.averageConsumption, equals(0.0));
        expect(statistics.totalEntries, equals(0));
      });
    });
    
    group('Ephemeral Storage Health', () {
      test('ephemeralStorageHealth should return true', () async {
        final isHealthy = await container.read(
          ephemeralStorageHealthProvider.future,
        );
        
        expect(isHealthy, isTrue);
      });
    });
    
    group('Data Persistence', () {
      test('should persist data during app session', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        await notifier.addVehicle(VehicleModel.create(
          name: 'Session Vehicle',
          initialKm: 10000.0,
        ));
        
        // Simulate reading from different provider instances
        final container2 = ProviderContainer();
        final state = await container2.read(vehiclesProvider.future);
        
        // Should have at least one vehicle (could be more from previous tests)
        expect(state.vehicles.where((v) => v.name == 'Session Vehicle'), hasLength(1));
        
        container2.dispose();
      });
      
      test('should maintain data consistency across provider instances', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        await notifier.addVehicle(VehicleModel.create(
          name: 'Consistency Test Vehicle',
          initialKm: 10000.0,
        ));
        
        // Read from same container
        final state = await container.read(vehiclesProvider.future);
        final addedVehicle = state.vehicles.firstWhere((v) => v.name == 'Consistency Test Vehicle');
        
        // Check vehicle exists in individual provider
        final retrievedVehicle = await container.read(
          vehicleProvider(addedVehicle.id!).future,
        );
        
        expect(retrievedVehicle, isNotNull);
        expect(retrievedVehicle!.name, equals('Consistency Test Vehicle'));
      });
    });
  });
}

