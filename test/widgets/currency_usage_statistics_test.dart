/// Unit tests for currency usage statistics widget
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/widgets/currency_usage_statistics.dart';
import 'package:petrol_tracker/models/multi_currency_cost_analysis.dart';

void main() {
  group('CurrencyUsageStatistics Widget Tests', () {
    late MultiCurrencySpendingStats mockStats;
    late CurrencyUsageSummary mockCurrencyUsage;

    setUp(() {
      mockStats = MultiCurrencySpendingStats(
        totalSpent: CurrencyAwareAmount.sameAs(amount: 1000.0, currency: 'USD'),
        averagePerFillUp: CurrencyAwareAmount.sameAs(amount: 50.0, currency: 'USD'),
        averagePerMonth: CurrencyAwareAmount.sameAs(amount: 200.0, currency: 'USD'),
        mostExpensiveFillUp: CurrencyAwareAmount.sameAs(amount: 80.0, currency: 'USD'),
        cheapestFillUp: CurrencyAwareAmount.sameAs(amount: 30.0, currency: 'USD'),
        totalFillUps: 20,
        totalCountries: 3,
        totalCurrencies: 2,
        mostExpensiveCountry: 'USA',
        cheapestCountry: 'Canada',
        countrySpending: {},
        currencyBreakdown: {
          'USD': CurrencyAwareAmount.sameAs(amount: 700.0, currency: 'USD'),
          'EUR': CurrencyAwareAmount.sameAs(amount: 300.0, currency: 'EUR'),
        },
        primaryCurrency: 'USD',
        calculatedAt: DateTime.now(),
      );

      mockCurrencyUsage = CurrencyUsageSummary(
        currencyEntryCount: {'USD': 14, 'EUR': 6},
        currencyTotalAmounts: {},
        primaryCurrency: 'USD',
        totalEntries: 20,
        calculatedAt: DateTime.now(),
      );
    });

    testWidgets('should display tab bar with correct tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencyUsageStatistics(
              spendingStats: mockStats,
              currencyUsage: mockCurrencyUsage,
              primaryCurrency: 'USD',
              showConversionDetails: true,
            ),
          ),
        ),
      );

      expect(find.byType(TabBar), findsOneWidget);
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Conversions'), findsOneWidget);
      expect(find.text('Breakdown'), findsOneWidget);
    });

    testWidgets('should display overview tab content correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              body: CurrencyUsageStatistics(
                spendingStats: mockStats,
                currencyUsage: mockCurrencyUsage,
                showConversionDetails: true,
              ),
            ),
          ),
        ),
      );

      // Should be on Overview tab by default
      expect(find.text('Total Currencies'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Primary Currency'), findsOneWidget);
      expect(find.text('USD'), findsAtLeast(1));
    });

    testWidgets('should switch to conversions tab correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              body: CurrencyUsageStatistics(
                spendingStats: mockStats,
                currencyUsage: mockCurrencyUsage,
                showConversionDetails: true,
              ),
            ),
          ),
        ),
      );

      // Tap on Conversions tab
      await tester.tap(find.text('Conversions'));
      await tester.pumpAndSettle();

      expect(find.text('Conversion Status'), findsOneWidget);
    });

    testWidgets('should switch to breakdown tab correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              body: CurrencyUsageStatistics(
                spendingStats: mockStats,
                currencyUsage: mockCurrencyUsage,
                showConversionDetails: true,
              ),
            ),
          ),
        ),
      );

      // Tap on Breakdown tab
      await tester.tap(find.text('Breakdown'));
      await tester.pumpAndSettle();

      expect(find.text('Currency Breakdown'), findsOneWidget);
    });

    testWidgets('should display conversion failure warnings when present', (WidgetTester tester) async {
      final statsWithFailures = MultiCurrencySpendingStats(
        totalSpent: CurrencyAwareAmount.sameAs(amount: 1000.0, currency: 'USD'),
        averagePerFillUp: CurrencyAwareAmount.conversionFailed(
          originalAmount: 50.0,
          originalCurrency: 'XYZ',
          targetCurrency: 'USD',
        ),
        averagePerMonth: CurrencyAwareAmount.sameAs(amount: 200.0, currency: 'USD'),
        mostExpensiveFillUp: CurrencyAwareAmount.sameAs(amount: 80.0, currency: 'USD'),
        cheapestFillUp: CurrencyAwareAmount.sameAs(amount: 30.0, currency: 'USD'),
        totalFillUps: 20,
        totalCountries: 3,
        totalCurrencies: 2,
        mostExpensiveCountry: 'USA',
        cheapestCountry: 'Canada',
        countrySpending: {},
        currencyBreakdown: {},
        primaryCurrency: 'USD',
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              body: CurrencyUsageStatistics(
                spendingStats: statsWithFailures,
                currencyUsage: mockCurrencyUsage,
                showConversionDetails: true,
              ),
            ),
          ),
        ),
      );

      // Switch to conversions tab to see failure warnings
      await tester.tap(find.text('Conversions'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.warning), findsAtLeast(1));
    });

    testWidgets('should hide conversion details when showConversionDetails is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              body: CurrencyUsageStatistics(
                spendingStats: mockStats,
                currencyUsage: mockCurrencyUsage,
                showConversionDetails: false,
              ),
            ),
          ),
        ),
      );

      // Should only have 2 tabs when conversion details are hidden
      final tabFinder = find.byType(Tab);
      expect(tabFinder, findsNWidgets(2));
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Breakdown'), findsOneWidget);
      expect(find.text('Conversions'), findsNothing);
    });

    testWidgets('should display currency usage percentages correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              body: CurrencyUsageStatistics(
                spendingStats: mockStats,
                currencyUsage: mockCurrencyUsage,
                showConversionDetails: true,
              ),
            ),
          ),
        ),
      );

      // Switch to breakdown tab
      await tester.tap(find.text('Breakdown'));
      await tester.pumpAndSettle();

      expect(find.text('70.0%'), findsOneWidget); // USD percentage
      expect(find.text('30.0%'), findsOneWidget); // EUR percentage
    });

    testWidgets('should display no data message when stats are empty', (WidgetTester tester) async {
      final emptyStats = MultiCurrencySpendingStats(
        totalSpent: CurrencyAwareAmount.sameAs(amount: 0.0, currency: 'USD'),
        averagePerFillUp: CurrencyAwareAmount.sameAs(amount: 0.0, currency: 'USD'),
        averagePerMonth: CurrencyAwareAmount.sameAs(amount: 0.0, currency: 'USD'),
        mostExpensiveFillUp: CurrencyAwareAmount.sameAs(amount: 0.0, currency: 'USD'),
        cheapestFillUp: CurrencyAwareAmount.sameAs(amount: 0.0, currency: 'USD'),
        totalFillUps: 0,
        totalCountries: 0,
        totalCurrencies: 0,
        mostExpensiveCountry: '',
        cheapestCountry: '',
        countrySpending: {},
        currencyBreakdown: {},
        primaryCurrency: 'USD',
        calculatedAt: DateTime.now(),
      );

      final emptyCurrencyUsage = CurrencyUsageSummary(
        currencyEntryCount: {},
        currencyTotalAmounts: {},
        primaryCurrency: 'USD',
        totalEntries: 0,
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              body: CurrencyUsageStatistics(
                spendingStats: emptyStats,
                currencyUsage: emptyCurrencyUsage,
                showConversionDetails: true,
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('No data'), findsAtLeast(1));
    });

    testWidgets('should be scrollable when content exceeds screen height', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              body: SizedBox(
                height: 200, // Limited height to force scrolling
                child: CurrencyUsageStatistics(
                  spendingStats: mockStats,
                  currencyUsage: mockCurrencyUsage,
                  showConversionDetails: true,
                ),
              ),
            ),
          ),
        ),
      );

      // Look for scrollable widgets
      expect(find.byType(SingleChildScrollView), findsAtLeast(1));
    });

    testWidgets('should display most used currency correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: 3,
            child: Scaffold(
              body: CurrencyUsageStatistics(
                spendingStats: mockStats,
                currencyUsage: mockCurrencyUsage,
                showConversionDetails: true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Most Used'), findsAtLeast(1));
      expect(find.text('USD'), findsAtLeast(1)); // Most used currency
    });
  });
}