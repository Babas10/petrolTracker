import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/providers/chart_providers.dart';
import 'package:petrol_tracker/providers/database_providers.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/database/database_service.dart';
import 'package:petrol_tracker/database/database.dart';

void main() {
  group('Chart Providers Tests', () {
    late ProviderContainer container;
    late AppDatabase testDatabase;
    late int testVehicleId;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      testDatabase = AppDatabase.memory();
      await testDatabase.clearAllData();

      // Create container without overrides for now - use in-memory database
      container = ProviderContainer();

      // Create a test vehicle and fuel entries
      final vehicleRepository = container.read(vehicleRepositoryProvider);
      final fuelRepository = container.read(fuelEntryRepositoryProvider);
      
      final vehicle = VehicleModel.create(
        name: 'Test Vehicle',
        initialKm: 50000.0,
      );
      testVehicleId = await vehicleRepository.insertVehicle(vehicle);

      // Add test fuel entries with consumption data
      final entries = [
        FuelEntryModel.create(
          vehicleId: testVehicleId,
          date: DateTime(2024, 1, 15),
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          country: 'Canada',
          pricePerLiter: 1.45,
          consumption: 10.0, // 10 L/100km
        ),
        FuelEntryModel.create(
          vehicleId: testVehicleId,
          date: DateTime(2024, 1, 20),
          currentKm: 50600.0,
          fuelAmount: 42.0,
          price: 63.0,
          country: 'USA',
          pricePerLiter: 1.5,
          consumption: 10.5, // 10.5 L/100km
        ),
        FuelEntryModel.create(
          vehicleId: testVehicleId,
          date: DateTime(2024, 2, 10),
          currentKm: 51000.0,
          fuelAmount: 38.0,
          price: 57.0,
          country: 'Canada',
          pricePerLiter: 1.5,
          consumption: 9.5, // 9.5 L/100km
        ),
      ];

      for (final entry in entries) {
        await fuelRepository.insertEntry(entry);
      }
    });

    tearDown(() async {
      container.dispose();
      await testDatabase.close();
    });

    group('Data Point Classes', () {
      test('ConsumptionDataPoint equality and toString work correctly', () {
        final point1 = ConsumptionDataPoint(
          date: DateTime(2024, 1, 15),
          consumption: 10.0,
          kilometers: 50200.0,
        );
        
        final point2 = ConsumptionDataPoint(
          date: DateTime(2024, 1, 15),
          consumption: 10.0,
          kilometers: 50200.0,
        );
        
        final point3 = ConsumptionDataPoint(
          date: DateTime(2024, 1, 16),
          consumption: 10.0,
          kilometers: 50200.0,
        );

        expect(point1, equals(point2));
        expect(point1, isNot(equals(point3)));
        expect(point1.toString(), contains('ConsumptionDataPoint'));
        expect(point1.hashCode, equals(point2.hashCode));
      });

      test('PriceTrendDataPoint equality and toString work correctly', () {
        final point1 = PriceTrendDataPoint(
          date: DateTime(2024, 1, 15),
          pricePerLiter: 1.45,
          country: 'Canada',
        );
        
        final point2 = PriceTrendDataPoint(
          date: DateTime(2024, 1, 15),
          pricePerLiter: 1.45,
          country: 'Canada',
        );
        
        final point3 = PriceTrendDataPoint(
          date: DateTime(2024, 1, 15),
          pricePerLiter: 1.5,
          country: 'Canada',
        );

        expect(point1, equals(point2));
        expect(point1, isNot(equals(point3)));
        expect(point1.toString(), contains('PriceTrendDataPoint'));
        expect(point1.hashCode, equals(point2.hashCode));
      });
    });

    group('consumptionChartData Provider', () {
      test('returns consumption data points for vehicle', () async {
        final data = await container.read(
          consumptionChartDataProvider(testVehicleId).future,
        );

        expect(data, hasLength(3));
        expect(data[0].consumption, equals(10.0));
        expect(data[1].consumption, equals(10.5));
        expect(data[2].consumption, equals(9.5));
        expect(data.every((d) => d.consumption > 0), isTrue);
      });

      test('filters by date range when provided', () async {
        final data = await container.read(
          consumptionChartDataProvider(
            testVehicleId,
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 31),
          ).future,
        );

        expect(data, hasLength(2)); // Only January entries
        expect(data.every((d) => d.date.month == 1), isTrue);
      });

      test('filters out entries without consumption data', () async {
        final repository = container.read(fuelEntryRepositoryProvider);
        
        // Add entry without consumption
        await repository.insertEntry(
          FuelEntryModel.create(
            vehicleId: testVehicleId,
            date: DateTime(2024, 3, 1),
            currentKm: 51500.0,
            fuelAmount: 40.0,
            price: 60.0,
            country: 'Canada',
            pricePerLiter: 1.5,
            // No consumption specified
          ),
        );

        final data = await container.read(
          consumptionChartDataProvider(testVehicleId).future,
        );

        // Should still be 3, not 4
        expect(data, hasLength(3));
        expect(data.every((d) => d.consumption > 0), isTrue);
      });
    });

    group('priceTrendChartData Provider', () {
      test('returns price trend data points', () async {
        final data = await container.read(priceTrendChartDataProvider().future);

        expect(data, hasLength(3));
        expect(data[0].pricePerLiter, equals(1.45));
        expect(data[0].country, equals('Canada'));
        expect(data[1].pricePerLiter, equals(1.5));
        expect(data[1].country, equals('USA'));
      });

      test('filters by date range when provided', () async {
        final data = await container.read(
          priceTrendChartDataProvider(
            startDate: DateTime(2024, 2, 1),
            endDate: DateTime(2024, 2, 28),
          ).future,
        );

        expect(data, hasLength(1)); // Only February entry
        expect(data.first.date.month, equals(2));
        expect(data.first.country, equals('Canada'));
      });
    });

    group('monthlyConsumptionAverages Provider', () {
      test('calculates monthly averages correctly', () async {
        final averages = await container.read(
          monthlyConsumptionAveragesProvider(testVehicleId, 2024).future,
        );

        expect(averages.keys, containsAll(['2024-01', '2024-02']));
        
        // January average: (10.0 + 10.5) / 2 = 10.25
        expect(averages['2024-01'], closeTo(10.25, 0.01));
        
        // February average: 9.5
        expect(averages['2024-02'], equals(9.5));
      });

      test('filters by year correctly', () async {
        final averages = await container.read(
          monthlyConsumptionAveragesProvider(testVehicleId, 2023).future,
        );

        expect(averages, isEmpty); // No entries for 2023
      });

      test('excludes entries without consumption data', () async {
        final repository = container.read(fuelEntryRepositoryProvider);
        
        // Add January entry without consumption
        await repository.insertEntry(
          FuelEntryModel.create(
            vehicleId: testVehicleId,
            date: DateTime(2024, 1, 25),
            currentKm: 51200.0,
            fuelAmount: 40.0,
            price: 60.0,
            country: 'Canada',
            pricePerLiter: 1.5,
            // No consumption
          ),
        );

        final averages = await container.read(
          monthlyConsumptionAveragesProvider(testVehicleId, 2024).future,
        );

        // January average should still be (10.0 + 10.5) / 2 = 10.25
        expect(averages['2024-01'], closeTo(10.25, 0.01));
      });
    });

    group('costAnalysisData Provider', () {
      test('calculates cost analysis correctly for all entries', () async {
        final analysis = await container.read(
          costAnalysisDataProvider(testVehicleId).future,
        );

        expect(analysis['totalCost'], equals(58.0 + 63.0 + 57.0)); // 178.0
        expect(analysis['totalFuel'], equals(40.0 + 42.0 + 38.0)); // 120.0
        expect(analysis['totalDistance'], equals(1000.0)); // 51000 - 50000
        expect(analysis['entriesCount'], equals(3));
        
        // Average price per liter: 178.0 / 120.0 = 1.483...
        expect(analysis['averagePricePerLiter'], closeTo(1.483, 0.01));
        
        // Cost per kilometer: 178.0 / 1000.0 = 0.178
        expect(analysis['costPerKilometer'], equals(0.178));
      });

      test('filters by date range when provided', () async {
        final analysis = await container.read(
          costAnalysisDataProvider(
            testVehicleId,
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 31),
          ).future,
        );

        expect(analysis['totalCost'], equals(58.0 + 63.0)); // 121.0
        expect(analysis['totalFuel'], equals(40.0 + 42.0)); // 82.0
        expect(analysis['totalDistance'], equals(400.0)); // 50600 - 50200
        expect(analysis['entriesCount'], equals(2));
      });

      test('returns zero values for empty entries', () async {
        // Create vehicle with no entries
        final vehicleRepository = container.read(vehicleRepositoryProvider);
        final emptyVehicle = VehicleModel.create(
          name: 'Empty Vehicle',
          initialKm: 0.0,
        );
        final emptyVehicleId = await vehicleRepository.insertVehicle(emptyVehicle);

        final analysis = await container.read(
          costAnalysisDataProvider(emptyVehicleId).future,
        );

        expect(analysis['totalCost'], equals(0.0));
        expect(analysis['totalFuel'], equals(0.0));
        expect(analysis['totalDistance'], equals(0.0));
        expect(analysis['averagePricePerLiter'], equals(0.0));
        expect(analysis['costPerKilometer'], equals(0.0));
        expect(analysis['entriesCount'], equals(0));
      });
    });

    group('countryPriceComparison Provider', () {
      test('calculates country price averages correctly', () async {
        final comparison = await container.read(
          countryPriceComparisonProvider().future,
        );

        expect(comparison.keys, containsAll(['Canada', 'USA']));
        
        // Canada average: (1.45 + 1.5) / 2 = 1.475
        expect(comparison['Canada'], closeTo(1.475, 0.01));
        
        // USA average: 1.5
        expect(comparison['USA'], equals(1.5));
      });

      test('filters by date range when provided', () async {
        final comparison = await container.read(
          countryPriceComparisonProvider(
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 31),
          ).future,
        );

        expect(comparison.keys, containsAll(['Canada', 'USA']));
        
        // Only January entries: Canada = 1.45, USA = 1.5
        expect(comparison['Canada'], equals(1.45));
        expect(comparison['USA'], equals(1.5));
      });
    });
  });
}