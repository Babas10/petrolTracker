import 'package:json_annotation/json_annotation.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';

part 'vehicle_dto.g.dart';

/// Data Transfer Object for Vehicle API requests
@JsonSerializable()
class VehicleCreateDto {
  final String name;
  final double initialKm;

  const VehicleCreateDto({
    required this.name,
    required this.initialKm,
  });

  factory VehicleCreateDto.fromJson(Map<String, dynamic> json) =>
      _$VehicleCreateDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleCreateDtoToJson(this);

  /// Convert DTO to domain model
  VehicleModel toModel() {
    return VehicleModel.create(
      name: name,
      initialKm: initialKm,
    );
  }
}

/// Data Transfer Object for Vehicle API responses
@JsonSerializable()
class VehicleResponseDto {
  final int id;
  final String name;
  final double initialKm;
  final DateTime createdAt;

  const VehicleResponseDto({
    required this.id,
    required this.name,
    required this.initialKm,
    required this.createdAt,
  });

  factory VehicleResponseDto.fromJson(Map<String, dynamic> json) =>
      _$VehicleResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VehicleResponseDtoToJson(this);

  /// Create DTO from domain model
  factory VehicleResponseDto.fromModel(VehicleModel model) {
    return VehicleResponseDto(
      id: model.id!,
      name: model.name,
      initialKm: model.initialKm,
      createdAt: model.createdAt,
    );
  }
}

/// Bulk operations DTO
@JsonSerializable()
class BulkVehiclesDto {
  final List<VehicleCreateDto> vehicles;

  const BulkVehiclesDto({
    required this.vehicles,
  });

  factory BulkVehiclesDto.fromJson(Map<String, dynamic> json) =>
      _$BulkVehiclesDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BulkVehiclesDtoToJson(this);
}

/// Bulk response DTO
@JsonSerializable()
class BulkVehiclesResponseDto {
  final List<VehicleResponseDto> created;
  final List<String> errors;

  const BulkVehiclesResponseDto({
    required this.created,
    required this.errors,
  });

  factory BulkVehiclesResponseDto.fromJson(Map<String, dynamic> json) =>
      _$BulkVehiclesResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BulkVehiclesResponseDtoToJson(this);
}