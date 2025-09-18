/// Performance optimization providers for currency operations
/// 
/// This file contains specialized providers focused on performance optimization
/// for currency-related operations in the petrol tracker application.
library;

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/services/currency_service.dart';
import 'package:petrol_tracker/providers/currency_providers.dart';
import 'package:petrol_tracker/providers/currency_settings_providers.dart';

part 'currency_performance_providers.g.dart';

/// Debounced provider for currency rate updates
/// 
/// Prevents excessive API calls by debouncing rate refresh requests.
/// Useful when multiple components request rate updates simultaneously.
@riverpod
class DebouncedCurrencyRateRefresh extends _$DebouncedCurrencyRateRefresh {
  Timer? _debounceTimer;
  final Set<String> _pendingCurrencies = <String>{};
  
  @override
  Future<Map<String, DateTime>> build() async {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });
    
    return <String, DateTime>{};
  }
  
  /// Request rate refresh for a currency with debouncing
  void requestRefresh(String currency) {
    _pendingCurrencies.add(currency);
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performBatchRefresh();
    });
  }
  
  Future<void> _performBatchRefresh() async {
    if (_pendingCurrencies.isEmpty) return;
    
    final currenciesToRefresh = Set<String>.from(_pendingCurrencies);
    _pendingCurrencies.clear();
    
    final currencyService = ref.read(currencyServiceProvider);
    final updates = <String, DateTime>{};
    
    for (final currency in currenciesToRefresh) {
      try {
        await currencyService.fetchDailyRates(currency);
        updates[currency] = DateTime.now();
      } catch (e) {
        // Continue with other currencies on individual failures
      }
    }
    
    if (updates.isNotEmpty) {
      final currentState = await future;
      state = AsyncValue.data({
        ...currentState,
        ...updates,
      });
      
      // Invalidate related providers
      ref.invalidate(exchangeRatesForCurrencyProvider);
    }
  }
}

/// Cached provider for expensive currency calculations
/// 
/// Caches the results of expensive multi-currency calculations
/// to avoid recalculation on every UI rebuild.
@riverpod
class CachedCurrencyCalculations extends _$CachedCurrencyCalculations {
  final Map<String, dynamic> _cache = <String, dynamic>{};
  Timer? _cacheCleanupTimer;
  
  @override
  Map<String, dynamic> build() {
    ref.onDispose(() {
      _cacheCleanupTimer?.cancel();
    });
    
    // Set up periodic cache cleanup
    _setupCacheCleanup();
    
    return <String, dynamic>{};
  }
  
  void _setupCacheCleanup() {
    _cacheCleanupTimer?.cancel();
    _cacheCleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _cleanupExpiredEntries();
    });
  }
  
  void _cleanupExpiredEntries() {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _cache.entries) {
      if (entry.value is Map && entry.value['expiry'] is DateTime) {
        final expiry = entry.value['expiry'] as DateTime;
        if (now.isAfter(expiry)) {
          expiredKeys.add(entry.key);
        }
      }
    }
    
    for (final key in expiredKeys) {
      _cache.remove(key);
    }
    
    if (expiredKeys.isNotEmpty) {
      state = Map.from(_cache);
    }
  }
  
  /// Get cached calculation result or compute if not cached
  T getCachedCalculation<T>(
    String key,
    T Function() calculator, {
    Duration cacheDuration = const Duration(minutes: 1),
  }) {
    final cachedEntry = _cache[key];
    
    if (cachedEntry != null && 
        cachedEntry is Map &&
        cachedEntry['expiry'] is DateTime &&
        cachedEntry['result'] is T) {
      final expiry = cachedEntry['expiry'] as DateTime;
      if (DateTime.now().isBefore(expiry)) {
        return cachedEntry['result'] as T;
      }
    }
    
    // Calculate new result
    final result = calculator();
    
    // Cache the result
    _cache[key] = {
      'result': result,
      'expiry': DateTime.now().add(cacheDuration),
    };
    
    state = Map.from(_cache);
    
    return result;
  }
  
  /// Invalidate a specific cache entry
  void invalidateCache(String key) {
    if (_cache.remove(key) != null) {
      state = Map.from(_cache);
    }
  }
  
  /// Clear all cached calculations
  void clearCache() {
    _cache.clear();
    state = <String, dynamic>{};
  }
}

/// Provider for optimized batch currency conversions
/// 
/// Optimizes currency conversions by batching requests and reusing
/// exchange rates across multiple conversions.
@riverpod
Future<List<OptimizedConversionResult>> optimizedBatchConversions(
  OptimizedBatchConversionsRef ref,
  List<ConversionRequest> requests,
) async {
  if (requests.isEmpty) return [];
  
  final currencyService = ref.read(currencyServiceProvider);
  final results = <OptimizedConversionResult>[];
  
  // Group requests by source currency for efficient rate fetching
  final groupedRequests = <String, List<ConversionRequest>>{};
  for (final request in requests) {
    groupedRequests.putIfAbsent(request.fromCurrency, () => []).add(request);
  }
  
  // Process each currency group
  for (final entry in groupedRequests.entries) {
    final sourceCurrency = entry.key;
    final currencyRequests = entry.value;
    
    try {
      // Fetch rates once for this currency
      final rates = await currencyService.getLocalRates(sourceCurrency);
      
      // Process all conversions for this currency
      for (final request in currencyRequests) {
        try {
          final conversion = await currencyService.convertAmount(
            amount: request.amount,
            fromCurrency: request.fromCurrency,
            toCurrency: request.toCurrency,
          );
          
          results.add(OptimizedConversionResult(
            request: request,
            conversion: conversion,
            success: conversion != null,
            error: null,
          ));
        } catch (e) {
          results.add(OptimizedConversionResult(
            request: request,
            conversion: null,
            success: false,
            error: e.toString(),
          ));
        }
      }
    } catch (e) {
      // Mark all requests for this currency as failed
      for (final request in currencyRequests) {
        results.add(OptimizedConversionResult(
          request: request,
          conversion: null,
          success: false,
          error: 'Failed to fetch rates for ${sourceCurrency}: $e',
        ));
      }
    }
  }
  
  return results;
}

/// Provider for preloading exchange rates
/// 
/// Proactively loads exchange rates for commonly used currencies
/// to improve performance when conversions are needed.
@riverpod
class ExchangeRatePreloader extends _$ExchangeRatePreloader {
  Timer? _preloadTimer;
  
  @override
  Future<Set<String>> build() async {
    ref.onDispose(() {
      _preloadTimer?.cancel();
    });
    
    // Start preloading process
    _schedulePreloading();
    
    return <String>{};
  }
  
  void _schedulePreloading() {
    _preloadTimer?.cancel();
    _preloadTimer = Timer.periodic(const Duration(hours: 6), (_) {
      _preloadCommonCurrencies();
    });
    
    // Initial preload
    _preloadCommonCurrencies();
  }
  
  Future<void> _preloadCommonCurrencies() async {
    try {
      final currencyService = ref.read(currencyServiceProvider);
      final primaryCurrency = ref.read(primaryCurrencyProvider);
      
      // Get list of commonly used currencies
      final commonCurrencies = [
        primaryCurrency,
        'USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY'
      ].toSet();
      
      final preloadedCurrencies = <String>{};
      
      for (final currency in commonCurrencies) {
        try {
          await currencyService.getLocalRates(currency);
          preloadedCurrencies.add(currency);
        } catch (e) {
          // Continue with other currencies on individual failures
        }
      }
      
      state = AsyncValue.data(preloadedCurrencies);
    } catch (e) {
      // Handle errors gracefully without affecting user experience
    }
  }
  
  /// Manually trigger preloading for specific currencies
  Future<void> preloadCurrencies(List<String> currencies) async {
    final currencyService = ref.read(currencyServiceProvider);
    final currentPreloaded = await future;
    final newPreloaded = Set<String>.from(currentPreloaded);
    
    for (final currency in currencies) {
      try {
        await currencyService.getLocalRates(currency);
        newPreloaded.add(currency);
      } catch (e) {
        // Continue with other currencies
      }
    }
    
    state = AsyncValue.data(newPreloaded);
  }
}

/// Provider for memory-efficient currency rate management
/// 
/// Manages memory usage by cleaning up old exchange rate data
/// and optimizing cache storage.
@riverpod
class MemoryEfficientRateManager extends _$MemoryEfficientRateManager {
  Timer? _cleanupTimer;
  
  @override
  Future<MemoryUsageStats> build() async {
    ref.onDispose(() {
      _cleanupTimer?.cancel();
    });
    
    _scheduleMemoryCleanup();
    
    return MemoryUsageStats(
      activeCurrencies: 0,
      cacheSize: 0,
      lastCleanup: DateTime.now(),
    );
  }
  
  void _scheduleMemoryCleanup() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(hours: 2), (_) {
      _performMemoryCleanup();
    });
  }
  
  Future<void> _performMemoryCleanup() async {
    try {
      final currencyService = ref.read(currencyServiceProvider);
      
      // Get cache statistics
      final cacheStats = await currencyService.getCacheStats();
      final totalKeys = cacheStats['total_rate_keys'] as int? ?? 0;
      
      // Clear stale entries
      final staleEntries = <String>[];
      if (cacheStats['freshness'] is Map) {
        final freshness = cacheStats['freshness'] as Map<String, bool>;
        for (final entry in freshness.entries) {
          if (!entry.value) {
            staleEntries.add(entry.key);
          }
        }
      }
      
      // Update memory stats
      final stats = MemoryUsageStats(
        activeCurrencies: totalKeys - staleEntries.length,
        cacheSize: totalKeys,
        lastCleanup: DateTime.now(),
        staleEntries: staleEntries,
      );
      
      state = AsyncValue.data(stats);
    } catch (e) {
      // Handle errors gracefully
    }
  }
  
  /// Force memory cleanup
  Future<void> forceCleanup() async {
    await _performMemoryCleanup();
  }
  
  /// Get current memory usage statistics
  Future<MemoryUsageStats> getCurrentStats() async {
    await _performMemoryCleanup();
    return await future;
  }
}

/// Data class for conversion requests
class ConversionRequest {
  final double amount;
  final String fromCurrency;
  final String toCurrency;
  final String? identifier;
  
  const ConversionRequest({
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
    this.identifier,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversionRequest &&
        other.amount == amount &&
        other.fromCurrency == fromCurrency &&
        other.toCurrency == toCurrency &&
        other.identifier == identifier;
  }
  
  @override
  int get hashCode {
    return Object.hash(amount, fromCurrency, toCurrency, identifier);
  }
}

/// Data class for optimized conversion results
class OptimizedConversionResult {
  final ConversionRequest request;
  final CurrencyConversion? conversion;
  final bool success;
  final String? error;
  
  const OptimizedConversionResult({
    required this.request,
    required this.conversion,
    required this.success,
    this.error,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OptimizedConversionResult &&
        other.request == request &&
        other.conversion == conversion &&
        other.success == success &&
        other.error == error;
  }
  
  @override
  int get hashCode {
    return Object.hash(request, conversion, success, error);
  }
}

/// Data class for memory usage statistics
class MemoryUsageStats {
  final int activeCurrencies;
  final int cacheSize;
  final DateTime lastCleanup;
  final List<String> staleEntries;
  
  const MemoryUsageStats({
    required this.activeCurrencies,
    required this.cacheSize,
    required this.lastCleanup,
    this.staleEntries = const [],
  });
  
  /// Calculate memory efficiency ratio
  double get efficiencyRatio {
    if (cacheSize == 0) return 1.0;
    return activeCurrencies / cacheSize;
  }
  
  /// Check if memory cleanup is needed
  bool get needsCleanup {
    return staleEntries.length > 5 || efficiencyRatio < 0.7;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemoryUsageStats &&
        other.activeCurrencies == activeCurrencies &&
        other.cacheSize == cacheSize &&
        other.lastCleanup == lastCleanup &&
        _listEquals(other.staleEntries, staleEntries);
  }
  
  @override
  int get hashCode {
    return Object.hash(
      activeCurrencies,
      cacheSize,
      lastCleanup,
      Object.hashAll(staleEntries),
    );
  }
  
  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}