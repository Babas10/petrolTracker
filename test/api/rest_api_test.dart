import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/api/rest_api_service.dart';
import 'package:petrol_tracker/api/dto/vehicle_dto.dart';
import 'package:petrol_tracker/api/dto/fuel_entry_dto.dart';

void main() {
  group('REST API Service Tests', () {
    late RestApiService apiService;
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      apiService = RestApiService(container: container, port: 8081); // Use different port for testing
    });

    tearDown(() async {
      await apiService.stop();
      container.dispose();
    });

    test('should create REST API service', () {
      expect(apiService, isNotNull);
    });

    test('should create vehicle DTO from JSON', () {
      final json = {
        'name': 'Test Vehicle',
        'initialKm': 50000.0,
      };

      final dto = VehicleCreateDto.fromJson(json);
      expect(dto.name, equals('Test Vehicle'));
      expect(dto.initialKm, equals(50000.0));
    });

    test('should create fuel entry DTO from JSON', () {
      final json = {
        'vehicleId': 1,
        'date': '2024-01-15',
        'currentKm': 50400.0,
        'fuelAmount': 40.0,
        'price': 58.0,
        'country': 'Canada',
        'pricePerLiter': 1.45,
      };

      final dto = FuelEntryCreateDto.fromJson(json);
      expect(dto.vehicleId, equals(1));
      expect(dto.dateString, equals('2024-01-15'));
      expect(dto.currentKm, equals(50400.0));
      expect(dto.fuelAmount, equals(40.0));
      expect(dto.price, equals(58.0));
      expect(dto.country, equals('Canada'));
      expect(dto.pricePerLiter, equals(1.45));
    });

    test('should convert vehicle DTO to model', () {
      final dto = VehicleCreateDto(
        name: 'Test Vehicle',
        initialKm: 50000.0,
      );

      final model = dto.toModel();
      expect(model.name, equals('Test Vehicle'));
      expect(model.initialKm, equals(50000.0));
      expect(model.id, isNull);
    });

    test('should convert fuel entry DTO to model', () {
      final dto = FuelEntryCreateDto(
        vehicleId: 1,
        dateString: '2024-01-15',
        currentKm: 50400.0,
        fuelAmount: 40.0,
        price: 58.0,
        country: 'Canada',
        pricePerLiter: 1.45,
      );

      final model = dto.toModel();
      expect(model.vehicleId, equals(1));
      expect(model.date, equals(DateTime.parse('2024-01-15')));
      expect(model.currentKm, equals(50400.0));
      expect(model.fuelAmount, equals(40.0));
      expect(model.price, equals(58.0));
      expect(model.country, equals('Canada'));
      expect(model.pricePerLiter, equals(1.45));
      expect(model.id, isNull);
    });

    test('should serialize and deserialize vehicle response DTO', () {
      final dto = VehicleResponseDto(
        id: 1,
        name: 'Test Vehicle',
        initialKm: 50000.0,
        createdAt: DateTime.parse('2024-01-15T10:00:00Z'),
      );

      final json = dto.toJson();
      final deserializedDto = VehicleResponseDto.fromJson(json);

      expect(deserializedDto.id, equals(dto.id));
      expect(deserializedDto.name, equals(dto.name));
      expect(deserializedDto.initialKm, equals(dto.initialKm));
      expect(deserializedDto.createdAt, equals(dto.createdAt));
    });

    test('should handle bulk vehicle creation DTO', () {
      final json = {
        'vehicles': [
          {'name': 'Vehicle 1', 'initialKm': 10000.0},
          {'name': 'Vehicle 2', 'initialKm': 20000.0},
        ],
      };

      final dto = BulkVehiclesDto.fromJson(json);
      expect(dto.vehicles.length, equals(2));
      expect(dto.vehicles[0].name, equals('Vehicle 1'));
      expect(dto.vehicles[1].name, equals('Vehicle 2'));

      // Test round trip
      final jsonOut = dto.toJson();
      final dtoOut = BulkVehiclesDto.fromJson(jsonOut);
      expect(dtoOut.vehicles.length, equals(2));
    });

    test('should handle bulk fuel entry creation DTO', () {
      final json = {
        'fuelEntries': [
          {
            'vehicleId': 1,
            'date': '2024-01-15',
            'currentKm': 50400.0,
            'fuelAmount': 40.0,
            'price': 58.0,
            'country': 'Canada',
            'pricePerLiter': 1.45,
          },
          {
            'vehicleId': 1,
            'date': '2024-01-22',
            'currentKm': 50800.0,
            'fuelAmount': 38.0,
            'price': 55.1,
            'country': 'Canada',
            'pricePerLiter': 1.45,
          },
        ],
      };

      final dto = BulkFuelEntriesDto.fromJson(json);
      expect(dto.fuelEntries.length, equals(2));
      expect(dto.fuelEntries[0].vehicleId, equals(1));
      expect(dto.fuelEntries[1].vehicleId, equals(1));

      // Test round trip
      final jsonOut = dto.toJson();
      final dtoOut = BulkFuelEntriesDto.fromJson(jsonOut);
      expect(dtoOut.fuelEntries.length, equals(2));
    });
  });
}