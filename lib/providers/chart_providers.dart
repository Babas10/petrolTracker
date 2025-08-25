import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/services/consumption_calculation_service.dart';
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

/// Enhanced data point for consumption chart with period composition details
class EnhancedConsumptionDataPoint extends ConsumptionDataPoint {
  final int totalEntries;
  final int partialEntries;
  final String periodComposition;
  final List<int> entryIds;
  final DateTime periodStart;
  final DateTime periodEnd;
  final double totalFuel;
  final double totalDistance;
  final double totalCost;
  final bool hasPartialRefuels;

  const EnhancedConsumptionDataPoint({
    required super.date,
    required super.consumption,
    required super.kilometers,
    required this.totalEntries,
    required this.partialEntries,
    required this.periodComposition,
    required this.entryIds,
    required this.periodStart,
    required this.periodEnd,
    required this.totalFuel,
    required this.totalDistance,
    required this.totalCost,
    required this.hasPartialRefuels,
  });

  /// Returns true if this is a simple Full→Full period
  bool get isSimplePeriod => totalEntries == 2 && partialEntries == 0;

  /// Returns true if this period contains partial refuels
  bool get isComplexPeriod => partialEntries > 0;

  /// Formatted period duration string
  String get formattedDuration {
    final days = periodEnd.difference(periodStart).inDays;
    return '$days days';
  }

  /// Formatted total fuel string
  String get formattedTotalFuel => '${totalFuel.toStringAsFixed(1)}L';

  /// Formatted total cost string
  String get formattedTotalCost => '\$${totalCost.toStringAsFixed(2)}';

  /// Formatted distance string
  String get formattedDistance => '${totalDistance.toStringAsFixed(0)} km';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnhancedConsumptionDataPoint &&
        super == other &&
        other.totalEntries == totalEntries &&
        other.partialEntries == partialEntries &&
        other.periodComposition == periodComposition &&
        other.entryIds.length == entryIds.length &&
        other.periodStart == periodStart &&
        other.periodEnd == periodEnd &&
        other.totalFuel == totalFuel &&
        other.totalDistance == totalDistance &&
        other.totalCost == totalCost &&
        other.hasPartialRefuels == hasPartialRefuels;
  }

  @override
  int get hashCode => Object.hash(
    super.hashCode,
    totalEntries,
    partialEntries,
    periodComposition,
    entryIds,
    periodStart,
    periodEnd,
    totalFuel,
    totalDistance,
    totalCost,
    hasPartialRefuels,
  );

  @override
  String toString() {
    return 'EnhancedConsumptionDataPoint(date: $date, consumption: $consumption, periodComposition: $periodComposition, totalEntries: $totalEntries, partialEntries: $partialEntries)';
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
/// Uses period-based consumption calculation (full tank to full tank)
@riverpod
Future<List<ConsumptionDataPoint>> consumptionChartData(
  ConsumptionChartDataRef ref,
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

  if (entries.isEmpty) {
    return [];
  }

  // Calculate consumption periods using the new service
  final periods = ConsumptionCalculationService.calculateConsumptionPeriods(entries);
  
  if (periods.isEmpty) {
    return [];
  }

  // Convert periods to chart data points (one point per completed period)
  return periods.map((period) => ConsumptionDataPoint(
    date: period.endFullTank.date, // Use the end date of the period
    consumption: period.consumption, // Period-based consumption
    kilometers: period.endFullTank.currentKm, // End kilometers
  )).toList();
}

/// Provider for enhanced consumption chart data with period composition details
@riverpod
Future<List<EnhancedConsumptionDataPoint>> enhancedConsumptionChartData(
  EnhancedConsumptionChartDataRef ref,
  int vehicleId, {
  DateTime? startDate,
  DateTime? endDate,
  String? countryFilter,
}) async {
  print('🔍 [PROVIDER] enhancedConsumptionChartData called for vehicle $vehicleId');
  print('🔍 [PROVIDER] Date range: $startDate to $endDate');
  print('🔍 [PROVIDER] Country filter: $countryFilter');
  
  // Get fuel entries for the vehicle
  List<FuelEntryModel> entries;
  
  if (startDate != null && endDate != null) {
    print('🔍 [PROVIDER] Using date range provider...');
    entries = await ref.watch(
      fuelEntriesByVehicleAndDateRangeProvider(vehicleId, startDate, endDate).future,
    );
    print('🔍 [PROVIDER] Date range provider returned ${entries.length} entries');
  } else {
    print('🔍 [PROVIDER] Using all entries provider...');
    entries = await ref.watch(fuelEntriesByVehicleProvider(vehicleId).future);
    print('🔍 [PROVIDER] All entries provider returned ${entries.length} entries');
  }

  // Apply country filter if specified
  if (countryFilter != null) {
    final beforeFilter = entries.length;
    entries = entries.where((entry) => entry.country == countryFilter).toList();
    print('🔍 [PROVIDER] Country filter applied: $beforeFilter -> ${entries.length} entries');
  }

  if (entries.isEmpty) {
    print('🔍 [PROVIDER] No entries after filtering - returning empty list');
    return [];
  }

  print('🔍 [PROVIDER] Starting consumption calculation with ${entries.length} entries');
  if (entries.isNotEmpty) {
    print('🔍 [PROVIDER] Entry dates: ${entries.last.date} to ${entries.first.date}');
    print('🔍 [PROVIDER] Entries with full tank: ${entries.where((e) => e.isFullTank).length}');
    print('🔍 [PROVIDER] Entries with partial tank: ${entries.where((e) => !e.isFullTank).length}');
  }

  // Calculate consumption periods using the new service
  print('🔍 [PROVIDER] Calling ConsumptionCalculationService.calculateConsumptionPeriods...');
  final periods = ConsumptionCalculationService.calculateConsumptionPeriods(entries);
  print('🔍 [PROVIDER] Got ${periods.length} consumption periods');
  
  if (periods.isEmpty) {
    print('🔍 [PROVIDER] ❌ No consumption periods calculated despite having ${entries.length} entries');
    print('🔍 [PROVIDER] This usually means not enough full tank entries to calculate consumption');
    return [];
  }

  // Convert periods to enhanced chart data points with composition details
  print('🔍 [PROVIDER] Converting periods to enhanced data points...');
  final result = ConsumptionCalculationService.getEnhancedConsumptionDataPoints(periods);
  print('🔍 [PROVIDER] Returning ${result.length} enhanced data points');
  return result;
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

/// Data point for spending chart (Issues #10, #11, #14)
class SpendingDataPoint {
  final DateTime date;
  final double amount;
  final String country;
  final String currency;
  final String periodLabel;

  const SpendingDataPoint({
    required this.date,
    required this.amount,
    required this.country,
    required this.currency,
    required this.periodLabel,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SpendingDataPoint &&
        other.date == date &&
        other.amount == amount &&
        other.country == country &&
        other.currency == currency &&
        other.periodLabel == periodLabel;
  }

  @override
  int get hashCode => Object.hash(date, amount, country, currency, periodLabel);

  @override
  String toString() {
    return 'SpendingDataPoint(date: $date, amount: $amount, country: $country, currency: $currency, periodLabel: $periodLabel)';
  }
}

/// Data point for country spending comparison
class CountrySpendingDataPoint {
  final String country;
  final double totalSpent;
  final double averagePricePerLiter;
  final int entryCount;
  final String currency;

  const CountrySpendingDataPoint({
    required this.country,
    required this.totalSpent,
    required this.averagePricePerLiter,
    required this.entryCount,
    required this.currency,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CountrySpendingDataPoint &&
        other.country == country &&
        other.totalSpent == totalSpent &&
        other.averagePricePerLiter == averagePricePerLiter &&
        other.entryCount == entryCount &&
        other.currency == currency;
  }

  @override
  int get hashCode => Object.hash(country, totalSpent, averagePricePerLiter, entryCount, currency);

  @override
  String toString() {
    return 'CountrySpendingDataPoint(country: $country, totalSpent: $totalSpent, averagePricePerLiter: $averagePricePerLiter, entryCount: $entryCount, currency: $currency)';
  }
}

/// Provider for monthly spending data (Issue #11)
@riverpod
Future<List<SpendingDataPoint>> monthlySpendingData(
  MonthlySpendingDataRef ref,
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

  if (entries.isEmpty) {
    return [];
  }

  // Group entries by month
  final monthlyData = <String, List<FuelEntryModel>>{};
  
  for (final entry in entries) {
    final monthKey = '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}';
    monthlyData.putIfAbsent(monthKey, () => []).add(entry);
  }

  // Calculate spending for each month
  final result = <SpendingDataPoint>[];
  final sortedMonths = monthlyData.keys.toList()..sort();

  for (final monthKey in sortedMonths) {
    final monthEntries = monthlyData[monthKey]!;
    final totalAmount = monthEntries.fold<double>(0, (sum, entry) => sum + entry.price);
    
    // Use the most common country and currency for the month
    final countryStats = <String, int>{};
    final currencyStats = <String, int>{};
    
    for (final entry in monthEntries) {
      countryStats[entry.country] = (countryStats[entry.country] ?? 0) + 1;
      // Extract currency from price formatting (this is simplified)
      final currency = _extractCurrencyFromEntries(monthEntries);
      currencyStats[currency] = (currencyStats[currency] ?? 0) + 1;
    }
    
    final mostCommonCountry = countryStats.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    final mostCommonCurrency = currencyStats.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    
    final monthDate = _getMonthDate(monthKey);
    final periodLabel = _getMonthLabel(monthKey);
    
    result.add(SpendingDataPoint(
      date: monthDate,
      amount: totalAmount,
      country: mostCommonCountry,
      currency: mostCommonCurrency,
      periodLabel: periodLabel,
    ));
  }

  return result;
}

/// Provider for country spending comparison (Issues #10, #11)
@riverpod
Future<List<CountrySpendingDataPoint>> countrySpendingComparison(
  CountrySpendingComparisonRef ref,
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
    return [];
  }

  // Group entries by country
  final countryData = <String, List<FuelEntryModel>>{};
  
  for (final entry in entries) {
    countryData.putIfAbsent(entry.country, () => []).add(entry);
  }

  // Calculate spending for each country
  final result = <CountrySpendingDataPoint>[];
  
  for (final entry in countryData.entries) {
    final country = entry.key;
    final countryEntries = entry.value;
    
    final totalSpent = countryEntries.fold<double>(0, (sum, entry) => sum + entry.price);
    final averagePricePerLiter = countryEntries.fold<double>(0, (sum, entry) => sum + entry.pricePerLiter) / countryEntries.length;
    final currency = _extractCurrencyFromEntries(countryEntries);
    
    result.add(CountrySpendingDataPoint(
      country: country,
      totalSpent: totalSpent,
      averagePricePerLiter: averagePricePerLiter,
      entryCount: countryEntries.length,
      currency: currency,
    ));
  }

  // Sort by total spent (highest first)
  result.sort((a, b) => b.totalSpent.compareTo(a.totalSpent));
  
  return result;
}

/// Provider for price trends by country over time (Issue #10)
@riverpod
Future<Map<String, List<PriceTrendDataPoint>>> priceTrendsByCountry(
  PriceTrendsByCountryRef ref,
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
    return {};
  }

  // Group entries by country
  final countryTrends = <String, List<PriceTrendDataPoint>>{};
  
  for (final entry in entries) {
    final dataPoint = PriceTrendDataPoint(
      date: entry.date,
      pricePerLiter: entry.pricePerLiter,
      country: entry.country,
    );
    
    countryTrends.putIfAbsent(entry.country, () => []).add(dataPoint);
  }

  // Sort each country's trends by date
  for (final countryData in countryTrends.values) {
    countryData.sort((a, b) => a.date.compareTo(b.date));
  }
  
  return countryTrends;
}

/// Provider for comprehensive spending statistics (Issue #14)
@riverpod
Future<Map<String, dynamic>> spendingStatistics(
  SpendingStatisticsRef ref,
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

  if (entries.isEmpty) {
    return {
      'totalSpent': 0.0,
      'averagePerFillUp': 0.0,
      'averagePerMonth': 0.0,
      'mostExpensiveFillUp': 0.0,
      'cheapestFillUp': 0.0,
      'totalFillUps': 0,
      'mostExpensiveCountry': '',
      'cheapestCountry': '',
      'totalCountries': 0,
    };
  }

  // Calculate basic statistics
  final totalSpent = entries.fold<double>(0, (sum, entry) => sum + entry.price);
  final averagePerFillUp = totalSpent / entries.length;
  final prices = entries.map((e) => e.price).toList()..sort();
  final mostExpensiveFillUp = prices.last;
  final cheapestFillUp = prices.first;

  // Calculate monthly average (if we have enough data)
  entries.sort((a, b) => a.date.compareTo(b.date));
  final timeSpan = entries.last.date.difference(entries.first.date);
  final months = timeSpan.inDays / 30.0;
  final averagePerMonth = months > 0 ? totalSpent / months : totalSpent;

  // Find most/least expensive countries
  final countrySpending = <String, double>{};
  final countryEntryCount = <String, int>{};
  
  for (final entry in entries) {
    countrySpending[entry.country] = (countrySpending[entry.country] ?? 0) + entry.price;
    countryEntryCount[entry.country] = (countryEntryCount[entry.country] ?? 0) + 1;
  }

  // Calculate average spending per entry by country to find most/least expensive
  final countryAverages = <String, double>{};
  for (final country in countrySpending.keys) {
    countryAverages[country] = countrySpending[country]! / countryEntryCount[country]!;
  }

  final sortedCountries = countryAverages.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final mostExpensiveCountry = sortedCountries.isNotEmpty ? sortedCountries.first.key : '';
  final cheapestCountry = sortedCountries.isNotEmpty ? sortedCountries.last.key : '';

  return {
    'totalSpent': totalSpent,
    'averagePerFillUp': averagePerFillUp,
    'averagePerMonth': averagePerMonth,
    'mostExpensiveFillUp': mostExpensiveFillUp,
    'cheapestFillUp': cheapestFillUp,
    'totalFillUps': entries.length,
    'mostExpensiveCountry': mostExpensiveCountry,
    'cheapestCountry': cheapestCountry,
    'totalCountries': countrySpending.keys.length,
    'countrySpending': countrySpending,
    'countryAverages': countryAverages,
  };
}

/// Helper function to extract currency from entries (simplified)
String _extractCurrencyFromEntries(List<FuelEntryModel> entries) {
  // This is a simplified approach - in a real app you'd store currency separately
  // For now, we'll guess based on country or use a default
  if (entries.isEmpty) return 'USD';
  
  final country = entries.first.country.toLowerCase();
  switch (country) {
    case 'canada': return 'CAD';
    case 'usa': case 'united states': return 'USD';
    case 'germany': case 'france': return 'EUR';
    case 'australia': return 'AUD';
    case 'japan': return 'JPY';
    default: return 'USD';
  }
}

/// Helper function to get date from month key
DateTime _getMonthDate(String monthKey) {
  final parts = monthKey.split('-');
  return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
}

/// Helper function to get month label for display
String _getMonthLabel(String monthKey) {
  final date = _getMonthDate(monthKey);
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return '${months[date.month - 1]} ${date.year}';
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
/// Uses period-based consumption calculation (full tank to full tank)
@riverpod
Future<Map<String, double>> consumptionStatistics(
  ConsumptionStatisticsRef ref,
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

  if (entries.isEmpty) {
    return {
      'average': 0.0,
      'minimum': 0.0,
      'maximum': 0.0,
      'total': 0.0,
      'count': 0.0,
    };
  }

  // Calculate consumption periods using the new service
  final periods = ConsumptionCalculationService.calculateConsumptionPeriods(entries);
  
  if (periods.isEmpty) {
    return {
      'average': 0.0,
      'minimum': 0.0,
      'maximum': 0.0,
      'total': 0.0,
      'count': 0.0,
    };
  }

  // Use the built-in statistics calculation from our service
  return ConsumptionCalculationService.calculateStatistics(periods);
}