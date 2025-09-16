/// Enhanced local currency conversion logic with advanced caching and fallback strategies
/// 
/// This service provides fast, reliable currency conversions without requiring API calls
/// during normal usage. It includes sophisticated rate caching, bidirectional conversions,
/// batch operations, and comprehensive error handling.
/// 
/// Features:
/// - Fast local conversions using cached exchange rates
/// - Bidirectional conversion support (direct and reverse rates)
/// - Cross-currency conversion via base currencies
/// - Batch conversion operations for multiple entries
/// - Comprehensive validation and error handling
/// - Fallback strategies for missing or stale rates
/// - Performance optimizations for frequent conversions
library;

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/utils/currency_validator.dart';
import 'package:petrol_tracker/services/currency_service.dart';

/// Result of a conversion validation
class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  
  const ValidationResult._(this.isValid, this.errorMessage);
  
  factory ValidationResult.success() => const ValidationResult._(true, null);
  factory ValidationResult.error(String message) => ValidationResult._(false, message);
}

/// Configuration for the local currency converter
class CurrencyConverterConfig {
  /// Maximum amount that can be converted (prevents overflow)
  static const double maxConvertibleAmount = 1000000000.0;
  
  /// Minimum amount that can be converted
  static const double minConvertibleAmount = 0.001;
  
  /// Default base currency for cross-conversions
  static const String defaultBaseCurrency = 'USD';
  
  /// Cache expiration time (24 hours)
  static const Duration cacheExpiration = Duration(hours: 24);
  
  /// Memory cache size limit (number of currency pairs)
  static const int memoryCacheLimit = 100;
  
  /// Tolerance for rate calculation validation (to handle floating-point precision)
  static const double calculationTolerance = 0.001;
}

/// Enhanced local currency converter with advanced features
class LocalCurrencyConverter {
  static LocalCurrencyConverter? _instance;
  static LocalCurrencyConverter get instance => _instance ??= LocalCurrencyConverter._();
  
  LocalCurrencyConverter._();

  /// Memory cache for frequently used rates
  final Map<String, Map<String, double>> _memoryCachedRates = {};
  
  /// Cache access timestamps for LRU eviction
  final Map<String, DateTime> _cacheAccessTimes = {};

  /// Main conversion method with comprehensive fallback logic
  /// 
  /// Converts [amount] from [fromCurrency] to [toCurrency] using cached rates.
  /// Returns null if no conversion is possible with available rates.
  /// 
  /// Example:
  /// ```dart
  /// final result = await converter.convertAmount(
  ///   amount: 100.0,
  ///   fromCurrency: 'EUR',
  ///   toCurrency: 'USD',
  /// );
  /// ```
  Future<CurrencyConversion?> convertAmount({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    DateTime? forDate,
  }) async {
    // Validate input parameters
    final validation = ConversionValidator.validateConversion(
      amount: amount,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
    );
    
    if (!validation.isValid) {
      developer.log(
        'Conversion validation failed: ${validation.errorMessage}',
        name: 'LocalCurrencyConverter',
      );
      return null;
    }

    // Handle same currency conversion
    if (fromCurrency == toCurrency) {
      return _createSameCurrencyConversion(amount, fromCurrency, forDate);
    }

    // Get exchange rate using fallback strategies
    final rateResult = await _getExchangeRateWithFallbacks(fromCurrency, toCurrency);
    if (rateResult == null) {
      developer.log(
        'No exchange rate available for $fromCurrency -> $toCurrency',
        name: 'LocalCurrencyConverter',
      );
      return null;
    }

    final convertedAmount = amount * rateResult.rate;
    
    // Validate the conversion result
    if (!_isValidConversionResult(convertedAmount)) {
      developer.log(
        'Invalid conversion result: $amount * ${rateResult.rate} = $convertedAmount',
        name: 'LocalCurrencyConverter',
      );
      return null;
    }

    final conversion = CurrencyConversion(
      originalAmount: amount,
      originalCurrency: fromCurrency,
      convertedAmount: convertedAmount,
      targetCurrency: toCurrency,
      exchangeRate: rateResult.rate,
      rateDate: rateResult.rateDate,
    );

    developer.log(
      'Local conversion completed: $conversion',
      name: 'LocalCurrencyConverter',
    );

    return conversion;
  }

  /// Batch convert multiple amounts efficiently
  /// 
  /// Converts multiple [amounts] from their respective [fromCurrencies] to [toCurrency].
  /// Returns only successful conversions, skipping any that fail.
  /// 
  /// Example:
  /// ```dart
  /// final conversions = await converter.convertBatch(
  ///   amounts: [100.0, 50.0, 75.0],
  ///   fromCurrencies: ['EUR', 'GBP', 'JPY'],
  ///   toCurrency: 'USD',
  /// );
  /// ```
  Future<List<CurrencyConversion>> convertBatch({
    required List<double> amounts,
    required List<String> fromCurrencies, 
    required String toCurrency,
  }) async {
    if (amounts.length != fromCurrencies.length) {
      throw ArgumentError('amounts and fromCurrencies lists must have the same length');
    }

    final conversions = <CurrencyConversion>[];
    final uniqueCurrencies = fromCurrencies.toSet();
    
    // Pre-load rates for all unique currencies to optimize batch operations
    await _preloadRatesForCurrencies(uniqueCurrencies.union({toCurrency}));
    
    for (int i = 0; i < amounts.length; i++) {
      final conversion = await convertAmount(
        amount: amounts[i],
        fromCurrency: fromCurrencies[i],
        toCurrency: toCurrency,
      );
      
      if (conversion != null) {
        conversions.add(conversion);
      } else {
        developer.log(
          'Skipping failed conversion: ${amounts[i]} ${fromCurrencies[i]} -> $toCurrency',
          name: 'LocalCurrencyConverter',
        );
      }
    }

    developer.log(
      'Batch conversion completed: ${conversions.length}/${amounts.length} successful',
      name: 'LocalCurrencyConverter',
    );

    return conversions;
  }

  /// Convert fuel entries to primary currency
  /// 
  /// Converts all fuel entries that are not already in the [primaryCurrency]
  /// to the primary currency, preserving original amounts where conversions occur.
  /// 
  /// Example:
  /// ```dart
  /// final convertedEntries = await converter.convertFuelEntriesToPrimary(
  ///   entries,
  ///   'USD',
  /// );
  /// ```
  Future<List<FuelEntryModel>> convertFuelEntriesToPrimary(
    List<FuelEntryModel> entries,
    String primaryCurrency,
  ) async {
    if (entries.isEmpty) return [];

    final convertedEntries = <FuelEntryModel>[];
    final currenciesNeedingConversion = <String>{};
    
    // Identify currencies that need conversion
    for (final entry in entries) {
      if (entry.currency != primaryCurrency) {
        currenciesNeedingConversion.add(entry.currency);
      }
    }

    // Pre-load rates for efficiency
    await _preloadRatesForCurrencies(currenciesNeedingConversion.union({primaryCurrency}));

    for (final entry in entries) {
      if (entry.currency == primaryCurrency) {
        // Entry already in primary currency
        convertedEntries.add(entry);
        continue;
      }

      // Convert the entry's price to primary currency
      final originalPrice = entry.originalAmount ?? entry.price;
      final conversion = await convertAmount(
        amount: originalPrice,
        fromCurrency: entry.currency,
        toCurrency: primaryCurrency,
      );

      if (conversion != null) {
        // Create converted entry preserving original amount
        final convertedEntry = FuelEntryModel.create(
          vehicleId: entry.vehicleId,
          date: entry.date,
          currentKm: entry.currentKm,
          fuelAmount: entry.fuelAmount,
          price: conversion.convertedAmount,
          originalAmount: originalPrice,
          currency: primaryCurrency,
          country: entry.country,
          pricePerLiter: entry.pricePerLiter * conversion.exchangeRate,
          consumption: entry.consumption,
          isFullTank: entry.isFullTank,
        );
        convertedEntries.add(convertedEntry);
      } else {
        // Keep original if conversion fails
        developer.log(
          'Failed to convert entry ${entry.id} from ${entry.currency} to $primaryCurrency',
          name: 'LocalCurrencyConverter',
        );
        convertedEntries.add(entry);
      }
    }

    developer.log(
      'Converted ${convertedEntries.length} fuel entries to $primaryCurrency',
      name: 'LocalCurrencyConverter',
    );

    return convertedEntries;
  }

  /// Get available exchange rates for a base currency
  /// 
  /// Returns all available exchange rates from the cache for the specified base currency.
  /// Includes both direct rates and reverse rates that can be calculated.
  Future<Map<String, double>> getAvailableRates(String baseCurrency) async {
    await _loadCachedRatesForCurrency(baseCurrency);
    return Map.from(_memoryCachedRates[baseCurrency] ?? {});
  }

  /// Check if conversion is possible between two currencies
  /// 
  /// Returns true if a conversion can be performed with available cached rates.
  Future<bool> canConvert(String fromCurrency, String toCurrency) async {
    if (fromCurrency == toCurrency) return true;
    
    final rate = await _getExchangeRateWithFallbacks(fromCurrency, toCurrency);
    return rate != null;
  }

  /// Clear all cached rates and reset memory cache
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where(
        (key) => key.startsWith('currency_rates_') || key.startsWith('local_converter_'),
      );
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      
      _memoryCachedRates.clear();
      _cacheAccessTimes.clear();
      
      developer.log(
        'Cleared all currency converter cache',
        name: 'LocalCurrencyConverter',
      );
    } catch (e) {
      developer.log(
        'Error clearing currency converter cache: $e',
        name: 'LocalCurrencyConverter',
        error: e,
      );
      rethrow;
    }
  }

  /// Get cache statistics and health information
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final rateKeys = allKeys.where((key) => key.startsWith('currency_rates_')).toList();
      
      final stats = <String, dynamic>{
        'memory_cached_currencies': _memoryCachedRates.keys.toList(),
        'memory_cache_size': _memoryCachedRates.length,
        'persistent_cache_keys': rateKeys.length,
        'cache_access_times': _cacheAccessTimes.length,
        'memory_cache_limit': CurrencyConverterConfig.memoryCacheLimit,
      };
      
      // Add freshness info for each cached currency
      final freshness = <String, bool>{};
      for (final currency in _memoryCachedRates.keys) {
        freshness[currency] = await _areRatesFresh(currency);
      }
      stats['rate_freshness'] = freshness;
      
      return stats;
    } catch (e) {
      developer.log(
        'Error getting cache stats: $e',
        name: 'LocalCurrencyConverter',
        error: e,
      );
      return {'error': e.toString()};
    }
  }

  // Private helper methods

  /// Get exchange rate with comprehensive fallback strategies
  Future<_RateResult?> _getExchangeRateWithFallbacks(String from, String to) async {
    // Strategy 1: Try direct rate (from -> to)
    var rate = await _getDirectRate(from, to);
    if (rate != null) return rate;
    
    // Strategy 2: Try reverse rate (to -> from) and calculate inverse
    rate = await _getReverseRate(from, to);
    if (rate != null) return rate;
    
    // Strategy 3: Try cross-currency conversion via USD
    rate = await _getCrossRate(from, to, CurrencyConverterConfig.defaultBaseCurrency);
    if (rate != null) return rate;
    
    // Strategy 4: Try cross-currency conversion via EUR (if not already USD)
    if (CurrencyConverterConfig.defaultBaseCurrency != 'EUR') {
      rate = await _getCrossRate(from, to, 'EUR');
      if (rate != null) return rate;
    }
    
    return null;
  }

  /// Get direct exchange rate (from -> to)
  Future<_RateResult?> _getDirectRate(String from, String to) async {
    await _loadCachedRatesForCurrency(from);
    final rates = _memoryCachedRates[from];
    if (rates == null) return null;
    
    final rate = rates[to];
    if (rate == null || rate <= 0) return null;
    
    return _RateResult(rate, await _getRateDate(from));
  }

  /// Get reverse exchange rate (to -> from) and calculate inverse
  Future<_RateResult?> _getReverseRate(String from, String to) async {
    await _loadCachedRatesForCurrency(to);
    final rates = _memoryCachedRates[to];
    if (rates == null) return null;
    
    final reverseRate = rates[from];
    if (reverseRate == null || reverseRate <= 0) return null;
    
    return _RateResult(1.0 / reverseRate, await _getRateDate(to));
  }

  /// Get cross-currency rate via base currency (from -> base -> to)
  Future<_RateResult?> _getCrossRate(String from, String to, String base) async {
    if (from == base || to == base) return null;
    
    await _loadCachedRatesForCurrency(base);
    final baseRates = _memoryCachedRates[base];
    if (baseRates == null) return null;
    
    final fromToBase = baseRates[from];
    final baseToTarget = baseRates[to];
    
    if (fromToBase == null || baseToTarget == null || fromToBase <= 0) return null;
    
    // Cross rate: (from -> base) * (base -> to) = (from -> to)
    final crossRate = (1.0 / fromToBase) * baseToTarget;
    
    return _RateResult(crossRate, await _getRateDate(base));
  }

  /// Load cached rates for a currency into memory cache
  Future<void> _loadCachedRatesForCurrency(String currency) async {
    if (_memoryCachedRates.containsKey(currency)) {
      _updateCacheAccessTime(currency);
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final ratesJson = prefs.getString('currency_rates_$currency');
      
      if (ratesJson != null) {
        final ratesMap = json.decode(ratesJson) as Map<String, dynamic>;
        final rates = ratesMap.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        );
        
        _addToMemoryCache(currency, rates);
        developer.log(
          'Loaded ${rates.length} rates for $currency from persistent cache',
          name: 'LocalCurrencyConverter',
        );
      }
    } catch (e) {
      developer.log(
        'Error loading cached rates for $currency: $e',
        name: 'LocalCurrencyConverter',
        error: e,
      );
    }
  }

  /// Pre-load rates for multiple currencies for batch operations
  Future<void> _preloadRatesForCurrencies(Set<String> currencies) async {
    final loadTasks = currencies
        .where((currency) => !_memoryCachedRates.containsKey(currency))
        .map((currency) => _loadCachedRatesForCurrency(currency));
    
    await Future.wait(loadTasks);
    
    developer.log(
      'Pre-loaded rates for ${currencies.length} currencies',
      name: 'LocalCurrencyConverter',
    );
  }

  /// Add rates to memory cache with LRU eviction
  void _addToMemoryCache(String currency, Map<String, double> rates) {
    // Implement LRU eviction if cache is full
    if (_memoryCachedRates.length >= CurrencyConverterConfig.memoryCacheLimit) {
      _evictLeastRecentlyUsed();
    }
    
    _memoryCachedRates[currency] = Map.from(rates);
    _updateCacheAccessTime(currency);
  }

  /// Update cache access time for LRU management
  void _updateCacheAccessTime(String currency) {
    _cacheAccessTimes[currency] = DateTime.now();
  }

  /// Evict least recently used cache entry
  void _evictLeastRecentlyUsed() {
    if (_cacheAccessTimes.isEmpty) return;
    
    final oldestEntry = _cacheAccessTimes.entries
        .reduce((a, b) => a.value.isBefore(b.value) ? a : b);
    
    _memoryCachedRates.remove(oldestEntry.key);
    _cacheAccessTimes.remove(oldestEntry.key);
    
    developer.log(
      'Evicted LRU cache entry for ${oldestEntry.key}',
      name: 'LocalCurrencyConverter',
    );
  }

  /// Check if cached rates are fresh for a currency
  Future<bool> _areRatesFresh(String currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString('currency_rates_timestamp_$currency');
      
      if (timestampStr == null) return false;
      
      final timestamp = DateTime.parse(timestampStr);
      final age = DateTime.now().difference(timestamp);
      
      return age < CurrencyConverterConfig.cacheExpiration;
    } catch (e) {
      return false;
    }
  }

  /// Get rate date for a cached currency
  Future<DateTime> _getRateDate(String currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampStr = prefs.getString('currency_rates_timestamp_$currency');
      
      if (timestampStr != null) {
        return DateTime.parse(timestampStr);
      }
    } catch (e) {
      // Fall back to current time if timestamp is not available
    }
    
    return DateTime.now();
  }

  /// Create same currency conversion result
  CurrencyConversion _createSameCurrencyConversion(
    double amount, 
    String currency, 
    DateTime? forDate,
  ) {
    return CurrencyConversion(
      originalAmount: amount,
      originalCurrency: currency,
      convertedAmount: amount,
      targetCurrency: currency,
      exchangeRate: 1.0,
      rateDate: forDate ?? DateTime.now(),
    );
  }

  /// Validate conversion result for sanity
  bool _isValidConversionResult(double result) {
    return result.isFinite && 
           result >= 0 && 
           result <= CurrencyConverterConfig.maxConvertibleAmount;
  }
}

/// Internal class to hold rate result with metadata
class _RateResult {
  final double rate;
  final DateTime rateDate;
  
  const _RateResult(this.rate, this.rateDate);
}

/// Validation utilities for currency conversions
class ConversionValidator {
  /// Validate conversion parameters
  static ValidationResult validateConversion({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    // Validate amount
    if (!amount.isFinite || amount <= 0) {
      return ValidationResult.error('Amount must be a positive finite number');
    }
    
    if (amount < CurrencyConverterConfig.minConvertibleAmount) {
      return ValidationResult.error('Amount too small (minimum: ${CurrencyConverterConfig.minConvertibleAmount})');
    }
    
    if (amount > CurrencyConverterConfig.maxConvertibleAmount) {
      return ValidationResult.error('Amount too large (maximum: ${CurrencyConverterConfig.maxConvertibleAmount})');
    }
    
    // Validate currencies
    if (!CurrencyValidator.isValidCurrency(fromCurrency)) {
      return ValidationResult.error('Invalid source currency: $fromCurrency');
    }
    
    if (!CurrencyValidator.isValidCurrency(toCurrency)) {
      return ValidationResult.error('Invalid target currency: $toCurrency');
    }
    
    return ValidationResult.success();
  }

  /// Validate exchange rate
  static ValidationResult validateExchangeRate(double rate) {
    if (!rate.isFinite || rate <= 0) {
      return ValidationResult.error('Exchange rate must be a positive finite number');
    }
    
    if (rate > 1000000) {
      return ValidationResult.error('Exchange rate seems unrealistic (> 1,000,000)');
    }
    
    return ValidationResult.success();
  }
}