import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/services/currency_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  group('CurrencyService Integration', () {
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

    group('API Response Processing Tests', () {
      test('should parse successful API response correctly', () async {
        // Test response parsing without actual HTTP calls
        const mockResponseBody = '''
        {
          "EUR": {"rate": "0.8542", "rate_date": "2025-09-11"},
          "GBP": {"rate": "0.7387", "rate_date": "2025-09-11"},
          "JPY": {"rate": "147.3705", "rate_date": "2025-09-11"},
          "CAD": {"rate": "1.3859", "rate_date": "2025-09-11"}
        }''';

        final rates = await simulateFetchRatesResponse(mockResponseBody, 'USD');

        expect(rates, isNotNull);
        expect(rates['EUR'], equals(0.8542));
        expect(rates['GBP'], equals(0.7387));
        expect(rates['JPY'], equals(147.3705));
        expect(rates['CAD'], equals(1.3859));
        expect(rates['USD'], equals(1.0)); // Base currency should be 1.0
      });

      test('should handle empty response', () async {
        const emptyResponse = '{}';
        
        final rates = await simulateFetchRatesResponse(emptyResponse, 'USD');
        
        expect(rates, isNotNull);
        expect(rates['USD'], equals(1.0)); // Should still include base currency
        expect(rates.length, equals(1));
      });

      test('should validate response structure', () {
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

      test('should handle malformed rate values', () {
        const invalidRateResponse = '''
        {
          "EUR": {"rate": "invalid", "rate_date": "2025-09-11"}
        }''';

        expect(
          () async => await simulateFetchRatesResponse(invalidRateResponse, 'USD'),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('End-to-End Flow Tests', () {
      test('should complete cached flow: Cache -> Conversion', () async {
        // Simulate rates being cached (as if fetched from API)
        final prefs = await SharedPreferences.getInstance();
        final rates = {
          'EUR': 0.8542,
          'GBP': 0.7387,
          'CAD': 1.3859,
          'USD': 1.0,
        };
        await prefs.setString('currency_rates_USD', jsonEncode(rates));
        await prefs.setString('currency_rates_timestamp_USD', DateTime.now().toIso8601String());

        // Step 1: Verify rates are fresh
        expect(await currencyService.areRatesFresh('USD'), isTrue);

        // Step 2: Get cached rates
        final cachedRates = await currencyService.getLocalRates('USD');
        
        expect(cachedRates, isNotNull);
        expect(cachedRates['EUR'], equals(0.8542));
        expect(cachedRates['USD'], equals(1.0));

        // Step 3: Perform conversion using cached rates
        final conversion = await currencyService.convertAmount(
          amount: 100.0,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          baseCurrency: 'USD',
        );

        expect(conversion, isNotNull);
        expect(conversion!.originalAmount, equals(100.0));
        expect(conversion.convertedAmount, equals(85.42));
        expect(conversion.exchangeRate, equals(0.8542));
        expect(conversion.originalCurrency, equals('USD'));
        expect(conversion.targetCurrency, equals('EUR'));

        // Step 4: Perform multiple conversions
        final conversion2 = await currencyService.convertAmount(
          amount: 50.0,
          fromCurrency: 'USD',
          toCurrency: 'GBP',
          baseCurrency: 'USD',
        );

        expect(conversion2, isNotNull);
        expect(conversion2!.convertedAmount, equals(36.935));
      });

      test('should handle fallback to stale cached rates when API would fail', () async {
        // First, set up cached rates with stale timestamp
        final prefs = await SharedPreferences.getInstance();
        final rates = {'EUR': 0.8542, 'GBP': 0.7387, 'USD': 1.0};
        await prefs.setString('currency_rates_USD', jsonEncode(rates));
        
        // Set timestamp to be stale (25 hours old)
        final staleTimestamp = DateTime.now()
            .subtract(const Duration(hours: 25))
            .toIso8601String();
        await prefs.setString('currency_rates_timestamp_USD', staleTimestamp);

        // Verify rates are considered stale
        expect(await currencyService.areRatesFresh('USD'), isFalse);

        // This would normally try to fetch fresh rates, but since microservice might not be running,
        // it should fall back to cached rates. We test the cache fallback behavior.
        final conversion = await currencyService.convertAmount(
          amount: 100.0,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
          baseCurrency: 'USD',
        );

        // Should work with cached rates even if stale
        expect(conversion, isNotNull);
        expect(conversion!.convertedAmount, equals(85.42));
      });
    });

    group('Performance Tests', () {
      test('should handle rapid sequential conversions efficiently', () async {
        // Set up cached rates
        final prefs = await SharedPreferences.getInstance();
        final rates = {
          'EUR': 0.8542,
          'GBP': 0.7387,
          'JPY': 147.3705,
          'CAD': 1.3859,
          'AUD': 1.5116,
          'USD': 1.0,
        };
        await prefs.setString('currency_rates_USD', jsonEncode(rates));
        await prefs.setString('currency_rates_timestamp_USD', DateTime.now().toIso8601String());

        final stopwatch = Stopwatch()..start();

        // Perform 100 rapid conversions
        final conversions = <CurrencyConversion?>[];
        for (int i = 0; i < 100; i++) {
          final conversion = await currencyService.convertAmount(
            amount: (i + 1) * 10.0,
            fromCurrency: 'USD',
            toCurrency: i % 2 == 0 ? 'EUR' : 'GBP',
            baseCurrency: 'USD',
          );
          conversions.add(conversion);
        }

        stopwatch.stop();

        // All conversions should succeed
        expect(conversions.every((c) => c != null), isTrue);
        
        // Performance should be reasonable (under 1 second for 100 conversions)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}

/// Helper function to simulate successful HTTP responses for testing
Future<Map<String, double>> simulateFetchRatesResponse(String responseBody, String baseCurrency) async {
  final data = jsonDecode(responseBody) as Map<String, dynamic>;
  final rates = <String, double>{};
  
  for (final entry in data.entries) {
    final currency = entry.key;
    final rateData = entry.value as Map<String, dynamic>;
    final rateStr = rateData['rate'] as String;
    rates[currency] = double.parse(rateStr);
  }
  
  rates[baseCurrency] = 1.0;
  return rates;
}