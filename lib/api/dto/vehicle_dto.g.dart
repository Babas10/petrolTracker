// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleCreateDto _$VehicleCreateDtoFromJson(Map<String, dynamic> json) =>
    VehicleCreateDto(
      name: json['name'] as String,
      initialKm: (json['initialKm'] as num).toDouble(),
    );

Map<String, dynamic> _$VehicleCreateDtoToJson(VehicleCreateDto instance) =>
    <String, dynamic>{'name': instance.name, 'initialKm': instance.initialKm};

VehicleResponseDto _$VehicleResponseDtoFromJson(Map<String, dynamic> json) =>
    VehicleResponseDto(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      initialKm: (json['initialKm'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$VehicleResponseDtoToJson(VehicleResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'initialKm': instance.initialKm,
      'createdAt': instance.createdAt.toIso8601String(),
    };

BulkVehiclesDto _$BulkVehiclesDtoFromJson(Map<String, dynamic> json) =>
    BulkVehiclesDto(
      vehicles: (json['vehicles'] as List<dynamic>)
          .map((e) => VehicleCreateDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BulkVehiclesDtoToJson(BulkVehiclesDto instance) =>
    <String, dynamic>{'vehicles': instance.vehicles};

BulkVehiclesResponseDto _$BulkVehiclesResponseDtoFromJson(
  Map<String, dynamic> json,
) => BulkVehiclesResponseDto(
  created: (json['created'] as List<dynamic>)
      .map((e) => VehicleResponseDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  errors: (json['errors'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$BulkVehiclesResponseDtoToJson(
  BulkVehiclesResponseDto instance,
) => <String, dynamic>{'created': instance.created, 'errors': instance.errors};
