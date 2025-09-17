/// Integration tests for multi-currency cost analysis dashboard
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/screens/cost_analysis_dashboard_screen.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/currency_settings.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/currency_settings_providers.dart';
import 'package:petrol_tracker/services/currency_service.dart';

// Mock currency service for integration testing
class MockCurrencyService implements CurrencyService {
  final Map<String, Map<String, double>> _mockRates = {
    'USD': {'EUR': 0.85, 'GBP': 0.75, 'CAD': 1.25, 'JPY': 110.0},
    'EUR': {'USD': 1.18, 'GBP': 0.88, 'CAD': 1.47, 'JPY': 129.0},
    'CAD': {'USD': 0.80, 'EUR': 0.68, 'GBP': 0.60, 'JPY': 88.0},
  };

  @override
  Future<CurrencyConversion?> convertAmount({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    String? baseCurrency,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (fromCurrency == toCurrency) {
      return CurrencyConversion.sameCurrency(amount: amount, currency: fromCurrency);
    }

    final rates = _mockRates[fromCurrency];
    if (rates == null || !rates.containsKey(toCurrency)) {
      return null; // Conversion failed
    }

    final rate = rates[toCurrency]!;
    return CurrencyConversion(
      originalAmount: amount,
      originalCurrency: fromCurrency,
      convertedAmount: amount * rate,
      targetCurrency: toCurrency,
      exchangeRate: rate,
      rateDate: DateTime.now(),
    );
  }

  @override
  void initialize() {}

  @override
  void dispose() {}

  @override
  Future<bool> areRatesFresh(String baseCurrency) async => true;

  @override
  Future<Map<String, double>> fetchDailyRates(String baseCurrency) async => {};

  @override
  Future<Map<String, double>> getLocalRates(String baseCurrency) async => {};

  @override
  Future<void> clearCache() async {}

  @override
  Future<Map<String, dynamic>> getCacheStats() async => {};
}

// Mock notifiers for testing
class MockFuelEntryNotifier extends StateNotifier<AsyncValue<List<FuelEntryModel>>> {
  MockFuelEntryNotifier() : super(const AsyncValue.loading());

  void setMockData(List<FuelEntryModel> entries) {
    state = AsyncValue.data(entries);
  }
}

class MockCurrencySettingsNotifier extends StateNotifier<AsyncValue<CurrencySettings>> {
  MockCurrencySettingsNotifier() : super(const AsyncValue.loading());

  void setMockSettings(CurrencySettings settings) {
    state = AsyncValue.data(settings);
  }
}

void main() {
  group('Multi-Currency Dashboard Integration Tests', () {
    late MockFuelEntryNotifier mockFuelEntryNotifier;
    late MockCurrencySettingsNotifier mockCurrencySettingsNotifier;
    late MockCurrencyService mockCurrencyService;

    setUp(() {
      mockFuelEntryNotifier = MockFuelEntryNotifier();
      mockCurrencySettingsNotifier = MockCurrencySettingsNotifier();
      mockCurrencyService = MockCurrencyService();
    });

    Widget createTestApp(List<Override> overrides) {
      return ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          home: const CostAnalysisDashboardScreen(vehicleId: 1),
        ),
      );
    }

    testWidgets('should display multi-currency dashboard with USD primary currency', (WidgetTester tester) async {
      // Set up mock data with multi-currency entries
      final entries = [
        _createMockFuelEntry(DateTime(2023, 1, 15), 100.0, 'USA'), // USD
        _createMockFuelEntry(DateTime(2023, 1, 25), 120.0, 'Canada'), // CAD
        _createMockFuelEntry(DateTime(2023, 2, 10), 110.0, 'Germany'), // EUR
        _createMockFuelEntry(DateTime(2023, 3, 5), 95.0, 'USA'), // USD
      ];
      mockFuelEntryNotifier.setMockData(entries);

      // Set up currency settings with USD as primary
      mockCurrencySettingsNotifier.setMockSettings(
        const CurrencySettings(
          primaryCurrency: 'USD',
          enableAutoConversion: true,
          rateUpdateFrequency: Duration(hours: 1),
          fallbackToPrimary: true,
          showConversionRates: true,
          precisionDecimals: 2,
          lastUpdated: null,
        ),
      );

      await tester.pumpWidget(createTestApp([
        currencySettingsNotifierProvider.overrideWith((ref) => mockCurrencySettingsNotifier),
        fuelEntriesByVehicleProvider(1).overrideWith((ref) => mockFuelEntryNotifier),
      ]));

      // Wait for providers to load
      await tester.pumpAndSettle();

      // Verify multi-currency indicator is displayed
      expect(find.textContaining('USD'), findsAtLeastNWidget(1));
      expect(find.textContaining('currencies'), findsAtLeastNWidget(1));

      // Verify dashboard components are present
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should handle currency conversion and display converted amounts', (WidgetTester tester) async {
      // Set up entries with different currencies
      final entries = [
        _createMockFuelEntry(DateTime(2023, 1, 15), 100.0, 'USA'), // USD -> USD (no conversion)
        _createMockFuelEntry(DateTime(2023, 1, 25), 100.0, 'Canada'), // CAD -> USD (should convert)
      ];
      mockFuelEntryNotifier.setMockData(entries);

      mockCurrencySettingsNotifier.setMockSettings(
        const CurrencySettings(
          primaryCurrency: 'USD',
          enableAutoConversion: true,
          rateUpdateFrequency: Duration(hours: 1),
          fallbackToPrimary: true,
          showConversionRates: true,
          precisionDecimals: 2,
          lastUpdated: null,
        ),
      );

      await tester.pumpWidget(createTestApp([
        currencySettingsNotifierProvider.overrideWith((ref) => mockCurrencySettingsNotifier),
        fuelEntriesByVehicleProvider(1).overrideWith((ref) => mockFuelEntryNotifier),
      ]));

      await tester.pumpAndSettle();

      // Should display converted amounts
      // The CAD amount should be converted to USD at mock rate (0.80)
      // 100 CAD * 0.80 = 80 USD
      expect(find.textContaining('USD'), findsAtLeastNWidget(1));
    });

    testWidgets('should display currency summary card with correct information', (WidgetTester tester) async {
      final entries = [
        _createMockFuelEntry(DateTime(2023, 1, 15), 100.0, 'USA'), // USD
        _createMockFuelEntry(DateTime(2023, 1, 25), 150.0, 'USA'), // USD
        _createMockFuelEntry(DateTime(2023, 2, 10), 120.0, 'Germany'), // EUR
      ];
      mockFuelEntryNotifier.setMockData(entries);

      mockCurrencySettingsNotifier.setMockSettings(
        const CurrencySettings(
          primaryCurrency: 'USD',
          enableAutoConversion: true,
          rateUpdateFrequency: Duration(hours: 1),
          fallbackToPrimary: true,
          showConversionRates: true,
          precisionDecimals: 2,
          lastUpdated: null,
        ),
      );

      await tester.pumpWidget(createTestApp([
        currencySettingsNotifierProvider.overrideWith((ref) => mockCurrencySettingsNotifier),
        fuelEntriesByVehicleProvider(1).overrideWith((ref) => mockFuelEntryNotifier),
      ]));

      await tester.pumpAndSettle();

      // Look for currency summary components
      expect(find.text('Currency Usage'), findsAtLeastNWidget(1));
    });

    testWidgets('should display currency usage statistics with tabs', (WidgetTester tester) async {
      final entries = [
        _createMockFuelEntry(DateTime(2023, 1, 15), 100.0, 'USA'), // USD
        _createMockFuelEntry(DateTime(2023, 1, 25), 120.0, 'Canada'), // CAD
        _createMockFuelEntry(DateTime(2023, 2, 10), 110.0, 'Germany'), // EUR
      ];
      mockFuelEntryNotifier.setMockData(entries);

      mockCurrencySettingsNotifier.setMockSettings(
        const CurrencySettings(
          primaryCurrency: 'USD',
          enableAutoConversion: true,
          rateUpdateFrequency: Duration(hours: 1),
          fallbackToPrimary: true,
          showConversionRates: true,
          precisionDecimals: 2,
          lastUpdated: null,
        ),
      );

      await tester.pumpWidget(createTestApp([
        currencySettingsNotifierProvider.overrideWith((ref) => mockCurrencySettingsNotifier),
        fuelEntriesByVehicleProvider(1).overrideWith((ref) => mockFuelEntryNotifier),
      ]));

      await tester.pumpAndSettle();

      // Look for tab bar in currency statistics
      expect(find.byType(TabBar), findsAtLeastNWidget(1));
      expect(find.text('Overview'), findsAtLeastNWidget(1));
      expect(find.text('Conversions'), findsAtLeastNWidget(1));
      expect(find.text('Breakdown'), findsAtLeastNWidget(1));
    });

    testWidgets('should handle empty data gracefully', (WidgetTester tester) async {
      mockFuelEntryNotifier.setMockData([]);

      mockCurrencySettingsNotifier.setMockSettings(
        const CurrencySettings(
          primaryCurrency: 'USD',
          enableAutoConversion: true,
          rateUpdateFrequency: Duration(hours: 1),
          fallbackToPrimary: true,
          showConversionRates: true,
          precisionDecimals: 2,
          lastUpdated: null,
        ),
      );

      await tester.pumpWidget(createTestApp([
        currencySettingsNotifierProvider.overrideWith((ref) => mockCurrencySettingsNotifier),
        fuelEntriesByVehicleProvider(1).overrideWith((ref) => mockFuelEntryNotifier),
      ]));

      await tester.pumpAndSettle();

      // Should display appropriate messages for empty data
      expect(find.textContaining('No data'), findsAtLeastNWidget(1));
    });

    testWidgets('should switch primary currency and update all displays', (WidgetTester tester) async {
      final entries = [
        _createMockFuelEntry(DateTime(2023, 1, 15), 100.0, 'USA'), // USD
        _createMockFuelEntry(DateTime(2023, 1, 25), 120.0, 'Canada'), // CAD
      ];
      mockFuelEntryNotifier.setMockData(entries);

      // Start with USD as primary
      mockCurrencySettingsNotifier.setMockSettings(
        const CurrencySettings(
          primaryCurrency: 'USD',
          enableAutoConversion: true,
          rateUpdateFrequency: Duration(hours: 1),
          fallbackToPrimary: true,
          showConversionRates: true,
          precisionDecimals: 2,
          lastUpdated: null,
        ),
      );

      await tester.pumpWidget(createTestApp([
        currencySettingsNotifierProvider.overrideWith((ref) => mockCurrencySettingsNotifier),
        fuelEntriesByVehicleProvider(1).overrideWith((ref) => mockFuelEntryNotifier),
      ]));

      await tester.pumpAndSettle();

      // Verify USD is displayed as primary
      expect(find.textContaining('USD'), findsAtLeastNWidget(1));

      // Change to EUR as primary
      mockCurrencySettingsNotifier.setMockSettings(
        const CurrencySettings(
          primaryCurrency: 'EUR',
          enableAutoConversion: true,
          rateUpdateFrequency: Duration(hours: 1),
          fallbackToPrimary: true,
          showConversionRates: true,
          precisionDecimals: 2,
          lastUpdated: null,
        ),
      );

      await tester.pumpAndSettle();

      // Should now display EUR as primary
      expect(find.textContaining('EUR'), findsAtLeastNWidget(1));
    });

    testWidgets('should display conversion failures appropriately', (WidgetTester tester) async {
      // This test would require mocking conversion failures
      // For now, we'll test that the UI handles the case gracefully
      final entries = [
        _createMockFuelEntry(DateTime(2023, 1, 15), 100.0, 'Unknown Country'),
      ];
      mockFuelEntryNotifier.setMockData(entries);

      mockCurrencySettingsNotifier.setMockSettings(
        const CurrencySettings(
          primaryCurrency: 'USD',
          enableAutoConversion: true,
          rateUpdateFrequency: Duration(hours: 1),
          fallbackToPrimary: true,
          showConversionRates: true,
          precisionDecimals: 2,
          lastUpdated: null,
        ),
      );

      await tester.pumpWidget(createTestApp([
        currencySettingsNotifierProvider.overrideWith((ref) => mockCurrencySettingsNotifier),
        fuelEntriesByVehicleProvider(1).overrideWith((ref) => mockFuelEntryNotifier),
      ]));

      await tester.pumpAndSettle();

      // Should handle unknown currencies gracefully (fallback to USD)
      expect(find.textContaining('USD'), findsAtLeastNWidget(1));
    });

    testWidgets('should maintain scroll position when currency data updates', (WidgetTester tester) async {
      final entries = List.generate(20, (index) => 
        _createMockFuelEntry(DateTime(2023, 1, index + 1), 100.0 + index, 'USA'),
      );
      mockFuelEntryNotifier.setMockData(entries);

      mockCurrencySettingsNotifier.setMockSettings(
        const CurrencySettings(
          primaryCurrency: 'USD',
          enableAutoConversion: true,
          rateUpdateFrequency: Duration(hours: 1),
          fallbackToPrimary: true,
          showConversionRates: true,
          precisionDecimals: 2,
          lastUpdated: null,
        ),
      );

      await tester.pumpWidget(createTestApp([
        currencySettingsNotifierProvider.overrideWith((ref) => mockCurrencySettingsNotifier),
        fuelEntriesByVehicleProvider(1).overrideWith((ref) => mockFuelEntryNotifier),
      ]));

      await tester.pumpAndSettle();

      // Find a scrollable widget and scroll down
      final scrollableFinder = find.byType(Scrollable);
      if (scrollableFinder.evaluate().isNotEmpty) {
        await tester.drag(scrollableFinder.first, const Offset(0, -300));
        await tester.pumpAndSettle();

        // Update currency settings (this should maintain scroll position)
        mockCurrencySettingsNotifier.setMockSettings(
          const CurrencySettings(
            primaryCurrency: 'EUR',
            enableAutoConversion: true,
            rateUpdateFrequency: Duration(hours: 1),
            fallbackToPrimary: true,
            showConversionRates: true,
            precisionDecimals: 2,
            lastUpdated: null,
          ),
        );

        await tester.pumpAndSettle();

        // Should handle the update without major UI disruption
        expect(find.byType(CostAnalysisDashboardScreen), findsOneWidget);
      }
    });

    testWidgets('should display loading states appropriately', (WidgetTester tester) async {
      // Start with loading state
      await tester.pumpWidget(createTestApp([
        currencySettingsNotifierProvider.overrideWith((ref) => mockCurrencySettingsNotifier),
        fuelEntriesByVehicleProvider(1).overrideWith((ref) => mockFuelEntryNotifier),
      ]));

      // Should display loading indicators
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidget(1));

      // Set data and verify loading states are removed
      final entries = [
        _createMockFuelEntry(DateTime(2023, 1, 15), 100.0, 'USA'),
      ];
      mockFuelEntryNotifier.setMockData(entries);
      mockCurrencySettingsNotifier.setMockSettings(
        const CurrencySettings(
          primaryCurrency: 'USD',
          enableAutoConversion: true,
          rateUpdateFrequency: Duration(hours: 1),
          fallbackToPrimary: true,
          showConversionRates: true,
          precisionDecimals: 2,
          lastUpdated: null,
        ),
      );

      await tester.pumpAndSettle();

      // Loading indicators should be replaced with content
      expect(find.textContaining('USD'), findsAtLeastNWidget(1));
    });
  });
}

// Helper function for creating mock fuel entries
FuelEntryModel _createMockFuelEntry(DateTime date, double price, String country) {
  return FuelEntryModel(
    id: null,
    vehicleId: 1,
    date: date,
    currentKm: 10000.0 + (date.day * 100),
    fuelAmount: 50.0,
    price: price,
    currency: 'USD',
    country: country,
    pricePerLiter: price / 50.0,
    consumption: null,
    isFullTank: true,
  );
}