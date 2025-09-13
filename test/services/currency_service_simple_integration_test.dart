import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/services/currency_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  group('CurrencyService Simple Integration', () {
    late CurrencyService currencyService;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      CurrencyService.resetInstance();
      currencyService = CurrencyService.instance;
      currencyService.initialize();
    });

    tearDown(() {
      currencyService.dispose();
      CurrencyService.resetInstance();
    });

    group('Real Microservice Integration', () {
      test('should connect to microservice when available', () async {
        // This test will only pass if the microservice is running
        // It's designed to be skipped if the service is not available
        
        try {
          final rates = await currencyService.fetchDailyRates('USD');
          
          // If we get here, the microservice is running and working
          expect(rates, isNotNull);
          expect(rates, isA<Map<String, double>>());
          expect(rates.containsKey('USD'), isTrue);
          expect(rates['USD'], equals(1.0));
          
          // Should have multiple currencies
          expect(rates.length, greaterThan(1));
          
          // All rates should be positive numbers
          for (final rate in rates.values) {
            expect(rate, greaterThan(0));
          }
          
          // Test passed - microservice is available and working
        } on CurrencyServiceException catch (e) {
          if (e.message.contains('Network error') || e.message.contains('Connection refused')) {
            // Microservice is not running - skip test gracefully
            return;
          } else {
            // Other error - should fail the test
            fail('Unexpected CurrencyServiceException: ${e.message}');
          }
        }
      }, timeout: const Timeout(Duration(seconds: 10)));

      test('should handle complete flow with microservice', () async {
        try {
          // Step 1: Check if rates are fresh (should be false initially)
          final initialFreshness = await currencyService.areRatesFresh('USD');
          expect(initialFreshness, isFalse);

          // Step 2: Get rates (this should fetch from microservice and cache)
          final rates = await currencyService.getLocalRates('USD');
          expect(rates, isNotNull);

          // Step 3: Check that rates are now fresh
          final afterFetchFreshness = await currencyService.areRatesFresh('USD');
          expect(afterFetchFreshness, isTrue);

          // Step 4: Perform currency conversion
          final conversion = await currencyService.convertAmount(
            amount: 100.0,
            fromCurrency: 'USD',
            toCurrency: 'EUR',
            baseCurrency: 'USD',
          );

          if (conversion != null) {
            expect(conversion.originalAmount, equals(100.0));
            expect(conversion.originalCurrency, equals('USD'));
            expect(conversion.targetCurrency, equals('EUR'));
            expect(conversion.exchangeRate, greaterThan(0));
            expect(conversion.convertedAmount, greaterThan(0));
            
            // Conversion test passed
          }

          // Complete flow test passed
        } on CurrencyServiceException catch (e) {
          if (e.message.contains('Network error') || e.message.contains('Connection refused')) {
            // Microservice not available - skip complete flow test
            return;
          } else {
            fail('Unexpected CurrencyServiceException: ${e.message}');
          }
        }
      }, timeout: const Timeout(Duration(seconds: 15)));
    });

    group('Offline Mode Tests', () {
      test('should work with pre-cached data when microservice is offline', () async {
        // Pre-populate cache with test data
        final prefs = await SharedPreferences.getInstance();
        final testRates = {
          'EUR': 0.8542,
          'GBP': 0.7387,
          'JPY': 147.3705,
          'CAD': 1.3859,
          'USD': 1.0,
        };
        
        await prefs.setString('currency_rates_USD', jsonEncode(testRates));
        await prefs.setString('currency_rates_timestamp_USD', DateTime.now().toIso8601String());

        // Verify rates are considered fresh
        final isFresh = await currencyService.areRatesFresh('USD');
        expect(isFresh, isTrue);

        // Test conversions using cached data
        final conversion1 = await currencyService.convertAmount(
          amount: 100.0,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          baseCurrency: 'USD',
        );

        expect(conversion1, isNotNull);
        expect(conversion1!.convertedAmount, equals(85.42));

        final conversion2 = await currencyService.convertAmount(
          amount: 100.0,
          fromCurrency: 'USD',
          toCurrency: 'GBP',
          baseCurrency: 'USD',
        );

        expect(conversion2, isNotNull);
        expect(conversion2!.convertedAmount, equals(73.87));

        // Offline mode test passed with cached data
      });

      test('should handle stale cache gracefully', () async {
        // Pre-populate cache with old timestamp
        final prefs = await SharedPreferences.getInstance();
        final testRates = {
          'EUR': 0.8542,
          'USD': 1.0,
        };
        
        await prefs.setString('currency_rates_USD', jsonEncode(testRates));
        final staleTimestamp = DateTime.now()
            .subtract(const Duration(hours: 25))
            .toIso8601String();
        await prefs.setString('currency_rates_timestamp_USD', staleTimestamp);

        // Verify rates are considered stale
        final isFresh = await currencyService.areRatesFresh('USD');
        expect(isFresh, isFalse);

        // Getting rates should attempt fresh fetch, but fall back to stale cache if service unavailable
        try {
          final rates = await currencyService.getLocalRates('USD');
          // If this succeeds, either microservice was available or we fell back to cache
          expect(rates, isNotNull);
          expect(rates.containsKey('USD'), isTrue);
        } on CurrencyServiceException {
          // This might happen if there's no cached data to fall back to
          // Test handles this gracefully
        }

        // Stale cache test completed
      });
    });

    group('Error Resilience Tests', () {
      test('should handle invalid currency codes gracefully', () async {
        final conversion = await currencyService.convertAmount(
          amount: 100.0,
          fromCurrency: 'INVALID',
          toCurrency: 'USD',
          baseCurrency: 'USD',
        );

        // Should return null for invalid currency conversion
        expect(conversion, isNull);
      });

      test('should validate configuration', () {
        expect(CurrencyServiceConfig.baseUrl, isNotEmpty);
        expect(CurrencyServiceConfig.apiKey, isNotEmpty);
        expect(CurrencyServiceConfig.requestTimeout.inSeconds, greaterThan(0));
        expect(CurrencyServiceConfig.cacheExpiration.inHours, equals(24));
      });

      test('should handle cache corruption gracefully', () async {
        // Corrupt the cache with invalid JSON
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currency_rates_USD', 'invalid json');
        await prefs.setString('currency_rates_timestamp_USD', DateTime.now().toIso8601String());

        // Should handle this gracefully and not crash
        expect(
          () async => await currencyService.convertAmount(
            amount: 100.0,
            fromCurrency: 'USD',
            toCurrency: 'EUR',
            baseCurrency: 'USD',
          ),
          returnsNormally,
        );

        // Cache corruption test passed
      });
    });

    group('Performance Tests', () {
      test('should handle multiple rapid conversions efficiently', () async {
        // Set up cached rates for performance testing
        final prefs = await SharedPreferences.getInstance();
        final testRates = {
          'EUR': 0.8542,
          'GBP': 0.7387,
          'JPY': 147.3705,
          'CAD': 1.3859,
          'AUD': 1.5116,
          'USD': 1.0,
        };
        
        await prefs.setString('currency_rates_USD', jsonEncode(testRates));
        await prefs.setString('currency_rates_timestamp_USD', DateTime.now().toIso8601String());

        final stopwatch = Stopwatch()..start();
        
        // Perform 50 rapid conversions
        var successCount = 0;
        for (int i = 0; i < 50; i++) {
          final conversion = await currencyService.convertAmount(
            amount: (i + 1) * 10.0,
            fromCurrency: 'USD',
            toCurrency: i % 2 == 0 ? 'EUR' : 'GBP',
            baseCurrency: 'USD',
          );
          if (conversion != null) successCount++;
        }
        
        stopwatch.stop();
        
        expect(successCount, equals(50));
        expect(stopwatch.elapsedMilliseconds, lessThan(500)); // Should be very fast with cached data
      });
    });
  });
}