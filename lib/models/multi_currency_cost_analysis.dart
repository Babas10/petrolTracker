/// Multi-currency cost analysis models for Issue #129
/// 
/// This file contains data models for handling cost analysis with multiple
/// currencies, including conversion tracking and transparency features.
library;

import 'package:petrol_tracker/services/currency_service.dart';

/// Represents a cost amount with its original currency and converted values
class CurrencyAwareAmount {
  final double originalAmount;
  final String originalCurrency;
  final double? convertedAmount;
  final String? targetCurrency;
  final double? exchangeRate;
  final DateTime? rateDate;
  final bool conversionFailed;

  const CurrencyAwareAmount({
    required this.originalAmount,
    required this.originalCurrency,
    this.convertedAmount,
    this.targetCurrency,
    this.exchangeRate,
    this.rateDate,
    this.conversionFailed = false,
  });

  /// Creates an amount that doesn't need conversion (same currency)
  factory CurrencyAwareAmount.sameAs({
    required double amount,
    required String currency,
  }) {
    return CurrencyAwareAmount(
      originalAmount: amount,
      originalCurrency: currency,
      convertedAmount: amount,
      targetCurrency: currency,
      exchangeRate: 1.0,
      rateDate: DateTime.now(),
    );
  }

  /// Creates an amount from a successful conversion
  factory CurrencyAwareAmount.fromConversion({
    required double originalAmount,
    required String originalCurrency,
    required CurrencyConversion conversion,
  }) {
    return CurrencyAwareAmount(
      originalAmount: originalAmount,
      originalCurrency: originalCurrency,
      convertedAmount: conversion.convertedAmount,
      targetCurrency: conversion.targetCurrency,
      exchangeRate: conversion.exchangeRate,
      rateDate: conversion.rateDate,
    );
  }

  /// Creates an amount where conversion failed
  factory CurrencyAwareAmount.conversionFailed({
    required double originalAmount,
    required String originalCurrency,
    required String targetCurrency,
  }) {
    return CurrencyAwareAmount(
      originalAmount: originalAmount,
      originalCurrency: originalCurrency,
      targetCurrency: targetCurrency,
      conversionFailed: true,
    );
  }

  /// The amount to display (converted if available, original otherwise)
  double get displayAmount => convertedAmount ?? originalAmount;

  /// The currency to display with the amount
  String get displayCurrency => targetCurrency ?? originalCurrency;

  /// Whether this amount was successfully converted
  bool get isConverted => convertedAmount != null && !conversionFailed;

  /// Whether this amount needs conversion (different currencies)
  bool get needsConversion => originalCurrency != targetCurrency;

  /// Formatted string for display
  String toDisplayString({int decimalPlaces = 2}) {
    return '${displayAmount.toStringAsFixed(decimalPlaces)} ${displayCurrency}';
  }

  /// Formatted string showing conversion transparency
  String toTransparencyString({int decimalPlaces = 2}) {
    if (!needsConversion || conversionFailed) {
      return toDisplayString(decimalPlaces: decimalPlaces);
    }

    final original = '${originalAmount.toStringAsFixed(decimalPlaces)} $originalCurrency';
    final converted = '${convertedAmount!.toStringAsFixed(decimalPlaces)} $targetCurrency';
    final rate = exchangeRate!.toStringAsFixed(4);
    
    return '$converted (from $original @ $rate)';
  }

  Map<String, dynamic> toJson() => {
    'originalAmount': originalAmount,
    'originalCurrency': originalCurrency,
    'convertedAmount': convertedAmount,
    'targetCurrency': targetCurrency,
    'exchangeRate': exchangeRate,
    'rateDate': rateDate?.toIso8601String(),
    'conversionFailed': conversionFailed,
  };

  factory CurrencyAwareAmount.fromJson(Map<String, dynamic> json) {
    return CurrencyAwareAmount(
      originalAmount: (json['originalAmount'] as num).toDouble(),
      originalCurrency: json['originalCurrency'] as String,
      convertedAmount: json['convertedAmount'] != null 
          ? (json['convertedAmount'] as num).toDouble() 
          : null,
      targetCurrency: json['targetCurrency'] as String?,
      exchangeRate: json['exchangeRate'] != null 
          ? (json['exchangeRate'] as num).toDouble() 
          : null,
      rateDate: json['rateDate'] != null 
          ? DateTime.parse(json['rateDate'] as String) 
          : null,
      conversionFailed: json['conversionFailed'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencyAwareAmount &&
        other.originalAmount == originalAmount &&
        other.originalCurrency == originalCurrency &&
        other.convertedAmount == convertedAmount &&
        other.targetCurrency == targetCurrency &&
        other.exchangeRate == exchangeRate &&
        other.conversionFailed == conversionFailed;
  }

  @override
  int get hashCode => Object.hash(
        originalAmount,
        originalCurrency,
        convertedAmount,
        targetCurrency,
        exchangeRate,
        conversionFailed,
      );

  @override
  String toString() => toTransparencyString();
}

/// Multi-currency spending statistics for cost analysis
class MultiCurrencySpendingStats {
  final CurrencyAwareAmount totalSpent;
  final CurrencyAwareAmount averagePerFillUp;
  final CurrencyAwareAmount averagePerMonth;
  final CurrencyAwareAmount mostExpensiveFillUp;
  final CurrencyAwareAmount cheapestFillUp;
  final int totalFillUps;
  final int totalCountries;
  final int totalCurrencies;
  final String mostExpensiveCountry;
  final String cheapestCountry;
  final Map<String, CurrencyAwareAmount> countrySpending;
  final Map<String, CurrencyAwareAmount> currencyBreakdown;
  final String primaryCurrency;
  final DateTime calculatedAt;

  const MultiCurrencySpendingStats({
    required this.totalSpent,
    required this.averagePerFillUp,
    required this.averagePerMonth,
    required this.mostExpensiveFillUp,
    required this.cheapestFillUp,
    required this.totalFillUps,
    required this.totalCountries,
    required this.totalCurrencies,
    required this.mostExpensiveCountry,
    required this.cheapestCountry,
    required this.countrySpending,
    required this.currencyBreakdown,
    required this.primaryCurrency,
    required this.calculatedAt,
  });

  /// Whether any conversions failed in these statistics
  bool get hasConversionFailures {
    return totalSpent.conversionFailed ||
           averagePerFillUp.conversionFailed ||
           averagePerMonth.conversionFailed ||
           mostExpensiveFillUp.conversionFailed ||
           cheapestFillUp.conversionFailed ||
           countrySpending.values.any((amount) => amount.conversionFailed) ||
           currencyBreakdown.values.any((amount) => amount.conversionFailed);
  }

  /// List of currencies that had conversion failures
  List<String> get failedCurrencies {
    final failed = <String>{};
    
    if (totalSpent.conversionFailed) failed.add(totalSpent.originalCurrency);
    if (averagePerFillUp.conversionFailed) failed.add(averagePerFillUp.originalCurrency);
    if (averagePerMonth.conversionFailed) failed.add(averagePerMonth.originalCurrency);
    if (mostExpensiveFillUp.conversionFailed) failed.add(mostExpensiveFillUp.originalCurrency);
    if (cheapestFillUp.conversionFailed) failed.add(cheapestFillUp.originalCurrency);
    
    for (final amount in countrySpending.values) {
      if (amount.conversionFailed) failed.add(amount.originalCurrency);
    }
    
    for (final amount in currencyBreakdown.values) {
      if (amount.conversionFailed) failed.add(amount.originalCurrency);
    }
    
    return failed.toList();
  }

  Map<String, dynamic> toJson() => {
    'totalSpent': totalSpent.toJson(),
    'averagePerFillUp': averagePerFillUp.toJson(),
    'averagePerMonth': averagePerMonth.toJson(),
    'mostExpensiveFillUp': mostExpensiveFillUp.toJson(),
    'cheapestFillUp': cheapestFillUp.toJson(),
    'totalFillUps': totalFillUps,
    'totalCountries': totalCountries,
    'totalCurrencies': totalCurrencies,
    'mostExpensiveCountry': mostExpensiveCountry,
    'cheapestCountry': cheapestCountry,
    'countrySpending': countrySpending.map((k, v) => MapEntry(k, v.toJson())),
    'currencyBreakdown': currencyBreakdown.map((k, v) => MapEntry(k, v.toJson())),
    'primaryCurrency': primaryCurrency,
    'calculatedAt': calculatedAt.toIso8601String(),
  };

  factory MultiCurrencySpendingStats.fromJson(Map<String, dynamic> json) {
    return MultiCurrencySpendingStats(
      totalSpent: CurrencyAwareAmount.fromJson(json['totalSpent'] as Map<String, dynamic>),
      averagePerFillUp: CurrencyAwareAmount.fromJson(json['averagePerFillUp'] as Map<String, dynamic>),
      averagePerMonth: CurrencyAwareAmount.fromJson(json['averagePerMonth'] as Map<String, dynamic>),
      mostExpensiveFillUp: CurrencyAwareAmount.fromJson(json['mostExpensiveFillUp'] as Map<String, dynamic>),
      cheapestFillUp: CurrencyAwareAmount.fromJson(json['cheapestFillUp'] as Map<String, dynamic>),
      totalFillUps: json['totalFillUps'] as int,
      totalCountries: json['totalCountries'] as int,
      totalCurrencies: json['totalCurrencies'] as int,
      mostExpensiveCountry: json['mostExpensiveCountry'] as String,
      cheapestCountry: json['cheapestCountry'] as String,
      countrySpending: (json['countrySpending'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, CurrencyAwareAmount.fromJson(v as Map<String, dynamic>)),
      ),
      currencyBreakdown: (json['currencyBreakdown'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, CurrencyAwareAmount.fromJson(v as Map<String, dynamic>)),
      ),
      primaryCurrency: json['primaryCurrency'] as String,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'MultiCurrencySpendingStats(totalSpent: $totalSpent, '
           'totalFillUps: $totalFillUps, primaryCurrency: $primaryCurrency)';
  }
}

/// Data point for multi-currency spending charts
class MultiCurrencySpendingDataPoint {
  final DateTime date;
  final CurrencyAwareAmount amount;
  final String country;
  final String periodLabel;

  const MultiCurrencySpendingDataPoint({
    required this.date,
    required this.amount,
    required this.country,
    required this.periodLabel,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'amount': amount.toJson(),
    'country': country,
    'periodLabel': periodLabel,
  };

  factory MultiCurrencySpendingDataPoint.fromJson(Map<String, dynamic> json) {
    return MultiCurrencySpendingDataPoint(
      date: DateTime.parse(json['date'] as String),
      amount: CurrencyAwareAmount.fromJson(json['amount'] as Map<String, dynamic>),
      country: json['country'] as String,
      periodLabel: json['periodLabel'] as String,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MultiCurrencySpendingDataPoint &&
        other.date == date &&
        other.amount == amount &&
        other.country == country &&
        other.periodLabel == periodLabel;
  }

  @override
  int get hashCode => Object.hash(date, amount, country, periodLabel);

  @override
  String toString() {
    return 'MultiCurrencySpendingDataPoint(date: $date, amount: $amount, country: $country)';
  }
}

/// Data point for multi-currency country spending comparison
class MultiCurrencyCountrySpendingDataPoint {
  final String country;
  final CurrencyAwareAmount totalSpent;
  final CurrencyAwareAmount averagePricePerLiter;
  final int entryCount;
  final Set<String> currenciesUsed;

  const MultiCurrencyCountrySpendingDataPoint({
    required this.country,
    required this.totalSpent,
    required this.averagePricePerLiter,
    required this.entryCount,
    required this.currenciesUsed,
  });

  /// Whether this country data involves multiple currencies
  bool get isMultiCurrency => currenciesUsed.length > 1;

  Map<String, dynamic> toJson() => {
    'country': country,
    'totalSpent': totalSpent.toJson(),
    'averagePricePerLiter': averagePricePerLiter.toJson(),
    'entryCount': entryCount,
    'currenciesUsed': currenciesUsed.toList(),
  };

  factory MultiCurrencyCountrySpendingDataPoint.fromJson(Map<String, dynamic> json) {
    return MultiCurrencyCountrySpendingDataPoint(
      country: json['country'] as String,
      totalSpent: CurrencyAwareAmount.fromJson(json['totalSpent'] as Map<String, dynamic>),
      averagePricePerLiter: CurrencyAwareAmount.fromJson(json['averagePricePerLiter'] as Map<String, dynamic>),
      entryCount: json['entryCount'] as int,
      currenciesUsed: (json['currenciesUsed'] as List<dynamic>).cast<String>().toSet(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MultiCurrencyCountrySpendingDataPoint &&
        other.country == country &&
        other.totalSpent == totalSpent &&
        other.averagePricePerLiter == averagePricePerLiter &&
        other.entryCount == entryCount &&
        other.currenciesUsed.length == currenciesUsed.length &&
        other.currenciesUsed.every((c) => currenciesUsed.contains(c));
  }

  @override
  int get hashCode => Object.hash(country, totalSpent, averagePricePerLiter, entryCount, currenciesUsed);

  @override
  String toString() {
    return 'MultiCurrencyCountrySpendingDataPoint(country: $country, totalSpent: $totalSpent, '
           'entryCount: $entryCount, currencies: ${currenciesUsed.join(", ")})';
  }
}

/// Summary of currency usage across entries
class CurrencyUsageSummary {
  final Map<String, int> currencyEntryCount;
  final Map<String, CurrencyAwareAmount> currencyTotalAmounts;
  final String primaryCurrency;
  final int totalEntries;
  final DateTime calculatedAt;

  const CurrencyUsageSummary({
    required this.currencyEntryCount,
    required this.currencyTotalAmounts,
    required this.primaryCurrency,
    required this.totalEntries,
    required this.calculatedAt,
  });

  /// Get the percentage of entries using each currency
  Map<String, double> get currencyUsagePercentages {
    if (totalEntries == 0) return {};
    
    return currencyEntryCount.map(
      (currency, count) => MapEntry(currency, count / totalEntries * 100),
    );
  }

  /// Get currencies sorted by usage frequency
  List<String> get currenciesByUsage {
    final entries = currencyEntryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => e.key).toList();
  }

  /// Get the most frequently used currency
  String? get mostUsedCurrency {
    if (currencyEntryCount.isEmpty) return null;
    return currenciesByUsage.first;
  }

  /// Whether multiple currencies are used
  bool get isMultiCurrency => currencyEntryCount.length > 1;

  Map<String, dynamic> toJson() => {
    'currencyEntryCount': currencyEntryCount,
    'currencyTotalAmounts': currencyTotalAmounts.map((k, v) => MapEntry(k, v.toJson())),
    'primaryCurrency': primaryCurrency,
    'totalEntries': totalEntries,
    'calculatedAt': calculatedAt.toIso8601String(),
  };

  factory CurrencyUsageSummary.fromJson(Map<String, dynamic> json) {
    return CurrencyUsageSummary(
      currencyEntryCount: (json['currencyEntryCount'] as Map<String, dynamic>).cast<String, int>(),
      currencyTotalAmounts: (json['currencyTotalAmounts'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, CurrencyAwareAmount.fromJson(v as Map<String, dynamic>)),
      ),
      primaryCurrency: json['primaryCurrency'] as String,
      totalEntries: json['totalEntries'] as int,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'CurrencyUsageSummary(currencies: ${currencyEntryCount.length}, '
           'totalEntries: $totalEntries, primaryCurrency: $primaryCurrency)';
  }
}