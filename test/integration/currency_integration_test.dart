import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/services/country_currency_service.dart';

void main() {
  group('Currency Integration Tests', () {

    test('CountryCurrencyService should return correct primary currency', () {
      // Test country-currency mappings
      expect(CountryCurrencyService.getPrimaryCurrency('Germany'), 'EUR');
      expect(CountryCurrencyService.getPrimaryCurrency('United States'), 'USD');
      expect(CountryCurrencyService.getPrimaryCurrency('Japan'), 'JPY');
      expect(CountryCurrencyService.getPrimaryCurrency('Unknown Country'), null);
    });

    test('CountryCurrencyService should filter currencies based on country', () {
      // Test filtered currencies for Germany
      final germanyCurrencies = CountryCurrencyService.getFilteredCurrencies('Germany', 'USD');
      
      // Should contain EUR (primary), USD (user primary), and major currencies
      expect(germanyCurrencies, contains('EUR'));
      expect(germanyCurrencies, contains('USD'));
      expect(germanyCurrencies, contains('GBP'));
      
      // EUR should come first as it's the primary currency for Germany
      expect(germanyCurrencies.first, 'EUR');
    });

    test('CountryCurrencyService should provide smart defaults', () {
      // Test smart defaults
      expect(CountryCurrencyService.getSmartDefault('Germany', 'USD'), 'EUR');
      expect(CountryCurrencyService.getSmartDefault('United States', 'EUR'), 'USD');
      expect(CountryCurrencyService.getSmartDefault(null, 'CAD'), 'CAD');
    });

    test('CountryCurrencyService should identify currency usage by country', () {
      expect(CountryCurrencyService.isCurrencyCommonInCountry('EUR', 'Germany'), true);
      expect(CountryCurrencyService.isCurrencyCommonInCountry('USD', 'Germany'), false);
      expect(CountryCurrencyService.isCurrencyCommonInCountry('CHF', 'Switzerland'), true);
    });

    test('CountryCurrencyService should return countries using a currency', () {
      final euroCountries = CountryCurrencyService.getCountriesForCurrency('EUR');
      expect(euroCountries, contains('Germany'));
      expect(euroCountries, contains('France'));
      expect(euroCountries, contains('Italy'));
      
      final usdCountries = CountryCurrencyService.getCountriesForCurrency('USD');
      expect(usdCountries, contains('United States'));
      expect(usdCountries, contains('Ecuador'));
    });

  });
}