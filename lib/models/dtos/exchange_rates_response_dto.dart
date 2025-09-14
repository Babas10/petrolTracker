import 'package:json_annotation/json_annotation.dart';
import 'currency_rate_dto.dart';

part 'exchange_rates_response_dto.g.dart';

/// DTO for the exchange rates API response from the currency microservice
/// 
/// This represents the JSON structure returned by the API when fetching
/// exchange rates for a specific base currency.
@JsonSerializable()
class ExchangeRatesResponseDto {
  /// Base currency for all the rates in this response
  @JsonKey(name: 'base_currency')
  final String baseCurrency;
  
  /// Map of currency codes to their rate information
  /// Key: target currency code, Value: rate details
  final Map<String, CurrencyRateDto> rates;
  
  /// When these rates were fetched/published
  @JsonKey(name: 'fetch_date')
  final DateTime fetchDate;
  
  /// API response timestamp
  final DateTime? timestamp;
  
  /// Optional status message from API
  final String? status;
  
  /// Optional error message if request partially failed
  final String? error;

  const ExchangeRatesResponseDto({
    required this.baseCurrency,
    required this.rates,
    required this.fetchDate,
    this.timestamp,
    this.status,
    this.error,
  });

  /// Create from JSON (API response)
  factory ExchangeRatesResponseDto.fromJson(Map<String, dynamic> json) => 
      _$ExchangeRatesResponseDtoFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$ExchangeRatesResponseDtoToJson(this);
}

/// Extension methods for ExchangeRatesResponseDto business logic
extension ExchangeRatesResponseDtoExtension on ExchangeRatesResponseDto {
  /// Check if the response contains valid data
  bool get isValid {
    return baseCurrency.length == 3 &&
           rates.isNotEmpty &&
           rates.values.every((rate) => rate.isValid);
  }
  
  /// Get a specific rate for a target currency
  CurrencyRateDto? getRateFor(String targetCurrency) {
    return rates[targetCurrency.toUpperCase()];
  }
  
  /// Check if response contains a rate for the target currency
  bool hasRateFor(String targetCurrency) {
    return rates.containsKey(targetCurrency.toUpperCase());
  }
  
  /// Get all available target currencies
  List<String> get availableCurrencies {
    return rates.keys.toList()..sort();
  }
  
  /// Get number of rates in this response
  int get rateCount => rates.length;
  
  /// Check if this response is from today
  bool get isFromToday {
    final today = DateTime.now();
    final fetchDay = DateTime(fetchDate.year, fetchDate.month, fetchDate.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    return fetchDay.isAtSameMomentAs(todayDay);
  }
  
  /// Get age of this response in hours
  int get ageInHours {
    final now = DateTime.now();
    return now.difference(timestamp ?? fetchDate).inHours;
  }
  
  /// Check if response is stale (older than 24 hours)
  bool get isStale => ageInHours >= 24;
  
  /// Get a summary of this response
  String get summary {
    return 'Base: $baseCurrency, Rates: ${rateCount}, '
           'Fetched: ${fetchDate.toIso8601String().split('T')[0]}';
  }
}