import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/services/chart_data_service.dart';
import 'package:petrol_tracker/widgets/chart_webview.dart';

void main() {
  group('ChartDataService Tests', () {
    late List<FuelEntryModel> testEntries;
    late List<VehicleModel> testVehicles;

    setUp(() {
      testEntries = [
        FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime(2024, 1, 1),
          currentKm: 10000.0,
          fuelAmount: 50.0,
          price: 75.0,
          pricePerLiter: 1.50,
          country: 'Canada',
          consumption: 7.5,
        ).copyWith(id: 1),
        FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime(2024, 1, 15),
          currentKm: 10300.0,
          fuelAmount: 45.0,
          price: 67.50,
          pricePerLiter: 1.50,
          country: 'Canada',
          consumption: 8.0,
        ).copyWith(id: 2),
        FuelEntryModel.create(
          vehicleId: 2,
          date: DateTime(2024, 1, 10),
          currentKm: 20000.0,
          fuelAmount: 60.0,
          price: 90.0,
          pricePerLiter: 1.50,
          country: 'USA',
          consumption: 9.0,
        ).copyWith(id: 3),
        FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime(2024, 2, 1),
          currentKm: 10600.0,
          fuelAmount: 48.0,
          price: 76.80,
          pricePerLiter: 1.60,
          country: 'Canada',
          consumption: 7.8,
        ).copyWith(id: 4),
      ];

      testVehicles = [
        VehicleModel.create(name: 'Toyota Camry', initialKm: 10000.0).copyWith(id: 1),
        VehicleModel.create(name: 'Honda Civic', initialKm: 20000.0).copyWith(id: 2),
      ];
    });

    group('transformConsumptionData', () {
      test('should transform fuel entries to consumption chart data', () {
        final chartData = ChartDataService.transformConsumptionData(testEntries);

        expect(chartData.length, equals(4));
        
        // Check first entry
        expect(chartData[0].date, equals(DateTime(2024, 1, 1)));
        expect(chartData[0].value, equals(7.5));
        expect(chartData[0].metadata?['entryId'], equals(1));
        expect(chartData[0].metadata?['vehicleId'], equals(1));
        
        // Check sorting (should be chronological)
        expect(chartData[1].date, equals(DateTime(2024, 1, 10)));
        expect(chartData[2].date, equals(DateTime(2024, 1, 15)));
        expect(chartData[3].date, equals(DateTime(2024, 2, 1)));
      });

      test('should filter out entries without consumption data', () {
        final entriesWithoutConsumption = [
          FuelEntryModel.create(
            vehicleId: 1,
            date: DateTime(2024, 1, 1),
            currentKm: 10000.0,
            fuelAmount: 50.0,
            price: 75.0,
            pricePerLiter: 1.50,
            country: 'Canada',
          ).copyWith(id: 1),
        ];

        final chartData = ChartDataService.transformConsumptionData(entriesWithoutConsumption);

        expect(chartData.length, equals(0));
      });
    });

    group('transformPriceTrendData', () {
      test('should transform fuel entries to price trend chart data', () {
        final chartData = ChartDataService.transformPriceTrendData(testEntries);

        expect(chartData.length, equals(4));
        
        // Check first entry
        expect(chartData[0].date, equals(DateTime(2024, 1, 1)));
        expect(chartData[0].value, equals(1.50));
        expect(chartData[0].metadata?['country'], equals('Canada'));
        expect(chartData[0].metadata?['totalPrice'], equals(75.0));
        
        // Check sorting (should be chronological)
        expect(chartData[1].date, equals(DateTime(2024, 1, 10)));
        expect(chartData[2].date, equals(DateTime(2024, 1, 15)));
        expect(chartData[3].date, equals(DateTime(2024, 2, 1)));
      });
    });

    group('transformMonthlyAverageData', () {
      test('should calculate monthly average consumption', () {
        final chartData = ChartDataService.transformMonthlyAverageData(testEntries);

        expect(chartData.length, equals(2)); // January and February 2024
        
        // January average: (7.5 + 8.0 + 9.0) / 3 = 8.17
        expect(chartData[0].date, equals(DateTime(2024, 1, 1)));
        expect(chartData[0].value, closeTo(8.17, 0.01));
        expect(chartData[0].metadata?['entryCount'], equals(3));
        
        // February average: 7.8
        expect(chartData[1].date, equals(DateTime(2024, 2, 1)));
        expect(chartData[1].value, equals(7.8));
        expect(chartData[1].metadata?['entryCount'], equals(1));
      });

      test('should handle entries without consumption data', () {
        final entriesWithoutConsumption = [
          FuelEntryModel.create(
            vehicleId: 1,
            date: DateTime(2024, 1, 1),
            currentKm: 10000.0,
            fuelAmount: 50.0,
            price: 75.0,
            pricePerLiter: 1.50,
            country: 'Canada',
          ).copyWith(id: 1),
        ];

        final chartData = ChartDataService.transformMonthlyAverageData(entriesWithoutConsumption);

        expect(chartData.length, equals(0));
      });
    });

    group('transformCostAnalysisData', () {
      test('should transform fuel entries to cost analysis chart data', () {
        final chartData = ChartDataService.transformCostAnalysisData(testEntries);

        expect(chartData.length, equals(4));
        
        // Check first entry
        expect(chartData[0].date, equals(DateTime(2024, 1, 1)));
        expect(chartData[0].value, equals(75.0));
        expect(chartData[0].metadata?['pricePerLiter'], equals(1.50));
        expect(chartData[0].metadata?['fuelAmount'], equals(50.0));
      });
    });

    group('transformCountryComparisonData', () {
      test('should group data by country and calculate averages', () {
        final chartData = ChartDataService.transformCountryComparisonData(testEntries);

        // Should have entries for dates that appear in data
        expect(chartData.length, greaterThan(0));
        
        // Find Canada vs USA comparison
        final canadaUSAComparison = chartData.where((data) => 
          data.values.containsKey('Canada') && data.values.containsKey('USA')
        ).toList();
        
        if (canadaUSAComparison.isNotEmpty) {
          final comparison = canadaUSAComparison.first;
          expect(comparison.values['Canada'], equals(1.50)); // Price per liter for Canada entries
          expect(comparison.values['USA'], equals(1.50)); // Price per liter for USA entry
        }
      });
    });

    group('transformVehicleComparisonData', () {
      test('should group consumption data by vehicle', () {
        final chartData = ChartDataService.transformVehicleComparisonData(testEntries, testVehicles);

        expect(chartData.length, greaterThan(0));
        
        // Check that vehicle names are used correctly
        final firstEntry = chartData.first;
        expect(firstEntry.values.keys, contains('Toyota Camry'));
        
        // Verify consumption values
        if (firstEntry.values.containsKey('Toyota Camry')) {
          expect(firstEntry.values['Toyota Camry'], greaterThan(0));
        }
      });

      test('should handle entries for vehicles not in the vehicle list', () {
        final entriesWithUnknownVehicle = [
          ...testEntries,
          FuelEntryModel.create(
            vehicleId: 999, // Unknown vehicle
            date: DateTime(2024, 1, 5),
            currentKm: 30000.0,
            fuelAmount: 40.0,
            price: 60.0,
            pricePerLiter: 1.50,
            country: 'Canada',
            consumption: 6.5,
          ).copyWith(id: 5),
        ];

        final chartData = ChartDataService.transformVehicleComparisonData(
          entriesWithUnknownVehicle, 
          testVehicles,
        );

        // Should only include known vehicles
        expect(chartData.length, greaterThan(0));
        for (final data in chartData) {
          expect(data.values.keys.every((key) => ['Toyota Camry', 'Honda Civic'].contains(key)), isTrue);
        }
      });
    });

    group('transformCategoryBarData', () {
      test('should group data by country and sum costs', () {
        final chartData = ChartDataService.transformCountryCostData(testEntries);

        expect(chartData.length, equals(2)); // Canada and USA
        
        final canadaData = chartData.firstWhere((d) => d.label == 'Canada');
        final usaData = chartData.firstWhere((d) => d.label == 'USA');
        
        // Canada total: 75.0 + 67.50 + 76.80 = 219.30
        expect(canadaData.value, closeTo(219.30, 0.01));
        expect(canadaData.metadata?['count'], equals(3));
        
        // USA total: 90.0
        expect(usaData.value, equals(90.0));
        expect(usaData.metadata?['count'], equals(1));
      });

      test('should group efficiency data by country', () {
        final chartData = ChartDataService.transformCountryEfficiencyData(testEntries);

        expect(chartData.length, equals(2)); // Canada and USA
        
        final canadaData = chartData.firstWhere((d) => d.label == 'Canada');
        final usaData = chartData.firstWhere((d) => d.label == 'USA');
        
        // Canada total consumption: 7.5 + 8.0 + 7.8 = 23.3
        expect(canadaData.value, closeTo(23.3, 0.01));
        
        // USA total consumption: 9.0
        expect(usaData.value, equals(9.0));
      });

      test('should group monthly spending data', () {
        final chartData = ChartDataService.transformMonthlySpendingData(testEntries);

        expect(chartData.length, equals(2)); // 2024-01 and 2024-02
        
        final januaryData = chartData.firstWhere((d) => d.label == '2024-01');
        final februaryData = chartData.firstWhere((d) => d.label == '2024-02');
        
        // January total: 75.0 + 67.50 + 90.0 = 232.50
        expect(januaryData.value, closeTo(232.50, 0.01));
        
        // February total: 76.80
        expect(februaryData.value, equals(76.80));
      });
    });

    group('calculateChartStatistics', () {
      test('should calculate correct statistics', () {
        final chartData = [
          const ChartDataPoint(value: 5.0),
          const ChartDataPoint(value: 10.0),
          const ChartDataPoint(value: 15.0),
          const ChartDataPoint(value: 20.0),
        ];

        final stats = ChartDataService.calculateChartStatistics(chartData);

        expect(stats['min'], equals(5.0));
        expect(stats['max'], equals(20.0));
        expect(stats['average'], equals(12.5));
        expect(stats['total'], equals(50.0));
        expect(stats['count'], equals(4.0));
      });

      test('should handle empty data', () {
        final stats = ChartDataService.calculateChartStatistics([]);

        expect(stats['min'], equals(0));
        expect(stats['max'], equals(0));
        expect(stats['average'], equals(0));
        expect(stats['total'], equals(0));
        expect(stats['count'], equals(0));
      });
    });

    group('filterByDateRange', () {
      test('should filter data points by date range', () {
        final chartData = ChartDataService.transformConsumptionData(testEntries);
        
        final filtered = ChartDataService.filterByDateRange(
          chartData,
          DateTime(2024, 1, 5),
          DateTime(2024, 1, 20),
        );

        expect(filtered.length, equals(2)); // Entries on Jan 10 and Jan 15
        expect(filtered.every((point) => 
          point.date!.isAfter(DateTime(2024, 1, 4)) && 
          point.date!.isBefore(DateTime(2024, 1, 21))
        ), isTrue);
      });

      test('should handle date range with no matching data', () {
        final chartData = ChartDataService.transformConsumptionData(testEntries);
        
        final filtered = ChartDataService.filterByDateRange(
          chartData,
          DateTime(2025, 1, 1),
          DateTime(2025, 1, 31),
        );

        expect(filtered.length, equals(0));
      });
    });

    group('filterMultiSeriesByDateRange', () {
      test('should filter multi-series data by date range', () {
        final chartData = ChartDataService.transformCountryComparisonData(testEntries);
        
        final filtered = ChartDataService.filterMultiSeriesByDateRange(
          chartData,
          DateTime(2024, 1, 5),
          DateTime(2024, 1, 20),
        );

        expect(filtered.every((point) => 
          point.date.isAfter(DateTime(2024, 1, 4)) && 
          point.date.isBefore(DateTime(2024, 1, 21))
        ), isTrue);
      });
    });
  });
}