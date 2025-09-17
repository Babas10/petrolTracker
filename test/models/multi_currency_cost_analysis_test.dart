/// Unit tests for multi-currency cost analysis models
import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/models/multi_currency_cost_analysis.dart';
import 'package:petrol_tracker/services/currency_service.dart';

void main() {
  group('CurrencyAwareAmount Tests', () {
    test('should create same currency amount correctly', () {
      final amount = CurrencyAwareAmount.sameAs(
        amount: 100.0,
        currency: 'USD',
      );

      expect(amount.originalAmount, equals(100.0));
      expect(amount.originalCurrency, equals('USD'));
      expect(amount.convertedAmount, equals(100.0));
      expect(amount.targetCurrency, equals('USD'));
      expect(amount.exchangeRate, equals(1.0));
      expect(amount.conversionFailed, isFalse);
      expect(amount.isConverted, isTrue);
      expect(amount.needsConversion, isFalse);
      expect(amount.displayAmount, equals(100.0));
      expect(amount.displayCurrency, equals('USD'));
    });

    test('should create from conversion correctly', () {
      final conversion = CurrencyConversion(
        originalAmount: 100.0,
        originalCurrency: 'USD',
        convertedAmount: 85.0,
        targetCurrency: 'EUR',
        exchangeRate: 0.85,
        rateDate: DateTime.now(),
      );

      final amount = CurrencyAwareAmount.fromConversion(
        originalAmount: 100.0,
        originalCurrency: 'USD',
        conversion: conversion,
      );

      expect(amount.originalAmount, equals(100.0));
      expect(amount.originalCurrency, equals('USD'));
      expect(amount.convertedAmount, equals(85.0));
      expect(amount.targetCurrency, equals('EUR'));
      expect(amount.exchangeRate, equals(0.85));
      expect(amount.conversionFailed, isFalse);
      expect(amount.isConverted, isTrue);
      expect(amount.needsConversion, isTrue);
      expect(amount.displayAmount, equals(85.0));
      expect(amount.displayCurrency, equals('EUR'));
    });

    test('should create failed conversion correctly', () {
      final amount = CurrencyAwareAmount.conversionFailed(
        originalAmount: 100.0,
        originalCurrency: 'USD',
        targetCurrency: 'EUR',
      );

      expect(amount.originalAmount, equals(100.0));
      expect(amount.originalCurrency, equals('USD'));
      expect(amount.convertedAmount, isNull);
      expect(amount.targetCurrency, equals('EUR'));
      expect(amount.exchangeRate, isNull);
      expect(amount.conversionFailed, isTrue);
      expect(amount.isConverted, isFalse);
      expect(amount.needsConversion, isTrue);
      expect(amount.displayAmount, equals(100.0)); // Falls back to original
      expect(amount.displayCurrency, equals('EUR')); // Shows target currency
    });

    test('should format display strings correctly', () {
      final amount = CurrencyAwareAmount.sameAs(
        amount: 123.456,
        currency: 'USD',
      );

      expect(amount.toDisplayString(), equals('123.46 USD'));
      expect(amount.toDisplayString(decimalPlaces: 1), equals('123.5 USD'));
      expect(amount.toDisplayString(decimalPlaces: 0), equals('123 USD'));
    });

    test('should format transparency strings correctly', () {
      final conversion = CurrencyConversion(
        originalAmount: 100.0,
        originalCurrency: 'USD',
        convertedAmount: 85.0,
        targetCurrency: 'EUR',
        exchangeRate: 0.85,
        rateDate: DateTime.now(),
      );

      final amount = CurrencyAwareAmount.fromConversion(
        originalAmount: 100.0,
        originalCurrency: 'USD',
        conversion: conversion,
      );

      final transparencyString = amount.toTransparencyString();
      expect(transparencyString, contains('85.00 EUR'));
      expect(transparencyString, contains('from 100.00 USD'));
      expect(transparencyString, contains('@ 0.8500'));
    });

    test('should handle JSON serialization correctly', () {
      final amount = CurrencyAwareAmount.fromConversion(
        originalAmount: 100.0,
        originalCurrency: 'USD',
        conversion: CurrencyConversion(
          originalAmount: 100.0,
          originalCurrency: 'USD',
          convertedAmount: 85.0,
          targetCurrency: 'EUR',
          exchangeRate: 0.85,
          rateDate: DateTime(2023, 12, 1),
        ),
      );

      final json = amount.toJson();
      final restored = CurrencyAwareAmount.fromJson(json);

      expect(restored.originalAmount, equals(amount.originalAmount));
      expect(restored.originalCurrency, equals(amount.originalCurrency));
      expect(restored.convertedAmount, equals(amount.convertedAmount));
      expect(restored.targetCurrency, equals(amount.targetCurrency));
      expect(restored.exchangeRate, equals(amount.exchangeRate));
      expect(restored.conversionFailed, equals(amount.conversionFailed));
    });

    test('should handle equality correctly', () {
      final amount1 = CurrencyAwareAmount.sameAs(amount: 100.0, currency: 'USD');
      final amount2 = CurrencyAwareAmount.sameAs(amount: 100.0, currency: 'USD');
      final amount3 = CurrencyAwareAmount.sameAs(amount: 200.0, currency: 'USD');

      expect(amount1, equals(amount2));
      expect(amount1, isNot(equals(amount3)));
      expect(amount1.hashCode, equals(amount2.hashCode));
    });
  });

  group('MultiCurrencySpendingStats Tests', () {
    test('should detect conversion failures correctly', () {
      final successfulAmount = CurrencyAwareAmount.sameAs(amount: 100.0, currency: 'USD');
      final failedAmount = CurrencyAwareAmount.conversionFailed(
        originalAmount: 50.0,
        originalCurrency: 'XYZ',
        targetCurrency: 'USD',
      );

      final stats = MultiCurrencySpendingStats(
        totalSpent: successfulAmount,
        averagePerFillUp: failedAmount,
        averagePerMonth: successfulAmount,
        mostExpensiveFillUp: successfulAmount,
        cheapestFillUp: successfulAmount,
        totalFillUps: 10,
        totalCountries: 2,
        totalCurrencies: 3,
        mostExpensiveCountry: 'Country A',
        cheapestCountry: 'Country B',
        countrySpending: {},
        currencyBreakdown: {'USD': successfulAmount, 'XYZ': failedAmount},
        primaryCurrency: 'USD',
        calculatedAt: DateTime.now(),
      );

      expect(stats.hasConversionFailures, isTrue);
      expect(stats.failedCurrencies, contains('XYZ'));
      expect(stats.failedCurrencies, hasLength(1));
    });

    test('should handle JSON serialization correctly', () {
      final amount = CurrencyAwareAmount.sameAs(amount: 100.0, currency: 'USD');
      final now = DateTime.now();

      final stats = MultiCurrencySpendingStats(
        totalSpent: amount,
        averagePerFillUp: amount,
        averagePerMonth: amount,
        mostExpensiveFillUp: amount,
        cheapestFillUp: amount,
        totalFillUps: 10,
        totalCountries: 2,
        totalCurrencies: 1,
        mostExpensiveCountry: 'Country A',
        cheapestCountry: 'Country B',
        countrySpending: {'Country A': amount},
        currencyBreakdown: {'USD': amount},
        primaryCurrency: 'USD',
        calculatedAt: now,
      );

      final json = stats.toJson();
      final restored = MultiCurrencySpendingStats.fromJson(json);

      expect(restored.totalSpent, equals(stats.totalSpent));
      expect(restored.totalFillUps, equals(stats.totalFillUps));
      expect(restored.primaryCurrency, equals(stats.primaryCurrency));
      expect(restored.calculatedAt.millisecondsSinceEpoch, equals(now.millisecondsSinceEpoch));
    });
  });

  group('MultiCurrencySpendingDataPoint Tests', () {
    test('should create and serialize correctly', () {
      final amount = CurrencyAwareAmount.sameAs(amount: 150.0, currency: 'EUR');
      final date = DateTime(2023, 12, 1);

      final dataPoint = MultiCurrencySpendingDataPoint(
        date: date,
        amount: amount,
        country: 'Germany',
        periodLabel: 'Dec 2023',
      );

      expect(dataPoint.date, equals(date));
      expect(dataPoint.amount, equals(amount));
      expect(dataPoint.country, equals('Germany'));
      expect(dataPoint.periodLabel, equals('Dec 2023'));

      // Test JSON serialization
      final json = dataPoint.toJson();
      final restored = MultiCurrencySpendingDataPoint.fromJson(json);

      expect(restored.date, equals(dataPoint.date));
      expect(restored.amount, equals(dataPoint.amount));
      expect(restored.country, equals(dataPoint.country));
      expect(restored.periodLabel, equals(dataPoint.periodLabel));
    });

    test('should handle equality correctly', () {
      final amount = CurrencyAwareAmount.sameAs(amount: 150.0, currency: 'EUR');
      final date = DateTime(2023, 12, 1);

      final dataPoint1 = MultiCurrencySpendingDataPoint(
        date: date,
        amount: amount,
        country: 'Germany',
        periodLabel: 'Dec 2023',
      );

      final dataPoint2 = MultiCurrencySpendingDataPoint(
        date: date,
        amount: amount,
        country: 'Germany',
        periodLabel: 'Dec 2023',
      );

      final dataPoint3 = MultiCurrencySpendingDataPoint(
        date: date,
        amount: amount,
        country: 'France',
        periodLabel: 'Dec 2023',
      );

      expect(dataPoint1, equals(dataPoint2));
      expect(dataPoint1, isNot(equals(dataPoint3)));
      expect(dataPoint1.hashCode, equals(dataPoint2.hashCode));
    });
  });

  group('MultiCurrencyCountrySpendingDataPoint Tests', () {
    test('should detect multi-currency correctly', () {
      final amount = CurrencyAwareAmount.sameAs(amount: 300.0, currency: 'USD');

      final singleCurrencyPoint = MultiCurrencyCountrySpendingDataPoint(
        country: 'USA',
        totalSpent: amount,
        averagePricePerLiter: amount,
        entryCount: 5,
        currenciesUsed: {'USD'},
      );

      final multiCurrencyPoint = MultiCurrencyCountrySpendingDataPoint(
        country: 'Switzerland',
        totalSpent: amount,
        averagePricePerLiter: amount,
        entryCount: 8,
        currenciesUsed: {'CHF', 'EUR'},
      );

      expect(singleCurrencyPoint.isMultiCurrency, isFalse);
      expect(multiCurrencyPoint.isMultiCurrency, isTrue);
    });

    test('should handle JSON serialization correctly', () {
      final amount = CurrencyAwareAmount.sameAs(amount: 300.0, currency: 'USD');

      final dataPoint = MultiCurrencyCountrySpendingDataPoint(
        country: 'Canada',
        totalSpent: amount,
        averagePricePerLiter: amount,
        entryCount: 12,
        currenciesUsed: {'CAD', 'USD'},
      );

      final json = dataPoint.toJson();
      final restored = MultiCurrencyCountrySpendingDataPoint.fromJson(json);

      expect(restored.country, equals(dataPoint.country));
      expect(restored.totalSpent, equals(dataPoint.totalSpent));
      expect(restored.entryCount, equals(dataPoint.entryCount));
      expect(restored.currenciesUsed, equals(dataPoint.currenciesUsed));
      expect(restored.isMultiCurrency, equals(dataPoint.isMultiCurrency));
    });
  });

  group('CurrencyUsageSummary Tests', () {
    test('should calculate usage percentages correctly', () {
      final summary = CurrencyUsageSummary(
        currencyEntryCount: {'USD': 70, 'EUR': 30},
        currencyTotalAmounts: {},
        primaryCurrency: 'USD',
        totalEntries: 100,
        calculatedAt: DateTime.now(),
      );

      final percentages = summary.currencyUsagePercentages;
      expect(percentages['USD'], equals(70.0));
      expect(percentages['EUR'], equals(30.0));
    });

    test('should sort currencies by usage correctly', () {
      final summary = CurrencyUsageSummary(
        currencyEntryCount: {'EUR': 30, 'USD': 70, 'GBP': 10},
        currencyTotalAmounts: {},
        primaryCurrency: 'USD',
        totalEntries: 110,
        calculatedAt: DateTime.now(),
      );

      final sortedCurrencies = summary.currenciesByUsage;
      expect(sortedCurrencies, equals(['USD', 'EUR', 'GBP']));
      expect(summary.mostUsedCurrency, equals('USD'));
    });

    test('should detect multi-currency usage correctly', () {
      final singleCurrencySummary = CurrencyUsageSummary(
        currencyEntryCount: {'USD': 100},
        currencyTotalAmounts: {},
        primaryCurrency: 'USD',
        totalEntries: 100,
        calculatedAt: DateTime.now(),
      );

      final multiCurrencySummary = CurrencyUsageSummary(
        currencyEntryCount: {'USD': 70, 'EUR': 30},
        currencyTotalAmounts: {},
        primaryCurrency: 'USD',
        totalEntries: 100,
        calculatedAt: DateTime.now(),
      );

      expect(singleCurrencySummary.isMultiCurrency, isFalse);
      expect(multiCurrencySummary.isMultiCurrency, isTrue);
    });

    test('should handle JSON serialization correctly', () {
      final amount = CurrencyAwareAmount.sameAs(amount: 500.0, currency: 'USD');
      final now = DateTime.now();

      final summary = CurrencyUsageSummary(
        currencyEntryCount: {'USD': 70, 'EUR': 30},
        currencyTotalAmounts: {'USD': amount},
        primaryCurrency: 'USD',
        totalEntries: 100,
        calculatedAt: now,
      );

      final json = summary.toJson();
      final restored = CurrencyUsageSummary.fromJson(json);

      expect(restored.currencyEntryCount, equals(summary.currencyEntryCount));
      expect(restored.primaryCurrency, equals(summary.primaryCurrency));
      expect(restored.totalEntries, equals(summary.totalEntries));
      expect(restored.calculatedAt.millisecondsSinceEpoch, equals(now.millisecondsSinceEpoch));
    });
  });
}