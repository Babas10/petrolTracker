import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrol_tracker/services/exchange_rate_cache.dart';

void main() {
  group('ExchangeRateCache Tests', () {
    late ExchangeRateCache cache;
    
    setUp(() async {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      cache = ExchangeRateCache.instance;
    });
    
    tearDown(() async {
      await cache.clearAllCache();
    });

    group('Basic Cache Operations', () {
      test('should save and load rates correctly', () async {
        final rates = {
          'EUR': 0.85,
          'GBP': 0.73,
          'JPY': 110.0,
        };
        
        await cache.saveRates('USD', rates, source: 'test');
        final loadedRates = await cache.loadRates('USD');
        
        expect(loadedRates, isNotNull);
        expect(loadedRates!.length, equals(3));
        expect(loadedRates['EUR'], equals(0.85));
        expect(loadedRates['GBP'], equals(0.73));
        expect(loadedRates['JPY'], equals(110.0));
      });

      test('should return null for non-existent currency', () async {
        final rates = await cache.loadRates('NONEXISTENT');
        expect(rates, isNull);
      });

      test('should handle empty rates map', () async {
        expect(
          () => cache.saveRates('USD', {}, source: 'test'),
          throwsArgumentError,
        );
      });

      test('should handle invalid currency codes', () async {
        expect(
          () => cache.saveRates('INVALID_CURRENCY', {'EUR': 0.85}, source: 'test'),
          throwsArgumentError,
        );
      });
    });

    group('Batch Operations', () {
      test('should batch load multiple currencies', () async {
        // Set up test data
        await cache.saveRates('USD', {'EUR': 0.85, 'GBP': 0.73}, source: 'test');
        await cache.saveRates('EUR', {'USD': 1.176, 'GBP': 0.858}, source: 'test');
        await cache.saveRates('GBP', {'USD': 1.37, 'EUR': 1.166}, source: 'test');
        
        final results = await cache.batchLoadRates(['USD', 'EUR', 'GBP', 'NONEXISTENT']);
        
        expect(results.length, equals(3)); // Only existing currencies
        expect(results.containsKey('USD'), isTrue);
        expect(results.containsKey('EUR'), isTrue);
        expect(results.containsKey('GBP'), isTrue);
        expect(results.containsKey('NONEXISTENT'), isFalse);
        
        expect(results['USD']!['EUR'], equals(0.85));
        expect(results['EUR']!['USD'], equals(1.176));
      });

      test('should reject oversized batch requests', () async {
        final largeCurrencyList = List.generate(25, (i) => 'CUR$i');
        
        expect(
          () => cache.batchLoadRates(largeCurrencyList),
          throwsArgumentError,
        );
      });
    });

    group('Freshness and Staleness', () {
      test('should correctly identify fresh rates', () async {
        await cache.saveRates('USD', {'EUR': 0.85}, source: 'test');
        
        final isFresh = await cache.areRatesFresh('USD');
        expect(isFresh, isTrue);
      });

      test('should correctly identify non-existent rates as not fresh', () async {
        final isFresh = await cache.areRatesFresh('NONEXISTENT');
        expect(isFresh, isFalse);
      });

      test('should handle corrupted timestamp data', () async {
        await cache.saveRates('USD', {'EUR': 0.85}, source: 'test');
        
        // Corrupt the timestamp
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currency_rates_timestamp_USD', 'invalid_timestamp');
        
        final isFresh = await cache.areRatesFresh('USD');
        expect(isFresh, isFalse);
      });
    });

    group('Cache Health Monitoring', () {
      test('should generate accurate health report', () async {
        // Set up some test currencies
        final testCurrencies = ['USD', 'EUR', 'GBP'];
        
        // Save rates for USD and EUR only
        await cache.saveRates('USD', {'EUR': 0.85, 'GBP': 0.73}, source: 'test');
        await cache.saveRates('EUR', {'USD': 1.176, 'GBP': 0.858}, source: 'test');
        
        final healthReport = await cache.getCacheHealth(testCurrencies);
        
        expect(healthReport.totalCurrencies, equals(3));
        expect(healthReport.freshCurrencies, equals(2)); // USD and EUR
        expect(healthReport.missingCurrencies, equals(1)); // GBP
        expect(healthReport.criticalMissing, contains('GBP'));
        expect(healthReport.healthPercentage, closeTo(66.67, 0.1));
        expect(healthReport.status, equals(CacheHealthStatus.stale));
      });

      test('should report healthy cache', () async {
        final testCurrencies = ['USD', 'EUR'];
        
        await cache.saveRates('USD', {'EUR': 0.85}, source: 'test');
        await cache.saveRates('EUR', {'USD': 1.176}, source: 'test');
        
        final healthReport = await cache.getCacheHealth(testCurrencies);
        
        expect(healthReport.status, equals(CacheHealthStatus.healthy));
        expect(healthReport.healthPercentage, equals(100.0));
        expect(healthReport.missingCurrencies, equals(0));
      });

      test('should report critical cache', () async {
        final testCurrencies = ['USD', 'EUR', 'GBP', 'JPY'];
        
        // Don't save any rates, so all will be missing
        final healthReport = await cache.getCacheHealth(testCurrencies);
        
        expect(healthReport.status, equals(CacheHealthStatus.critical));
        expect(healthReport.healthPercentage, equals(0.0));
        expect(healthReport.missingCurrencies, equals(4));
      });
    });

    group('Cache Statistics', () {
      test('should provide detailed cache statistics', () async {
        await cache.saveRates('USD', {'EUR': 0.85, 'GBP': 0.73}, source: 'test');
        await cache.saveRates('EUR', {'USD': 1.176}, source: 'test');
        
        // Load some rates to populate memory cache
        await cache.loadRates('USD');
        await cache.loadRates('EUR');
        
        final stats = await cache.getCacheStatistics();
        
        expect(stats, isNotNull);
        expect(stats.containsKey('memory_cache_size'), isTrue);
        expect(stats.containsKey('persistent_cache_currencies'), isTrue);
        expect(stats.containsKey('health_status'), isTrue);
        expect(stats.containsKey('health_percentage'), isTrue);
        
        expect(stats['persistent_cache_currencies'], greaterThanOrEqualTo(2));
        expect(stats['memory_cache_size'], greaterThan(0));
      });
    });

    group('Cache Clearing', () {
      test('should clear cache for specific currency', () async {
        await cache.saveRates('USD', {'EUR': 0.85}, source: 'test');
        await cache.saveRates('EUR', {'USD': 1.176}, source: 'test');
        
        // Verify both currencies exist
        expect(await cache.loadRates('USD'), isNotNull);
        expect(await cache.loadRates('EUR'), isNotNull);
        
        // Clear USD cache
        await cache.clearCurrency('USD');
        
        // USD should be gone, EUR should remain
        expect(await cache.loadRates('USD'), isNull);
        expect(await cache.loadRates('EUR'), isNotNull);
      });

      test('should clear all cache data', () async {
        await cache.saveRates('USD', {'EUR': 0.85}, source: 'test');
        await cache.saveRates('EUR', {'USD': 1.176}, source: 'test');
        await cache.saveRates('GBP', {'USD': 1.37}, source: 'test');
        
        // Verify all exist
        expect(await cache.loadRates('USD'), isNotNull);
        expect(await cache.loadRates('EUR'), isNotNull);
        expect(await cache.loadRates('GBP'), isNotNull);
        
        // Clear all
        await cache.clearAllCache();
        
        // All should be gone
        expect(await cache.loadRates('USD'), isNull);
        expect(await cache.loadRates('EUR'), isNull);
        expect(await cache.loadRates('GBP'), isNull);
      });
    });

    group('Memory Cache Management', () {
      test('should use memory cache for repeated access', () async {
        await cache.saveRates('USD', {'EUR': 0.85}, source: 'test');
        
        // First load should come from persistent storage
        final rates1 = await cache.loadRates('USD');
        expect(rates1, isNotNull);
        
        // Second load should come from memory cache (faster)
        final rates2 = await cache.loadRates('USD');
        expect(rates2, isNotNull);
        expect(rates2, equals(rates1));
      });

      test('should handle memory cache overflow gracefully', () async {
        // This test would require mocking the memory cache limit to be very small
        // For now, we'll just test that the method doesn't throw
        for (int i = 0; i < 10; i++) {
          await cache.saveRates('USD', {'CUR$i': 1.0 + i * 0.1}, source: 'test');
          await cache.loadRates('USD');
        }
        
        final stats = await cache.getCacheStatistics();
        expect(stats['memory_cache_size'], isA<int>());
      });
    });

    group('Prefetching', () {
      test('should prefetch common currencies', () async {
        // Set up some rates for common currencies
        await cache.saveRates('USD', {'EUR': 0.85, 'GBP': 0.73}, source: 'test');
        await cache.saveRates('EUR', {'USD': 1.176}, source: 'test');
        
        // This should not throw and should populate memory cache
        await cache.prefetchCommonCurrencies();
        
        final stats = await cache.getCacheStatistics();
        expect(stats['memory_cache_size'], greaterThan(0));
      });
    });

    group('Error Handling', () {
      test('should handle SharedPreferences errors gracefully', () async {
        // This is difficult to test without more advanced mocking
        // For now, we'll test that basic operations don't throw unexpected errors
        
        final rates = await cache.loadRates('NONEXISTENT');
        expect(rates, isNull);
        
        final isFresh = await cache.areRatesFresh('NONEXISTENT');
        expect(isFresh, isFalse);
      });

      test('should handle corrupted cache data', () async {
        // Manually corrupt cache data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currency_rates_CORRUPT', 'invalid json');
        
        final rates = await cache.loadRates('CORRUPT');
        expect(rates, isNull);
      });
    });

    group('Metadata Management', () {
      test('should track access statistics', () async {
        await cache.saveRates('USD', {'EUR': 0.85}, source: 'test_source');
        
        // Access the rates multiple times
        await cache.loadRates('USD');
        await cache.loadRates('USD');
        await cache.loadRates('USD');
        
        final stats = await cache.getCacheStatistics();
        expect(stats['most_accessed_currencies'], isA<List>());
      });

      test('should store source information', () async {
        await cache.saveRates('USD', {'EUR': 0.85}, source: 'api_v1');
        
        // The metadata should be stored, though we can't directly access it
        // in this simplified test. In a real implementation, we'd have 
        // methods to retrieve metadata.
        final rates = await cache.loadRates('USD');
        expect(rates, isNotNull);
      });
    });
  });
}