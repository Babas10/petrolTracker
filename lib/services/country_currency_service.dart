import 'dart:developer' as developer;
import '../models/currency_info.dart';
import 'currency_metadata.dart';

/// Comprehensive country-to-currency mapping service
/// 
/// This service provides intelligent currency suggestions based on country selection,
/// handles multi-currency countries, and supports smart filtering for fuel entry forms.
/// 
/// Features:
/// - Primary currency mapping for 50+ countries
/// - Multi-currency country support (e.g., Switzerland accepts CHF and EUR)
/// - Smart filtering that includes user's default currency
/// - Geographic currency detection for regional recommendations
/// - Currency metadata access (symbols, names, decimal places)
class CountryCurrencyService {
  /// Primary currency mapping for each country
  /// 
  /// Based on official ISO 4217 standards and real-world usage.
  /// Each country maps to its primary/official currency.
  static const Map<String, String> primaryCurrencyMap = {
    // Western Europe
    'Switzerland': 'CHF',
    'France': 'EUR',
    'Germany': 'EUR',
    'Italy': 'EUR',
    'Spain': 'EUR',
    'Netherlands': 'EUR',
    'Austria': 'EUR',
    'Belgium': 'EUR',
    'Portugal': 'EUR',
    'Luxembourg': 'EUR',
    'Ireland': 'EUR',
    'Finland': 'EUR',
    'Slovenia': 'EUR',
    'Slovakia': 'EUR',
    'Estonia': 'EUR',
    'Latvia': 'EUR',
    'Lithuania': 'EUR',
    'Malta': 'EUR',
    'Cyprus': 'EUR',
    'Greece': 'EUR',
    
    // Northern Europe (Non-Euro)
    'United Kingdom': 'GBP',
    'Norway': 'NOK',
    'Sweden': 'SEK',
    'Denmark': 'DKK',
    'Iceland': 'ISK',
    
    // Central & Eastern Europe
    'Poland': 'PLN',
    'Czech Republic': 'CZK',
    'Hungary': 'HUF',
    'Romania': 'RON',
    'Bulgaria': 'BGN',
    'Croatia': 'HRK',
    'Serbia': 'RSD',
    'Ukraine': 'UAH',
    'Russia': 'RUB',
    'Turkey': 'TRY',
    
    // North America
    'United States': 'USD',
    'Canada': 'CAD',
    'Mexico': 'MXN',
    
    // Asia Pacific
    'Japan': 'JPY',
    'Australia': 'AUD',
    'New Zealand': 'NZD',
    'South Korea': 'KRW',
    'Singapore': 'SGD',
    'China': 'CNY',
    'Hong Kong': 'HKD',
    'Taiwan': 'TWD',
    'India': 'INR',
    'Thailand': 'THB',
    'Malaysia': 'MYR',
    'Indonesia': 'IDR',
    'Philippines': 'PHP',
    'Vietnam': 'VND',
    
    // Middle East
    'United Arab Emirates': 'AED',
    'Saudi Arabia': 'SAR',
    'Qatar': 'QAR',
    'Kuwait': 'KWD',
    'Bahrain': 'BHD',
    'Oman': 'OMR',
    'Israel': 'ILS',
    
    // Africa
    'South Africa': 'ZAR',
    'Nigeria': 'NGN',
    'Egypt': 'EGP',
    'Morocco': 'MAD',
    'Tunisia': 'TND',
    'Kenya': 'KES',
    'Ghana': 'GHS',
    
    // South America
    'Brazil': 'BRL',
    'Argentina': 'ARS',
    'Chile': 'CLP',
    'Colombia': 'COP',
    'Peru': 'PEN',
    'Uruguay': 'UYU',
    'Venezuela': 'VEF',
    'Ecuador': 'USD', // Uses USD
    'Panama': 'USD',  // Uses USD
    
    // Additional countries
    'Fiji': 'FJD',
    'Papua New Guinea': 'PGK',
    'Jamaica': 'JMD',
    'Bahamas': 'BSD',
    'Barbados': 'BBD',
    'Trinidad and Tobago': 'TTD',
  };

  /// Countries that commonly accept multiple currencies
  /// 
  /// Based on real-world travel experiences and border economics.
  /// Includes tourist areas where foreign currencies are widely accepted.
  static const Map<String, List<String>> multiCurrencyCountries = {
    // European border countries
    'Switzerland': ['CHF', 'EUR'], // EUR accepted near French/German/Italian borders
    'United Kingdom': ['GBP', 'EUR'], // EUR in some tourist areas and airports
    
    // North American borders
    'Canada': ['CAD', 'USD'], // USD widely accepted especially near US border
    'Mexico': ['MXN', 'USD'], // USD very common in tourist areas
    
    // Asian financial centers
    'Hong Kong': ['HKD', 'USD', 'CNY'], // International financial center
    'Singapore': ['SGD', 'USD'], // International business hub
    'Thailand': ['THB', 'USD'], // USD in tourist areas
    'Vietnam': ['VND', 'USD'], // USD historically used
    'Cambodia': ['KHR', 'USD'], // USD widely circulated
    
    // Middle East (USD/EUR common)
    'United Arab Emirates': ['AED', 'USD', 'EUR'], // International business
    'Qatar': ['QAR', 'USD'], // International business
    
    // South America
    'Argentina': ['ARS', 'USD'], // USD due to inflation hedging
    'Peru': ['PEN', 'USD'], // USD in tourism
  };

  /// Get filtered currencies for smart selection in fuel entry forms
  /// 
  /// Returns a prioritized list of currencies relevant to the selected country:
  /// 1. Primary currency for the country (first in list)
  /// 2. Additional currencies for multi-currency countries
  /// 3. User's default currency (if not already included)
  /// 4. Regional currencies (if enabled)
  /// 
  /// [selectedCountry] - The country selected in the fuel entry form
  /// [userDefaultCurrency] - User's preferred/default currency
  /// [includeRegionalCurrencies] - Whether to include currencies from nearby countries
  /// [maxSuggestions] - Maximum number of currency suggestions (default: 8)
  /// 
  /// Returns a list of currency codes, sorted by relevance
  static List<String> getFilteredCurrencies(
    String selectedCountry,
    String userDefaultCurrency, {
    bool includeRegionalCurrencies = true,
    int maxSuggestions = 8,
  }) {
    try {
      final currencies = <String>{};
      
      // 1. Add primary currency for the country
      final primaryCurrency = primaryCurrencyMap[selectedCountry];
      if (primaryCurrency != null) {
        currencies.add(primaryCurrency);
      }
      
      // 2. Add additional currencies for multi-currency countries
      final additionalCurrencies = multiCurrencyCountries[selectedCountry];
      if (additionalCurrencies != null) {
        currencies.addAll(additionalCurrencies);
      }
      
      // 3. Always include user's default currency
      if (userDefaultCurrency.isNotEmpty) {
        currencies.add(userDefaultCurrency);
      }
      
      // 4. Add regional currencies if requested
      if (includeRegionalCurrencies && currencies.length < maxSuggestions) {
        final regionalCurrencies = _getRegionalCurrencies(selectedCountry);
        for (final currency in regionalCurrencies) {
          if (currencies.length >= maxSuggestions) break;
          currencies.add(currency);
        }
      }
      
      // Convert to list and ensure primary currency is first
      final result = currencies.toList();
      if (primaryCurrency != null && result.contains(primaryCurrency)) {
        result.remove(primaryCurrency);
        result.insert(0, primaryCurrency);
      }
      
      // Ensure user's default is second (if not primary)
      if (userDefaultCurrency.isNotEmpty && 
          userDefaultCurrency != primaryCurrency && 
          result.contains(userDefaultCurrency)) {
        result.remove(userDefaultCurrency);
        if (result.isNotEmpty) {
          result.insert(1, userDefaultCurrency);
        } else {
          result.insert(0, userDefaultCurrency);
        }
      }
      
      // Limit to maxSuggestions
      return result.take(maxSuggestions).toList();
      
    } catch (e) {
      developer.log('Error filtering currencies for country $selectedCountry: $e');
      // Fallback: return user's default currency
      return userDefaultCurrency.isNotEmpty ? [userDefaultCurrency] : ['USD'];
    }
  }
  
  /// Get all countries that primarily use a specific currency
  /// 
  /// [currency] - The currency code to search for
  /// Returns a list of country names that use this currency as their primary currency
  static List<String> getCountriesForCurrency(String currency) {
    return primaryCurrencyMap.entries
        .where((entry) => entry.value == currency.toUpperCase())
        .map((entry) => entry.key)
        .toList()
      ..sort();
  }
  
  /// Get currency information with metadata
  /// 
  /// [currencyCode] - The 3-letter currency code
  /// Returns CurrencyInfo object with symbol, name, decimal places, etc.
  static CurrencyInfo? getCurrencyInfo(String currencyCode) {
    return CurrencyMetadata.getCurrencyInfo(currencyCode);
  }
  
  /// Check if a country commonly uses multiple currencies
  /// 
  /// [country] - The country name to check
  /// Returns true if the country commonly accepts multiple currencies
  static bool isMultiCurrencyCountry(String country) {
    return multiCurrencyCountries.containsKey(country);
  }
  
  /// Get the primary currency for a specific country
  /// 
  /// [country] - The country name
  /// Returns the primary currency code, or null if country not found
  static String? getPrimaryCurrency(String country) {
    return primaryCurrencyMap[country];
  }
  
  /// Get all currencies that are commonly used in a country
  /// 
  /// Includes both primary and additional currencies for multi-currency countries
  /// 
  /// [country] - The country name
  /// Returns a list of currency codes used in that country
  static List<String> getAllCountryCurrencies(String country) {
    final currencies = <String>[];
    
    final primary = primaryCurrencyMap[country];
    if (primary != null) {
      currencies.add(primary);
    }
    
    final additional = multiCurrencyCountries[country];
    if (additional != null) {
      currencies.addAll(additional.where((currency) => !currencies.contains(currency)));
    }
    
    return currencies;
  }
  
  /// Get list of all supported countries
  /// 
  /// Returns alphabetically sorted list of all countries in the mapping
  static List<String> getSupportedCountries() {
    final countries = primaryCurrencyMap.keys.toList()..sort();
    return countries;
  }
  
  /// Check if a country is supported
  /// 
  /// [country] - The country name to check
  /// Returns true if the country is in our mapping
  static bool isSupportedCountry(String country) {
    return primaryCurrencyMap.containsKey(country);
  }
  
  /// Get regional currencies based on geographic proximity
  /// 
  /// [country] - The reference country
  /// Returns a list of currencies commonly used in the same region
  static List<String> _getRegionalCurrencies(String country) {
    final region = CurrencyRegionConfig.countryToRegion[country];
    if (region == null) return [];
    
    final regionalCurrencies = CurrencyRegionConfig.regionCurrencies[region] ?? [];
    
    // Filter out currencies we already have and return up to 3 regional currencies
    return regionalCurrencies.take(3).toList();
  }
  
  /// Get currency suggestions with reasons for debugging/UI
  /// 
  /// Returns detailed information about why each currency was suggested
  static List<CurrencySuggestion> getDetailedCurrencySuggestions(
    String selectedCountry,
    String userDefaultCurrency, {
    bool includeRegionalCurrencies = true,
    int maxSuggestions = 8,
  }) {
    final suggestions = <CurrencySuggestion>[];
    final addedCurrencies = <String>{};
    
    try {
      // 1. Primary currency
      final primaryCurrency = primaryCurrencyMap[selectedCountry];
      if (primaryCurrency != null && !addedCurrencies.contains(primaryCurrency)) {
        suggestions.add(CurrencySuggestion(
          currencyCode: primaryCurrency,
          reason: CurrencySuggestionReason.primaryCurrency,
          countryName: selectedCountry,
        ));
        addedCurrencies.add(primaryCurrency);
      }
      
      // 2. User default currency
      if (userDefaultCurrency.isNotEmpty && !addedCurrencies.contains(userDefaultCurrency)) {
        suggestions.add(CurrencySuggestion(
          currencyCode: userDefaultCurrency,
          reason: CurrencySuggestionReason.userDefault,
          countryName: selectedCountry,
        ));
        addedCurrencies.add(userDefaultCurrency);
      }
      
      // 3. Additional currencies for multi-currency countries
      final additionalCurrencies = multiCurrencyCountries[selectedCountry];
      if (additionalCurrencies != null) {
        for (final currency in additionalCurrencies) {
          if (suggestions.length >= maxSuggestions) break;
          if (!addedCurrencies.contains(currency)) {
            suggestions.add(CurrencySuggestion(
              currencyCode: currency,
              reason: CurrencySuggestionReason.multiCurrencyCountry,
              countryName: selectedCountry,
            ));
            addedCurrencies.add(currency);
          }
        }
      }
      
      // 4. Regional currencies
      if (includeRegionalCurrencies && suggestions.length < maxSuggestions) {
        final regionalCurrencies = _getRegionalCurrencies(selectedCountry);
        for (final currency in regionalCurrencies) {
          if (suggestions.length >= maxSuggestions) break;
          if (!addedCurrencies.contains(currency)) {
            suggestions.add(CurrencySuggestion(
              currencyCode: currency,
              reason: CurrencySuggestionReason.regional,
              countryName: selectedCountry,
            ));
            addedCurrencies.add(currency);
          }
        }
      }
      
      return suggestions;
      
    } catch (e) {
      developer.log('Error getting detailed currency suggestions: $e');
      return [
        CurrencySuggestion(
          currencyCode: userDefaultCurrency.isNotEmpty ? userDefaultCurrency : 'USD',
          reason: CurrencySuggestionReason.fallback,
          countryName: selectedCountry,
        )
      ];
    }
  }
}

/// Enum for different reasons why a currency is suggested
enum CurrencySuggestionReason {
  primaryCurrency,
  userDefault,
  multiCurrencyCountry,
  regional,
  fallback,
}

/// Detailed currency suggestion with reasoning
class CurrencySuggestion {
  final String currencyCode;
  final CurrencySuggestionReason reason;
  final String countryName;
  
  const CurrencySuggestion({
    required this.currencyCode,
    required this.reason,
    required this.countryName,
  });
  
  /// Get human-readable description of why this currency was suggested
  String get reasonDescription {
    switch (reason) {
      case CurrencySuggestionReason.primaryCurrency:
        return 'Primary currency of $countryName';
      case CurrencySuggestionReason.userDefault:
        return 'Your default currency';
      case CurrencySuggestionReason.multiCurrencyCountry:
        return 'Commonly accepted in $countryName';
      case CurrencySuggestionReason.regional:
        return 'Regional currency';
      case CurrencySuggestionReason.fallback:
        return 'Fallback suggestion';
    }
  }
  
  @override
  String toString() {
    return 'CurrencySuggestion(code: $currencyCode, reason: ${reasonDescription})';
  }
}