# Country-Currency Mapping Service Documentation

## Overview

The Country-Currency Mapping Service provides comprehensive intelligent currency suggestions based on country selection. This system enables smart currency filtering for fuel entry forms and other currency selection interfaces throughout the application.

## Architecture

The service is composed of several interconnected components:

### Core Components

1. **CountryCurrencyService** - Main service for country-to-currency mappings
2. **CurrencyMetadata** - Comprehensive currency information database
3. **GeographicCurrencyDetector** - Geographic and regional currency analysis
4. **CurrencyUsageTracker** - Historical usage pattern tracking
5. **SmartCurrencyProvider** - Intelligent suggestion aggregator

### Data Models

- **CurrencyInfo** - Comprehensive currency metadata (using Freezed)
- **CurrencySuggestion** - Currency suggestion with reasoning
- **DetailedCurrencySuggestion** - Enhanced suggestion with confidence and metadata

## Features

### Smart Currency Filtering

The service provides intelligent currency suggestions based on multiple factors:

1. **Primary Currency Mapping** - Official currency for each country
2. **Multi-Currency Support** - Countries that commonly accept multiple currencies
3. **User Default Integration** - Always includes user's preferred currency
4. **Regional Intelligence** - Currencies common in geographic regions
5. **Historical Patterns** - User's past currency selections
6. **Travel Optimization** - Corridor-specific currency suggestions

### Supported Countries

The service supports 80+ countries across all continents:

#### Europe
- Eurozone countries (EUR)
- Non-Euro European countries (GBP, CHF, NOK, SEK, DKK, PLN, CZK, HUF, etc.)
- Multi-currency regions (Switzerland accepts CHF and EUR)

#### North America
- United States (USD)
- Canada (CAD, USD accepted)
- Mexico (MXN, USD common in tourist areas)

#### Asia Pacific
- Major economies (JPY, CNY, INR, KRW, SGD, HKD)
- ASEAN countries (THB, MYR, IDR, PHP, VND)
- Financial centers (USD widely accepted)

#### Other Regions
- Middle East (AED, SAR, QAR with USD in business)
- South America (BRL, ARS, CLP, COP, PEN with USD influence)
- Africa (ZAR, NGN, EGP with international currency acceptance)
- Oceania (AUD, NZD)

## Usage Examples

### Basic Currency Filtering

```dart
// Get smart currency suggestions for a country
final currencies = CountryCurrencyService.getFilteredCurrencies(
  'Switzerland',
  'USD', // User's default currency
  maxSuggestions: 5,
);
// Returns: ['CHF', 'USD', 'EUR', ...] (primary currency first)
```

### Multi-Currency Country Detection

```dart
// Check if country accepts multiple currencies
final isMultiCurrency = CountryCurrencyService.isMultiCurrencyCountry('Switzerland');
// Returns: true

// Get all currencies for a country
final allCurrencies = CountryCurrencyService.getAllCountryCurrencies('Switzerland');
// Returns: ['CHF', 'EUR']
```

### Geographic Currency Detection

```dart
// Get regional currency suggestions
final regionalCurrencies = GeographicCurrencyDetector.getNearbyCountryCurrencies('Germany');
// Returns: ['EUR', 'CHF', 'GBP', 'NOK', 'SEK'] (European region)

// Get travel-optimized suggestions
final travelCurrencies = GeographicCurrencyDetector.getTravelCorridorCurrencies(
  'Germany', 
  'Switzerland'
);
// Returns: ['EUR', 'CHF'] (common for this route)
```

### Usage Tracking

```dart
// Record currency selection (improves future suggestions)
await CurrencyUsageTracker.recordCurrencyUsage('Switzerland', 'CHF');

// Get user's preferred currencies for a country
final preferred = await CurrencyUsageTracker.getPreferredCurrencies('Switzerland');
// Returns currencies ordered by usage frequency
```

### Smart Suggestions

```dart
// Get intelligent suggestions combining all factors
final suggestions = await SmartCurrencyProvider.getSmartSuggestions(
  country: 'Switzerland',
  userDefaultCurrency: 'USD',
  includeUsageHistory: true,
  includeRegionalCurrencies: true,
);
// Returns prioritized list: [historical usage, primary, user default, regional, international]
```

### Detailed Suggestions with Reasoning

```dart
// Get suggestions with explanations
final detailedSuggestions = await SmartCurrencyProvider.getDetailedSmartSuggestions(
  country: 'Switzerland',
  userDefaultCurrency: 'USD',
);

for (final suggestion in detailedSuggestions) {
  print('${suggestion.currencyCode}: ${suggestion.explanation}');
  print('Confidence: ${suggestion.confidenceLevel}');
  print('Reason: ${suggestion.reasonDescription}');
}
```

## Configuration

### Regional Mapping

Countries are grouped into geographic regions:

- **Europe** - EUR, CHF, GBP, NOK, SEK, DKK, PLN, CZK, HUF
- **North America** - USD, CAD, MXN
- **Asia Pacific** - JPY, KRW, CNY, INR, SGD, HKD, THB, MYR, IDR, PHP, VND
- **BRICS** - BRL, RUB, INR, CNY, ZAR
- **Middle East** - AED, SAR, QAR, KWD, BHD, OMR
- **Africa** - ZAR, NGN, EGP, MAD, TND, KES
- **South America** - BRL, ARS, CLP, COP, PEN, UYU
- **Oceania** - AUD, NZD, FJD, PGK

### Multi-Currency Countries

Countries with significant multi-currency usage:

```dart
static const Map<String, List<String>> multiCurrencyCountries = {
  'Switzerland': ['CHF', 'EUR'], // EUR near borders
  'Canada': ['CAD', 'USD'], // USD widely accepted
  'Mexico': ['MXN', 'USD'], // USD in tourist areas
  'Hong Kong': ['HKD', 'USD', 'CNY'], // Financial center
  'Singapore': ['SGD', 'USD'], // Business hub
  'United Arab Emirates': ['AED', 'USD', 'EUR'], // International business
  // ... more countries
};
```

## Currency Information

### Comprehensive Metadata

Each currency includes detailed information:

```dart
const CurrencyInfo usdInfo = CurrencyInfo(
  code: 'USD',
  name: 'US Dollar',
  symbol: '\$',
  decimalPlaces: 2,
  countries: ['United States'],
  alternativeSymbols: ['US\$'],
  isInternational: true,
  notes: 'Most widely used international reserve currency',
);
```

### Special Properties

- **Zero Decimal Currencies**: JPY, KRW, VND, CLP (no cents/centimes)
- **International Currencies**: USD, EUR, GBP, JPY, CNY (widely accepted)
- **Alternative Symbols**: Context-specific symbols (US$ vs $ for USD)

## Performance Considerations

### Caching Strategy

The service implements multi-level caching:

1. **Static Data** - Country mappings cached in memory
2. **Usage History** - SharedPreferences for persistence
3. **Smart Results** - Computed suggestions cached temporarily

### Optimization Features

- Lazy loading of usage statistics
- Efficient set operations for currency filtering
- Minimal database queries through strategic caching
- Background cleanup of old usage data

### Performance Targets

- Currency lookup: < 1ms
- Smart suggestions: < 10ms
- Usage tracking: < 5ms (async)
- Batch operations: < 50ms for 100 items

## Integration Guide

### Fuel Entry Form Integration

```dart
class FuelEntryForm extends StatefulWidget {
  @override
  _FuelEntryFormState createState() => _FuelEntryFormState();
}

class _FuelEntryFormState extends State<FuelEntryForm> {
  String? selectedCountry;
  String? selectedCurrency;
  String userDefaultCurrency = 'USD'; // From user settings
  
  List<String> availableCurrencies = [];
  
  void _onCountryChanged(String? country) async {
    setState(() {
      selectedCountry = country;
    });
    
    if (country != null) {
      // Get smart currency suggestions
      final currencies = await SmartCurrencyProvider.getSmartSuggestions(
        country: country,
        userDefaultCurrency: userDefaultCurrency,
      );
      
      setState(() {
        availableCurrencies = currencies;
        // Auto-select primary currency if user hasn't selected yet
        selectedCurrency ??= currencies.first;
      });
    }
  }
  
  void _onCurrencySelected(String currency) async {
    setState(() {
      selectedCurrency = currency;
    });
    
    // Record selection to improve future suggestions
    if (selectedCountry != null) {
      await CurrencyUsageTracker.recordCurrencyUsage(
        selectedCountry!,
        currency,
        context: 'fuel_entry',
      );
    }
  }
}
```

### Settings Integration

```dart
// Get usage analytics for settings page
final analytics = await SmartCurrencyProvider.getUsageAnalytics();
print('Countries used: ${analytics['supported_countries_count']}');
print('Most used currencies: ${analytics['globally_preferred_currencies']}');

// Clear usage history if needed
await CurrencyUsageTracker.clearAllUsageData();
```

## Error Handling

### Graceful Degradation

The service provides robust fallback mechanisms:

1. **Unknown Countries** - Returns user default + major international currencies
2. **Invalid Currencies** - Filters out invalid codes automatically
3. **No Usage History** - Falls back to geographic and primary currency suggestions
4. **Service Failures** - Returns basic currency list as ultimate fallback

### Error Logging

All errors are logged with context but don't throw exceptions:

```dart
try {
  final suggestions = await SmartCurrencyProvider.getSmartSuggestions(...);
} catch (e) {
  developer.log('Smart suggestions failed: $e');
  // Falls back to basic suggestions automatically
}
```

## Testing

### Test Coverage

The service includes comprehensive test suites:

- **CountryCurrencyService**: 27 tests covering mappings, filtering, edge cases
- **CurrencyMetadata**: 23 tests covering data integrity and performance
- **GeographicCurrencyDetector**: Regional detection and travel corridors
- **CurrencyUsageTracker**: Historical patterns and analytics
- **SmartCurrencyProvider**: Integration and intelligent suggestions

### Test Examples

```dart
// Test multi-currency country detection
test('should correctly identify multi-currency countries', () {
  expect(CountryCurrencyService.isMultiCurrencyCountry('Switzerland'), isTrue);
  expect(CountryCurrencyService.isMultiCurrencyCountry('Germany'), isFalse);
});

// Test smart filtering
test('should prioritize primary currency first', () {
  final currencies = CountryCurrencyService.getFilteredCurrencies('Germany', 'USD');
  expect(currencies.first, equals('EUR')); // Germany's primary currency
  expect(currencies, contains('USD')); // User's default currency
});
```

## Maintenance

### Adding New Countries

1. Add country to `primaryCurrencyMap` in CountryCurrencyService
2. Add to appropriate region in CurrencyRegionConfig
3. Update multi-currency mapping if applicable
4. Add test cases for the new country
5. Update documentation

### Adding New Currencies

1. Add CurrencyInfo to CurrencyMetadata
2. Add to appropriate regional groupings
3. Update any economic zone mappings
4. Add comprehensive test cases
5. Verify integration with existing countries

### Data Updates

Currency mappings should be reviewed periodically for:
- New countries or currency changes
- Updated multi-currency acceptance patterns
- Economic zone membership changes
- Regional grouping adjustments

## Security and Privacy

### Data Privacy

- All usage tracking is stored locally on device
- No personal currency preferences transmitted to servers
- Users can clear usage history at any time
- No tracking across app installations

### Data Validation

- All currency codes validated against ISO 4217 standards
- Country names sanitized for consistency
- Input validation prevents injection attacks
- Graceful handling of malformed data

## Future Enhancements

### Planned Features

1. **Real-time Exchange Rate Integration** - Live rate display with conversion suggestions
2. **Machine Learning Suggestions** - AI-powered prediction of currency preferences
3. **Location-based Detection** - GPS-based country detection for auto-suggestions
4. **Business Rules Engine** - Configurable rules for enterprise currency policies
5. **Offline Enhancement** - Expanded offline currency conversion capabilities

### API Extensions

Future versions may include:
- REST API for currency suggestions
- Webhook integration for usage analytics
- Export/import of usage patterns
- Integration with expense management systems

---

For technical support or feature requests, please refer to the project's issue tracker or contact the development team.