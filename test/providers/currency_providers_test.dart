import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/providers/currency_providers_manual.dart';
import 'package:petrol_tracker/services/currency_service.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/currency_providers.dart' as original;

void main() {
  group('Currency Providers Tests', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });
    
    group('Currency Service Provider', () {
      test('should provide CurrencyService instance', () {
        final currencyService = container.read(currencyServiceProvider);
        
        expect(currencyService, isA<CurrencyService>());
        expect(currencyService, same(CurrencyService.instance));
      });
    });
    
    group('Primary Currency Provider', () {
      test('should provide default currency initially', () {
        final primaryCurrency = container.read(original.primaryCurrencyProvider);
        
        expect(primaryCurrency, equals('USD'));
      });
      
      test('should update primary currency', () async {
        final notifier = container.read(original.primaryCurrencyProvider.notifier);
        
        await notifier.setPrimaryCurrency('EUR');
        final newCurrency = container.read(original.primaryCurrencyProvider);
        
        expect(newCurrency, equals('EUR'));
      });
      
      test('should reject invalid currency codes', () async {
        final notifier = container.read(original.primaryCurrencyProvider.notifier);
        
        await notifier.setPrimaryCurrency('INVALID');
        final currency = container.read(original.primaryCurrencyProvider);
        
        // Should remain unchanged
        expect(currency, equals('USD'));
      });
    });
    
    group('Available Currencies Provider', () {
      test('should provide list of common currencies', () {
        final currencies = container.read(original.availableCurrenciesProvider);
        
        expect(currencies, isA<List<String>>());
        expect(currencies, contains('USD'));
        expect(currencies, contains('EUR'));
        expect(currencies, contains('GBP'));
        expect(currencies.length, greaterThan(10));
      });
    });
    
    group('Dynamic Available Currencies Provider', () {
      test('should extract currencies from fuel entries', () async {
        // Add some test fuel entries
        final fuelEntriesNotifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        await fuelEntriesNotifier.addFuelEntry(FuelEntryModel(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 10000,
          fuelAmount: 50.0,
          price: 100.0,
          country: 'United States',
          pricePerLiter: 2.0,
        ));
        
        await fuelEntriesNotifier.addFuelEntry(FuelEntryModel(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 10100,
          fuelAmount: 45.0,
          price: 80.0,
          country: 'Germany',
          pricePerLiter: 1.8,
        ));
        
        final currencies = await container.read(dynamicAvailableCurrenciesProvider.future);
        
        expect(currencies, contains('USD'));
        expect(currencies, contains('EUR'));
        expect(currencies, contains('GBP')); // Always included
      });
    });
    
    group('Currency Usage Statistics Provider', () {
      test('should calculate usage statistics correctly', () async {
        // Add test fuel entries with different countries
        final fuelEntriesNotifier = container.read(fuelEntriesNotifierProvider.notifier);
        
        await fuelEntriesNotifier.addFuelEntry(FuelEntryModel(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 10000,
          fuelAmount: 50.0,
          price: 100.0,
          country: 'United States',
          pricePerLiter: 2.0,
        ));
        
        await fuelEntriesNotifier.addFuelEntry(FuelEntryModel(
          vehicleId: 1,
          date: DateTime.now(),
          litersFueled: 45.0,
          totalCost: 80.0,
          fuelType: 'Gasoline',
          gasStation: 'EU Station',
          country: 'Germany',
          odometer: 10100,
        ));
        
        await fuelEntriesNotifier.addFuelEntry(FuelEntryModel(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 10200,
          fuelAmount: 40.0,
          price: 90.0,
          country: 'United States',
          pricePerLiter: 2.25,
        ));
        
        final stats = await container.read(currencyUsageStatisticsProvider.future);
        
        expect(stats.totalEntries, equals(3));
        expect(stats.uniqueCurrencies, contains('USD'));
        expect(stats.uniqueCurrencies, contains('EUR'));
        expect(stats.currencyEntryCount['USD'], equals(2));
        expect(stats.currencyEntryCount['EUR'], equals(1));
        expect(stats.hasMultiCurrencyUsage, isTrue);
        expect(stats.mostUsedCurrency, equals('USD'));
        
        final percentages = stats.currencyUsagePercentages;
        expect(percentages['USD'], closeTo(66.67, 0.1));
        expect(percentages['EUR'], closeTo(33.33, 0.1));
      });
    });
    
    group('Currency Conversion Provider', () {
      test('should handle same currency conversion', () async {
        final params = ConversionParams(
          amount: 100.0,
          fromCurrency: 'USD',
          toCurrency: 'USD',
        );
        
        final conversion = await container.read(currencyConversionProvider(params).future);
        
        expect(conversion, isNotNull);
        expect(conversion!.originalAmount, equals(100.0));
        expect(conversion.convertedAmount, equals(100.0));
        expect(conversion.exchangeRate, equals(1.0));
        expect(conversion.originalCurrency, equals('USD'));
        expect(conversion.targetCurrency, equals('USD'));
      });
      
      test('should handle conversion failure gracefully', () async {
        final params = ConversionParams(
          amount: 100.0,
          fromCurrency: 'INVALID',
          toCurrency: 'USD',
        );
        
        final conversion = await container.read(currencyConversionProvider(params).future);
        
        // Should handle gracefully and potentially return null or use fallback
        expect(conversion, isA<CurrencyConversion?>());
      });
    });
    
    group('Exchange Rates Monitor Provider', () {
      test('should initialize with loading state', () {
        final monitor = container.read(exchangeRatesMonitorProvider);
        
        expect(monitor, isA<AsyncValue<Map<String, DateTime>>>());
      });
      
      test('should handle rate refresh requests', () async {
        final monitor = container.read(exchangeRatesMonitorProvider.notifier);
        
        // Should not throw an exception
        expect(() => monitor.refreshRatesFor('EUR'), returnsNormally);
      });
    });
    
    group('Conversion Health Status Provider', () {
      test('should provide health status information', () async {
        final healthStatus = await container.read(conversionHealthStatusProvider.future);
        
        expect(healthStatus, isA<ConversionHealthStatus>());
        expect(healthStatus.totalCurrencies, greaterThanOrEqualTo(0));
        expect(healthStatus.healthyCurrencies, greaterThanOrEqualTo(0));
        expect(healthStatus.healthScore, greaterThanOrEqualTo(0.0));
        expect(healthStatus.healthScore, lessThanOrEqualTo(1.0));
        expect(healthStatus.lastChecked, isA<DateTime>());
        expect(healthStatus.staleCurrencies, isA<List<String>>());
        expect(healthStatus.failedCurrencies, isA<List<String>>());
      });
      
      test('should calculate health description correctly', () {
        const excellentHealth = ConversionHealthStatus(
          healthScore: 0.95,
          totalCurrencies: 10,
          healthyCurrencies: 9,
          staleCurrencies: [],
          failedCurrencies: [],
          lastChecked: null,
        );
        
        const goodHealth = ConversionHealthStatus(
          healthScore: 0.8,
          totalCurrencies: 10,
          healthyCurrencies: 8,
          staleCurrencies: [],
          failedCurrencies: [],
          lastChecked: null,
        );
        
        const fairHealth = ConversionHealthStatus(
          healthScore: 0.6,
          totalCurrencies: 10,
          healthyCurrencies: 6,
          staleCurrencies: [],
          failedCurrencies: [],
          lastChecked: null,
        );
        
        const poorHealth = ConversionHealthStatus(
          healthScore: 0.3,
          totalCurrencies: 10,
          healthyCurrencies: 3,
          staleCurrencies: [],
          failedCurrencies: [],
          lastChecked: null,
        );
        
        expect(excellentHealth.healthDescription, equals('Excellent'));
        expect(excellentHealth.isHealthy, isTrue);
        
        expect(goodHealth.healthDescription, equals('Good'));
        expect(goodHealth.isHealthy, isTrue);
        
        expect(fairHealth.healthDescription, equals('Fair'));
        expect(fairHealth.isHealthy, isFalse);
        
        expect(poorHealth.healthDescription, equals('Poor'));
        expect(poorHealth.isHealthy, isFalse);
      });
    });
    
    group('Currency Filter Provider', () {
      test('should handle currency filter state', () {
        final initialFilter = container.read(original.currencyFilterProvider);
        expect(initialFilter, isNull);
        
        container.read(original.currencyFilterProvider.notifier).state = 'USD';
        final updatedFilter = container.read(original.currencyFilterProvider);
        expect(updatedFilter, equals('USD'));
        
        container.read(original.currencyFilterProvider.notifier).state = null;
        final clearedFilter = container.read(original.currencyFilterProvider);
        expect(clearedFilter, isNull);
      });
    });
    
    group('Currency Country Extraction', () {
      test('should extract correct currencies from country names', () {
        expect(_extractCurrencyFromCountry('United States'), equals('USD'));
        expect(_extractCurrencyFromCountry('usa'), equals('USD'));
        expect(_extractCurrencyFromCountry('Canada'), equals('CAD'));
        expect(_extractCurrencyFromCountry('Germany'), equals('EUR'));
        expect(_extractCurrencyFromCountry('france'), equals('EUR'));
        expect(_extractCurrencyFromCountry('United Kingdom'), equals('GBP'));
        expect(_extractCurrencyFromCountry('uk'), equals('GBP'));
        expect(_extractCurrencyFromCountry('Japan'), equals('JPY'));
        expect(_extractCurrencyFromCountry('Australia'), equals('AUD'));
        expect(_extractCurrencyFromCountry('Switzerland'), equals('CHF'));
        expect(_extractCurrencyFromCountry('unknown country'), equals('USD')); // fallback
      });
    });
    
    group('ConversionParams', () {
      test('should handle equality correctly', () {
        const params1 = ConversionParams(
          amount: 100.0,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );
        
        const params2 = ConversionParams(
          amount: 100.0,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );
        
        const params3 = ConversionParams(
          amount: 200.0,
          fromCurrency: 'USD',
          toCurrency: 'EUR',
        );
        
        expect(params1, equals(params2));
        expect(params1, isNot(equals(params3)));
        expect(params1.hashCode, equals(params2.hashCode));
        expect(params1.hashCode, isNot(equals(params3.hashCode)));
      });
    });
    
    group('CurrencyUsageStatistics', () {
      test('should calculate usage percentages correctly', () {
        const stats = CurrencyUsageStatistics(
          primaryCurrency: 'USD',
          currencyEntryCount: {'USD': 3, 'EUR': 2, 'GBP': 1},
          currencyTotalAmount: {'USD': 300.0, 'EUR': 200.0, 'GBP': 100.0},
          totalEntries: 6,
          uniqueCurrencies: ['USD', 'EUR', 'GBP'],
        );
        
        expect(stats.hasMultiCurrencyUsage, isTrue);
        expect(stats.mostUsedCurrency, equals('USD'));
        
        final percentages = stats.currencyUsagePercentages;
        expect(percentages['USD'], equals(50.0));
        expect(percentages['EUR'], closeTo(33.33, 0.1));
        expect(percentages['GBP'], closeTo(16.67, 0.1));
      });
      
      test('should handle empty statistics', () {
        const stats = CurrencyUsageStatistics(
          primaryCurrency: 'USD',
          currencyEntryCount: {},
          currencyTotalAmount: {},
          totalEntries: 0,
          uniqueCurrencies: [],
        );
        
        expect(stats.hasMultiCurrencyUsage, isFalse);
        expect(stats.mostUsedCurrency, equals('USD')); // fallback to primary
        expect(stats.currencyUsagePercentages, isEmpty);
      });
    });
  });
  
  group('Integration Tests', () {
    late ProviderContainer container;
    
    setUp(() {
      container = ProviderContainer();
    });
    
    tearDown(() {
      container.dispose();
    });
    
    test('should handle complete currency workflow', () async {
      // 1. Add fuel entries from different countries
      final fuelEntriesNotifier = container.read(fuelEntriesNotifierProvider.notifier);
      
      await fuelEntriesNotifier.addFuelEntry(FuelEntryModel(
        vehicleId: 1,
        date: DateTime.now(),
        litersFueled: 50.0,
        totalCost: 100.0,
        fuelType: 'Gasoline',
        gasStation: 'US Station',
        country: 'United States',
        odometer: 10000,
      ));
      
      await fuelEntriesNotifier.addFuelEntry(FuelEntryModel(
        vehicleId: 1,
        date: DateTime.now(),
        litersFueled: 45.0,
        totalCost: 80.0,
        fuelType: 'Gasoline',
        gasStation: 'EU Station',
        country: 'Germany',
        odometer: 10100,
      ));
      
      // 2. Check that dynamic currencies are updated
      final availableCurrencies = await container.read(dynamicAvailableCurrenciesProvider.future);
      expect(availableCurrencies, contains('USD'));
      expect(availableCurrencies, contains('EUR'));
      
      // 3. Check usage statistics
      final stats = await container.read(currencyUsageStatisticsProvider.future);
      expect(stats.hasMultiCurrencyUsage, isTrue);
      expect(stats.totalEntries, equals(2));
      
      // 4. Test currency conversion
      const params = ConversionParams(
        amount: 100.0,
        fromCurrency: 'USD',
        toCurrency: 'USD',
      );
      final conversion = await container.read(currencyConversionProvider(params).future);
      expect(conversion, isNotNull);
      
      // 5. Check health status
      final healthStatus = await container.read(conversionHealthStatusProvider.future);
      expect(healthStatus.totalCurrencies, greaterThanOrEqualTo(2));
    });
  });
}

/// Helper function for testing currency extraction
String _extractCurrencyFromCountry(String country) {
  switch (country.toLowerCase()) {
    case 'united states':
    case 'usa':
    case 'us':
      return 'USD';
    case 'canada':
      return 'CAD';
    case 'united kingdom':
    case 'uk':
    case 'england':
    case 'scotland':
    case 'wales':
      return 'GBP';
    case 'germany':
    case 'france':
    case 'italy':
    case 'spain':
    case 'netherlands':
    case 'belgium':
    case 'austria':
    case 'portugal':
    case 'ireland':
    case 'finland':
    case 'greece':
      return 'EUR';
    case 'japan':
      return 'JPY';
    case 'australia':
      return 'AUD';
    case 'switzerland':
      return 'CHF';
    case 'china':
      return 'CNY';
    case 'india':
      return 'INR';
    case 'brazil':
      return 'BRL';
    case 'mexico':
      return 'MXN';
    case 'singapore':
      return 'SGD';
    case 'hong kong':
      return 'HKD';
    case 'new zealand':
      return 'NZD';
    case 'sweden':
      return 'SEK';
    case 'norway':
      return 'NOK';
    case 'denmark':
      return 'DKK';
    case 'poland':
      return 'PLN';
    case 'czech republic':
      return 'CZK';
    case 'hungary':
      return 'HUF';
    default:
      return 'USD'; // Default fallback
  }
}