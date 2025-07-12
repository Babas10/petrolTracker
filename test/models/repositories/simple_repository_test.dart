import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/database/database.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';

void main() {
  group('Simple Repository Integration Tests', () {
    late AppDatabase database;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      database = AppDatabase.memory();
      await database.clearAllData();
    });

    tearDown(() async {
      await database.close();
    });

    test('Can insert and retrieve vehicles through models', () async {
      final vehicle = VehicleModel.create(
        name: 'Test Car',
        initialKm: 50000.0,
      );

      // Insert using model's toCompanion method
      final id = await database.into(database.vehicles).insert(
        vehicle.toCompanion(),
      );

      // Retrieve and convert back to model
      final retrieved = await database.select(database.vehicles).getSingle();
      final vehicleModel = VehicleModel.fromEntity(retrieved);

      expect(vehicleModel.id, equals(id));
      expect(vehicleModel.name, equals('Test Car'));
      expect(vehicleModel.initialKm, equals(50000.0));
    });

    test('Can insert and retrieve fuel entries through models', () async {
      // First create a vehicle
      final vehicleId = await database.into(database.vehicles).insert(
        VehiclesCompanion.insert(
          name: 'Test Car',
          initialKm: 50000.0,
        ),
      );

      final entry = FuelEntryModel.create(
        vehicleId: vehicleId,
        date: DateTime(2024, 1, 15),
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        country: 'Canada',
        pricePerLiter: 1.45,
      );

      // Insert using model's toCompanion method
      final id = await database.into(database.fuelEntries).insert(
        entry.toCompanion(),
      );

      // Retrieve and convert back to model
      final retrieved = await database.select(database.fuelEntries).getSingle();
      final entryModel = FuelEntryModel.fromEntity(retrieved);

      expect(entryModel.id, equals(id));
      expect(entryModel.vehicleId, equals(vehicleId));
      expect(entryModel.fuelAmount, equals(40.0));
      expect(entryModel.country, equals('Canada'));
    });

    test('Model validation works correctly', () async {
      // Test valid vehicle
      final validVehicle = VehicleModel.create(
        name: 'Valid Car',
        initialKm: 50000.0,
      );
      expect(validVehicle.isValid, isTrue);

      // Test invalid vehicle
      final invalidVehicle = VehicleModel.create(
        name: '', // Invalid empty name
        initialKm: -1000.0, // Invalid negative km
      );
      expect(invalidVehicle.isValid, isFalse);

      final errors = invalidVehicle.validate();
      expect(errors.length, equals(2));
      expect(errors, contains('Vehicle name is required'));
      expect(errors, contains('Initial kilometers must be 0 or greater'));
    });

    test('Fuel entry validation works correctly', () async {
      // Test valid entry
      final validEntry = FuelEntryModel.create(
        vehicleId: 1,
        date: DateTime(2024, 1, 15),
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        country: 'Canada',
        pricePerLiter: 1.45,
      );
      expect(validEntry.isValid(previousKm: 50000.0), isTrue);

      // Test entry with km regression
      final invalidEntry = FuelEntryModel.create(
        vehicleId: 1,
        date: DateTime(2024, 1, 15),
        currentKm: 49000.0, // Less than previous
        fuelAmount: 40.0,
        price: 58.0,
        country: 'Canada',
        pricePerLiter: 1.45,
      );
      expect(invalidEntry.isValid(previousKm: 50000.0), isFalse);

      final errors = invalidEntry.validate(previousKm: 50000.0);
      expect(errors, contains('Current kilometers must be greater than or equal to previous entry (50000.0 km)'));
    });

    test('Consumption calculation works correctly', () async {
      final consumption = FuelEntryModel.calculateConsumption(
        fuelAmount: 40.0,
        currentKm: 50400.0,
        previousKm: 50000.0,
      );

      // 40L for 400km = 10L/100km
      expect(consumption, equals(10.0));
    });

    test('Model conversion and equality work correctly', () async {
      final now = DateTime.now();
      final vehicle1 = VehicleModel(
        id: 1,
        name: 'Test Car',
        initialKm: 50000.0,
        createdAt: now,
      );

      final vehicle2 = vehicle1.copyWith(name: 'Updated Car');
      expect(vehicle2.name, equals('Updated Car'));
      expect(vehicle2.id, equals(1));
      expect(vehicle2.initialKm, equals(50000.0));

      final vehicle3 = VehicleModel(
        id: 1,
        name: 'Test Car',
        initialKm: 50000.0,
        createdAt: now,
      );

      expect(vehicle1, equals(vehicle3));
      expect(vehicle1, isNot(equals(vehicle2)));
    });
  });
}