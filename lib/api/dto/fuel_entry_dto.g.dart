// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FuelEntryCreateDto _$FuelEntryCreateDtoFromJson(Map<String, dynamic> json) =>
    FuelEntryCreateDto(
      vehicleId: (json['vehicleId'] as num).toInt(),
      dateString: json['date'] as String,
      currentKm: (json['currentKm'] as num).toDouble(),
      fuelAmount: (json['fuelAmount'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      country: json['country'] as String,
      pricePerLiter: (json['pricePerLiter'] as num).toDouble(),
      consumption: (json['consumption'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$FuelEntryCreateDtoToJson(FuelEntryCreateDto instance) =>
    <String, dynamic>{
      'vehicleId': instance.vehicleId,
      'date': instance.dateString,
      'currentKm': instance.currentKm,
      'fuelAmount': instance.fuelAmount,
      'price': instance.price,
      'country': instance.country,
      'pricePerLiter': instance.pricePerLiter,
      'consumption': instance.consumption,
    };

FuelEntryResponseDto _$FuelEntryResponseDtoFromJson(
  Map<String, dynamic> json,
) => FuelEntryResponseDto(
  id: (json['id'] as num).toInt(),
  vehicleId: (json['vehicleId'] as num).toInt(),
  dateString: json['date'] as String,
  currentKm: (json['currentKm'] as num).toDouble(),
  fuelAmount: (json['fuelAmount'] as num).toDouble(),
  price: (json['price'] as num).toDouble(),
  country: json['country'] as String,
  pricePerLiter: (json['pricePerLiter'] as num).toDouble(),
  consumption: (json['consumption'] as num?)?.toDouble(),
);

Map<String, dynamic> _$FuelEntryResponseDtoToJson(
  FuelEntryResponseDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'vehicleId': instance.vehicleId,
  'date': instance.dateString,
  'currentKm': instance.currentKm,
  'fuelAmount': instance.fuelAmount,
  'price': instance.price,
  'country': instance.country,
  'pricePerLiter': instance.pricePerLiter,
  'consumption': instance.consumption,
};

BulkFuelEntriesDto _$BulkFuelEntriesDtoFromJson(Map<String, dynamic> json) =>
    BulkFuelEntriesDto(
      fuelEntries: (json['fuelEntries'] as List<dynamic>)
          .map((e) => FuelEntryCreateDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BulkFuelEntriesDtoToJson(BulkFuelEntriesDto instance) =>
    <String, dynamic>{'fuelEntries': instance.fuelEntries};

BulkFuelEntriesResponseDto _$BulkFuelEntriesResponseDtoFromJson(
  Map<String, dynamic> json,
) => BulkFuelEntriesResponseDto(
  created: (json['created'] as List<dynamic>)
      .map((e) => FuelEntryResponseDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  errors: (json['errors'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$BulkFuelEntriesResponseDtoToJson(
  BulkFuelEntriesResponseDto instance,
) => <String, dynamic>{'created': instance.created, 'errors': instance.errors};

BulkDataDto _$BulkDataDtoFromJson(Map<String, dynamic> json) => BulkDataDto(
  vehicles: (json['vehicles'] as List<dynamic>?)
      ?.map((e) => VehicleCreateDto.fromJson(e as Map<String, dynamic>))
      .toList(),
  fuelEntries: (json['fuelEntries'] as List<dynamic>?)
      ?.map((e) => FuelEntryCreateDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$BulkDataDtoToJson(BulkDataDto instance) =>
    <String, dynamic>{
      'vehicles': instance.vehicles,
      'fuelEntries': instance.fuelEntries,
    };

BulkDataResponseDto _$BulkDataResponseDtoFromJson(Map<String, dynamic> json) =>
    BulkDataResponseDto(
      vehiclesCreated: (json['vehiclesCreated'] as List<dynamic>)
          .map((e) => VehicleResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      fuelEntriesCreated: (json['fuelEntriesCreated'] as List<dynamic>)
          .map((e) => FuelEntryResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      errors: (json['errors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$BulkDataResponseDtoToJson(
  BulkDataResponseDto instance,
) => <String, dynamic>{
  'vehiclesCreated': instance.vehiclesCreated,
  'fuelEntriesCreated': instance.fuelEntriesCreated,
  'errors': instance.errors,
};
