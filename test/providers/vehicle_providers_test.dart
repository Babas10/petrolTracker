import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/database_providers.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/models/repositories/vehicle_repository.dart';
import 'package:petrol_tracker/database/database_service.dart';
import 'package:petrol_tracker/database/database.dart';

void main() {
  group('Vehicle Providers Tests', () {
    late ProviderContainer container;
    late AppDatabase testDatabase;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      testDatabase = AppDatabase.memory();
      await testDatabase.clearAllData();

      // Create container without overrides for now - use in-memory database
      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
      await testDatabase.close();
    });

    group('VehicleState', () {
      test('default constructor creates empty state', () {
        const state = VehicleState();
        expect(state.vehicles, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('copyWith updates fields correctly', () {
        const state = VehicleState();
        final vehicle = VehicleModel.create(name: 'Test', initialKm: 0);
        
        final newState = state.copyWith(
          vehicles: [vehicle],
          isLoading: true,
          error: 'test error',
        );

        expect(newState.vehicles, hasLength(1));
        expect(newState.isLoading, isTrue);
        expect(newState.error, equals('test error'));
      });

      test('equality works correctly', () {
        const state1 = VehicleState();
        const state2 = VehicleState();
        const state3 = VehicleState(isLoading: true);

        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });
    });

    group('VehiclesNotifier', () {
      test('initial build loads empty vehicles list', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        final state = await container.read(vehiclesProvider.future);

        expect(state.vehicles, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('addVehicle adds vehicle to state', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        
        final vehicle = VehicleModel.create(
          name: 'Test Car',
          initialKm: 50000.0,
        );

        await notifier.addVehicle(vehicle);
        final state = await container.read(vehiclesProvider.future);

        expect(state.vehicles, hasLength(1));
        expect(state.vehicles.first.name, equals('Test Car'));
        expect(state.vehicles.first.initialKm, equals(50000.0));
        expect(state.vehicles.first.id, isNotNull);
        expect(state.error, isNull);
      });

      test('updateVehicle updates existing vehicle', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        
        // Add a vehicle first
        final vehicle = VehicleModel.create(
          name: 'Test Car',
          initialKm: 50000.0,
        );
        await notifier.addVehicle(vehicle);
        
        var state = await container.read(vehiclesProvider.future);
        final addedVehicle = state.vehicles.first;

        // Update the vehicle
        final updatedVehicle = addedVehicle.copyWith(name: 'Updated Car');
        await notifier.updateVehicle(updatedVehicle);

        state = await container.read(vehiclesProvider.future);
        expect(state.vehicles, hasLength(1));
        expect(state.vehicles.first.name, equals('Updated Car'));
        expect(state.vehicles.first.id, equals(addedVehicle.id));
      });

      test('updateVehicle throws error for vehicle without ID', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        final vehicle = VehicleModel.create(name: 'Test', initialKm: 0);

        expect(
          () => notifier.updateVehicle(vehicle),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('deleteVehicle removes vehicle from state', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        
        // Add a vehicle first
        final vehicle = VehicleModel.create(
          name: 'Test Car',
          initialKm: 50000.0,
        );
        await notifier.addVehicle(vehicle);
        
        var state = await container.read(vehiclesProvider.future);
        final addedVehicle = state.vehicles.first;

        // Delete the vehicle
        await notifier.deleteVehicle(addedVehicle.id!);

        state = await container.read(vehiclesProvider.future);
        expect(state.vehicles, isEmpty);
      });

      test('refresh reloads vehicles from repository', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        final repository = container.read(vehicleRepositoryProvider);
        
        // Add vehicle directly to repository
        final vehicle = VehicleModel.create(
          name: 'Direct Insert',
          initialKm: 25000.0,
        );
        await repository.insertVehicle(vehicle);

        // Refresh should load the directly inserted vehicle
        await notifier.refresh();
        final state = await container.read(vehiclesProvider.future);

        expect(state.vehicles, hasLength(1));
        expect(state.vehicles.first.name, equals('Direct Insert'));
      });

      test('clearError removes error from state', () async {
        final notifier = container.read(vehiclesProvider.notifier);
        
        // Simulate error state by setting it manually through state
        const errorState = VehicleState(error: 'Test error');
        container.read(vehiclesProvider.notifier).state = 
            AsyncValue.data(errorState);

        notifier.clearError();
        final state = await container.read(vehiclesProvider.future);
        expect(state.error, isNull);
      });
    });

    group('Individual Vehicle Providers', () {
      test('vehicle provider returns specific vehicle by ID', () async {
        final repository = container.read(vehicleRepositoryProvider);
        
        // Add a vehicle
        final vehicle = VehicleModel.create(
          name: 'Test Vehicle',
          initialKm: 30000.0,
        );
        final id = await repository.insertVehicle(vehicle);

        // Get vehicle by ID
        final retrieved = await container.read(vehicleProvider(id).future);
        expect(retrieved, isNotNull);
        expect(retrieved!.name, equals('Test Vehicle'));
        expect(retrieved.id, equals(id));
      });

      test('vehicleNameExists provider checks name uniqueness', () async {
        final repository = container.read(vehicleRepositoryProvider);
        
        // Add a vehicle
        final vehicle = VehicleModel.create(
          name: 'Unique Name',
          initialKm: 30000.0,
        );
        final id = await repository.insertVehicle(vehicle);

        // Check if name exists
        final exists = await container.read(
          vehicleNameExistsProvider('Unique Name').future,
        );
        expect(exists, isTrue);

        // Check if name exists excluding the same vehicle
        final existsExcluding = await container.read(
          vehicleNameExistsProvider('Unique Name', excludeId: id).future,
        );
        expect(existsExcluding, isFalse);

        // Check non-existent name
        final doesNotExist = await container.read(
          vehicleNameExistsProvider('Non-existent').future,
        );
        expect(doesNotExist, isFalse);
      });

      test('vehicleCount provider returns correct count', () async {
        final repository = container.read(vehicleRepositoryProvider);
        
        // Initially should be 0
        var count = await container.read(vehicleCountProvider.future);
        expect(count, equals(0));

        // Add vehicles
        await repository.insertVehicle(
          VehicleModel.create(name: 'Car 1', initialKm: 0),
        );
        await repository.insertVehicle(
          VehicleModel.create(name: 'Car 2', initialKm: 0),
        );

        // Should now be 2
        count = await container.read(vehicleCountProvider.future);
        expect(count, equals(2));
      });
    });
  });
}