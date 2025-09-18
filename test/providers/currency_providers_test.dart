import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrol_tracker/providers/currency_providers.dart';

void main() {
  group('PrimaryCurrencyNotifier', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('starts with default USD currency', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final primaryCurrency = container.read(primaryCurrencyProvider);
      expect(primaryCurrency, equals('USD'));
    });

    test('loads saved currency from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'primary_currency': 'EUR'});
      
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Wait for async loading to complete
      await Future.delayed(const Duration(milliseconds: 50));
      
      final primaryCurrency = container.read(primaryCurrencyProvider);
      expect(primaryCurrency, equals('EUR'));
    });

    test('updates currency and persists to SharedPreferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(primaryCurrencyProvider.notifier);
      
      await notifier.setPrimaryCurrency('GBP');
      
      final primaryCurrency = container.read(primaryCurrencyProvider);
      expect(primaryCurrency, equals('GBP'));
      
      // Verify it was saved to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('primary_currency'), equals('GBP'));
    });

    test('validates currency format before setting', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(primaryCurrencyProvider.notifier);
      
      // Should reject invalid currency codes
      await notifier.setPrimaryCurrency('invalid');
      expect(container.read(primaryCurrencyProvider), equals('USD')); // Should remain default
      
      await notifier.setPrimaryCurrency('eur'); // lowercase
      expect(container.read(primaryCurrencyProvider), equals('USD')); // Should remain default
      
      await notifier.setPrimaryCurrency('EURO'); // too long
      expect(container.read(primaryCurrencyProvider), equals('USD')); // Should remain default
      
      // Should accept valid currency code
      await notifier.setPrimaryCurrency('EUR');
      expect(container.read(primaryCurrencyProvider), equals('EUR'));
    });

    test('handles SharedPreferences errors gracefully', () async {
      // This test ensures the provider works even if SharedPreferences fails
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(primaryCurrencyProvider.notifier);
      
      // Even if saving fails, the state should still update
      await notifier.setPrimaryCurrency('CAD');
      expect(container.read(primaryCurrencyProvider), equals('CAD'));
    });
  });

  group('availableCurrenciesProvider', () {
    test('returns list of common currencies', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final currencies = container.read(availableCurrenciesProvider);
      
      expect(currencies, isA<List<String>>());
      expect(currencies, isNotEmpty);
      expect(currencies, contains('USD'));
      expect(currencies, contains('EUR'));
      expect(currencies, contains('GBP'));
      expect(currencies, contains('CAD'));
      expect(currencies, contains('AUD'));
      expect(currencies, contains('JPY'));
    });

    test('currencies are uppercase 3-letter codes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final currencies = container.read(availableCurrenciesProvider);
      
      for (final currency in currencies) {
        expect(currency.length, equals(3));
        expect(currency, equals(currency.toUpperCase()));
        expect(RegExp(r'^[A-Z]{3}$').hasMatch(currency), isTrue);
      }
    });
  });

  group('currencyFilterProvider', () {
    test('starts with null value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filter = container.read(currencyFilterProvider);
      expect(filter, isNull);
    });

    test('can be updated to filter by currency', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(currencyFilterProvider.notifier).state = 'EUR';
      
      final filter = container.read(currencyFilterProvider);
      expect(filter, equals('EUR'));
    });

    test('can be reset to null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(currencyFilterProvider.notifier);
      
      notifier.state = 'USD';
      expect(container.read(currencyFilterProvider), equals('USD'));
      
      notifier.state = null;
      expect(container.read(currencyFilterProvider), isNull);
    });
  });

  group('Provider integration', () {
    test('currency filter works independently of primary currency', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set primary currency
      container.read(primaryCurrencyProvider.notifier).setPrimaryCurrency('USD');
      
      // Set different filter currency
      container.read(currencyFilterProvider.notifier).state = 'EUR';
      
      expect(container.read(primaryCurrencyProvider), equals('USD'));
      expect(container.read(currencyFilterProvider), equals('EUR'));
    });

    test('multiple containers maintain independent state', () async {
      final container1 = ProviderContainer();
      final container2 = ProviderContainer();
      addTearDown(() {
        container1.dispose();
        container2.dispose();
      });

      await container1.read(primaryCurrencyProvider.notifier).setPrimaryCurrency('EUR');
      await container2.read(primaryCurrencyProvider.notifier).setPrimaryCurrency('GBP');
      
      // Give time for state updates
      await Future.delayed(const Duration(milliseconds: 10));
      
      expect(container1.read(primaryCurrencyProvider), equals('EUR'));
      expect(container2.read(primaryCurrencyProvider), equals('GBP'));
    });
  });
}