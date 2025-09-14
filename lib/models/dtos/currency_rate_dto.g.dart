// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_rate_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CurrencyRateDto _$CurrencyRateDtoFromJson(Map<String, dynamic> json) =>
    CurrencyRateDto(
      rate: json['rate'] as String,
      rateDate: json['rate_date'] as String,
      source: json['source'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      bid: json['bid'] as String?,
      ask: json['ask'] as String?,
    );

Map<String, dynamic> _$CurrencyRateDtoToJson(CurrencyRateDto instance) =>
    <String, dynamic>{
      'rate': instance.rate,
      'rate_date': instance.rateDate,
      'source': instance.source,
      'confidence': instance.confidence,
      'bid': instance.bid,
      'ask': instance.ask,
    };
