import '../models/currency_info.dart';

/// Comprehensive metadata for all supported currencies
/// 
/// This class provides detailed information about currencies including
/// symbols, names, and country associations. Data is based on ISO 4217
/// standards and real-world usage patterns.
class CurrencyMetadata {
  static const Map<String, CurrencyInfo> currencyInfo = {
    // Major International Currencies
    'USD': CurrencyInfo(
      code: 'USD',
      name: 'US Dollar',
      symbol: '\$',
      decimalPlaces: 2,
      countries: ['United States'],
      alternativeSymbols: ['US\$'],
      isInternational: true,
      notes: 'Most widely used international reserve currency',
    ),
    
    'EUR': CurrencyInfo(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      decimalPlaces: 2,
      countries: [
        'Germany', 'France', 'Italy', 'Spain', 'Netherlands',
        'Austria', 'Belgium', 'Finland', 'Ireland', 'Portugal',
        'Luxembourg', 'Slovenia', 'Slovakia', 'Estonia', 'Latvia',
        'Lithuania', 'Malta', 'Cyprus', 'Greece'
      ],
      alternativeSymbols: ['EUR'],
      isInternational: true,
      notes: 'Official currency of the Eurozone',
    ),
    
    // European Currencies (Non-Euro)
    'CHF': CurrencyInfo(
      code: 'CHF',
      name: 'Swiss Franc',
      symbol: 'CHF',
      decimalPlaces: 2,
      countries: ['Switzerland', 'Liechtenstein'],
      alternativeSymbols: ['Fr.', 'SFr.'],
      isInternational: false,
      notes: 'Known for stability, often used as safe-haven currency',
    ),
    
    'GBP': CurrencyInfo(
      code: 'GBP',
      name: 'British Pound Sterling',
      symbol: '£',
      decimalPlaces: 2,
      countries: ['United Kingdom'],
      alternativeSymbols: ['GBP'],
      isInternational: true,
      notes: 'One of the oldest currencies still in use',
    ),
    
    'NOK': CurrencyInfo(
      code: 'NOK',
      name: 'Norwegian Krone',
      symbol: 'kr',
      decimalPlaces: 2,
      countries: ['Norway'],
      alternativeSymbols: ['NOK'],
      isInternational: false,
    ),
    
    'SEK': CurrencyInfo(
      code: 'SEK',
      name: 'Swedish Krona',
      symbol: 'kr',
      decimalPlaces: 2,
      countries: ['Sweden'],
      alternativeSymbols: ['SEK'],
      isInternational: false,
    ),
    
    'DKK': CurrencyInfo(
      code: 'DKK',
      name: 'Danish Krone',
      symbol: 'kr',
      decimalPlaces: 2,
      countries: ['Denmark'],
      alternativeSymbols: ['DKK'],
      isInternational: false,
    ),
    
    'PLN': CurrencyInfo(
      code: 'PLN',
      name: 'Polish Złoty',
      symbol: 'zł',
      decimalPlaces: 2,
      countries: ['Poland'],
      alternativeSymbols: ['PLN'],
      isInternational: false,
    ),
    
    'CZK': CurrencyInfo(
      code: 'CZK',
      name: 'Czech Koruna',
      symbol: 'Kč',
      decimalPlaces: 2,
      countries: ['Czech Republic'],
      alternativeSymbols: ['CZK'],
      isInternational: false,
    ),
    
    'HUF': CurrencyInfo(
      code: 'HUF',
      name: 'Hungarian Forint',
      symbol: 'Ft',
      decimalPlaces: 2,
      countries: ['Hungary'],
      alternativeSymbols: ['HUF'],
      isInternational: false,
    ),
    
    // North American Currencies
    'CAD': CurrencyInfo(
      code: 'CAD',
      name: 'Canadian Dollar',
      symbol: 'C\$',
      decimalPlaces: 2,
      countries: ['Canada'],
      alternativeSymbols: ['\$', 'CAD'],
      isInternational: false,
      notes: 'Often accepted alongside USD in border regions',
    ),
    
    'MXN': CurrencyInfo(
      code: 'MXN',
      name: 'Mexican Peso',
      symbol: '\$',
      decimalPlaces: 2,
      countries: ['Mexico'],
      alternativeSymbols: ['Mex\$', 'MXN'],
      isInternational: false,
      notes: 'USD widely accepted in tourist areas',
    ),
    
    // Asian Currencies
    'JPY': CurrencyInfo(
      code: 'JPY',
      name: 'Japanese Yen',
      symbol: '¥',
      decimalPlaces: 0,
      countries: ['Japan'],
      alternativeSymbols: ['JPY'],
      isInternational: true,
      notes: 'No decimal subdivision in everyday use',
    ),
    
    'KRW': CurrencyInfo(
      code: 'KRW',
      name: 'South Korean Won',
      symbol: '₩',
      decimalPlaces: 0,
      countries: ['South Korea'],
      alternativeSymbols: ['KRW'],
      isInternational: false,
      notes: 'No decimal subdivision in everyday use',
    ),
    
    'CNY': CurrencyInfo(
      code: 'CNY',
      name: 'Chinese Yuan',
      symbol: '¥',
      decimalPlaces: 2,
      countries: ['China'],
      alternativeSymbols: ['RMB', 'CNY'],
      isInternational: true,
      notes: 'Also known as Renminbi (RMB)',
    ),
    
    'INR': CurrencyInfo(
      code: 'INR',
      name: 'Indian Rupee',
      symbol: '₹',
      decimalPlaces: 2,
      countries: ['India'],
      alternativeSymbols: ['Rs', 'INR'],
      isInternational: false,
    ),
    
    'SGD': CurrencyInfo(
      code: 'SGD',
      name: 'Singapore Dollar',
      symbol: 'S\$',
      decimalPlaces: 2,
      countries: ['Singapore'],
      alternativeSymbols: ['\$', 'SGD'],
      isInternational: false,
    ),
    
    'THB': CurrencyInfo(
      code: 'THB',
      name: 'Thai Baht',
      symbol: '฿',
      decimalPlaces: 2,
      countries: ['Thailand'],
      alternativeSymbols: ['THB'],
      isInternational: false,
    ),
    
    'HKD': CurrencyInfo(
      code: 'HKD',
      name: 'Hong Kong Dollar',
      symbol: 'HK\$',
      decimalPlaces: 2,
      countries: ['Hong Kong'],
      alternativeSymbols: ['\$', 'HKD'],
      isInternational: false,
    ),
    
    'MYR': CurrencyInfo(
      code: 'MYR',
      name: 'Malaysian Ringgit',
      symbol: 'RM',
      decimalPlaces: 2,
      countries: ['Malaysia'],
      alternativeSymbols: ['MYR'],
      isInternational: false,
    ),
    
    'IDR': CurrencyInfo(
      code: 'IDR',
      name: 'Indonesian Rupiah',
      symbol: 'Rp',
      decimalPlaces: 2,
      countries: ['Indonesia'],
      alternativeSymbols: ['IDR'],
      isInternational: false,
      notes: 'Often quoted without decimals due to large denominations',
    ),
    
    'PHP': CurrencyInfo(
      code: 'PHP',
      name: 'Philippine Peso',
      symbol: '₱',
      decimalPlaces: 2,
      countries: ['Philippines'],
      alternativeSymbols: ['PHP'],
      isInternational: false,
    ),
    
    'VND': CurrencyInfo(
      code: 'VND',
      name: 'Vietnamese Dong',
      symbol: '₫',
      decimalPlaces: 0,
      countries: ['Vietnam'],
      alternativeSymbols: ['VND'],
      isInternational: false,
      notes: 'No decimal subdivision in everyday use',
    ),
    
    // Oceania Currencies
    'AUD': CurrencyInfo(
      code: 'AUD',
      name: 'Australian Dollar',
      symbol: 'A\$',
      decimalPlaces: 2,
      countries: ['Australia'],
      alternativeSymbols: ['\$', 'AUD'],
      isInternational: false,
      notes: 'Also used in several Pacific islands',
    ),
    
    'NZD': CurrencyInfo(
      code: 'NZD',
      name: 'New Zealand Dollar',
      symbol: 'NZ\$',
      decimalPlaces: 2,
      countries: ['New Zealand'],
      alternativeSymbols: ['\$', 'NZD'],
      isInternational: false,
    ),
    
    // South American Currencies
    'BRL': CurrencyInfo(
      code: 'BRL',
      name: 'Brazilian Real',
      symbol: 'R\$',
      decimalPlaces: 2,
      countries: ['Brazil'],
      alternativeSymbols: ['BRL'],
      isInternational: false,
    ),
    
    'ARS': CurrencyInfo(
      code: 'ARS',
      name: 'Argentine Peso',
      symbol: '\$',
      decimalPlaces: 2,
      countries: ['Argentina'],
      alternativeSymbols: ['ARS'],
      isInternational: false,
    ),
    
    'CLP': CurrencyInfo(
      code: 'CLP',
      name: 'Chilean Peso',
      symbol: '\$',
      decimalPlaces: 0,
      countries: ['Chile'],
      alternativeSymbols: ['CLP'],
      isInternational: false,
      notes: 'No decimal subdivision in everyday use',
    ),
    
    'COP': CurrencyInfo(
      code: 'COP',
      name: 'Colombian Peso',
      symbol: '\$',
      decimalPlaces: 2,
      countries: ['Colombia'],
      alternativeSymbols: ['COP'],
      isInternational: false,
    ),
    
    'PEN': CurrencyInfo(
      code: 'PEN',
      name: 'Peruvian Sol',
      symbol: 'S/',
      decimalPlaces: 2,
      countries: ['Peru'],
      alternativeSymbols: ['PEN'],
      isInternational: false,
    ),
    
    // Other Important Currencies
    'RUB': CurrencyInfo(
      code: 'RUB',
      name: 'Russian Ruble',
      symbol: '₽',
      decimalPlaces: 2,
      countries: ['Russia'],
      alternativeSymbols: ['RUB'],
      isInternational: false,
    ),
    
    'TRY': CurrencyInfo(
      code: 'TRY',
      name: 'Turkish Lira',
      symbol: '₺',
      decimalPlaces: 2,
      countries: ['Turkey'],
      alternativeSymbols: ['TL', 'TRY'],
      isInternational: false,
    ),
    
    'ZAR': CurrencyInfo(
      code: 'ZAR',
      name: 'South African Rand',
      symbol: 'R',
      decimalPlaces: 2,
      countries: ['South Africa'],
      alternativeSymbols: ['ZAR'],
      isInternational: false,
    ),
    
    // Middle Eastern Currencies
    'AED': CurrencyInfo(
      code: 'AED',
      name: 'UAE Dirham',
      symbol: 'د.إ',
      decimalPlaces: 2,
      countries: ['United Arab Emirates'],
      alternativeSymbols: ['AED'],
      isInternational: false,
    ),
    
    'SAR': CurrencyInfo(
      code: 'SAR',
      name: 'Saudi Riyal',
      symbol: 'ر.س',
      decimalPlaces: 2,
      countries: ['Saudi Arabia'],
      alternativeSymbols: ['SAR'],
      isInternational: false,
    ),
  };
  
  /// Get currency information by currency code
  static CurrencyInfo? getCurrencyInfo(String currencyCode) {
    return currencyInfo[currencyCode.toUpperCase()];
  }
  
  /// Get all supported currency codes
  static List<String> getSupportedCurrencies() {
    return currencyInfo.keys.toList()..sort();
  }
  
  /// Get currencies by region
  static List<String> getCurrenciesByRegion(CurrencyRegion region) {
    return CurrencyRegionConfig.regionCurrencies[region] ?? [];
  }
  
  /// Check if a currency code is supported
  static bool isSupportedCurrency(String currencyCode) {
    return currencyInfo.containsKey(currencyCode.toUpperCase());
  }
  
  /// Get international currencies (widely used for international trade)
  static List<String> getInternationalCurrencies() {
    return currencyInfo.entries
        .where((entry) => entry.value.isInternational)
        .map((entry) => entry.key)
        .toList()
      ..sort();
  }
  
  /// Get currencies with zero decimal places (like JPY, KRW)
  static List<String> getZeroDecimalCurrencies() {
    return currencyInfo.entries
        .where((entry) => entry.value.decimalPlaces == 0)
        .map((entry) => entry.key)
        .toList();
  }
}