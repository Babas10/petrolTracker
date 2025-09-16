# Local Currency Conversion System

## Overview

The Local Currency Conversion System provides fast, reliable currency conversions without requiring API calls during normal usage. It includes sophisticated rate caching, bidirectional conversions, batch operations, and comprehensive error handling.

## Architecture

The system consists of several key components:

### Core Components

1. **LocalCurrencyConverter** - Main conversion engine
2. **ExchangeRateCache** - Advanced caching system
3. **ConversionValidator** - Input validation utilities
4. **Local Currency Providers** - Riverpod providers for dependency injection

## Features

### ✨ Core Capabilities

- **Fast Local Conversions**: Uses cached exchange rates for instant conversions
- **Bidirectional Support**: Handles direct rates (USD→EUR) and reverse rates (EUR→USD)
- **Cross-Currency Conversion**: Converts via base currencies (GBP→JPY via USD)
- **Batch Operations**: Efficiently converts multiple amounts in single operations
- **Advanced Caching**: Multi-level caching with intelligent management
- **Comprehensive Validation**: Validates amounts, currencies, and conversion results
- **Fallback Strategies**: Multiple strategies when direct rates are unavailable
- **Performance Optimization**: Memory cache with LRU eviction and prefetching

### 🔄 Conversion Strategies

The system uses a hierarchical approach to find exchange rates:

1. **Direct Rate**: Try direct conversion (from → to)
2. **Reverse Rate**: Try inverse of reverse rate (to → from)
3. **Cross-Currency via USD**: Convert from → USD → to
4. **Cross-Currency via EUR**: Convert from → EUR → to (if USD not available)

## Usage

### Basic Conversion

```dart
import 'package:petrol_tracker/services/local_currency_converter.dart';

final converter = LocalCurrencyConverter.instance;

// Simple conversion
final result = await converter.convertAmount(
  amount: 100.0,
  fromCurrency: 'EUR',
  toCurrency: 'USD',
);

if (result != null) {
  print('${result.originalAmount} ${result.originalCurrency} = '
        '${result.convertedAmount} ${result.targetCurrency}');
  print('Exchange rate: ${result.exchangeRate}');
}
```

### Batch Conversion

```dart
// Convert multiple amounts efficiently
final conversions = await converter.convertBatch(
  amounts: [100.0, 200.0, 300.0],
  fromCurrencies: ['EUR', 'GBP', 'JPY'],
  toCurrency: 'USD',
);

print('Converted ${conversions.length} amounts to USD');
```

### Fuel Entry Conversion

```dart
// Convert fuel entries to primary currency
final convertedEntries = await converter.convertFuelEntriesToPrimary(
  fuelEntries,
  'USD', // User's primary currency
);

// All entries are now in USD with original amounts preserved
```

### Using Providers (Recommended)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/providers/local_currency_providers.dart';

class CurrencyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final converter = ref.read(localCurrencyConverterProvider);
    
    // Check if conversion is possible
    final canConvert = ref.watch(canConvertLocallyProvider('EUR', 'USD'));
    
    return canConvert.when(
      data: (possible) => possible 
        ? Text('Conversion available') 
        : Text('Conversion not available'),
      loading: () => CircularProgressIndicator(),
      error: (_, __) => Text('Error checking conversion'),
    );
  }
}
```

## Configuration

### CurrencyConverterConfig

```dart
class CurrencyConverterConfig {
  // Maximum amount that can be converted (prevents overflow)
  static const double maxConvertibleAmount = 1000000000.0;
  
  // Minimum amount that can be converted
  static const double minConvertibleAmount = 0.001;
  
  // Default base currency for cross-conversions
  static const String defaultBaseCurrency = 'USD';
  
  // Cache expiration time (24 hours)
  static const Duration cacheExpiration = Duration(hours: 24);
  
  // Memory cache size limit (number of currency pairs)
  static const int memoryCacheLimit = 100;
}
```

### ExchangeRateCacheConfig

```dart
class ExchangeRateCacheConfig {
  // Cache key prefixes
  static const String ratesCachePrefix = 'currency_rates_';
  static const String timestampPrefix = 'currency_rates_timestamp_';
  
  // Cache settings
  static const Duration defaultExpiration = Duration(hours: 24);
  static const Duration staleCacheGracePeriod = Duration(hours: 12);
  static const int maxMemoryCacheSize = 50;
  static const int maxRatesPerCurrency = 200;
}
```

## Cache Management

### Cache Health Monitoring

```dart
final cache = ExchangeRateCache.instance;

// Get cache health report
final healthReport = await cache.getCacheHealth();

print('Cache Status: ${healthReport.status}');
print('Health Percentage: ${healthReport.healthPercentage}%');
print('Fresh Currencies: ${healthReport.freshCurrencies}');
print('Stale Currencies: ${healthReport.staleCurrencies}');
print('Missing Currencies: ${healthReport.missingCurrencies}');
```

### Cache Statistics

```dart
// Get detailed cache statistics
final stats = await cache.getCacheStatistics();

print('Memory Cache Size: ${stats['memory_cache_size']}');
print('Persistent Cache: ${stats['persistent_cache_currencies']} currencies');
print('Most Accessed: ${stats['most_accessed_currencies']}');
```

### Cache Maintenance

```dart
// Clear specific currency cache
await cache.clearCurrency('EUR');

// Clear all cache data
await cache.clearAllCache();

// Prefetch common currencies
await cache.prefetchCommonCurrencies();
```

## Error Handling

### Validation Results

```dart
final validation = ConversionValidator.validateConversion(
  amount: 100.0,
  fromCurrency: 'USD',
  toCurrency: 'EUR',
);

if (!validation.isValid) {
  print('Validation failed: ${validation.errorMessage}');
}
```

### Common Error Scenarios

1. **Invalid Amount**: Negative, zero, or extremely large amounts
2. **Invalid Currency**: Unknown or malformed currency codes
3. **Missing Rates**: No cached exchange rates available
4. **Corrupted Cache**: Invalid cache data format
5. **Network Issues**: When fetching fresh rates (handled gracefully)

### Fallback Behavior

- **Missing Direct Rate**: Try reverse rate or cross-currency conversion
- **Stale Rates**: Continue using stale rates within grace period
- **Cache Corruption**: Skip corrupted entries and use valid cached data
- **Conversion Failure**: Return null instead of throwing exceptions

## Performance Considerations

### Memory Management

- **LRU Eviction**: Removes least recently used currencies when cache is full
- **Memory Limits**: Configurable limits prevent excessive memory usage
- **Access Tracking**: Monitors currency access patterns for optimization

### Batch Operations

- **Prefetching**: Pre-loads rates for all currencies in batch operations
- **Parallel Processing**: Processes multiple conversions concurrently
- **Rate Reuse**: Reuses loaded rates for multiple conversions

### Caching Strategy

- **Two-Level Cache**: Memory cache for speed, persistent cache for durability
- **Intelligent Prefetching**: Loads commonly used currencies proactively
- **Metadata Tracking**: Monitors usage patterns and cache health

## Integration with Existing Systems

### Currency Service Integration

The local converter works alongside the existing `CurrencyService`:

- **CurrencyService**: Fetches fresh rates from API (once daily)
- **LocalCurrencyConverter**: Performs fast local conversions using cached rates
- **Shared Cache**: Both systems use the same underlying cache storage

### Fuel Entry Integration

```dart
// When saving a fuel entry with currency conversion
final fuelEntry = FuelEntryModel.create(
  // ... other fields
  price: convertedPrice,        // Price in user's primary currency
  currency: primaryCurrency,    // User's primary currency
  originalAmount: originalPrice, // Original price before conversion
  // originalCurrency is stored in the currency field of the transaction
);
```

## Testing

### Unit Tests

- **Basic Conversions**: Same currency, direct rates, reverse rates, cross-currency
- **Validation**: Invalid inputs, edge cases, extreme values
- **Batch Operations**: Multiple conversions, mixed success/failure
- **Cache Management**: Memory limits, LRU eviction, statistics
- **Error Handling**: Missing rates, corrupted data, validation failures

### Integration Tests

- **End-to-End Flow**: Complete fuel entry conversion workflow
- **Performance**: Large batch conversions, cache efficiency
- **Real-World Scenarios**: International travel, business reporting
- **Cache Health**: Health monitoring, statistics accuracy

### Test Data Setup

```dart
// Set up test exchange rates
await cache.saveRates('USD', {
  'EUR': 0.85,
  'GBP': 0.73,
  'JPY': 110.0,
}, source: 'test');
```

## Migration Guide

### From CurrencyService

If you're currently using the basic `CurrencyService` directly:

```dart
// Before
final service = CurrencyService.instance;
final conversion = await service.convertAmount(
  amount: 100,
  fromCurrency: 'USD',
  toCurrency: 'EUR',
);

// After
final converter = LocalCurrencyConverter.instance;
final conversion = await converter.convertAmount(
  amount: 100,
  fromCurrency: 'USD',
  toCurrency: 'EUR',
);
```

### Provider Migration

```dart
// Before
final service = ref.read(currencyServiceProvider);

// After
final converter = ref.read(localCurrencyConverterProvider);
```

## Best Practices

### 1. Use Providers for Dependency Injection

```dart
// Good
final converter = ref.read(localCurrencyConverterProvider);

// Avoid
final converter = LocalCurrencyConverter.instance;
```

### 2. Check Conversion Availability

```dart
// Check before attempting conversion
final canConvert = await converter.canConvert('EUR', 'USD');
if (canConvert) {
  final result = await converter.convertAmount(...);
}
```

### 3. Use Batch Operations for Multiple Conversions

```dart
// Good - single batch operation
final conversions = await converter.convertBatch(...);

// Avoid - multiple individual conversions
for (final entry in entries) {
  await converter.convertAmount(...); // Inefficient
}
```

### 4. Monitor Cache Health

```dart
// Regular health checks in admin/debug screens
final health = await cache.getCacheHealth();
if (!health.isAcceptable) {
  // Trigger cache refresh or show warning
}
```

### 5. Handle Null Results Gracefully

```dart
final conversion = await converter.convertAmount(...);
if (conversion != null) {
  // Use conversion result
} else {
  // Fallback behavior or error handling
}
```

## Troubleshooting

### Common Issues

1. **Conversion Returns Null**
   - Check if currencies are valid
   - Verify exchange rates are cached
   - Check amount is within valid range

2. **Poor Performance**
   - Monitor cache hit rates
   - Use batch operations for multiple conversions
   - Consider prefetching common currencies

3. **Cache Issues**
   - Check cache health report
   - Clear corrupted cache data
   - Verify storage permissions

4. **Memory Usage**
   - Monitor cache statistics
   - Adjust memory cache limits
   - Clear unused cache entries

### Debug Information

```dart
// Get comprehensive debug information
final converterStats = await converter.getCacheStats();
final cacheStats = await cache.getCacheStatistics();
final healthReport = await cache.getCacheHealth();

print('Converter: $converterStats');
print('Cache: $cacheStats');
print('Health: $healthReport');
```

## Future Enhancements

### Planned Features

- **Rate Interpolation**: Calculate rates for missing currency pairs
- **Historical Rate Support**: Cache and use historical exchange rates
- **Rate Confidence Scoring**: Score rate reliability based on age and source
- **Automatic Refresh**: Background refresh of stale rates
- **Currency Volatility Tracking**: Monitor and alert on significant rate changes

### Performance Optimizations

- **Compression**: Compress cached rate data to reduce storage usage
- **Predictive Caching**: Pre-load rates based on usage patterns
- **Rate Aggregation**: Combine rates from multiple sources for accuracy
- **Delta Updates**: Only sync changed rates instead of full rate sets

---

*This system provides enterprise-grade currency conversion capabilities while maintaining simplicity and performance for everyday use.*