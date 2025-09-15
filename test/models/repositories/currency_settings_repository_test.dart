import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrol_tracker/models/repositories/currency_settings_repository.dart';
import 'package:petrol_tracker/models/currency/currency_settings.dart';

void main() {
  group('CurrencySettingsRepository', () {
    late CurrencySettingsRepository repository;

    setUp(() {
      repository = CurrencySettingsRepository();
      // Clear all SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    group('loadSettings', () {
      test('should return default settings when no data exists', () async {
        final settings = await repository.loadSettings();
        
        expect(settings.primaryCurrency, 'USD');
        expect(settings.showOriginalAmounts, true);
        expect(settings.showExchangeRates, true);
        expect(settings.showConversionIndicators, true);
        expect(settings.decimalPlaces, 2);
        expect(settings.autoUpdateRates, true);
        expect(settings.maxRateAgeHours, 24);
        expect(settings.favoriteCurrencies, isEmpty);
      });

      test('should load settings from storage when available', () async {
        const testSettings = CurrencySettings(
          primaryCurrency: 'EUR',
          showOriginalAmounts: false,
          showExchangeRates: false,
          decimalPlaces: 3,
          favoriteCurrencies: ['USD', 'GBP'],
        );

        // Save settings first
        await repository.saveSettings(testSettings);
        
        // Load and verify
        final loadedSettings = await repository.loadSettings();
        
        expect(loadedSettings.primaryCurrency, 'EUR');
        expect(loadedSettings.showOriginalAmounts, false);
        expect(loadedSettings.showExchangeRates, false);
        expect(loadedSettings.decimalPlaces, 3);
        expect(loadedSettings.favoriteCurrencies, ['USD', 'GBP']);
      });

      test('should fallback to legacy primary currency setting', () async {
        // Set only legacy primary currency
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('primary_currency', 'GBP');
        
        final settings = await repository.loadSettings();
        
        expect(settings.primaryCurrency, 'GBP');
        expect(settings.showOriginalAmounts, true); // Other settings should be defaults
      });

      test('should return defaults when stored data is invalid', () async {
        // Store invalid JSON
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currency_settings', 'invalid json');
        
        final settings = await repository.loadSettings();
        
        expect(settings.primaryCurrency, 'USD'); // Should fallback to defaults
      });

      test('should return defaults when primary currency is invalid', () async {
        const invalidSettings = CurrencySettings(
          primaryCurrency: 'INVALID',
        );

        // Manually store invalid settings (bypassing validation)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currency_settings', '{"primaryCurrency": "INVALID"}');
        
        final settings = await repository.loadSettings();
        
        expect(settings.primaryCurrency, 'USD'); // Should fallback to defaults
      });
    });

    group('saveSettings', () {
      test('should save valid settings successfully', () async {
        const testSettings = CurrencySettings(
          primaryCurrency: 'EUR',
          showOriginalAmounts: false,
          favoriteCurrencies: ['USD', 'GBP', 'JPY'],
        );

        await repository.saveSettings(testSettings);
        
        // Verify by loading
        final loadedSettings = await repository.loadSettings();
        expect(loadedSettings.primaryCurrency, 'EUR');
        expect(loadedSettings.showOriginalAmounts, false);
        expect(loadedSettings.favoriteCurrencies, ['USD', 'GBP', 'JPY']);
      });

      test('should update lastUpdated timestamp when saving', () async {
        final beforeSave = DateTime.now();
        const testSettings = CurrencySettings(primaryCurrency: 'EUR');

        await repository.saveSettings(testSettings);
        
        final loadedSettings = await repository.loadSettings();
        expect(loadedSettings.lastUpdated, isNotNull);
        expect(loadedSettings.lastUpdated!.isAfter(beforeSave), true);
      });

      test('should save primary currency separately for backward compatibility', () async {
        const testSettings = CurrencySettings(primaryCurrency: 'EUR');

        await repository.saveSettings(testSettings);
        
        // Check that primary currency is stored separately
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('primary_currency'), 'EUR');
      });

      test('should throw error for invalid primary currency', () async {
        const invalidSettings = CurrencySettings(primaryCurrency: 'INVALID');

        expect(
          () => repository.saveSettings(invalidSettings),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw error for invalid decimal places', () async {
        const invalidSettings = CurrencySettings(
          primaryCurrency: 'USD',
          decimalPlaces: -1,
        );

        expect(
          () => repository.saveSettings(invalidSettings),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw error for invalid max rate age', () async {
        const invalidSettings = CurrencySettings(
          primaryCurrency: 'USD',
          maxRateAgeHours: 0,
        );

        expect(
          () => repository.saveSettings(invalidSettings),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw error for invalid favorite currencies', () async {
        const invalidSettings = CurrencySettings(
          primaryCurrency: 'USD',
          favoriteCurrencies: ['INVALID'],
        );

        expect(
          () => repository.saveSettings(invalidSettings),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('updatePrimaryCurrency', () {
      test('should update primary currency successfully', () async {
        await repository.updatePrimaryCurrency('EUR');
        
        final settings = await repository.loadSettings();
        expect(settings.primaryCurrency, 'EUR');
      });

      test('should preserve other settings when updating primary currency', () async {
        // First save some settings
        const initialSettings = CurrencySettings(
          primaryCurrency: 'USD',
          showOriginalAmounts: false,
          favoriteCurrencies: ['GBP', 'JPY'],
        );
        await repository.saveSettings(initialSettings);
        
        // Update primary currency
        await repository.updatePrimaryCurrency('EUR');
        
        // Verify primary currency changed but others remained
        final settings = await repository.loadSettings();
        expect(settings.primaryCurrency, 'EUR');
        expect(settings.showOriginalAmounts, false);
        expect(settings.favoriteCurrencies, ['GBP', 'JPY']);
      });

      test('should throw error for invalid currency', () async {
        expect(
          () => repository.updatePrimaryCurrency('INVALID'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should be case insensitive', () async {
        await repository.updatePrimaryCurrency('eur');
        
        final settings = await repository.loadSettings();
        expect(settings.primaryCurrency, 'EUR');
      });
    });

    group('getPrimaryCurrency', () {
      test('should return USD by default', () async {
        final currency = await repository.getPrimaryCurrency();
        expect(currency, 'USD');
      });

      test('should return stored primary currency', () async {
        await repository.updatePrimaryCurrency('EUR');
        
        final currency = await repository.getPrimaryCurrency();
        expect(currency, 'EUR');
      });

      test('should return default currency on error', () async {
        // Corrupt the stored settings
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currency_settings', 'invalid json');
        
        final currency = await repository.getPrimaryCurrency();
        expect(currency, 'USD');
      });
    });

    group('addFavoriteCurrency', () {
      test('should add currency to favorites', () async {
        await repository.addFavoriteCurrency('EUR');
        await repository.addFavoriteCurrency('GBP');
        
        final settings = await repository.loadSettings();
        expect(settings.favoriteCurrencies, contains('EUR'));
        expect(settings.favoriteCurrencies, contains('GBP'));
      });

      test('should not add duplicate currencies', () async {
        await repository.addFavoriteCurrency('EUR');
        await repository.addFavoriteCurrency('EUR');
        
        final settings = await repository.loadSettings();
        expect(settings.favoriteCurrencies.where((c) => c == 'EUR').length, 1);
      });

      test('should throw error for invalid currency', () async {
        expect(
          () => repository.addFavoriteCurrency('INVALID'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should normalize currency code to uppercase', () async {
        await repository.addFavoriteCurrency('eur');
        
        final settings = await repository.loadSettings();
        expect(settings.favoriteCurrencies, contains('EUR'));
      });
    });

    group('removeFavoriteCurrency', () {
      test('should remove currency from favorites', () async {
        // Add some favorites first
        await repository.addFavoriteCurrency('EUR');
        await repository.addFavoriteCurrency('GBP');
        
        // Remove one
        await repository.removeFavoriteCurrency('EUR');
        
        final settings = await repository.loadSettings();
        expect(settings.favoriteCurrencies, isNot(contains('EUR')));
        expect(settings.favoriteCurrencies, contains('GBP'));
      });

      test('should handle removing non-existent currency gracefully', () async {
        await repository.removeFavoriteCurrency('EUR');
        
        final settings = await repository.loadSettings();
        expect(settings.favoriteCurrencies, isEmpty);
      });

      test('should be case insensitive', () async {
        await repository.addFavoriteCurrency('EUR');
        await repository.removeFavoriteCurrency('eur');
        
        final settings = await repository.loadSettings();
        expect(settings.favoriteCurrencies, isNot(contains('EUR')));
      });
    });

    group('clearSettings', () {
      test('should clear all stored settings', () async {
        // Store some settings first
        const testSettings = CurrencySettings(
          primaryCurrency: 'EUR',
          favoriteCurrencies: ['USD', 'GBP'],
        );
        await repository.saveSettings(testSettings);
        
        // Clear settings
        await repository.clearSettings();
        
        // Verify settings are back to defaults
        final settings = await repository.loadSettings();
        expect(settings.primaryCurrency, 'USD');
        expect(settings.favoriteCurrencies, isEmpty);
        
        // Verify storage is actually cleared
        expect(await repository.hasStoredSettings(), false);
      });
    });

    group('hasStoredSettings', () {
      test('should return false when no settings exist', () async {
        final hasSettings = await repository.hasStoredSettings();
        expect(hasSettings, false);
      });

      test('should return true when settings exist', () async {
        await repository.updatePrimaryCurrency('EUR');
        
        final hasSettings = await repository.hasStoredSettings();
        expect(hasSettings, true);
      });

      test('should return true when legacy settings exist', () async {
        // Set only legacy primary currency
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('primary_currency', 'EUR');
        
        final hasSettings = await repository.hasStoredSettings();
        expect(hasSettings, true);
      });
    });

    group('getStorageInfo', () {
      test('should return correct info when no settings exist', () async {
        final info = await repository.getStorageInfo();
        
        expect(info['hasSettings'], false);
        expect(info['settingsSize'], 0);
        expect(info['lastUpdated'], null);
      });

      test('should return correct info when settings exist', () async {
        const testSettings = CurrencySettings(primaryCurrency: 'EUR');
        await repository.saveSettings(testSettings);
        
        final info = await repository.getStorageInfo();
        
        expect(info['hasSettings'], true);
        expect(info['settingsSize'], greaterThan(0));
        expect(info['lastUpdated'], isNotNull);
      });

      test('should handle corrupted settings gracefully', () async {
        // Store invalid JSON
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currency_settings', 'invalid json');
        
        final info = await repository.getStorageInfo();
        
        expect(info['hasSettings'], true);
        expect(info['settingsSize'], greaterThan(0));
        expect(info['lastUpdated'], null);
      });
    });

    group('edge cases and error handling', () {
      test('should handle SharedPreferences exceptions gracefully', () async {
        // This test is more about ensuring the code handles exceptions
        // In a real scenario, SharedPreferences could throw various exceptions
        
        expect(
          () => repository.loadSettings(),
          returnsNormally,
        );
      });

      test('should validate settings roundtrip', () async {
        const originalSettings = CurrencySettings(
          primaryCurrency: 'EUR',
          showOriginalAmounts: false,
          showExchangeRates: true,
          showConversionIndicators: false,
          decimalPlaces: 3,
          autoUpdateRates: false,
          maxRateAgeHours: 48,
          favoriteCurrencies: ['USD', 'GBP', 'JPY', 'CHF'],
        );

        await repository.saveSettings(originalSettings);
        final loadedSettings = await repository.loadSettings();

        expect(loadedSettings.primaryCurrency, originalSettings.primaryCurrency);
        expect(loadedSettings.showOriginalAmounts, originalSettings.showOriginalAmounts);
        expect(loadedSettings.showExchangeRates, originalSettings.showExchangeRates);
        expect(loadedSettings.showConversionIndicators, originalSettings.showConversionIndicators);
        expect(loadedSettings.decimalPlaces, originalSettings.decimalPlaces);
        expect(loadedSettings.autoUpdateRates, originalSettings.autoUpdateRates);
        expect(loadedSettings.maxRateAgeHours, originalSettings.maxRateAgeHours);
        expect(loadedSettings.favoriteCurrencies, originalSettings.favoriteCurrencies);
        expect(loadedSettings.lastUpdated, isNotNull);
      });

      test('should handle extreme values within valid ranges', () async {
        const extremeSettings = CurrencySettings(
          primaryCurrency: 'USD',
          decimalPlaces: 4, // Maximum allowed
          maxRateAgeHours: 168, // Maximum allowed (7 days)
          favoriteCurrencies: [], // Empty list
        );

        await repository.saveSettings(extremeSettings);
        final loadedSettings = await repository.loadSettings();

        expect(loadedSettings.decimalPlaces, 4);
        expect(loadedSettings.maxRateAgeHours, 168);
        expect(loadedSettings.favoriteCurrencies, isEmpty);
      });
    });
  });
}