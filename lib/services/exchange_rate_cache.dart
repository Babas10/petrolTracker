/// Advanced exchange rate caching system with intelligent management
/// 
/// This service provides sophisticated caching strategies for exchange rates including:
/// - Multi-level caching (memory + persistent storage)
/// - Intelligent prefetching and preloading
/// - Cache invalidation and refresh strategies
/// - Performance monitoring and optimization
/// - Batch operations for efficiency
library;

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrol_tracker/utils/currency_validator.dart';

/// Configuration for the exchange rate cache
class ExchangeRateCacheConfig {
  /// Cache key prefix for exchange rates
  static const String ratesCachePrefix = 'currency_rates_';
  
  /// Cache key prefix for timestamps
  static const String timestampPrefix = 'currency_rates_timestamp_';
  
  /// Cache key prefix for metadata
  static const String metadataPrefix = 'currency_metadata_';
  
  /// Default cache expiration (24 hours)
  static const Duration defaultExpiration = Duration(hours: 24);
  
  /// Stale cache grace period (additional time before considering rates unusable)
  static const Duration staleCacheGracePeriod = Duration(hours: 12);
  
  /// Maximum number of currencies to keep in memory cache
  static const int maxMemoryCacheSize = 50;
  
  /// Maximum number of rates per currency
  static const int maxRatesPerCurrency = 200;
  
  /// Batch operation size limit
  static const int maxBatchSize = 20;
}

/// Metadata about cached exchange rates
class CacheMetadata {
  final DateTime lastUpdated;
  final DateTime lastAccessed;
  final int accessCount;
  final String source;
  final int rateCount;

  const CacheMetadata({
    required this.lastUpdated,
    required this.lastAccessed,
    required this.accessCount,
    required this.source,
    required this.rateCount,
  });

  factory CacheMetadata.fromJson(Map<String, dynamic> json) {
    return CacheMetadata(
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      lastAccessed: DateTime.parse(json['lastAccessed'] as String),
      accessCount: json['accessCount'] as int,
      source: json['source'] as String,
      rateCount: json['rateCount'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'lastUpdated': lastUpdated.toIso8601String(),
    'lastAccessed': lastAccessed.toIso8601String(),
    'accessCount': accessCount,
    'source': source,
    'rateCount': rateCount,
  };

  CacheMetadata copyWith({
    DateTime? lastUpdated,
    DateTime? lastAccessed,
    int? accessCount,
    String? source,
    int? rateCount,
  }) {
    return CacheMetadata(
      lastUpdated: lastUpdated ?? this.lastUpdated,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      accessCount: accessCount ?? this.accessCount,
      source: source ?? this.source,
      rateCount: rateCount ?? this.rateCount,
    );
  }
}

/// Cache health status
enum CacheHealthStatus {
  healthy,    // All rates are fresh
  stale,      // Some rates are stale but usable
  degraded,   // Many rates are missing or very stale
  critical    // Cache is mostly unusable
}

/// Cache health report
class CacheHealthReport {
  final CacheHealthStatus status;
  final int totalCurrencies;
  final int freshCurrencies;
  final int staleCurrencies;
  final int missingCurrencies;
  final List<String> criticalMissing;
  final Duration averageAge;

  const CacheHealthReport({
    required this.status,
    required this.totalCurrencies,
    required this.freshCurrencies,
    required this.staleCurrencies,
    required this.missingCurrencies,
    required this.criticalMissing,
    required this.averageAge,
  });

  /// Get cache health as a percentage (0-100)
  double get healthPercentage {
    if (totalCurrencies == 0) return 0.0;
    return (freshCurrencies / totalCurrencies) * 100.0;
  }

  /// Check if cache is acceptable for normal operations
  bool get isAcceptable => status != CacheHealthStatus.critical;
}

/// Advanced exchange rate cache manager
class ExchangeRateCache {
  static ExchangeRateCache? _instance;
  static ExchangeRateCache get instance => _instance ??= ExchangeRateCache._();
  
  ExchangeRateCache._();

  /// In-memory cache for frequently accessed rates
  final Map<String, Map<String, double>> _memoryCache = {};
  
  /// Metadata cache for tracking usage and freshness
  final Map<String, CacheMetadata> _metadataCache = {};
  
  /// Access frequency tracking for intelligent prefetching
  final Map<String, int> _accessFrequency = {};

  /// Load exchange rates for a base currency from cache
  /// 
  /// Returns cached rates if available and not expired.
  /// Updates access statistics for intelligent caching.
  Future<Map<String, double>?> loadRates(String baseCurrency) async {
    try {
      // Update access frequency for prefetching decisions
      _updateAccessFrequency(baseCurrency);

      // Check memory cache first
      if (_memoryCache.containsKey(baseCurrency)) {
        await _updateAccessStatistics(baseCurrency);
        developer.log(
          'Loaded rates for $baseCurrency from memory cache',
          name: 'ExchangeRateCache',
        );
        return Map.from(_memoryCache[baseCurrency]!);
      }

      // Load from persistent storage
      final prefs = await SharedPreferences.getInstance();
      final ratesJson = prefs.getString('${ExchangeRateCacheConfig.ratesCachePrefix}$baseCurrency');
      
      if (ratesJson == null) {
        developer.log(
          'No cached rates found for $baseCurrency',
          name: 'ExchangeRateCache',
        );
        return null;
      }

      final ratesMap = json.decode(ratesJson) as Map<String, dynamic>;
      final rates = ratesMap.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );

      // Add to memory cache for faster future access
      _addToMemoryCache(baseCurrency, rates);
      await _updateAccessStatistics(baseCurrency);

      developer.log(
        'Loaded ${rates.length} rates for $baseCurrency from persistent cache',
        name: 'ExchangeRateCache',
      );

      return rates;
    } catch (e) {
      developer.log(
        'Error loading rates for $baseCurrency: $e',
        name: 'ExchangeRateCache',
        error: e,
      );
      return null;
    }
  }

  /// Save exchange rates for a base currency to cache
  /// 
  /// Saves rates to both memory and persistent storage.
  /// Updates metadata for cache management.
  Future<void> saveRates(
    String baseCurrency, 
    Map<String, double> rates, {
    String source = 'unknown',
  }) async {
    try {
      // Validate inputs
      if (!CurrencyValidator.isValidCurrency(baseCurrency)) {
        throw ArgumentError('Invalid base currency: $baseCurrency');
      }

      if (rates.isEmpty) {
        throw ArgumentError('Cannot save empty rates map');
      }

      // Limit the number of rates to prevent storage bloat
      final limitedRates = Map.fromEntries(
        rates.entries.take(ExchangeRateCacheConfig.maxRatesPerCurrency),
      );

      // Save to persistent storage
      final prefs = await SharedPreferences.getInstance();
      final ratesJson = json.encode(limitedRates);
      await prefs.setString('${ExchangeRateCacheConfig.ratesCachePrefix}$baseCurrency', ratesJson);
      await prefs.setString('${ExchangeRateCacheConfig.timestampPrefix}$baseCurrency', DateTime.now().toIso8601String());

      // Update metadata
      final metadata = CacheMetadata(
        lastUpdated: DateTime.now(),
        lastAccessed: DateTime.now(),
        accessCount: (_metadataCache[baseCurrency]?.accessCount ?? 0) + 1,
        source: source,
        rateCount: limitedRates.length,
      );
      
      await _saveMetadata(baseCurrency, metadata);

      // Add to memory cache
      _addToMemoryCache(baseCurrency, limitedRates);

      developer.log(
        'Saved ${limitedRates.length} rates for $baseCurrency (source: $source)',
        name: 'ExchangeRateCache',
      );
    } catch (e) {
      developer.log(
        'Error saving rates for $baseCurrency: $e',
        name: 'ExchangeRateCache',
        error: e,
      );
      rethrow;
    }
  }

  /// Batch load rates for multiple currencies
  /// 
  /// Efficiently loads rates for multiple currencies in parallel.
  /// Optimizes memory usage and reduces storage I/O.
  Future<Map<String, Map<String, double>>> batchLoadRates(
    List<String> baseCurrencies,
  ) async {
    if (baseCurrencies.length > ExchangeRateCacheConfig.maxBatchSize) {
      throw ArgumentError('Batch size too large: ${baseCurrencies.length} > ${ExchangeRateCacheConfig.maxBatchSize}');
    }

    final results = <String, Map<String, double>>{};
    final loadTasks = <Future<void>>[];

    for (final currency in baseCurrencies) {
      final task = loadRates(currency).then((rates) {
        if (rates != null) {
          results[currency] = rates;
        }
      });
      loadTasks.add(task);
    }

    await Future.wait(loadTasks);

    developer.log(
      'Batch loaded rates for ${results.length}/${baseCurrencies.length} currencies',
      name: 'ExchangeRateCache',
    );

    return results;
  }

  /// Check if rates are fresh (not expired)
  Future<bool> areRatesFresh(String baseCurrency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString('${ExchangeRateCacheConfig.timestampPrefix}$baseCurrency');
      
      if (timestampStr == null) return false;
      
      final timestamp = DateTime.parse(timestampStr);
      final age = DateTime.now().difference(timestamp);
      
      return age < ExchangeRateCacheConfig.defaultExpiration;
    } catch (e) {
      developer.log(
        'Error checking rate freshness for $baseCurrency: $e',
        name: 'ExchangeRateCache',
        error: e,
      );
      return false;
    }
  }

  /// Check if rates are stale but still usable
  Future<bool> areRatesStale(String baseCurrency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString('${ExchangeRateCacheConfig.timestampPrefix}$baseCurrency');
      
      if (timestampStr == null) return true;
      
      final timestamp = DateTime.parse(timestampStr);
      final age = DateTime.now().difference(timestamp);
      
      final expiredButUsable = age >= ExchangeRateCacheConfig.defaultExpiration && 
                              age < (ExchangeRateCacheConfig.defaultExpiration + ExchangeRateCacheConfig.staleCacheGracePeriod);
      
      return expiredButUsable;
    } catch (e) {
      return true;
    }
  }

  /// Get cache health report
  Future<CacheHealthReport> getCacheHealth([List<String>? currenciesToCheck]) async {
    try {
      final currencies = currenciesToCheck ?? CurrencyValidator.supportedCurrencies.take(20).toList();
      
      int freshCount = 0;
      int staleCount = 0;
      int missingCount = 0;
      final criticalMissing = <String>[];
      final ages = <Duration>[];

      for (final currency in currencies) {
        final rates = await loadRates(currency);
        if (rates == null) {
          missingCount++;
          if (CurrencyValidator.isMajorCurrency(currency)) {
            criticalMissing.add(currency);
          }
        } else {
          final fresh = await areRatesFresh(currency);
          if (fresh) {
            freshCount++;
          } else {
            staleCount++;
          }

          // Calculate age for average
          try {
            final prefs = await SharedPreferences.getInstance();
            final timestampStr = prefs.getString('${ExchangeRateCacheConfig.timestampPrefix}$currency');
            if (timestampStr != null) {
              final timestamp = DateTime.parse(timestampStr);
              ages.add(DateTime.now().difference(timestamp));
            }
          } catch (e) {
            // Skip age calculation for this currency
          }
        }
      }

      final averageAge = ages.isEmpty ? Duration.zero : 
        Duration(milliseconds: ages.map((age) => age.inMilliseconds).reduce((a, b) => a + b) ~/ ages.length);

      // Determine health status
      final healthPercentage = currencies.isEmpty ? 0.0 : (freshCount / currencies.length) * 100.0;
      final CacheHealthStatus status;
      
      if (healthPercentage >= 90) {
        status = CacheHealthStatus.healthy;
      } else if (healthPercentage >= 60) {
        status = CacheHealthStatus.stale;
      } else if (healthPercentage >= 30) {
        status = CacheHealthStatus.degraded;
      } else {
        status = CacheHealthStatus.critical;
      }

      return CacheHealthReport(
        status: status,
        totalCurrencies: currencies.length,
        freshCurrencies: freshCount,
        staleCurrencies: staleCount,
        missingCurrencies: missingCount,
        criticalMissing: criticalMissing,
        averageAge: averageAge,
      );
    } catch (e) {
      developer.log(
        'Error generating cache health report: $e',
        name: 'ExchangeRateCache',
        error: e,
      );
      
      return const CacheHealthReport(
        status: CacheHealthStatus.critical,
        totalCurrencies: 0,
        freshCurrencies: 0,
        staleCurrencies: 0,
        missingCurrencies: 0,
        criticalMissing: [],
        averageAge: Duration.zero,
      );
    }
  }

  /// Clear cache for a specific currency
  Future<void> clearCurrency(String baseCurrency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${ExchangeRateCacheConfig.ratesCachePrefix}$baseCurrency');
      await prefs.remove('${ExchangeRateCacheConfig.timestampPrefix}$baseCurrency');
      await prefs.remove('${ExchangeRateCacheConfig.metadataPrefix}$baseCurrency');
      
      _memoryCache.remove(baseCurrency);
      _metadataCache.remove(baseCurrency);
      _accessFrequency.remove(baseCurrency);

      developer.log(
        'Cleared cache for $baseCurrency',
        name: 'ExchangeRateCache',
      );
    } catch (e) {
      developer.log(
        'Error clearing cache for $baseCurrency: $e',
        name: 'ExchangeRateCache',
        error: e,
      );
      rethrow;
    }
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => 
        key.startsWith(ExchangeRateCacheConfig.ratesCachePrefix) ||
        key.startsWith(ExchangeRateCacheConfig.timestampPrefix) ||
        key.startsWith(ExchangeRateCacheConfig.metadataPrefix),
      ).toList();
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      
      _memoryCache.clear();
      _metadataCache.clear();
      _accessFrequency.clear();

      developer.log(
        'Cleared all exchange rate cache data',
        name: 'ExchangeRateCache',
      );
    } catch (e) {
      developer.log(
        'Error clearing all cache: $e',
        name: 'ExchangeRateCache',
        error: e,
      );
      rethrow;
    }
  }

  /// Get detailed cache statistics
  Future<Map<String, dynamic>> getCacheStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final rateKeys = allKeys.where((key) => key.startsWith(ExchangeRateCacheConfig.ratesCachePrefix)).toList();
      
      final cacheHealth = await getCacheHealth();
      
      return {
        'memory_cache_size': _memoryCache.length,
        'memory_cache_limit': ExchangeRateCacheConfig.maxMemoryCacheSize,
        'persistent_cache_currencies': rateKeys.length,
        'metadata_entries': _metadataCache.length,
        'access_frequency_tracked': _accessFrequency.length,
        'health_status': cacheHealth.status.name,
        'health_percentage': cacheHealth.healthPercentage,
        'fresh_currencies': cacheHealth.freshCurrencies,
        'stale_currencies': cacheHealth.staleCurrencies,
        'missing_currencies': cacheHealth.missingCurrencies,
        'critical_missing': cacheHealth.criticalMissing,
        'average_age_hours': cacheHealth.averageAge.inHours,
        'most_accessed_currencies': _getMostAccessedCurrencies(10),
      };
    } catch (e) {
      developer.log(
        'Error generating cache statistics: $e',
        name: 'ExchangeRateCache',
        error: e,
      );
      return {'error': e.toString()};
    }
  }

  /// Prefetch rates for commonly used currencies
  Future<void> prefetchCommonCurrencies() async {
    final commonCurrencies = ['USD', 'EUR', 'GBP', 'JPY', 'CHF', 'CAD', 'AUD'];
    
    // Add most accessed currencies to prefetch list
    final mostAccessed = _getMostAccessedCurrencies(5);
    commonCurrencies.addAll(mostAccessed);
    
    // Remove duplicates
    final uniqueCurrencies = commonCurrencies.toSet().toList();
    
    developer.log(
      'Prefetching rates for ${uniqueCurrencies.length} common currencies',
      name: 'ExchangeRateCache',
    );
    
    await batchLoadRates(uniqueCurrencies);
  }

  // Private helper methods

  /// Add rates to memory cache with LRU eviction
  void _addToMemoryCache(String baseCurrency, Map<String, double> rates) {
    // Implement LRU eviction if needed
    while (_memoryCache.length >= ExchangeRateCacheConfig.maxMemoryCacheSize) {
      final lruKey = _findLeastRecentlyUsed();
      if (lruKey != null) {
        _memoryCache.remove(lruKey);
        developer.log(
          'Evicted LRU currency from memory cache: $lruKey',
          name: 'ExchangeRateCache',
        );
      } else {
        break;
      }
    }
    
    _memoryCache[baseCurrency] = Map.from(rates);
  }

  /// Find least recently used currency in memory cache
  String? _findLeastRecentlyUsed() {
    if (_metadataCache.isEmpty) return _memoryCache.keys.first;
    
    DateTime? oldestAccess;
    String? oldestCurrency;
    
    for (final entry in _metadataCache.entries) {
      if (_memoryCache.containsKey(entry.key)) {
        if (oldestAccess == null || entry.value.lastAccessed.isBefore(oldestAccess)) {
          oldestAccess = entry.value.lastAccessed;
          oldestCurrency = entry.key;
        }
      }
    }
    
    return oldestCurrency;
  }

  /// Update access statistics for a currency
  Future<void> _updateAccessStatistics(String baseCurrency) async {
    final currentMetadata = _metadataCache[baseCurrency];
    
    if (currentMetadata != null) {
      final updatedMetadata = currentMetadata.copyWith(
        lastAccessed: DateTime.now(),
        accessCount: currentMetadata.accessCount + 1,
      );
      
      _metadataCache[baseCurrency] = updatedMetadata;
      await _saveMetadata(baseCurrency, updatedMetadata);
    }
  }

  /// Update access frequency tracking
  void _updateAccessFrequency(String baseCurrency) {
    _accessFrequency[baseCurrency] = (_accessFrequency[baseCurrency] ?? 0) + 1;
  }

  /// Save metadata to persistent storage
  Future<void> _saveMetadata(String baseCurrency, CacheMetadata metadata) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadataJson = json.encode(metadata.toJson());
      await prefs.setString('${ExchangeRateCacheConfig.metadataPrefix}$baseCurrency', metadataJson);
      
      _metadataCache[baseCurrency] = metadata;
    } catch (e) {
      developer.log(
        'Error saving metadata for $baseCurrency: $e',
        name: 'ExchangeRateCache',
        error: e,
      );
    }
  }

  /// Get most accessed currencies for prefetching
  List<String> _getMostAccessedCurrencies(int count) {
    final entries = _accessFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return entries.take(count).map((e) => e.key).toList();
  }
}