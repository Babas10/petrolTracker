import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/utils/currency_validator.dart';

void main() {
  group('CurrencyValidator', () {
    group('isValidCurrency', () {
      test('should return true for valid currencies', () {
        expect(CurrencyValidator.isValidCurrency('USD'), true);
        expect(CurrencyValidator.isValidCurrency('EUR'), true);
        expect(CurrencyValidator.isValidCurrency('GBP'), true);
        expect(CurrencyValidator.isValidCurrency('JPY'), true);
      });

      test('should return false for invalid currencies', () {
        expect(CurrencyValidator.isValidCurrency('usd'), false); // lowercase
        expect(CurrencyValidator.isValidCurrency('US'), false);  // too short
        expect(CurrencyValidator.isValidCurrency('USDD'), false); // too long
        expect(CurrencyValidator.isValidCurrency('XYZ'), false); // unsupported
        expect(CurrencyValidator.isValidCurrency(''), false);    // empty
      });
    });

    group('isMajorCurrency', () {
      test('should return true for major currencies', () {
        expect(CurrencyValidator.isMajorCurrency('USD'), true);
        expect(CurrencyValidator.isMajorCurrency('EUR'), true);
        expect(CurrencyValidator.isMajorCurrency('GBP'), true);
        expect(CurrencyValidator.isMajorCurrency('JPY'), true);
      });

      test('should return false for non-major currencies', () {
        expect(CurrencyValidator.isMajorCurrency('THB'), false);
        expect(CurrencyValidator.isMajorCurrency('MYR'), false);
        expect(CurrencyValidator.isMajorCurrency('invalid'), false);
      });
    });

    group('usesDecimalPlaces', () {
      test('should return false for currencies that do not use decimals', () {
        expect(CurrencyValidator.usesDecimalPlaces('JPY'), false);
        expect(CurrencyValidator.usesDecimalPlaces('KRW'), false);
        expect(CurrencyValidator.usesDecimalPlaces('VND'), false);
      });

      test('should return true for currencies that use decimals', () {
        expect(CurrencyValidator.usesDecimalPlaces('USD'), true);
        expect(CurrencyValidator.usesDecimalPlaces('EUR'), true);
        expect(CurrencyValidator.usesDecimalPlaces('GBP'), true);
      });
    });

    group('getDecimalPlaces', () {
      test('should return 0 for currencies without decimals', () {
        expect(CurrencyValidator.getDecimalPlaces('JPY'), 0);
        expect(CurrencyValidator.getDecimalPlaces('KRW'), 0);
        expect(CurrencyValidator.getDecimalPlaces('VND'), 0);
      });

      test('should return 2 for currencies with decimals', () {
        expect(CurrencyValidator.getDecimalPlaces('USD'), 2);
        expect(CurrencyValidator.getDecimalPlaces('EUR'), 2);
        expect(CurrencyValidator.getDecimalPlaces('GBP'), 2);
      });
    });

    group('isValidExchangeRate', () {
      test('should return true for valid exchange rates', () {
        expect(CurrencyValidator.isValidExchangeRate(1.0), true);
        expect(CurrencyValidator.isValidExchangeRate(0.85), true);
        expect(CurrencyValidator.isValidExchangeRate(1.23), true);
        expect(CurrencyValidator.isValidExchangeRate(100.0), true);
      });

      test('should return false for invalid exchange rates', () {
        expect(CurrencyValidator.isValidExchangeRate(0.0), false);
        expect(CurrencyValidator.isValidExchangeRate(-1.0), false);
        expect(CurrencyValidator.isValidExchangeRate(15000.0), false);
      });
    });

    group('areDifferentCurrencies', () {
      test('should return true for different currencies', () {
        expect(CurrencyValidator.areDifferentCurrencies('USD', 'EUR'), true);
        expect(CurrencyValidator.areDifferentCurrencies('usd', 'EUR'), true);
      });

      test('should return false for same currencies', () {
        expect(CurrencyValidator.areDifferentCurrencies('USD', 'USD'), false);
        expect(CurrencyValidator.areDifferentCurrencies('usd', 'USD'), false);
      });
    });

    group('isValidAmount', () {
      test('should return true for valid amounts', () {
        expect(CurrencyValidator.isValidAmount(1.0), true);
        expect(CurrencyValidator.isValidAmount(100.50), true);
        expect(CurrencyValidator.isValidAmount(999999.99), true);
      });

      test('should return false for invalid amounts', () {
        expect(CurrencyValidator.isValidAmount(0.0), false);
        expect(CurrencyValidator.isValidAmount(-1.0), false);
        expect(CurrencyValidator.isValidAmount(1000000000.0), false);
      });
    });

    group('normalizeCurrency', () {
      test('should normalize currency codes', () {
        expect(CurrencyValidator.normalizeCurrency('usd'), 'USD');
        expect(CurrencyValidator.normalizeCurrency('  eur  '), 'EUR');
        expect(CurrencyValidator.normalizeCurrency('GbP'), 'GBP');
      });
    });

    group('areAllValidCurrencies', () {
      test('should return true for all valid currencies', () {
        expect(CurrencyValidator.areAllValidCurrencies(['USD', 'EUR', 'GBP']), true);
      });

      test('should return false if any currency is invalid', () {
        expect(CurrencyValidator.areAllValidCurrencies(['USD', 'EUR', 'INVALID']), false);
        expect(CurrencyValidator.areAllValidCurrencies(['USD', 'eur']), false);
      });
    });

    group('getCurrencyValidationError', () {
      test('should return null for valid currencies', () {
        expect(CurrencyValidator.getCurrencyValidationError('USD'), null);
        expect(CurrencyValidator.getCurrencyValidationError('EUR'), null);
      });

      test('should return error message for invalid currencies', () {
        expect(CurrencyValidator.getCurrencyValidationError(''), isNotNull);
        expect(CurrencyValidator.getCurrencyValidationError('US'), isNotNull);
        expect(CurrencyValidator.getCurrencyValidationError('INVALID'), isNotNull);
      });
    });

    group('getExchangeRateValidationError', () {
      test('should return null for valid rates', () {
        expect(CurrencyValidator.getExchangeRateValidationError(1.0), null);
        expect(CurrencyValidator.getExchangeRateValidationError(0.85), null);
      });

      test('should return error message for invalid rates', () {
        expect(CurrencyValidator.getExchangeRateValidationError(0.0), isNotNull);
        expect(CurrencyValidator.getExchangeRateValidationError(-1.0), isNotNull);
        expect(CurrencyValidator.getExchangeRateValidationError(15000.0), isNotNull);
      });
    });

    group('getAmountValidationError', () {
      test('should return null for valid amounts', () {
        expect(CurrencyValidator.getAmountValidationError(1.0), null);
        expect(CurrencyValidator.getAmountValidationError(100.50), null);
      });

      test('should return error message for invalid amounts', () {
        expect(CurrencyValidator.getAmountValidationError(0.0), isNotNull);
        expect(CurrencyValidator.getAmountValidationError(-1.0), isNotNull);
        expect(CurrencyValidator.getAmountValidationError(1000000000.0), isNotNull);
      });
    });

    group('validateCurrencyPair', () {
      test('should return null for valid currency pairs', () {
        expect(CurrencyValidator.validateCurrencyPair('USD', 'EUR'), null);
        expect(CurrencyValidator.validateCurrencyPair('GBP', 'JPY'), null);
      });

      test('should return error message for invalid pairs', () {
        expect(CurrencyValidator.validateCurrencyPair('USD', 'USD'), isNotNull);
        expect(CurrencyValidator.validateCurrencyPair('INVALID', 'EUR'), isNotNull);
        expect(CurrencyValidator.validateCurrencyPair('USD', 'INVALID'), isNotNull);
      });
    });

    group('getCurrencySymbol', () {
      test('should return correct symbols for currencies with symbols', () {
        expect(CurrencyValidator.getCurrencySymbol('USD'), '\$');
        expect(CurrencyValidator.getCurrencySymbol('EUR'), '€');
        expect(CurrencyValidator.getCurrencySymbol('GBP'), '£');
        expect(CurrencyValidator.getCurrencySymbol('JPY'), '¥');
        expect(CurrencyValidator.getCurrencySymbol('CNY'), '¥');
      });

      test('should return currency code for currencies without symbols', () {
        expect(CurrencyValidator.getCurrencySymbol('THB'), 'THB');
        expect(CurrencyValidator.getCurrencySymbol('MYR'), 'MYR');
      });

      test('should be case insensitive', () {
        expect(CurrencyValidator.getCurrencySymbol('usd'), '\$');
        expect(CurrencyValidator.getCurrencySymbol('eur'), '€');
      });
    });

    group('hasSymbol', () {
      test('should return true for currencies with symbols', () {
        expect(CurrencyValidator.hasSymbol('USD'), true);
        expect(CurrencyValidator.hasSymbol('EUR'), true);
        expect(CurrencyValidator.hasSymbol('GBP'), true);
      });

      test('should return false for currencies without symbols', () {
        expect(CurrencyValidator.hasSymbol('THB'), false);
        expect(CurrencyValidator.hasSymbol('MYR'), false);
      });
    });

    group('supportedCurrencies', () {
      test('should contain expected major currencies', () {
        expect(CurrencyValidator.supportedCurrencies, contains('USD'));
        expect(CurrencyValidator.supportedCurrencies, contains('EUR'));
        expect(CurrencyValidator.supportedCurrencies, contains('GBP'));
        expect(CurrencyValidator.supportedCurrencies, contains('JPY'));
        expect(CurrencyValidator.supportedCurrencies, contains('CHF'));
        expect(CurrencyValidator.supportedCurrencies, contains('CAD'));
        expect(CurrencyValidator.supportedCurrencies, contains('AUD'));
        expect(CurrencyValidator.supportedCurrencies, contains('CNY'));
      });

      test('should have reasonable size', () {
        expect(CurrencyValidator.supportedCurrencies.length, greaterThan(40));
        expect(CurrencyValidator.supportedCurrencies.length, lessThan(100));
      });
    });

    group('majorCurrencies', () {
      test('should contain expected major currencies only', () {
        expect(CurrencyValidator.majorCurrencies, contains('USD'));
        expect(CurrencyValidator.majorCurrencies, contains('EUR'));
        expect(CurrencyValidator.majorCurrencies, contains('GBP'));
        expect(CurrencyValidator.majorCurrencies, contains('JPY'));
        expect(CurrencyValidator.majorCurrencies.length, 8);
      });
    });
  });
}