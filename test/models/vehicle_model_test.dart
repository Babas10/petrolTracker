import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/database/database.dart';

void main() {
  group('VehicleModel Tests', () {
    test('creates vehicle model correctly', () {
      final now = DateTime.now();
      final vehicle = VehicleModel(
        id: 1,
        name: 'Test Car',
        initialKm: 50000.0,
        createdAt: now,
      );

      expect(vehicle.id, equals(1));
      expect(vehicle.name, equals('Test Car'));
      expect(vehicle.initialKm, equals(50000.0));
      expect(vehicle.createdAt, equals(now));
    });

    test('creates vehicle model from entity', () {
      final now = DateTime.now();
      final entity = Vehicle(
        id: 1,
        name: 'Test Car',
        initialKm: 50000.0,
        createdAt: now,
      );

      final vehicle = VehicleModel.fromEntity(entity);

      expect(vehicle.id, equals(1));
      expect(vehicle.name, equals('Test Car'));
      expect(vehicle.initialKm, equals(50000.0));
      expect(vehicle.createdAt, equals(now));
    });

    test('creates vehicle model for new creation', () {
      final vehicle = VehicleModel.create(
        name: 'New Car',
        initialKm: 75000.0,
      );

      expect(vehicle.id, isNull);
      expect(vehicle.name, equals('New Car'));
      expect(vehicle.initialKm, equals(75000.0));
      expect(vehicle.createdAt, isA<DateTime>());
    });

    test('converts to companion correctly', () {
      final now = DateTime.now();
      final vehicle = VehicleModel(
        name: 'Test Car',
        initialKm: 50000.0,
        createdAt: now,
      );

      final companion = vehicle.toCompanion();

      expect(companion.name.value, equals('Test Car'));
      expect(companion.initialKm.value, equals(50000.0));
      expect(companion.createdAt.value, equals(now));
    });

    test('converts to update companion correctly', () {
      final now = DateTime.now();
      final vehicle = VehicleModel(
        id: 1,
        name: 'Test Car',
        initialKm: 50000.0,
        createdAt: now,
      );

      final companion = vehicle.toUpdateCompanion();

      expect(companion.id.value, equals(1));
      expect(companion.name.value, equals('Test Car'));
      expect(companion.initialKm.value, equals(50000.0));
      expect(companion.createdAt.value, equals(now));
    });

    test('validates correctly - valid vehicle', () {
      final vehicle = VehicleModel.create(
        name: 'Valid Car',
        initialKm: 50000.0,
      );

      final errors = vehicle.validate();
      expect(errors, isEmpty);
      expect(vehicle.isValid, isTrue);
    });

    test('validates correctly - empty name', () {
      final vehicle = VehicleModel.create(
        name: '',
        initialKm: 50000.0,
      );

      final errors = vehicle.validate();
      expect(errors, contains('Vehicle name is required'));
      expect(vehicle.isValid, isFalse);
    });

    test('validates correctly - short name', () {
      final vehicle = VehicleModel.create(
        name: 'A',
        initialKm: 50000.0,
      );

      final errors = vehicle.validate();
      expect(errors, contains('Vehicle name must be at least 2 characters long'));
      expect(vehicle.isValid, isFalse);
    });

    test('validates correctly - long name', () {
      final vehicle = VehicleModel.create(
        name: 'A' * 101, // 101 characters
        initialKm: 50000.0,
      );

      final errors = vehicle.validate();
      expect(errors, contains('Vehicle name must be less than 100 characters'));
      expect(vehicle.isValid, isFalse);
    });

    test('validates correctly - negative initial km', () {
      final vehicle = VehicleModel.create(
        name: 'Test Car',
        initialKm: -1000.0,
      );

      final errors = vehicle.validate();
      expect(errors, contains('Initial kilometers must be 0 or greater'));
      expect(vehicle.isValid, isFalse);
    });

    test('validates correctly - multiple errors', () {
      final vehicle = VehicleModel.create(
        name: '',
        initialKm: -1000.0,
      );

      final errors = vehicle.validate();
      expect(errors.length, equals(2));
      expect(errors, contains('Vehicle name is required'));
      expect(errors, contains('Initial kilometers must be 0 or greater'));
      expect(vehicle.isValid, isFalse);
    });

    test('copyWith works correctly', () {
      final now = DateTime.now();
      final original = VehicleModel(
        id: 1,
        name: 'Original Car',
        initialKm: 50000.0,
        createdAt: now,
      );

      final copied = original.copyWith(
        name: 'Updated Car',
        initialKm: 60000.0,
      );

      expect(copied.id, equals(1));
      expect(copied.name, equals('Updated Car'));
      expect(copied.initialKm, equals(60000.0));
      expect(copied.createdAt, equals(now));
    });

    test('equality works correctly', () {
      final now = DateTime.now();
      final vehicle1 = VehicleModel(
        id: 1,
        name: 'Test Car',
        initialKm: 50000.0,
        createdAt: now,
      );

      final vehicle2 = VehicleModel(
        id: 1,
        name: 'Test Car',
        initialKm: 50000.0,
        createdAt: now,
      );

      final vehicle3 = VehicleModel(
        id: 2,
        name: 'Test Car',
        initialKm: 50000.0,
        createdAt: now,
      );

      expect(vehicle1, equals(vehicle2));
      expect(vehicle1, isNot(equals(vehicle3)));
    });

    test('hashCode works correctly', () {
      final now = DateTime.now();
      final vehicle1 = VehicleModel(
        id: 1,
        name: 'Test Car',
        initialKm: 50000.0,
        createdAt: now,
      );

      final vehicle2 = VehicleModel(
        id: 1,
        name: 'Test Car',
        initialKm: 50000.0,
        createdAt: now,
      );

      expect(vehicle1.hashCode, equals(vehicle2.hashCode));
    });

    test('toString works correctly', () {
      final now = DateTime.now();
      final vehicle = VehicleModel(
        id: 1,
        name: 'Test Car',
        initialKm: 50000.0,
        createdAt: now,
      );

      final result = vehicle.toString();
      expect(result, contains('VehicleModel'));
      expect(result, contains('id: 1'));
      expect(result, contains('name: Test Car'));
      expect(result, contains('initialKm: 50000.0'));
    });
  });
}