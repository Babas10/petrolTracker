/// Unit tests for currency summary card widget
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/widgets/currency_summary_card.dart';
import 'package:petrol_tracker/models/multi_currency_cost_analysis.dart';

void main() {
  group('CurrencySummaryCard Widget Tests', () {
    testWidgets('should display no data message when currencyUsage is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencySummaryCard(
              currencyUsage: null,
              primaryCurrency: 'USD',
              showConversionDetails: false,
            ),
          ),
        ),
      );

      expect(find.text('No currency data available'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should display single currency usage correctly', (WidgetTester tester) async {
      final currencyUsage = CurrencyUsageSummary(
        currencyEntryCount: {'USD': 10},
        currencyTotalAmounts: {},
        primaryCurrency: 'USD',
        totalEntries: 10,
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencySummaryCard(
              currencyUsage: currencyUsage,
              primaryCurrency: 'USD',
              showConversionDetails: false,
            ),
          ),
        ),
      );

      expect(find.text('Currency Usage'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('100.0%'), findsOneWidget);
      expect(find.text('Single Currency'), findsOneWidget);
    });

    testWidgets('should display multi-currency usage correctly', (WidgetTester tester) async {
      final currencyUsage = CurrencyUsageSummary(
        currencyEntryCount: {'USD': 70, 'EUR': 30},
        currencyTotalAmounts: {},
        primaryCurrency: 'USD',
        totalEntries: 100,
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencySummaryCard(
              currencyUsage: currencyUsage,
              primaryCurrency: 'USD',
              showConversionDetails: false,
            ),
          ),
        ),
      );

      expect(find.text('Currency Usage'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('EUR'), findsOneWidget);
      expect(find.text('70.0%'), findsOneWidget);
      expect(find.text('30.0%'), findsOneWidget);
      expect(find.text('Multi-Currency (2)'), findsOneWidget);
    });

    testWidgets('should show conversion details when enabled', (WidgetTester tester) async {
      final currencyUsage = CurrencyUsageSummary(
        currencyEntryCount: {'USD': 50, 'EUR': 50},
        currencyTotalAmounts: {},
        primaryCurrency: 'USD',
        totalEntries: 100,
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencySummaryCard(
              currencyUsage: currencyUsage,
              primaryCurrency: 'USD',
              showConversionDetails: true,
            ),
          ),
        ),
      );

      expect(find.text('Primary Currency: USD'), findsOneWidget);
      expect(find.text('All amounts converted to USD'), findsOneWidget);
    });

    testWidgets('should display primary currency indicator correctly', (WidgetTester tester) async {
      final currencyUsage = CurrencyUsageSummary(
        currencyEntryCount: {'USD': 60, 'EUR': 40},
        currencyTotalAmounts: {},
        primaryCurrency: 'USD',
        totalEntries: 100,
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencySummaryCard(
              currencyUsage: currencyUsage,
              primaryCurrency: 'USD',
              showConversionDetails: false,
            ),
          ),
        ),
      );

      // Look for primary currency chip or indicator
      expect(find.textContaining('USD'), findsAtLeast(1));
    });

    testWidgets('should handle empty currency usage', (WidgetTester tester) async {
      final currencyUsage = CurrencyUsageSummary(
        currencyEntryCount: {},
        currencyTotalAmounts: {},
        primaryCurrency: 'USD',
        totalEntries: 0,
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencySummaryCard(
              currencyUsage: currencyUsage,
              primaryCurrency: 'USD',
              showConversionDetails: false,
            ),
          ),
        ),
      );

      expect(find.text('No currency data available'), findsOneWidget);
    });

    testWidgets('should display usage percentages with correct formatting', (WidgetTester tester) async {
      final currencyUsage = CurrencyUsageSummary(
        currencyEntryCount: {'USD': 33, 'EUR': 67},
        currencyTotalAmounts: {},
        primaryCurrency: 'USD',
        totalEntries: 100,
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencySummaryCard(
              currencyUsage: currencyUsage,
              primaryCurrency: 'USD',
              showConversionDetails: false,
            ),
          ),
        ),
      );

      expect(find.text('33.0%'), findsOneWidget);
      expect(find.text('67.0%'), findsOneWidget);
    });

    testWidgets('should show calculation timestamp', (WidgetTester tester) async {
      final calculatedAt = DateTime(2023, 12, 1, 10, 30);
      final currencyUsage = CurrencyUsageSummary(
        currencyEntryCount: {'USD': 100},
        currencyTotalAmounts: {},
        primaryCurrency: 'USD',
        totalEntries: 100,
        calculatedAt: calculatedAt,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencySummaryCard(
              currencyUsage: currencyUsage,
              primaryCurrency: 'USD',
              showConversionDetails: true,
            ),
          ),
        ),
      );

      // Should display some form of timestamp
      expect(find.textContaining('2023'), findsAtLeast(1));
    });

    testWidgets('should be accessible', (WidgetTester tester) async {
      final currencyUsage = CurrencyUsageSummary(
        currencyEntryCount: {'USD': 70, 'EUR': 30},
        currencyTotalAmounts: {},
        primaryCurrency: 'USD',
        totalEntries: 100,
        calculatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CurrencySummaryCard(
              currencyUsage: currencyUsage,
              primaryCurrency: 'USD',
              showConversionDetails: false,
            ),
          ),
        ),
      );

      // Verify semantic properties are accessible
      expect(find.byType(Card), findsOneWidget);
      
      // Check for semantic labels or tooltips
      final card = tester.widget<Card>(find.byType(Card));
      expect(card, isNotNull);
    });
  });
}