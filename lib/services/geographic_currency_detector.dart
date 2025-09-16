import '../models/currency_info.dart';

/// Service for detecting likely currencies based on geographic proximity
/// 
/// This service provides intelligent currency suggestions based on regional
/// groupings and geographic relationships between countries. It's useful for
/// providing fallback currency suggestions when traveling or when the primary
/// country mapping doesn't provide enough options.
class GeographicCurrencyDetector {
  
  /// Detect likely currencies based on geographic proximity
  /// 
  /// This method analyzes the geographic region of a country and returns
  /// currencies commonly used in that region. This is helpful for:
  /// - Cross-border travel scenarios
  /// - Regional business transactions
  /// - Tourist areas that accept multiple regional currencies
  /// 
  /// [country] - The reference country name
  /// [maxSuggestions] - Maximum number of regional currencies to return (default: 5)
  /// 
  /// Returns a list of currency codes commonly used in the same geographic region
  static List<String> getNearbyCountryCurrencies(
    String country, {
    int maxSuggestions = 5,
  }) {
    // Find which region the country belongs to
    final region = CurrencyRegionConfig.countryToRegion[country];
    if (region == null) {
      // If country not found, return major international currencies as fallback
      return ['USD', 'EUR', 'GBP'].take(maxSuggestions).toList();
    }
    
    // Get currencies for this region
    final regionalCurrencies = CurrencyRegionConfig.regionCurrencies[region] ?? [];
    
    // Return up to maxSuggestions currencies
    return regionalCurrencies.take(maxSuggestions).toList();
  }
  
  /// Check if a country belongs to a specific geographic region
  /// 
  /// [country] - The country name to check
  /// [region] - The currency region to check against
  /// 
  /// Returns true if the country belongs to the specified region
  static bool isCountryInRegion(String country, CurrencyRegion region) {
    return CurrencyRegionConfig.countryToRegion[country] == region;
  }
  
  /// Get the geographic region for a specific country
  /// 
  /// [country] - The country name
  /// 
  /// Returns the CurrencyRegion enum, or null if country not found
  static CurrencyRegion? getCountryRegion(String country) {
    return CurrencyRegionConfig.countryToRegion[country];
  }
  
  /// Get all countries in a specific geographic region
  /// 
  /// [region] - The currency region
  /// 
  /// Returns a list of country names in that region
  static List<String> getCountriesInRegion(CurrencyRegion region) {
    return CurrencyRegionConfig.countryToRegion.entries
        .where((entry) => entry.value == region)
        .map((entry) => entry.key)
        .toList()
      ..sort();
  }
  
  /// Get border currency suggestions based on geographic adjacency
  /// 
  /// For countries that share borders or are geographically close,
  /// this method provides currency suggestions based on common
  /// cross-border economic activities.
  /// 
  /// [country] - The reference country
  /// 
  /// Returns a list of currencies commonly used in border/adjacent areas
  static List<String> getBorderCurrencySuggestions(String country) {
    // Define border relationships and commonly accepted currencies
    const borderCurrencies = <String, List<String>>{
      // European borders - EUR widely accepted
      'Switzerland': ['EUR', 'CHF'], // EUR near French/German/Italian borders
      'United Kingdom': ['EUR', 'GBP'], // EUR in international areas
      'Norway': ['EUR', 'NOK'], // EUR in some tourist areas
      'Poland': ['EUR', 'PLN'], // EUR increasingly accepted
      'Czech Republic': ['EUR', 'CZK'], // EUR in tourist areas
      'Hungary': ['EUR', 'HUF'], // EUR in tourist areas
      
      // North American borders
      'Canada': ['USD', 'CAD'], // USD widely accepted, especially near border
      'Mexico': ['USD', 'MXN'], // USD very common in tourist areas
      
      // Asian economic zones
      'Malaysia': ['SGD', 'MYR'], // SGD near Singapore border
      'Cambodia': ['USD', 'KHR'], // USD historically widespread
      'Laos': ['THB', 'USD', 'LAK'], // THB from Thailand, USD from tourism
      'Myanmar': ['USD', 'THB', 'MMK'], // Cross-border trade currencies
      
      // Middle East oil economies
      'United Arab Emirates': ['USD', 'AED'], // USD in international business
      'Qatar': ['USD', 'QAR'], // USD in international business
      'Kuwait': ['USD', 'KWD'], // USD in oil trade
      'Bahrain': ['USD', 'BHD'], // USD in finance
      
      // South American regional integration
      'Paraguay': ['USD', 'ARS', 'BRL', 'PYG'], // Regional trade currencies
      'Uruguay': ['USD', 'ARS', 'UYU'], // Regional integration
      'Bolivia': ['USD', 'PEN', 'BOB'], // Cross-border trade
      
      // African cross-border trade
      'South Africa': ['USD', 'ZAR'], // USD in international trade
      'Kenya': ['USD', 'ZAR'], // Regional economic hub currencies
      'Ghana': ['USD', 'NGN', 'GHS'], // Regional West African currencies
      
      // Caribbean USD dominance
      'Jamaica': ['USD', 'JMD'], // USD tourism and remittances
      'Bahamas': ['USD', 'BSD'], // USD co-circulation
      'Barbados': ['USD', 'BBD'], // USD tourism
      'Trinidad and Tobago': ['USD', 'TTD'], // USD energy trade
    };
    
    final suggestions = borderCurrencies[country];
    if (suggestions != null) {
      return List.from(suggestions);
    }
    
    // If no specific border currencies defined, fall back to regional currencies
    return getNearbyCountryCurrencies(country, maxSuggestions: 3);
  }
  
  /// Get currency suggestions for international travel corridors
  /// 
  /// Some routes and corridors have specific currency usage patterns
  /// due to heavy tourism, business travel, or trade relationships.
  /// 
  /// [fromCountry] - Origin country
  /// [toCountry] - Destination country
  /// 
  /// Returns currencies commonly useful for travel between these countries
  static List<String> getTravelCorridorCurrencies(String fromCountry, String toCountry) {
    // Define major travel corridor currency patterns
    const travelCorridors = <String, Map<String, List<String>>>{
      // European travel corridors
      'Germany': {
        'Switzerland': ['EUR', 'CHF'],
        'France': ['EUR'],
        'Austria': ['EUR'],
        'Czech Republic': ['EUR', 'CZK'],
      },
      'United Kingdom': {
        'France': ['GBP', 'EUR'],
        'Spain': ['GBP', 'EUR'],
        'Germany': ['GBP', 'EUR'],
        'Italy': ['GBP', 'EUR'],
      },
      
      // North American corridors
      'United States': {
        'Canada': ['USD', 'CAD'],
        'Mexico': ['USD', 'MXN'],
      },
      'Canada': {
        'United States': ['CAD', 'USD'],
      },
      
      // Asian business corridors
      'Japan': {
        'South Korea': ['JPY', 'KRW', 'USD'],
        'China': ['JPY', 'CNY', 'USD'],
        'Singapore': ['JPY', 'SGD', 'USD'],
      },
      'Singapore': {
        'Malaysia': ['SGD', 'MYR'],
        'Thailand': ['SGD', 'THB', 'USD'],
        'Indonesia': ['SGD', 'IDR', 'USD'],
      },
      
      // Middle East business corridors
      'United Arab Emirates': {
        'Saudi Arabia': ['AED', 'SAR', 'USD'],
        'Qatar': ['AED', 'QAR', 'USD'],
        'India': ['AED', 'INR', 'USD'],
      },
    };
    
    final fromCorridors = travelCorridors[fromCountry];
    if (fromCorridors != null) {
      final specificCorridor = fromCorridors[toCountry];
      if (specificCorridor != null) {
        return List.from(specificCorridor);
      }
    }
    
    // If no specific corridor, combine regional currencies from both countries
    final fromRegionalCurrencies = getNearbyCountryCurrencies(fromCountry, maxSuggestions: 3);
    final toRegionalCurrencies = getNearbyCountryCurrencies(toCountry, maxSuggestions: 3);
    
    final combined = <String>{};
    combined.addAll(fromRegionalCurrencies);
    combined.addAll(toRegionalCurrencies);
    combined.add('USD'); // USD as international fallback
    
    return combined.toList();
  }
  
  /// Get currencies for specific economic zones or trade blocs
  /// 
  /// Economic integration areas often have currency usage patterns
  /// that transcend individual country borders.
  /// 
  /// [country] - The reference country
  /// 
  /// Returns currencies commonly used in the same economic zone
  static List<String> getEconomicZoneCurrencies(String country) {
    // Define economic zones and their common currencies
    const economicZones = <String, List<String>>{
      // Eurozone (obviously EUR)
      'Germany': ['EUR'],
      'France': ['EUR'],
      'Italy': ['EUR'],
      'Spain': ['EUR'],
      'Netherlands': ['EUR'],
      'Belgium': ['EUR'],
      'Austria': ['EUR'],
      'Portugal': ['EUR'],
      'Ireland': ['EUR'],
      'Greece': ['EUR'],
      'Finland': ['EUR'],
      'Luxembourg': ['EUR'],
      'Slovenia': ['EUR'],
      'Slovakia': ['EUR'],
      'Estonia': ['EUR'],
      'Latvia': ['EUR'],
      'Lithuania': ['EUR'],
      'Malta': ['EUR'],
      'Cyprus': ['EUR'],
      
      // USMCA (formerly NAFTA)
      'United States': ['USD', 'CAD', 'MXN'],
      'Canada': ['CAD', 'USD', 'MXN'],
      'Mexico': ['MXN', 'USD', 'CAD'],
      
      // ASEAN economic integration
      'Singapore': ['SGD', 'MYR', 'THB', 'IDR', 'PHP'],
      'Malaysia': ['MYR', 'SGD', 'THB', 'IDR'],
      'Thailand': ['THB', 'SGD', 'MYR', 'VND'],
      'Indonesia': ['IDR', 'SGD', 'MYR', 'USD'],
      'Philippines': ['PHP', 'SGD', 'USD'],
      'Vietnam': ['VND', 'THB', 'USD'],
      
      // GCC (Gulf Cooperation Council) - USD pegged economies
      'United Arab Emirates': ['AED', 'SAR', 'QAR', 'USD'],
      'Saudi Arabia': ['SAR', 'AED', 'QAR', 'USD'],
      'Qatar': ['QAR', 'AED', 'SAR', 'USD'],
      'Kuwait': ['KWD', 'AED', 'SAR', 'USD'],
      'Bahrain': ['BHD', 'AED', 'SAR', 'USD'],
      'Oman': ['OMR', 'AED', 'SAR', 'USD'],
      
      // Mercosur (South American trade bloc)
      'Brazil': ['BRL', 'ARS', 'UYU', 'PYG'],
      'Argentina': ['ARS', 'BRL', 'UYU', 'USD'],
      'Uruguay': ['UYU', 'ARS', 'BRL', 'USD'],
      'Paraguay': ['PYG', 'ARS', 'BRL', 'USD'],
      
      // East African Community
      'Kenya': ['KES', 'TZS', 'UGX', 'USD'],
      'Tanzania': ['TZS', 'KES', 'UGX', 'USD'],
      'Uganda': ['UGX', 'KES', 'TZS', 'USD'],
    };
    
    final zoneCurrencies = economicZones[country];
    if (zoneCurrencies != null) {
      return List.from(zoneCurrencies);
    }
    
    // If no specific economic zone, fall back to regional currencies
    return getNearbyCountryCurrencies(country);
  }
  
  /// Get comprehensive geographic currency suggestions
  /// 
  /// This method combines multiple geographic factors to provide the most
  /// comprehensive set of currency suggestions for a country.
  /// 
  /// [country] - The reference country
  /// [maxSuggestions] - Maximum number of suggestions to return
  /// 
  /// Returns a prioritized list of currencies based on all geographic factors
  static List<String> getComprehensiveGeographicSuggestions(
    String country, {
    int maxSuggestions = 10,
  }) {
    final suggestions = <String>{};
    
    // 1. Regional currencies
    final regionalCurrencies = getNearbyCountryCurrencies(country);
    suggestions.addAll(regionalCurrencies);
    
    // 2. Border currencies
    final borderCurrencies = getBorderCurrencySuggestions(country);
    suggestions.addAll(borderCurrencies);
    
    // 3. Economic zone currencies
    final zoneCurrencies = getEconomicZoneCurrencies(country);
    suggestions.addAll(zoneCurrencies);
    
    // 4. Major international currencies as fallback
    suggestions.addAll(['USD', 'EUR', 'GBP', 'JPY']);
    
    return suggestions.take(maxSuggestions).toList();
  }
}