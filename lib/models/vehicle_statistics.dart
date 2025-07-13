/// Statistics model for vehicles
/// 
/// Contains aggregated data about a vehicle's fuel consumption,
/// costs, and usage patterns.
class VehicleStatistics {
  final int vehicleId;
  final int totalEntries;
  final double totalFuelConsumed;
  final double totalCostSpent;
  final double averageConsumption;
  final double averageFuelAmount;
  final double averageCost;
  final double totalDistanceTraveled;
  final DateTime? firstEntryDate;
  final DateTime? lastEntryDate;
  final Map<String, int> countryBreakdown;
  final double? bestConsumption;
  final double? worstConsumption;

  const VehicleStatistics({
    required this.vehicleId,
    required this.totalEntries,
    required this.totalFuelConsumed,
    required this.totalCostSpent,
    required this.averageConsumption,
    required this.averageFuelAmount,
    required this.averageCost,
    required this.totalDistanceTraveled,
    this.firstEntryDate,
    this.lastEntryDate,
    required this.countryBreakdown,
    this.bestConsumption,
    this.worstConsumption,
  });

  /// Create empty statistics for vehicles with no entries
  factory VehicleStatistics.empty(int vehicleId) {
    return VehicleStatistics(
      vehicleId: vehicleId,
      totalEntries: 0,
      totalFuelConsumed: 0.0,
      totalCostSpent: 0.0,
      averageConsumption: 0.0,
      averageFuelAmount: 0.0,
      averageCost: 0.0,
      totalDistanceTraveled: 0.0,
      countryBreakdown: {},
    );
  }

  /// Create statistics from fuel entry data
  factory VehicleStatistics.fromEntries(
    int vehicleId,
    List<dynamic> entries, // FuelEntryModel list
  ) {
    if (entries.isEmpty) {
      return VehicleStatistics.empty(vehicleId);
    }

    // Calculate totals
    double totalFuel = 0.0;
    double totalCost = 0.0;
    double totalConsumption = 0.0;
    int validConsumptionEntries = 0;
    final Map<String, int> countries = {};
    double? bestConsumption;
    double? worstConsumption;

    DateTime? firstDate;
    DateTime? lastDate;

    for (final entry in entries) {
      totalFuel += entry.fuelAmount as double;
      totalCost += entry.price as double;

      // Track consumption values
      final consumption = entry.consumption as double?;
      if (consumption != null && consumption > 0) {
        totalConsumption += consumption;
        validConsumptionEntries++;

        // Track best/worst consumption
        if (bestConsumption == null || consumption < bestConsumption) {
          bestConsumption = consumption;
        }
        if (worstConsumption == null || consumption > worstConsumption) {
          worstConsumption = consumption;
        }
      }

      // Track countries
      final country = entry.country as String;
      countries[country] = (countries[country] ?? 0) + 1;

      // Track date range
      final entryDate = entry.date as DateTime;
      if (firstDate == null || entryDate.isBefore(firstDate)) {
        firstDate = entryDate;
      }
      if (lastDate == null || entryDate.isAfter(lastDate)) {
        lastDate = entryDate;
      }
    }

    // Calculate averages
    final avgConsumption = validConsumptionEntries > 0 
        ? totalConsumption / validConsumptionEntries 
        : 0.0;
    final avgFuelAmount = totalFuel / entries.length;
    final avgCost = totalCost / entries.length;

    // Calculate total distance (simplified - based on entries)
    double totalDistance = 0.0;
    if (entries.length > 1) {
      final firstEntry = entries.last; // Oldest entry
      final lastEntry = entries.first; // Newest entry
      totalDistance = (lastEntry.currentKm as double) - (firstEntry.currentKm as double);
    }

    return VehicleStatistics(
      vehicleId: vehicleId,
      totalEntries: entries.length,
      totalFuelConsumed: totalFuel,
      totalCostSpent: totalCost,
      averageConsumption: avgConsumption,
      averageFuelAmount: avgFuelAmount,
      averageCost: avgCost,
      totalDistanceTraveled: totalDistance,
      firstEntryDate: firstDate,
      lastEntryDate: lastDate,
      countryBreakdown: countries,
      bestConsumption: bestConsumption,
      worstConsumption: worstConsumption,
    );
  }

  /// Get formatted average consumption string
  String get formattedAverageConsumption {
    if (averageConsumption == 0.0) return 'N/A';
    return '${averageConsumption.toStringAsFixed(1)}L/100km';
  }

  /// Get formatted total cost string
  String get formattedTotalCost {
    return '\$${totalCostSpent.toStringAsFixed(2)}';
  }

  /// Get formatted average cost string
  String get formattedAverageCost {
    if (averageCost == 0.0) return 'N/A';
    return '\$${averageCost.toStringAsFixed(2)}';
  }

  /// Get formatted total fuel string
  String get formattedTotalFuel {
    return '${totalFuelConsumed.toStringAsFixed(1)}L';
  }

  /// Get formatted total distance string
  String get formattedTotalDistance {
    return '${totalDistanceTraveled.toStringAsFixed(0)}km';
  }

  /// Get most frequent country
  String? get mostFrequentCountry {
    if (countryBreakdown.isEmpty) return null;
    
    return countryBreakdown.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get efficiency rating (good, average, poor)
  String get efficiencyRating {
    if (averageConsumption == 0.0) return 'Unknown';
    
    if (averageConsumption <= 6.0) return 'Excellent';
    if (averageConsumption <= 8.0) return 'Good';
    if (averageConsumption <= 10.0) return 'Average';
    if (averageConsumption <= 12.0) return 'Poor';
    return 'Very Poor';
  }

  /// Create a copy with updated values
  VehicleStatistics copyWith({
    int? vehicleId,
    int? totalEntries,
    double? totalFuelConsumed,
    double? totalCostSpent,
    double? averageConsumption,
    double? averageFuelAmount,
    double? averageCost,
    double? totalDistanceTraveled,
    DateTime? firstEntryDate,
    DateTime? lastEntryDate,
    Map<String, int>? countryBreakdown,
    double? bestConsumption,
    double? worstConsumption,
  }) {
    return VehicleStatistics(
      vehicleId: vehicleId ?? this.vehicleId,
      totalEntries: totalEntries ?? this.totalEntries,
      totalFuelConsumed: totalFuelConsumed ?? this.totalFuelConsumed,
      totalCostSpent: totalCostSpent ?? this.totalCostSpent,
      averageConsumption: averageConsumption ?? this.averageConsumption,
      averageFuelAmount: averageFuelAmount ?? this.averageFuelAmount,
      averageCost: averageCost ?? this.averageCost,
      totalDistanceTraveled: totalDistanceTraveled ?? this.totalDistanceTraveled,
      firstEntryDate: firstEntryDate ?? this.firstEntryDate,
      lastEntryDate: lastEntryDate ?? this.lastEntryDate,
      countryBreakdown: countryBreakdown ?? this.countryBreakdown,
      bestConsumption: bestConsumption ?? this.bestConsumption,
      worstConsumption: worstConsumption ?? this.worstConsumption,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleStatistics &&
        other.vehicleId == vehicleId &&
        other.totalEntries == totalEntries &&
        other.totalFuelConsumed == totalFuelConsumed &&
        other.totalCostSpent == totalCostSpent &&
        other.averageConsumption == averageConsumption;
  }

  @override
  int get hashCode {
    return Object.hash(
      vehicleId,
      totalEntries,
      totalFuelConsumed,
      totalCostSpent,
      averageConsumption,
    );
  }

  @override
  String toString() {
    return 'VehicleStatistics(vehicleId: $vehicleId, totalEntries: $totalEntries, '
           'avgConsumption: $averageConsumption, totalCost: $totalCostSpent)';
  }
}