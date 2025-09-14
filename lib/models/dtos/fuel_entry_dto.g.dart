// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FuelEntryDto _$FuelEntryDtoFromJson(Map<String, dynamic> json) => FuelEntryDto(
  id: (json['id'] as num?)?.toInt(),
  vehicleId: (json['vehicle_id'] as num).toInt(),
  date: DateTime.parse(json['date'] as String),
  currentKm: (json['current_km'] as num).toDouble(),
  fuelAmount: (json['fuel_amount'] as num).toDouble(),
  price: (json['price'] as num).toDouble(),
  originalAmount: (json['original_amount'] as num?)?.toDouble(),
  currency: json['currency'] as String? ?? 'USD',
  country: json['country'] as String,
  pricePerLiter: (json['price_per_liter'] as num).toDouble(),
  consumption: (json['consumption'] as num?)?.toDouble(),
  isFullTank: json['is_full_tank'] as bool? ?? true,
  exchangeRate: (json['exchange_rate'] as num?)?.toDouble(),
  rateDate: json['rate_date'] == null
      ? null
      : DateTime.parse(json['rate_date'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$FuelEntryDtoToJson(FuelEntryDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'vehicle_id': instance.vehicleId,
      'date': instance.date.toIso8601String(),
      'current_km': instance.currentKm,
      'fuel_amount': instance.fuelAmount,
      'price': instance.price,
      'original_amount': instance.originalAmount,
      'currency': instance.currency,
      'country': instance.country,
      'price_per_liter': instance.pricePerLiter,
      'consumption': instance.consumption,
      'is_full_tank': instance.isFullTank,
      'exchange_rate': instance.exchangeRate,
      'rate_date': instance.rateDate?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
