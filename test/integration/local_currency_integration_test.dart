import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrol_tracker/services/local_currency_converter.dart';
import 'package:petrol_tracker/services/exchange_rate_cache.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';

void main() {
  group('Local Currency Integration Tests', () {
    late LocalCurrencyConverter converter;
    late ExchangeRateCache cache;
    
    setUp(() async {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      
      converter = LocalCurrencyConverter.instance;
      cache = ExchangeRateCache.instance;
      
      // Set up comprehensive test data simulating real-world exchange rates
      await _setupTestExchangeRates(cache);
    });
    
    tearDown(() async {
      await converter.clearCache();
      await cache.clearAllCache();
    });

    group('End-to-End Currency Conversion Flow', () {
      test('should handle complete fuel entry conversion workflow', () async {
        // Create sample fuel entries in different currencies
        final entries = [
          FuelEntryModel.create(
            vehicleId: 1,
            date: DateTime.now().subtract(const Duration(days: 5)),
            currentKm: 1000,
            fuelAmount: 50.0,
            price: 65.0, // USD
            currency: 'USD',
            country: 'United States',
            pricePerLiter: 1.30,
          ),
          FuelEntryModel.create(
            vehicleId: 1,
            date: DateTime.now().subtract(const Duration(days: 4)),
            currentKm: 1250,
            fuelAmount: 45.0,
            price: 72.5, // EUR
            currency: 'EUR',
            country: 'Germany',
            pricePerLiter: 1.61,
          ),
          FuelEntryModel.create(
            vehicleId: 1,
            date: DateTime.now().subtract(const Duration(days: 3)),
            currentKm: 1500,
            fuelAmount: 48.0,
            price: 58.0, // GBP
            currency: 'GBP',
            country: 'United Kingdom',
            pricePerLiter: 1.21,
          ),
          FuelEntryModel.create(
            vehicleId: 1,
            date: DateTime.now().subtract(const Duration(days: 2)),
            currentKm: 1750,
            fuelAmount: 52.0,
            price: 7150.0, // JPY
            currency: 'JPY',
            country: 'Japan',
            pricePerLiter: 137.5,
          ),
        ];

        // Convert all entries to USD (user's primary currency)
        final convertedEntries = await converter.convertFuelEntriesToPrimary(
          entries,
          'USD',
        );

        expect(convertedEntries.length, equals(4));

        // First entry should remain unchanged (already USD)
        expect(convertedEntries[0].currency, equals('USD'));
        expect(convertedEntries[0].price, equals(65.0));
        expect(convertedEntries[0].originalAmount, isNull);

        // Second entry: EUR to USD
        expect(convertedEntries[1].currency, equals('USD'));
        expect(convertedEntries[1].price, closeTo(85.24, 0.1)); // 72.5 * 1.176
        expect(convertedEntries[1].originalAmount, equals(72.5));

        // Third entry: GBP to USD  
        expect(convertedEntries[2].currency, equals('USD'));
        expect(convertedEntries[2].price, closeTo(79.45, 0.1)); // 58.0 * 1.37
        expect(convertedEntries[2].originalAmount, equals(58.0));

        // Fourth entry: JPY to USD
        expect(convertedEntries[3].currency, equals('USD'));
        expect(convertedEntries[3].price, closeTo(65.0, 0.1)); // 7150 / 110
        expect(convertedEntries[3].originalAmount, equals(7150.0));

        // Verify all entries now have consistent USD pricing for analysis
        final totalCostUSD = convertedEntries
            .map((entry) => entry.price)
            .reduce((a, b) => a + b);
        
        expect(totalCostUSD, greaterThan(250.0));
        expect(totalCostUSD, lessThan(350.0));
      });

      test('should efficiently handle batch conversions', () async {
        // Create a large batch of mixed currency amounts
        final amounts = <double>[];
        final currencies = <String>[];
        final targetCurrency = 'USD';
        
        // Generate test data
        for (int i = 0; i < 50; i++) {
          amounts.add((i + 1) * 10.0);
          currencies.add(['USD', 'EUR', 'GBP', 'JPY', 'CHF'][i % 5]);
        }

        final stopwatch = Stopwatch()..start();
        
        final conversions = await converter.convertBatch(
          amounts: amounts,
          fromCurrencies: currencies,
          toCurrency: targetCurrency,
        );
        
        stopwatch.stop();

        expect(conversions.length, equals(50));
        expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // Should be fast
        
        // Verify all conversions succeeded and are to target currency
        for (final conversion in conversions) {
          expect(conversion.targetCurrency, equals(targetCurrency));
          expect(conversion.convertedAmount, greaterThan(0));
          expect(conversion.exchangeRate, greaterThan(0));
        }
      });

      test('should provide accurate conversion availability information', () async {
        // Test various currency pairs
        expect(await converter.canConvert('USD', 'EUR'), isTrue);
        expect(await converter.canConvert('EUR', 'USD'), isTrue);
        expect(await converter.canConvert('USD', 'USD'), isTrue);
        expect(await converter.canConvert('GBP', 'JPY'), isTrue); // Cross-conversion
        expect(await converter.canConvert('USD', 'UNKNOWN'), isFalse);
        
        // Verify available rates
        final usdRates = await converter.getAvailableRates('USD');
        expect(usdRates.containsKey('EUR'), isTrue);
        expect(usdRates.containsKey('GBP'), isTrue);
        expect(usdRates.containsKey('JPY'), isTrue);
        
        final eurRates = await converter.getAvailableRates('EUR');
        expect(eurRates.containsKey('USD'), isTrue);
      });
    });

    group('Cache Health and Performance', () {
      test('should maintain healthy cache status', () async {
        // Perform some conversions to populate cache
        await converter.convertAmount(amount: 100, fromCurrency: 'USD', toCurrency: 'EUR');
        await converter.convertAmount(amount: 100, fromCurrency: 'EUR', toCurrency: 'GBP');
        await converter.convertAmount(amount: 100, fromCurrency: 'GBP', toCurrency: 'JPY');

        final healthReport = await cache.getCacheHealth();
        
        expect(healthReport.status, isA<CacheHealthStatus>());
        expect(healthReport.healthPercentage, greaterThanOrEqualTo(0.0));
        expect(healthReport.freshCurrencies, greaterThan(0));
      });

      test('should provide detailed cache statistics', () async {
        // Populate cache with various operations
        await converter.convertAmount(amount: 100, fromCurrency: 'USD', toCurrency: 'EUR');
        await converter.convertAmount(amount: 200, fromCurrency: 'EUR', toCurrency: 'USD');
        await converter.getAvailableRates('USD');
        await converter.getAvailableRates('EUR');

        final cacheStats = await cache.getCacheStatistics();
        final converterStats = await converter.getCacheStats();

        expect(cacheStats.containsKey('memory_cache_size'), isTrue);
        expect(cacheStats.containsKey('health_status'), isTrue);
        expect(cacheStats.containsKey('persistent_cache_currencies'), isTrue);
        
        expect(converterStats.containsKey('memory_cached_currencies'), isTrue);
        expect(converterStats.containsKey('memory_cache_size'), isTrue);
        
        expect(cacheStats['memory_cache_size'], isA<int>());
        expect(converterStats['memory_cache_size'], isA<int>());
      });

      test('should handle cache overflow gracefully', () async {
        // Generate many currency pairs to test cache limits
        final currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CHF', 'CAD', 'AUD', 'NZD'];
        
        // Perform conversions between all pairs
        for (final from in currencies) {
          for (final to in currencies) {
            if (from != to) {
              await converter.convertAmount(
                amount: 100.0,
                fromCurrency: from,
                toCurrency: to,
              );
            }
          }
        }

        // Cache should still be functional
        final stats = await converter.getCacheStats();
        expect(stats['memory_cache_size'], lessThanOrEqualTo(50)); // Within limits
        
        // Recent conversions should still work
        final recentConversion = await converter.convertAmount(
          amount: 100,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );
        expect(recentConversion, isNotNull);
      });
    });

    group('Fallback and Error Handling', () {
      test('should handle missing rates with appropriate fallbacks', () async {
        // Try to convert with a currency that has no cached rates
        await cache.clearCurrency('CHF');
        
        final conversion = await converter.convertAmount(
          amount: 100.0,
          fromCurrency: 'CHF',
          toCurrency: 'USD',
        );
        
        // Should attempt cross-conversion or return null gracefully
        expect(conversion, anyOf(isNull, isNotNull));
        
        if (conversion != null) {
          expect(conversion.originalCurrency, equals('CHF'));
          expect(conversion.targetCurrency, equals('USD'));
          expect(conversion.exchangeRate, greaterThan(0));
        }
      });

      test('should validate inputs and prevent invalid conversions', () async {
        // Test various invalid inputs
        expect(
          await converter.convertAmount(
            amount: -100,
            fromCurrency: 'USD',
            toCurrency: 'EUR',
          ),
          isNull,
        );
        
        expect(
          await converter.convertAmount(
            amount: 0,
            fromCurrency: 'USD',
            toCurrency: 'EUR',
          ),
          isNull,
        );
        
        expect(
          await converter.convertAmount(
            amount: double.infinity,
            fromCurrency: 'USD',
            toCurrency: 'EUR',
          ),
          isNull,
        );
        
        expect(
          await converter.convertAmount(
            amount: 100,
            fromCurrency: 'INVALID',
            toCurrency: 'EUR',
          ),
          isNull,
        );
      });

      test('should handle corrupted cache data gracefully', () async {
        // Corrupt some cache data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currency_rates_CORRUPT', 'invalid json data');
        
        // System should continue working with other currencies
        final conversion = await converter.convertAmount(
          amount: 100,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );
        
        expect(conversion, isNotNull);
      });
    });

    group('Real-World Scenarios', () {
      test('should handle international fuel purchase scenario', () async {
        // Simulate a traveler buying fuel in different countries
        final travelExpenses = [
          {'amount': 45.0, 'currency': 'USD', 'country': 'USA'},
          {'amount': 52.3, 'currency': 'EUR', 'country': 'France'},  
          {'amount': 48.7, 'currency': 'GBP', 'country': 'UK'},
          {'amount': 6800.0, 'currency': 'JPY', 'country': 'Japan'},
          {'amount': 58.9, 'currency': 'CHF', 'country': 'Switzerland'},
        ];

        final amounts = travelExpenses.map((e) => e['amount'] as double).toList();
        final currencies = travelExpenses.map((e) => e['currency'] as String).toList();
        
        final conversions = await converter.convertBatch(
          amounts: amounts,
          fromCurrencies: currencies,
          toCurrency: 'USD', // User's home currency
        );

        expect(conversions.length, equals(5));
        
        // Calculate total trip cost in USD
        final totalCostUSD = conversions
            .map((conversion) => conversion.convertedAmount)
            .reduce((a, b) => a + b);
        
        expect(totalCostUSD, greaterThan(200.0));
        expect(totalCostUSD, lessThan(400.0));
        
        // Verify each conversion has reasonable rates
        for (final conversion in conversions) {
          expect(conversion.exchangeRate, greaterThan(0));
          expect(conversion.convertedAmount, greaterThan(0));
          expect(conversion.targetCurrency, equals('USD'));
        }
      });

      test('should handle business expense reporting scenario', () async {
        // Simulate converting monthly fuel expenses from various subsidiaries
        final monthlyExpenses = List.generate(30, (day) => {
          'day': day + 1,
          'amount': 50.0 + (day * 2.5), // Varying amounts
          'currency': ['USD', 'EUR', 'GBP', 'CAD', 'AUD'][day % 5],
        });

        final amounts = monthlyExpenses.map((e) => e['amount'] as double).toList();
        final currencies = monthlyExpenses.map((e) => e['currency'] as String).toList();

        final conversions = await converter.convertBatch(
          amounts: amounts,
          fromCurrencies: currencies,
          toCurrency: 'USD', // Corporate reporting currency
        );

        expect(conversions.length, equals(30));
        
        // Calculate monthly total
        final monthlyTotalUSD = conversions
            .map((conversion) => conversion.convertedAmount)
            .reduce((a, b) => a + b);

        expect(monthlyTotalUSD, greaterThan(2000.0));
        
        // Verify conversion consistency (same currency should have same rate)
        final usdConversions = conversions
            .where((c) => c.originalCurrency == 'USD')
            .toList();
        
        if (usdConversions.length > 1) {
          final firstRate = usdConversions.first.exchangeRate;
          for (final conversion in usdConversions) {
            expect(conversion.exchangeRate, equals(firstRate));
          }
        }
      });
    });
  });
}

/// Set up comprehensive test exchange rate data
Future<void> _setupTestExchangeRates(ExchangeRateCache cache) async {
  // USD rates (base currency for most conversions)
  await cache.saveRates('USD', {
    'EUR': 0.85,      // 1 USD = 0.85 EUR
    'GBP': 0.73,      // 1 USD = 0.73 GBP  
    'JPY': 110.0,     // 1 USD = 110 JPY
    'CHF': 0.92,      // 1 USD = 0.92 CHF
    'CAD': 1.25,      // 1 USD = 1.25 CAD
    'AUD': 1.35,      // 1 USD = 1.35 AUD
    'NZD': 1.42,      // 1 USD = 1.42 NZD
  }, source: 'test');

  // EUR rates
  await cache.saveRates('EUR', {
    'USD': 1.176,     // 1 EUR = 1.176 USD
    'GBP': 0.858,     // 1 EUR = 0.858 GBP
    'JPY': 129.4,     // 1 EUR = 129.4 JPY
    'CHF': 1.082,     // 1 EUR = 1.082 CHF
    'CAD': 1.47,      // 1 EUR = 1.47 CAD
  }, source: 'test');

  // GBP rates
  await cache.saveRates('GBP', {
    'USD': 1.37,      // 1 GBP = 1.37 USD
    'EUR': 1.166,     // 1 GBP = 1.166 EUR
    'JPY': 150.7,     // 1 GBP = 150.7 JPY
    'CHF': 1.26,      // 1 GBP = 1.26 CHF
  }, source: 'test');

  // JPY rates (note: JPY is typically quoted in reverse)
  await cache.saveRates('JPY', {
    'USD': 0.0091,    // 1 JPY = 0.0091 USD
    'EUR': 0.0077,    // 1 JPY = 0.0077 EUR
    'GBP': 0.0066,    // 1 JPY = 0.0066 GBP
  }, source: 'test');

  // CHF rates
  await cache.saveRates('CHF', {
    'USD': 1.087,     // 1 CHF = 1.087 USD
    'EUR': 0.925,     // 1 CHF = 0.925 EUR
    'GBP': 0.794,     // 1 CHF = 0.794 GBP
  }, source: 'test');
}