import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/chart_providers.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';

void main() {
  group('Providers Unit Tests', () {
    group('VehicleState', () {
      test('default constructor creates empty state', () {
        const state = VehicleState();
        expect(state.vehicles, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('copyWith updates fields correctly', () {
        const state = VehicleState();
        final vehicle = VehicleModel.create(name: 'Test', initialKm: 0);
        
        final newState = state.copyWith(
          vehicles: [vehicle],
          isLoading: true,
          error: 'test error',
        );

        expect(newState.vehicles, hasLength(1));
        expect(newState.isLoading, isTrue);
        expect(newState.error, equals('test error'));
      });

      test('equality works correctly', () {
        const state1 = VehicleState();
        const state2 = VehicleState();
        const state3 = VehicleState(isLoading: true);

        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });
    });

    group('FuelEntryState', () {
      test('default constructor creates empty state', () {
        const state = FuelEntryState();
        expect(state.entries, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('copyWith updates fields correctly', () {
        const state = FuelEntryState();
        final entry = FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 1000,
          fuelAmount: 40,
          price: 60,
          country: 'Canada',
          pricePerLiter: 1.5,
        );
        
        final newState = state.copyWith(
          entries: [entry],
          isLoading: true,
          error: 'test error',
        );

        expect(newState.entries, hasLength(1));
        expect(newState.isLoading, isTrue);
        expect(newState.error, equals('test error'));
      });

      test('equality works correctly', () {
        const state1 = FuelEntryState();
        const state2 = FuelEntryState();
        const state3 = FuelEntryState(isLoading: true);

        expect(state1, equals(state2));
        expect(state1, isNot(equals(state3)));
      });
    });

    group('Chart Data Classes', () {
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

    group('Model Validations', () {
      test('VehicleModel validation works', () {
        final validVehicle = VehicleModel.create(
          name: 'Valid Car',
          initialKm: 50000.0,
        );
        expect(validVehicle.isValid, isTrue);
        expect(validVehicle.validate(), isEmpty);

        final invalidVehicle = VehicleModel.create(
          name: '', // Invalid
          initialKm: -1000.0, // Invalid
        );
        expect(invalidVehicle.isValid, isFalse);
        expect(invalidVehicle.validate(), isNotEmpty);
      });

      test('FuelEntryModel validation works', () {
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
      });

      test('consumption calculation works', () {
        final consumption = FuelEntryModel.calculateConsumption(
          fuelAmount: 40.0,
          currentKm: 50400.0,
          previousKm: 50000.0,
        );
        expect(consumption, equals(10.0)); // 40L for 400km = 10L/100km
      });
    });

    group('Model Utilities', () {
      test('VehicleModel copyWith works', () {
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
      });

      test('FuelEntryModel copyWith works', () {
        final entry1 = FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime(2024, 1, 15),
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          country: 'Canada',
          pricePerLiter: 1.45,
        );

        final entry2 = entry1.copyWith(fuelAmount: 45.0);
        expect(entry2.fuelAmount, equals(45.0));
        expect(entry2.vehicleId, equals(1));
        expect(entry2.country, equals('Canada'));
      });
    });
  });
}