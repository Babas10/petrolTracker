import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'fuel_entry_providers.dart';

part 'chart_providers.g.dart';

/// Data point for consumption chart
class ConsumptionDataPoint {
  final DateTime date;
  final double consumption;
  final double kilometers;

  const ConsumptionDataPoint({
    required this.date,
    required this.consumption,
    required this.kilometers,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConsumptionDataPoint &&
        other.date == date &&
        other.consumption == consumption &&
        other.kilometers == kilometers;
  }

  @override
  int get hashCode => Object.hash(date, consumption, kilometers);

  @override
  String toString() {
    return 'ConsumptionDataPoint(date: $date, consumption: $consumption, kilometers: $kilometers)';
  }
}

/// Data point for price trend chart
class PriceTrendDataPoint {
  final DateTime date;
  final double pricePerLiter;
  final String country;

  const PriceTrendDataPoint({
    required this.date,
    required this.pricePerLiter,
    required this.country,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PriceTrendDataPoint &&
        other.date == date &&
        other.pricePerLiter == pricePerLiter &&
        other.country == country;
  }

  @override
  int get hashCode => Object.hash(date, pricePerLiter, country);

  @override
  String toString() {
    return 'PriceTrendDataPoint(date: $date, pricePerLiter: $pricePerLiter, country: $country)';
  }
}

/// Provider for consumption chart data for a specific vehicle
@riverpod
Future<List<ConsumptionDataPoint>> consumptionChartData(
  ConsumptionChartDataRef ref,
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

  // Convert to chart data points, filtering out entries without consumption
  return entries
      .where((entry) => entry.consumption != null)
      .map((entry) => ConsumptionDataPoint(
            date: entry.date,
            consumption: entry.consumption!,
            kilometers: entry.currentKm,
          ))
      .toList();
}

/// Provider for price trend chart data
@riverpod
Future<List<PriceTrendDataPoint>> priceTrendChartData(
  PriceTrendChartDataRef ref, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  // Get fuel entries within date range
  List<FuelEntryModel> entries;
  
  if (startDate != null && endDate != null) {
    entries = await ref.watch(
      fuelEntriesByDateRangeProvider(startDate, endDate).future,
    );
  } else {
    // Get all entries if no date range specified
    final entriesState = await ref.watch(fuelEntriesNotifierProvider.future);
    entries = entriesState.entries;
  }

  // Convert to price trend data points
  return entries
      .map((entry) => PriceTrendDataPoint(
            date: entry.date,
            pricePerLiter: entry.pricePerLiter,
            country: entry.country,
          ))
      .toList();
}

/// Provider for monthly consumption averages for a vehicle
@riverpod
Future<Map<String, double>> monthlyConsumptionAverages(
  MonthlyConsumptionAveragesRef ref,
  int vehicleId,
  int year,
) async {
  final entries = await ref.watch(fuelEntriesByVehicleProvider(vehicleId).future);
  
  // Filter entries for the specified year and group by month
  final monthlyEntries = <String, List<FuelEntryModel>>{};
  
  for (final entry in entries) {
    if (entry.date.year == year && entry.consumption != null) {
      final monthKey = '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}';
      monthlyEntries.putIfAbsent(monthKey, () => []).add(entry);
    }
  }

  // Calculate average consumption for each month
  final monthlyAverages = <String, double>{};
  
  for (final entry in monthlyEntries.entries) {
    final consumptions = entry.value
        .where((e) => e.consumption != null)
        .map((e) => e.consumption!)
        .toList();
    
    if (consumptions.isNotEmpty) {
      final average = consumptions.reduce((a, b) => a + b) / consumptions.length;
      monthlyAverages[entry.key] = average;
    }
  }

  return monthlyAverages;
}

/// Provider for cost analysis data
@riverpod
Future<Map<String, dynamic>> costAnalysisData(
  CostAnalysisDataRef ref,
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

  if (entries.isEmpty) {
    return {
      'totalCost': 0.0,
      'totalFuel': 0.0,
      'totalDistance': 0.0,
      'averagePricePerLiter': 0.0,
      'costPerKilometer': 0.0,
      'entriesCount': 0,
    };
  }

  // Calculate totals and averages
  final totalCost = entries.fold<double>(0, (sum, entry) => sum + entry.price);
  final totalFuel = entries.fold<double>(0, (sum, entry) => sum + entry.fuelAmount);
  
  // Calculate total distance (difference between first and last entry)
  entries.sort((a, b) => a.date.compareTo(b.date));
  final totalDistance = entries.length > 1 
      ? entries.last.currentKm - entries.first.currentKm 
      : 0.0;
  
  final averagePricePerLiter = totalFuel > 0 ? totalCost / totalFuel : 0.0;
  final costPerKilometer = totalDistance > 0 ? totalCost / totalDistance : 0.0;

  return {
    'totalCost': totalCost,
    'totalFuel': totalFuel,
    'totalDistance': totalDistance,
    'averagePricePerLiter': averagePricePerLiter,
    'costPerKilometer': costPerKilometer,
    'entriesCount': entries.length,
  };
}

/// Provider for country-wise fuel price comparison
@riverpod
Future<Map<String, double>> countryPriceComparison(
  CountryPriceComparisonRef ref, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  // Get fuel entries grouped by country
  final groupedEntries = await ref.watch(fuelEntriesGroupedByCountryProvider.future);
  
  final countryAverages = <String, double>{};
  
  for (final entry in groupedEntries.entries) {
    final country = entry.key;
    var entries = entry.value;
    
    // Filter by date range if specified
    if (startDate != null && endDate != null) {
      entries = entries.where((e) => 
        e.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        e.date.isBefore(endDate.add(const Duration(days: 1)))
      ).toList();
    }
    
    if (entries.isNotEmpty) {
      final averagePrice = entries
          .map((e) => e.pricePerLiter)
          .reduce((a, b) => a + b) / entries.length;
      countryAverages[country] = averagePrice;
    }
  }

  return countryAverages;
}