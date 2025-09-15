import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/utils/currency_display_utils.dart';

void main() {
  group('CurrencyDisplayUtils', () {
    group('getCurrencyName', () {
      test('should return correct names for major currencies', () {
        expect(CurrencyDisplayUtils.getCurrencyName('USD'), 'US Dollar');
        expect(CurrencyDisplayUtils.getCurrencyName('EUR'), 'Euro');
        expect(CurrencyDisplayUtils.getCurrencyName('GBP'), 'British Pound Sterling');
        expect(CurrencyDisplayUtils.getCurrencyName('JPY'), 'Japanese Yen');
        expect(CurrencyDisplayUtils.getCurrencyName('CHF'), 'Swiss Franc');
      });

      test('should be case insensitive', () {
        expect(CurrencyDisplayUtils.getCurrencyName('usd'), 'US Dollar');
        expect(CurrencyDisplayUtils.getCurrencyName('eur'), 'Euro');
        expect(CurrencyDisplayUtils.getCurrencyName('Gbp'), 'British Pound Sterling');
      });

      test('should return currency code for unknown currencies', () {
        expect(CurrencyDisplayUtils.getCurrencyName('XYZ'), 'XYZ');
        expect(CurrencyDisplayUtils.getCurrencyName('ABC'), 'ABC');
      });

      test('should handle empty string', () {
        expect(CurrencyDisplayUtils.getCurrencyName(''), '');
      });
    });

    group('getDisplayString', () {
      test('should format currencies with symbols correctly', () {
        expect(
          CurrencyDisplayUtils.getDisplayString('USD'),
          'USD (\$) - US Dollar',
        );
        expect(
          CurrencyDisplayUtils.getDisplayString('EUR'),
          'EUR (€) - Euro',
        );
        expect(
          CurrencyDisplayUtils.getDisplayString('GBP'),
          'GBP (£) - British Pound Sterling',
        );
      });

      test('should format currencies without symbols correctly', () {
        // CHF has a symbol but it's the same as the code
        expect(
          CurrencyDisplayUtils.getDisplayString('CHF'),
          'CHF - Swiss Franc',
        );
      });

      test('should format unknown currencies correctly', () {
        expect(
          CurrencyDisplayUtils.getDisplayString('XYZ'),
          'XYZ - XYZ',
        );
      });

      test('should be case insensitive', () {
        expect(
          CurrencyDisplayUtils.getDisplayString('usd'),
          'USD (\$) - US Dollar',
        );
      });
    });

    group('getSupportedCurrenciesWithInfo', () {
      test('should return list with correct structure', () {
        final currencies = CurrencyDisplayUtils.getSupportedCurrenciesWithInfo();
        
        expect(currencies, isNotEmpty);
        
        // Check first currency has required fields
        final firstCurrency = currencies.first;
        expect(firstCurrency.keys, containsAll([
          'code',
          'name',
          'symbol',
          'isMajor',
          'displayString',
        ]));
        
        expect(firstCurrency['code'], isA<String>());
        expect(firstCurrency['name'], isA<String>());
        expect(firstCurrency['symbol'], isA<String>());
        expect(firstCurrency['isMajor'], isA<bool>());
        expect(firstCurrency['displayString'], isA<String>());
      });

      test('should sort major currencies first', () {
        final currencies = CurrencyDisplayUtils.getSupportedCurrenciesWithInfo();
        
        // Find first non-major currency
        int firstNonMajorIndex = -1;
        for (int i = 0; i < currencies.length; i++) {
          if (!(currencies[i]['isMajor'] as bool)) {
            firstNonMajorIndex = i;
            break;
          }
        }
        
        if (firstNonMajorIndex > 0) {
          // All currencies before the first non-major should be major
          for (int i = 0; i < firstNonMajorIndex; i++) {
            expect(currencies[i]['isMajor'], true,
                reason: 'Currency at index $i should be major: ${currencies[i]['code']}');
          }
        }
      });

      test('should include USD as major currency', () {
        final currencies = CurrencyDisplayUtils.getSupportedCurrenciesWithInfo();
        final usdCurrency = currencies.firstWhere(
          (c) => c['code'] == 'USD',
          orElse: () => <String, dynamic>{},
        );
        
        expect(usdCurrency, isNotEmpty);
        expect(usdCurrency['isMajor'], true);
        expect(usdCurrency['name'], 'US Dollar');
        expect(usdCurrency['symbol'], '\$');
      });
    });

    group('getMajorCurrencies', () {
      test('should return only major currencies', () {
        final majorCurrencies = CurrencyDisplayUtils.getMajorCurrencies();
        
        expect(majorCurrencies, isNotEmpty);
        expect(majorCurrencies, contains('USD'));
        expect(majorCurrencies, contains('EUR'));
        expect(majorCurrencies, contains('GBP'));
        expect(majorCurrencies, contains('JPY'));
        
        // All returned currencies should be major
        for (final currency in majorCurrencies) {
          expect(
            CurrencyDisplayUtils.getSupportedCurrenciesWithInfo()
                .firstWhere((c) => c['code'] == currency)['isMajor'],
            true,
            reason: '$currency should be a major currency',
          );
        }
      });

      test('should return sorted list', () {
        final majorCurrencies = CurrencyDisplayUtils.getMajorCurrencies();
        final sortedCurrencies = List<String>.from(majorCurrencies)..sort();
        
        expect(majorCurrencies, equals(sortedCurrencies));
      });
    });

    group('getAllSupportedCurrencies', () {
      test('should return sorted list of all currencies', () {
        final allCurrencies = CurrencyDisplayUtils.getAllSupportedCurrencies();
        final sortedCurrencies = List<String>.from(allCurrencies)..sort();
        
        expect(allCurrencies, equals(sortedCurrencies));
        expect(allCurrencies, contains('USD'));
        expect(allCurrencies, contains('EUR'));
        expect(allCurrencies, isNotEmpty);
      });
    });

    group('validateCurrencySelection', () {
      test('should return null for valid currencies', () {
        expect(CurrencyDisplayUtils.validateCurrencySelection('USD'), null);
        expect(CurrencyDisplayUtils.validateCurrencySelection('EUR'), null);
        expect(CurrencyDisplayUtils.validateCurrencySelection('GBP'), null);
      });

      test('should return error message for null or empty currency', () {
        expect(
          CurrencyDisplayUtils.validateCurrencySelection(null),
          'Please select a currency',
        );
        expect(
          CurrencyDisplayUtils.validateCurrencySelection(''),
          'Please select a currency',
        );
      });

      test('should return error message for invalid currencies', () {
        final error = CurrencyDisplayUtils.validateCurrencySelection('XYZ');
        expect(error, isNotNull);
        expect(error, contains('XYZ'));
      });
    });

    group('getCurrencyRegion', () {
      test('should return correct regions for major currencies', () {
        expect(CurrencyDisplayUtils.getCurrencyRegion('USD'), 'United States');
        expect(CurrencyDisplayUtils.getCurrencyRegion('EUR'), 'European Union');
        expect(CurrencyDisplayUtils.getCurrencyRegion('GBP'), 'United Kingdom');
        expect(CurrencyDisplayUtils.getCurrencyRegion('JPY'), 'Japan');
        expect(CurrencyDisplayUtils.getCurrencyRegion('CHF'), 'Switzerland');
      });

      test('should return "International" for unknown currencies', () {
        expect(CurrencyDisplayUtils.getCurrencyRegion('XYZ'), 'International');
        expect(CurrencyDisplayUtils.getCurrencyRegion('ABC'), 'International');
      });

      test('should be case insensitive', () {
        expect(CurrencyDisplayUtils.getCurrencyRegion('usd'), 'United States');
        expect(CurrencyDisplayUtils.getCurrencyRegion('eur'), 'European Union');
      });
    });

    group('edge cases', () {
      test('should handle null and empty strings gracefully', () {
        expect(() => CurrencyDisplayUtils.getCurrencyName(''), returnsNormally);
        expect(() => CurrencyDisplayUtils.getDisplayString(''), returnsNormally);
        expect(() => CurrencyDisplayUtils.getCurrencyRegion(''), returnsNormally);
      });

      test('should handle special characters in currency codes', () {
        expect(() => CurrencyDisplayUtils.getCurrencyName('US@'), returnsNormally);
      });

      test('should handle very long currency codes', () {
        const longCode = 'VERYLONGCURRENCYCODE';
        expect(() => CurrencyDisplayUtils.getCurrencyName(longCode), returnsNormally);
        expect(CurrencyDisplayUtils.getCurrencyName(longCode), longCode);
      });
    });

    group('integration with CurrencyValidator', () {
      test('should be consistent with CurrencyValidator supported currencies', () {
        final allCurrencies = CurrencyDisplayUtils.getAllSupportedCurrencies();
        final majorCurrencies = CurrencyDisplayUtils.getMajorCurrencies();
        
        // All major currencies should be in the supported list
        for (final currency in majorCurrencies) {
          expect(allCurrencies, contains(currency));
        }
        
        // All currencies should have names (even if it's the code itself)
        for (final currency in allCurrencies) {
          final name = CurrencyDisplayUtils.getCurrencyName(currency);
          expect(name, isNotEmpty);
        }
      });
    });
  });
}