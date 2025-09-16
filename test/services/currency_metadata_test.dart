import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/services/currency_metadata.dart';
import 'package:petrol_tracker/models/currency_info.dart';

void main() {
  group('CurrencyMetadata Tests', () {
    
    group('Currency Information Retrieval', () {
      test('should return comprehensive currency information for major currencies', () {
        // Test USD
        final usdInfo = CurrencyMetadata.getCurrencyInfo('USD');
        expect(usdInfo, isNotNull);
        expect(usdInfo!.code, equals('USD'));
        expect(usdInfo.name, equals('US Dollar'));
        expect(usdInfo.symbol, equals('\$'));
        expect(usdInfo.decimalPlaces, equals(2));
        expect(usdInfo.countries, contains('United States'));
        expect(usdInfo.isInternational, isTrue);
        
        // Test EUR
        final eurInfo = CurrencyMetadata.getCurrencyInfo('EUR');
        expect(eurInfo, isNotNull);
        expect(eurInfo!.code, equals('EUR'));
        expect(eurInfo.name, equals('Euro'));
        expect(eurInfo.symbol, equals('€'));
        expect(eurInfo.decimalPlaces, equals(2));
        expect(eurInfo.countries, contains('Germany'));
        expect(eurInfo.countries, contains('France'));
        expect(eurInfo.countries, contains('Italy'));
        expect(eurInfo.isInternational, isTrue);
        
        // Test JPY (zero decimal places)
        final jpyInfo = CurrencyMetadata.getCurrencyInfo('JPY');
        expect(jpyInfo, isNotNull);
        expect(jpyInfo!.code, equals('JPY'));
        expect(jpyInfo.name, equals('Japanese Yen'));
        expect(jpyInfo.symbol, equals('¥'));
        expect(jpyInfo.decimalPlaces, equals(0));
        expect(jpyInfo.countries, contains('Japan'));
        expect(jpyInfo.isInternational, isTrue);
      });
      
      test('should return null for unknown currency codes', () {
        final unknownInfo = CurrencyMetadata.getCurrencyInfo('UNKNOWN');
        expect(unknownInfo, isNull);
        
        final emptyInfo = CurrencyMetadata.getCurrencyInfo('');
        expect(emptyInfo, isNull);
      });
      
      test('should handle case-insensitive currency codes', () {
        final usdUpper = CurrencyMetadata.getCurrencyInfo('USD');
        final usdLower = CurrencyMetadata.getCurrencyInfo('usd');
        final usdMixed = CurrencyMetadata.getCurrencyInfo('UsD');
        
        expect(usdUpper, isNotNull);
        expect(usdLower, isNotNull);
        expect(usdMixed, isNotNull);
        expect(usdUpper, equals(usdLower));
        expect(usdLower, equals(usdMixed));
      });
    });

    group('Currency Categorization', () {
      test('should correctly identify international currencies', () {
        final internationalCurrencies = CurrencyMetadata.getInternationalCurrencies();
        
        expect(internationalCurrencies, isNotEmpty);
        expect(internationalCurrencies, contains('USD'));
        expect(internationalCurrencies, contains('EUR'));
        expect(internationalCurrencies, contains('GBP'));
        expect(internationalCurrencies, contains('JPY'));
        expect(internationalCurrencies, contains('CNY'));
        
        // List should be sorted
        final sortedList = List<String>.from(internationalCurrencies)..sort();
        expect(internationalCurrencies, equals(sortedList));
      });
      
      test('should correctly identify zero decimal currencies', () {
        final zeroDecimalCurrencies = CurrencyMetadata.getZeroDecimalCurrencies();
        
        expect(zeroDecimalCurrencies, contains('JPY'));
        expect(zeroDecimalCurrencies, contains('KRW'));
        expect(zeroDecimalCurrencies, contains('VND'));
        expect(zeroDecimalCurrencies, contains('CLP'));
        
        // Verify these currencies actually have 0 decimal places
        for (final currency in zeroDecimalCurrencies) {
          final info = CurrencyMetadata.getCurrencyInfo(currency);
          expect(info, isNotNull);
          expect(info!.decimalPlaces, equals(0));
        }
      });
      
      test('should provide comprehensive list of supported currencies', () {
        final supportedCurrencies = CurrencyMetadata.getSupportedCurrencies();
        
        expect(supportedCurrencies.isNotEmpty, isTrue);
        expect(supportedCurrencies.length, greaterThan(30)); // Should support many currencies
        
        // Major currencies should be included
        expect(supportedCurrencies, contains('USD'));
        expect(supportedCurrencies, contains('EUR'));
        expect(supportedCurrencies, contains('GBP'));
        expect(supportedCurrencies, contains('JPY'));
        expect(supportedCurrencies, contains('CHF'));
        expect(supportedCurrencies, contains('CAD'));
        expect(supportedCurrencies, contains('AUD'));
        expect(supportedCurrencies, contains('CNY'));
        expect(supportedCurrencies, contains('INR'));
        expect(supportedCurrencies, contains('BRL'));
        
        // List should be sorted
        final sortedList = List<String>.from(supportedCurrencies)..sort();
        expect(supportedCurrencies, equals(sortedList));
      });
    });

    group('Regional Currency Groups', () {
      test('should return currencies by European region', () {
        final europeanCurrencies = CurrencyMetadata.getCurrenciesByRegion(CurrencyRegion.europe);
        
        expect(europeanCurrencies, contains('EUR'));
        expect(europeanCurrencies, contains('CHF'));
        expect(europeanCurrencies, contains('GBP'));
        expect(europeanCurrencies, contains('NOK'));
        expect(europeanCurrencies, contains('SEK'));
        expect(europeanCurrencies, contains('DKK'));
        expect(europeanCurrencies, contains('PLN'));
        expect(europeanCurrencies, contains('CZK'));
        expect(europeanCurrencies, contains('HUF'));
      });
      
      test('should return currencies by North American region', () {
        final northAmericanCurrencies = CurrencyMetadata.getCurrenciesByRegion(CurrencyRegion.northAmerica);
        
        expect(northAmericanCurrencies, contains('USD'));
        expect(northAmericanCurrencies, contains('CAD'));
        expect(northAmericanCurrencies, contains('MXN'));
      });
      
      test('should return currencies by Asia Pacific region', () {
        final asiaPacificCurrencies = CurrencyMetadata.getCurrenciesByRegion(CurrencyRegion.asiaPacific);
        
        expect(asiaPacificCurrencies, contains('JPY'));
        expect(asiaPacificCurrencies, contains('KRW'));
        expect(asiaPacificCurrencies, contains('CNY'));
        expect(asiaPacificCurrencies, contains('INR'));
        expect(asiaPacificCurrencies, contains('SGD'));
        expect(asiaPacificCurrencies, contains('HKD'));
        expect(asiaPacificCurrencies, contains('THB'));
      });
      
      test('should return currencies by other regions', () {
        final bricsCurrencies = CurrencyMetadata.getCurrenciesByRegion(CurrencyRegion.brics);
        expect(bricsCurrencies, contains('BRL'));
        expect(bricsCurrencies, contains('RUB'));
        expect(bricsCurrencies, contains('INR'));
        expect(bricsCurrencies, contains('CNY'));
        expect(bricsCurrencies, contains('ZAR'));
        
        final oceaniaCurrencies = CurrencyMetadata.getCurrenciesByRegion(CurrencyRegion.oceania);
        expect(oceaniaCurrencies, contains('AUD'));
        expect(oceaniaCurrencies, contains('NZD'));
      });
      
      test('should return empty list for unknown region', () {
        // This is not possible with the current enum, but testing the implementation
        final unknownCurrencies = CurrencyMetadata.getCurrenciesByRegion(CurrencyRegion.africa);
        expect(unknownCurrencies, isA<List<String>>());
      });
    });

    group('Currency Validation', () {
      test('should correctly validate supported currencies', () {
        expect(CurrencyMetadata.isSupportedCurrency('USD'), isTrue);
        expect(CurrencyMetadata.isSupportedCurrency('EUR'), isTrue);
        expect(CurrencyMetadata.isSupportedCurrency('GBP'), isTrue);
        expect(CurrencyMetadata.isSupportedCurrency('JPY'), isTrue);
        expect(CurrencyMetadata.isSupportedCurrency('CHF'), isTrue);
        expect(CurrencyMetadata.isSupportedCurrency('CAD'), isTrue);
        expect(CurrencyMetadata.isSupportedCurrency('AUD'), isTrue);
        expect(CurrencyMetadata.isSupportedCurrency('CNY'), isTrue);
        expect(CurrencyMetadata.isSupportedCurrency('INR'), isTrue);
        expect(CurrencyMetadata.isSupportedCurrency('BRL'), isTrue);
      });
      
      test('should correctly reject unsupported currencies', () {
        expect(CurrencyMetadata.isSupportedCurrency('UNKNOWN'), isFalse);
        expect(CurrencyMetadata.isSupportedCurrency(''), isFalse);
        expect(CurrencyMetadata.isSupportedCurrency('XYZ'), isFalse);
        expect(CurrencyMetadata.isSupportedCurrency('123'), isFalse);
      });
      
      test('should handle case-insensitive validation', () {
        expect(CurrencyMetadata.isSupportedCurrency('USD'), isTrue);
        expect(CurrencyMetadata.isSupportedCurrency('usd'), isTrue);
        expect(CurrencyMetadata.isSupportedCurrency('UsD'), isTrue);
      });
    });

    group('Currency Properties and Metadata', () {
      test('should have correct decimal places for various currencies', () {
        // Standard 2-decimal currencies
        expect(CurrencyMetadata.getCurrencyInfo('USD')?.decimalPlaces, equals(2));
        expect(CurrencyMetadata.getCurrencyInfo('EUR')?.decimalPlaces, equals(2));
        expect(CurrencyMetadata.getCurrencyInfo('GBP')?.decimalPlaces, equals(2));
        expect(CurrencyMetadata.getCurrencyInfo('CHF')?.decimalPlaces, equals(2));
        
        // Zero-decimal currencies
        expect(CurrencyMetadata.getCurrencyInfo('JPY')?.decimalPlaces, equals(0));
        expect(CurrencyMetadata.getCurrencyInfo('KRW')?.decimalPlaces, equals(0));
        expect(CurrencyMetadata.getCurrencyInfo('VND')?.decimalPlaces, equals(0));
      });
      
      test('should have correct symbols for major currencies', () {
        expect(CurrencyMetadata.getCurrencyInfo('USD')?.symbol, equals('\$'));
        expect(CurrencyMetadata.getCurrencyInfo('EUR')?.symbol, equals('€'));
        expect(CurrencyMetadata.getCurrencyInfo('GBP')?.symbol, equals('£'));
        expect(CurrencyMetadata.getCurrencyInfo('JPY')?.symbol, equals('¥'));
        expect(CurrencyMetadata.getCurrencyInfo('CHF')?.symbol, equals('CHF'));
        expect(CurrencyMetadata.getCurrencyInfo('CAD')?.symbol, equals('C\$'));
        expect(CurrencyMetadata.getCurrencyInfo('CNY')?.symbol, equals('¥'));
      });
      
      test('should have alternative symbols where appropriate', () {
        final usdInfo = CurrencyMetadata.getCurrencyInfo('USD');
        expect(usdInfo?.alternativeSymbols, contains('US\$'));
        
        final eurInfo = CurrencyMetadata.getCurrencyInfo('EUR');
        expect(eurInfo?.alternativeSymbols, contains('EUR'));
        
        final chfInfo = CurrencyMetadata.getCurrencyInfo('CHF');
        expect(chfInfo?.alternativeSymbols, contains('Fr.'));
        expect(chfInfo?.alternativeSymbols, contains('SFr.'));
      });
      
      test('should have comprehensive country associations', () {
        // USD should be associated with United States
        final usdInfo = CurrencyMetadata.getCurrencyInfo('USD');
        expect(usdInfo?.countries, contains('United States'));
        
        // EUR should be associated with multiple Eurozone countries
        final eurInfo = CurrencyMetadata.getCurrencyInfo('EUR');
        expect(eurInfo?.countries, contains('Germany'));
        expect(eurInfo?.countries, contains('France'));
        expect(eurInfo?.countries, contains('Italy'));
        expect(eurInfo?.countries, contains('Spain'));
        expect(eurInfo?.countries?.length, greaterThan(10)); // Many Eurozone countries
        
        // CHF should be associated with Switzerland and Liechtenstein
        final chfInfo = CurrencyMetadata.getCurrencyInfo('CHF');
        expect(chfInfo?.countries, contains('Switzerland'));
        expect(chfInfo?.countries, contains('Liechtenstein'));
      });
      
      test('should have appropriate notes for special currencies', () {
        final usdInfo = CurrencyMetadata.getCurrencyInfo('USD');
        expect(usdInfo?.notes, isNotNull);
        expect(usdInfo!.notes!, contains('international'));
        
        final chfInfo = CurrencyMetadata.getCurrencyInfo('CHF');
        expect(chfInfo?.notes, isNotNull);
        expect(chfInfo!.notes!, contains('stability'));
        
        final jpyInfo = CurrencyMetadata.getCurrencyInfo('JPY');
        expect(jpyInfo?.notes, isNotNull);
        expect(jpyInfo!.notes!, contains('decimal'));
      });
    });

    group('Data Consistency', () {
      test('should have consistent international currency flags', () {
        final internationalCurrencies = CurrencyMetadata.getInternationalCurrencies();
        
        for (final currency in internationalCurrencies) {
          final info = CurrencyMetadata.getCurrencyInfo(currency);
          expect(info, isNotNull);
          expect(info!.isInternational, isTrue,
              reason: '$currency should be marked as international');
        }
      });
      
      test('should have valid currency codes', () {
        final supportedCurrencies = CurrencyMetadata.getSupportedCurrencies();
        
        for (final currency in supportedCurrencies) {
          // Currency codes should be 3 characters
          expect(currency.length, equals(3),
              reason: '$currency should be 3 characters long');
          
          // Currency codes should be uppercase
          expect(currency, equals(currency.toUpperCase()),
              reason: '$currency should be uppercase');
          
          // Should be able to retrieve info for each supported currency
          final info = CurrencyMetadata.getCurrencyInfo(currency);
          expect(info, isNotNull,
              reason: 'Should have info for supported currency $currency');
        }
      });
      
      test('should have consistent country associations', () {
        final supportedCurrencies = CurrencyMetadata.getSupportedCurrencies();
        
        for (final currency in supportedCurrencies) {
          final info = CurrencyMetadata.getCurrencyInfo(currency);
          expect(info, isNotNull);
          expect(info!.countries, isNotEmpty,
              reason: '$currency should be associated with at least one country');
          
          // All country names should be non-empty strings
          for (final country in info.countries) {
            expect(country.trim(), isNotEmpty,
                reason: 'Country name should not be empty for $currency');
          }
        }
      });
    });

    group('Performance', () {
      test('should handle rapid currency info lookups efficiently', () {
        final supportedCurrencies = CurrencyMetadata.getSupportedCurrencies();
        final stopwatch = Stopwatch()..start();
        
        // Perform 1000 lookups
        for (int i = 0; i < 1000; i++) {
          final currency = supportedCurrencies[i % supportedCurrencies.length];
          final info = CurrencyMetadata.getCurrencyInfo(currency);
          expect(info, isNotNull);
        }
        
        stopwatch.stop();
        
        // Should complete in reasonable time (under 100ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });
  });
}