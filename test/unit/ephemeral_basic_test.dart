import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';

void main() {
  group('Ephemeral Storage Basic Tests', () {
    test('should create vehicle and verify it exists', () async {
      final container = ProviderContainer();
      
      try {
        final notifier = container.read(vehiclesProvider.notifier);
        
        // Create a vehicle with unique name
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final vehicle = VehicleModel.create(
          name: 'Basic Test Vehicle $timestamp',
          initialKm: 10000.0,
        );
        
        // Add the vehicle
        await notifier.addVehicle(vehicle);
        
        // Get the state and check the vehicle was added
        final state = await container.read(vehiclesProvider.future);
        
        // Verify vehicle exists
        expect(state.vehicles.isNotEmpty, isTrue);
        
        // Find our specific vehicle
        final addedVehicle = state.vehicles.firstWhere(
          (v) => v.name == 'Basic Test Vehicle $timestamp',
          orElse: () => throw StateError('Vehicle not found'),
        );
        
        expect(addedVehicle.name, equals('Basic Test Vehicle $timestamp'));
        expect(addedVehicle.initialKm, equals(10000.0));
        expect(addedVehicle.id, isNotNull);
        
      } finally {
        container.dispose();
      }
    });
    
    test('should create fuel entry and verify it exists', () async {
      final container = ProviderContainer();
      
      try {
        final vehicleNotifier = container.read(vehiclesProvider.notifier);
        final fuelNotifier = container.read(fuelEntriesProvider.notifier);
        
        // First create a vehicle
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final vehicle = VehicleModel.create(
          name: 'Fuel Test Vehicle $timestamp',
          initialKm: 10000.0,
        );
        
        await vehicleNotifier.addVehicle(vehicle);
        
        // Get the vehicle
        final vehicleState = await container.read(vehiclesProvider.future);
        final addedVehicle = vehicleState.vehicles.firstWhere(
          (v) => v.name == 'Fuel Test Vehicle $timestamp',
        );
        
        // Add a fuel entry
        await fuelNotifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: addedVehicle.id!,
          date: DateTime.now(),
          currentKm: 10300.0,
          fuelAmount: 50.0,
          price: 75.0,
          pricePerLiter: 1.50,
          country: 'Canada',
        ));
        
        // Verify fuel entry exists
        final fuelState = await container.read(fuelEntriesProvider.future);
        expect(fuelState.entries.isNotEmpty, isTrue);
        
        // Find our specific fuel entry
        final addedEntry = fuelState.entries.firstWhere(
          (e) => e.vehicleId == addedVehicle.id,
        );
        
        expect(addedEntry.vehicleId, equals(addedVehicle.id));
        expect(addedEntry.fuelAmount, equals(50.0));
        expect(addedEntry.country, equals('Canada'));
        expect(addedEntry.id, isNotNull);
        
      } finally {
        container.dispose();
      }
    });
    
    test('should handle multiple operations', () async {
      final container = ProviderContainer();
      
      try {
        final vehicleNotifier = container.read(vehiclesProvider.notifier);
        final fuelNotifier = container.read(fuelEntriesProvider.notifier);
        
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        
        // Add multiple vehicles
        for (int i = 0; i < 5; i++) {
          await vehicleNotifier.addVehicle(VehicleModel.create(
            name: 'Multi Test Vehicle $timestamp $i',
            initialKm: 10000.0 + i * 1000,
          ));
        }
        
        // Verify vehicles were added
        final vehicleState = await container.read(vehiclesProvider.future);
        final testVehicles = vehicleState.vehicles.where(
          (v) => v.name.contains('Multi Test Vehicle $timestamp')
        ).toList();
        
        expect(testVehicles.length, equals(5));
        
        // Add fuel entries for each vehicle
        for (final vehicle in testVehicles) {
          await fuelNotifier.addFuelEntry(FuelEntryModel.create(
            vehicleId: vehicle.id!,
            date: DateTime.now(),
            currentKm: vehicle.initialKm + 300.0,
            fuelAmount: 50.0,
            price: 75.0,
            pricePerLiter: 1.50,
            country: 'Canada',
          ));
        }
        
        // Verify fuel entries were added
        final fuelState = await container.read(fuelEntriesProvider.future);
        final testEntries = fuelState.entries.where(
          (e) => testVehicles.any((v) => v.id == e.vehicleId)
        ).toList();
        
        expect(testEntries.length, equals(5));
        
      } finally {
        container.dispose();
      }
    });
    
    test('should handle provider queries', () async {
      final container = ProviderContainer();
      
      try {
        final vehicleNotifier = container.read(vehiclesProvider.notifier);
        final fuelNotifier = container.read(fuelEntriesProvider.notifier);
        
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        
        // Add a vehicle
        await vehicleNotifier.addVehicle(VehicleModel.create(
          name: 'Query Test Vehicle $timestamp',
          initialKm: 10000.0,
        ));
        
        final vehicleState = await container.read(vehiclesProvider.future);
        final testVehicle = vehicleState.vehicles.firstWhere(
          (v) => v.name == 'Query Test Vehicle $timestamp',
        );
        
        // Test vehicle provider query
        final retrievedVehicle = await container.read(vehicleProvider(testVehicle.id!).future);
        expect(retrievedVehicle, isNotNull);
        expect(retrievedVehicle!.name, equals('Query Test Vehicle $timestamp'));
        
        // Test vehicle name exists
        final nameExists = await container.read(
          vehicleNameExistsProvider('Query Test Vehicle $timestamp').future,
        );
        expect(nameExists, isTrue);
        
        // Add fuel entry and test queries
        await fuelNotifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: testVehicle.id!,
          date: DateTime.now(),
          currentKm: 10300.0,
          fuelAmount: 50.0,
          price: 75.0,
          pricePerLiter: 1.50,
          country: 'Canada',
        ));
        
        // Test fuel entry queries
        final vehicleFuelEntries = await container.read(
          fuelEntriesByVehicleProvider(testVehicle.id!).future,
        );
        expect(vehicleFuelEntries.length, equals(1));
        
        final latestEntry = await container.read(
          latestFuelEntryForVehicleProvider(testVehicle.id!).future,
        );
        expect(latestEntry, isNotNull);
        expect(latestEntry!.vehicleId, equals(testVehicle.id));
        
      } finally {
        container.dispose();
      }
    });
    
    test('should verify ephemeral storage health', () async {
      final container = ProviderContainer();
      
      try {
        final isHealthy = await container.read(ephemeralStorageHealthProvider.future);
        expect(isHealthy, isTrue);
        
      } finally {
        container.dispose();
      }
    });
  });
}