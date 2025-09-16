import 'package:petrol_tracker/utils/currency_validator.dart';

/// Service for mapping countries to their primary currencies and related functionality
/// 
/// Provides country-to-currency mappings, currency filtering based on country selection,
/// and smart defaults for fuel entry forms. This service helps improve user experience
/// by suggesting relevant currencies based on the selected country.
class CountryCurrencyService {
  /// Map of countries to their primary currencies
  /// 
  /// This map includes the most commonly used currency for each country.
  /// For countries with multiple currencies, the most widely accepted one is chosen.
  static const Map<String, String> _countryToCurrency = {
    // North America
    'United States': 'USD',
    'Canada': 'CAD',
    'Mexico': 'MXN',
    
    // Europe
    'Germany': 'EUR',
    'France': 'EUR',
    'Italy': 'EUR',
    'Spain': 'EUR',
    'Netherlands': 'EUR',
    'Belgium': 'EUR',
    'Austria': 'EUR',
    'Portugal': 'EUR',
    'Ireland': 'EUR',
    'Greece': 'EUR',
    'Finland': 'EUR',
    'Luxembourg': 'EUR',
    'Slovenia': 'EUR',
    'Slovakia': 'EUR',
    'Estonia': 'EUR',
    'Latvia': 'EUR',
    'Lithuania': 'EUR',
    'Malta': 'EUR',
    'Cyprus': 'EUR',
    'United Kingdom': 'GBP',
    'Switzerland': 'CHF',
    'Norway': 'NOK',
    'Sweden': 'SEK',
    'Denmark': 'DKK',
    'Poland': 'PLN',
    'Czech Republic': 'CZK',
    'Hungary': 'HUF',
    'Romania': 'RON',
    'Bulgaria': 'BGN',
    'Croatia': 'HRK',
    'Iceland': 'ISK',
    'Ukraine': 'UAH',
    'Turkey': 'TRY',
    'Russia': 'RUB',
    
    // Asia
    'Japan': 'JPY',
    'China': 'CNY',
    'South Korea': 'KRW',
    'India': 'INR',
    'Singapore': 'SGD',
    'Hong Kong': 'HKD',
    'Taiwan': 'TWD',
    'Thailand': 'THB',
    'Malaysia': 'MYR',
    'Indonesia': 'IDR',
    'Philippines': 'PHP',
    'Vietnam': 'VND',
    'Pakistan': 'PKR',
    'Bangladesh': 'BDT',
    'Sri Lanka': 'LKR',
    
    // Middle East & Africa
    'Israel': 'ILS',
    'United Arab Emirates': 'AED',
    'Saudi Arabia': 'SAR',
    'Egypt': 'EGP',
    'South Africa': 'ZAR',
    'Morocco': 'MAD',
    'Tunisia': 'TND',
    'Nigeria': 'NGN',
    'Kenya': 'KES',
    'Ghana': 'GHS',
    
    // Oceania
    'Australia': 'AUD',
    'New Zealand': 'NZD',
    
    // South America
    'Brazil': 'BRL',
    'Argentina': 'ARS',
    'Chile': 'CLP',
    'Colombia': 'COP',
    'Peru': 'PEN',
    'Uruguay': 'UYU',
    'Paraguay': 'PYG',
    'Ecuador': 'USD', // Uses USD
    'Venezuela': 'VES',
    'Bolivia': 'BOB',
    
    // Additional countries with common currencies
    'Afghanistan': 'AFN',
    'Albania': 'ALL',
    'Algeria': 'DZD',
    'Armenia': 'AMD',
    'Azerbaijan': 'AZN',
    'Bahrain': 'BHD',
    'Belarus': 'BYN',
    'Bosnia and Herzegovina': 'BAM',
    'Cambodia': 'KHR',
    'Montenegro': 'EUR',
    'Serbia': 'RSD',
    'North Macedonia': 'MKD',
    'Moldova': 'MDL',
    'Georgia': 'GEL',
    'Kazakhstan': 'KZT',
    'Uzbekistan': 'UZS',
    'Kyrgyzstan': 'KGS',
    'Tajikistan': 'TJS',
    'Turkmenistan': 'TMT',
    'Mongolia': 'MNT',
    'Nepal': 'NPR',
    'Bhutan': 'BTN',
    'Myanmar': 'MMK',
    'Laos': 'LAK',
    'Brunei': 'BND',
    'Maldives': 'MVR',
  };

  /// Regional currency groups for countries that commonly use multiple currencies
  /// 
  /// Some regions or countries may accept multiple currencies for fuel purchases,
  /// especially in border areas or tourist destinations.
  static const Map<String, List<String>> _regionalCurrencies = {
    // European countries might accept EUR even if not in Eurozone
    'Switzerland': ['CHF', 'EUR'],
    'United Kingdom': ['GBP', 'EUR'],
    'Norway': ['NOK', 'EUR'],
    'Sweden': ['SEK', 'EUR'],
    'Denmark': ['DKK', 'EUR'],
    'Poland': ['PLN', 'EUR'],
    'Czech Republic': ['CZK', 'EUR'],
    'Hungary': ['HUF', 'EUR'],
    
    // Border countries that might accept neighboring currencies
    'Canada': ['CAD', 'USD'],
    'Mexico': ['MXN', 'USD'],
    
    // International hubs that accept multiple currencies
    'Singapore': ['SGD', 'USD'],
    'Hong Kong': ['HKD', 'USD'],
    'United Arab Emirates': ['AED', 'USD'],
    
    // Countries that commonly use USD alongside local currency
    'Ecuador': ['USD'],
    'El Salvador': ['USD'],
    'Panama': ['USD', 'PAB'],
    'Cambodia': ['KHR', 'USD'],
    'Zimbabwe': ['USD', 'ZWL'],
  };

  /// Get the primary currency for a given country
  /// 
  /// Returns the most commonly used currency for the specified country.
  /// If the country is not found, returns null.
  /// 
  /// Example:
  /// ```dart
  /// final currency = CountryCurrencyService.getPrimaryCurrency('Germany');
  /// print(currency); // 'EUR'
  /// ```
  static String? getPrimaryCurrency(String country) {
    return _countryToCurrency[country];
  }

  /// Get all currencies commonly used in a country
  /// 
  /// Returns a list of currencies that are commonly accepted in the specified country.
  /// The primary currency is always first in the list if available.
  /// If the country is not found, returns an empty list.
  /// 
  /// Example:
  /// ```dart
  /// final currencies = CountryCurrencyService.getCurrenciesForCountry('Switzerland');
  /// print(currencies); // ['CHF', 'EUR']
  /// ```
  static List<String> getCurrenciesForCountry(String country) {
    final regional = _regionalCurrencies[country];
    if (regional != null) {
      return List<String>.from(regional);
    }
    
    final primary = _countryToCurrency[country];
    if (primary != null) {
      return [primary];
    }
    
    return [];
  }

  /// Get filtered currencies for fuel entry form
  /// 
  /// Returns a prioritized list of currencies for the dropdown based on:
  /// 1. Primary currency of the selected country (if any)
  /// 2. Regional currencies for the country
  /// 3. User's primary currency from settings
  /// 4. Major international currencies
  /// 5. All other supported currencies
  /// 
  /// This provides an intelligent currency selection experience.
  /// 
  /// Example:
  /// ```dart
  /// final currencies = CountryCurrencyService.getFilteredCurrencies(
  ///   'Germany', 
  ///   'USD'
  /// );
  /// // Returns: ['EUR', 'USD', 'GBP', 'JPY', ...other currencies]
  /// ```
  static List<String> getFilteredCurrencies(
    String? selectedCountry, 
    String userPrimaryCurrency
  ) {
    final Set<String> orderedCurrencies = {};
    
    // 1. Add currencies for the selected country (if any)
    if (selectedCountry != null) {
      final countryCurrencies = getCurrenciesForCountry(selectedCountry);
      orderedCurrencies.addAll(countryCurrencies);
    }
    
    // 2. Add user's primary currency
    orderedCurrencies.add(userPrimaryCurrency);
    
    // 3. Add major international currencies
    const majorCurrencies = ['USD', 'EUR', 'GBP', 'JPY', 'CHF', 'CAD', 'AUD'];
    orderedCurrencies.addAll(majorCurrencies);
    
    // 4. Add all other supported currencies
    orderedCurrencies.addAll(CurrencyValidator.supportedCurrencies);
    
    // Filter to only include actually supported currencies and return as list
    return orderedCurrencies
        .where((currency) => CurrencyValidator.isValidCurrency(currency))
        .toList();
  }

  /// Get smart default currency for a country
  /// 
  /// Returns the best default currency to pre-select when a country is chosen.
  /// Priority order:
  /// 1. Primary currency of the selected country
  /// 2. User's primary currency from settings
  /// 3. USD as fallback
  /// 
  /// Example:
  /// ```dart
  /// final defaultCurrency = CountryCurrencyService.getSmartDefault(
  ///   'Japan', 
  ///   'USD'
  /// );
  /// print(defaultCurrency); // 'JPY'
  /// ```
  static String getSmartDefault(String? selectedCountry, String userPrimaryCurrency) {
    // Try country's primary currency first
    if (selectedCountry != null) {
      final countryCurrency = getPrimaryCurrency(selectedCountry);
      if (countryCurrency != null && CurrencyValidator.isValidCurrency(countryCurrency)) {
        return countryCurrency;
      }
    }
    
    // Fall back to user's primary currency
    if (CurrencyValidator.isValidCurrency(userPrimaryCurrency)) {
      return userPrimaryCurrency;
    }
    
    // Final fallback to USD
    return 'USD';
  }

  /// Check if a currency is commonly used in a country
  /// 
  /// Returns true if the currency is in the list of currencies commonly
  /// accepted in the specified country.
  /// 
  /// Example:
  /// ```dart
  /// final isCommon = CountryCurrencyService.isCurrencyCommonInCountry('EUR', 'Germany');
  /// print(isCommon); // true
  /// ```
  static bool isCurrencyCommonInCountry(String currency, String country) {
    final currencies = getCurrenciesForCountry(country);
    return currencies.contains(currency);
  }

  /// Get all countries that primarily use a specific currency
  /// 
  /// Returns a list of countries that have the specified currency as their primary currency.
  /// Useful for analytics or informational purposes.
  /// 
  /// Example:
  /// ```dart
  /// final countries = CountryCurrencyService.getCountriesForCurrency('EUR');
  /// // Returns: ['Germany', 'France', 'Italy', ...]
  /// ```
  static List<String> getCountriesForCurrency(String currency) {
    return _countryToCurrency.entries
        .where((entry) => entry.value == currency)
        .map((entry) => entry.key)
        .toList()
      ..sort();
  }

  /// Get currency statistics for informational purposes
  /// 
  /// Returns a map with statistics about the country-currency mappings.
  /// Useful for debugging or analytics.
  static Map<String, int> getCurrencyStatistics() {
    final Map<String, int> stats = {};
    
    for (final currency in _countryToCurrency.values) {
      stats[currency] = (stats[currency] ?? 0) + 1;
    }
    
    return Map.fromEntries(
      stats.entries.toList()..sort((a, b) => b.value.compareTo(a.value))
    );
  }
}