/// Manual provider definitions for currency operations
/// 
/// This file contains manually created providers that bypass build_runner
/// issues while providing the same functionality as the @riverpod annotations.
library;

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/services/currency_service.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/currency_settings_providers.dart';
import 'package:petrol_tracker/providers/currency_providers.dart' as original;

/// Provider for the currency service
final currencyServiceProvider = Provider<CurrencyService>((ref) {
  return CurrencyService.instance;
});

/// Provider for reactive exchange rates monitoring
final exchangeRatesMonitorProvider = StateNotifierProvider<ExchangeRatesMonitorNotifier, AsyncValue<Map<String, DateTime>>>((ref) {
  return ExchangeRatesMonitorNotifier(ref);
});

class ExchangeRatesMonitorNotifier extends StateNotifier<AsyncValue<Map<String, DateTime>>> {
  final Ref ref;
  Timer? _refreshTimer;
  
  ExchangeRatesMonitorNotifier(this.ref) : super(const AsyncValue.loading()) {
    _initialize();
  }
  
  Future<void> _initialize() async {
    try {
      final currencyService = ref.read(currencyServiceProvider);
      final primaryCurrency = ref.read(original.primaryCurrencyProvider);
      
      final isFresh = await currencyService.areRatesFresh(primaryCurrency);
      final now = DateTime.now();
      
      state = AsyncValue.data({
        primaryCurrency: isFresh ? now : now.subtract(const Duration(hours: 25)),
      });
      
      _setupPeriodicCheck();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  void _setupPeriodicCheck() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _checkAndRefreshRates();
    });
  }
  
  Future<void> _checkAndRefreshRates() async {
    try {
      final currencyService = ref.read(currencyServiceProvider);
      final primaryCurrency = ref.read(original.primaryCurrencyProvider);
      
      final isFresh = await currencyService.areRatesFresh(primaryCurrency);
      if (!isFresh) {
        // Trigger rate refresh by invalidating dependent providers
        ref.invalidate(exchangeRatesForCurrencyProvider);
        ref.invalidate(currencyConversionProvider);
        
        // Update state to reflect refresh attempt
        final currentState = state.value ?? <String, DateTime>{};
        state = AsyncValue.data({
          ...currentState,
          primaryCurrency: DateTime.now(),
        });
      }
    } catch (e) {
      // Handle errors gracefully - continue monitoring
    }
  }
  
  Future<void> refreshRatesFor(String currency) async {
    try {
      final currencyService = ref.read(currencyServiceProvider);
      await currencyService.fetchDailyRates(currency);
      
      final currentState = state.value ?? <String, DateTime>{};
      state = AsyncValue.data({
        ...currentState,
        currency: DateTime.now(),
      });
      
      // Invalidate dependent providers
      ref.invalidate(exchangeRatesForCurrencyProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

/// Provider for exchange rates for a specific currency
final exchangeRatesForCurrencyProvider = FutureProvider.family<Map<String, double>, String>((ref, baseCurrency) async {
  final currencyService = ref.read(currencyServiceProvider);
  
  // Watch exchange rates monitor to be notified of refresh events
  ref.watch(exchangeRatesMonitorProvider);
  
  try {
    final rates = await currencyService.getLocalRates(baseCurrency);
    return rates;
  } catch (e) {
    // Return basic fallback rates
    return {baseCurrency: 1.0};
  }
});

/// Provider for currency conversion between two specific currencies
final currencyConversionProvider = FutureProvider.family<CurrencyConversion?, ConversionParams>((ref, params) async {
  if (params.fromCurrency == params.toCurrency) {
    return CurrencyConversion.sameCurrency(
      amount: params.amount,
      currency: params.fromCurrency,
    );
  }
  
  final currencyService = ref.read(currencyServiceProvider);
  
  // Watch exchange rates to get automatic updates
  ref.watch(exchangeRatesForCurrencyProvider(params.fromCurrency));
  
  return await currencyService.convertAmount(
    amount: params.amount,
    fromCurrency: params.fromCurrency,
    toCurrency: params.toCurrency,
  );
});

/// Provider for dynamic available currencies based on fuel entries
final dynamicAvailableCurrenciesProvider = FutureProvider<List<String>>((ref) async {
  final fuelEntriesState = await ref.watch(fuelEntriesNotifierProvider.future);
  final allEntries = fuelEntriesState.entries;
  
  final currencies = <String>{};
  for (final entry in allEntries) {
    if (entry.country.isNotEmpty) {
      final currency = _extractCurrencyFromCountry(entry.country);
      currencies.add(currency);
    }
  }
  
  // Always include common currencies for better UX
  currencies.addAll(['USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY']);
  
  final sortedCurrencies = currencies.toList()..sort();
  return sortedCurrencies;
});

/// Provider for currency statistics and usage analytics
final currencyUsageStatisticsProvider = FutureProvider<CurrencyUsageStatistics>((ref) async {
  final fuelEntriesState = await ref.watch(fuelEntriesNotifierProvider.future);
  final allEntries = fuelEntriesState.entries;
  final primaryCurrency = ref.watch(original.primaryCurrencyProvider);
  
  final currencyCountMap = <String, int>{};
  final currencyAmountMap = <String, double>{};
  
  for (final entry in allEntries) {
    final currency = _extractCurrencyFromCountry(entry.country);
    currencyCountMap[currency] = (currencyCountMap[currency] ?? 0) + 1;
    currencyAmountMap[currency] = (currencyAmountMap[currency] ?? 0) + entry.price;
  }
  
  return CurrencyUsageStatistics(
    primaryCurrency: primaryCurrency,
    currencyEntryCount: currencyCountMap,
    currencyTotalAmount: currencyAmountMap,
    totalEntries: allEntries.length,
    uniqueCurrencies: currencyCountMap.keys.toList(),
  );
});

/// Provider for conversion rate health monitoring
final conversionHealthStatusProvider = FutureProvider<ConversionHealthStatus>((ref) async {
  final currencyService = ref.read(currencyServiceProvider);
  final primaryCurrency = ref.watch(original.primaryCurrencyProvider);
  final availableCurrencies = await ref.watch(dynamicAvailableCurrenciesProvider.future);
  
  final healthChecks = <String, bool>{};
  final staleCurrencies = <String>[];
  final failedCurrencies = <String>[];
  
  for (final currency in availableCurrencies) {
    if (currency == primaryCurrency) continue;
    
    try {
      final isFresh = await currencyService.areRatesFresh(currency);
      healthChecks[currency] = isFresh;
      
      if (!isFresh) {
        staleCurrencies.add(currency);
      }
      
      // Test conversion capability
      final testConversion = await currencyService.convertAmount(
        amount: 1.0,
        fromCurrency: currency,
        toCurrency: primaryCurrency,
      );
      
      if (testConversion == null) {
        failedCurrencies.add(currency);
      }
    } catch (e) {
      healthChecks[currency] = false;
      failedCurrencies.add(currency);
    }
  }
  
  final healthScore = healthChecks.values.where((isHealthy) => isHealthy).length / 
                     healthChecks.length.clamp(1, double.infinity);
  
  return ConversionHealthStatus(
    healthScore: healthScore,
    totalCurrencies: availableCurrencies.length,
    healthyCurrencies: healthChecks.values.where((h) => h).length,
    staleCurrencies: staleCurrencies,
    failedCurrencies: failedCurrencies,
    lastChecked: DateTime.now(),
  );
});

/// Helper function to extract currency from country
String _extractCurrencyFromCountry(String country) {
  switch (country.toLowerCase()) {
    case 'united states':
    case 'usa':
    case 'us':
      return 'USD';
    case 'canada':
      return 'CAD';
    case 'united kingdom':
    case 'uk':
    case 'england':
    case 'scotland':
    case 'wales':
      return 'GBP';
    case 'germany':
    case 'france':
    case 'italy':
    case 'spain':
    case 'netherlands':
    case 'belgium':
    case 'austria':
    case 'portugal':
    case 'ireland':
    case 'finland':
    case 'greece':
      return 'EUR';
    case 'japan':
      return 'JPY';
    case 'australia':
      return 'AUD';
    case 'switzerland':
      return 'CHF';
    case 'china':
      return 'CNY';
    case 'india':
      return 'INR';
    case 'brazil':
      return 'BRL';
    case 'mexico':
      return 'MXN';
    case 'singapore':
      return 'SGD';
    case 'hong kong':
      return 'HKD';
    case 'new zealand':
      return 'NZD';
    case 'sweden':
      return 'SEK';
    case 'norway':
      return 'NOK';
    case 'denmark':
      return 'DKK';
    case 'poland':
      return 'PLN';
    case 'czech republic':
      return 'CZK';
    case 'hungary':
      return 'HUF';
    default:
      return 'USD'; // Default fallback
  }
}

/// Parameter class for currency conversion
class ConversionParams {
  final double amount;
  final String fromCurrency;
  final String toCurrency;
  
  const ConversionParams({
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversionParams &&
        other.amount == amount &&
        other.fromCurrency == fromCurrency &&
        other.toCurrency == toCurrency;
  }
  
  @override
  int get hashCode {
    return Object.hash(amount, fromCurrency, toCurrency);
  }
}

/// Data class for currency usage statistics
class CurrencyUsageStatistics {
  final String primaryCurrency;
  final Map<String, int> currencyEntryCount;
  final Map<String, double> currencyTotalAmount;
  final int totalEntries;
  final List<String> uniqueCurrencies;
  
  const CurrencyUsageStatistics({
    required this.primaryCurrency,
    required this.currencyEntryCount,
    required this.currencyTotalAmount,
    required this.totalEntries,
    required this.uniqueCurrencies,
  });
  
  /// Get the most frequently used currency
  String get mostUsedCurrency {
    if (currencyEntryCount.isEmpty) return primaryCurrency;
    
    return currencyEntryCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  /// Get currency usage percentages
  Map<String, double> get currencyUsagePercentages {
    if (totalEntries == 0) return {};
    
    return currencyEntryCount.map((currency, count) =>
        MapEntry(currency, (count / totalEntries) * 100));
  }
  
  /// Check if user has multi-currency entries
  bool get hasMultiCurrencyUsage => uniqueCurrencies.length > 1;
}

/// Data class for conversion health status
class ConversionHealthStatus {
  final double healthScore;
  final int totalCurrencies;
  final int healthyCurrencies;
  final List<String> staleCurrencies;
  final List<String> failedCurrencies;
  final DateTime lastChecked;
  
  const ConversionHealthStatus({
    required this.healthScore,
    required this.totalCurrencies,
    required this.healthyCurrencies,
    required this.staleCurrencies,
    required this.failedCurrencies,
    required this.lastChecked,
  });
  
  /// Check if the overall system is healthy
  bool get isHealthy => healthScore >= 0.8;
  
  /// Get a human-readable health status
  String get healthDescription {
    if (healthScore >= 0.9) return 'Excellent';
    if (healthScore >= 0.7) return 'Good';
    if (healthScore >= 0.5) return 'Fair';
    return 'Poor';
  }
}