import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/services/multi_currency_chart_data_service.dart';
import 'package:petrol_tracker/services/currency_service.dart';

@GenerateMocks([CurrencyService])
import 'multi_currency_chart_data_service_test.mocks.dart';

void main() {
  group('MultiCurrencyChartDataService', () {
    late MultiCurrencyChartDataService service;
    late MockCurrencyService mockCurrencyService;

    setUp(() {
      mockCurrencyService = MockCurrencyService();
      service = MultiCurrencyChartDataService(
        currencyService: mockCurrencyService,
        primaryCurrency: 'USD',
      );
    });

    group('generateCostChart', () {
      test('should generate cost chart with currency conversion', () async {
        // Arrange
        final entries = [
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 15),
            currentKm: 10000,
            fuelAmount: 50.0,
            price: 100.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 25),
            currentKm: 10200,
            fuelAmount: 45.0,
            price: 80.0,
            country: 'Germany',
            pricePerLiter: 1.78,
          ),
        ];

        final dateRange = DateRange(
          start: DateTime(2023, 1, 1),
          end: DateTime(2023, 1, 31),
        );

        // Mock currency conversion for EUR to USD
        when(mockCurrencyService.convertAmount(
          amount: 80.0,
          fromCurrency: 'EUR',
          toCurrency: 'USD',
        )).thenAnswer((_) async => MockCurrencyConversion(
          originalAmount: 80.0,
          convertedAmount: 85.0,
          exchangeRate: 1.0625,
          originalCurrency: 'EUR',
          targetCurrency: 'USD',
        ));

        // Act
        final result = await service.generateCostChart(
          entries: entries,
          period: ChartPeriod.monthly,
          dateRange: dateRange,
        );

        // Assert
        expect(result, isNotEmpty);
        expect(result.length, equals(1)); // One month
        expect(result.first.value, equals(185.0)); // 100 + 85 (converted)
        expect(result.first.metadata.currency, equals('USD'));
        expect(result.first.metadata.originalCurrencies, contains('USD'));
        expect(result.first.metadata.originalCurrencies, contains('EUR'));
        expect(result.first.metadata.entryCount, equals(2));
      });

      test('should handle conversion failures gracefully', () async {
        // Arrange
        final entries = [
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 15),
            currentKm: 10000,
            fuelAmount: 50.0,
            price: 100.0,
            country: 'Germany',
            pricePerLiter: 2.0,
          ),
        ];

        final dateRange = DateRange(
          start: DateTime(2023, 1, 1),
          end: DateTime(2023, 1, 31),
        );

        // Mock currency conversion failure
        when(mockCurrencyService.convertAmount(
          amount: 100.0,
          fromCurrency: 'EUR',
          toCurrency: 'USD',
        )).thenAnswer((_) async => null);

        // Act
        final result = await service.generateCostChart(
          entries: entries,
          period: ChartPeriod.monthly,
          dateRange: dateRange,
        );

        // Assert
        expect(result, isNotEmpty);
        expect(result.first.value, equals(100.0)); // Original amount kept
      });

      test('should filter entries by date range', () async {
        // Arrange
        final entries = [
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 15),
            currentKm: 10000,
            fuelAmount: 50.0,
            price: 100.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 3, 15), // Outside date range
            currentKm: 10200,
            fuelAmount: 45.0,
            price: 80.0,
            country: 'United States',
            pricePerLiter: 1.78,
          ),
        ];

        final dateRange = DateRange(
          start: DateTime(2023, 1, 1),
          end: DateTime(2023, 1, 31),
        );

        // Act
        final result = await service.generateCostChart(
          entries: entries,
          period: ChartPeriod.monthly,
          dateRange: dateRange,
        );

        // Assert
        expect(result, isNotEmpty);
        expect(result.first.value, equals(100.0)); // Only January entry
        expect(result.first.metadata.entryCount, equals(1));
      });
    });

    group('generateConsumptionChart', () {
      test('should calculate consumption correctly', () async {
        // Arrange
        final entries = [
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 10),
            currentKm: 10000,
            fuelAmount: 50.0,
            price: 100.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 20),
            currentKm: 10500, // 500 km driven
            fuelAmount: 40.0,
            price: 80.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
        ];

        final dateRange = DateRange(
          start: DateTime(2023, 1, 1),
          end: DateTime(2023, 1, 31),
        );

        // Act
        final result = await service.generateConsumptionChart(
          entries: entries,
          period: ChartPeriod.monthly,
          dateRange: dateRange,
        );

        // Assert
        expect(result, isNotEmpty);
        expect(result.first.metadata.totalVolume, equals(90.0)); // 50 + 40
        expect(result.first.metadata.totalDistance, equals(500.0));
        expect(result.first.value, equals(18.0)); // (90/500) * 100
      });
    });

    group('generateEfficiencyChart', () {
      test('should calculate cost per km correctly', () async {
        // Arrange
        final entries = [
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 10),
            currentKm: 10000,
            fuelAmount: 50.0,
            price: 100.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 20),
            currentKm: 10500,
            fuelAmount: 40.0,
            price: 80.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
        ];

        final dateRange = DateRange(
          start: DateTime(2023, 1, 1),
          end: DateTime(2023, 1, 31),
        );

        // Act
        final result = await service.generateEfficiencyChart(
          entries: entries,
          period: ChartPeriod.monthly,
          dateRange: dateRange,
        );

        // Assert
        expect(result, isNotEmpty);
        expect(result.first.value, equals(0.36)); // (100+80)/500
        expect(result.first.metadata.totalDistance, equals(500.0));
      });
    });

    group('generatePriceChart', () {
      test('should calculate average price per liter', () async {
        // Arrange
        final entries = [
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 10),
            currentKm: 10000,
            fuelAmount: 50.0,
            price: 100.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 20),
            currentKm: 10500,
            fuelAmount: 40.0,
            price: 80.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
        ];

        final dateRange = DateRange(
          start: DateTime(2023, 1, 1),
          end: DateTime(2023, 1, 31),
        );

        // Act
        final result = await service.generatePriceChart(
          entries: entries,
          period: ChartPeriod.monthly,
          dateRange: dateRange,
        );

        // Assert
        expect(result, isNotEmpty);
        expect(result.first.value, equals(2.0)); // (100+80)/(50+40)
        expect(result.first.metadata.totalVolume, equals(90.0));
      });
    });

    group('period grouping', () {
      test('should group entries by daily period', () async {
        // Arrange
        final entries = [
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 15, 10, 0),
            currentKm: 10000,
            fuelAmount: 30.0,
            price: 60.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 15, 15, 0), // Same day
            currentKm: 10100,
            fuelAmount: 20.0,
            price: 40.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 16, 10, 0), // Different day
            currentKm: 10200,
            fuelAmount: 25.0,
            price: 50.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
        ];

        final dateRange = DateRange(
          start: DateTime(2023, 1, 1),
          end: DateTime(2023, 1, 31),
        );

        // Act
        final result = await service.generateCostChart(
          entries: entries,
          period: ChartPeriod.daily,
          dateRange: dateRange,
        );

        // Assert
        expect(result.length, equals(2)); // Two different days
        
        // First day should have combined cost
        final firstDay = result.firstWhere((r) => r.date.day == 15);
        expect(firstDay.value, equals(100.0)); // 60 + 40
        expect(firstDay.metadata.entryCount, equals(2));
        
        // Second day should have single entry cost
        final secondDay = result.firstWhere((r) => r.date.day == 16);
        expect(secondDay.value, equals(50.0));
        expect(secondDay.metadata.entryCount, equals(1));
      });

      test('should group entries by weekly period', () async {
        // Arrange
        final entries = [
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 2), // Monday week 1
            currentKm: 10000,
            fuelAmount: 30.0,
            price: 60.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 5), // Thursday week 1
            currentKm: 10100,
            fuelAmount: 20.0,
            price: 40.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 9), // Monday week 2
            currentKm: 10200,
            fuelAmount: 25.0,
            price: 50.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
        ];

        final dateRange = DateRange(
          start: DateTime(2023, 1, 1),
          end: DateTime(2023, 1, 31),
        );

        // Act
        final result = await service.generateCostChart(
          entries: entries,
          period: ChartPeriod.weekly,
          dateRange: dateRange,
        );

        // Assert
        expect(result.length, equals(2)); // Two weeks
      });
    });

    group('currency extraction', () {
      test('should extract correct currencies from country names', () async {
        // This is tested indirectly through the chart generation tests
        // where we verify the originalCurrencies metadata
        final entries = [
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 15),
            currentKm: 10000,
            fuelAmount: 50.0,
            price: 100.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 25),
            currentKm: 10200,
            fuelAmount: 45.0,
            price: 80.0,
            country: 'Germany',
            pricePerLiter: 1.78,
          ),
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 28),
            currentKm: 10300,
            fuelAmount: 40.0,
            price: 75.0,
            country: 'United Kingdom',
            pricePerLiter: 1.88,
          ),
        ];

        final dateRange = DateRange(
          start: DateTime(2023, 1, 1),
          end: DateTime(2023, 1, 31),
        );

        // Mock conversions
        when(mockCurrencyService.convertAmount(
          amount: anyNamed('amount'),
          fromCurrency: 'EUR',
          toCurrency: 'USD',
        )).thenAnswer((_) async => MockCurrencyConversion(
          originalAmount: 80.0,
          convertedAmount: 85.0,
          exchangeRate: 1.0625,
          originalCurrency: 'EUR',
          targetCurrency: 'USD',
        ));

        when(mockCurrencyService.convertAmount(
          amount: anyNamed('amount'),
          fromCurrency: 'GBP',
          toCurrency: 'USD',
        )).thenAnswer((_) async => MockCurrencyConversion(
          originalAmount: 75.0,
          convertedAmount: 95.0,
          exchangeRate: 1.27,
          originalCurrency: 'GBP',
          targetCurrency: 'USD',
        ));

        // Act
        final result = await service.generateCostChart(
          entries: entries,
          period: ChartPeriod.monthly,
          dateRange: dateRange,
        );

        // Assert
        expect(result.first.metadata.originalCurrencies, contains('USD'));
        expect(result.first.metadata.originalCurrencies, contains('EUR'));
        expect(result.first.metadata.originalCurrencies, contains('GBP'));
        expect(result.first.metadata.originalCurrencies.length, equals(3));
      });
    });
  });
}

/// Mock currency conversion for testing
class MockCurrencyConversion {
  final double originalAmount;
  final double convertedAmount;
  final double exchangeRate;
  final String originalCurrency;
  final String targetCurrency;

  MockCurrencyConversion({
    required this.originalAmount,
    required this.convertedAmount,
    required this.exchangeRate,
    required this.originalCurrency,
    required this.targetCurrency,
  });
}