/// Multi-Currency Consumption Calculation Service for Issue #132
/// 
/// This service calculates fuel consumption metrics with proper currency
/// conversion to ensure accurate cost analysis across different currencies.
library;

import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/services/currency_service.dart';
import 'package:petrol_tracker/models/chart_data_models.dart';

/// Service for calculating consumption metrics with multi-currency support
class MultiCurrencyConsumptionCalculationService {
  final CurrencyService _currencyService;
  final String _primaryCurrency;

  MultiCurrencyConsumptionCalculationService({
    required CurrencyService currencyService,
    required String primaryCurrency,
  }) : _currencyService = currencyService,
       _primaryCurrency = primaryCurrency;

  /// Calculate comprehensive consumption analysis
  Future<ConsumptionAnalysis> calculateConsumption({
    required List<FuelEntryModel> entries,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    if (entries.isEmpty) {
      return _createEmptyAnalysis(periodStart, periodEnd);
    }

    // Convert all costs to primary currency
    final convertedEntries = await _convertEntriesToPrimaryCurrency(entries);
    
    // Sort entries by date for proper distance calculation
    final sortedEntries = List<FuelEntryModel>.from(convertedEntries)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // Calculate metrics
    final totalVolume = sortedEntries.fold<double>(
      0.0,
      (sum, entry) => sum + entry.fuelAmount,
    );
    
    final totalCost = sortedEntries.fold<double>(
      0.0,
      (sum, entry) => sum + entry.price, // Already converted
    );
    
    final totalDistance = _calculateTotalDistance(sortedEntries);
    
    final averageConsumption = totalDistance > 0 
        ? (totalVolume / totalDistance) * 100 
        : 0.0;
    
    final costPerLiter = totalVolume > 0 ? totalCost / totalVolume : 0.0;
    final costPerKilometer = totalDistance > 0 ? totalCost / totalDistance : 0.0;
    
    // Calculate currency breakdown from original entries
    final currencyBreakdown = _calculateCurrencyBreakdown(entries);
    
    return ConsumptionAnalysis(
      totalVolume: totalVolume,
      totalCost: totalCost,
      totalDistance: totalDistance,
      averageConsumption: averageConsumption,
      costPerLiter: costPerLiter,
      costPerKilometer: costPerKilometer,
      currency: _primaryCurrency,
      periodStart: periodStart,
      periodEnd: periodEnd,
      entriesAnalyzed: convertedEntries.length,
      currencyBreakdown: currencyBreakdown,
    );
  }

  /// Calculate consumption by vehicle
  Future<Map<int, ConsumptionAnalysis>> calculateConsumptionByVehicle({
    required List<FuelEntryModel> entries,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final vehicleGroups = <int, List<FuelEntryModel>>{};
    
    // Group entries by vehicle
    for (final entry in entries) {
      vehicleGroups.putIfAbsent(entry.vehicleId, () => []).add(entry);
    }
    
    final results = <int, ConsumptionAnalysis>{};
    
    // Calculate consumption for each vehicle
    for (final vehicleEntry in vehicleGroups.entries) {
      final vehicleId = vehicleEntry.key;
      final vehicleEntries = vehicleEntry.value;
      
      final analysis = await calculateConsumption(
        entries: vehicleEntries,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
      
      results[vehicleId] = analysis;
    }
    
    return results;
  }

  /// Calculate monthly consumption trends
  Future<List<ConsumptionAnalysis>> calculateMonthlyTrends({
    required List<FuelEntryModel> entries,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final monthlyData = <DateTime, List<FuelEntryModel>>{};
    
    // Group entries by month
    for (final entry in entries) {
      if (entry.date.isAfter(periodStart.subtract(const Duration(days: 1))) &&
          entry.date.isBefore(periodEnd.add(const Duration(days: 1)))) {
        final monthKey = DateTime(entry.date.year, entry.date.month);
        monthlyData.putIfAbsent(monthKey, () => []).add(entry);
      }
    }
    
    final trends = <ConsumptionAnalysis>[];
    
    // Calculate consumption for each month
    final sortedMonths = monthlyData.keys.toList()
      ..sort();
    
    for (final month in sortedMonths) {
      final monthEntries = monthlyData[month]!;
      final monthEnd = DateTime(month.year, month.month + 1, 0);
      
      final analysis = await calculateConsumption(
        entries: monthEntries,
        periodStart: month,
        periodEnd: monthEnd,
      );
      
      trends.add(analysis);
    }
    
    return trends;
  }

  /// Calculate efficiency metrics (cost per unit)
  Future<Map<String, double>> calculateEfficiencyMetrics({
    required List<FuelEntryModel> entries,
  }) async {
    if (entries.isEmpty) {
      return {
        'costPerLiter': 0.0,
        'costPerKilometer': 0.0,
        'consumptionPer100Km': 0.0,
        'averagePricePerLiter': 0.0,
      };
    }

    final convertedEntries = await _convertEntriesToPrimaryCurrency(entries);
    
    final totalCost = convertedEntries.fold<double>(
      0.0,
      (sum, entry) => sum + entry.price,
    );
    
    final totalVolume = convertedEntries.fold<double>(
      0.0,
      (sum, entry) => sum + entry.fuelAmount,
    );
    
    final totalDistance = _calculateTotalDistance(convertedEntries);
    
    return {
      'costPerLiter': totalVolume > 0 ? totalCost / totalVolume : 0.0,
      'costPerKilometer': totalDistance > 0 ? totalCost / totalDistance : 0.0,
      'consumptionPer100Km': totalDistance > 0 ? (totalVolume / totalDistance) * 100 : 0.0,
      'averagePricePerLiter': totalVolume > 0 ? totalCost / totalVolume : 0.0,
    };
  }

  /// Convert fuel entries to primary currency
  Future<List<FuelEntryModel>> _convertEntriesToPrimaryCurrency(
    List<FuelEntryModel> entries,
  ) async {
    final convertedEntries = <FuelEntryModel>[];
    
    for (final entry in entries) {
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
        // Keep original if conversion fails
        convertedEntries.add(entry);
      }
    }
    
    return convertedEntries;
  }

  /// Calculate total distance from entries
  double _calculateTotalDistance(List<FuelEntryModel> entries) {
    if (entries.length < 2) return 0.0;
    
    double totalDistance = 0.0;
    
    for (int i = 1; i < entries.length; i++) {
      final current = entries[i];
      final previous = entries[i - 1];
      
      final distance = current.currentKm - previous.currentKm;
      if (distance > 0 && distance < 10000) { // Sanity check for reasonable distance
        totalDistance += distance;
      }
    }
    
    return totalDistance;
  }

  /// Calculate currency breakdown from original entries
  Map<String, CurrencyBreakdown> _calculateCurrencyBreakdown(
    List<FuelEntryModel> originalEntries,
  ) {
    final breakdown = <String, CurrencyBreakdown>{};
    final currencyTotals = <String, double>{};
    final currencyCounts = <String, int>{};
    
    for (final entry in originalEntries) {
      final currency = _extractCurrencyFromCountry(entry.country);
      currencyTotals[currency] = (currencyTotals[currency] ?? 0.0) + entry.price;
      currencyCounts[currency] = (currencyCounts[currency] ?? 0) + 1;
    }
    
    final totalAmount = currencyTotals.values.fold(0.0, (a, b) => a + b);
    
    for (final currency in currencyTotals.keys) {
      final amount = currencyTotals[currency]!;
      final count = currencyCounts[currency]!;
      final percentage = totalAmount > 0 ? (amount / totalAmount) * 100 : 0.0;
      
      breakdown[currency] = CurrencyBreakdown(
        currency: currency,
        totalAmount: amount,
        entryCount: count,
        percentage: percentage,
      );
    }
    
    return breakdown;
  }

  /// Create empty analysis for periods with no data
  ConsumptionAnalysis _createEmptyAnalysis(DateTime periodStart, DateTime periodEnd) {
    return ConsumptionAnalysis(
      totalVolume: 0.0,
      totalCost: 0.0,
      totalDistance: 0.0,
      averageConsumption: 0.0,
      costPerLiter: 0.0,
      costPerKilometer: 0.0,
      currency: _primaryCurrency,
      periodStart: periodStart,
      periodEnd: periodEnd,
      entriesAnalyzed: 0,
      currencyBreakdown: {},
    );
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