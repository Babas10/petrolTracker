import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';

/// Web-compatible data injector for testing
/// Shows a floating action button that opens a data injection dialog
class WebDataInjector extends ConsumerWidget {
  final Widget child;

  const WebDataInjector({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only show on web and in debug mode
    if (!kIsWeb || !kDebugMode) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned(
          bottom: 80,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => _showDataInjectionDialog(context, ref),
            backgroundColor: Colors.orange,
            child: const Icon(Icons.api),
            heroTag: "dataInjector",
          ),
        ),
      ],
    );
  }

  void _showDataInjectionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => DataInjectionDialog(ref: ref),
    );
  }
}

class DataInjectionDialog extends StatefulWidget {
  final WidgetRef ref;

  const DataInjectionDialog({
    super.key,
    required this.ref,
  });

  @override
  State<DataInjectionDialog> createState() => _DataInjectionDialogState();
}

class _DataInjectionDialogState extends State<DataInjectionDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.api, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Web Data Injector',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Quick test data injection for web development',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.green[700], size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Toyota Hilux 2013 data auto-loads on startup',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick actions
            _buildQuickAction(
              context,
              'Create Test Vehicle',
              'Adds a single test vehicle',
              Icons.directions_car,
              () => _createTestVehicle(),
            ),
            const SizedBox(height: 12),
            
            _buildQuickAction(
              context,
              'Create Vehicle + 5 Fuel Entries',
              'Perfect for testing charts',
              Icons.show_chart,
              () => _createVehicleWithEntries(),
            ),
            const SizedBox(height: 12),
            
            _buildQuickAction(
              context,
              'Create Toyota Hilux 2013',
              'Real-world dataset with 11 fuel entries',
              Icons.local_gas_station,
              () => _createToyotaHiluxDataset(),
            ),
            const SizedBox(height: 12),
            
            _buildQuickAction(
              context,
              'Create Large Dataset',
              'Vehicle + 20 entries for stress testing',
              Icons.dataset,
              () => _createLargeDataset(),
            ),
            const SizedBox(height: 12),
            
            _buildQuickAction(
              context,
              'Create Mixed Refuel Test Vehicle',
              'Perfect for testing full/partial consumption periods',
              Icons.scatter_plot,
              () => _createMixedRefuelTestVehicle(),
            ),
            const SizedBox(height: 12),
            
            _buildQuickAction(
              context,
              'Clear All Data',
              'Reset to empty state',
              Icons.delete_sweep,
              () => _clearAllData(),
              isDestructive: true,
            ),
            
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'For full REST API access, run: flutter run -d macos',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDestructive ? Colors.red[300]! : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red[600] : Colors.blue[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: isDestructive ? Colors.red[700] : null,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createTestVehicle() async {
    try {
      final vehicle = VehicleModel.create(
        name: 'Test Vehicle ${DateTime.now().millisecondsSinceEpoch % 1000}',
        initialKm: 50000.0,
      );

      await widget.ref.read(vehiclesNotifierProvider.notifier).addVehicle(vehicle);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Test vehicle created!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createVehicleWithEntries() async {
    try {
      // Create vehicle
      final vehicle = VehicleModel.create(
        name: 'Chart Test Vehicle',
        initialKm: 50000.0,
      );

      final createdVehicle = await widget.ref.read(vehiclesNotifierProvider.notifier).addVehicle(vehicle);
      
      // Create 5 fuel entries
      final baseDate = DateTime.now().subtract(const Duration(days: 35));
      final fuelNotifier = widget.ref.read(fuelEntriesNotifierProvider.notifier);
      
      for (int i = 0; i < 5; i++) {
        final entry = FuelEntryModel.create(
          vehicleId: createdVehicle.id!,
          date: baseDate.add(Duration(days: i * 7)),
          currentKm: 50000.0 + (i * 400.0),
          fuelAmount: 40.0 + (i * 2.0),
          price: 58.0 + (i * 1.5),
          country: 'Canada',
          pricePerLiter: 1.45,
          consumption: i == 0 ? null : 10.0 + (i * 0.5), // First entry has no consumption
          isFullTank: i == 0 ? true : (i % 3 != 1), // First entry must be full tank, then mix
        );
        
        await fuelNotifier.addFuelEntry(entry);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Vehicle + 5 fuel entries created! Perfect for chart testing.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createToyotaHiluxDataset() async {
    try {
      // Create Toyota Hilux 2013
      final vehicle = VehicleModel.create(
        name: 'Toyota Hilux 2013',
        initialKm: 98510.0,
      );

      final createdVehicle = await widget.ref.read(vehiclesNotifierProvider.notifier).addVehicle(vehicle);
      
      // Real fuel entries data (converted from gallons to liters)
      final fuelNotifier = widget.ref.read(fuelEntriesNotifierProvider.notifier);
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
          isFullTank: i == 0 ? true : (i % 4 != 2), // First must be full, then realistic mix
        );
        
        await fuelNotifier.addFuelEntry(entry);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Toyota Hilux 2013 created! (Real data: 11 entries, 4,450 km)'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  double _calculateConsumption(double previousKm, double currentKm, double fuelAmount) {
    final distance = currentKm - previousKm;
    if (distance <= 0) return 0.0;
    return (fuelAmount / distance) * 100; // L/100km
  }

  Future<void> _createLargeDataset() async {
    try {
      // Create vehicle
      final vehicle = VehicleModel.create(
        name: 'Stress Test Vehicle',
        initialKm: 40000.0,
      );

      final createdVehicle = await widget.ref.read(vehiclesNotifierProvider.notifier).addVehicle(vehicle);
      
      // Create 20 fuel entries over 6 months
      final baseDate = DateTime.now().subtract(const Duration(days: 180));
      final fuelNotifier = widget.ref.read(fuelEntriesNotifierProvider.notifier);
      
      for (int i = 0; i < 20; i++) {
        final entry = FuelEntryModel.create(
          vehicleId: createdVehicle.id!,
          date: baseDate.add(Duration(days: i * 9)),
          currentKm: 40000.0 + (i * 350.0),
          fuelAmount: 35.0 + (i % 10),
          price: 50.0 + (i * 1.2),
          country: i % 3 == 0 ? 'USA' : 'Canada',
          pricePerLiter: 1.40 + (i * 0.02),
          consumption: i == 0 ? null : 8.5 + (i % 5),
          isFullTank: i == 0 ? true : (i % 5 != 2), // First must be full, then varied mix
        );
        
        await fuelNotifier.addFuelEntry(entry);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Large dataset created! (1 vehicle + 20 entries)'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text('Are you sure you want to delete all vehicles and fuel entries? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete All'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Clear fuel entries first (foreign key constraints)
      await widget.ref.read(fuelEntriesNotifierProvider.notifier).clearAllEntries();
      
      // Clear vehicles
      await widget.ref.read(vehiclesNotifierProvider.notifier).clearAllVehicles();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ All data cleared!'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createMixedRefuelTestVehicle() async {
    try {
      // Create vehicle for mixed refuel testing
      final vehicle = VehicleModel.create(
        name: 'Mixed Refuel Test Vehicle',
        initialKm: 75000.0,
      );

      final createdVehicle = await widget.ref.read(vehiclesNotifierProvider.notifier).addVehicle(vehicle);
      
      // Create entries that demonstrate consumption periods clearly
      final baseDate = DateTime.now().subtract(const Duration(days: 50));
      final fuelNotifier = widget.ref.read(fuelEntriesNotifierProvider.notifier);
      
      // Define a clear pattern for testing:
      // Period 1: Full -> Partial -> Partial -> Full (3 entries, consumption calculated)
      // Period 2: Full -> Partial -> Full (2 entries, consumption calculated)  
      // Period 3: Full -> Partial (incomplete, no consumption yet)
      
      final entries = [
        // Entry 1: Start with full tank (required)
        {
          'days': 0,
          'km': 75000.0,
          'fuel': 45.0,
          'price': 65.25,
          'full': true,
          'note': 'Start - Full Tank'
        },
        // Entry 2: Partial refuel
        {
          'days': 5,
          'km': 75280.0,
          'fuel': 20.0,
          'price': 29.00,
          'full': false,
          'note': 'Partial refuel'
        },
        // Entry 3: Another partial refuel
        {
          'days': 10,
          'km': 75520.0,
          'fuel': 25.0,
          'price': 36.25,
          'full': false,
          'note': 'Another partial'
        },
        // Entry 4: Full tank (completes Period 1: 520km with 90L total)
        {
          'days': 15,
          'km': 75520.0,
          'fuel': 35.0,
          'price': 50.75,
          'full': true,
          'note': 'Full tank - completes period 1'
        },
        // Entry 5: Partial refuel (starts Period 2)
        {
          'days': 20,
          'km': 75800.0,
          'fuel': 22.0,
          'price': 31.90,
          'full': false,
          'note': 'Start period 2 - partial'
        },
        // Entry 6: Full tank (completes Period 2: 280km with 57L total)
        {
          'days': 25,
          'km': 75800.0,
          'fuel': 35.0,
          'price': 50.75,
          'full': true,
          'note': 'Full tank - completes period 2'
        },
        // Entry 7: Partial refuel (starts Period 3 - incomplete)
        {
          'days': 30,
          'km': 76050.0,
          'fuel': 18.0,
          'price': 26.10,
          'full': false,
          'note': 'Partial - incomplete period'
        },
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
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Mixed Refuel Test Vehicle created!\n• 2 complete consumption periods\n• 1 incomplete period\nPerfect for testing the new consumption logic!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}