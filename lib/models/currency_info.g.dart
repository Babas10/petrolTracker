// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CurrencyInfoImpl _$$CurrencyInfoImplFromJson(Map<String, dynamic> json) =>
    _$CurrencyInfoImpl(
      code: json['code'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      decimalPlaces: json['decimalPlaces'] as int,
      countries:
          (json['countries'] as List<dynamic>).map((e) => e as String).toList(),
      alternativeSymbols: (json['alternativeSymbols'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isInternational: json['isInternational'] as bool? ?? false,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$CurrencyInfoImplToJson(_$CurrencyInfoImpl instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'symbol': instance.symbol,
      'decimalPlaces': instance.decimalPlaces,
      'countries': instance.countries,
      'alternativeSymbols': instance.alternativeSymbols,
      'isInternational': instance.isInternational,
      'notes': instance.notes,
    };