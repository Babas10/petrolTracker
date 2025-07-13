import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:petrol_tracker/navigation/main_layout.dart';

/// Add fuel entry screen with input form
/// 
/// This screen provides a form for adding new fuel entries with:
/// - Vehicle selection
/// - Date selection
/// - Fuel amount and cost inputs
/// - Current kilometers
/// - Location/country selection
/// - Form validation
class AddFuelEntryScreen extends StatefulWidget {
  const AddFuelEntryScreen({super.key});

  @override
  State<AddFuelEntryScreen> createState() => _AddFuelEntryScreenState();
}

class _AddFuelEntryScreenState extends State<AddFuelEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fuelAmountController = TextEditingController();
  final _priceController = TextEditingController();
  final _kilometersController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String? _selectedVehicle;
  bool _isLoading = false;

  @override
  void dispose() {
    _fuelAmountController.dispose();
    _priceController.dispose();
    _kilometersController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavAppBar(
        title: 'Add Fuel Entry',
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveEntry,
            child: _isLoading 
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVehicleSelection(),
              const SizedBox(height: 24),
              _buildDateSection(),
              const SizedBox(height: 24),
              _buildFuelAmountSection(),
              const SizedBox(height: 24),
              _buildPriceSection(),
              const SizedBox(height: 24),
              _buildKilometersSection(),
              const SizedBox(height: 24),
              _buildLocationSection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedVehicle,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Select a vehicle',
            prefixIcon: Icon(Icons.directions_car),
          ),
          items: const [
            // TODO: Replace with actual vehicles from provider
            DropdownMenuItem(
              value: null,
              child: Text('No vehicles available'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedVehicle = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a vehicle';
            }
            return null;
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.info_outline, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'No vehicles? Add one first in the Vehicles tab.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/vehicles'),
              child: const Text('Add Vehicle'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFuelAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fuel Amount',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _fuelAmountController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter fuel amount',
            suffixText: 'Liters',
            prefixIcon: Icon(Icons.local_gas_station),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter fuel amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Price',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _priceController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter total price',
            prefixText: '\$ ',
            prefixIcon: Icon(Icons.attach_money),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter total price';
            }
            final price = double.tryParse(value);
            if (price == null || price <= 0) {
              return 'Please enter a valid price';
            }
            return null;
          },
          onChanged: (value) {
            // Calculate price per liter automatically
            _calculatePricePerLiter();
          },
        ),
        const SizedBox(height: 8),
        if (_fuelAmountController.text.isNotEmpty && _priceController.text.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calculate,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Price per liter: \$${_calculatePricePerLiter().toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildKilometersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Kilometers',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _kilometersController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter current odometer reading',
            suffixText: 'km',
            prefixIcon: Icon(Icons.speed),
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter current kilometers';
            }
            final km = double.tryParse(value);
            if (km == null || km < 0) {
              return 'Please enter a valid kilometer reading';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location/Country',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _locationController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter country or location',
            prefixIcon: Icon(Icons.location_on),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter location';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveEntry,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: _isLoading
            ? const CircularProgressIndicator()
            : const Text('Save Fuel Entry'),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  double _calculatePricePerLiter() {
    final amount = double.tryParse(_fuelAmountController.text);
    final price = double.tryParse(_priceController.text);
    
    if (amount != null && price != null && amount > 0) {
      return price / amount;
    }
    return 0.0;
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement actual save functionality with provider
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fuel entry saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/entries');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving entry: $e'),
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