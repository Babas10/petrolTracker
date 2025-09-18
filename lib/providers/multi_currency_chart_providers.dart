/// Multi-currency chart providers for Issue #129
/// 
/// This file contains Riverpod providers that extend the existing chart
/// providers with multi-currency conversion capabilities for unified
/// cost analysis dashboard.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/multi_currency_cost_analysis.dart';
import 'package:petrol_tracker/services/multi_currency_cost_analysis_service.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/currency_settings_providers.dart';

part 'multi_currency_chart_providers.g.dart';

/// Provider for multi-currency spending statistics
@riverpod
Future<MultiCurrencySpendingStats> multiCurrencySpendingStatistics(
  MultiCurrencySpendingStatisticsRef ref,
  int vehicleId, {
  DateTime? startDate,
  DateTime? endDate,
  String? countryFilter,
}) async {
  // Get fuel entries for the vehicle
  List<FuelEntryModel> entries;
  
  if (startDate != null && endDate != null) {
    entries = await ref.watch(
      fuelEntriesByVehicleAndDateRangeProvider(vehicleId, startDate, endDate).future,
    );
  } else {
    entries = await ref.watch(fuelEntriesByVehicleProvider(vehicleId).future);
  }

  // Apply country filter if specified
  if (countryFilter != null) {
    entries = entries.where((entry) => entry.country == countryFilter).toList();
  }

  // Get user's primary currency
  final currencySettings = await ref.watch(currencySettingsNotifierProvider.future);
  final primaryCurrency = currencySettings.primaryCurrency;

  // Calculate multi-currency statistics
  final service = MultiCurrencyCostAnalysisService.instance;
  return await service.calculateSpendingStatistics(
    entries: entries,
    primaryCurrency: primaryCurrency,
  );
}

/// Provider for multi-currency monthly spending data
@riverpod
Future<List<MultiCurrencySpendingDataPoint>> multiCurrencyMonthlySpendingData(
  MultiCurrencyMonthlySpendingDataRef ref,
  int vehicleId, {
  DateTime? startDate,
  DateTime? endDate,
  String? countryFilter,
}) async {
  // Get fuel entries for the vehicle
  List<FuelEntryModel> entries;
  
  if (startDate != null && endDate != null) {
    entries = await ref.watch(
      fuelEntriesByVehicleAndDateRangeProvider(vehicleId, startDate, endDate).future,
    );
  } else {
    entries = await ref.watch(fuelEntriesByVehicleProvider(vehicleId).future);
  }

  // Apply country filter if specified
  if (countryFilter != null) {
    entries = entries.where((entry) => entry.country == countryFilter).toList();
  }

  // Get user's primary currency
  final currencySettings = await ref.watch(currencySettingsNotifierProvider.future);
  final primaryCurrency = currencySettings.primaryCurrency;

  // Generate monthly spending data with currency conversion
  final service = MultiCurrencyCostAnalysisService.instance;
  return await service.generateMonthlySpendingData(
    entries: entries,
    primaryCurrency: primaryCurrency,
  );
}

/// Provider for multi-currency country spending comparison
@riverpod
Future<List<MultiCurrencyCountrySpendingDataPoint>> multiCurrencyCountrySpendingComparison(
  Ref ref,
  int vehicleId, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  // Get fuel entries for the vehicle
  List<FuelEntryModel> entries;
  
  if (startDate != null && endDate != null) {
    entries = await ref.watch(
      fuelEntriesByVehicleAndDateRangeProvider(vehicleId, startDate, endDate).future,
    );
  } else {
    entries = await ref.watch(fuelEntriesByVehicleProvider(vehicleId).future);
  }

  // Get user's primary currency
  final currencySettings = await ref.watch(currencySettingsNotifierProvider.future);
  final primaryCurrency = currencySettings.primaryCurrency;

  // Generate country spending comparison with currency conversion
  final service = MultiCurrencyCostAnalysisService.instance;
  return await service.generateCountrySpendingComparison(
    entries: entries,
    primaryCurrency: primaryCurrency,
  );
}

/// Provider for currency usage summary
@riverpod
Future<CurrencyUsageSummary> currencyUsageSummary(
  Ref ref,
  int vehicleId, {
  DateTime? startDate,
  DateTime? endDate,
  String? countryFilter,
}) async {
  // Get fuel entries for the vehicle
  List<FuelEntryModel> entries;
  
  if (startDate != null && endDate != null) {
    entries = await ref.watch(
      fuelEntriesByVehicleAndDateRangeProvider(vehicleId, startDate, endDate).future,
    );
  } else {
    entries = await ref.watch(fuelEntriesByVehicleProvider(vehicleId).future);
  }

  // Apply country filter if specified
  if (countryFilter != null) {
    entries = entries.where((entry) => entry.country == countryFilter).toList();
  }

  // Get user's primary currency
  final currencySettings = await ref.watch(currencySettingsNotifierProvider.future);
  final primaryCurrency = currencySettings.primaryCurrency;

  // Generate currency usage summary
  final service = MultiCurrencyCostAnalysisService.instance;
  return await service.generateCurrencyUsageSummary(
    entries: entries,
    primaryCurrency: primaryCurrency,
  );
}

/// Provider for checking if a vehicle has multi-currency entries
@riverpod
Future<bool> hasMultiCurrencyEntries(
  HasMultiCurrencyEntriesRef ref,
  int vehicleId, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  // Get fuel entries for the vehicle
  List<FuelEntryModel> entries;
  
  if (startDate != null && endDate != null) {
    entries = await ref.watch(
      fuelEntriesByVehicleAndDateRangeProvider(vehicleId, startDate, endDate).future,
    );
  } else {
    entries = await ref.watch(fuelEntriesByVehicleProvider(vehicleId).future);
  }

  if (entries.isEmpty) return false;

  // Extract currencies from entries
  final currencies = <String>{};
  
  for (final entry in entries) {
    // Use the consolidated currency extraction method
    final currency = MultiCurrencyCostAnalysisService.extractCurrencyFromCountry(entry.country);
    currencies.add(currency);
  }

  return currencies.length > 1;
}

/// Provider for getting the user's primary currency
@riverpod
Future<String> userPrimaryCurrency(UserPrimaryCurrencyRef ref) async {
  final currencySettings = await ref.watch(currencySettingsNotifierProvider.future);
  return currencySettings.primaryCurrency;
}

/// Provider for multi-currency aware chart data (converted to primary currency)
@riverpod
Future<List<Map<String, dynamic>>> multiCurrencyChartData(
  MultiCurrencyChartDataRef ref,
  List<MultiCurrencySpendingDataPoint> dataPoints,
) async {
  return dataPoints.map((point) => {
    'date': point.date.toIso8601String().split('T')[0],
    'amount': point.amount.displayAmount,
    'originalAmount': point.amount.originalAmount,
    'originalCurrency': point.amount.originalCurrency,
    'convertedAmount': point.amount.convertedAmount,
    'targetCurrency': point.amount.targetCurrency,
    'exchangeRate': point.amount.exchangeRate,
    'conversionFailed': point.amount.conversionFailed,
    'country': point.country,
    'periodLabel': point.periodLabel,
  }).toList();
}

/// Provider for multi-currency country comparison chart data
@riverpod
Future<List<Map<String, dynamic>>> multiCurrencyCountryChartData(
  MultiCurrencyCountryChartDataRef ref,
  List<MultiCurrencyCountrySpendingDataPoint> dataPoints,
) async {
  return dataPoints.map((point) => {
    'country': point.country,
    'totalSpent': point.totalSpent.displayAmount,
    'originalTotalSpent': point.totalSpent.originalAmount,
    'originalCurrency': point.totalSpent.originalCurrency,
    'averagePricePerLiter': point.averagePricePerLiter.displayAmount,
    'originalAveragePrice': point.averagePricePerLiter.originalAmount,
    'entryCount': point.entryCount,
    'currenciesUsed': point.currenciesUsed.toList(),
    'isMultiCurrency': point.isMultiCurrency,
  }).toList();
}

/// Provider that combines original chart data with currency conversion info
@riverpod
Future<Map<String, dynamic>> enhancedSpendingStatistics(
  Ref ref,
  int vehicleId, {
  DateTime? startDate,
  DateTime? endDate,
  String? countryFilter,
}) async {
  // Get both original and multi-currency statistics
  final multiCurrencyStats = await ref.watch(multiCurrencySpendingStatisticsProvider(
    vehicleId,
    startDate: startDate,
    endDate: endDate,
    countryFilter: countryFilter,
  ).future);

  final currencyUsage = await ref.watch(currencyUsageSummaryProvider(
    vehicleId,
    startDate: startDate,
    endDate: endDate,
    countryFilter: countryFilter,
  ).future);

  final hasMultiCurrency = await ref.watch(hasMultiCurrencyEntriesProvider(
    vehicleId,
    startDate: startDate,
    endDate: endDate,
  ).future);

  return {
    // Core statistics (converted to primary currency)
    'totalSpent': multiCurrencyStats.totalSpent.displayAmount,
    'averagePerFillUp': multiCurrencyStats.averagePerFillUp.displayAmount,
    'averagePerMonth': multiCurrencyStats.averagePerMonth.displayAmount,
    'mostExpensiveFillUp': multiCurrencyStats.mostExpensiveFillUp.displayAmount,
    'cheapestFillUp': multiCurrencyStats.cheapestFillUp.displayAmount,
    'totalFillUps': multiCurrencyStats.totalFillUps,
    'mostExpensiveCountry': multiCurrencyStats.mostExpensiveCountry,
    'cheapestCountry': multiCurrencyStats.cheapestCountry,
    'totalCountries': multiCurrencyStats.totalCountries,
    
    // Multi-currency specific data
    'primaryCurrency': multiCurrencyStats.primaryCurrency,
    'totalCurrencies': multiCurrencyStats.totalCurrencies,
    'hasMultiCurrency': hasMultiCurrency,
    'currencyUsage': currencyUsage,
    'hasConversionFailures': multiCurrencyStats.hasConversionFailures,
    'failedCurrencies': multiCurrencyStats.failedCurrencies,
    
    // Currency breakdown
    'countrySpending': multiCurrencyStats.countrySpending.map(
      (country, amount) => MapEntry(country, {
        'amount': amount.displayAmount,
        'originalAmount': amount.originalAmount,
        'originalCurrency': amount.originalCurrency,
        'conversionFailed': amount.conversionFailed,
      }),
    ),
    
    'currencyBreakdown': multiCurrencyStats.currencyBreakdown.map(
      (currency, amount) => MapEntry(currency, {
        'amount': amount.displayAmount,
        'originalAmount': amount.originalAmount,
        'originalCurrency': amount.originalCurrency,
        'conversionFailed': amount.conversionFailed,
      }),
    ),
    
    // Metadata
    'calculatedAt': multiCurrencyStats.calculatedAt.toIso8601String(),
  };
}

/// Provider for dashboard currency indicator data
@riverpod
Future<Map<String, dynamic>> dashboardCurrencyIndicator(
  DashboardCurrencyIndicatorRef ref,
  int vehicleId,
) async {
  final primaryCurrency = await ref.watch(userPrimaryCurrencyProvider.future);
  final hasMultiCurrency = await ref.watch(hasMultiCurrencyEntriesProvider(vehicleId).future);
  final currencyUsage = await ref.watch(currencyUsageSummaryProvider(vehicleId).future);
  
  return {
    'primaryCurrency': primaryCurrency,
    'hasMultiCurrency': hasMultiCurrency,
    'totalCurrencies': currencyUsage.currencyEntryCount.length,
    'mostUsedCurrency': currencyUsage.mostUsedCurrency,
    'currencyBreakdown': currencyUsage.currencyUsagePercentages,
  };
}