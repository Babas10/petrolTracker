/// Multi-Currency Chart Providers for Issue #132
/// 
/// These providers handle chart data generation with proper currency conversion
/// and state management for multi-currency aware chart visualizations.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/chart_data_models.dart';
import 'package:petrol_tracker/services/multi_currency_chart_data_service.dart';
import 'package:petrol_tracker/services/multi_currency_consumption_calculation_service.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/currency_providers.dart';

/// Provider for multi-currency chart data service
final multiCurrencyChartDataServiceProvider = Provider.family<MultiCurrencyChartDataService, String>((ref, primaryCurrency) {
  final currencyService = ref.read(currencyServiceProvider);
  
  return MultiCurrencyChartDataService(
    currencyService: currencyService,
    primaryCurrency: primaryCurrency,
  );
});

/// Provider for multi-currency consumption calculation service
final multiCurrencyConsumptionServiceProvider = Provider.family<MultiCurrencyConsumptionCalculationService, String>((ref, primaryCurrency) {
  final currencyService = ref.read(currencyServiceProvider);
  
  return MultiCurrencyConsumptionCalculationService(
    currencyService: currencyService,
    primaryCurrency: primaryCurrency,
  );
});

/// Provider for multi-currency chart data
final multiCurrencyChartDataProvider = FutureProvider.family<List<ChartDataPoint>, ChartDataParams>((ref, params) async {
  final primaryCurrency = ref.watch(primaryCurrencyProvider);
  final chartService = ref.read(multiCurrencyChartDataServiceProvider(primaryCurrency));
  
  // Get fuel entries based on vehicle filter
  List<FuelEntryModel> entries;
  
  if (params.vehicleId != null) {
    final vehicleEntries = await ref.watch(fuelEntriesByVehicleProvider(params.vehicleId!).future);
    entries = vehicleEntries;
  } else {
    final allEntriesState = await ref.watch(fuelEntriesNotifierProvider.future);
    entries = allEntriesState.entries;
  }
  
  // Filter entries by date range if provided
  if (params.dateRange != null) {
    entries = entries.where((entry) => params.dateRange!.contains(entry.date)).toList();
  }
  
  // Generate chart data based on type
  switch (params.chartType) {
    case ChartType.cost:
      return await chartService.generateCostChart(
        entries: entries,
        period: params.period,
        dateRange: params.dateRange ?? DateRange(
          start: DateTime.now().subtract(const Duration(days: 365)),
          end: DateTime.now(),
        ),
      );
    case ChartType.consumption:
      return await chartService.generateConsumptionChart(
        entries: entries,
        period: params.period,
        dateRange: params.dateRange ?? DateRange(
          start: DateTime.now().subtract(const Duration(days: 365)),
          end: DateTime.now(),
        ),
      );
    case ChartType.efficiency:
      return await chartService.generateEfficiencyChart(
        entries: entries,
        period: params.period,
        dateRange: params.dateRange ?? DateRange(
          start: DateTime.now().subtract(const Duration(days: 365)),
          end: DateTime.now(),
        ),
      );
    case ChartType.price:
      return await chartService.generatePriceChart(
        entries: entries,
        period: params.period,
        dateRange: params.dateRange ?? DateRange(
          start: DateTime.now().subtract(const Duration(days: 365)),
          end: DateTime.now(),
        ),
      );
  }
});

/// Provider for chart configuration
final chartConfigurationProvider = Provider.family<ChartConfiguration, ChartType>((ref, chartType) {
  final primaryCurrency = ref.watch(primaryCurrencyProvider);
  
  return ChartConfiguration(
    chartType: chartType.name,
    primaryCurrency: primaryCurrency,
    showCurrencyBreakdown: true,
    enableCurrencyTooltips: true,
    currencyFormatter: 'currency',
  );
});

/// Provider for consumption analysis
final consumptionAnalysisProvider = FutureProvider.family<ConsumptionAnalysis, ConsumptionAnalysisParams>((ref, params) async {
  final primaryCurrency = ref.watch(primaryCurrencyProvider);
  final consumptionService = ref.read(multiCurrencyConsumptionServiceProvider(primaryCurrency));
  
  // Get fuel entries
  List<FuelEntryModel> entries;
  
  if (params.vehicleId != null) {
    final vehicleEntries = await ref.watch(fuelEntriesByVehicleProvider(params.vehicleId!).future);
    entries = vehicleEntries;
  } else {
    final allEntriesState = await ref.watch(fuelEntriesNotifierProvider.future);
    entries = allEntriesState.entries;
  }
  
  // Filter by date range
  entries = entries.where((entry) => 
    entry.date.isAfter(params.periodStart.subtract(const Duration(days: 1))) &&
    entry.date.isBefore(params.periodEnd.add(const Duration(days: 1)))
  ).toList();
  
  return await consumptionService.calculateConsumption(
    entries: entries,
    periodStart: params.periodStart,
    periodEnd: params.periodEnd,
  );
});

/// Provider for monthly consumption trends
final monthlyConsumptionTrendsProvider = FutureProvider.family<List<ConsumptionAnalysis>, ConsumptionAnalysisParams>((ref, params) async {
  final primaryCurrency = ref.watch(primaryCurrencyProvider);
  final consumptionService = ref.read(multiCurrencyConsumptionServiceProvider(primaryCurrency));
  
  // Get fuel entries
  List<FuelEntryModel> entries;
  
  if (params.vehicleId != null) {
    final vehicleEntries = await ref.watch(fuelEntriesByVehicleProvider(params.vehicleId!).future);
    entries = vehicleEntries;
  } else {
    final allEntriesState = await ref.watch(fuelEntriesNotifierProvider.future);
    entries = allEntriesState.entries;
  }
  
  return await consumptionService.calculateMonthlyTrends(
    entries: entries,
    periodStart: params.periodStart,
    periodEnd: params.periodEnd,
  );
});

/// Provider for consumption by vehicle
final consumptionByVehicleProvider = FutureProvider.family<Map<int, ConsumptionAnalysis>, ConsumptionAnalysisParams>((ref, params) async {
  final primaryCurrency = ref.watch(primaryCurrencyProvider);
  final consumptionService = ref.read(multiCurrencyConsumptionServiceProvider(primaryCurrency));
  
  final allEntriesState = await ref.watch(fuelEntriesNotifierProvider.future);
  final entries = allEntriesState.entries;
  
  return await consumptionService.calculateConsumptionByVehicle(
    entries: entries,
    periodStart: params.periodStart,
    periodEnd: params.periodEnd,
  );
});

/// Provider for efficiency metrics
final efficiencyMetricsProvider = FutureProvider.family<Map<String, double>, int?>((ref, vehicleId) async {
  final primaryCurrency = ref.watch(primaryCurrencyProvider);
  final consumptionService = ref.read(multiCurrencyConsumptionServiceProvider(primaryCurrency));
  
  // Get fuel entries
  List<FuelEntryModel> entries;
  
  if (vehicleId != null) {
    final vehicleEntries = await ref.watch(fuelEntriesByVehicleProvider(vehicleId).future);
    entries = vehicleEntries;
  } else {
    final allEntriesState = await ref.watch(fuelEntriesNotifierProvider.future);
    entries = allEntriesState.entries;
  }
  
  return await consumptionService.calculateEfficiencyMetrics(entries: entries);
});

/// Provider for chart data cache management
final chartDataCacheProvider = StateNotifierProvider<ChartDataCacheNotifier, Map<String, ChartDataCacheEntry>>((ref) {
  return ChartDataCacheNotifier();
});

/// Chart data cache notifier
class ChartDataCacheNotifier extends StateNotifier<Map<String, ChartDataCacheEntry>> {
  ChartDataCacheNotifier() : super({});

  /// Get cached chart data
  List<ChartDataPoint>? getCachedData(String cacheKey) {
    final cacheEntry = state[cacheKey];
    if (cacheEntry != null && cacheEntry.isValid) {
      return cacheEntry.data;
    }
    return null;
  }

  /// Cache chart data
  void cacheData(String cacheKey, List<ChartDataPoint> data, String currency) {
    final cacheEntry = ChartDataCacheEntry(
      cacheKey: cacheKey,
      data: data,
      timestamp: DateTime.now(),
      currency: currency,
    );
    
    state = {...state, cacheKey: cacheEntry};
    
    // Clean up expired entries
    _cleanExpiredEntries();
  }

  /// Clear all cached data
  void clearCache() {
    state = {};
  }

  /// Clear cache for specific currency
  void clearCacheForCurrency(String currency) {
    final filteredState = <String, ChartDataCacheEntry>{};
    
    for (final entry in state.entries) {
      if (entry.value.currency != currency) {
        filteredState[entry.key] = entry.value;
      }
    }
    
    state = filteredState;
  }

  /// Clean expired cache entries
  void _cleanExpiredEntries() {
    final validEntries = <String, ChartDataCacheEntry>{};
    
    for (final entry in state.entries) {
      if (entry.value.isValid) {
        validEntries[entry.key] = entry.value;
      }
    }
    
    state = validEntries;
  }
}

/// Parameter classes for providers
class ChartDataParams {
  final ChartType chartType;
  final ChartPeriod period;
  final DateRange? dateRange;
  final int? vehicleId;

  const ChartDataParams({
    required this.chartType,
    required this.period,
    this.dateRange,
    this.vehicleId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChartDataParams &&
        other.chartType == chartType &&
        other.period == period &&
        other.dateRange == dateRange &&
        other.vehicleId == vehicleId;
  }

  @override
  int get hashCode {
    return Object.hash(chartType, period, dateRange, vehicleId);
  }
}

class ConsumptionAnalysisParams {
  final DateTime periodStart;
  final DateTime periodEnd;
  final int? vehicleId;

  const ConsumptionAnalysisParams({
    required this.periodStart,
    required this.periodEnd,
    this.vehicleId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConsumptionAnalysisParams &&
        other.periodStart == periodStart &&
        other.periodEnd == periodEnd &&
        other.vehicleId == vehicleId;
  }

  @override
  int get hashCode {
    return Object.hash(periodStart, periodEnd, vehicleId);
  }
}