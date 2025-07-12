import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/database/database_service.dart';
import 'package:petrol_tracker/database/database.dart';
import 'package:petrol_tracker/database/database_exceptions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Database Tests', () {
    late AppDatabase database;

    setUp(() async {
      // Use in-memory database for testing
      database = AppDatabase.memory();
      
      // Clear any existing data
      await database.clearAllData();
    });

    tearDown(() async {
      await database.close();
    });

    test('Database initialization', () async {
      final stats = await database.getDatabaseStats();
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats['vehicles'], equals(0));
      expect(stats['fuel_entries'], equals(0));
      expect(stats['database_version'], equals(1));
    });

    test('Database integrity check', () async {
      final result = await database.customSelect('PRAGMA integrity_check').get();
      final isIntegrityOk = result.isNotEmpty && 
                           result.first.data['integrity_check'] == 'ok';
      expect(isIntegrityOk, isTrue);
    });

    test('Vehicle table operations', () async {
      // Test inserting a vehicle
      final vehicleId = await database.into(database.vehicles).insert(
        VehiclesCompanion.insert(
          name: 'Test Car',
          initialKm: 50000.0,
        ),
      );

      expect(vehicleId, isA<int>());
      expect(vehicleId, greaterThan(0));

      // Test retrieving the vehicle
      final vehicles = await database.select(database.vehicles).get();
      expect(vehicles.length, equals(1));
      expect(vehicles.first.name, equals('Test Car'));
      expect(vehicles.first.initialKm, equals(50000.0));

      // Test unique constraint
      expect(
        () async => await database.into(database.vehicles).insert(
          VehiclesCompanion.insert(
            name: 'Test Car', // Same name should fail
            initialKm: 60000.0,
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Fuel entry table operations', () async {
      // First create a vehicle
      final vehicleId = await database.into(database.vehicles).insert(
        VehiclesCompanion.insert(
          name: 'Test Car',
          initialKm: 50000.0,
        ),
      );

      // Test inserting a fuel entry
      final entryId = await database.into(database.fuelEntries).insert(
        FuelEntriesCompanion.insert(
          vehicleId: vehicleId,
          date: DateTime.now(),
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          country: 'Canada',
          pricePerLiter: 1.45,
        ),
      );

      expect(entryId, isA<int>());
      expect(entryId, greaterThan(0));

      // Test retrieving the fuel entry
      final entries = await database.select(database.fuelEntries).get();
      expect(entries.length, equals(1));
      expect(entries.first.vehicleId, equals(vehicleId));
      expect(entries.first.fuelAmount, equals(40.0));
      expect(entries.first.country, equals('Canada'));
    });

    test('Foreign key constraint', () async {
      // Test that we can't insert a fuel entry without a valid vehicle
      expect(
        () async => await database.into(database.fuelEntries).insert(
          FuelEntriesCompanion.insert(
            vehicleId: 999, // Non-existent vehicle ID
            date: DateTime.now(),
            currentKm: 50200.0,
            fuelAmount: 40.0,
            price: 58.0,
            country: 'Canada',
            pricePerLiter: 1.45,
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Database transaction', () async {
      final vehicleId = await database.transaction(() async {
        final id = await database.into(database.vehicles).insert(
          VehiclesCompanion.insert(
            name: 'Transaction Test Car',
            initialKm: 30000.0,
          ),
        );

        await database.into(database.fuelEntries).insert(
          FuelEntriesCompanion.insert(
            vehicleId: id,
            date: DateTime.now(),
            currentKm: 30150.0,
            fuelAmount: 35.0,
            price: 50.75,
            country: 'USA',
            pricePerLiter: 1.45,
          ),
        );

        return id;
      });

      expect(vehicleId, isA<int>());

      final vehicles = await database.select(database.vehicles).get();
      final entries = await database.select(database.fuelEntries).get();
      
      expect(vehicles.length, equals(1));
      expect(entries.length, equals(1));
      expect(entries.first.vehicleId, equals(vehicleId));
    });

    test('Database exception handling', () {
      // Test DatabaseExceptionHandler
      final exception = DatabaseExceptionHandler.handleException(
        Exception('UNIQUE constraint failed'),
        'Test operation',
      );

      expect(exception, isA<DatabaseConstraintException>());
      expect(exception.message, contains('unique constraint violation'));

      final userMessage = DatabaseExceptionHandler.getUserFriendlyMessage(exception);
      expect(userMessage, contains('already exists'));

      final isRecoverable = DatabaseExceptionHandler.isRecoverable(exception);
      expect(isRecoverable, isTrue);
    });

    test('Clear all data', () async {
      // Add some test data
      final vehicleId = await database.into(database.vehicles).insert(
        VehiclesCompanion.insert(
          name: 'Test Car',
          initialKm: 50000.0,
        ),
      );

      await database.into(database.fuelEntries).insert(
        FuelEntriesCompanion.insert(
          vehicleId: vehicleId,
          date: DateTime.now(),
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          country: 'Canada',
          pricePerLiter: 1.45,
        ),
      );

      // Verify data exists
      var stats = await database.getDatabaseStats();
      expect(stats['vehicles'], equals(1));
      expect(stats['fuel_entries'], equals(1));

      // Clear all data
      await database.clearAllData();

      // Verify data is cleared
      stats = await database.getDatabaseStats();
      expect(stats['vehicles'], equals(0));
      expect(stats['fuel_entries'], equals(0));
    });
  });
}