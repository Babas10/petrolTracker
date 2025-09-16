import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:petrol_tracker/services/local_currency_converter.dart';
import 'package:petrol_tracker/services/exchange_rate_cache.dart';

part 'local_currency_providers.g.dart';

/// Provider for the local currency converter singleton
/// 
/// Provides access to the enhanced local currency conversion system
/// with advanced caching, fallback strategies, and batch operations.
@riverpod
LocalCurrencyConverter localCurrencyConverter(LocalCurrencyConverterRef ref) {
  return LocalCurrencyConverter.instance;
}

/// Provider for the exchange rate cache singleton
/// 
/// Provides access to the advanced exchange rate caching system
/// with intelligent management and performance monitoring.
@riverpod
ExchangeRateCache exchangeRateCache(ExchangeRateCacheRef ref) {
  return ExchangeRateCache.instance;
}

/// Provider for checking if local conversion is available between two currencies
/// 
/// This is useful for UI components to show/hide conversion features
/// based on actual rate availability.
@riverpod
Future<bool> canConvertLocally(
  CanConvertLocallyRef ref,
  String fromCurrency,
  String toCurrency,
) async {
  final converter = ref.read(localCurrencyConverterProvider);
  return converter.canConvert(fromCurrency, toCurrency);
}

/// Provider for getting available exchange rates for a base currency
/// 
/// Returns all cached exchange rates for the specified currency.
/// Useful for displaying available conversion options to users.
@riverpod
Future<Map<String, double>> availableRates(
  AvailableRatesRef ref,
  String baseCurrency,
) async {
  final converter = ref.read(localCurrencyConverterProvider);
  return converter.getAvailableRates(baseCurrency);
}

/// Provider for cache health monitoring
/// 
/// Provides real-time information about the health of the currency cache.
/// Useful for displaying cache status in admin/debug screens.
@riverpod
Future<CacheHealthReport> cacheHealth(CacheHealthRef ref) async {
  final cache = ref.read(exchangeRateCacheProvider);
  return cache.getCacheHealth();
}

/// Provider for cache statistics
/// 
/// Provides detailed statistics about cache usage and performance.
/// Useful for monitoring and optimization.
@riverpod
Future<Map<String, dynamic>> cacheStatistics(CacheStatisticsRef ref) async {
  final cache = ref.read(exchangeRateCacheProvider);
  final converter = ref.read(localCurrencyConverterProvider);
  
  final cacheStats = await cache.getCacheStatistics();
  final converterStats = await converter.getCacheStats();
  
  return {
    'exchange_rate_cache': cacheStats,
    'local_converter_cache': converterStats,
    'combined_health': await cache.getCacheHealth(),
  };
}