import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart' show debugPrint;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'units_providers.g.dart';

/// Enum representing unit system options
enum UnitSystem {
  /// Metric system (L/100km, km, Liters)
  metric,
  /// Imperial system (MPG, miles, Gallons)
  imperial,
}

/// Extension to provide display names and unit labels
extension UnitSystemExtension on UnitSystem {
  String get displayName {
    switch (this) {
      case UnitSystem.metric:
        return 'Metric';
      case UnitSystem.imperial:
        return 'Imperial';
    }
  }
  
  String get consumptionUnit {
    switch (this) {
      case UnitSystem.metric:
        return 'L/100km';
      case UnitSystem.imperial:
        return 'MPG';
    }
  }
  
  String get distanceUnit {
    switch (this) {
      case UnitSystem.metric:
        return 'km';
      case UnitSystem.imperial:
        return 'miles';
    }
  }
  
  String get volumeUnit {
    switch (this) {
      case UnitSystem.metric:
        return 'L';
      case UnitSystem.imperial:
        return 'gal';
    }
  }
  
  String get shortDescription {
    switch (this) {
      case UnitSystem.metric:
        return 'L/100km, km, L';
      case UnitSystem.imperial:
        return 'MPG, miles, gal';
    }
  }
}

/// Unit conversion utilities
class UnitConverter {
  /// Convert consumption from metric (L/100km) to imperial (MPG)
  /// Formula: MPG = 235.214583 / (L/100km)
  static double consumptionToImperial(double metricConsumption) {
    if (metricConsumption <= 0) return 0.0;
    return 235.214583 / metricConsumption;
  }
  
  /// Convert consumption from imperial (MPG) to metric (L/100km)
  /// Formula: L/100km = 235.214583 / MPG
  static double consumptionToMetric(double imperialConsumption) {
    if (imperialConsumption <= 0) return 0.0;
    return 235.214583 / imperialConsumption;
  }
  
  /// Convert distance from metric (km) to imperial (miles)
  /// Formula: miles = km * 0.621371
  static double distanceToImperial(double kilometers) {
    return kilometers * 0.621371;
  }
  
  /// Convert distance from imperial (miles) to metric (km)
  /// Formula: km = miles / 0.621371
  static double distanceToMetric(double miles) {
    return miles / 0.621371;
  }
  
  /// Convert volume from metric (liters) to imperial (gallons)
  /// Formula: gallons = liters * 0.264172
  static double volumeToImperial(double liters) {
    return liters * 0.264172;
  }
  
  /// Convert volume from imperial (gallons) to metric (liters)
  /// Formula: liters = gallons / 0.264172
  static double volumeToMetric(double gallons) {
    return gallons / 0.264172;
  }
  
  /// Format consumption value with appropriate precision for the unit system
  static String formatConsumption(double consumption, UnitSystem unitSystem) {
    switch (unitSystem) {
      case UnitSystem.metric:
        return '${consumption.toStringAsFixed(1)} L/100km';
      case UnitSystem.imperial:
        return '${consumption.toStringAsFixed(1)} MPG';
    }
  }
  
  /// Format distance value with appropriate precision for the unit system
  static String formatDistance(double distance, UnitSystem unitSystem) {
    switch (unitSystem) {
      case UnitSystem.metric:
        return '${distance.toStringAsFixed(0)} km';
      case UnitSystem.imperial:
        return '${distance.toStringAsFixed(0)} miles';
    }
  }
  
  /// Format volume value with appropriate precision for the unit system
  static String formatVolume(double volume, UnitSystem unitSystem) {
    switch (unitSystem) {
      case UnitSystem.metric:
        return '${volume.toStringAsFixed(1)} L';
      case UnitSystem.imperial:
        return '${volume.toStringAsFixed(1)} gal';
    }
  }
  
  /// Convert consumption value to the target unit system
  static double convertConsumption(
    double value, 
    UnitSystem from, 
    UnitSystem to,
  ) {
    if (from == to) return value;
    
    switch (from) {
      case UnitSystem.metric:
        return consumptionToImperial(value);
      case UnitSystem.imperial:
        return consumptionToMetric(value);
    }
  }
  
  /// Convert distance value to the target unit system
  static double convertDistance(
    double value, 
    UnitSystem from, 
    UnitSystem to,
  ) {
    if (from == to) return value;
    
    switch (from) {
      case UnitSystem.metric:
        return distanceToImperial(value);
      case UnitSystem.imperial:
        return distanceToMetric(value);
    }
  }
  
  /// Convert volume value to the target unit system
  static double convertVolume(
    double value, 
    UnitSystem from, 
    UnitSystem to,
  ) {
    if (from == to) return value;
    
    switch (from) {
      case UnitSystem.metric:
        return volumeToImperial(value);
      case UnitSystem.imperial:
        return volumeToMetric(value);
    }
  }
}

/// Units persistence service for storing user preferences
class UnitsPersistenceService {
  static const String _fileName = 'units_preferences.json';
  
  /// Get the units preferences file
  static Future<File> _getUnitsFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
  
  /// Load units preference from storage
  static Future<UnitSystem> loadUnitsPreference() async {
    try {
      final file = await _getUnitsFile();
      if (!await file.exists()) {
        return UnitSystem.metric; // Default to metric
      }
      
      final contents = await file.readAsString();
      final data = jsonDecode(contents) as Map<String, dynamic>;
      final unitsString = data['unitSystem'] as String?;
      
      // Convert string back to enum
      switch (unitsString) {
        case 'imperial':
          return UnitSystem.imperial;
        case 'metric':
        default:
          return UnitSystem.metric;
      }
    } catch (e) {
      // If there's any error loading, default to metric
      debugPrint('Error loading units preference: $e');
      return UnitSystem.metric;
    }
  }
  
  /// Save units preference to storage
  static Future<void> saveUnitsPreference(UnitSystem unitSystem) async {
    try {
      final file = await _getUnitsFile();
      final data = {
        'unitSystem': unitSystem.name,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving units preference: $e');
      // Don't throw - failing to save shouldn't crash the app
    }
  }
}

/// Provider for the current unit system
@riverpod
class Units extends _$Units {
  @override
  Future<UnitSystem> build() async {
    // Load saved units preference on initialization
    return await UnitsPersistenceService.loadUnitsPreference();
  }
  
  /// Change the unit system and persist it
  Future<void> setUnitSystem(UnitSystem newUnitSystem) async {
    // Update the state immediately for UI responsiveness
    state = AsyncValue.data(newUnitSystem);
    
    // Persist the change
    await UnitsPersistenceService.saveUnitsPreference(newUnitSystem);
  }
  
  /// Get the current unit system synchronously (for UI)
  UnitSystem get currentUnitSystem {
    return state.value ?? UnitSystem.metric;
  }
}

/// Provider that returns formatted consumption with current units
@riverpod
String formattedConsumption(Ref ref, double consumption) {
  final unitSystem = ref.watch(unitsProvider);
  return unitSystem.when(
    data: (units) {
      final convertedConsumption = units == UnitSystem.metric 
          ? consumption 
          : UnitConverter.consumptionToImperial(consumption);
      return UnitConverter.formatConsumption(convertedConsumption, units);
    },
    loading: () => '${consumption.toStringAsFixed(1)} L/100km',
    error: (_, __) => '${consumption.toStringAsFixed(1)} L/100km',
  );
}

/// Provider that returns formatted distance with current units
@riverpod
String formattedDistance(Ref ref, double distance) {
  final unitSystem = ref.watch(unitsProvider);
  return unitSystem.when(
    data: (units) {
      final convertedDistance = units == UnitSystem.metric 
          ? distance 
          : UnitConverter.distanceToImperial(distance);
      return UnitConverter.formatDistance(convertedDistance, units);
    },
    loading: () => '${distance.toStringAsFixed(0)} km',
    error: (_, __) => '${distance.toStringAsFixed(0)} km',
  );
}

/// Provider that returns formatted volume with current units
@riverpod
String formattedVolume(Ref ref, double volume) {
  final unitSystem = ref.watch(unitsProvider);
  return unitSystem.when(
    data: (units) {
      final convertedVolume = units == UnitSystem.metric 
          ? volume 
          : UnitConverter.volumeToImperial(volume);
      return UnitConverter.formatVolume(convertedVolume, units);
    },
    loading: () => '${volume.toStringAsFixed(1)} L',
    error: (_, __) => '${volume.toStringAsFixed(1)} L',
  );
}

/// Provider that returns consumption value in the current unit system
@riverpod
double consumptionInCurrentUnits(Ref ref, double metricConsumption) {
  final unitSystem = ref.watch(unitsProvider);
  return unitSystem.when(
    data: (units) {
      return units == UnitSystem.metric 
          ? metricConsumption 
          : UnitConverter.consumptionToImperial(metricConsumption);
    },
    loading: () => metricConsumption,
    error: (_, __) => metricConsumption,
  );
}

/// Provider that returns distance value in the current unit system
@riverpod
double distanceInCurrentUnits(Ref ref, double kilometers) {
  final unitSystem = ref.watch(unitsProvider);
  return unitSystem.when(
    data: (units) {
      return units == UnitSystem.metric 
          ? kilometers 
          : UnitConverter.distanceToImperial(kilometers);
    },
    loading: () => kilometers,
    error: (_, __) => kilometers,
  );
}

/// Provider that returns volume value in the current unit system
@riverpod
double volumeInCurrentUnits(Ref ref, double liters) {
  final unitSystem = ref.watch(unitsProvider);
  return unitSystem.when(
    data: (units) {
      return units == UnitSystem.metric 
          ? liters 
          : UnitConverter.volumeToImperial(liters);
    },
    loading: () => liters,
    error: (_, __) => liters,
  );
}