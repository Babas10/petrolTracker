import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:petrol_tracker/navigation/main_layout.dart';
import 'package:petrol_tracker/models/maintenance_log_model.dart';
import 'package:petrol_tracker/models/maintenance_category_model.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/providers/maintenance_providers.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';

/// Add maintenance log screen for creating new maintenance entries
/// 
/// Features:
/// - Step-by-step form with category selection
/// - Vehicle selection with auto-fill odometer from latest fuel entry
/// - Cost breakdown (parts, labor, total)
/// - Service provider and notes fields
/// - Form validation and error handling
/// - Smart defaults and suggestions
class AddMaintenanceLogScreen extends ConsumerStatefulWidget {
  final int? preselectedVehicleId;

  const AddMaintenanceLogScreen({
    super.key,
    this.preselectedVehicleId,
  });

  @override
  ConsumerState<AddMaintenanceLogScreen> createState() => _AddMaintenanceLogScreenState();
}

class _AddMaintenanceLogScreenState extends ConsumerState<AddMaintenanceLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _odometerController = TextEditingController();
  final _serviceProviderController = TextEditingController();
  final _totalCostController = TextEditingController(); // Renamed for clarity
  final _notesController = TextEditingController();

  VehicleModel? _selectedVehicle;
  MaintenanceCategoryModel? _selectedCategory;
  DateTime _serviceDate = DateTime.now();
  String _currency = 'USD';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeDefaults();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _odometerController.dispose();
    _serviceProviderController.dispose();
    _totalCostController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _initializeDefaults() {
    // Set default currency based on system locale (simplified)
    _currency = 'USD'; // Could be enhanced to detect from system
    
    // If a vehicle is preselected, set it
    if (widget.preselectedVehicleId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadPreselectedVehicle();
      });
    }
  }

  Future<void> _loadPreselectedVehicle() async {
    try {
      final vehiclesAsync = ref.read(vehiclesProvider);
      vehiclesAsync.whenData((vehiclesState) {
        final vehicle = vehiclesState.vehicles.firstWhere(
          (v) => v.id == widget.preselectedVehicleId,
          orElse: () => vehiclesState.vehicles.isNotEmpty ? vehiclesState.vehicles.first : throw Exception('No vehicles'),
        );
        setState(() {
          _selectedVehicle = vehicle;
        });
        _autoFillOdometer();
      });
    } catch (e) {
      // Handle error silently or show snackbar
    }
  }

  Future<void> _autoFillOdometer() async {
    if (_selectedVehicle?.id == null) return;

    try {
      final latestEntryAsync = ref.read(latestFuelEntryForVehicleProvider(_selectedVehicle!.id!));
      latestEntryAsync.whenData((latestEntry) {
        if (latestEntry != null) {
          setState(() {
            _odometerController.text = latestEntry.currentKm.toStringAsFixed(0);
          });
        }
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavAppBar(
        title: 'Add Maintenance Log',
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitForm,
            child: _isSubmitting 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildVehicleSelection(),
              const SizedBox(height: 16),
              _buildCategorySelection(),
              const SizedBox(height: 16),
              _buildBasicInformation(),
              const SizedBox(height: 16),
              _buildServiceDetails(),
              const SizedBox(height: 16),
              _buildCostSection(),
              const SizedBox(height: 16),
              _buildNotesSection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleSelection() {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_car,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Vehicle',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            vehiclesAsync.when(
              data: (vehiclesState) {
                if (vehiclesState.vehicles.isEmpty) {
                  return const Text('No vehicles available. Please add a vehicle first.');
                }

                return DropdownButtonFormField<VehicleModel>(
                  value: _selectedVehicle,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select a vehicle',
                  ),
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a vehicle';
                    }
                    return null;
                  },
                  items: vehiclesState.vehicles.map((vehicle) => DropdownMenuItem(
                    value: vehicle,
                    child: Text(vehicle.name),
                  )).toList(),
                  onChanged: (vehicle) {
                    setState(() {
                      _selectedVehicle = vehicle;
                    });
                    if (vehicle != null) {
                      _autoFillOdometer();
                    }
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error loading vehicles: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    final categoriesAsync = ref.watch(maintenanceCategoriesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            categoriesAsync.when(
              data: (categories) {
                // Find current selection in the categories list to avoid stale references
                MaintenanceCategoryModel? validSelection;
                if (_selectedCategory != null && categories.isNotEmpty) {
                  try {
                    validSelection = categories.firstWhere(
                      (cat) => cat.id == _selectedCategory!.id,
                    );
                  } catch (e) {
                    // Selected category not found in current list, reset selection
                    validSelection = null;
                    _selectedCategory = null;
                  }
                }
                    
                return SizedBox(
                  width: double.infinity,
                  child: DropdownButtonFormField<MaintenanceCategoryModel>(
                    key: const ValueKey('maintenance_category_dropdown'),
                    value: validSelection,
                    decoration: const InputDecoration(
                      hintText: 'Select maintenance category',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                    items: categories.map((category) => DropdownMenuItem<MaintenanceCategoryModel>(
                      value: category,
                      child: Text(
                        category.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )).toList(),
                    onChanged: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    isExpanded: true,
                    isDense: false,
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 56,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SizedBox(
                height: 56,
                child: Center(
                  child: Text('Error loading categories: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInformation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Service Title',
                hintText: 'e.g., Oil Change, Brake Pad Replacement',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a service title';
                }
                if (value.length > 200) {
                  return 'Title must be less than 200 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Additional details about the service performed',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value != null && value.length > 1000) {
                  return 'Description must be less than 1000 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.build,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Service Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Service Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(DateFormat.yMMMd().format(_serviceDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _odometerController,
                    decoration: const InputDecoration(
                      labelText: 'Odometer (km)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.speed),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      final odometer = double.tryParse(value);
                      if (odometer == null || odometer < 0) {
                        return 'Invalid odometer reading';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serviceProviderController,
              decoration: const InputDecoration(
                labelText: 'Service Provider (Optional)',
                hintText: 'e.g., Garage name, Self-service, Dealership',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.business),
              ),
              validator: (value) {
                if (value != null && value.length > 200) {
                  return 'Service provider name must be less than 200 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Cost',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalCostController,
              decoration: const InputDecoration(
                labelText: 'Total Cost',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
                hintText: '0.00',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value?.isNotEmpty == true) {
                  final cost = double.tryParse(value!);
                  if (cost == null || cost < 0) {
                    return 'Invalid amount';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notes,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  'Additional Notes',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Additional information or reminders',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              maxLines: 2,
              validator: (value) {
                if (value != null && value.length > 2000) {
                  return 'Notes must be less than 2000 characters';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        child: _isSubmitting
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text('Saving...'),
              ],
            )
          : const Text(
              'Save Maintenance Log',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _serviceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _serviceDate) {
      setState(() {
        _serviceDate = pickedDate;
      });
    }
  }

  double _getTotalCost() {
    return double.tryParse(_totalCostController.text) ?? 0.0;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a vehicle')),
      );
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final maintenanceLog = MaintenanceLogModel(
        vehicleId: _selectedVehicle!.id!,
        categoryId: _selectedCategory!.id!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty 
          ? _descriptionController.text.trim() 
          : null,
        serviceDate: _serviceDate,
        odometerReading: double.parse(_odometerController.text),
        serviceProvider: _serviceProviderController.text.trim().isNotEmpty 
          ? _serviceProviderController.text.trim() 
          : null,
        partsCost: 0.0, // Not used in simplified version
        laborCost: 0.0, // Not used in simplified version
        totalCost: _getTotalCost(),
        currency: _currency,
        laborHours: null, // Not used in simplified version
        notes: _notesController.text.trim().isNotEmpty 
          ? _notesController.text.trim() 
          : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final notifier = ref.read(maintenanceLogsNotifierProvider.notifier);
      await notifier.addMaintenanceLog(maintenanceLog);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maintenance log saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save maintenance log: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}