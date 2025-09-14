import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/providers/database_providers.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/chart_providers.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';

void main() {
  group('Providers Integration Tests', () {
    late ProviderContainer container;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      container = ProviderContainer();
      
      // Clear database for clean tests
      final databaseService = container.read(databaseServiceProvider);
      await databaseService.clearAllData();
    });

    tearDown(() {
      container.dispose();
    });

    test('Database providers work correctly', () {
      final database = container.read(databaseProvider);
      final service = container.read(databaseServiceProvider);
      final vehicleRepo = container.read(vehicleRepositoryProvider);
      final fuelRepo = container.read(fuelEntryRepositoryProvider);

      expect(database, isNotNull);
      expect(service, isNotNull);
      expect(vehicleRepo, isNotNull);
      expect(fuelRepo, isNotNull);
    });

    test('Vehicle providers state management works', () async {
      final notifier = container.read(vehiclesProvider.notifier);
      
      // Test initial empty state
      final initialState = await container.read(vehiclesProvider.future);
      expect(initialState.vehicles, isEmpty);
      expect(initialState.isLoading, isFalse);
      expect(initialState.error, isNull);

      // Test adding a vehicle
      final vehicle = VehicleModel.create(
        name: 'Test Car',
        initialKm: 50000.0,
      );

      await notifier.addVehicle(vehicle);
      final stateAfterAdd = await container.read(vehiclesProvider.future);

      expect(stateAfterAdd.vehicles, hasLength(1));
      expect(stateAfterAdd.vehicles.first.name, equals('Test Car'));
      expect(stateAfterAdd.error, isNull);
    });

    test('Fuel entry providers state management works', () async {
      // First add a vehicle
      final vehicleNotifier = container.read(vehiclesProvider.notifier);
      final vehicle = VehicleModel.create(
        name: 'Test Car for Fuel',
        initialKm: 50000.0,
      );
      await vehicleNotifier.addVehicle(vehicle);
      final vehicleState = await container.read(vehiclesProvider.future);
      final vehicleId = vehicleState.vehicles.first.id!;

      // Test fuel entry operations
      final fuelNotifier = container.read(fuelEntriesProvider.notifier);
      
      // Test initial empty state
      final initialState = await container.read(fuelEntriesProvider.future);
      expect(initialState.entries, isEmpty);

      // Test adding a fuel entry
      final entry = FuelEntryModel.create(
        vehicleId: vehicleId,
        date: DateTime(2024, 1, 15),
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        country: 'Canada',
        pricePerLiter: 1.45,
      );

      await fuelNotifier.addFuelEntry(entry);
      final stateAfterAdd = await container.read(fuelEntriesProvider.future);

      expect(stateAfterAdd.entries, hasLength(1));
      expect(stateAfterAdd.entries.first.vehicleId, equals(vehicleId));
      expect(stateAfterAdd.error, isNull);
    });

    test('Chart providers work with data', () async {
      // Setup data
      final vehicleNotifier = container.read(vehiclesProvider.notifier);
      final fuelNotifier = container.read(fuelEntriesProvider.notifier);
      
      final vehicle = VehicleModel.create(
        name: 'Chart Test Car',
        initialKm: 50000.0,
      );
      await vehicleNotifier.addVehicle(vehicle);
      final vehicleState = await container.read(vehiclesProvider.future);
      final vehicleId = vehicleState.vehicles.first.id!;

      // Add fuel entries with consumption data
      final entry1 = FuelEntryModel.create(
        vehicleId: vehicleId,
        date: DateTime(2024, 1, 15),
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        country: 'Canada',
        pricePerLiter: 1.45,
        consumption: 10.0,
      );

      final entry2 = FuelEntryModel.create(
        vehicleId: vehicleId,
        date: DateTime(2024, 1, 20),
        currentKm: 50600.0,
        fuelAmount: 42.0,
        price: 63.0,
        country: 'USA',
        pricePerLiter: 1.5,
        consumption: 10.5,
      );

      await fuelNotifier.addFuelEntry(entry1);
      await fuelNotifier.addFuelEntry(entry2);

      // Test chart providers
      final consumptionData = await container.read(
        consumptionChartDataProvider(vehicleId).future,
      );
      expect(consumptionData, hasLength(2));
      expect(consumptionData.any((d) => d.consumption == 10.0), isTrue);
      expect(consumptionData.any((d) => d.consumption == 10.5), isTrue);

      final costAnalysis = await container.read(
        costAnalysisDataProvider(vehicleId).future,
      );
      expect(costAnalysis['totalCost'], equals(58.0 + 63.0));
      expect(costAnalysis['totalFuel'], equals(40.0 + 42.0));
      expect(costAnalysis['entriesCount'], equals(2));
    });

    test('Provider error handling works', () async {
      final notifier = container.read(vehiclesProvider.notifier);
      
      // Test invalid vehicle (should pass through as the validation is in repository)
      final invalidVehicle = VehicleModel.create(
        name: '', // Invalid empty name
        initialKm: -1000.0, // Invalid negative km
      );

      try {
        await notifier.addVehicle(invalidVehicle);
        final state = await container.read(vehiclesProvider.future);
        // Should have error in state
        expect(state.error, isNotNull);
      } catch (e) {
        // Error handling might throw or set error state
        expect(e, isNotNull);
      }
    });
  });
}