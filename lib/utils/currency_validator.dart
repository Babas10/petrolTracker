/// Utility class for validating currency codes and related data
/// 
/// Provides static methods to validate ISO 4217 currency codes,
/// exchange rates, and currency-related business rules.
class CurrencyValidator {
  /// List of supported currency codes (ISO 4217)
  /// 
  /// This list includes the most common currencies supported by the
  /// currency microservice and commonly used in international travel.
  static const List<String> supportedCurrencies = [
    // Major currencies
    'USD', // United States Dollar
    'EUR', // Euro
    'GBP', // British Pound Sterling
    'JPY', // Japanese Yen
    'CHF', // Swiss Franc
    'CAD', // Canadian Dollar
    'AUD', // Australian Dollar
    'CNY', // Chinese Yuan
    
    // Other important currencies
    'INR', // Indian Rupee
    'MXN', // Mexican Peso
    'BRL', // Brazilian Real
    'KRW', // South Korean Won
    'SGD', // Singapore Dollar
    'NZD', // New Zealand Dollar
    'NOK', // Norwegian Krone
    'SEK', // Swedish Krona
    'DKK', // Danish Krone
    'PLN', // Polish Zloty
    'CZK', // Czech Koruna
    'HUF', // Hungarian Forint
    'RUB', // Russian Ruble
    'TRY', // Turkish Lira
    'ZAR', // South African Rand
    'THB', // Thai Baht
    'MYR', // Malaysian Ringgit
    'PHP', // Philippine Peso
    'IDR', // Indonesian Rupiah
    'VND', // Vietnamese Dong
    'AED', // UAE Dirham
    'SAR', // Saudi Riyal
    'QAR', // Qatari Riyal
    'KWD', // Kuwaiti Dinar
    'BHD', // Bahraini Dinar
    'OMR', // Omani Rial
    'JOD', // Jordanian Dinar
    'LBP', // Lebanese Pound
    'EGP', // Egyptian Pound
    'ILS', // Israeli Shekel
    'CLP', // Chilean Peso
    'COP', // Colombian Peso
    'PEN', // Peruvian Sol
    'ARS', // Argentine Peso
    'UYU', // Uruguayan Peso
  ];

  /// Major world currencies (most commonly used)
  static const List<String> majorCurrencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'CHF', 'CAD', 'AUD', 'CNY',
  ];

  /// Currencies that typically don't use decimal places
  static const List<String> noDecimalCurrencies = [
    'JPY', // Japanese Yen
    'KRW', // South Korean Won
    'VND', // Vietnamese Dong
    'IDR', // Indonesian Rupiah
    'CLP', // Chilean Peso
    'PYG', // Paraguayan Guarani
    'UGX', // Ugandan Shilling
    'RWF', // Rwandan Franc
  ];

  /// Validate a currency code
  /// 
  /// Returns true if the currency code is valid (3 characters, uppercase, supported)
  static bool isValidCurrency(String currency) {
    if (currency.length != 3) return false;
    if (currency != currency.toUpperCase()) return false;
    return supportedCurrencies.contains(currency);
  }

  /// Check if a currency is a major world currency
  static bool isMajorCurrency(String currency) {
    return majorCurrencies.contains(currency.toUpperCase());
  }

  /// Check if a currency typically uses decimal places
  static bool usesDecimalPlaces(String currency) {
    return !noDecimalCurrencies.contains(currency.toUpperCase());
  }

  /// Get the typical number of decimal places for a currency
  static int getDecimalPlaces(String currency) {
    return usesDecimalPlaces(currency) ? 2 : 0;
  }

  /// Validate an exchange rate value
  /// 
  /// Returns true if the rate is within reasonable bounds
  static bool isValidExchangeRate(double rate) {
    return rate > 0 && rate < 10000; // Very generous upper bound
  }

  /// Validate that two currencies are different
  static bool areDifferentCurrencies(String currency1, String currency2) {
    return currency1.toUpperCase() != currency2.toUpperCase();
  }

  /// Validate a currency amount
  /// 
  /// Returns true if the amount is positive and reasonable
  static bool isValidAmount(double amount) {
    return amount > 0 && amount < 1000000000; // Up to 1 billion
  }

  /// Normalize a currency code (trim and uppercase)
  static String normalizeCurrency(String currency) {
    return currency.trim().toUpperCase();
  }

  /// Validate a list of currency codes
  static bool areAllValidCurrencies(List<String> currencies) {
    return currencies.every(isValidCurrency);
  }

  /// Get currency validation error message
  static String? getCurrencyValidationError(String currency) {
    if (currency.trim().isEmpty) {
      return 'Currency code cannot be empty';
    }
    
    final normalized = normalizeCurrency(currency);
    
    if (normalized.length != 3) {
      return 'Currency code must be exactly 3 characters (e.g., USD, EUR)';
    }
    
    if (!supportedCurrencies.contains(normalized)) {
      return 'Currency code "$normalized" is not supported';
    }
    
    return null; // No error - valid currency
  }

  /// Get exchange rate validation error message
  static String? getExchangeRateValidationError(double rate) {
    if (rate <= 0) {
      return 'Exchange rate must be greater than 0';
    }
    
    if (rate >= 10000) {
      return 'Exchange rate seems unreasonably high (>= 10000)';
    }
    
    return null; // No error - valid rate
  }

  /// Get amount validation error message
  static String? getAmountValidationError(double amount) {
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    
    if (amount >= 1000000000) {
      return 'Amount seems unreasonably large (>= 1 billion)';
    }
    
    return null; // No error - valid amount
  }

  /// Validate a currency pair for conversion
  static String? validateCurrencyPair(String fromCurrency, String toCurrency) {
    final fromError = getCurrencyValidationError(fromCurrency);
    if (fromError != null) return 'From currency: $fromError';
    
    final toError = getCurrencyValidationError(toCurrency);
    if (toError != null) return 'To currency: $toError';
    
    if (!areDifferentCurrencies(fromCurrency, toCurrency)) {
      return 'From and to currencies must be different';
    }
    
    return null; // Valid pair
  }

  /// Get currency symbol for display
  static String getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'JPY': return '¥';
      case 'KRW': return '₩';
      case 'CNY': return '¥';
      case 'INR': return '₹';
      case 'RUB': return '₽';
      case 'TRY': return '₺';
      default: return currency; // Return currency code if no symbol
    }
  }

  /// Check if currency has a dedicated symbol
  static bool hasSymbol(String currency) {
    return getCurrencySymbol(currency) != currency.toUpperCase();
  }
}