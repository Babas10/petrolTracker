import 'currency_validator.dart';
import 'currency_formatter.dart';

/// Utility class for currency display and UI-specific functionality
/// 
/// Provides methods for displaying currency information in user interfaces,
/// including dropdowns, settings, and validation messages.
/// 
/// Note: For basic currency formatting (amounts, symbols), use CurrencyFormatter.
/// This class focuses on UI-specific display needs like currency names and selection.
class CurrencyDisplayUtils {
  /// Map of currency codes to their human-readable names
  static const Map<String, String> _currencyNames = {
    // Major currencies
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound Sterling',
    'JPY': 'Japanese Yen',
    'CHF': 'Swiss Franc',
    'CAD': 'Canadian Dollar',
    'AUD': 'Australian Dollar',
    'CNY': 'Chinese Yuan',
    'INR': 'Indian Rupee',
    'KRW': 'South Korean Won',
    'SGD': 'Singapore Dollar',
    'HKD': 'Hong Kong Dollar',
    'NOK': 'Norwegian Krone',
    'SEK': 'Swedish Krona',
    'DKK': 'Danish Krone',
    'PLN': 'Polish Złoty',
    'CZK': 'Czech Koruna',
    'HUF': 'Hungarian Forint',
    'RUB': 'Russian Ruble',
    'TRY': 'Turkish Lira',
    
    // Additional currencies
    'NZD': 'New Zealand Dollar',
    'MXN': 'Mexican Peso',
    'BRL': 'Brazilian Real',
    'ZAR': 'South African Rand',
    'ILS': 'Israeli New Shekel',
    'AED': 'UAE Dirham',
    'SAR': 'Saudi Riyal',
    'EGP': 'Egyptian Pound',
    'THB': 'Thai Baht',
    'MYR': 'Malaysian Ringgit',
    'IDR': 'Indonesian Rupiah',
    'PHP': 'Philippine Peso',
    'VND': 'Vietnamese Dong',
    'TWD': 'Taiwan Dollar',
    'PKR': 'Pakistani Rupee',
    'BGN': 'Bulgarian Lev',
    'RON': 'Romanian Leu',
    'HRK': 'Croatian Kuna',
    'ISK': 'Icelandic Króna',
    'UAH': 'Ukrainian Hryvnia',
  };


  /// Get human-readable name for a currency code
  /// 
  /// Returns the full name of the currency (e.g., "US Dollar" for "USD").
  /// If the currency is not found, returns the currency code itself.
  /// 
  /// Example:
  /// ```dart
  /// CurrencyDisplayUtils.getCurrencyName('USD'); // Returns "US Dollar"
  /// CurrencyDisplayUtils.getCurrencyName('XYZ'); // Returns "XYZ"
  /// ```
  static String getCurrencyName(String currencyCode) {
    final normalizedCode = currencyCode.toUpperCase();
    return _currencyNames[normalizedCode] ?? normalizedCode;
  }


  /// Get formatted display string for currency selection
  /// 
  /// Returns a user-friendly string combining the code, symbol, and name.
  /// Format: "USD ($) - US Dollar"
  /// 
  /// Example:
  /// ```dart
  /// CurrencyDisplayUtils.getDisplayString('USD'); 
  /// // Returns "USD (\$) - US Dollar"
  /// ```
  static String getDisplayString(String currencyCode) {
    final normalizedCode = currencyCode.toUpperCase();
    final name = getCurrencyName(normalizedCode);
    final symbol = CurrencyValidator.getCurrencySymbol(normalizedCode);
    
    if (CurrencyValidator.hasSymbol(normalizedCode) && symbol != normalizedCode) {
      return '$normalizedCode ($symbol) - $name';
    } else {
      return '$normalizedCode - $name';
    }
  }

  /// Get list of supported currencies with display information
  /// 
  /// Returns a list of maps containing currency information for UI display.
  /// Each map contains: code, name, symbol, isMajor
  /// 
  /// The list is sorted with major currencies first, then alphabetically.
  static List<Map<String, dynamic>> getSupportedCurrenciesWithInfo() {
    final currencies = <Map<String, dynamic>>[];
    
    for (final code in CurrencyValidator.supportedCurrencies) {
      currencies.add({
        'code': code,
        'name': getCurrencyName(code),
        'symbol': CurrencyValidator.getCurrencySymbol(code),
        'isMajor': CurrencyValidator.isMajorCurrency(code),
        'displayString': getDisplayString(code),
      });
    }
    
    // Sort: major currencies first, then alphabetically by code
    currencies.sort((a, b) {
      final aMajor = a['isMajor'] as bool;
      final bMajor = b['isMajor'] as bool;
      
      if (aMajor && !bMajor) return -1;
      if (!aMajor && bMajor) return 1;
      
      return (a['code'] as String).compareTo(b['code'] as String);
    });
    
    return currencies;
  }

  /// Get list of major currencies only
  /// 
  /// Returns a list of currency codes for the most commonly used currencies.
  /// Useful for creating simplified currency selection UIs.
  static List<String> getMajorCurrencies() {
    return CurrencyValidator.supportedCurrencies
        .where((code) => CurrencyValidator.isMajorCurrency(code))
        .toList()
      ..sort();
  }

  /// Get list of all supported currency codes
  /// 
  /// Returns a sorted list of all supported currency codes.
  /// This is a convenience method that delegates to CurrencyValidator.
  static List<String> getAllSupportedCurrencies() {
    return List<String>.from(CurrencyValidator.supportedCurrencies)..sort();
  }


  /// Validate currency code and return validation message
  /// 
  /// Returns null if the currency is valid, or an error message if invalid.
  /// This is a convenience method that delegates to CurrencyValidator.
  static String? validateCurrencySelection(String? currencyCode) {
    if (currencyCode == null || currencyCode.isEmpty) {
      return 'Please select a currency';
    }
    
    return CurrencyValidator.getCurrencyValidationError(currencyCode);
  }

  /// Get region/country information for major currencies
  /// 
  /// Returns a human-readable description of where the currency is primarily used.
  static String getCurrencyRegion(String currencyCode) {
    final normalizedCode = currencyCode.toUpperCase();
    
    const regionMap = {
      'USD': 'United States',
      'EUR': 'European Union',
      'GBP': 'United Kingdom',
      'JPY': 'Japan',
      'CHF': 'Switzerland',
      'CAD': 'Canada',
      'AUD': 'Australia',
      'CNY': 'China',
      'INR': 'India',
      'KRW': 'South Korea',
      'SGD': 'Singapore',
      'HKD': 'Hong Kong',
      'NOK': 'Norway',
      'SEK': 'Sweden',
      'DKK': 'Denmark',
      'PLN': 'Poland',
      'CZK': 'Czech Republic',
      'HUF': 'Hungary',
      'RUB': 'Russia',
      'TRY': 'Turkey',
      'NZD': 'New Zealand',
      'MXN': 'Mexico',
      'BRL': 'Brazil',
      'ZAR': 'South Africa',
      'ILS': 'Israel',
      'AED': 'United Arab Emirates',
      'SAR': 'Saudi Arabia',
      'EGP': 'Egypt',
      'THB': 'Thailand',
      'MYR': 'Malaysia',
      'IDR': 'Indonesia',
      'PHP': 'Philippines',
      'VND': 'Vietnam',
      'TWD': 'Taiwan',
      'PKR': 'Pakistan',
    };
    
    return regionMap[normalizedCode] ?? 'International';
  }
}