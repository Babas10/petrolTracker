import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/services/multi_currency_consumption_calculation_service.dart';
import 'package:petrol_tracker/services/currency_service.dart';

@GenerateMocks([CurrencyService])
import 'multi_currency_consumption_calculation_service_test.mocks.dart';

void main() {
  group('MultiCurrencyConsumptionCalculationService', () {
    late MultiCurrencyConsumptionCalculationService service;
    late MockCurrencyService mockCurrencyService;

    setUp(() {
      mockCurrencyService = MockCurrencyService();
      service = MultiCurrencyConsumptionCalculationService(
        currencyService: mockCurrencyService,
        primaryCurrency: 'USD',
      );
    });

    group('calculateConsumption', () {
      test('should calculate consumption with currency conversion', () async {
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
            country: 'Germany',
            pricePerLiter: 2.0,
          ),
        ];

        // Mock EUR to USD conversion
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
        final result = await service.calculateConsumption(
          entries: entries,
          periodStart: DateTime(2023, 1, 1),
          periodEnd: DateTime(2023, 1, 31),
        );

        // Assert
        expect(result.totalVolume, equals(90.0)); // 50 + 40
        expect(result.totalCost, equals(185.0)); // 100 + 85 (converted)
        expect(result.totalDistance, equals(500.0));
        expect(result.averageConsumption, equals(18.0)); // (90/500) * 100
        expect(result.costPerLiter, closeTo(2.056, 0.001)); // 185/90
        expect(result.costPerKilometer, equals(0.37)); // 185/500
        expect(result.currency, equals('USD'));
        expect(result.entriesAnalyzed, equals(2));
        
        // Check currency breakdown
        expect(result.currencyBreakdown, hasLength(2));
        expect(result.currencyBreakdown['USD']?.totalAmount, equals(100.0));
        expect(result.currencyBreakdown['EUR']?.totalAmount, equals(80.0));
        expect(result.currencyBreakdown['USD']?.entryCount, equals(1));
        expect(result.currencyBreakdown['EUR']?.entryCount, equals(1));
      });

      test('should handle empty entries', () async {
        // Act
        final result = await service.calculateConsumption(
          entries: [],
          periodStart: DateTime(2023, 1, 1),
          periodEnd: DateTime(2023, 1, 31),
        );

        // Assert
        expect(result.totalVolume, equals(0.0));
        expect(result.totalCost, equals(0.0));
        expect(result.totalDistance, equals(0.0));
        expect(result.averageConsumption, equals(0.0));
        expect(result.costPerLiter, equals(0.0));
        expect(result.costPerKilometer, equals(0.0));
        expect(result.entriesAnalyzed, equals(0));
        expect(result.currencyBreakdown, isEmpty);
      });

      test('should handle single entry', () async {
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
        ];

        // Act
        final result = await service.calculateConsumption(
          entries: entries,
          periodStart: DateTime(2023, 1, 1),
          periodEnd: DateTime(2023, 1, 31),
        );

        // Assert
        expect(result.totalVolume, equals(50.0));
        expect(result.totalCost, equals(100.0));
        expect(result.totalDistance, equals(0.0)); // Can't calculate distance with one entry
        expect(result.averageConsumption, equals(0.0));
        expect(result.costPerLiter, equals(2.0));
        expect(result.costPerKilometer, equals(0.0));
      });

      test('should filter out unreasonable distance values', () async {
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
            currentKm: 25000, // Unreasonable 15,000 km in 10 days
            fuelAmount: 40.0,
            price: 80.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
        ];

        // Act
        final result = await service.calculateConsumption(
          entries: entries,
          periodStart: DateTime(2023, 1, 1),
          periodEnd: DateTime(2023, 1, 31),
        );

        // Assert
        expect(result.totalDistance, equals(0.0)); // Filtered out unreasonable distance
        expect(result.averageConsumption, equals(0.0));
      });
    });

    group('calculateConsumptionByVehicle', () {
      test('should group consumption by vehicle', () async {
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
          FuelEntryModel(
            vehicleId: 2,
            date: DateTime(2023, 1, 15),
            currentKm: 5000,
            fuelAmount: 60.0,
            price: 120.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
        ];

        // Act
        final result = await service.calculateConsumptionByVehicle(
          entries: entries,
          periodStart: DateTime(2023, 1, 1),
          periodEnd: DateTime(2023, 1, 31),
        );

        // Assert
        expect(result, hasLength(2));
        expect(result[1]?.totalVolume, equals(90.0)); // Vehicle 1: 50 + 40
        expect(result[1]?.totalCost, equals(180.0)); // Vehicle 1: 100 + 80
        expect(result[1]?.totalDistance, equals(500.0)); // Vehicle 1: 10500 - 10000
        expect(result[2]?.totalVolume, equals(60.0)); // Vehicle 2
        expect(result[2]?.totalCost, equals(120.0)); // Vehicle 2
        expect(result[2]?.totalDistance, equals(0.0)); // Vehicle 2: single entry
      });
    });

    group('calculateMonthlyTrends', () {
      test('should calculate monthly consumption trends', () async {
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
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 2, 10),
            currentKm: 11000,
            fuelAmount: 45.0,
            price: 90.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 2, 25),
            currentKm: 11400,
            fuelAmount: 35.0,
            price: 70.0,
            country: 'United States',
            pricePerLiter: 2.0,
          ),
        ];

        // Act
        final result = await service.calculateMonthlyTrends(
          entries: entries,
          periodStart: DateTime(2023, 1, 1),
          periodEnd: DateTime(2023, 2, 28),
        );

        // Assert
        expect(result, hasLength(2)); // Two months
        
        final january = result.firstWhere((r) => r.periodStart.month == 1);
        expect(january.totalVolume, equals(90.0)); // 50 + 40
        expect(january.totalCost, equals(180.0)); // 100 + 80
        expect(january.totalDistance, equals(500.0)); // 10500 - 10000
        
        final february = result.firstWhere((r) => r.periodStart.month == 2);
        expect(february.totalVolume, equals(80.0)); // 45 + 35
        expect(february.totalCost, equals(160.0)); // 90 + 70
        expect(february.totalDistance, equals(400.0)); // 11400 - 11000
      });
    });

    group('calculateEfficiencyMetrics', () {
      test('should calculate efficiency metrics correctly', () async {
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

        // Act
        final result = await service.calculateEfficiencyMetrics(entries: entries);

        // Assert
        expect(result['costPerLiter'], equals(2.0)); // 180/90
        expect(result['costPerKilometer'], equals(0.36)); // 180/500
        expect(result['consumptionPer100Km'], equals(18.0)); // (90/500)*100
        expect(result['averagePricePerLiter'], equals(2.0)); // 180/90
      });

      test('should handle empty entries for efficiency metrics', () async {
        // Act
        final result = await service.calculateEfficiencyMetrics(entries: []);

        // Assert
        expect(result['costPerLiter'], equals(0.0));
        expect(result['costPerKilometer'], equals(0.0));
        expect(result['consumptionPer100Km'], equals(0.0));
        expect(result['averagePricePerLiter'], equals(0.0));
      });
    });

    group('currency breakdown calculation', () {
      test('should calculate currency breakdown with percentages', () async {
        // Arrange
        final entries = [
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 10),
            currentKm: 10000,
            fuelAmount: 50.0,
            price: 100.0, // USD
            country: 'United States',
            pricePerLiter: 2.0,
          ),
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 15),
            currentKm: 10200,
            fuelAmount: 40.0,
            price: 80.0, // EUR
            country: 'Germany',
            pricePerLiter: 2.0,
          ),
          FuelEntryModel(
            vehicleId: 1,
            date: DateTime(2023, 1, 20),
            currentKm: 10400,
            fuelAmount: 30.0,
            price: 60.0, // EUR
            country: 'France',
            pricePerLiter: 2.0,
          ),
        ];

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

        // Act
        final result = await service.calculateConsumption(
          entries: entries,
          periodStart: DateTime(2023, 1, 1),
          periodEnd: DateTime(2023, 1, 31),
        );

        // Assert
        final currencyBreakdown = result.currencyBreakdown;
        expect(currencyBreakdown, hasLength(2));
        
        final usdBreakdown = currencyBreakdown['USD']!;
        expect(usdBreakdown.totalAmount, equals(100.0));
        expect(usdBreakdown.entryCount, equals(1));
        expect(usdBreakdown.percentage, closeTo(41.67, 0.1)); // 100/240 * 100
        
        final eurBreakdown = currencyBreakdown['EUR']!;
        expect(eurBreakdown.totalAmount, equals(140.0)); // 80 + 60
        expect(eurBreakdown.entryCount, equals(2));
        expect(eurBreakdown.percentage, closeTo(58.33, 0.1)); // 140/240 * 100
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