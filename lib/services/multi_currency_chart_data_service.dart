/// Multi-Currency Chart Data Service for Issue #132
/// 
/// This service handles the conversion of fuel entry data to chart-ready format
/// with proper currency conversion to the user's primary currency for accurate
/// visualization and analysis across different currencies.
library;

import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/services/currency_service.dart';
import 'package:petrol_tracker/models/chart_data_models.dart';

/// Enumeration for different chart types
enum ChartType {
  cost,
  consumption,
  efficiency,
  price,
}

/// Enumeration for chart period grouping
enum ChartPeriod {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
}

/// Date range class for chart filtering
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  bool contains(DateTime date) {
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
           date.isBefore(end.add(const Duration(days: 1)));
  }
}

/// Service for generating multi-currency aware chart data
class MultiCurrencyChartDataService {
  final CurrencyService _currencyService;
  final String _primaryCurrency;

  MultiCurrencyChartDataService({
    required CurrencyService currencyService,
    required String primaryCurrency,
  }) : _currencyService = currencyService,
       _primaryCurrency = primaryCurrency;

  /// Generate cost chart data with currency conversion
  Future<List<ChartDataPoint>> generateCostChart({
    required List<FuelEntryModel> entries,
    required ChartPeriod period,
    required DateRange dateRange,
  }) async {
    // Convert all entries to primary currency
    final convertedEntries = await _convertEntriesToPrimaryCurrency(entries);
    
    // Group by period
    final groupedData = _groupEntriesByPeriod(convertedEntries, period, dateRange);
    
    // Calculate totals for each period
    final chartData = <ChartDataPoint>[];
    
    for (final entry in groupedData.entries) {
      final periodDate = entry.key;
      final periodEntries = entry.value;
      
      final totalCost = periodEntries.fold<double>(
        0.0,
        (sum, entry) => sum + entry.price, // Already converted amounts
      );
      
      chartData.add(ChartDataPoint(
        date: periodDate,
        value: totalCost,
        label: _formatPeriodLabel(periodDate, period),
        metadata: ChartMetadata(
          currency: _primaryCurrency,
          entryCount: periodEntries.length,
          originalCurrencies: _getOriginalCurrencies(periodEntries),
          totalVolume: periodEntries.fold<double>(0.0, (sum, e) => sum + e.fuelAmount),
        ),
      ));
    }
    
    return chartData..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Generate consumption chart data with currency-aware cost calculations
  Future<List<ChartDataPoint>> generateConsumptionChart({
    required List<FuelEntryModel> entries,
    required ChartPeriod period,
    required DateRange dateRange,
  }) async {
    // Convert entries to primary currency for cost calculations
    final convertedEntries = await _convertEntriesToPrimaryCurrency(entries);
    
    // Group by period
    final groupedData = _groupEntriesByPeriod(convertedEntries, period, dateRange);
    
    final chartData = <ChartDataPoint>[];
    
    for (final entry in groupedData.entries) {
      final periodDate = entry.key;
      final periodEntries = entry.value;
      
      // Calculate consumption metrics
      final totalVolume = periodEntries.fold<double>(
        0.0,
        (sum, entry) => sum + entry.fuelAmount,
      );
      
      final totalDistance = _calculateTotalDistance(periodEntries);
      
      final averageConsumption = totalDistance > 0 
          ? (totalVolume / totalDistance) * 100 
          : 0.0;
      
      chartData.add(ChartDataPoint(
        date: periodDate,
        value: averageConsumption,
        label: _formatPeriodLabel(periodDate, period),
        metadata: ChartMetadata(
          currency: _primaryCurrency,
          entryCount: periodEntries.length,
          originalCurrencies: _getOriginalCurrencies(periodEntries),
          totalVolume: totalVolume,
          totalDistance: totalDistance,
        ),
      ));
    }
    
    return chartData..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Generate efficiency chart data (cost per km)
  Future<List<ChartDataPoint>> generateEfficiencyChart({
    required List<FuelEntryModel> entries,
    required ChartPeriod period,
    required DateRange dateRange,
  }) async {
    // Convert entries to primary currency for cost calculations
    final convertedEntries = await _convertEntriesToPrimaryCurrency(entries);
    
    // Group by period
    final groupedData = _groupEntriesByPeriod(convertedEntries, period, dateRange);
    
    final chartData = <ChartDataPoint>[];
    
    for (final entry in groupedData.entries) {
      final periodDate = entry.key;
      final periodEntries = entry.value;
      
      final totalCost = periodEntries.fold<double>(
        0.0,
        (sum, entry) => sum + entry.price,
      );
      
      final totalDistance = _calculateTotalDistance(periodEntries);
      
      final costPerKm = totalDistance > 0 ? totalCost / totalDistance : 0.0;
      
      chartData.add(ChartDataPoint(
        date: periodDate,
        value: costPerKm,
        label: _formatPeriodLabel(periodDate, period),
        metadata: ChartMetadata(
          currency: _primaryCurrency,
          entryCount: periodEntries.length,
          originalCurrencies: _getOriginalCurrencies(periodEntries),
          totalDistance: totalDistance,
          currencyBreakdown: _calculateCurrencyBreakdown(periodEntries),
        ),
      ));
    }
    
    return chartData..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Generate price trend chart data
  Future<List<ChartDataPoint>> generatePriceChart({
    required List<FuelEntryModel> entries,
    required ChartPeriod period,
    required DateRange dateRange,
  }) async {
    // Convert entries to primary currency for price calculations
    final convertedEntries = await _convertEntriesToPrimaryCurrency(entries);
    
    // Group by period
    final groupedData = _groupEntriesByPeriod(convertedEntries, period, dateRange);
    
    final chartData = <ChartDataPoint>[];
    
    for (final entry in groupedData.entries) {
      final periodDate = entry.key;
      final periodEntries = entry.value;
      
      // Calculate average price per liter for the period
      final totalCost = periodEntries.fold<double>(
        0.0,
        (sum, entry) => sum + entry.price,
      );
      
      final totalVolume = periodEntries.fold<double>(
        0.0,
        (sum, entry) => sum + entry.fuelAmount,
      );
      
      final averagePricePerLiter = totalVolume > 0 ? totalCost / totalVolume : 0.0;
      
      chartData.add(ChartDataPoint(
        date: periodDate,
        value: averagePricePerLiter,
        label: _formatPeriodLabel(periodDate, period),
        metadata: ChartMetadata(
          currency: _primaryCurrency,
          entryCount: periodEntries.length,
          originalCurrencies: _getOriginalCurrencies(periodEntries),
          totalVolume: totalVolume,
        ),
      ));
    }
    
    return chartData..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Convert fuel entries to primary currency
  Future<List<FuelEntryModel>> _convertEntriesToPrimaryCurrency(
    List<FuelEntryModel> entries,
  ) async {
    final convertedEntries = <FuelEntryModel>[];
    
    for (final entry in entries) {
      // If entry already has country information, extract currency from it
      final entryCurrency = _extractCurrencyFromCountry(entry.country);
      
      if (entryCurrency == _primaryCurrency) {
        convertedEntries.add(entry);
        continue;
      }
      
      // Convert price to primary currency
      final conversion = await _currencyService.convertAmount(
        amount: entry.price,
        fromCurrency: entryCurrency,
        toCurrency: _primaryCurrency,
      );
      
      if (conversion != null) {
        // Create new entry with converted price
        convertedEntries.add(FuelEntryModel(
          id: entry.id,
          vehicleId: entry.vehicleId,
          date: entry.date,
          currentKm: entry.currentKm,
          fuelAmount: entry.fuelAmount,
          price: conversion.convertedAmount,
          originalAmount: entry.price,
          currency: _primaryCurrency,
          country: entry.country,
          pricePerLiter: entry.fuelAmount > 0 
              ? conversion.convertedAmount / entry.fuelAmount 
              : 0.0,
          consumption: entry.consumption,
          isFullTank: entry.isFullTank,
        ));
      } else {
        // Keep original if conversion fails, but log the failure
        convertedEntries.add(entry);
      }
    }
    
    return convertedEntries;
  }

  /// Group entries by time period
  Map<DateTime, List<FuelEntryModel>> _groupEntriesByPeriod(
    List<FuelEntryModel> entries,
    ChartPeriod period,
    DateRange dateRange,
  ) {
    final grouped = <DateTime, List<FuelEntryModel>>{};
    
    for (final entry in entries) {
      if (!dateRange.contains(entry.date)) continue;
      
      final periodKey = _getPeriodKey(entry.date, period);
      grouped.putIfAbsent(periodKey, () => []).add(entry);
    }
    
    return grouped;
  }

  /// Get period key for grouping
  DateTime _getPeriodKey(DateTime date, ChartPeriod period) {
    switch (period) {
      case ChartPeriod.daily:
        return DateTime(date.year, date.month, date.day);
      case ChartPeriod.weekly:
        final weekStart = date.subtract(Duration(days: date.weekday - 1));
        return DateTime(weekStart.year, weekStart.month, weekStart.day);
      case ChartPeriod.monthly:
        return DateTime(date.year, date.month);
      case ChartPeriod.quarterly:
        final quarter = ((date.month - 1) ~/ 3) + 1;
        return DateTime(date.year, (quarter - 1) * 3 + 1);
      case ChartPeriod.yearly:
        return DateTime(date.year);
    }
  }

  /// Format period label for display
  String _formatPeriodLabel(DateTime date, ChartPeriod period) {
    switch (period) {
      case ChartPeriod.daily:
        return '${date.day}/${date.month}';
      case ChartPeriod.weekly:
        return 'Week ${date.day}/${date.month}';
      case ChartPeriod.monthly:
        return '${date.month}/${date.year}';
      case ChartPeriod.quarterly:
        final quarter = ((date.month - 1) ~/ 3) + 1;
        return 'Q$quarter ${date.year}';
      case ChartPeriod.yearly:
        return '${date.year}';
    }
  }

  /// Calculate total distance from entries
  double _calculateTotalDistance(List<FuelEntryModel> entries) {
    if (entries.length < 2) return 0.0;
    
    // Sort entries by date
    final sortedEntries = List<FuelEntryModel>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    double totalDistance = 0.0;
    for (int i = 1; i < sortedEntries.length; i++) {
      final current = sortedEntries[i];
      final previous = sortedEntries[i - 1];
      
      final distance = current.currentKm - previous.currentKm;
      if (distance > 0) {
        totalDistance += distance;
      }
    }
    
    return totalDistance;
  }

  /// Get list of original currencies from entries
  List<String> _getOriginalCurrencies(List<FuelEntryModel> entries) {
    return entries
        .map((e) => _extractCurrencyFromCountry(e.country))
        .toSet()
        .toList();
  }

  /// Calculate currency breakdown for metadata
  Map<String, double> _calculateCurrencyBreakdown(List<FuelEntryModel> entries) {
    final breakdown = <String, double>{};
    
    for (final entry in entries) {
      final currency = _extractCurrencyFromCountry(entry.country);
      breakdown[currency] = (breakdown[currency] ?? 0.0) + entry.price;
    }
    
    return breakdown;
  }

  /// Extract currency from country name
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
}