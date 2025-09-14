import 'package:json_annotation/json_annotation.dart';

part 'currency_rate_dto.g.dart';

/// DTO for individual currency rate from the API response
/// 
/// This represents a single exchange rate entry within the
/// ExchangeRatesResponseDto rates map.
@JsonSerializable()
class CurrencyRateDto {
  /// Exchange rate as string (to maintain precision from API)
  final String rate;
  
  /// Date when this rate was effective/published
  @JsonKey(name: 'rate_date')
  final String rateDate;
  
  /// Optional additional metadata from API
  final String? source;
  
  /// Optional confidence level (0.0 to 1.0)
  final double? confidence;
  
  /// Optional bid rate (for financial applications)
  final String? bid;
  
  /// Optional ask rate (for financial applications)
  final String? ask;

  const CurrencyRateDto({
    required this.rate,
    required this.rateDate,
    this.source,
    this.confidence,
    this.bid,
    this.ask,
  });

  /// Create from JSON (API response)
  factory CurrencyRateDto.fromJson(Map<String, dynamic> json) => 
      _$CurrencyRateDtoFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$CurrencyRateDtoToJson(this);
}

/// Extension methods for CurrencyRateDto business logic
extension CurrencyRateDtoExtension on CurrencyRateDto {
  /// Convert rate string to double
  double get rateValue {
    try {
      return double.parse(rate);
    } catch (e) {
      return 0.0;
    }
  }
  
  /// Convert rate date string to DateTime
  DateTime? get rateDateValue {
    try {
      return DateTime.parse(rateDate);
    } catch (e) {
      return null;
    }
  }
  
  /// Get bid rate as double
  double? get bidValue {
    if (bid == null) return null;
    try {
      return double.parse(bid!);
    } catch (e) {
      return null;
    }
  }
  
  /// Get ask rate as double
  double? get askValue {
    if (ask == null) return null;
    try {
      return double.parse(ask!);
    } catch (e) {
      return null;
    }
  }
  
  /// Check if this rate has valid data
  bool get isValid {
    final rateVal = rateValue;
    final dateVal = rateDateValue;
    return rateVal > 0 && 
           rateVal < 1000 && // Reasonable upper bound
           dateVal != null;
  }
  
  /// Get spread between bid and ask (if available)
  double? get spread {
    final bidVal = bidValue;
    final askVal = askValue;
    if (bidVal == null || askVal == null) return null;
    return askVal - bidVal;
  }
  
  /// Get mid-point between bid and ask rates
  double? get midRate {
    final bidVal = bidValue;
    final askVal = askValue;
    if (bidVal == null || askVal == null) return null;
    return (bidVal + askVal) / 2;
  }
  
  /// Check if this rate has bid/ask data
  bool get hasBidAskData => bid != null && ask != null;
  
  /// Get confidence level as percentage string
  String get confidencePercentage {
    if (confidence == null) return 'N/A';
    return '${(confidence! * 100).toStringAsFixed(1)}%';
  }
  
  /// Check if confidence level is high (>= 0.9)
  bool get isHighConfidence => (confidence ?? 0.0) >= 0.9;
  
  /// Get age of this rate in hours
  int get ageInHours {
    final dateVal = rateDateValue;
    if (dateVal == null) return 0;
    final now = DateTime.now();
    return now.difference(dateVal).inHours;
  }
  
  /// Check if this rate is fresh (less than 24 hours old)
  bool get isFresh => ageInHours < 24;
  
  /// Format the rate for display
  String get formattedRate {
    return rateValue.toStringAsFixed(4);
  }
  
  /// Get a summary string for this rate
  String get summary {
    final dateStr = rateDateValue?.toIso8601String().split('T')[0] ?? 'Unknown';
    return 'Rate: ${formattedRate}, Date: $dateStr, Age: ${ageInHours}h';
  }
}