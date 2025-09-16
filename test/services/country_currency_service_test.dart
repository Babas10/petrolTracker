import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/services/country_currency_service.dart';
import 'package:petrol_tracker/models/currency_info.dart';

void main() {
  group('CountryCurrencyService Tests', () {
    
    group('Primary Currency Mapping', () {
      test('should return correct primary currency for major countries', () {
        // European countries
        expect(CountryCurrencyService.getPrimaryCurrency('Germany'), equals('EUR'));
        expect(CountryCurrencyService.getPrimaryCurrency('France'), equals('EUR'));
        expect(CountryCurrencyService.getPrimaryCurrency('Switzerland'), equals('CHF'));
        expect(CountryCurrencyService.getPrimaryCurrency('United Kingdom'), equals('GBP'));
        expect(CountryCurrencyService.getPrimaryCurrency('Norway'), equals('NOK'));
        
        // North American countries
        expect(CountryCurrencyService.getPrimaryCurrency('United States'), equals('USD'));
        expect(CountryCurrencyService.getPrimaryCurrency('Canada'), equals('CAD'));
        expect(CountryCurrencyService.getPrimaryCurrency('Mexico'), equals('MXN'));
        
        // Asian countries
        expect(CountryCurrencyService.getPrimaryCurrency('Japan'), equals('JPY'));
        expect(CountryCurrencyService.getPrimaryCurrency('China'), equals('CNY'));
        expect(CountryCurrencyService.getPrimaryCurrency('India'), equals('INR'));
        expect(CountryCurrencyService.getPrimaryCurrency('Singapore'), equals('SGD'));
        
        // Other major countries
        expect(CountryCurrencyService.getPrimaryCurrency('Australia'), equals('AUD'));
        expect(CountryCurrencyService.getPrimaryCurrency('Brazil'), equals('BRL'));
        expect(CountryCurrencyService.getPrimaryCurrency('Russia'), equals('RUB'));
        expect(CountryCurrencyService.getPrimaryCurrency('South Africa'), equals('ZAR'));
      });
      
      test('should return null for unknown countries', () {
        expect(CountryCurrencyService.getPrimaryCurrency('Unknown Country'), isNull);
        expect(CountryCurrencyService.getPrimaryCurrency(''), isNull);
        expect(CountryCurrencyService.getPrimaryCurrency('NonExistentCountry'), isNull);
      });
      
      test('should handle countries that use USD', () {
        expect(CountryCurrencyService.getPrimaryCurrency('Ecuador'), equals('USD'));
        expect(CountryCurrencyService.getPrimaryCurrency('Panama'), equals('USD'));
      });
    });

    group('Multi-Currency Countries', () {
      test('should correctly identify multi-currency countries', () {
        expect(CountryCurrencyService.isMultiCurrencyCountry('Switzerland'), isTrue);
        expect(CountryCurrencyService.isMultiCurrencyCountry('United Kingdom'), isTrue);
        expect(CountryCurrencyService.isMultiCurrencyCountry('Canada'), isTrue);
        expect(CountryCurrencyService.isMultiCurrencyCountry('Mexico'), isTrue);
        expect(CountryCurrencyService.isMultiCurrencyCountry('Hong Kong'), isTrue);
        expect(CountryCurrencyService.isMultiCurrencyCountry('Singapore'), isTrue);
        expect(CountryCurrencyService.isMultiCurrencyCountry('United Arab Emirates'), isTrue);
      });
      
      test('should correctly identify single-currency countries', () {
        expect(CountryCurrencyService.isMultiCurrencyCountry('Germany'), isFalse);
        expect(CountryCurrencyService.isMultiCurrencyCountry('France'), isFalse);
        expect(CountryCurrencyService.isMultiCurrencyCountry('Japan'), isFalse);
        expect(CountryCurrencyService.isMultiCurrencyCountry('Brazil'), isFalse);
      });
      
      test('should return all currencies for multi-currency countries', () {
        final switzerlandCurrencies = CountryCurrencyService.getAllCountryCurrencies('Switzerland');
        expect(switzerlandCurrencies, contains('CHF'));
        expect(switzerlandCurrencies, contains('EUR'));
        expect(switzerlandCurrencies.length, greaterThanOrEqualTo(2));
        
        final canadaCurrencies = CountryCurrencyService.getAllCountryCurrencies('Canada');
        expect(canadaCurrencies, contains('CAD'));
        expect(canadaCurrencies, contains('USD'));
        
        final hongKongCurrencies = CountryCurrencyService.getAllCountryCurrencies('Hong Kong');
        expect(hongKongCurrencies, contains('HKD'));
        expect(hongKongCurrencies, contains('USD'));
        expect(hongKongCurrencies, contains('CNY'));
      });
    });

    group('Filtered Currency Suggestions', () {
      test('should prioritize primary currency first', () {
        final currencies = CountryCurrencyService.getFilteredCurrencies('Germany', 'USD');
        
        expect(currencies.isNotEmpty, isTrue);
        expect(currencies.first, equals('EUR')); // Germany's primary currency
        expect(currencies, contains('USD')); // User's default currency
      });
      
      test('should include user default currency', () {
        final currencies = CountryCurrencyService.getFilteredCurrencies('France', 'JPY');
        
        expect(currencies, contains('EUR')); // France's primary currency
        expect(currencies, contains('JPY')); // User's default currency
      });
      
      test('should handle multi-currency countries properly', () {
        final currencies = CountryCurrencyService.getFilteredCurrencies('Switzerland', 'USD');
        
        expect(currencies.first, equals('CHF')); // Primary currency first
        expect(currencies, contains('EUR')); // Multi-currency option
        expect(currencies, contains('USD')); // User's default currency
      });
      
      test('should respect maxSuggestions limit', () {
        final currencies = CountryCurrencyService.getFilteredCurrencies(
          'United States',
          'EUR',
          maxSuggestions: 5,
        );
        
        expect(currencies.length, lessThanOrEqualTo(5));
        expect(currencies, contains('USD')); // Primary currency
        expect(currencies, contains('EUR')); // User default
      });
      
      test('should include regional currencies when enabled', () {
        final currencies = CountryCurrencyService.getFilteredCurrencies(
          'Germany',
          'USD',
          includeRegionalCurrencies: true,
        );
        
        expect(currencies, contains('EUR')); // Primary
        expect(currencies, contains('USD')); // User default
        expect(currencies.length, greaterThan(2)); // Should include regional currencies
      });
      
      test('should not include regional currencies when disabled', () {
        final currencies = CountryCurrencyService.getFilteredCurrencies(
          'Germany',
          'USD',
          includeRegionalCurrencies: false,
          maxSuggestions: 3,
        );
        
        expect(currencies, contains('EUR')); // Primary
        expect(currencies, contains('USD')); // User default
        // Length depends on multi-currency support, but should be limited
        expect(currencies.length, lessThanOrEqualTo(3));
      });
      
      test('should handle empty user default currency gracefully', () {
        final currencies = CountryCurrencyService.getFilteredCurrencies('Japan', '');
        
        expect(currencies, contains('JPY')); // Japan's primary currency
        expect(currencies.isNotEmpty, isTrue);
      });
      
      test('should handle unknown countries gracefully', () {
        final currencies = CountryCurrencyService.getFilteredCurrencies('Unknown Country', 'USD');
        
        expect(currencies, isNotEmpty); // Should return fallback
        expect(currencies, contains('USD')); // Should include user default as fallback
      });
    });

    group('Country Lookup Functions', () {
      test('should find countries that use specific currencies', () {
        final eurCountries = CountryCurrencyService.getCountriesForCurrency('EUR');
        
        expect(eurCountries, contains('Germany'));
        expect(eurCountries, contains('France'));
        expect(eurCountries, contains('Italy'));
        expect(eurCountries, contains('Spain'));
        expect(eurCountries.length, greaterThan(15)); // Many Eurozone countries
        
        // Check that list is sorted
        final sortedCountries = List<String>.from(eurCountries)..sort();
        expect(eurCountries, equals(sortedCountries));
      });
      
      test('should find countries for other major currencies', () {
        final usdCountries = CountryCurrencyService.getCountriesForCurrency('USD');
        expect(usdCountries, contains('United States'));
        expect(usdCountries, contains('Ecuador'));
        expect(usdCountries, contains('Panama'));
        
        final gbpCountries = CountryCurrencyService.getCountriesForCurrency('GBP');
        expect(gbpCountries, contains('United Kingdom'));
        
        final jpyCountries = CountryCurrencyService.getCountriesForCurrency('JPY');
        expect(jpyCountries, contains('Japan'));
      });
      
      test('should return empty list for unknown currencies', () {
        final unknownCurrencyCountries = CountryCurrencyService.getCountriesForCurrency('UNKNOWN');
        expect(unknownCurrencyCountries, isEmpty);
      });
    });

    group('Supported Countries', () {
      test('should return comprehensive list of supported countries', () {
        final supportedCountries = CountryCurrencyService.getSupportedCountries();
        
        expect(supportedCountries.isNotEmpty, isTrue);
        expect(supportedCountries.length, greaterThan(50)); // Should support many countries
        
        // Check major countries are included
        expect(supportedCountries, contains('United States'));
        expect(supportedCountries, contains('Germany'));
        expect(supportedCountries, contains('Japan'));
        expect(supportedCountries, contains('United Kingdom'));
        expect(supportedCountries, contains('China'));
        expect(supportedCountries, contains('Brazil'));
        expect(supportedCountries, contains('Australia'));
        
        // Check that list is sorted
        final sortedCountries = List<String>.from(supportedCountries)..sort();
        expect(supportedCountries, equals(sortedCountries));
      });
      
      test('should correctly identify supported countries', () {
        expect(CountryCurrencyService.isSupportedCountry('Germany'), isTrue);
        expect(CountryCurrencyService.isSupportedCountry('United States'), isTrue);
        expect(CountryCurrencyService.isSupportedCountry('Japan'), isTrue);
        expect(CountryCurrencyService.isSupportedCountry('Switzerland'), isTrue);
        
        expect(CountryCurrencyService.isSupportedCountry('Unknown Country'), isFalse);
        expect(CountryCurrencyService.isSupportedCountry(''), isFalse);
        expect(CountryCurrencyService.isSupportedCountry('NonExistent'), isFalse);
      });
    });

    group('Currency Information Integration', () {
      test('should return currency information when available', () {
        final usdInfo = CountryCurrencyService.getCurrencyInfo('USD');
        expect(usdInfo, isNotNull);
        expect(usdInfo!.code, equals('USD'));
        expect(usdInfo.name, contains('Dollar'));
        expect(usdInfo.symbol, equals('\$'));
        
        final eurInfo = CountryCurrencyService.getCurrencyInfo('EUR');
        expect(eurInfo, isNotNull);
        expect(eurInfo!.code, equals('EUR'));
        expect(eurInfo.name, equals('Euro'));
        expect(eurInfo.symbol, equals('€'));
      });
      
      test('should return null for unknown currency codes', () {
        final unknownInfo = CountryCurrencyService.getCurrencyInfo('UNKNOWN');
        expect(unknownInfo, isNull);
      });
    });

    group('Detailed Currency Suggestions', () {
      test('should provide detailed suggestions with reasoning', () {
        final suggestions = CountryCurrencyService.getDetailedCurrencySuggestions(
          'Switzerland',
          'USD',
        );
        
        expect(suggestions.isNotEmpty, isTrue);
        
        // Check that all suggestions have required properties
        for (final suggestion in suggestions) {
          expect(suggestion.currencyCode, isNotEmpty);
          expect(suggestion.reason, isA<CurrencySuggestionReason>());
          expect(suggestion.countryName, equals('Switzerland'));
          expect(suggestion.reasonDescription, isNotEmpty);
        }
        
        // Check that primary currency suggestion exists
        final primarySuggestion = suggestions.firstWhere(
          (s) => s.reason == CurrencySuggestionReason.primaryCurrency,
          orElse: () => throw StateError('Primary currency suggestion not found'),
        );
        expect(primarySuggestion.currencyCode, equals('CHF'));
        
        // Check that user default suggestion exists
        final userDefaultSuggestion = suggestions.firstWhere(
          (s) => s.reason == CurrencySuggestionReason.userDefault,
          orElse: () => throw StateError('User default suggestion not found'),
        );
        expect(userDefaultSuggestion.currencyCode, equals('USD'));
      });
      
      test('should respect maxSuggestions for detailed suggestions', () {
        final suggestions = CountryCurrencyService.getDetailedCurrencySuggestions(
          'Germany',
          'USD',
          maxSuggestions: 3,
        );
        
        expect(suggestions.length, lessThanOrEqualTo(3));
      });
      
      test('should handle unknown countries in detailed suggestions', () {
        final suggestions = CountryCurrencyService.getDetailedCurrencySuggestions(
          'Unknown Country',
          'USD',
        );
        
        expect(suggestions.isNotEmpty, isTrue);
        
        // Should include user default currency suggestion
        final userDefaultSuggestion = suggestions.where(
          (s) => s.reason == CurrencySuggestionReason.userDefault && s.currencyCode == 'USD',
        );
        expect(userDefaultSuggestion.isNotEmpty, isTrue);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle null and empty inputs gracefully', () {
        // Empty country name
        final emptyCountryCurrencies = CountryCurrencyService.getFilteredCurrencies('', 'USD');
        expect(emptyCountryCurrencies, isNotEmpty); // Should return fallback
        
        // Empty user default currency
        final emptyUserCurrencies = CountryCurrencyService.getFilteredCurrencies('Germany', '');
        expect(emptyUserCurrencies, contains('EUR')); // Should include primary currency
      });
      
      test('should handle case sensitivity appropriately', () {
        // Currency lookup should be case-insensitive
        final usdInfo1 = CountryCurrencyService.getCurrencyInfo('USD');
        final usdInfo2 = CountryCurrencyService.getCurrencyInfo('usd');
        expect(usdInfo1, equals(usdInfo2));
      });
      
      test('should maintain consistency in currency ordering', () {
        final currencies1 = CountryCurrencyService.getFilteredCurrencies('Germany', 'USD');
        final currencies2 = CountryCurrencyService.getFilteredCurrencies('Germany', 'USD');
        
        // Results should be consistent across calls
        expect(currencies1, equals(currencies2));
      });
    });
    
    group('Performance and Scalability', () {
      test('should handle multiple rapid calls efficiently', () {
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 100; i++) {
          CountryCurrencyService.getFilteredCurrencies('Germany', 'USD');
          CountryCurrencyService.getPrimaryCurrency('France');
          CountryCurrencyService.isMultiCurrencyCountry('Switzerland');
        }
        
        stopwatch.stop();
        
        // Should complete 300 operations in reasonable time (under 1 second)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}