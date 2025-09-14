/// Immutable model representing a completed currency conversion
/// 
/// This model stores the details of a currency conversion operation,
/// including original and converted amounts with the exchange rate used.
class CurrencyConversion {
  /// Original amount in source currency
  final double originalAmount;
  
  /// Source currency code (3-character ISO 4217)
  final String originalCurrency;
  
  /// Converted amount in target currency
  final double convertedAmount;
  
  /// Target currency code (3-character ISO 4217)
  final String targetCurrency;
  
  /// Exchange rate used for conversion (originalCurrency to targetCurrency)
  final double exchangeRate;
  
  /// Date when the exchange rate was effective
  final DateTime rateDate;
  
  /// Optional conversion timestamp (when conversion was performed)
  final DateTime? conversionTimestamp;

  const CurrencyConversion({
    required this.originalAmount,
    required this.originalCurrency,
    required this.convertedAmount,
    required this.targetCurrency,
    required this.exchangeRate,
    required this.rateDate,
    this.conversionTimestamp,
  });

  /// Create from JSON (API response or storage)
  factory CurrencyConversion.fromJson(Map<String, dynamic> json) {
    return CurrencyConversion(
      originalAmount: (json['originalAmount'] as num).toDouble(),
      originalCurrency: json['originalCurrency'] as String,
      convertedAmount: (json['convertedAmount'] as num).toDouble(),
      targetCurrency: json['targetCurrency'] as String,
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      rateDate: DateTime.parse(json['rateDate'] as String),
      conversionTimestamp: json['conversionTimestamp'] != null 
          ? DateTime.parse(json['conversionTimestamp'] as String)
          : null,
    );
  }

  /// Convert to JSON (API requests or storage)
  Map<String, dynamic> toJson() {
    return {
      'originalAmount': originalAmount,
      'originalCurrency': originalCurrency,
      'convertedAmount': convertedAmount,
      'targetCurrency': targetCurrency,
      'exchangeRate': exchangeRate,
      'rateDate': rateDate.toIso8601String(),
      'conversionTimestamp': conversionTimestamp?.toIso8601String(),
    };
  }

  /// Creates a copy with updated values
  CurrencyConversion copyWith({
    double? originalAmount,
    String? originalCurrency,
    double? convertedAmount,
    String? targetCurrency,
    double? exchangeRate,
    DateTime? rateDate,
    DateTime? conversionTimestamp,
  }) {
    return CurrencyConversion(
      originalAmount: originalAmount ?? this.originalAmount,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      rateDate: rateDate ?? this.rateDate,
      conversionTimestamp: conversionTimestamp ?? this.conversionTimestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencyConversion &&
        other.originalAmount == originalAmount &&
        other.originalCurrency == originalCurrency &&
        other.convertedAmount == convertedAmount &&
        other.targetCurrency == targetCurrency &&
        other.exchangeRate == exchangeRate &&
        other.rateDate == rateDate &&
        other.conversionTimestamp == conversionTimestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      originalAmount,
      originalCurrency,
      convertedAmount,
      targetCurrency,
      exchangeRate,
      rateDate,
      conversionTimestamp,
    );
  }

  @override
  String toString() {
    return 'CurrencyConversion(originalAmount: $originalAmount, originalCurrency: $originalCurrency, convertedAmount: $convertedAmount, targetCurrency: $targetCurrency, exchangeRate: $exchangeRate, rateDate: $rateDate, conversionTimestamp: $conversionTimestamp)';
  }
}

/// Extension methods for CurrencyConversion business logic
extension CurrencyConversionExtension on CurrencyConversion {
  /// Verify that the conversion calculation is correct
  bool get isCalculationValid {
    final expectedAmount = originalAmount * exchangeRate;
    const tolerance = 0.01; // Allow for small floating point errors
    return (convertedAmount - expectedAmount).abs() < tolerance;
  }
  
  /// Get the inverse conversion (convert back to original currency)
  CurrencyConversion get inverse {
    return CurrencyConversion(
      originalAmount: convertedAmount,
      originalCurrency: targetCurrency,
      convertedAmount: originalAmount,
      targetCurrency: originalCurrency,
      exchangeRate: 1.0 / exchangeRate,
      rateDate: rateDate,
      conversionTimestamp: conversionTimestamp,
    );
  }
  
  /// Format the conversion for display
  /// E.g., "€50.00 → $45.20 (rate: 0.904)"
  String get formattedConversion {
    return '${_formatCurrency(originalAmount, originalCurrency)} → '
           '${_formatCurrency(convertedAmount, targetCurrency)} '
           '(rate: ${exchangeRate.toStringAsFixed(4)})';
  }
  
  /// Format just the original amount with currency
  String get formattedOriginalAmount {
    return _formatCurrency(originalAmount, originalCurrency);
  }
  
  /// Format just the converted amount with currency  
  String get formattedConvertedAmount {
    return _formatCurrency(convertedAmount, targetCurrency);
  }
  
  /// Get conversion summary text
  String get conversionSummary {
    return '$originalCurrency to $targetCurrency at ${exchangeRate.toStringAsFixed(4)}';
  }
  
  /// Check if this conversion is between the same currencies (no-op conversion)
  bool get isSameCurrency => originalCurrency == targetCurrency;
  
  /// Get the conversion percentage change
  /// Positive means target currency is stronger, negative means weaker
  double get conversionPercentage {
    if (exchangeRate == 1.0) return 0.0;
    return ((exchangeRate - 1.0) * 100);
  }
  
  /// Get age of the rate used in this conversion
  int get rateAgeInHours {
    final now = DateTime.now();
    return now.difference(rateDate).inHours;
  }
  
  /// Check if the rate used is still fresh (within 24 hours)
  bool get isRateFresh => rateAgeInHours < 24;
  
  /// Validate that this conversion has valid data
  bool get isValid {
    return originalCurrency.length == 3 &&
           targetCurrency.length == 3 &&
           originalAmount > 0 &&
           convertedAmount > 0 &&
           exchangeRate > 0 &&
           isCalculationValid;
  }

  /// Helper method to format currency amounts
  String _formatCurrency(double amount, String currency) {
    // Basic formatting - can be enhanced with proper currency symbols
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$${amount.toStringAsFixed(2)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(2)}';
      case 'GBP':
        return '£${amount.toStringAsFixed(2)}';
      case 'JPY':
        return '¥${amount.toStringAsFixed(0)}'; // JPY typically has no decimals
      case 'CHF':
        return 'CHF ${amount.toStringAsFixed(2)}';
      case 'CAD':
        return 'CAD ${amount.toStringAsFixed(2)}';
      default:
        return '$currency ${amount.toStringAsFixed(2)}';
    }
  }
}