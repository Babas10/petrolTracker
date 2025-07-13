import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/models/vehicle_statistics.dart';

void main() {
  group('VehicleStatistics', () {
    test('should create empty statistics', () {
      final stats = VehicleStatistics.empty(1);
      
      expect(stats.vehicleId, equals(1));
      expect(stats.totalEntries, equals(0));
      expect(stats.totalFuelConsumed, equals(0.0));
      expect(stats.totalCostSpent, equals(0.0));
      expect(stats.averageConsumption, equals(0.0));
      expect(stats.countryBreakdown, isEmpty);
    });

    test('should create statistics from mock entries', () {
      final mockEntries = [
        MockFuelEntry(
          fuelAmount: 50.0,
          price: 75.0,
          consumption: 8.5,
          country: 'Canada',
          date: DateTime(2024, 1, 15),
          currentKm: 15000,
        ),
        MockFuelEntry(
          fuelAmount: 45.0,
          price: 68.0,
          consumption: 8.0,
          country: 'United States',
          date: DateTime(2024, 1, 20),
          currentKm: 15500,
        ),
        MockFuelEntry(
          fuelAmount: 52.0,
          price: 78.0,
          consumption: 9.0,
          country: 'Canada',
          date: DateTime(2024, 1, 25),
          currentKm: 16000,
        ),
      ];

      final stats = VehicleStatistics.fromEntries(1, mockEntries);

      expect(stats.vehicleId, equals(1));
      expect(stats.totalEntries, equals(3));
      expect(stats.totalFuelConsumed, equals(147.0));
      expect(stats.totalCostSpent, equals(221.0));
      expect(stats.averageConsumption, closeTo(8.5, 0.1));
      expect(stats.countryBreakdown['Canada'], equals(2));
      expect(stats.countryBreakdown['United States'], equals(1));
    });

    test('should format values correctly', () {
      final stats = VehicleStatistics(
        vehicleId: 1,
        totalEntries: 5,
        totalFuelConsumed: 250.5,
        totalCostSpent: 375.75,
        averageConsumption: 8.25,
        averageFuelAmount: 50.1,
        averageCost: 75.15,
        totalDistanceTraveled: 1000.0,
        countryBreakdown: {'Canada': 3, 'USA': 2},
      );

      expect(stats.formattedAverageConsumption, equals('8.3L/100km'));
      expect(stats.formattedTotalCost, equals('\$375.75'));
      expect(stats.formattedTotalFuel, equals('250.5L'));
      expect(stats.formattedTotalDistance, equals('1000km'));
    });

    test('should return correct efficiency rating', () {
      expect(
        VehicleStatistics.empty(1).copyWith(averageConsumption: 5.5).efficiencyRating,
        equals('Excellent'),
      );
      expect(
        VehicleStatistics.empty(1).copyWith(averageConsumption: 7.5).efficiencyRating,
        equals('Good'),
      );
      expect(
        VehicleStatistics.empty(1).copyWith(averageConsumption: 9.5).efficiencyRating,
        equals('Average'),
      );
      expect(
        VehicleStatistics.empty(1).copyWith(averageConsumption: 11.5).efficiencyRating,
        equals('Poor'),
      );
      expect(
        VehicleStatistics.empty(1).copyWith(averageConsumption: 15.0).efficiencyRating,
        equals('Very Poor'),
      );
    });

    test('should find most frequent country', () {
      final stats = VehicleStatistics.empty(1).copyWith(
        countryBreakdown: {'Canada': 5, 'USA': 2, 'Mexico': 1},
      );

      expect(stats.mostFrequentCountry, equals('Canada'));
    });

    test('should handle empty country breakdown', () {
      final stats = VehicleStatistics.empty(1);
      expect(stats.mostFrequentCountry, isNull);
    });

    test('should handle zero values gracefully', () {
      final stats = VehicleStatistics.empty(1);
      
      expect(stats.formattedAverageConsumption, equals('N/A'));
      expect(stats.formattedAverageCost, equals('N/A'));
      expect(stats.efficiencyRating, equals('Unknown'));
    });

    test('should copy with new values', () {
      final original = VehicleStatistics.empty(1);
      final copied = original.copyWith(
        totalEntries: 5,
        totalFuelConsumed: 100.0,
      );

      expect(copied.vehicleId, equals(1));
      expect(copied.totalEntries, equals(5));
      expect(copied.totalFuelConsumed, equals(100.0));
      expect(copied.totalCostSpent, equals(0.0)); // unchanged
    });

    test('should have proper equality', () {
      final stats1 = VehicleStatistics.empty(1).copyWith(totalEntries: 5);
      final stats2 = VehicleStatistics.empty(1).copyWith(totalEntries: 5);
      final stats3 = VehicleStatistics.empty(1).copyWith(totalEntries: 3);

      expect(stats1, equals(stats2));
      expect(stats1, isNot(equals(stats3)));
    });
  });
}

// Mock class for testing
class MockFuelEntry {
  final double fuelAmount;
  final double price;
  final double? consumption;
  final String country;
  final DateTime date;
  final double currentKm;

  MockFuelEntry({
    required this.fuelAmount,
    required this.price,
    this.consumption,
    required this.country,
    required this.date,
    required this.currentKm,
  });
}