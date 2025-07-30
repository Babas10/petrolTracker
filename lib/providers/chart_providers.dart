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

/// Enum for different period types
enum PeriodType {
  weekly,
  monthly,
  yearly,
}

/// Data point for period-based average consumption
class PeriodAverageDataPoint {
  final DateTime date;
  final double averageConsumption;
  final int entryCount;
  final String periodLabel;
  final PeriodType periodType;

  const PeriodAverageDataPoint({
    required this.date,
    required this.averageConsumption,
    required this.entryCount,
    required this.periodLabel,
    required this.periodType,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PeriodAverageDataPoint &&
        other.date == date &&
        other.averageConsumption == averageConsumption &&
        other.entryCount == entryCount &&
        other.periodLabel == periodLabel &&
        other.periodType == periodType;
  }

  @override
  int get hashCode => Object.hash(date, averageConsumption, entryCount, periodLabel, periodType);

  @override
  String toString() {
    return 'PeriodAverageDataPoint(date: $date, averageConsumption: $averageConsumption, entryCount: $entryCount, periodLabel: $periodLabel, periodType: $periodType)';
  }
}

/// Provider for period-based average consumption data
@riverpod
Future<List<PeriodAverageDataPoint>> periodAverageConsumptionData(
  PeriodAverageConsumptionDataRef ref,
  int vehicleId,
  PeriodType periodType, {
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

  // Filter entries with consumption data
  final entriesWithConsumption = entries
      .where((entry) => entry.consumption != null)
      .toList();

  if (entriesWithConsumption.isEmpty) {
    return [];
  }

  // Group entries by period
  final periodData = <String, List<FuelEntryModel>>{};
  
  for (final entry in entriesWithConsumption) {
    final periodKey = _getPeriodKey(entry.date, periodType);
    periodData.putIfAbsent(periodKey, () => []).add(entry);
  }

  // Calculate averages for each period
  final result = <PeriodAverageDataPoint>[];
  final sortedPeriods = periodData.keys.toList()..sort();

  for (final periodKey in sortedPeriods) {
    final periodEntries = periodData[periodKey]!;
    final consumptions = periodEntries
        .where((e) => e.consumption != null)
        .map((e) => e.consumption!)
        .toList();
    
    if (consumptions.isNotEmpty) {
      final average = consumptions.reduce((a, b) => a + b) / consumptions.length;
      final periodDate = _getPeriodDate(periodKey, periodType);
      final periodLabel = _getPeriodLabel(periodKey, periodType);
      
      result.add(PeriodAverageDataPoint(
        date: periodDate,
        averageConsumption: average,
        entryCount: consumptions.length,
        periodLabel: periodLabel,
        periodType: periodType,
      ));
    }
  }

  return result;
}

/// Helper function to get period key for grouping
String _getPeriodKey(DateTime date, PeriodType periodType) {
  switch (periodType) {
    case PeriodType.weekly:
      // Get the Monday of the week
      final monday = date.subtract(Duration(days: date.weekday - 1));
      return '${monday.year}-W${_getWeekOfYear(monday).toString().padLeft(2, '0')}';
    case PeriodType.monthly:
      return '${date.year}-${date.month.toString().padLeft(2, '0')}';
    case PeriodType.yearly:
      return date.year.toString();
  }
}

/// Helper function to get period date from key
DateTime _getPeriodDate(String periodKey, PeriodType periodType) {
  switch (periodType) {
    case PeriodType.weekly:
      // Parse week format: 2023-W52
      final parts = periodKey.split('-W');
      final year = int.parse(parts[0]);
      final week = int.parse(parts[1]);
      return _getDateFromWeek(year, week);
    case PeriodType.monthly:
      // Parse month format: 2023-12
      final parts = periodKey.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
    case PeriodType.yearly:
      return DateTime(int.parse(periodKey), 1, 1);
  }
}

/// Helper function to get period label for display
String _getPeriodLabel(String periodKey, PeriodType periodType) {
  switch (periodType) {
    case PeriodType.weekly:
      final parts = periodKey.split('-W');
      return 'Week ${parts[1]}, ${parts[0]}';
    case PeriodType.monthly:
      final date = _getPeriodDate(periodKey, periodType);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.year}';
    case PeriodType.yearly:
      return periodKey;
  }
}

/// Helper function to get week of year
int _getWeekOfYear(DateTime date) {
  final startOfYear = DateTime(date.year, 1, 1);
  final difference = date.difference(startOfYear).inDays;
  return (difference / 7).ceil();
}

/// Helper function to get date from year and week
DateTime _getDateFromWeek(int year, int week) {
  final jan1 = DateTime(year, 1, 1);
  final daysFromJan1 = (week - 1) * 7;
  return jan1.add(Duration(days: daysFromJan1));
}

/// Provider for overall consumption statistics
@riverpod
Future<Map<String, double>> consumptionStatistics(
  ConsumptionStatisticsRef ref,
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

  // Filter entries with consumption data
  final entriesWithConsumption = entries
      .where((entry) => entry.consumption != null)
      .toList();

  if (entriesWithConsumption.isEmpty) {
    return {
      'average': 0.0,
      'minimum': 0.0,
      'maximum': 0.0,
      'total': 0.0,
      'count': 0.0,
    };
  }

  final consumptions = entriesWithConsumption
      .map((e) => e.consumption!)
      .toList();

  consumptions.sort();

  return {
    'average': consumptions.reduce((a, b) => a + b) / consumptions.length,
    'minimum': consumptions.first,
    'maximum': consumptions.last,
    'total': consumptions.reduce((a, b) => a + b),
    'count': consumptions.length.toDouble(),
  };
}