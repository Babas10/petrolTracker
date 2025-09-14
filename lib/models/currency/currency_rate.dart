/// Immutable model representing an exchange rate between two currencies
/// 
/// This model is used to store exchange rates from the currency microservice
/// and provides methods for rate calculations and formatting.
class CurrencyRate {
  /// Base currency code (3-character ISO 4217)
  final String baseCurrency;
  
  /// Target currency code (3-character ISO 4217)
  final String targetCurrency;
  
  /// Exchange rate from base to target currency
  /// E.g., if USD to EUR rate is 0.85, then 1 USD = 0.85 EUR
  final double rate;
  
  /// Date when this rate was effective/published
  final DateTime rateDate;
  
  /// When this rate information was last updated in our system
  final DateTime? lastUpdated;

  const CurrencyRate({
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.rateDate,
    this.lastUpdated,
  });

  /// Create from JSON (API response)
  factory CurrencyRate.fromJson(Map<String, dynamic> json) {
    return CurrencyRate(
      baseCurrency: json['baseCurrency'] as String,
      targetCurrency: json['targetCurrency'] as String,
      rate: (json['rate'] as num).toDouble(),
      rateDate: DateTime.parse(json['rateDate'] as String),
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  /// Convert to JSON (for API requests and persistence)
  Map<String, dynamic> toJson() {
    return {
      'baseCurrency': baseCurrency,
      'targetCurrency': targetCurrency,
      'rate': rate,
      'rateDate': rateDate.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// Creates a copy with updated values
  CurrencyRate copyWith({
    String? baseCurrency,
    String? targetCurrency,
    double? rate,
    DateTime? rateDate,
    DateTime? lastUpdated,
  }) {
    return CurrencyRate(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      rate: rate ?? this.rate,
      rateDate: rateDate ?? this.rateDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencyRate &&
        other.baseCurrency == baseCurrency &&
        other.targetCurrency == targetCurrency &&
        other.rate == rate &&
        other.rateDate == rateDate &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return Object.hash(
      baseCurrency,
      targetCurrency,
      rate,
      rateDate,
      lastUpdated,
    );
  }

  @override
  String toString() {
    return 'CurrencyRate(baseCurrency: $baseCurrency, targetCurrency: $targetCurrency, rate: $rate, rateDate: $rateDate, lastUpdated: $lastUpdated)';
  }
}

/// Extension methods for CurrencyRate business logic
extension CurrencyRateExtension on CurrencyRate {
  /// Convert an amount using this exchange rate
  double convertAmount(double amount) => amount * rate;
  
  /// Get the inverse rate (target to base)
  double get inverseRate => 1.0 / rate;
  
  /// Convert an amount using the inverse rate
  double convertAmountInverse(double amount) => amount * inverseRate;
  
  /// Check if this rate is fresh (within the last 24 hours)
  bool get isFresh {
    final now = DateTime.now();
    final age = now.difference(lastUpdated ?? rateDate);
    return age.inHours < 24;
  }
  
  /// Get age of this rate in hours
  int get ageInHours {
    final now = DateTime.now();
    return now.difference(lastUpdated ?? rateDate).inHours;
  }
  
  /// Format the rate for display (e.g., "1 USD = 0.85 EUR")
  String get formattedRate {
    return '1 $baseCurrency = ${rate.toStringAsFixed(4)} $targetCurrency';
  }
  
  /// Format the inverse rate for display (e.g., "1 EUR = 1.18 USD")
  String get formattedInverseRate {
    return '1 $targetCurrency = ${inverseRate.toStringAsFixed(4)} $baseCurrency';
  }
  
  /// Get currency pair key (e.g., "USD-EUR")
  String get currencyPair => '$baseCurrency-$targetCurrency';
  
  /// Get inverse currency pair key (e.g., "EUR-USD")
  String get inverseCurrencyPair => '$targetCurrency-$baseCurrency';
  
  /// Validate that this rate has valid data
  bool get isValid {
    return baseCurrency.length == 3 &&
           targetCurrency.length == 3 &&
           baseCurrency != targetCurrency &&
           rate > 0 &&
           rate < 1000; // Reasonable upper bound
  }
}