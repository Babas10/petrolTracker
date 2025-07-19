import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/widgets/chart_webview.dart';

/// Service for transforming data into chart-ready formats
class ChartDataService {
  /// Transform fuel entries into consumption chart data
  static List<ChartDataPoint> transformConsumptionData(
    List<FuelEntryModel> entries,
  ) {
    // Sort entries by date
    final sortedEntries = List<FuelEntryModel>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    return sortedEntries
        .where((entry) => entry.consumption != null)
        .map((entry) => ChartDataPoint(
              date: entry.date,
              value: entry.consumption!,
              metadata: {
                'entryId': entry.id,
                'vehicleId': entry.vehicleId,
                'fuelAmount': entry.fuelAmount,
                'currentKm': entry.currentKm,
              },
            ))
        .toList();
  }

  /// Transform fuel entries into price trend chart data
  static List<ChartDataPoint> transformPriceTrendData(
    List<FuelEntryModel> entries,
  ) {
    // Sort entries by date
    final sortedEntries = List<FuelEntryModel>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    return sortedEntries
        .map((entry) => ChartDataPoint(
              date: entry.date,
              value: entry.pricePerLiter,
              metadata: {
                'entryId': entry.id,
                'vehicleId': entry.vehicleId,
                'country': entry.country,
                'totalPrice': entry.price,
                'fuelAmount': entry.fuelAmount,
              },
            ))
        .toList();
  }

  /// Transform fuel entries into monthly average consumption data
  static List<ChartDataPoint> transformMonthlyAverageData(
    List<FuelEntryModel> entries,
  ) {
    final monthlyData = <String, List<double>>{};

    // Group entries by month
    for (final entry in entries) {
      if (entry.consumption != null) {
        final monthKey = '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}';
        monthlyData.putIfAbsent(monthKey, () => []).add(entry.consumption!);
      }
    }

    // Calculate averages and create chart data
    final chartData = <ChartDataPoint>[];
    final sortedMonths = monthlyData.keys.toList()..sort();

    for (final month in sortedMonths) {
      final consumptions = monthlyData[month]!;
      final average = consumptions.reduce((a, b) => a + b) / consumptions.length;
      
      // Parse month back to date (first day of month)
      final parts = month.split('-');
      final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);

      chartData.add(ChartDataPoint(
        date: date,
        value: average,
        metadata: {
          'month': month,
          'entryCount': consumptions.length,
          'total': consumptions.reduce((a, b) => a + b),
        },
      ));
    }

    return chartData;
  }

  /// Transform fuel entries into cost analysis data
  static List<ChartDataPoint> transformCostAnalysisData(
    List<FuelEntryModel> entries,
  ) {
    // Sort entries by date
    final sortedEntries = List<FuelEntryModel>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));

    return sortedEntries
        .map((entry) => ChartDataPoint(
              date: entry.date,
              value: entry.price,
              metadata: {
                'entryId': entry.id,
                'vehicleId': entry.vehicleId,
                'country': entry.country,
                'pricePerLiter': entry.pricePerLiter,
                'fuelAmount': entry.fuelAmount,
                'currentKm': entry.currentKm,
              },
            ))
        .toList();
  }

  /// Transform fuel entries by country into multi-series data
  static List<MultiSeriesChartData> transformCountryComparisonData(
    List<FuelEntryModel> entries,
  ) {
    // Group entries by date and country
    final dateCountryData = <String, Map<String, List<double>>>{};

    for (final entry in entries) {
      final dateKey = entry.date.toIso8601String().split('T')[0];
      dateCountryData.putIfAbsent(dateKey, () => {});
      dateCountryData[dateKey]!
          .putIfAbsent(entry.country, () => [])
          .add(entry.pricePerLiter);
    }

    // Calculate averages for each date and country
    final chartData = <MultiSeriesChartData>[];
    final sortedDates = dateCountryData.keys.toList()..sort();

    for (final dateKey in sortedDates) {
      final countryData = dateCountryData[dateKey]!;
      final averages = <String, double>{};

      for (final country in countryData.keys) {
        final prices = countryData[country]!;
        averages[country] = prices.reduce((a, b) => a + b) / prices.length;
      }

      chartData.add(MultiSeriesChartData(
        date: DateTime.parse(dateKey),
        values: averages,
      ));
    }

    return chartData;
  }

  /// Transform fuel entries into vehicle comparison data
  static List<MultiSeriesChartData> transformVehicleComparisonData(
    List<FuelEntryModel> entries,
    List<VehicleModel> vehicles,
  ) {
    // Create vehicle name mapping
    final vehicleNames = <int, String>{};
    for (final vehicle in vehicles) {
      if (vehicle.id != null) {
        vehicleNames[vehicle.id!] = vehicle.name;
      }
    }

    // Group entries by date and vehicle
    final dateVehicleData = <String, Map<String, List<double>>>{};

    for (final entry in entries) {
      if (entry.consumption != null && vehicleNames.containsKey(entry.vehicleId)) {
        final dateKey = entry.date.toIso8601String().split('T')[0];
        final vehicleName = vehicleNames[entry.vehicleId]!;
        
        dateVehicleData.putIfAbsent(dateKey, () => {});
        dateVehicleData[dateKey]!
            .putIfAbsent(vehicleName, () => [])
            .add(entry.consumption!);
      }
    }

    // Calculate averages for each date and vehicle
    final chartData = <MultiSeriesChartData>[];
    final sortedDates = dateVehicleData.keys.toList()..sort();

    for (final dateKey in sortedDates) {
      final vehicleData = dateVehicleData[dateKey]!;
      final averages = <String, double>{};

      for (final vehicleName in vehicleData.keys) {
        final consumptions = vehicleData[vehicleName]!;
        averages[vehicleName] = consumptions.reduce((a, b) => a + b) / consumptions.length;
      }

      chartData.add(MultiSeriesChartData(
        date: DateTime.parse(dateKey),
        values: averages,
      ));
    }

    return chartData;
  }

  /// Transform fuel entries into bar chart data by category
  static List<ChartDataPoint> transformCategoryBarData(
    List<FuelEntryModel> entries,
    String Function(FuelEntryModel) categoryExtractor,
    double Function(FuelEntryModel) valueExtractor,
  ) {
    final categoryData = <String, List<double>>{};

    // Group data by category
    for (final entry in entries) {
      final category = categoryExtractor(entry);
      final value = valueExtractor(entry);
      categoryData.putIfAbsent(category, () => []).add(value);
    }

    // Calculate totals or averages for each category
    return categoryData.entries
        .map((entry) => ChartDataPoint(
              label: entry.key,
              value: entry.value.reduce((a, b) => a + b),
              metadata: {
                'count': entry.value.length,
                'average': entry.value.reduce((a, b) => a + b) / entry.value.length,
              },
            ))
        .toList();
  }

  /// Transform data for fuel efficiency comparison by country
  static List<ChartDataPoint> transformCountryEfficiencyData(
    List<FuelEntryModel> entries,
  ) {
    return transformCategoryBarData(
      entries.where((e) => e.consumption != null).toList(),
      (entry) => entry.country,
      (entry) => entry.consumption!,
    );
  }

  /// Transform data for cost analysis by country
  static List<ChartDataPoint> transformCountryCostData(
    List<FuelEntryModel> entries,
  ) {
    return transformCategoryBarData(
      entries,
      (entry) => entry.country,
      (entry) => entry.price,
    );
  }

  /// Transform data for monthly fuel spending
  static List<ChartDataPoint> transformMonthlySpendingData(
    List<FuelEntryModel> entries,
  ) {
    return transformCategoryBarData(
      entries,
      (entry) => '${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}',
      (entry) => entry.price,
    );
  }

  /// Calculate statistics for chart data
  static Map<String, double> calculateChartStatistics(List<ChartDataPoint> data) {
    if (data.isEmpty) {
      return {
        'min': 0,
        'max': 0,
        'average': 0,
        'total': 0,
        'count': 0,
      };
    }

    final values = data.map((d) => d.value).toList();
    values.sort();

    return {
      'min': values.first,
      'max': values.last,
      'average': values.reduce((a, b) => a + b) / values.length,
      'total': values.reduce((a, b) => a + b),
      'count': values.length.toDouble(),
    };
  }

  /// Filter chart data by date range
  static List<ChartDataPoint> filterByDateRange(
    List<ChartDataPoint> data,
    DateTime startDate,
    DateTime endDate,
  ) {
    return data
        .where((point) =>
            point.date != null &&
            point.date!.isAfter(startDate.subtract(const Duration(days: 1))) &&
            point.date!.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  /// Filter multi-series chart data by date range
  static List<MultiSeriesChartData> filterMultiSeriesByDateRange(
    List<MultiSeriesChartData> data,
    DateTime startDate,
    DateTime endDate,
  ) {
    return data
        .where((point) =>
            point.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            point.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }
}