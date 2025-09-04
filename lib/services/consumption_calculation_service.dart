import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/providers/chart_providers.dart';
import 'package:petrol_tracker/providers/units_providers.dart';

/// Represents a consumption period ending at a full tank
class ConsumptionPeriod {
  final FuelEntryModel startEntry; // Can be full or partial
  final FuelEntryModel endFullTank;
  final List<FuelEntryModel> partialEntries;
  final double totalFuel;
  final double totalDistance;
  final double consumption;
  final double totalCost;

  const ConsumptionPeriod({
    required this.startEntry,
    required this.endFullTank,
    required this.partialEntries,
    required this.totalFuel,
    required this.totalDistance,
    required this.consumption,
    required this.totalCost,
  });

  /// Get all entries in this period (partials + end full tank)
  List<FuelEntryModel> get allEntries => [...partialEntries, endFullTank];

  /// Formatted consumption string with current units
  /// Note: This will be overridden by UI components that have access to Riverpod ref
  String get formattedConsumption => '${consumption.toStringAsFixed(1)} L/100km';
  
  /// Get formatted consumption with specific unit system
  String getFormattedConsumption(UnitSystem unitSystem) {
    final convertedConsumption = unitSystem == UnitSystem.metric 
        ? consumption 
        : UnitConverter.consumptionToImperial(consumption);
    return UnitConverter.formatConsumption(convertedConsumption, unitSystem);
  }

  /// Formatted total cost string
  String get formattedTotalCost => '\$${totalCost.toStringAsFixed(2)}';

  /// Period description for UI
  String get periodDescription {
    final startDate = startEntry.date;
    final endDate = endFullTank.date;
    final days = endDate.difference(startDate).inDays;
    return '${totalDistance.toStringAsFixed(0)} km over $days days';
  }
  
  /// Get period description with specific unit system
  String getPeriodDescription(UnitSystem unitSystem) {
    final startDate = startEntry.date;
    final endDate = endFullTank.date;
    final days = endDate.difference(startDate).inDays;
    final convertedDistance = unitSystem == UnitSystem.metric 
        ? totalDistance 
        : UnitConverter.distanceToImperial(totalDistance);
    final unit = unitSystem.distanceUnit;
    return '${convertedDistance.toStringAsFixed(0)} $unit over $days days';
  }
}

/// Service for calculating fuel consumption using full tank to full tank periods
class ConsumptionCalculationService {
  /// Calculate consumption periods from a list of fuel entries
  /// Focus on periods that END with full tank (meaningful consumption measurement)
  /// This gives periods like: Partial → Full or Full → Partial → Full
  static List<ConsumptionPeriod> calculateConsumptionPeriods(List<FuelEntryModel> entries) {
    final periods = <ConsumptionPeriod>[];
    
    // Sort entries by date to ensure proper order
    final sortedEntries = List<FuelEntryModel>.from(entries)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    // Track the sequence of entries leading up to each full tank
    List<FuelEntryModel> leadingEntries = [];
    
    for (int i = 0; i < sortedEntries.length; i++) {
      final entry = sortedEntries[i];
      
      if (entry.isFullTank) {
        // If we have leading entries, create a consumption period ending at this full tank
        if (leadingEntries.isNotEmpty) {
          final startEntry = leadingEntries.first;
          final partialEntries = leadingEntries.where((e) => !e.isFullTank).toList();
          
          // Create period ending at this full tank
          final period = _createConsumptionPeriod(
            startEntry: startEntry,
            endFullTank: entry,
            partialEntries: partialEntries,
          );
          periods.add(period);
        }
        
        // Start new sequence with this full tank
        leadingEntries = [entry];
      } else {
        // Add partial to the current sequence
        leadingEntries.add(entry);
      }
    }
    
    return periods;
  }

  /// Create a single consumption period
  static ConsumptionPeriod _createConsumptionPeriod({
    required FuelEntryModel startEntry,
    required FuelEntryModel endFullTank,
    required List<FuelEntryModel> partialEntries,
  }) {
    // Calculate total fuel added (partials + end full tank)
    final totalFuel = partialEntries.fold<double>(0, (sum, entry) => sum + entry.fuelAmount) + 
                     endFullTank.fuelAmount;
    
    // Calculate total distance
    final totalDistance = endFullTank.currentKm - startEntry.currentKm;
    
    // Calculate consumption (L/100km)
    final consumption = totalDistance > 0 ? (totalFuel / totalDistance) * 100 : 0.0;
    
    // Calculate total cost (partials + end full tank)
    final totalCost = partialEntries.fold<double>(0, (sum, entry) => sum + entry.price) + 
                     endFullTank.price;
    
    return ConsumptionPeriod(
      startEntry: startEntry,
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
      'startDate': period.startEntry.date.toIso8601String().split('T')[0],
      'endDate': period.endFullTank.date.toIso8601String().split('T')[0],
      'entryCount': period.allEntries.length,
    }).toList();
  }

  /// Generate enhanced consumption data points with period composition details
  static List<EnhancedConsumptionDataPoint> getEnhancedConsumptionDataPoints(List<ConsumptionPeriod> periods) {
    return periods.map((period) {
      final totalEntries = period.allEntries.length;
      final partialEntries = period.partialEntries.length;
      final periodComposition = _generatePeriodComposition(period);
      final entryIds = period.allEntries.map((e) => e.id ?? 0).toList();

      return EnhancedConsumptionDataPoint(
        date: period.endFullTank.date,
        consumption: period.consumption,
        kilometers: period.endFullTank.currentKm,
        totalEntries: totalEntries,
        partialEntries: partialEntries,
        periodComposition: periodComposition,
        entryIds: entryIds,
        periodStart: period.startEntry.date,
        periodEnd: period.endFullTank.date,
        totalFuel: period.totalFuel,
        totalDistance: period.totalDistance,
        totalCost: period.totalCost,
        hasPartialRefuels: partialEntries > 0,
      );
    }).toList();
  }

  /// Generate a human-readable description of the period composition
  static String _generatePeriodComposition(ConsumptionPeriod period) {
    final startType = period.startEntry.isFullTank ? 'Full' : 'Partial';
    final partialCount = period.partialEntries.length;
    
    // Always ends with Full tank in our new logic
    if (startType == 'Full' && partialCount == 0) {
      return 'Full → Full';
    } else if (startType == 'Partial' && partialCount == 0) {
      return 'Partial → Full';
    } else if (startType == 'Full' && partialCount == 1) {
      return 'Full → Partial → Full';
    } else if (startType == 'Partial' && partialCount == 1) {
      return 'Partial → Partial → Full';
    } else if (startType == 'Full' && partialCount > 1) {
      return 'Full → $partialCount Partials → Full';
    } else if (startType == 'Partial' && partialCount > 1) {
      return 'Partial → $partialCount Partials → Full';
    } else {
      return '$startType → Full';
    }
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