import 'package:petrol_tracker/models/fuel_entry_model.dart';

/// Represents a consumption period from one full tank to another
class ConsumptionPeriod {
  final FuelEntryModel startFullTank;
  final FuelEntryModel endFullTank;
  final List<FuelEntryModel> partialEntries;
  final double totalFuel;
  final double totalDistance;
  final double consumption;
  final double totalCost;

  const ConsumptionPeriod({
    required this.startFullTank,
    required this.endFullTank,
    required this.partialEntries,
    required this.totalFuel,
    required this.totalDistance,
    required this.consumption,
    required this.totalCost,
  });

  /// Get all entries in this period (partials + end full tank)
  List<FuelEntryModel> get allEntries => [...partialEntries, endFullTank];

  /// Formatted consumption string
  String get formattedConsumption => '${consumption.toStringAsFixed(1)} L/100km';

  /// Formatted total cost string
  String get formattedTotalCost => '\$${totalCost.toStringAsFixed(2)}';

  /// Period description for UI
  String get periodDescription {
    final startDate = startFullTank.date;
    final endDate = endFullTank.date;
    final days = endDate.difference(startDate).inDays;
    return '${totalDistance.toStringAsFixed(0)} km over $days days';
  }
}

/// Service for calculating fuel consumption using full tank to full tank periods
class ConsumptionCalculationService {
  /// Calculate consumption periods from a list of fuel entries
  /// Only calculates consumption between full tank entries
  static List<ConsumptionPeriod> calculateConsumptionPeriods(List<FuelEntryModel> entries) {
    final periods = <ConsumptionPeriod>[];
    
    // Sort entries by date to ensure proper order
    final sortedEntries = List<FuelEntryModel>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    FuelEntryModel? lastFullTank;
    List<FuelEntryModel> currentPartials = [];
    
    for (final entry in sortedEntries) {
      if (entry.isFullTank) {
        if (lastFullTank != null) {
          // Create consumption period from last full tank to this one
          final period = _createConsumptionPeriod(
            startFullTank: lastFullTank,
            endFullTank: entry,
            partialEntries: currentPartials,
          );
          periods.add(period);
        }
        lastFullTank = entry;
        currentPartials.clear();
      } else {
        currentPartials.add(entry);
      }
    }
    
    return periods;
  }

  /// Create a single consumption period
  static ConsumptionPeriod _createConsumptionPeriod({
    required FuelEntryModel startFullTank,
    required FuelEntryModel endFullTank,
    required List<FuelEntryModel> partialEntries,
  }) {
    // Calculate total fuel added (partials + end full tank)
    final totalFuel = partialEntries.fold<double>(0, (sum, entry) => sum + entry.fuelAmount) + 
                     endFullTank.fuelAmount;
    
    // Calculate total distance
    final totalDistance = endFullTank.currentKm - startFullTank.currentKm;
    
    // Calculate consumption (L/100km)
    final consumption = totalDistance > 0 ? (totalFuel / totalDistance) * 100 : 0.0;
    
    // Calculate total cost (partials + end full tank)
    final totalCost = partialEntries.fold<double>(0, (sum, entry) => sum + entry.price) + 
                     endFullTank.price;
    
    return ConsumptionPeriod(
      startFullTank: startFullTank,
      endFullTank: endFullTank,
      partialEntries: partialEntries,
      totalFuel: totalFuel,
      totalDistance: totalDistance,
      consumption: consumption,
      totalCost: totalCost,
    );
  }

  /// Get consumption data points for charts (one point per period)
  static List<Map<String, dynamic>> getConsumptionDataPoints(List<ConsumptionPeriod> periods) {
    return periods.map((period) => {
      'date': period.endFullTank.date.toIso8601String().split('T')[0],
      'value': period.consumption,
      'km': period.endFullTank.currentKm,
      'fuel': period.totalFuel,
      'cost': period.totalCost,
      'distance': period.totalDistance,
      'startDate': period.startFullTank.date.toIso8601String().split('T')[0],
      'endDate': period.endFullTank.date.toIso8601String().split('T')[0],
      'entryCount': period.allEntries.length,
    }).toList();
  }

  /// Calculate statistics from consumption periods
  static Map<String, double> calculateStatistics(List<ConsumptionPeriod> periods) {
    if (periods.isEmpty) {
      return {
        'average': 0.0,
        'minimum': 0.0,
        'maximum': 0.0,
        'totalDistance': 0.0,
        'totalFuel': 0.0,
        'totalCost': 0.0,
      };
    }

    final consumptions = periods.map((p) => p.consumption).toList();
    final average = consumptions.reduce((a, b) => a + b) / consumptions.length;
    final minimum = consumptions.reduce((a, b) => a < b ? a : b);
    final maximum = consumptions.reduce((a, b) => a > b ? a : b);
    
    final totalDistance = periods.fold<double>(0, (sum, p) => sum + p.totalDistance);
    final totalFuel = periods.fold<double>(0, (sum, p) => sum + p.totalFuel);
    final totalCost = periods.fold<double>(0, (sum, p) => sum + p.totalCost);

    return {
      'average': average,
      'minimum': minimum,
      'maximum': maximum,
      'totalDistance': totalDistance,
      'totalFuel': totalFuel,
      'totalCost': totalCost,
    };
  }

  /// Update fuel entries with period-based consumption calculations
  /// This replaces the old individual entry consumption values
  static List<FuelEntryModel> updateEntriesWithPeriodConsumption(
    List<FuelEntryModel> entries,
    List<ConsumptionPeriod> periods,
  ) {
    final updatedEntries = <FuelEntryModel>[];
    
    // Create a map of entry ID to consumption period
    final entryToPeriod = <int, ConsumptionPeriod>{};
    for (final period in periods) {
      for (final entry in period.allEntries) {
        if (entry.id != null) {
          entryToPeriod[entry.id!] = period;
        }
      }
    }
    
    // Update entries with period consumption
    for (final entry in entries) {
      if (entry.id != null && entryToPeriod.containsKey(entry.id)) {
        final period = entryToPeriod[entry.id!]!;
        // Only assign consumption to the end full tank entry of each period
        final consumption = entry.id == period.endFullTank.id ? period.consumption : null;
        updatedEntries.add(entry.copyWith(consumption: consumption));
      } else {
        // Entry not part of any complete period (e.g., last entry is partial)
        updatedEntries.add(entry.copyWith(consumption: null));
      }
    }
    
    return updatedEntries;
  }

  /// Check if there are any incomplete periods (partial entries without following full tank)
  static bool hasIncompletePeriods(List<FuelEntryModel> entries) {
    final sortedEntries = List<FuelEntryModel>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // If last entry is not a full tank, there's an incomplete period
    return sortedEntries.isNotEmpty && !sortedEntries.last.isFullTank;
  }

  /// Get entries that are part of incomplete periods
  static List<FuelEntryModel> getIncompletePeriodsEntries(List<FuelEntryModel> entries) {
    final sortedEntries = List<FuelEntryModel>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    final incompleteEntries = <FuelEntryModel>[];
    
    // Find the last full tank entry
    int lastFullTankIndex = -1;
    for (int i = sortedEntries.length - 1; i >= 0; i--) {
      if (sortedEntries[i].isFullTank) {
        lastFullTankIndex = i;
        break;
      }
    }
    
    // If there are entries after the last full tank, they're incomplete
    if (lastFullTankIndex >= 0 && lastFullTankIndex < sortedEntries.length - 1) {
      incompleteEntries.addAll(sortedEntries.sublist(lastFullTankIndex + 1));
    }
    
    return incompleteEntries;
  }
}