import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';

/// Comprehensive auto-population service for web development
/// Creates multiple diverse vehicles with extensive fuel entry data for thorough testing
class WebAutoPopulation {
  static const bool _enableAutoPopulation = true; // Set to false to disable
  static final Random _random = Random(42); // Fixed seed for consistent data

  /// Auto-populate comprehensive test data on startup (web and mobile in debug mode)
  static Future<void> autoPopulateIfNeeded(Ref ref) async {
    // Run on any platform in debug mode (web, iOS, Android)
    if (!kDebugMode || !_enableAutoPopulation) {
      return;
    }

    try {
      // Check if data already exists
      final vehicleState = await ref.read(vehiclesNotifierProvider.future);
      if (vehicleState.vehicles.isNotEmpty) {
        // Check if Tesla Model 3 already exists
        final hasTestla = vehicleState.vehicles.any((v) => v.name.contains('Tesla Model 3'));
        if (!hasTestla) {
          print('🚗 Adding Tesla Model 3 for year-spanning test...');
          await _createTeslaModel3(ref);
          print('✅ Added Tesla Model 3 with year-spanning entries');
        }
        return; // Data already exists, don't auto-populate other vehicles
      }

      print('🚗 Auto-populating comprehensive test data with 6 diverse vehicles...');
      
      await _createHondaCivic(ref);
      await _createToyotaHilux(ref);
      await _createBMW320i(ref);
      await _createToyotaPrius(ref);
      await _createMazdaMX5(ref);
      await _createTeslaModel3(ref); // New vehicle for year-spanning test
      
      print('✅ Auto-populated 6 vehicles with 150+ comprehensive fuel entries');
    } catch (e) {
      print('❌ Failed to auto-populate data: $e');
    }
  }

  /// Create Honda Civic 2020 - Compact car with high efficiency
  static Future<void> _createHondaCivic(Ref ref) async {
    final vehicle = VehicleModel.create(
      name: 'Honda Civic 2020',
      initialKm: 45200.0,
    );

    final createdVehicle = await ref.read(vehiclesNotifierProvider.notifier).addVehicle(vehicle);
    final fuelNotifier = ref.read(fuelEntriesNotifierProvider.notifier);
    
    // Generate 25 entries over 14 months with 6.5-7.5 L/100km consumption
    await _generateFuelEntries(
      fuelNotifier,
      createdVehicle.id!,
      vehicle.initialKm,
      vehicleName: 'Honda Civic',
      entryCount: 25,
      monthsSpan: 14,
      baseConsumption: 7.0,
      consumptionVariance: 0.5,
      tankSize: 50.0,
      countries: ['Canada', 'USA'],
      currencies: ['CAD', 'USD'],
      basePrices: [1.55, 1.20], // CAD, USD per liter
    );
  }

  /// Create Toyota Hilux 2013 - SUV/Truck with higher consumption (enhanced from original)
  static Future<void> _createToyotaHilux(Ref ref) async {
    final vehicle = VehicleModel.create(
      name: 'Toyota Hilux 2013',
      initialKm: 98510.0,
    );

    final createdVehicle = await ref.read(vehiclesNotifierProvider.notifier).addVehicle(vehicle);
    final fuelNotifier = ref.read(fuelEntriesNotifierProvider.notifier);
    
    // Generate 30 entries over 18 months with 11-14 L/100km consumption
    await _generateFuelEntries(
      fuelNotifier,
      createdVehicle.id!,
      vehicle.initialKm,
      vehicleName: 'Toyota Hilux',
      entryCount: 30,
      monthsSpan: 18,
      baseConsumption: 12.5,
      consumptionVariance: 1.5,
      tankSize: 80.0,
      countries: ['Canada', 'Australia', 'Germany'],
      currencies: ['CAD', 'AUD', 'EUR'],
      basePrices: [1.60, 1.75, 1.65], // CAD, AUD, EUR per liter
    );
  }

  /// Create BMW 320i 2019 - Luxury sedan with moderate consumption
  static Future<void> _createBMW320i(Ref ref) async {
    final vehicle = VehicleModel.create(
      name: 'BMW 320i 2019',
      initialKm: 32850.0,
    );

    final createdVehicle = await ref.read(vehiclesNotifierProvider.notifier).addVehicle(vehicle);
    final fuelNotifier = ref.read(fuelEntriesNotifierProvider.notifier);
    
    // Generate 22 entries over 13 months with 8.5-11 L/100km consumption
    await _generateFuelEntries(
      fuelNotifier,
      createdVehicle.id!,
      vehicle.initialKm,
      vehicleName: 'BMW 320i',
      entryCount: 22,
      monthsSpan: 13,
      baseConsumption: 9.75,
      consumptionVariance: 1.25,
      tankSize: 60.0,
      countries: ['Germany', 'France', 'USA'],
      currencies: ['EUR', 'EUR', 'USD'],
      basePrices: [1.70, 1.68, 1.15], // EUR, EUR, USD per liter
    );
  }

  /// Create Toyota Prius 2021 - Hybrid with very high efficiency
  static Future<void> _createToyotaPrius(Ref ref) async {
    final vehicle = VehicleModel.create(
      name: 'Toyota Prius 2021',
      initialKm: 18750.0,
    );

    final createdVehicle = await ref.read(vehiclesNotifierProvider.notifier).addVehicle(vehicle);
    final fuelNotifier = ref.read(fuelEntriesNotifierProvider.notifier);
    
    // Generate 28 entries over 16 months with 4.2-5.8 L/100km consumption
    await _generateFuelEntries(
      fuelNotifier,
      createdVehicle.id!,
      vehicle.initialKm,
      vehicleName: 'Toyota Prius',
      entryCount: 28,
      monthsSpan: 16,
      baseConsumption: 5.0,
      consumptionVariance: 0.8,
      tankSize: 45.0,
      countries: ['Japan', 'Canada', 'USA'],
      currencies: ['JPY', 'CAD', 'USD'],
      basePrices: [170.0, 1.58, 1.18], // JPY, CAD, USD (JPY per liter is much higher)
      currencyMultipliers: [1.0, 1.0, 1.0], // Adjust for JPY
    );
  }

  /// Create Mazda MX-5 2018 - Sports car with variable consumption
  static Future<void> _createMazdaMX5(Ref ref) async {
    final vehicle = VehicleModel.create(
      name: 'Mazda MX-5 2018',
      initialKm: 67420.0,
    );

    final createdVehicle = await ref.read(vehiclesNotifierProvider.notifier).addVehicle(vehicle);
    final fuelNotifier = ref.read(fuelEntriesNotifierProvider.notifier);
    
    // Generate 24 entries over 15 months with 8-16 L/100km consumption (highly variable)
    await _generateFuelEntries(
      fuelNotifier,
      createdVehicle.id!,
      vehicle.initialKm,
      vehicleName: 'Mazda MX-5',
      entryCount: 24,
      monthsSpan: 15,
      baseConsumption: 12.0,
      consumptionVariance: 4.0, // High variance for sports car (city vs highway)
      tankSize: 45.0,
      countries: ['Australia', 'Japan', 'Canada'],
      currencies: ['AUD', 'JPY', 'CAD'],
      basePrices: [1.80, 165.0, 1.62], // AUD, JPY, CAD per liter
    );
  }

  /// Create Tesla Model 3 2023 - Electric vehicle with year-spanning data for testing
  static Future<void> _createTeslaModel3(Ref ref) async {
    final vehicle = VehicleModel.create(
      name: 'Tesla Model 3 2023',
      initialKm: 25680.0,
    );

    final createdVehicle = await ref.read(vehiclesNotifierProvider.notifier).addVehicle(vehicle);
    final fuelNotifier = ref.read(fuelEntriesNotifierProvider.notifier);
    
    // Generate entries spanning from October 2024 to March 2025 for year transition testing
    await _generateYearSpanningEntries(
      fuelNotifier,
      createdVehicle.id!,
      vehicle.initialKm,
      vehicleName: 'Tesla Model 3',
    );
  }

  /// Generate fuel entries specifically designed to span across years
  static Future<void> _generateYearSpanningEntries(
    FuelEntriesNotifier fuelNotifier,
    int vehicleId,
    double initialKm, {
    required String vehicleName,
  }) async {
    // Create entries from October 2024 to March 2025
    final months = [
      {'year': 2024, 'month': 10, 'name': 'Oct'},  // 2024 months
      {'year': 2024, 'month': 11, 'name': 'Nov'},
      {'year': 2024, 'month': 12, 'name': 'Dec'},
      {'year': 2025, 'month': 1, 'name': 'Jan'},   // 2025 months
      {'year': 2025, 'month': 2, 'name': 'Feb'},
      {'year': 2025, 'month': 3, 'name': 'Mar'},
    ];
    
    double currentKm = initialKm;
    double? previousKm;
    
    for (int i = 0; i < months.length; i++) {
      final monthData = months[i];
      
      // Create entry for mid-month
      final entryDate = DateTime(monthData['year'] as int, monthData['month'] as int, 15);
      
      // Tesla-like efficiency (very low consumption equivalent)
      final baseConsumption = 2.5; // kWh/100km equivalent to L/100km for comparison
      final consumption = baseConsumption + (_random.nextDouble() * 1.0 - 0.5); // 2.0-3.0 range
      
      // Calculate realistic distance and "fuel" amount (electricity cost)
      final distance = 350 + _random.nextDouble() * 200; // 350-550 km per month
      currentKm += distance;
      
      final fuelAmount = (consumption / 100) * distance; // Equivalent energy in kWh
      
      // Electric charging costs (per kWh equivalent)
      final pricePerLiter = 0.25 + _random.nextDouble() * 0.15; // $0.25-$0.40 per kWh
      final totalPrice = fuelAmount * pricePerLiter;
      
      // Calculate actual consumption (null for first entry)
      double? actualConsumption;
      if (previousKm != null) {
        actualConsumption = _calculateConsumption(previousKm, currentKm, fuelAmount);
      }
      
      final entry = FuelEntryModel.create(
        vehicleId: vehicleId,
        date: entryDate,
        currentKm: currentKm,
        fuelAmount: fuelAmount,
        price: totalPrice,
        country: 'Canada',
        pricePerLiter: pricePerLiter,
        consumption: actualConsumption,
      );
      
      await fuelNotifier.addFuelEntry(entry);
      previousKm = currentKm;
      
      print('Created ${monthData['name']} ${monthData['year']} entry for Tesla Model 3');
    }
    
    print('✅ Created $vehicleName with ${months.length} entries spanning 2024-2025');
  }

  /// Generate comprehensive fuel entries for a vehicle
  static Future<void> _generateFuelEntries(
    FuelEntriesNotifier fuelNotifier,
    int vehicleId,
    double initialKm, {
    required String vehicleName,
    required int entryCount,
    required int monthsSpan,
    required double baseConsumption,
    required double consumptionVariance,
    required double tankSize,
    required List<String> countries,
    required List<String> currencies,
    required List<double> basePrices,
    List<double>? currencyMultipliers,
  }) async {
    final baseDate = DateTime.now().subtract(Duration(days: monthsSpan * 30));
    double currentKm = initialKm;
    double? previousKm;
    
    for (int i = 0; i < entryCount; i++) {
      // Calculate date with some randomness but roughly distributed over time span
      final dayOffset = (monthsSpan * 30 * i / entryCount).round() + 
                       _random.nextInt(10) - 5; // ±5 days randomness
      final entryDate = baseDate.add(Duration(days: dayOffset));
      
      // Add seasonal variation (higher consumption in winter)
      final seasonalMultiplier = _getSeasonalMultiplier(entryDate);
      final targetConsumption = (baseConsumption + 
                                _random.nextDouble() * consumptionVariance * 2 - consumptionVariance) *
                               seasonalMultiplier;
      
      // Calculate realistic distance based on consumption and fuel amount
      final fuelAmount = (tankSize * 0.4) + (_random.nextDouble() * tankSize * 0.5); // 40-90% tank
      final distance = (fuelAmount / targetConsumption) * 100; // Convert from L/100km
      
      currentKm += distance + _random.nextDouble() * 50; // Add some randomness
      
      // Select country and corresponding price
      final countryIndex = _random.nextInt(countries.length);
      final country = countries[countryIndex];
      final currency = currencies[countryIndex];
      final basePrice = basePrices[countryIndex];
      
      // Add price volatility (±15%)
      final priceMultiplier = 0.85 + _random.nextDouble() * 0.3;
      final pricePerLiter = basePrice * priceMultiplier;
      final totalPrice = fuelAmount * pricePerLiter;
      
      // Calculate actual consumption (null for first entry)
      double? consumption;
      if (previousKm != null) {
        consumption = _calculateConsumption(previousKm, currentKm, fuelAmount);
      }
      
      final entry = FuelEntryModel.create(
        vehicleId: vehicleId,
        date: entryDate,
        currentKm: currentKm,
        fuelAmount: fuelAmount,
        price: totalPrice,
        country: country,
        pricePerLiter: pricePerLiter,
        consumption: consumption,
      );
      
      await fuelNotifier.addFuelEntry(entry);
      previousKm = currentKm;
    }
    
    print('✅ Created $vehicleName with $entryCount entries across ${countries.join(", ")}');
  }

  /// Calculate seasonal consumption multiplier (higher in winter)
  static double _getSeasonalMultiplier(DateTime date) {
    final month = date.month;
    // Winter months (Dec, Jan, Feb) have higher consumption
    // Summer months (Jun, Jul, Aug) have lower consumption
    switch (month) {
      case 12: case 1: case 2: return 1.15; // Winter +15%
      case 3: case 11: return 1.08; // Late fall/early spring +8%
      case 4: case 10: return 1.02; // Spring/fall +2%
      case 6: case 7: case 8: return 0.95; // Summer -5%
      default: return 1.0; // Normal
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