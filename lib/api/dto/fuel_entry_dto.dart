import 'package:json_annotation/json_annotation.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'vehicle_dto.dart';

part 'fuel_entry_dto.g.dart';

/// Data Transfer Object for FuelEntry API requests
@JsonSerializable()
class FuelEntryCreateDto {
  final int vehicleId;
  @JsonKey(name: 'date')
  final String dateString;
  final double currentKm;
  final double fuelAmount;
  final double price;
  final String country;
  final double pricePerLiter;
  final double? consumption;

  const FuelEntryCreateDto({
    required this.vehicleId,
    required this.dateString,
    required this.currentKm,
    required this.fuelAmount,
    required this.price,
    required this.country,
    required this.pricePerLiter,
    this.consumption,
  });

  factory FuelEntryCreateDto.fromJson(Map<String, dynamic> json) =>
      _$FuelEntryCreateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FuelEntryCreateDtoToJson(this);

  /// Convert DTO to domain model
  FuelEntryModel toModel() {
    final date = DateTime.parse(dateString);
    return FuelEntryModel.create(
      vehicleId: vehicleId,
      date: date,
      currentKm: currentKm,
      fuelAmount: fuelAmount,
      price: price,
      country: country,
      pricePerLiter: pricePerLiter,
      consumption: consumption,
    );
  }
}

/// Data Transfer Object for FuelEntry API responses
@JsonSerializable()
class FuelEntryResponseDto {
  final int id;
  final int vehicleId;
  @JsonKey(name: 'date')
  final String dateString;
  final double currentKm;
  final double fuelAmount;
  final double price;
  final String country;
  final double pricePerLiter;
  final double? consumption;

  const FuelEntryResponseDto({
    required this.id,
    required this.vehicleId,
    required this.dateString,
    required this.currentKm,
    required this.fuelAmount,
    required this.price,
    required this.country,
    required this.pricePerLiter,
    this.consumption,
  });

  factory FuelEntryResponseDto.fromJson(Map<String, dynamic> json) =>
      _$FuelEntryResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FuelEntryResponseDtoToJson(this);

  /// Create DTO from domain model
  factory FuelEntryResponseDto.fromModel(FuelEntryModel model) {
    return FuelEntryResponseDto(
      id: model.id!,
      vehicleId: model.vehicleId,
      dateString: model.date.toIso8601String().split('T')[0],
      currentKm: model.currentKm,
      fuelAmount: model.fuelAmount,
      price: model.price,
      country: model.country,
      pricePerLiter: model.pricePerLiter,
      consumption: model.consumption,
    );
  }
}

/// Bulk operations DTO
@JsonSerializable()
class BulkFuelEntriesDto {
  final List<FuelEntryCreateDto> fuelEntries;

  const BulkFuelEntriesDto({
    required this.fuelEntries,
  });

  factory BulkFuelEntriesDto.fromJson(Map<String, dynamic> json) =>
      _$BulkFuelEntriesDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BulkFuelEntriesDtoToJson(this);
}

/// Bulk response DTO
@JsonSerializable()
class BulkFuelEntriesResponseDto {
  final List<FuelEntryResponseDto> created;
  final List<String> errors;

  const BulkFuelEntriesResponseDto({
    required this.created,
    required this.errors,
  });

  factory BulkFuelEntriesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$BulkFuelEntriesResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BulkFuelEntriesResponseDtoToJson(this);
}

/// Combined bulk operations DTO
@JsonSerializable()
class BulkDataDto {
  final List<VehicleCreateDto>? vehicles;
  final List<FuelEntryCreateDto>? fuelEntries;

  const BulkDataDto({
    this.vehicles,
    this.fuelEntries,
  });

  factory BulkDataDto.fromJson(Map<String, dynamic> json) =>
      _$BulkDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BulkDataDtoToJson(this);
}

/// Combined bulk response DTO
@JsonSerializable()
class BulkDataResponseDto {
  final List<VehicleResponseDto> vehiclesCreated;
  final List<FuelEntryResponseDto> fuelEntriesCreated;
  final List<String> errors;

  const BulkDataResponseDto({
    required this.vehiclesCreated,
    required this.fuelEntriesCreated,
    required this.errors,
  });

  factory BulkDataResponseDto.fromJson(Map<String, dynamic> json) =>
      _$BulkDataResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BulkDataResponseDtoToJson(this);
}

