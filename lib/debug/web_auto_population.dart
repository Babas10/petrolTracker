import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';

/// Auto-population service for web development
/// Automatically loads Toyota Hilux 2013 data when app starts on web platform
class WebAutoPopulation {
  static const bool _enableAutoPopulation = true; // Set to false to disable

  /// Auto-populate data on web platform startup
  static Future<void> autoPopulateIfNeeded(Ref ref) async {
    // Only run on web platform in debug mode
    if (!kIsWeb || !kDebugMode || !_enableAutoPopulation) {
      return;
    }

    try {
      // Check if data already exists
      final vehicleState = await ref.read(vehiclesNotifierProvider.future);
      if (vehicleState.vehicles.isNotEmpty) {
        return; // Data already exists, don't auto-populate
      }

      print('🚗 Auto-populating Toyota Hilux 2013 data for web development...');
      
      // Create Toyota Hilux 2013
      final vehicle = VehicleModel.create(
        name: 'Toyota Hilux 2013',
        initialKm: 98510.0,
      );

      final createdVehicle = await ref.read(vehiclesNotifierProvider.notifier).addVehicle(vehicle);
      
      // Real fuel entries data (converted from gallons to liters)
      final fuelNotifier = ref.read(fuelEntriesNotifierProvider.notifier);
      final baseDate = DateTime(2024, 1, 1);
      
      final fuelData = <Map<String, double>>[
        {'km': 98510.0, 'liters': 30.5, 'price': 25.46, 'date': 0},   // 8.06 gal
        {'km': 99080.0, 'liters': 25.4, 'price': 25.46, 'date': 7},   // 6.7 gal
        {'km': 99303.0, 'liters': 21.6, 'price': 20.00, 'date': 14},  // 5.7 gal
        {'km': 99600.0, 'liters': 37.9, 'price': 33.00, 'date': 21},  // 10 gal
        {'km': 100106.0, 'liters': 43.9, 'price': 37.00, 'date': 28}, // 11.6 gal
        {'km': 100422.0, 'liters': 41.5, 'price': 38.37, 'date': 35}, // 10.96 gal
        {'km': 100800.0, 'liters': 41.6, 'price': 34.00, 'date': 42}, // 11 gal
        {'km': 101379.0, 'liters': 57.2, 'price': 54.90, 'date': 49}, // 15.1 gal
        {'km': 101921.0, 'liters': 13.2, 'price': 15.86, 'date': 56}, // 3.5 gal
        {'km': 102405.0, 'liters': 71.2, 'price': 72.64, 'date': 63}, // 18.8 gal
        {'km': 102960.0, 'liters': 55.6, 'price': 54.31, 'date': 70}, // 14.68 gal
      ];
      
      for (int i = 0; i < fuelData.length; i++) {
        final data = fuelData[i];
        final pricePerLiter = data['price']! / data['liters']!;
        
        final entry = FuelEntryModel.create(
          vehicleId: createdVehicle.id!,
          date: baseDate.add(Duration(days: data['date']!.toInt())),
          currentKm: data['km']!,
          fuelAmount: data['liters']!,
          price: data['price']!,
          country: 'USA',
          pricePerLiter: pricePerLiter,
          consumption: i == 0 ? null : _calculateConsumption(
            i > 0 ? fuelData[i-1]['km']! : vehicle.initialKm,
            data['km']!,
            data['liters']!,
          ),
        );
        
        await fuelNotifier.addFuelEntry(entry);
      }
      
      print('✅ Auto-populated Toyota Hilux 2013 with 11 fuel entries');
    } catch (e) {
      print('❌ Failed to auto-populate data: $e');
    }
  }

  static double _calculateConsumption(double previousKm, double currentKm, double fuelAmount) {
    final distance = currentKm - previousKm;
    if (distance <= 0) return 0.0;
    return (fuelAmount / distance) * 100; // L/100km
  }
}

/// Provider for auto-population trigger
/// This ensures auto-population happens when the app starts
final webAutoPopulationProvider = FutureProvider<void>((ref) async {
  await WebAutoPopulation.autoPopulateIfNeeded(ref);
});