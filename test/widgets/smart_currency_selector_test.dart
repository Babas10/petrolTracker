import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/widgets/smart_currency_selector.dart';
import 'package:petrol_tracker/models/currency/currency_settings.dart';
import 'package:petrol_tracker/providers/currency_settings_providers.dart';

void main() {
  group('SmartCurrencySelector Tests', () {
    // Create a test currency settings
    final testCurrencySettings = CurrencySettings(
      primaryCurrency: 'USD',
      showOriginalAmounts: true,
      showExchangeRates: false,
      decimalPlaces: 2,
      showConversionIndicators: true,
      autoUpdateRates: false,
      maxRateAgeHours: 24,
      favoriteCurrencies: const ['USD', 'EUR', 'GBP'],
      lastUpdated: DateTime.now(),
    );

    Widget createTestWidget({
      String? selectedCountry,
      String? selectedCurrency,
      Function(String?)? onCurrencyChanged,
    }) {
      return ProviderScope(
        overrides: [
          currencySettingsNotifierProvider.overrideWith(
            () => MockCurrencySettingsNotifier(testCurrencySettings),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SmartCurrencySelector(
              selectedCountry: selectedCountry,
              selectedCurrency: selectedCurrency,
              onCurrencyChanged: onCurrencyChanged ?? (String? currency) {},
            ),
          ),
        ),
      );
    }

    group('Widget Structure', () {
      testWidgets('should display currency dropdown', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
        expect(find.text('Currency *'), findsOneWidget);
        expect(find.byIcon(Icons.attach_money), findsOneWidget);
      });

      testWidgets('should show loading indicator initially', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        
        // Should show loading initially
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
        
        await tester.pumpAndSettle();
        
        // Loading should disappear after settling
        expect(find.byType(LinearProgressIndicator), findsNothing);
      });

      testWidgets('should display hint text based on country selection', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(selectedCountry: null));
        await tester.pumpAndSettle();

        expect(find.textContaining('Select a country'), findsOneWidget);
      });

      testWidgets('should display filtering indicator when country is selected', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(selectedCountry: 'Germany'));
        await tester.pumpAndSettle();

        // Should show filtering information
        expect(find.textContaining('relevant currencies'), findsOneWidget);
      });
    });

    group('Country-Based Filtering', () {
      testWidgets('should filter currencies based on selected country', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(selectedCountry: 'Germany'));
        await tester.pumpAndSettle();

        // Tap the dropdown to see options
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();

        // Should show EUR as first option (primary currency for Germany)
        expect(find.text('EUR'), findsWidgets);
        // Should also show USD (user's default currency)
        expect(find.text('USD'), findsWidgets);
      });

      testWidgets('should show major currencies when no country selected', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(selectedCountry: null));
        await tester.pumpAndSettle();

        // Tap the dropdown to see options
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();

        // Should show major international currencies
        expect(find.text('USD'), findsWidgets);
        expect(find.text('EUR'), findsWidgets);
        expect(find.text('GBP'), findsWidgets);
      });
    });

    group('Visual Indicators', () {
      testWidgets('should show primary currency indicator', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Germany',
          selectedCurrency: 'EUR',
        ));
        await tester.pumpAndSettle();

        // Tap the dropdown to see options
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();

        // Should show location icon for primary currency
        expect(find.byIcon(Icons.location_on), findsWidgets);
      });

      testWidgets('should show filter indicator when currencies are filtered', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(selectedCountry: 'Germany'));
        await tester.pumpAndSettle();

        // Should show filter indicator in suffix
        expect(find.byIcon(Icons.filter_list), findsOneWidget);
      });

      testWidgets('should show filter badge with country name', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(selectedCountry: 'Germany'));
        await tester.pumpAndSettle();

        // Should show filtered badge
        expect(find.textContaining('Filtered for Germany'), findsOneWidget);
      });
    });

    group('Expand Functionality', () {
      testWidgets('should show expand button when currencies are filtered', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(selectedCountry: 'Germany'));
        await tester.pumpAndSettle();

        // Should show expand option
        expect(find.textContaining('Show all'), findsOneWidget);
        expect(find.byIcon(Icons.expand_more), findsOneWidget);
      });

      testWidgets('should expand to show all currencies when tapped', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(selectedCountry: 'Germany'));
        await tester.pumpAndSettle();

        // Tap expand button
        await tester.tap(find.textContaining('Show all'));
        await tester.pumpAndSettle();

        // Should now show all currencies message
        expect(find.textContaining('Showing all'), findsOneWidget);
      });
    });

    group('Currency Selection', () {
      testWidgets('should call onCurrencyChanged when currency is selected', (WidgetTester tester) async {
        String? selectedCurrency;
        
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Germany',
          onCurrencyChanged: (currency) {
            selectedCurrency = currency;
          },
        ));
        await tester.pumpAndSettle();

        // Tap the dropdown
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();

        // Select EUR
        await tester.tap(find.text('EUR').first);
        await tester.pumpAndSettle();

        expect(selectedCurrency, equals('EUR'));
      });

      testWidgets('should validate currency selection', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find the form field and trigger validation
        final formField = tester.widget<DropdownButtonFormField<String>>(
          find.byType(DropdownButtonFormField<String>),
        );
        
        final validationResult = formField.validator?.call(null);
        expect(validationResult, equals('Please select a currency'));
      });
    });

    group('Error Handling', () {
      testWidgets('should handle unknown country gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(selectedCountry: 'Unknown Country'));
        await tester.pumpAndSettle();

        // Should still show dropdown without crashing
        expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
        
        // Should show fallback currencies
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        
        expect(find.text('USD'), findsWidgets);
      });
    });

    group('Accessibility', () {
      testWidgets('should have proper accessibility labels', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(selectedCountry: 'Germany'));
        await tester.pumpAndSettle();

        // Should have semantic labels for screen readers
        expect(find.text('Currency *'), findsOneWidget);
        
        // Dropdown should be properly labeled
        final dropdown = find.byType(DropdownButtonFormField<String>);
        expect(dropdown, findsOneWidget);
      });
    });
  });
}

// Mock class for testing
class MockCurrencySettingsNotifier extends CurrencySettingsNotifier {
  final CurrencySettings _settings;
  
  MockCurrencySettingsNotifier(this._settings);
  
  @override
  Future<CurrencySettings> build() async {
    return _settings;
  }
}