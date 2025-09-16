import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrol_tracker/services/local_currency_converter.dart';
import 'package:petrol_tracker/services/currency_service.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';

void main() {
  group('LocalCurrencyConverter Tests', () {
    late LocalCurrencyConverter converter;
    
    setUp(() async {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      converter = LocalCurrencyConverter.instance;
      
      // Set up sample cached rates for testing
      final prefs = await SharedPreferences.getInstance();
      
      // USD to other currencies
      await prefs.setString('currency_rates_USD', '''{
        "EUR": 0.85,
        "GBP": 0.73,
        "JPY": 110.0,
        "CAD": 1.25,
        "CHF": 0.92
      }''');
      await prefs.setString('currency_rates_timestamp_USD', DateTime.now().toIso8601String());
      
      // EUR to other currencies
      await prefs.setString('currency_rates_EUR', '''{
        "USD": 1.176,
        "GBP": 0.858,
        "JPY": 129.4,
        "CHF": 1.082
      }''');
      await prefs.setString('currency_rates_timestamp_EUR', DateTime.now().toIso8601String());
    });
    
    tearDown(() async {
      await converter.clearCache();
    });

    group('Basic Conversion Tests', () {
      test('should convert same currency correctly', () async {
        final result = await converter.convertAmount(
          amount: 100.0,
          fromCurrency: 'USD',
          toCurrency: 'USD',
        );
        
        expect(result, isNotNull);
        expect(result!.originalAmount, equals(100.0));
        expect(result.convertedAmount, equals(100.0));
        expect(result.originalCurrency, equals('USD'));
        expect(result.targetCurrency, equals('USD'));
        expect(result.exchangeRate, equals(1.0));
      });

      test('should convert USD to EUR using direct rate', () async {
        final result = await converter.convertAmount(
          amount: 100.0,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );
        
        expect(result, isNotNull);
        expect(result!.originalAmount, equals(100.0));
        expect(result.convertedAmount, equals(85.0)); // 100 * 0.85
        expect(result.originalCurrency, equals('USD'));
        expect(result.targetCurrency, equals('EUR'));
        expect(result.exchangeRate, equals(0.85));
      });

      test('should convert EUR to USD using reverse rate', () async {
        final result = await converter.convertAmount(
          amount: 100.0,
          fromCurrency: 'EUR',
          toCurrency: 'USD',
        );
        
        expect(result, isNotNull);
        expect(result!.originalAmount, equals(100.0));
        expect(result.convertedAmount, equals(117.6)); // 100 * 1.176
        expect(result.originalCurrency, equals('EUR'));
        expect(result.targetCurrency, equals('USD'));
        expect(result.exchangeRate, equals(1.176));
      });

      test('should handle cross-currency conversion via USD', () async {
        // GBP to JPY should convert via USD: GBP -> USD -> JPY
        final result = await converter.convertAmount(
          amount: 100.0,
          fromCurrency: 'GBP',
          toCurrency: 'JPY',
        );
        
        expect(result, isNotNull);
        expect(result!.originalAmount, equals(100.0));
        expect(result.originalCurrency, equals('GBP'));
        expect(result.targetCurrency, equals('JPY'));
        // Rate should be calculated as: (1/0.73) * 110 = 150.68...
        expect(result.exchangeRate, closeTo(150.68, 0.01));
      });
    });

    group('Validation Tests', () {
      test('should reject negative amounts', () async {
        final result = await converter.convertAmount(
          amount: -100.0,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );
        
        expect(result, isNull);
      });

      test('should reject zero amounts', () async {
        final result = await converter.convertAmount(
          amount: 0.0,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );
        
        expect(result, isNull);
      });

      test('should reject invalid currencies', () async {
        final result = await converter.convertAmount(
          amount: 100.0,
          fromCurrency: 'INVALID',
          toCurrency: 'EUR',
        );
        
        expect(result, isNull);
      });

      test('should reject extremely large amounts', () async {
        final result = await converter.convertAmount(
          amount: 1e12, // 1 trillion
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );
        
        expect(result, isNull);
      });
    });

    group('Batch Conversion Tests', () {
      test('should convert multiple amounts correctly', () async {
        final results = await converter.convertBatch(
          amounts: [100.0, 200.0, 300.0],
          fromCurrencies: ['USD', 'EUR', 'USD'],
          toCurrency: 'GBP',
        );
        
        expect(results.length, equals(3));
        
        // First conversion: USD -> GBP
        expect(results[0].originalAmount, equals(100.0));
        expect(results[0].originalCurrency, equals('USD'));
        expect(results[0].targetCurrency, equals('GBP'));
        
        // Second conversion: EUR -> GBP
        expect(results[1].originalAmount, equals(200.0));
        expect(results[1].originalCurrency, equals('EUR'));
        expect(results[1].targetCurrency, equals('GBP'));
        
        // Third conversion: USD -> GBP
        expect(results[2].originalAmount, equals(300.0));
        expect(results[2].originalCurrency, equals('USD'));
        expect(results[2].targetCurrency, equals('GBP'));
      });

      test('should handle mixed success/failure in batch', () async {
        final results = await converter.convertBatch(
          amounts: [100.0, 200.0, 300.0],
          fromCurrencies: ['USD', 'INVALID', 'EUR'],
          toCurrency: 'GBP',
        );
        
        // Should only have 2 successful conversions (skipping INVALID currency)
        expect(results.length, equals(2));
        expect(results[0].originalCurrency, equals('USD'));
        expect(results[1].originalCurrency, equals('EUR'));
      });

      test('should reject mismatched array lengths', () async {
        expect(
          () => converter.convertBatch(
            amounts: [100.0, 200.0],
            fromCurrencies: ['USD'],
            toCurrency: 'EUR',
          ),
          throwsArgumentError,
        );
      });
    });

    group('Fuel Entry Conversion Tests', () {
      test('should convert fuel entries to primary currency', () async {
        final entries = [
          FuelEntryModel.create(
            vehicleId: 1,
            date: DateTime.now(),
            currentKm: 1000,
            fuelAmount: 40.0,
            price: 100.0,
            currency: 'USD',
            country: 'USA',
            pricePerLiter: 2.5,
          ),
          FuelEntryModel.create(
            vehicleId: 1,
            date: DateTime.now(),
            currentKm: 1050,
            fuelAmount: 35.0,
            price: 85.0,
            currency: 'EUR',
            country: 'Germany',
            pricePerLiter: 2.43,
          ),
        ];

        final convertedEntries = await converter.convertFuelEntriesToPrimary(
          entries,
          'USD',
        );

        expect(convertedEntries.length, equals(2));
        
        // First entry should remain unchanged (already in USD)
        expect(convertedEntries[0].currency, equals('USD'));
        expect(convertedEntries[0].price, equals(100.0));
        expect(convertedEntries[0].originalAmount, isNull);
        
        // Second entry should be converted to USD
        expect(convertedEntries[1].currency, equals('USD'));
        expect(convertedEntries[1].price, closeTo(100.0, 1.0)); // 85 * 1.176 ≈ 100
        expect(convertedEntries[1].originalAmount, equals(85.0));
      });

      test('should preserve entries when conversion fails', () async {
        final entries = [
          FuelEntryModel.create(
            vehicleId: 1,
            date: DateTime.now(),
            currentKm: 1000,
            fuelAmount: 40.0,
            price: 100.0,
            currency: 'UNKNOWN_CURRENCY',
            country: 'Unknown',
            pricePerLiter: 2.5,
          ),
        ];

        final convertedEntries = await converter.convertFuelEntriesToPrimary(
          entries,
          'USD',
        );

        expect(convertedEntries.length, equals(1));
        expect(convertedEntries[0].currency, equals('UNKNOWN_CURRENCY'));
        expect(convertedEntries[0].price, equals(100.0));
      });
    });

    group('Cache and Availability Tests', () {
      test('should check conversion availability correctly', () async {
        // Should be able to convert USD to EUR (direct rate available)
        final canConvertUsdEur = await converter.canConvert('USD', 'EUR');
        expect(canConvertUsdEur, isTrue);
        
        // Should be able to convert EUR to USD (reverse rate available)
        final canConvertEurUsd = await converter.canConvert('EUR', 'USD');
        expect(canConvertEurUsd, isTrue);
        
        // Should be able to convert same currency
        final canConvertSame = await converter.canConvert('USD', 'USD');
        expect(canConvertSame, isTrue);
        
        // Should not be able to convert unknown currency
        final canConvertUnknown = await converter.canConvert('UNKNOWN', 'USD');
        expect(canConvertUnknown, isFalse);
      });

      test('should get available rates for a currency', () async {
        final rates = await converter.getAvailableRates('USD');
        
        expect(rates, isNotNull);
        expect(rates.containsKey('EUR'), isTrue);
        expect(rates.containsKey('GBP'), isTrue);
        expect(rates.containsKey('JPY'), isTrue);
        expect(rates['EUR'], equals(0.85));
      });

      test('should get cache statistics', () async {
        // Trigger some conversions to populate cache
        await converter.convertAmount(amount: 100, fromCurrency: 'USD', toCurrency: 'EUR');
        await converter.convertAmount(amount: 100, fromCurrency: 'EUR', toCurrency: 'USD');
        
        final stats = await converter.getCacheStats();
        
        expect(stats, isNotNull);
        expect(stats.containsKey('memory_cached_currencies'), isTrue);
        expect(stats.containsKey('memory_cache_size'), isTrue);
        expect(stats.containsKey('persistent_cache_keys'), isTrue);
        
        final memoryCurrencies = stats['memory_cached_currencies'] as List;
        expect(memoryCurrencies.length, greaterThan(0));
      });
    });

    group('Error Handling Tests', () {
      test('should handle missing exchange rates gracefully', () async {
        // Try to convert to a currency with no cached rates
        final result = await converter.convertAmount(
          amount: 100.0,
          fromCurrency: 'USD',
          toCurrency: 'ZZZ', // Non-existent currency
        );
        
        expect(result, isNull);
      });

      test('should handle corrupted cache data', () async {
        // Corrupt the cache with invalid JSON
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currency_rates_CORRUPT', 'invalid json data');
        
        final result = await converter.convertAmount(
          amount: 100.0,
          fromCurrency: 'CORRUPT',
          toCurrency: 'USD',
        );
        
        expect(result, isNull);
      });

      test('should validate exchange rate sanity', () async {
        // Test ConversionValidator directly
        final validResult = ConversionValidator.validateConversion(
          amount: 100.0,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );
        expect(validResult.isValid, isTrue);
        
        final invalidAmount = ConversionValidator.validateConversion(
          amount: -100.0,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );
        expect(invalidAmount.isValid, isFalse);
        expect(invalidAmount.errorMessage, contains('positive'));
        
        final invalidCurrency = ConversionValidator.validateConversion(
          amount: 100.0,
          fromCurrency: 'INVALID',
          toCurrency: 'EUR',
        );
        expect(invalidCurrency.isValid, isFalse);
        expect(invalidCurrency.errorMessage, contains('Invalid source currency'));
      });
    });

    group('Performance Tests', () {
      test('should handle large batch conversions efficiently', () async {
        final amounts = List.generate(50, (i) => (i + 1) * 10.0);
        final currencies = List.generate(50, (i) => i.isEven ? 'USD' : 'EUR');
        
        final stopwatch = Stopwatch()..start();
        
        final results = await converter.convertBatch(
          amounts: amounts,
          fromCurrencies: currencies,
          toCurrency: 'GBP',
        );
        
        stopwatch.stop();
        
        expect(results.length, greaterThan(0));
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Should complete in under 5 seconds
      });
    });
  });
}