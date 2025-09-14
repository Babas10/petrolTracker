// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_rates_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExchangeRatesResponseDto _$ExchangeRatesResponseDtoFromJson(
  Map<String, dynamic> json,
) => ExchangeRatesResponseDto(
  baseCurrency: json['base_currency'] as String,
  rates: (json['rates'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, CurrencyRateDto.fromJson(e as Map<String, dynamic>)),
  ),
  fetchDate: DateTime.parse(json['fetch_date'] as String),
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
  status: json['status'] as String?,
  error: json['error'] as String?,
);

Map<String, dynamic> _$ExchangeRatesResponseDtoToJson(
  ExchangeRatesResponseDto instance,
) => <String, dynamic>{
  'base_currency': instance.baseCurrency,
  'rates': instance.rates,
  'fetch_date': instance.fetchDate.toIso8601String(),
  'timestamp': instance.timestamp?.toIso8601String(),
  'status': instance.status,
  'error': instance.error,
};
