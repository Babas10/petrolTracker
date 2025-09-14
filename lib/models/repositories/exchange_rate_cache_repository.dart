import 'package:drift/drift.dart';
import 'package:petrol_tracker/database/database.dart';
import 'package:petrol_tracker/models/exchange_rate_cache_model.dart';

/// Repository for managing exchange rate cache data
class ExchangeRateCacheRepository {
  final AppDatabase _database;

  ExchangeRateCacheRepository(this._database);

  /// Get a cached exchange rate for a specific currency pair
  Future<ExchangeRateCacheModel?> getRate(String baseCurrency, String targetCurrency) async {
    try {
      final rate = await (_database.select(_database.exchangeRatesCache)
            ..where((table) => 
                table.baseCurrency.equals(baseCurrency.toUpperCase()) & 
                table.targetCurrency.equals(targetCurrency.toUpperCase())))
          .getSingleOrNull();
      
      if (rate == null) return null;
      return ExchangeRateCacheModel.fromEntity(rate);
    } catch (e) {
      throw Exception('Failed to get exchange rate: $e');
    }
  }

  /// Get all cached rates for a specific base currency
  Future<List<ExchangeRateCacheModel>> getRatesForBaseCurrency(String baseCurrency) async {
    try {
      final rates = await (_database.select(_database.exchangeRatesCache)
            ..where((table) => table.baseCurrency.equals(baseCurrency.toUpperCase())))
          .get();
      
      return rates.map(ExchangeRateCacheModel.fromEntity).toList();
    } catch (e) {
      throw Exception('Failed to get rates for base currency: $e');
    }
  }

  /// Get all cached rates
  Future<List<ExchangeRateCacheModel>> getAllRates() async {
    try {
      final rates = await _database.select(_database.exchangeRatesCache).get();
      return rates.map(ExchangeRateCacheModel.fromEntity).toList();
    } catch (e) {
      throw Exception('Failed to get all rates: $e');
    }
  }

  /// Cache a single exchange rate
  Future<ExchangeRateCacheModel> cacheRate(ExchangeRateCacheModel rate) async {
    try {
      final id = await _database.into(_database.exchangeRatesCache).insertOnConflictUpdate(
        rate.toCompanion(),
      );
      
      return rate.copyWith(id: id);
    } catch (e) {
      throw Exception('Failed to cache exchange rate: $e');
    }
  }

  /// Cache multiple exchange rates in a transaction
  Future<List<ExchangeRateCacheModel>> cacheRates(List<ExchangeRateCacheModel> rates) async {
    try {
      final results = <ExchangeRateCacheModel>[];
      
      await _database.transaction(() async {
        for (final rate in rates) {
          final id = await _database.into(_database.exchangeRatesCache).insertOnConflictUpdate(
            rate.toCompanion(),
          );
          results.add(rate.copyWith(id: id));
        }
      });
      
      return results;
    } catch (e) {
      throw Exception('Failed to cache exchange rates: $e');
    }
  }

  /// Update an existing cached rate
  Future<ExchangeRateCacheModel> updateRate(ExchangeRateCacheModel rate) async {
    try {
      if (rate.id == null) {
        throw Exception('Cannot update rate without ID');
      }
      
      await _database.update(_database.exchangeRatesCache).replace(
        rate.toUpdateCompanion(),
      );
      
      return rate;
    } catch (e) {
      throw Exception('Failed to update exchange rate: $e');
    }
  }

  /// Check if a rate is fresh (less than 24 hours old)
  Future<bool> isRateFresh(String baseCurrency, String targetCurrency) async {
    try {
      final rate = await getRate(baseCurrency, targetCurrency);
      if (rate == null) return false;
      return rate.isFresh;
    } catch (e) {
      return false;
    }
  }

  /// Get fresh rates for a base currency (less than 24 hours old)
  Future<List<ExchangeRateCacheModel>> getFreshRatesForBaseCurrency(String baseCurrency) async {
    try {
      final rates = await getRatesForBaseCurrency(baseCurrency);
      return rates.where((rate) => rate.isFresh).toList();
    } catch (e) {
      throw Exception('Failed to get fresh rates: $e');
    }
  }

  /// Get stale rates (older than 24 hours)
  Future<List<ExchangeRateCacheModel>> getStaleRates() async {
    try {
      final rates = await getAllRates();
      return rates.where((rate) => !rate.isFresh).toList();
    } catch (e) {
      throw Exception('Failed to get stale rates: $e');
    }
  }

  /// Delete a specific cached rate
  Future<void> deleteRate(String baseCurrency, String targetCurrency) async {
    try {
      await (_database.delete(_database.exchangeRatesCache)
            ..where((table) => 
                table.baseCurrency.equals(baseCurrency.toUpperCase()) & 
                table.targetCurrency.equals(targetCurrency.toUpperCase())))
          .go();
    } catch (e) {
      throw Exception('Failed to delete exchange rate: $e');
    }
  }

  /// Delete all cached rates for a specific base currency
  Future<void> deleteRatesForBaseCurrency(String baseCurrency) async {
    try {
      await (_database.delete(_database.exchangeRatesCache)
            ..where((table) => table.baseCurrency.equals(baseCurrency.toUpperCase())))
          .go();
    } catch (e) {
      throw Exception('Failed to delete rates for base currency: $e');
    }
  }

  /// Delete all stale cached rates (older than 24 hours)
  Future<int> deleteStaleRates() async {
    try {
      final staleThreshold = DateTime.now().subtract(const Duration(hours: 24));
      
      return await (_database.delete(_database.exchangeRatesCache)
            ..where((table) => table.lastUpdated.isSmallerThanValue(staleThreshold)))
          .go();
    } catch (e) {
      throw Exception('Failed to delete stale rates: $e');
    }
  }

  /// Clear all cached rates (for testing/reset)
  Future<void> clearAllRates() async {
    try {
      await _database.delete(_database.exchangeRatesCache).go();
    } catch (e) {
      throw Exception('Failed to clear all rates: $e');
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final allRates = await getAllRates();
      final freshRates = allRates.where((rate) => rate.isFresh).toList();
      final staleRates = allRates.where((rate) => !rate.isFresh).toList();
      
      // Group by base currency
      final baseCurrencies = <String, int>{};
      for (final rate in allRates) {
        baseCurrencies[rate.baseCurrency] = (baseCurrencies[rate.baseCurrency] ?? 0) + 1;
      }
      
      return {
        'total_cached_rates': allRates.length,
        'fresh_rates': freshRates.length,
        'stale_rates': staleRates.length,
        'base_currencies': baseCurrencies.keys.toList(),
        'base_currency_counts': baseCurrencies,
        'oldest_rate_age_hours': allRates.isEmpty ? 0 : allRates.map((r) => r.ageInHours).reduce((a, b) => a > b ? a : b),
        'newest_rate_age_hours': allRates.isEmpty ? 0 : allRates.map((r) => r.ageInHours).reduce((a, b) => a < b ? a : b),
      };
    } catch (e) {
      throw Exception('Failed to get cache statistics: $e');
    }
  }

  /// Watch for changes to cached rates for a specific base currency
  Stream<List<ExchangeRateCacheModel>> watchRatesForBaseCurrency(String baseCurrency) {
    return (_database.select(_database.exchangeRatesCache)
          ..where((table) => table.baseCurrency.equals(baseCurrency.toUpperCase())))
        .watch()
        .map((rates) => rates.map(ExchangeRateCacheModel.fromEntity).toList());
  }

  /// Watch for changes to all cached rates
  Stream<List<ExchangeRateCacheModel>> watchAllRates() {
    return _database.select(_database.exchangeRatesCache)
        .watch()
        .map((rates) => rates.map(ExchangeRateCacheModel.fromEntity).toList());
  }
}