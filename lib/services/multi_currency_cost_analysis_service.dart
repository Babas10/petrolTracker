/// Multi-currency cost analysis service for Issue #129
/// 
/// This service handles conversion of fuel entry costs to a user's primary
/// currency for unified cost analysis while maintaining transparency about
/// original amounts and exchange rates.
library;

import 'dart:developer' as developer;
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/multi_currency_cost_analysis.dart';
import 'package:petrol_tracker/services/currency_service.dart';

/// Service for converting fuel entry costs to unified currency analysis
class MultiCurrencyCostAnalysisService {
  static MultiCurrencyCostAnalysisService? _instance;
  static MultiCurrencyCostAnalysisService get instance => 
      _instance ??= MultiCurrencyCostAnalysisService._();
  
  MultiCurrencyCostAnalysisService._();

  final CurrencyService _currencyService = CurrencyService.instance;

  /// Convert a single amount to the target currency
  Future<CurrencyAwareAmount> convertAmount({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    // No conversion needed if currencies are the same
    if (fromCurrency == toCurrency) {
      return CurrencyAwareAmount.sameAs(
        amount: amount,
        currency: fromCurrency,
      );
    }

    try {
      final conversion = await _currencyService.convertAmount(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );

      if (conversion != null) {
        return CurrencyAwareAmount.fromConversion(
          originalAmount: amount,
          originalCurrency: fromCurrency,
          conversion: conversion,
        );
      } else {
        return CurrencyAwareAmount.conversionFailed(
          originalAmount: amount,
          originalCurrency: fromCurrency,
          targetCurrency: toCurrency,
        );
      }
    } catch (e) {
      developer.log(
        'Failed to convert $amount $fromCurrency to $toCurrency: $e',
        name: 'MultiCurrencyCostAnalysisService',
        error: e,
      );
      
      return CurrencyAwareAmount.conversionFailed(
        originalAmount: amount,
        originalCurrency: fromCurrency,
        targetCurrency: toCurrency,
      );
    }
  }

  /// Convert multiple amounts in parallel for efficiency
  Future<List<CurrencyAwareAmount>> convertAmounts({
    required List<({double amount, String currency})> amounts,
    required String toCurrency,
  }) async {
    final conversions = await Future.wait(
      amounts.map((amountData) => convertAmount(
        amount: amountData.amount,
        fromCurrency: amountData.currency,
        toCurrency: toCurrency,
      )),
    );

    return conversions;
  }

  /// Convert a list of fuel entries to currency-aware spending data
  Future<List<CurrencyAwareAmount>> convertFuelEntryPrices({
    required List<FuelEntryModel> entries,
    required String toCurrency,
  }) async {
    if (entries.isEmpty) return [];

    final amounts = entries.map((entry) => (
      amount: entry.price,
      currency: _extractCurrencyFromEntry(entry),
    )).toList();

    return await convertAmounts(amounts: amounts, toCurrency: toCurrency);
  }

  /// Calculate comprehensive multi-currency spending statistics
  Future<MultiCurrencySpendingStats> calculateSpendingStatistics({
    required List<FuelEntryModel> entries,
    required String primaryCurrency,
  }) async {
    if (entries.isEmpty) {
      return _createEmptyStats(primaryCurrency);
    }

    try {
      // Convert all entry prices to primary currency
      final convertedAmounts = await convertFuelEntryPrices(
        entries: entries,
        toCurrency: primaryCurrency,
      );

      // Calculate basic statistics
      final validAmounts = convertedAmounts
          .where((amount) => !amount.conversionFailed)
          .toList();

      if (validAmounts.isEmpty) {
        return _createEmptyStats(primaryCurrency);
      }

      final totalSpent = _calculateTotalSpent(convertedAmounts, primaryCurrency);
      final averagePerFillUp = _calculateAveragePerFillUp(validAmounts, primaryCurrency);
      final averagePerMonth = _calculateAveragePerMonth(entries, validAmounts, primaryCurrency);
      final mostExpensive = _findMostExpensive(convertedAmounts, primaryCurrency);
      final cheapest = _findCheapest(convertedAmounts, primaryCurrency);

      // Calculate country and currency breakdowns
      final countrySpending = await _calculateCountrySpending(entries, primaryCurrency);
      final currencyBreakdown = await _calculateCurrencyBreakdown(entries, primaryCurrency);

      // Find most/least expensive countries
      final countriesByAverage = _calculateCountryAverages(entries, countrySpending);
      
      return MultiCurrencySpendingStats(
        totalSpent: totalSpent,
        averagePerFillUp: averagePerFillUp,
        averagePerMonth: averagePerMonth,
        mostExpensiveFillUp: mostExpensive,
        cheapestFillUp: cheapest,
        totalFillUps: entries.length,
        totalCountries: countrySpending.length,
        totalCurrencies: currencyBreakdown.length,
        mostExpensiveCountry: countriesByAverage.isNotEmpty ? countriesByAverage.first : '',
        cheapestCountry: countriesByAverage.isNotEmpty ? countriesByAverage.last : '',
        countrySpending: countrySpending,
        currencyBreakdown: currencyBreakdown,
        primaryCurrency: primaryCurrency,
        calculatedAt: DateTime.now(),
      );
    } catch (e) {
      developer.log(
        'Error calculating multi-currency spending statistics: $e',
        name: 'MultiCurrencyCostAnalysisService',
        error: e,
      );
      return _createEmptyStats(primaryCurrency);
    }
  }

  /// Generate monthly spending data with currency conversion
  Future<List<MultiCurrencySpendingDataPoint>> generateMonthlySpendingData({
    required List<FuelEntryModel> entries,
    required String primaryCurrency,
  }) async {
    if (entries.isEmpty) return [];

    // Group entries by month
    final monthlyData = <String, List<FuelEntryModel>>{};
    
    for (final entry in entries) {
      final monthKey = '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}';
      monthlyData.putIfAbsent(monthKey, () => []).add(entry);
    }

    // Convert each month's spending
    final result = <MultiCurrencySpendingDataPoint>[];
    final sortedMonths = monthlyData.keys.toList()..sort();

    for (final monthKey in sortedMonths) {
      final monthEntries = monthlyData[monthKey]!;
      
      // Convert all entries for this month
      final convertedAmounts = await convertFuelEntryPrices(
        entries: monthEntries,
        toCurrency: primaryCurrency,
      );

      // Calculate total for the month
      final totalAmount = convertedAmounts.fold<double>(
        0,
        (sum, amount) => sum + amount.displayAmount,
      );

      // Use the most common country for the month
      final countryStats = <String, int>{};
      for (final entry in monthEntries) {
        countryStats[entry.country] = (countryStats[entry.country] ?? 0) + 1;
      }
      final mostCommonCountry = countryStats.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      final monthDate = _getMonthDate(monthKey);
      final periodLabel = _getMonthLabel(monthKey);

      // Create currency-aware amount for the total
      final monthlyAmount = CurrencyAwareAmount.sameAs(
        amount: totalAmount,
        currency: primaryCurrency,
      );

      result.add(MultiCurrencySpendingDataPoint(
        date: monthDate,
        amount: monthlyAmount,
        country: mostCommonCountry,
        periodLabel: periodLabel,
      ));
    }

    return result;
  }

  /// Generate country spending comparison with currency conversion
  Future<List<MultiCurrencyCountrySpendingDataPoint>> generateCountrySpendingComparison({
    required List<FuelEntryModel> entries,
    required String primaryCurrency,
  }) async {
    if (entries.isEmpty) return [];

    // Group entries by country
    final countryData = <String, List<FuelEntryModel>>{};
    
    for (final entry in entries) {
      countryData.putIfAbsent(entry.country, () => []).add(entry);
    }

    // Process each country
    final result = <MultiCurrencyCountrySpendingDataPoint>[];
    
    for (final entry in countryData.entries) {
      final country = entry.key;
      final countryEntries = entry.value;
      
      // Convert all spending for this country
      final convertedAmounts = await convertFuelEntryPrices(
        entries: countryEntries,
        toCurrency: primaryCurrency,
      );

      // Calculate totals
      final totalSpent = convertedAmounts.fold<double>(
        0,
        (sum, amount) => sum + amount.displayAmount,
      );

      // Calculate average price per liter (in original currencies, then convert)
      final pricePerLiterTotal = countryEntries.fold<double>(
        0,
        (sum, entry) => sum + entry.pricePerLiter,
      );
      final avgPricePerLiter = pricePerLiterTotal / countryEntries.length;
      
      // For price per liter, use the most common currency in this country
      final currencyStats = <String, int>{};
      for (final entry in countryEntries) {
        final currency = _extractCurrencyFromEntry(entry);
        currencyStats[currency] = (currencyStats[currency] ?? 0) + 1;
      }
      final mostCommonCurrency = currencyStats.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      final convertedAvgPrice = await convertAmount(
        amount: avgPricePerLiter,
        fromCurrency: mostCommonCurrency,
        toCurrency: primaryCurrency,
      );

      // Get all currencies used in this country
      final currenciesUsed = countryEntries
          .map((entry) => _extractCurrencyFromEntry(entry))
          .toSet();

      result.add(MultiCurrencyCountrySpendingDataPoint(
        country: country,
        totalSpent: CurrencyAwareAmount.sameAs(
          amount: totalSpent,
          currency: primaryCurrency,
        ),
        averagePricePerLiter: convertedAvgPrice,
        entryCount: countryEntries.length,
        currenciesUsed: currenciesUsed,
      ));
    }

    // Sort by total spent (highest first)
    result.sort((a, b) => b.totalSpent.displayAmount.compareTo(a.totalSpent.displayAmount));
    
    return result;
  }

  /// Generate currency usage summary
  Future<CurrencyUsageSummary> generateCurrencyUsageSummary({
    required List<FuelEntryModel> entries,
    required String primaryCurrency,
  }) async {
    if (entries.isEmpty) {
      return CurrencyUsageSummary(
        currencyEntryCount: {},
        currencyTotalAmounts: {},
        primaryCurrency: primaryCurrency,
        totalEntries: 0,
        calculatedAt: DateTime.now(),
      );
    }

    // Count entries by currency
    final currencyEntryCount = <String, int>{};
    final currencyTotals = <String, double>{};

    for (final entry in entries) {
      final currency = _extractCurrencyFromEntry(entry);
      currencyEntryCount[currency] = (currencyEntryCount[currency] ?? 0) + 1;
      currencyTotals[currency] = (currencyTotals[currency] ?? 0) + entry.price;
    }

    // Convert total amounts to primary currency
    final currencyTotalAmounts = <String, CurrencyAwareAmount>{};
    
    for (final entry in currencyTotals.entries) {
      final currency = entry.key;
      final total = entry.value;
      
      final convertedAmount = await convertAmount(
        amount: total,
        fromCurrency: currency,
        toCurrency: primaryCurrency,
      );
      
      currencyTotalAmounts[currency] = convertedAmount;
    }

    return CurrencyUsageSummary(
      currencyEntryCount: currencyEntryCount,
      currencyTotalAmounts: currencyTotalAmounts,
      primaryCurrency: primaryCurrency,
      totalEntries: entries.length,
      calculatedAt: DateTime.now(),
    );
  }

  // Private helper methods

  MultiCurrencySpendingStats _createEmptyStats(String primaryCurrency) {
    final emptyAmount = CurrencyAwareAmount.sameAs(
      amount: 0.0,
      currency: primaryCurrency,
    );

    return MultiCurrencySpendingStats(
      totalSpent: emptyAmount,
      averagePerFillUp: emptyAmount,
      averagePerMonth: emptyAmount,
      mostExpensiveFillUp: emptyAmount,
      cheapestFillUp: emptyAmount,
      totalFillUps: 0,
      totalCountries: 0,
      totalCurrencies: 0,
      mostExpensiveCountry: '',
      cheapestCountry: '',
      countrySpending: {},
      currencyBreakdown: {},
      primaryCurrency: primaryCurrency,
      calculatedAt: DateTime.now(),
    );
  }

  CurrencyAwareAmount _calculateTotalSpent(
    List<CurrencyAwareAmount> amounts,
    String primaryCurrency,
  ) {
    final total = amounts.fold<double>(
      0,
      (sum, amount) => sum + amount.displayAmount,
    );

    return CurrencyAwareAmount.sameAs(
      amount: total,
      currency: primaryCurrency,
    );
  }

  CurrencyAwareAmount _calculateAveragePerFillUp(
    List<CurrencyAwareAmount> validAmounts,
    String primaryCurrency,
  ) {
    if (validAmounts.isEmpty) {
      return CurrencyAwareAmount.sameAs(amount: 0.0, currency: primaryCurrency);
    }

    final total = validAmounts.fold<double>(
      0,
      (sum, amount) => sum + amount.displayAmount,
    );
    final average = total / validAmounts.length;

    return CurrencyAwareAmount.sameAs(
      amount: average,
      currency: primaryCurrency,
    );
  }

  CurrencyAwareAmount _calculateAveragePerMonth(
    List<FuelEntryModel> entries,
    List<CurrencyAwareAmount> validAmounts,
    String primaryCurrency,
  ) {
    if (validAmounts.isEmpty || entries.isEmpty) {
      return CurrencyAwareAmount.sameAs(amount: 0.0, currency: primaryCurrency);
    }

    final sortedEntries = List<FuelEntryModel>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    final timeSpan = sortedEntries.last.date.difference(sortedEntries.first.date);
    final months = timeSpan.inDays / 30.0;
    
    final total = validAmounts.fold<double>(
      0,
      (sum, amount) => sum + amount.displayAmount,
    );
    
    final averagePerMonth = months > 0 ? total / months : total;

    return CurrencyAwareAmount.sameAs(
      amount: averagePerMonth,
      currency: primaryCurrency,
    );
  }

  CurrencyAwareAmount _findMostExpensive(
    List<CurrencyAwareAmount> amounts,
    String primaryCurrency,
  ) {
    if (amounts.isEmpty) {
      return CurrencyAwareAmount.sameAs(amount: 0.0, currency: primaryCurrency);
    }

    final validAmounts = amounts.where((amount) => !amount.conversionFailed).toList();
    if (validAmounts.isEmpty) {
      return CurrencyAwareAmount.sameAs(amount: 0.0, currency: primaryCurrency);
    }

    final maxAmount = validAmounts
        .map((amount) => amount.displayAmount)
        .reduce((a, b) => a > b ? a : b);

    return CurrencyAwareAmount.sameAs(
      amount: maxAmount,
      currency: primaryCurrency,
    );
  }

  CurrencyAwareAmount _findCheapest(
    List<CurrencyAwareAmount> amounts,
    String primaryCurrency,
  ) {
    if (amounts.isEmpty) {
      return CurrencyAwareAmount.sameAs(amount: 0.0, currency: primaryCurrency);
    }

    final validAmounts = amounts.where((amount) => !amount.conversionFailed).toList();
    if (validAmounts.isEmpty) {
      return CurrencyAwareAmount.sameAs(amount: 0.0, currency: primaryCurrency);
    }

    final minAmount = validAmounts
        .map((amount) => amount.displayAmount)
        .reduce((a, b) => a < b ? a : b);

    return CurrencyAwareAmount.sameAs(
      amount: minAmount,
      currency: primaryCurrency,
    );
  }

  Future<Map<String, CurrencyAwareAmount>> _calculateCountrySpending(
    List<FuelEntryModel> entries,
    String primaryCurrency,
  ) async {
    final countryTotals = <String, double>{};
    final countryCurrencies = <String, String>{};

    // Group by country and calculate totals in original currencies
    for (final entry in entries) {
      countryTotals[entry.country] = (countryTotals[entry.country] ?? 0) + entry.price;
      countryCurrencies[entry.country] = _extractCurrencyFromEntry(entry);
    }

    // Convert each country's total to primary currency
    final result = <String, CurrencyAwareAmount>{};
    for (final entry in countryTotals.entries) {
      final country = entry.key;
      final total = entry.value;
      final currency = countryCurrencies[country]!;

      final convertedAmount = await convertAmount(
        amount: total,
        fromCurrency: currency,
        toCurrency: primaryCurrency,
      );

      result[country] = convertedAmount;
    }

    return result;
  }

  Future<Map<String, CurrencyAwareAmount>> _calculateCurrencyBreakdown(
    List<FuelEntryModel> entries,
    String primaryCurrency,
  ) async {
    final currencyTotals = <String, double>{};

    // Calculate totals by currency
    for (final entry in entries) {
      final currency = _extractCurrencyFromEntry(entry);
      currencyTotals[currency] = (currencyTotals[currency] ?? 0) + entry.price;
    }

    // Convert each currency's total to primary currency
    final result = <String, CurrencyAwareAmount>{};
    for (final entry in currencyTotals.entries) {
      final currency = entry.key;
      final total = entry.value;

      final convertedAmount = await convertAmount(
        amount: total,
        fromCurrency: currency,
        toCurrency: primaryCurrency,
      );

      result[currency] = convertedAmount;
    }

    return result;
  }

  List<String> _calculateCountryAverages(
    List<FuelEntryModel> entries,
    Map<String, CurrencyAwareAmount> countrySpending,
  ) {
    final countryEntryCount = <String, int>{};
    for (final entry in entries) {
      countryEntryCount[entry.country] = (countryEntryCount[entry.country] ?? 0) + 1;
    }

    final countryAverages = <String, double>{};
    for (final entry in countrySpending.entries) {
      final country = entry.key;
      final totalSpent = entry.value.displayAmount;
      final entryCount = countryEntryCount[country] ?? 1;
      countryAverages[country] = totalSpent / entryCount;
    }

    final sortedCountries = countryAverages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedCountries.map((e) => e.key).toList();
  }

  /// Extract currency from fuel entry (simplified approach)
  /// In a real implementation, currency would be stored directly in the entry
  String _extractCurrencyFromEntry(FuelEntryModel entry) {
    // This is a simplified approach based on country
    // In a real implementation, the currency would be stored directly
    final country = entry.country.toLowerCase();
    switch (country) {
      case 'canada': return 'CAD';
      case 'usa': case 'united states': return 'USD';
      case 'germany': case 'france': case 'spain': case 'italy': return 'EUR';
      case 'australia': return 'AUD';
      case 'japan': return 'JPY';
      case 'united kingdom': case 'uk': return 'GBP';
      case 'switzerland': return 'CHF';
      default: return 'USD'; // Default fallback
    }
  }

  DateTime _getMonthDate(String monthKey) {
    final parts = monthKey.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
  }

  String _getMonthLabel(String monthKey) {
    final date = _getMonthDate(monthKey);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}