import 'package:freezed_annotation/freezed_annotation.dart';

part 'currency_info.freezed.dart';
part 'currency_info.g.dart';

/// Comprehensive information about a currency including metadata and country associations
@freezed
class CurrencyInfo with _$CurrencyInfo {
  const factory CurrencyInfo({
    /// The 3-letter ISO 4217 currency code (e.g., 'USD', 'EUR')
    required String code,
    
    /// The full display name of the currency (e.g., 'US Dollar', 'Euro')
    required String name,
    
    /// The currency symbol (e.g., '$', '€', '¥')
    required String symbol,
    
    /// Number of decimal places typically used (usually 2)
    required int decimalPlaces,
    
    /// List of countries that primarily use this currency
    required List<String> countries,
    
    /// Alternative symbols that might be used (e.g., 'US$' for USD in international contexts)
    @Default([]) List<String> alternativeSymbols,
    
    /// Whether this currency is commonly used internationally
    @Default(false) bool isInternational,
    
    /// Regional variants or notes about usage
    String? notes,
  }) = _CurrencyInfo;
  
  factory CurrencyInfo.fromJson(Map<String, dynamic> json) => _$CurrencyInfoFromJson(json);
}

/// Regional grouping of countries for geographic currency detection
enum CurrencyRegion {
  europe,
  northAmerica,
  asiaPacific,
  brics,
  middleEast,
  africa,
  southAmerica,
  oceania,
}

/// Configuration class for currency region mappings
class CurrencyRegionConfig {
  static const Map<CurrencyRegion, List<String>> regionCurrencies = {
    CurrencyRegion.europe: [
      'EUR', 'CHF', 'GBP', 'NOK', 'SEK', 'DKK', 
      'PLN', 'CZK', 'HUF', 'RON', 'BGN', 'HRK'
    ],
    CurrencyRegion.northAmerica: ['USD', 'CAD', 'MXN'],
    CurrencyRegion.asiaPacific: [
      'JPY', 'KRW', 'CNY', 'INR', 'SGD', 'HKD', 
      'THB', 'MYR', 'IDR', 'PHP', 'VND'
    ],
    CurrencyRegion.brics: ['BRL', 'RUB', 'INR', 'CNY', 'ZAR'],
    CurrencyRegion.middleEast: ['AED', 'SAR', 'QAR', 'KWD', 'BHD', 'OMR'],
    CurrencyRegion.africa: ['ZAR', 'NGN', 'EGP', 'MAD', 'TND', 'KES'],
    CurrencyRegion.southAmerica: ['BRL', 'ARS', 'CLP', 'COP', 'PEN', 'UYU'],
    CurrencyRegion.oceania: ['AUD', 'NZD', 'FJD', 'PGK'],
  };
  
  static const Map<String, CurrencyRegion> countryToRegion = {
    // Europe
    'Switzerland': CurrencyRegion.europe,
    'France': CurrencyRegion.europe,
    'Germany': CurrencyRegion.europe,
    'Italy': CurrencyRegion.europe,
    'Spain': CurrencyRegion.europe,
    'Netherlands': CurrencyRegion.europe,
    'Austria': CurrencyRegion.europe,
    'Belgium': CurrencyRegion.europe,
    'United Kingdom': CurrencyRegion.europe,
    'Norway': CurrencyRegion.europe,
    'Sweden': CurrencyRegion.europe,
    'Denmark': CurrencyRegion.europe,
    'Poland': CurrencyRegion.europe,
    'Czech Republic': CurrencyRegion.europe,
    'Hungary': CurrencyRegion.europe,
    
    // North America
    'United States': CurrencyRegion.northAmerica,
    'Canada': CurrencyRegion.northAmerica,
    'Mexico': CurrencyRegion.northAmerica,
    
    // Asia Pacific
    'Japan': CurrencyRegion.asiaPacific,
    'South Korea': CurrencyRegion.asiaPacific,
    'China': CurrencyRegion.asiaPacific,
    'India': CurrencyRegion.asiaPacific,
    'Singapore': CurrencyRegion.asiaPacific,
    'Thailand': CurrencyRegion.asiaPacific,
    'Malaysia': CurrencyRegion.asiaPacific,
    'Indonesia': CurrencyRegion.asiaPacific,
    'Philippines': CurrencyRegion.asiaPacific,
    'Vietnam': CurrencyRegion.asiaPacific,
    
    // Oceania
    'Australia': CurrencyRegion.oceania,
    'New Zealand': CurrencyRegion.oceania,
    
    // South America
    'Brazil': CurrencyRegion.southAmerica,
    'Argentina': CurrencyRegion.southAmerica,
    'Chile': CurrencyRegion.southAmerica,
    'Colombia': CurrencyRegion.southAmerica,
    'Peru': CurrencyRegion.southAmerica,
    
    // Others
    'Russia': CurrencyRegion.brics,
    'Turkey': CurrencyRegion.europe, // EU candidate
    'South Africa': CurrencyRegion.africa,
    'United Arab Emirates': CurrencyRegion.middleEast,
    'Saudi Arabia': CurrencyRegion.middleEast,
  };
}