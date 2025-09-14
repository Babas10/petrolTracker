/// Immutable model representing user's currency preferences and settings
/// 
/// This model stores the user's preferred currency display options
/// and controls how multi-currency data is presented in the UI.
class CurrencySettings {
  /// User's primary/preferred currency (3-character ISO 4217)
  /// All amounts will be displayed in this currency when possible
  final String primaryCurrency;
  
  /// Whether to show original amounts alongside converted amounts
  /// E.g., "€45.20 ($50.00)" vs just "$50.00"
  final bool showOriginalAmounts;
  
  /// Whether to display exchange rates in the UI
  /// E.g., show "rate: 0.904" in conversion displays
  final bool showExchangeRates;
  
  /// Whether to show currency conversion badges/indicators
  /// Helps users identify which amounts have been converted
  final bool showConversionIndicators;
  
  /// Number of decimal places to show for currency amounts
  /// Most currencies use 2, but some like JPY use 0
  final int decimalPlaces;
  
  /// Whether to automatically update exchange rates daily
  final bool autoUpdateRates;
  
  /// Maximum age in hours before rates are considered stale
  final int maxRateAgeHours;
  
  /// List of favorite/frequently used currencies for quick access
  final List<String> favoriteCurrencies;
  
  /// When this settings object was last updated
  final DateTime? lastUpdated;

  const CurrencySettings({
    this.primaryCurrency = 'USD',
    this.showOriginalAmounts = true,
    this.showExchangeRates = true,
    this.showConversionIndicators = true,
    this.decimalPlaces = 2,
    this.autoUpdateRates = true,
    this.maxRateAgeHours = 24,
    this.favoriteCurrencies = const [],
    this.lastUpdated,
  });

  /// Create from JSON (for persistence)
  factory CurrencySettings.fromJson(Map<String, dynamic> json) {
    return CurrencySettings(
      primaryCurrency: json['primaryCurrency'] as String? ?? 'USD',
      showOriginalAmounts: json['showOriginalAmounts'] as bool? ?? true,
      showExchangeRates: json['showExchangeRates'] as bool? ?? true,
      showConversionIndicators: json['showConversionIndicators'] as bool? ?? true,
      decimalPlaces: json['decimalPlaces'] as int? ?? 2,
      autoUpdateRates: json['autoUpdateRates'] as bool? ?? true,
      maxRateAgeHours: json['maxRateAgeHours'] as int? ?? 24,
      favoriteCurrencies: (json['favoriteCurrencies'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? const [],
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'] as String)
          : null,
    );
  }

  /// Convert to JSON (for persistence)
  Map<String, dynamic> toJson() {
    return {
      'primaryCurrency': primaryCurrency,
      'showOriginalAmounts': showOriginalAmounts,
      'showExchangeRates': showExchangeRates,
      'showConversionIndicators': showConversionIndicators,
      'decimalPlaces': decimalPlaces,
      'autoUpdateRates': autoUpdateRates,
      'maxRateAgeHours': maxRateAgeHours,
      'favoriteCurrencies': favoriteCurrencies,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  /// Creates a copy with updated values
  CurrencySettings copyWith({
    String? primaryCurrency,
    bool? showOriginalAmounts,
    bool? showExchangeRates,
    bool? showConversionIndicators,
    int? decimalPlaces,
    bool? autoUpdateRates,
    int? maxRateAgeHours,
    List<String>? favoriteCurrencies,
    DateTime? lastUpdated,
  }) {
    return CurrencySettings(
      primaryCurrency: primaryCurrency ?? this.primaryCurrency,
      showOriginalAmounts: showOriginalAmounts ?? this.showOriginalAmounts,
      showExchangeRates: showExchangeRates ?? this.showExchangeRates,
      showConversionIndicators: showConversionIndicators ?? this.showConversionIndicators,
      decimalPlaces: decimalPlaces ?? this.decimalPlaces,
      autoUpdateRates: autoUpdateRates ?? this.autoUpdateRates,
      maxRateAgeHours: maxRateAgeHours ?? this.maxRateAgeHours,
      favoriteCurrencies: favoriteCurrencies ?? this.favoriteCurrencies,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencySettings &&
        other.primaryCurrency == primaryCurrency &&
        other.showOriginalAmounts == showOriginalAmounts &&
        other.showExchangeRates == showExchangeRates &&
        other.showConversionIndicators == showConversionIndicators &&
        other.decimalPlaces == decimalPlaces &&
        other.autoUpdateRates == autoUpdateRates &&
        other.maxRateAgeHours == maxRateAgeHours &&
        _listEquals(other.favoriteCurrencies, favoriteCurrencies) &&
        other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return Object.hash(
      primaryCurrency,
      showOriginalAmounts,
      showExchangeRates,
      showConversionIndicators,
      decimalPlaces,
      autoUpdateRates,
      maxRateAgeHours,
      Object.hashAll(favoriteCurrencies),
      lastUpdated,
    );
  }

  @override
  String toString() {
    return 'CurrencySettings(primaryCurrency: $primaryCurrency, showOriginalAmounts: $showOriginalAmounts, showExchangeRates: $showExchangeRates, showConversionIndicators: $showConversionIndicators, decimalPlaces: $decimalPlaces, autoUpdateRates: $autoUpdateRates, maxRateAgeHours: $maxRateAgeHours, favoriteCurrencies: $favoriteCurrencies, lastUpdated: $lastUpdated)';
  }

  /// Helper method to compare lists
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Extension methods for CurrencySettings business logic
extension CurrencySettingsExtension on CurrencySettings {
  /// Validate that the settings have valid values
  bool get isValid {
    return primaryCurrency.length == 3 &&
           decimalPlaces >= 0 && 
           decimalPlaces <= 4 &&
           maxRateAgeHours > 0 &&
           maxRateAgeHours <= 168 && // Max 7 days
           _allCurrenciesValid();
  }
  
  /// Check if all favorite currencies have valid codes
  bool _allCurrenciesValid() {
    return favoriteCurrencies.every((currency) => currency.length == 3);
  }
  
  /// Get display format for amounts in the primary currency
  String formatPrimaryAmount(double amount) {
    return _formatCurrencyAmount(amount, primaryCurrency);
  }
  
  /// Format any currency amount according to settings
  String formatAmount(double amount, String currency) {
    if (currency == 'JPY' || currency == 'KRW') {
      // These currencies typically don't use decimal places
      return _formatCurrencyAmount(amount, currency, 0);
    }
    return _formatCurrencyAmount(amount, currency, decimalPlaces);
  }
  
  /// Format with original amount display if enabled
  String formatWithOriginal(double convertedAmount, double? originalAmount, String originalCurrency) {
    final convertedStr = formatPrimaryAmount(convertedAmount);
    
    if (!showOriginalAmounts || originalAmount == null) {
      return convertedStr;
    }
    
    final originalStr = formatAmount(originalAmount, originalCurrency);
    return '$originalStr ($convertedStr)';
  }
  
  /// Add a currency to favorites if not already present
  CurrencySettings addFavoriteCurrency(String currency) {
    if (currency.length != 3 || favoriteCurrencies.contains(currency)) {
      return this;
    }
    
    return copyWith(
      favoriteCurrencies: [...favoriteCurrencies, currency.toUpperCase()],
      lastUpdated: DateTime.now(),
    );
  }
  
  /// Remove a currency from favorites
  CurrencySettings removeFavoriteCurrency(String currency) {
    final updatedFavorites = favoriteCurrencies
        .where((c) => c != currency.toUpperCase())
        .toList();
    
    return copyWith(
      favoriteCurrencies: updatedFavorites,
      lastUpdated: DateTime.now(),
    );
  }
  
  /// Update primary currency and mark as updated
  CurrencySettings updatePrimaryCurrency(String newCurrency) {
    if (newCurrency.length != 3) return this;
    
    return copyWith(
      primaryCurrency: newCurrency.toUpperCase(),
      lastUpdated: DateTime.now(),
    );
  }
  
  /// Check if rates should be considered stale
  bool isRateStale(DateTime rateDate) {
    final now = DateTime.now();
    final ageInHours = now.difference(rateDate).inHours;
    return ageInHours >= maxRateAgeHours;
  }
  
  /// Get recommended currencies based on primary currency
  List<String> get recommendedCurrencies {
    switch (primaryCurrency) {
      case 'USD':
        return ['EUR', 'GBP', 'CAD', 'AUD', 'JPY'];
      case 'EUR':
        return ['USD', 'GBP', 'CHF', 'NOK', 'SEK'];
      case 'GBP':
        return ['USD', 'EUR', 'CAD', 'AUD', 'CHF'];
      default:
        return ['USD', 'EUR', 'GBP', 'JPY', 'CHF'];
    }
  }
  
  /// Helper method to format currency amounts
  String _formatCurrencyAmount(double amount, String currency, [int? customDecimals]) {
    final decimals = customDecimals ?? decimalPlaces;
    
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$${amount.toStringAsFixed(decimals)}';
      case 'EUR':
        return '€${amount.toStringAsFixed(decimals)}';
      case 'GBP':
        return '£${amount.toStringAsFixed(decimals)}';
      case 'JPY':
        return '¥${amount.toStringAsFixed(0)}';
      case 'KRW':
        return '₩${amount.toStringAsFixed(0)}';
      case 'CHF':
        return 'CHF ${amount.toStringAsFixed(decimals)}';
      case 'CAD':
        return 'CAD ${amount.toStringAsFixed(decimals)}';
      case 'AUD':
        return 'AUD ${amount.toStringAsFixed(decimals)}';
      case 'CNY':
        return '¥${amount.toStringAsFixed(decimals)}';
      case 'INR':
        return '₹${amount.toStringAsFixed(decimals)}';
      default:
        return '$currency ${amount.toStringAsFixed(decimals)}';
    }
  }
}