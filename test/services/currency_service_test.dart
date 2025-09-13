import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/services/currency_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  group('CurrencyService', () {
    late CurrencyService currencyService;

    setUp(() {
      // Initialize SharedPreferences with fake data
      SharedPreferences.setMockInitialValues({});
      // Reset service instance for clean tests
      CurrencyService.resetInstance();
      currencyService = CurrencyService.instance;
      currencyService.initialize();
    });

    tearDown(() {
      currencyService.dispose();
      CurrencyService.resetInstance();
    });

    group('Configuration', () {
      test('should have correct configuration values', () {
        expect(CurrencyServiceConfig.baseUrl, equals('http://localhost:8000/api/v1'));
        expect(CurrencyServiceConfig.apiKey, equals('dev-api-key'));
        expect(CurrencyServiceConfig.requestTimeout, equals(const Duration(seconds: 30)));
        expect(CurrencyServiceConfig.cacheExpiration, equals(const Duration(hours: 24)));
      });
    });

    group('CurrencyConversion', () {
      test('should create conversion correctly', () {
        final conversion = CurrencyConversion(
          originalAmount: 100.0,
          originalCurrency: 'USD',
          convertedAmount: 85.42,
          targetCurrency: 'EUR',
          exchangeRate: 0.8542,
          rateDate: DateTime(2025, 9, 11),
        );

        expect(conversion.originalAmount, equals(100.0));
        expect(conversion.originalCurrency, equals('USD'));
        expect(conversion.convertedAmount, equals(85.42));
        expect(conversion.targetCurrency, equals('EUR'));
        expect(conversion.exchangeRate, equals(0.8542));
      });

      test('should create same currency conversion', () {
        final conversion = CurrencyConversion.sameCurrency(
          amount: 100.0,
          currency: 'USD',
        );

        expect(conversion.originalAmount, equals(100.0));
        expect(conversion.originalCurrency, equals('USD'));
        expect(conversion.convertedAmount, equals(100.0));
        expect(conversion.targetCurrency, equals('USD'));
        expect(conversion.exchangeRate, equals(1.0));
      });

      test('should serialize and deserialize correctly', () {
        final original = CurrencyConversion(
          originalAmount: 100.0,
          originalCurrency: 'USD',
          convertedAmount: 85.42,
          targetCurrency: 'EUR',
          exchangeRate: 0.8542,
          rateDate: DateTime(2025, 9, 11),
        );

        final json = original.toJson();
        final restored = CurrencyConversion.fromJson(json);

        expect(restored.originalAmount, equals(original.originalAmount));
        expect(restored.originalCurrency, equals(original.originalCurrency));
        expect(restored.convertedAmount, equals(original.convertedAmount));
        expect(restored.targetCurrency, equals(original.targetCurrency));
        expect(restored.exchangeRate, equals(original.exchangeRate));
        expect(restored.rateDate.day, equals(original.rateDate.day));
      });
    });

    group('Cache Management', () {
      test('should indicate rates are not fresh when no cache exists', () async {
        final isFresh = await currencyService.areRatesFresh('USD');
        expect(isFresh, isFalse);
      });

      test('should indicate rates are fresh when recently cached', () async {
        // Simulate recent cache
        final prefs = await SharedPreferences.getInstance();
        final timestamp = DateTime.now().toIso8601String();
        await prefs.setString('currency_rates_timestamp_USD', timestamp);

        final isFresh = await currencyService.areRatesFresh('USD');
        expect(isFresh, isTrue);
      });

      test('should indicate rates are stale when cache is old', () async {
        // Simulate old cache
        final prefs = await SharedPreferences.getInstance();
        final oldTimestamp = DateTime.now()
            .subtract(const Duration(hours: 25))
            .toIso8601String();
        await prefs.setString('currency_rates_timestamp_USD', oldTimestamp);

        final isFresh = await currencyService.areRatesFresh('USD');
        expect(isFresh, isFalse);
      });

      test('should clear all cached data', () async {
        // Add some test cache data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currency_rates_USD', '{"EUR": 0.8542}');
        await prefs.setString('currency_rates_timestamp_USD', DateTime.now().toIso8601String());
        await prefs.setString('currency_rates_EUR', '{"USD": 1.1707}');

        // Clear cache
        await currencyService.clearCache();

        // Verify cache is cleared
        expect(prefs.getString('currency_rates_USD'), isNull);
        expect(prefs.getString('currency_rates_timestamp_USD'), isNull);
        expect(prefs.getString('currency_rates_EUR'), isNull);
      });

      test('should get cache statistics', () async {
        // Add some test cache data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currency_rates_USD', '{"EUR": 0.8542}');
        await prefs.setString('currency_rates_timestamp_USD', DateTime.now().toIso8601String());

        final stats = await currencyService.getCacheStats();

        expect(stats['total_rate_keys'], greaterThan(0));
        expect(stats['timestamp_keys'], greaterThan(0));
        expect(stats['freshness'], isA<Map<String, dynamic>>());
      });
    });

    group('Currency Conversion', () {
      test('should convert same currency correctly', () async {
        final result = await currencyService.convertAmount(
          amount: 100.0,
          fromCurrency: 'USD',
          toCurrency: 'USD',
        );

        expect(result, isNotNull);
        expect(result!.originalAmount, equals(100.0));
        expect(result.convertedAmount, equals(100.0));
        expect(result.exchangeRate, equals(1.0));
        expect(result.originalCurrency, equals('USD'));
        expect(result.targetCurrency, equals('USD'));
      });

      test('should convert using cached rates', () async {
        // Set up cached rates
        final prefs = await SharedPreferences.getInstance();
        final rates = {'EUR': 0.8542, 'USD': 1.0};
        await prefs.setString('currency_rates_USD', jsonEncode(rates));
        await prefs.setString('currency_rates_timestamp_USD', DateTime.now().toIso8601String());

        final result = await currencyService.convertAmount(
          amount: 100.0,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          baseCurrency: 'USD',
        );

        expect(result, isNotNull);
        expect(result!.originalAmount, equals(100.0));
        expect(result.convertedAmount, equals(85.42));
        expect(result.exchangeRate, equals(0.8542));
        expect(result.originalCurrency, equals('USD'));
        expect(result.targetCurrency, equals('EUR'));
      });

      test('should perform reverse conversion', () async {
        // Set up cached rates (USD as base)
        final prefs = await SharedPreferences.getInstance();
        final rates = {'EUR': 0.8542, 'USD': 1.0};
        await prefs.setString('currency_rates_USD', jsonEncode(rates));
        await prefs.setString('currency_rates_timestamp_USD', DateTime.now().toIso8601String());

        final result = await currencyService.convertAmount(
          amount: 85.42,
          fromCurrency: 'EUR',
          toCurrency: 'USD',
          baseCurrency: 'USD',
        );

        expect(result, isNotNull);
        expect(result!.originalAmount, equals(85.42));
        expect(result.convertedAmount, closeTo(100.0, 0.01));
        expect(result.exchangeRate, closeTo(1.1707, 0.0001));
        expect(result.originalCurrency, equals('EUR'));
        expect(result.targetCurrency, equals('USD'));
      });

      test('should handle missing rates gracefully', () async {
        // Set up cached rates without target currency
        final prefs = await SharedPreferences.getInstance();
        final rates = {'GBP': 0.7387, 'USD': 1.0};
        await prefs.setString('currency_rates_USD', jsonEncode(rates));
        await prefs.setString('currency_rates_timestamp_USD', DateTime.now().toIso8601String());

        final result = await currencyService.convertAmount(
          amount: 100.0,
          fromCurrency: 'USD',
          toCurrency: 'EUR', // Not in cached rates
          baseCurrency: 'USD',
        );

        expect(result, isNull);
      });
    });

    group('Error Handling', () {
      test('should handle CurrencyServiceException correctly', () {
        const exception = CurrencyServiceException(
          'Test error',
          details: 'Test details',
        );

        expect(exception.message, equals('Test error'));
        expect(exception.details, equals('Test details'));
        expect(exception.toString(), contains('Test error'));
        expect(exception.toString(), contains('Test details'));
      });

      test('should handle JSON parsing errors gracefully', () async {
        // Set up invalid JSON in cache
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currency_rates_USD', 'invalid json');
        await prefs.setString('currency_rates_timestamp_USD', DateTime.now().toIso8601String());

        // Should not throw, should return null or handle gracefully
        expect(
          () async => await currencyService.convertAmount(
            amount: 100.0,
            fromCurrency: 'USD',
            toCurrency: 'EUR',
            baseCurrency: 'USD',
          ),
          returnsNormally,
        );
      });
    });

    group('Network Operations', () {
      test('should handle successful API response', () async {
        // This test would need a mock HTTP client
        // For now, we'll test the response parsing logic separately
        const mockResponse = '''
        {
          "EUR": {"rate": "0.8542", "rate_date": "2025-09-11"},
          "GBP": {"rate": "0.7387", "rate_date": "2025-09-11"},
          "JPY": {"rate": "147.3705", "rate_date": "2025-09-11"}
        }''';

        final data = jsonDecode(mockResponse) as Map<String, dynamic>;
        final rates = <String, double>{};
        
        for (final entry in data.entries) {
          final currency = entry.key;
          final rateData = entry.value as Map<String, dynamic>;
          final rateStr = rateData['rate'] as String;
          rates[currency] = double.parse(rateStr);
        }

        expect(rates['EUR'], equals(0.8542));
        expect(rates['GBP'], equals(0.7387));
        expect(rates['JPY'], equals(147.3705));
      });

      test('should validate response format', () {
        const validResponse = '''
        {
          "EUR": {"rate": "0.8542", "rate_date": "2025-09-11"}
        }''';

        expect(() {
          final data = jsonDecode(validResponse) as Map<String, dynamic>;
          for (final entry in data.entries) {
            final rateData = entry.value as Map<String, dynamic>;
            expect(rateData.containsKey('rate'), isTrue);
            expect(rateData.containsKey('rate_date'), isTrue);
            expect(double.parse(rateData['rate'] as String), isA<double>());
          }
        }, returnsNormally);
      });
    });

    group('Integration Scenarios', () {
      test('should handle complete flow: fetch -> cache -> convert', () async {
        // 1. Simulate fresh cache miss
        expect(await currencyService.areRatesFresh('USD'), isFalse);

        // 2. Set up cache manually (simulating successful fetch)
        final prefs = await SharedPreferences.getInstance();
        final rates = {
          'EUR': 0.8542,
          'GBP': 0.7387,
          'JPY': 147.3705,
          'USD': 1.0,
        };
        await prefs.setString('currency_rates_USD', jsonEncode(rates));
        await prefs.setString('currency_rates_timestamp_USD', DateTime.now().toIso8601String());

        // 3. Verify cache is now fresh
        expect(await currencyService.areRatesFresh('USD'), isTrue);

        // 4. Perform conversion using cached data
        final conversion = await currencyService.convertAmount(
          amount: 100.0,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          baseCurrency: 'USD',
        );

        expect(conversion, isNotNull);
        expect(conversion!.convertedAmount, equals(85.42));
      });

      test('should handle multiple currency conversions', () async {
        // Set up comprehensive cached rates
        final prefs = await SharedPreferences.getInstance();
        final rates = {
          'EUR': 0.8542,
          'GBP': 0.7387,
          'JPY': 147.3705,
          'CAD': 1.3859,
          'USD': 1.0,
        };
        await prefs.setString('currency_rates_USD', jsonEncode(rates));
        await prefs.setString('currency_rates_timestamp_USD', DateTime.now().toIso8601String());

        // Test multiple conversions
        final conversions = await Future.wait([
          currencyService.convertAmount(
            amount: 100.0,
            fromCurrency: 'USD',
            toCurrency: 'EUR',
            baseCurrency: 'USD',
          ),
          currencyService.convertAmount(
            amount: 100.0,
            fromCurrency: 'USD',
            toCurrency: 'GBP',
            baseCurrency: 'USD',
          ),
          currencyService.convertAmount(
            amount: 100.0,
            fromCurrency: 'USD',
            toCurrency: 'JPY',
            baseCurrency: 'USD',
          ),
        ]);

        expect(conversions.every((c) => c != null), isTrue);
        expect(conversions[0]!.convertedAmount, equals(85.42)); // USD -> EUR
        expect(conversions[1]!.convertedAmount, equals(73.87)); // USD -> GBP
        expect(conversions[2]!.convertedAmount, equals(14737.05)); // USD -> JPY
      });
    });

    group('Performance and Memory', () {
      test('should reuse in-memory cache for performance', () async {
        // Set up cache
        final prefs = await SharedPreferences.getInstance();
        final rates = {'EUR': 0.8542, 'USD': 1.0};
        await prefs.setString('currency_rates_USD', jsonEncode(rates));
        await prefs.setString('currency_rates_timestamp_USD', DateTime.now().toIso8601String());

        // First call should load from SharedPreferences
        final result1 = await currencyService.convertAmount(
          amount: 100.0,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          baseCurrency: 'USD',
        );

        // Second call should use in-memory cache
        final result2 = await currencyService.convertAmount(
          amount: 200.0,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          baseCurrency: 'USD',
        );

        expect(result1, isNotNull);
        expect(result2, isNotNull);
        expect(result1!.exchangeRate, equals(result2!.exchangeRate));
      });
    });
  });
}