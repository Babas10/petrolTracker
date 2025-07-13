import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/providers/database_providers.dart';
import 'package:petrol_tracker/database/database_service.dart';

void main() {
  group('Database Providers Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('database provider provides AppDatabase instance', () {
      final database = container.read(databaseProvider);
      expect(database, isNotNull);
    });

    test('databaseService provider provides DatabaseService instance', () {
      final service = container.read(databaseServiceProvider);
      expect(service, isNotNull);
      expect(service, equals(DatabaseService.instance));
    });

    test('vehicleRepository provider provides VehicleRepository', () {
      final repository = container.read(vehicleRepositoryProvider);
      expect(repository, isNotNull);
    });

    test('fuelEntryRepository provider provides FuelEntryRepository', () {
      final repository = container.read(fuelEntryRepositoryProvider);
      expect(repository, isNotNull);
    });

    test('providers are kept alive', () {
      // These providers should maintain their instances
      final database1 = container.read(databaseProvider);
      final database2 = container.read(databaseProvider);
      expect(identical(database1, database2), isTrue);

      final service1 = container.read(databaseServiceProvider);
      final service2 = container.read(databaseServiceProvider);
      expect(identical(service1, service2), isTrue);
    });

    test('repositories can be created', () {
      final vehicleRepo = container.read(vehicleRepositoryProvider);
      final fuelRepo = container.read(fuelEntryRepositoryProvider);

      expect(vehicleRepo, isNotNull);
      expect(fuelRepo, isNotNull);
    });
  });
}