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
      final vehicleState = await ref.read(vehiclesProvider.future);
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

      print('🚗 Auto-populating comprehensive test data with 5 diverse vehicles...');
      
      await _createHondaCivic(ref);
      await _createToyotaHilux(ref);
      await _createToyotaPrius(ref);
      await _createMixedRefuelTestVehicle(ref); // New mixed refuel test vehicle
      await _createTeslaModel3(ref); // New vehicle for year-spanning test
      
      print('✅ Auto-populated 5 vehicles with mixed refuel types for comprehensive testing');
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

    final createdVehicle = await ref.read(vehiclesProvider.notifier).addVehicle(vehicle);
    final fuelNotifier = ref.read(fuelEntriesProvider.notifier);
    
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

    final createdVehicle = await ref.read(vehiclesProvider.notifier).addVehicle(vehicle);
    final fuelNotifier = ref.read(fuelEntriesProvider.notifier);
    
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

  /// Create Mixed Refuel Test Vehicle - Perfect for testing full/partial consumption periods
  static Future<void> _createMixedRefuelTestVehicle(Ref ref) async {
    final vehicle = VehicleModel.create(
      name: 'Mixed Refuel Test Vehicle',
      initialKm: 75000.0,
    );

    final createdVehicle = await ref.read(vehiclesProvider.notifier).addVehicle(vehicle);
    final fuelNotifier = ref.read(fuelEntriesProvider.notifier);
    
    // Create entries that demonstrate consumption periods clearly
    final baseDate = DateTime.now().subtract(const Duration(days: 50));
    
    // Enhanced pattern for richer testing - spans 6 months with 8 complete periods
    // Each period demonstrates different consumption scenarios across seasons
    
    final entries = [
      // Period 1: Full -> Partial -> Full (city driving, winter)
      {'days': -180, 'km': 75000.0, 'fuel': 55.0, 'price': 79.75, 'full': true, 'type': 'Full'},
      {'days': -175, 'km': 75180.0, 'fuel': 25.0, 'price': 36.25, 'full': false, 'type': 'Partial'},
      {'days': -170, 'km': 75380.0, 'fuel': 40.0, 'price': 58.00, 'full': true, 'type': 'Full'},
      
      // Period 2: Full -> Full (highway driving, winter)
      {'days': -160, 'km': 75780.0, 'fuel': 48.0, 'price': 69.60, 'full': true, 'type': 'Full'},
      
      // Period 3: Full -> Partial -> Partial -> Full (mixed driving, late winter)
      {'days': -145, 'km': 76200.0, 'fuel': 52.0, 'price': 75.40, 'full': true, 'type': 'Full'},
      {'days': -135, 'km': 76450.0, 'fuel': 30.0, 'price': 43.50, 'full': false, 'type': 'Partial'},
      {'days': -125, 'km': 76680.0, 'fuel': 28.0, 'price': 40.60, 'full': false, 'type': 'Partial'},
      {'days': -115, 'km': 76920.0, 'fuel': 42.0, 'price': 60.90, 'full': true, 'type': 'Full'},
      
      // Period 4: Full -> Partial -> Full (spring efficiency improvement)
      {'days': -100, 'km': 77350.0, 'fuel': 45.0, 'price': 65.25, 'full': true, 'type': 'Full'},
      {'days': -85, 'km': 77650.0, 'fuel': 22.0, 'price': 31.90, 'full': false, 'type': 'Partial'},
      {'days': -70, 'km': 77980.0, 'fuel': 38.0, 'price': 55.10, 'full': true, 'type': 'Full'},
      
      // Period 5: Full -> Full (summer efficiency, best consumption)
      {'days': -55, 'km': 78420.0, 'fuel': 40.0, 'price': 58.00, 'full': true, 'type': 'Full'},
      
      // Period 6: Full -> Partial -> Full (summer, AC usage)
      {'days': -40, 'km': 78800.0, 'fuel': 42.0, 'price': 60.90, 'full': true, 'type': 'Full'},
      {'days': -30, 'km': 79120.0, 'fuel': 24.0, 'price': 34.80, 'full': false, 'type': 'Partial'},
      {'days': -20, 'km': 79450.0, 'fuel': 36.0, 'price': 52.20, 'full': true, 'type': 'Full'},
      
      // Period 7: Full -> Partial -> Partial -> Full (fall, moderate consumption)
      {'days': -10, 'km': 79850.0, 'fuel': 44.0, 'price': 63.80, 'full': true, 'type': 'Full'},
      {'days': -5, 'km': 80100.0, 'fuel': 20.0, 'price': 29.00, 'full': false, 'type': 'Partial'},
      {'days': 0, 'km': 80350.0, 'fuel': 25.0, 'price': 36.25, 'full': false, 'type': 'Partial'},
      {'days': 5, 'km': 80600.0, 'fuel': 35.0, 'price': 50.75, 'full': true, 'type': 'Full'},
      
      // Period 8: Full -> Full (recent, efficient driving)
      {'days': 15, 'km': 81020.0, 'fuel': 38.0, 'price': 55.10, 'full': true, 'type': 'Full'},
      
      // Incomplete Period 9: Full -> Partial (current, ongoing)
      {'days': 25, 'km': 81350.0, 'fuel': 18.0, 'price': 26.10, 'full': false, 'type': 'Partial'},
    ];
    
    for (int i = 0; i < entries.length; i++) {
      final data = entries[i];
      final pricePerLiter = (data['price'] as double) / (data['fuel'] as double);
      
      final entry = FuelEntryModel.create(
        vehicleId: createdVehicle.id!,
        date: baseDate.add(Duration(days: data['days'] as int)),
        currentKm: data['km'] as double,
        fuelAmount: data['fuel'] as double,
        price: data['price'] as double,
        country: 'Canada',
        pricePerLiter: pricePerLiter,
        consumption: null, // Will be calculated by periods
        isFullTank: data['full'] as bool,
      );
      
      await fuelNotifier.addFuelEntry(entry);
      print('Created ${data['type']} refuel entry: ${data['fuel']}L at ${data['km']} km');
    }
    
    print('✅ Created Mixed Refuel Test Vehicle with 8 complete periods + 1 incomplete (spans 6 months)');
  }

  /// Create Toyota Prius 2021 - Hybrid with very high efficiency
  static Future<void> _createToyotaPrius(Ref ref) async {
    final vehicle = VehicleModel.create(
      name: 'Toyota Prius 2021',
      initialKm: 18750.0,
    );

    final createdVehicle = await ref.read(vehiclesProvider.notifier).addVehicle(vehicle);
    final fuelNotifier = ref.read(fuelEntriesProvider.notifier);
    
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


  /// Create Tesla Model 3 2023 - Electric vehicle with year-spanning data for testing
  static Future<void> _createTeslaModel3(Ref ref) async {
    final vehicle = VehicleModel.create(
      name: 'Tesla Model 3 2023',
      initialKm: 25680.0,
    );

    final createdVehicle = await ref.read(vehiclesProvider.notifier).addVehicle(vehicle);
    final fuelNotifier = ref.read(fuelEntriesProvider.notifier);
    
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
        isFullTank: true, // Tesla Model 3 - all entries are "full charges"
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
        isFullTank: i == 0 ? true : (i % 4 != 2), // First must be full, then realistic mix (75% full, 25% partial)
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