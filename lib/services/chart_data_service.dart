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

  /// Optimize chart data for dashboard display by showing the most recent data points
  /// This gives users the latest trend which is most relevant for dashboard view
  static List<ChartDataPoint> optimizeForDashboard(
    List<ChartDataPoint> data, {
    int maxPoints = 5,
  }) {
    if (data.length <= maxPoints) {
      return data;
    }

    // Sort by date to ensure chronological order
    final sortedData = List<ChartDataPoint>.from(data);
    sortedData.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return -1;
      if (b.date == null) return 1;
      return a.date!.compareTo(b.date!);
    });
    
    // Return the last N data points (most recent)
    return sortedData.length > maxPoints
        ? sortedData.sublist(sortedData.length - maxPoints)
        : sortedData;
  }

  /// Optimize chart data for full chart view with distributed points
  /// Keeps first, last, and evenly distributed points in between for historical overview
  static List<ChartDataPoint> optimizeForFullChart(
    List<ChartDataPoint> data, {
    int maxPoints = 20,
  }) {
    if (data.length <= maxPoints) {
      return data;
    }

    final optimized = <ChartDataPoint>[];
    
    // Always include first point
    optimized.add(data.first);
    
    // Always include last point if we have more than 1 point
    if (data.length > 1) {
      optimized.add(data.last);
    }
    
    // Add intermediate points evenly distributed
    final intermediateCount = maxPoints - 2; // Subtract first and last
    if (intermediateCount > 0 && data.length > 2) {
      for (int i = 1; i <= intermediateCount; i++) {
        final position = (data.length - 1) * i / (intermediateCount + 1);
        final index = position.round();
        
        // Avoid duplicates with first/last and ensure valid range
        if (index > 0 && index < data.length - 1) {
          final point = data[index];
          if (!optimized.any((p) => p.date == point.date)) {
            optimized.add(point);
          }
        }
      }
    }
    
    // Sort by date to maintain chronological order
    optimized.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return -1;
      if (b.date == null) return 1;
      return a.date!.compareTo(b.date!);
    });
    
    return optimized;
  }

  /// Optimize monthly data for dashboard display by showing the most recent months
  static List<ChartDataPoint> optimizeMonthlyForDashboard(
    List<ChartDataPoint> data, {
    int maxPoints = 6,
  }) {
    if (data.length <= maxPoints) {
      return data;
    }

    // Sort by date to ensure chronological order
    final sortedData = List<ChartDataPoint>.from(data);
    sortedData.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return -1;
      if (b.date == null) return 1;
      return a.date!.compareTo(b.date!);
    });
    
    // Return the last N months (most recent)
    return sortedData.length > maxPoints
        ? sortedData.sublist(sortedData.length - maxPoints)
        : sortedData;
  }

  /// Optimize monthly data for full chart view with distributed months
  static List<ChartDataPoint> optimizeMonthlyForFullChart(
    List<ChartDataPoint> data, {
    int maxPoints = 12,
  }) {
    if (data.length <= maxPoints) {
      return data;
    }

    final optimized = <ChartDataPoint>[];
    
    // For monthly data, we want to show evenly spaced months
    final step = (data.length / maxPoints).ceil();
    
    for (int i = 0; i < data.length; i += step) {
      optimized.add(data[i]);
    }
    
    // Ensure we include the last data point if not already included
    if (optimized.isNotEmpty && optimized.last != data.last) {
      optimized.add(data.last);
    }
    
    return optimized;
  }
}