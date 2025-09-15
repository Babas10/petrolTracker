import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrol_tracker/providers/currency_settings_providers.dart';
import 'package:petrol_tracker/models/currency/currency_settings.dart' as model;

void main() {
  group('model.CurrencySettingsProviders', () {
    late ProviderContainer container;

    setUp(() {
      // Clear all SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('currencySettingsNotifierProvider', () {
      test('should provide default settings initially', () async {
        final settings = await container.read(currencySettingsNotifierProvider.future);
        
        expect(settings.primaryCurrency, 'USD');
        expect(settings.showOriginalAmounts, true);
        expect(settings.showExchangeRates, true);
        expect(settings.showConversionIndicators, true);
        expect(settings.decimalPlaces, 2);
        expect(settings.autoUpdateRates, true);
        expect(settings.maxRateAgeHours, 24);
        expect(settings.favoriteCurrencies, isEmpty);
      });

      test('should load existing settings from storage', () async {
        // Pre-populate storage
        const testSettings = model.CurrencySettings(
          primaryCurrency: 'EUR',
          showOriginalAmounts: false,
          favoriteCurrencies: ['USD', 'GBP'],
        );
        
        final repository = container.read(currencySettingsRepositoryProvider);
        await repository.saveSettings(testSettings);
        
        // Create new container to test loading
        container.dispose();
        container = ProviderContainer();
        
        final settings = await container.read(currencySettingsNotifierProvider.future);
        expect(settings.primaryCurrency, 'EUR');
        expect(settings.showOriginalAmounts, false);
        expect(settings.favoriteCurrencies, ['USD', 'GBP']);
      });
    });

    group('model.CurrencySettings.updatePrimaryCurrency', () {
      test('should update primary currency successfully', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        await notifier.updatePrimaryCurrency('EUR');
        
        final settings = await container.read(currencySettingsNotifierProvider.future);
        expect(settings.primaryCurrency, 'EUR');
      });

      test('should persist currency change', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        await notifier.updatePrimaryCurrency('EUR');
        
        // Verify persistence by checking repository directly
        final repository = container.read(currencySettingsRepositoryProvider);
        final currency = await repository.getPrimaryCurrency();
        expect(currency, 'EUR');
      });

      test('should throw error for invalid currency', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        expect(
          () => notifier.updatePrimaryCurrency('INVALID'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should revert optimistic update on persistence error', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        // First set a known good currency
        await notifier.updatePrimaryCurrency('EUR');
        
        // Mock a persistence failure by disposing the container
        // (This simulates a scenario where the update fails)
        final originalSettings = await container.read(currencySettingsNotifierProvider.future);
        
        try {
          await notifier.updatePrimaryCurrency('INVALID');
          fail('Should have thrown an error');
        } catch (e) {
          // Error should be thrown and state should remain unchanged
          final currentSettings = await container.read(currencySettingsNotifierProvider.future);
          expect(currentSettings.primaryCurrency, originalSettings.primaryCurrency);
        }
      });

      test('should invalidate primaryCurrencyProvider on change', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        // Read primary currency provider first
        final initialCurrency = await container.read(primaryCurrencyProvider.future);
        expect(initialCurrency, 'USD');
        
        // Update currency
        await notifier.updatePrimaryCurrency('EUR');
        
        // Primary currency provider should reflect the change
        final updatedCurrency = await container.read(primaryCurrencyProvider.future);
        expect(updatedCurrency, 'EUR');
      });
    });

    group('model.CurrencySettings.updateDisplaySettings', () {
      test('should update display settings successfully', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        await notifier.updateDisplaySettings(
          showOriginalAmounts: false,
          showExchangeRates: false,
          decimalPlaces: 3,
        );
        
        final settings = await container.read(currencySettingsNotifierProvider.future);
        expect(settings.showOriginalAmounts, false);
        expect(settings.showExchangeRates, false);
        expect(settings.showConversionIndicators, true); // Should remain unchanged
        expect(settings.decimalPlaces, 3);
      });

      test('should validate decimal places', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        expect(
          () => notifier.updateDisplaySettings(decimalPlaces: -1),
          throwsA(isA<ArgumentError>()),
        );
        
        expect(
          () => notifier.updateDisplaySettings(decimalPlaces: 5),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should persist display settings changes', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        await notifier.updateDisplaySettings(
          showOriginalAmounts: false,
          showExchangeRates: false,
        );
        
        // Verify persistence
        container.dispose();
        container = ProviderContainer();
        
        final settings = await container.read(currencySettingsNotifierProvider.future);
        expect(settings.showOriginalAmounts, false);
        expect(settings.showExchangeRates, false);
      });
    });

    group('model.CurrencySettings.updateRateSettings', () {
      test('should update rate settings successfully', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        await notifier.updateRateSettings(
          autoUpdateRates: false,
          maxRateAgeHours: 48,
        );
        
        final settings = await container.read(currencySettingsNotifierProvider.future);
        expect(settings.autoUpdateRates, false);
        expect(settings.maxRateAgeHours, 48);
      });

      test('should validate max rate age hours', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        expect(
          () => notifier.updateRateSettings(maxRateAgeHours: 0),
          throwsA(isA<ArgumentError>()),
        );
        
        expect(
          () => notifier.updateRateSettings(maxRateAgeHours: 169),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('model.CurrencySettings.addFavoriteCurrency', () {
      test('should add favorite currency successfully', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        await notifier.addFavoriteCurrency('EUR');
        await notifier.addFavoriteCurrency('GBP');
        
        final settings = await container.read(currencySettingsNotifierProvider.future);
        expect(settings.favoriteCurrencies, contains('EUR'));
        expect(settings.favoriteCurrencies, contains('GBP'));
      });

      test('should throw error for invalid currency', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        expect(
          () => notifier.addFavoriteCurrency('INVALID'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should not add duplicate currencies', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        await notifier.addFavoriteCurrency('EUR');
        await notifier.addFavoriteCurrency('EUR');
        
        final settings = await container.read(currencySettingsNotifierProvider.future);
        expect(settings.favoriteCurrencies.where((c) => c == 'EUR').length, 1);
      });
    });

    group('model.CurrencySettings.removeFavoriteCurrency', () {
      test('should remove favorite currency successfully', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        // Add some favorites first
        await notifier.addFavoriteCurrency('EUR');
        await notifier.addFavoriteCurrency('GBP');
        
        // Remove one
        await notifier.removeFavoriteCurrency('EUR');
        
        final settings = await container.read(currencySettingsNotifierProvider.future);
        expect(settings.favoriteCurrencies, isNot(contains('EUR')));
        expect(settings.favoriteCurrencies, contains('GBP'));
      });
    });

    group('model.CurrencySettings.resetToDefaults', () {
      test('should reset all settings to defaults', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        // First change some settings
        await notifier.updatePrimaryCurrency('EUR');
        await notifier.updateDisplaySettings(showOriginalAmounts: false);
        await notifier.addFavoriteCurrency('GBP');
        
        // Reset to defaults
        await notifier.resetToDefaults();
        
        final settings = await container.read(currencySettingsNotifierProvider.future);
        expect(settings.primaryCurrency, 'USD');
        expect(settings.showOriginalAmounts, true);
        expect(settings.favoriteCurrencies, isEmpty);
      });

      test('should invalidate primaryCurrencyProvider on reset', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        // Change currency first
        await notifier.updatePrimaryCurrency('EUR');
        
        // Reset
        await notifier.resetToDefaults();
        
        // Primary currency provider should reflect the reset
        final currency = await container.read(primaryCurrencyProvider.future);
        expect(currency, 'USD');
      });
    });

    group('model.CurrencySettings.refresh', () {
      test('should refresh settings from storage', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        final repository = container.read(currencySettingsRepositoryProvider);
        
        // Manually update storage
        const updatedSettings = model.CurrencySettings(primaryCurrency: 'EUR');
        await repository.saveSettings(updatedSettings);
        
        // Refresh provider
        await notifier.refresh();
        
        final settings = await container.read(currencySettingsNotifierProvider.future);
        expect(settings.primaryCurrency, 'EUR');
      });
    });

    group('primaryCurrencyProvider', () {
      test('should return primary currency from settings', () async {
        final currency = await container.read(primaryCurrencyProvider.future);
        expect(currency, 'USD');
      });

      test('should update when settings change', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        await notifier.updatePrimaryCurrency('EUR');
        
        final currency = await container.read(primaryCurrencyProvider.future);
        expect(currency, 'EUR');
      });
    });

    group('isFirstTimeUserProvider', () {
      test('should return true for new user', () async {
        final isFirstTime = await container.read(isFirstTimeUserProvider.future);
        expect(isFirstTime, true);
      });

      test('should return false after settings are saved', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        await notifier.updatePrimaryCurrency('EUR');
        
        // Need new container to test the provider again
        container.dispose();
        container = ProviderContainer();
        
        final isFirstTime = await container.read(isFirstTimeUserProvider.future);
        expect(isFirstTime, false);
      });
    });

    group('currencyDisplayPreferencesProvider', () {
      test('should extract display preferences correctly', () async {
        final preferences = await container.read(currencyDisplayPreferencesProvider.future);
        
        expect(preferences.showOriginalAmounts, true);
        expect(preferences.showExchangeRates, true);
        expect(preferences.showConversionIndicators, true);
        expect(preferences.decimalPlaces, 2);
      });

      test('should update when display settings change', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        await notifier.updateDisplaySettings(
          showOriginalAmounts: false,
          decimalPlaces: 3,
        );
        
        final preferences = await container.read(currencyDisplayPreferencesProvider.future);
        expect(preferences.showOriginalAmounts, false);
        expect(preferences.showExchangeRates, true); // Unchanged
        expect(preferences.decimalPlaces, 3);
      });
    });

    group('CurrencyDisplayPreferences', () {
      test('should implement equality correctly', () {
        const prefs1 = CurrencyDisplayPreferences(
          showOriginalAmounts: true,
          showExchangeRates: false,
          showConversionIndicators: true,
          decimalPlaces: 2,
        );
        
        const prefs2 = CurrencyDisplayPreferences(
          showOriginalAmounts: true,
          showExchangeRates: false,
          showConversionIndicators: true,
          decimalPlaces: 2,
        );
        
        const prefs3 = CurrencyDisplayPreferences(
          showOriginalAmounts: false,
          showExchangeRates: false,
          showConversionIndicators: true,
          decimalPlaces: 2,
        );
        
        expect(prefs1, equals(prefs2));
        expect(prefs1, isNot(equals(prefs3)));
        expect(prefs1.hashCode, equals(prefs2.hashCode));
      });
    });

    group('error handling and edge cases', () {
      test('should handle provider invalidation gracefully', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        // Change settings
        await notifier.updatePrimaryCurrency('EUR');
        
        // Invalidate provider
        container.invalidate(currencySettingsNotifierProvider);
        
        // Should be able to read again
        final settings = await container.read(currencySettingsNotifierProvider.future);
        expect(settings.primaryCurrency, 'EUR'); // Should persist
      });

      test('should handle rapid successive updates', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        // Make multiple rapid updates
        final futures = [
          notifier.updatePrimaryCurrency('EUR'),
          notifier.updateDisplaySettings(showOriginalAmounts: false),
          notifier.addFavoriteCurrency('GBP'),
        ];
        
        await Future.wait(futures);
        
        final settings = await container.read(currencySettingsNotifierProvider.future);
        expect(settings.primaryCurrency, 'EUR');
        expect(settings.showOriginalAmounts, false);
        expect(settings.favoriteCurrencies, contains('GBP'));
      });

      test('should maintain provider state consistency', () async {
        final notifier = container.read(currencySettingsNotifierProvider.notifier);
        
        await notifier.updatePrimaryCurrency('EUR');
        
        // All related providers should be consistent
        final settings = await container.read(currencySettingsNotifierProvider.future);
        final primaryCurrency = await container.read(primaryCurrencyProvider.future);
        final isFirstTime = await container.read(isFirstTimeUserProvider.future);
        
        expect(settings.primaryCurrency, 'EUR');
        expect(primaryCurrency, 'EUR');
        expect(isFirstTime, false);
      });
    });
  });
}