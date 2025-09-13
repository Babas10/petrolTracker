/// Currency service for communicating with the currency microservice.
/// 
/// This service implements the once-daily rate fetching pattern with local
/// caching to minimize API calls and provide offline support.
/// 
/// Features:
/// - Fetches exchange rates from currency microservice maximum once per day
/// - Caches rates locally using SharedPreferences
/// - Performs local currency conversions using cached rates
/// - Works offline with cached data
/// - Handles network failures gracefully
library;

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration for the currency microservice integration.
class CurrencyServiceConfig {
  /// Base URL of the currency microservice
  static const String baseUrl = 'http://localhost:8000/api/v1';
  
  /// API key for authentication with the currency microservice
  static const String apiKey = 'dev-api-key';
  
  /// Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);
  
  /// Cache expiration time (24 hours)
  static const Duration cacheExpiration = Duration(hours: 24);
}

/// Exception thrown when currency service operations fail.
class CurrencyServiceException implements Exception {
  final String message;
  final String? details;
  final dynamic originalError;

  const CurrencyServiceException(
    this.message, {
    this.details,
    this.originalError,
  });

  @override
  String toString() {
    final buffer = StringBuffer('CurrencyServiceException: $message');
    if (details != null) {
      buffer.write(' - $details');
    }
    return buffer.toString();
  }
}

/// Result of a currency conversion operation.
class CurrencyConversion {
  final double originalAmount;
  final String originalCurrency;
  final double convertedAmount;
  final String targetCurrency;
  final double exchangeRate;
  final DateTime rateDate;

  const CurrencyConversion({
    required this.originalAmount,
    required this.originalCurrency,
    required this.convertedAmount,
    required this.targetCurrency,
    required this.exchangeRate,
    required this.rateDate,
  });

  /// Creates a conversion result for same currency (rate = 1.0)
  factory CurrencyConversion.sameCurrency({
    required double amount,
    required String currency,
  }) {
    return CurrencyConversion(
      originalAmount: amount,
      originalCurrency: currency,
      convertedAmount: amount,
      targetCurrency: currency,
      exchangeRate: 1.0,
      rateDate: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'originalAmount': originalAmount,
    'originalCurrency': originalCurrency,
    'convertedAmount': convertedAmount,
    'targetCurrency': targetCurrency,
    'exchangeRate': exchangeRate,
    'rateDate': rateDate.toIso8601String(),
  };

  factory CurrencyConversion.fromJson(Map<String, dynamic> json) {
    return CurrencyConversion(
      originalAmount: (json['originalAmount'] as num).toDouble(),
      originalCurrency: json['originalCurrency'] as String,
      convertedAmount: (json['convertedAmount'] as num).toDouble(),
      targetCurrency: json['targetCurrency'] as String,
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      rateDate: DateTime.parse(json['rateDate'] as String),
    );
  }

  @override
  String toString() {
    return '$originalAmount $originalCurrency → $convertedAmount $targetCurrency '
           '(rate: ${exchangeRate.toStringAsFixed(4)})';
  }
}

/// Service for managing currency exchange rates and conversions.
/// 
/// This service follows the once-daily API call pattern:
/// 1. On first use each day, fetches rates from the microservice
/// 2. Caches rates locally for 24 hours
/// 3. Performs all conversions using cached rates
/// 4. Works offline with cached data
class CurrencyService {
  static CurrencyService? _instance;
  static CurrencyService get instance => _instance ??= CurrencyService._();
  
  CurrencyService._();

  /// HTTP client for API requests
  http.Client? _httpClient;
  
  /// Cached rates data
  Map<String, Map<String, double>>? _cachedRates;
  
  /// Last cache update timestamp
  DateTime? _lastCacheUpdate;

  /// Initialize the currency service
  void initialize() {
    _httpClient ??= http.Client();
    developer.log(
      'CurrencyService initialized',
      name: 'CurrencyService',
    );
  }

  /// Dispose of resources
  void dispose() {
    _httpClient?.close();
    _httpClient = null;
    developer.log(
      'CurrencyService disposed',
      name: 'CurrencyService',
    );
  }

  /// Reset the service instance (for testing)
  static void resetInstance() {
    _instance?.dispose();
    _instance = null;
  }

  /// Generate cache key for a base currency
  String _getCacheKey(String baseCurrency) => 'currency_rates_$baseCurrency';

  /// Generate timestamp cache key for a base currency
  String _getTimestampKey(String baseCurrency) => 'currency_rates_timestamp_$baseCurrency';

  /// Check if cached rates are fresh (less than 24 hours old)
  Future<bool> areRatesFresh(String baseCurrency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString(_getTimestampKey(baseCurrency));
      
      if (timestampStr == null) {
        return false;
      }

      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final age = now.difference(timestamp);
      
      final isFresh = age < CurrencyServiceConfig.cacheExpiration;
      
      developer.log(
        'Rate freshness check for $baseCurrency: $isFresh (age: ${age.inHours}h)',
        name: 'CurrencyService',
      );
      
      return isFresh;
    } catch (e) {
      developer.log(
        'Error checking rate freshness: $e',
        name: 'CurrencyService',
        error: e,
      );
      return false;
    }
  }

  /// Fetch exchange rates from the currency microservice
  Future<Map<String, double>> fetchDailyRates(String baseCurrency) async {
    final url = Uri.parse('${CurrencyServiceConfig.baseUrl}/rates/latest/$baseCurrency');
    
    try {
      developer.log(
        'Fetching rates for $baseCurrency from microservice',
        name: 'CurrencyService',
      );
      
      final response = await _httpClient!.get(
        url,
        headers: {
          'Authorization': 'Bearer ${CurrencyServiceConfig.apiKey}',
          'Content-Type': 'application/json',
        },
      ).timeout(CurrencyServiceConfig.requestTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rates = <String, double>{};
        
        // Parse the response format: {currency: {rate: "0.8542", rate_date: "2025-09-11"}}
        for (final entry in data.entries) {
          final currency = entry.key;
          final rateData = entry.value as Map<String, dynamic>;
          final rateStr = rateData['rate'] as String;
          rates[currency] = double.parse(rateStr);
        }
        
        // Add base currency with rate 1.0
        rates[baseCurrency] = 1.0;
        
        // Cache the rates
        await _cacheRates(baseCurrency, rates);
        
        developer.log(
          'Successfully fetched ${rates.length} rates for $baseCurrency',
          name: 'CurrencyService',
        );
        
        return rates;
      } else if (response.statusCode == 404) {
        throw CurrencyServiceException(
          'No rates found for base currency: $baseCurrency',
          details: 'HTTP ${response.statusCode}',
        );
      } else if (response.statusCode == 400) {
        throw CurrencyServiceException(
          'Invalid currency code: $baseCurrency',
          details: 'HTTP ${response.statusCode}',
        );
      } else {
        throw CurrencyServiceException(
          'Failed to fetch rates from microservice',
          details: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      throw CurrencyServiceException(
        'Network error while fetching rates',
        details: 'Check if currency microservice is running at localhost:8000',
        originalError: e,
      );
    } catch (e) {
      if (e is CurrencyServiceException) rethrow;
      
      throw CurrencyServiceException(
        'Unexpected error while fetching rates',
        originalError: e,
      );
    }
  }

  /// Cache exchange rates locally
  @protected
  Future<void> _cacheRates(String baseCurrency, Map<String, double> rates) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratesJson = jsonEncode(rates);
      final timestamp = DateTime.now().toIso8601String();
      
      await Future.wait([
        prefs.setString(_getCacheKey(baseCurrency), ratesJson),
        prefs.setString(_getTimestampKey(baseCurrency), timestamp),
      ]);
      
      // Update in-memory cache
      _cachedRates ??= {};
      _cachedRates![baseCurrency] = Map.from(rates);
      _lastCacheUpdate = DateTime.now();
      
      developer.log(
        'Cached ${rates.length} rates for $baseCurrency',
        name: 'CurrencyService',
      );
    } catch (e) {
      developer.log(
        'Error caching rates: $e',
        name: 'CurrencyService',
        error: e,
      );
      throw CurrencyServiceException(
        'Failed to cache exchange rates',
        originalError: e,
      );
    }
  }

  /// Load cached exchange rates
  Future<Map<String, double>?> _loadCachedRates(String baseCurrency) async {
    try {
      // Check in-memory cache first
      if (_cachedRates?.containsKey(baseCurrency) == true) {
        developer.log(
          'Using in-memory cached rates for $baseCurrency',
          name: 'CurrencyService',
        );
        return _cachedRates![baseCurrency];
      }
      
      // Load from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final ratesJson = prefs.getString(_getCacheKey(baseCurrency));
      
      if (ratesJson == null) {
        return null;
      }
      
      final ratesMap = jsonDecode(ratesJson) as Map<String, dynamic>;
      final rates = ratesMap.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      );
      
      // Update in-memory cache
      _cachedRates ??= {};
      _cachedRates![baseCurrency] = rates;
      
      developer.log(
        'Loaded ${rates.length} cached rates for $baseCurrency',
        name: 'CurrencyService',
      );
      
      return rates;
    } catch (e) {
      developer.log(
        'Error loading cached rates: $e',
        name: 'CurrencyService',
        error: e,
      );
      return null;
    }
  }

  /// Get cached exchange rates, fetching if necessary
  Future<Map<String, double>> getLocalRates(String baseCurrency) async {
    // Check if rates are fresh
    final isFresh = await areRatesFresh(baseCurrency);
    
    if (!isFresh) {
      try {
        // Fetch fresh rates
        return await fetchDailyRates(baseCurrency);
      } catch (e) {
        developer.log(
          'Failed to fetch fresh rates, falling back to cached rates: $e',
          name: 'CurrencyService',
          error: e,
        );
        
        // Fall back to cached rates even if stale
        final cachedRates = await _loadCachedRates(baseCurrency);
        if (cachedRates != null) {
          return cachedRates;
        }
        
        // If no cached rates available, rethrow the fetch error
        rethrow;
      }
    } else {
      // Use cached rates
      final cachedRates = await _loadCachedRates(baseCurrency);
      if (cachedRates != null) {
        return cachedRates;
      } else {
        // Cache timestamp exists but no rates - fetch fresh
        return await fetchDailyRates(baseCurrency);
      }
    }
  }

  /// Convert amount from one currency to another using cached rates
  Future<CurrencyConversion?> convertAmount({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    String? baseCurrency,
  }) async {
    // Same currency conversion
    if (fromCurrency == toCurrency) {
      return CurrencyConversion.sameCurrency(
        amount: amount,
        currency: fromCurrency,
      );
    }

    try {
      // Use fromCurrency as base if not specified
      final base = baseCurrency ?? fromCurrency;
      final rates = await getLocalRates(base);
      
      double exchangeRate;
      
      if (base == fromCurrency) {
        // Direct conversion: base -> target
        final rate = rates[toCurrency];
        if (rate == null) {
          developer.log(
            'No rate available for $fromCurrency -> $toCurrency',
            name: 'CurrencyService',
          );
          return null;
        }
        exchangeRate = rate;
      } else if (base == toCurrency) {
        // Reverse conversion: target -> base, so we need 1/rate
        final rate = rates[fromCurrency];
        if (rate == null || rate == 0) {
          developer.log(
            'No rate available for $toCurrency -> $fromCurrency',
            name: 'CurrencyService',
          );
          return null;
        }
        exchangeRate = 1.0 / rate;
      } else {
        // Cross conversion via base currency
        final fromToBase = rates[fromCurrency];
        final baseToTarget = rates[toCurrency];
        
        if (fromToBase == null || baseToTarget == null || fromToBase == 0) {
          developer.log(
            'Cannot perform cross conversion $fromCurrency -> $toCurrency via $base',
            name: 'CurrencyService',
          );
          return null;
        }
        
        exchangeRate = baseToTarget / fromToBase;
      }
      
      final convertedAmount = amount * exchangeRate;
      
      final conversion = CurrencyConversion(
        originalAmount: amount,
        originalCurrency: fromCurrency,
        convertedAmount: convertedAmount,
        targetCurrency: toCurrency,
        exchangeRate: exchangeRate,
        rateDate: DateTime.now(),
      );
      
      developer.log(
        'Currency conversion: $conversion',
        name: 'CurrencyService',
      );
      
      return conversion;
    } catch (e) {
      developer.log(
        'Error converting currency: $e',
        name: 'CurrencyService',
        error: e,
      );
      return null;
    }
  }

  /// Clear all cached rates (useful for testing or troubleshooting)
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where(
        (key) => key.startsWith('currency_rates_'),
      );
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      
      _cachedRates?.clear();
      _lastCacheUpdate = null;
      
      developer.log(
        'Cleared all cached currency rates',
        name: 'CurrencyService',
      );
    } catch (e) {
      developer.log(
        'Error clearing cache: $e',
        name: 'CurrencyService',
        error: e,
      );
      throw CurrencyServiceException(
        'Failed to clear currency cache',
        originalError: e,
      );
    }
  }

  /// Get cache statistics for monitoring
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final rateKeys = allKeys.where((key) => key.startsWith('currency_rates_')).toList();
      final timestampKeys = allKeys.where((key) => key.contains('timestamp')).toList();
      
      final stats = <String, dynamic>{
        'total_rate_keys': rateKeys.length,
        'timestamp_keys': timestampKeys.length,
        'in_memory_currencies': _cachedRates?.keys.toList() ?? [],
        'last_cache_update': _lastCacheUpdate?.toIso8601String(),
      };
      
      // Add freshness info for each cached currency
      final freshness = <String, bool>{};
      for (final key in rateKeys) {
        if (key.contains('timestamp')) continue;
        final currency = key.replaceFirst('currency_rates_', '');
        freshness[currency] = await areRatesFresh(currency);
      }
      stats['freshness'] = freshness;
      
      return stats;
    } catch (e) {
      developer.log(
        'Error getting cache stats: $e',
        name: 'CurrencyService',
        error: e,
      );
      return {'error': e.toString()};
    }
  }
}