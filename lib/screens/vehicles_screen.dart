import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petrol_tracker/navigation/main_layout.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';

/// Vehicles screen for managing user's vehicles
/// 
/// This screen provides:
/// - List of registered vehicles
/// - Add new vehicle functionality
/// - Edit/delete vehicle options
/// - Vehicle statistics
class VehiclesScreen extends ConsumerStatefulWidget {
  const VehiclesScreen({super.key});

  @override
  ConsumerState<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends ConsumerState<VehiclesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavAppBar(
        title: 'Vehicles',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddVehicleDialog,
          ),
        ],
      ),
      body: const Column(
        children: [
          _VehicleStats(),
          Expanded(child: _VehiclesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVehicleDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddVehicleDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddVehicleDialog(ref: ref),
    );
  }
}

/// Vehicle statistics summary
class _VehicleStats extends ConsumerWidget {
  const _VehicleStats();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleCountAsync = ref.watch(vehicleCountProvider);
    final allFuelEntriesAsync = ref.watch(fuelEntriesNotifierProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.directions_car,
              title: 'Total Vehicles',
              value: vehicleCountAsync.when(
                data: (count) => count.toString(),
                loading: () => '...',
                error: (_, __) => '0',
              ),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.local_gas_station,
              title: 'Total Entries',
              value: allFuelEntriesAsync.when(
                data: (entryState) => entryState.entries.length.toString(),
                loading: () => '...',
                error: (_, __) => '0',
              ),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Statistics card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// List of vehicles
class _VehiclesList extends ConsumerWidget {
  const _VehiclesList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);

    return vehiclesAsync.when(
      data: (vehicleState) {
        if (vehicleState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vehicleState.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading vehicles',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(vehicleState.error!),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.refresh(vehiclesNotifierProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (vehicleState.vehicles.isEmpty) {
          return const _EmptyVehiclesState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: vehicleState.vehicles.length,
          itemBuilder: (context, index) {
            final vehicle = vehicleState.vehicles[index];
            return _VehicleCard(vehicle: vehicle);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading vehicles',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(error.toString()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(vehiclesNotifierProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state when no vehicles exist
class _EmptyVehiclesState extends ConsumerWidget {
  const _EmptyVehiclesState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No Vehicles Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add your first vehicle to start tracking fuel consumption.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddVehicleDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add First Vehicle'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVehicleDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _AddVehicleDialog(ref: ref),
    );
  }
}

/// Individual vehicle card widget
class _VehicleCard extends ConsumerWidget {
  final VehicleModel vehicle;

  const _VehicleCard({required this.vehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(fuelEntriesByVehicleProvider(vehicle.id!));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.directions_car,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(vehicle.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Initial KM: ${vehicle.initialKm.toStringAsFixed(0)} km'),
            entriesAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return const Text('No entries yet');
                }
                final avgConsumption = entries.isNotEmpty 
                  ? entries.map((e) => e.consumption ?? 0.0).reduce((a, b) => a + b) / entries.length
                  : 0.0;
                return Text('Entries: ${entries.length} • Avg: ${avgConsumption.toStringAsFixed(1)}L/100km');
              },
              loading: () => const Text('Loading entries...'),
              error: (_, __) => const Text('Entries: 0'),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuSelection(context, ref, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'entries',
              child: Row(
                children: [
                  Icon(Icons.list),
                  SizedBox(width: 8),
                  Text('View Entries'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showVehicleDetails(context),
      ),
    );
  }

  void _handleMenuSelection(BuildContext context, WidgetRef ref, String value) {
    switch (value) {
      case 'edit':
        _showEditVehicleDialog(context, ref);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref);
        break;
      case 'entries':
        _navigateToVehicleEntries(context);
        break;
    }
  }

  void _showEditVehicleDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _EditVehicleDialog(vehicle: vehicle, ref: ref),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete "${vehicle.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteVehicle(context, ref);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVehicle(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(vehiclesNotifierProvider.notifier).deleteVehicle(vehicle.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${vehicle.name} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting vehicle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToVehicleEntries(BuildContext context) {
    context.go('/entries', extra: {'vehicleId': vehicle.id});
  }

  void _showVehicleDetails(BuildContext context) {
    // For now, just show vehicle entries
    _navigateToVehicleEntries(context);
  }
}

/// Add vehicle dialog
class _AddVehicleDialog extends StatefulWidget {
  final WidgetRef ref;

  const _AddVehicleDialog({required this.ref});

  @override
  State<_AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<_AddVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _initialKmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _initialKmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Vehicle'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Name',
                hintText: 'e.g., Honda Civic 2020',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a vehicle name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _initialKmController,
              decoration: const InputDecoration(
                labelText: 'Initial Kilometers',
                hintText: 'Current odometer reading',
                suffixText: 'km',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.speed),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter initial kilometers';
                }
                final km = double.tryParse(value);
                if (km == null || km < 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveVehicle,
          child: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Add Vehicle'),
        ),
      ],
    );
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final vehicle = VehicleModel.create(
        name: _nameController.text.trim(),
        initialKm: double.parse(_initialKmController.text),
      );

      // Validate the vehicle
      final validationErrors = vehicle.validate();
      if (validationErrors.isNotEmpty) {
        throw Exception(validationErrors.first);
      }

      // Check if vehicle name already exists
      final nameExists = await widget.ref.read(
        vehicleNameExistsProvider(_nameController.text.trim()).future,
      );
      
      if (nameExists) {
        throw Exception('A vehicle with this name already exists');
      }

      await widget.ref.read(vehiclesNotifierProvider.notifier).addVehicle(vehicle);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding vehicle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// Edit vehicle dialog
class _EditVehicleDialog extends StatefulWidget {
  final VehicleModel vehicle;
  final WidgetRef ref;

  const _EditVehicleDialog({required this.vehicle, required this.ref});

  @override
  State<_EditVehicleDialog> createState() => _EditVehicleDialogState();
}

class _EditVehicleDialogState extends State<_EditVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _initialKmController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vehicle.name);
    _initialKmController = TextEditingController(text: widget.vehicle.initialKm.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialKmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Vehicle'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Name',
                hintText: 'e.g., Honda Civic 2020',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_car),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a vehicle name';
                }
                if (value.trim().length < 2) {
                  return 'Name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _initialKmController,
              decoration: const InputDecoration(
                labelText: 'Initial Kilometers',
                hintText: 'Current odometer reading',
                suffixText: 'km',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.speed),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter initial kilometers';
                }
                final km = double.tryParse(value);
                if (km == null || km < 0) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateVehicle,
          child: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Update Vehicle'),
        ),
      ],
    );
  }

  Future<void> _updateVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedVehicle = widget.vehicle.copyWith(
        name: _nameController.text.trim(),
        initialKm: double.parse(_initialKmController.text),
      );

      // Validate the vehicle
      final validationErrors = updatedVehicle.validate();
      if (validationErrors.isNotEmpty) {
        throw Exception(validationErrors.first);
      }

      // Check if vehicle name already exists (excluding current vehicle)
      if (_nameController.text.trim() != widget.vehicle.name) {
        final nameExists = await widget.ref.read(
          vehicleNameExistsProvider(_nameController.text.trim(), excludeId: widget.vehicle.id).future,
        );
        
        if (nameExists) {
          throw Exception('A vehicle with this name already exists');
        }
      }

      await widget.ref.read(vehiclesNotifierProvider.notifier).updateVehicle(updatedVehicle);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vehicle updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating vehicle: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}