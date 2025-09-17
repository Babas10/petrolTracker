import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petrol_tracker/navigation/main_layout.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/currency_settings_providers.dart';
import 'package:petrol_tracker/providers/currency_providers.dart';
import 'package:petrol_tracker/widgets/country_dropdown.dart';
import 'package:petrol_tracker/widgets/smart_currency_selector.dart';
import 'package:petrol_tracker/widgets/currency_selection_hints.dart';
import 'package:petrol_tracker/widgets/conversion_preview.dart';
import 'package:petrol_tracker/services/country_currency_service.dart';

/// Add fuel entry screen with input form
/// 
/// This screen provides a form for adding new fuel entries with:
/// - Vehicle selection
/// - Date selection
/// - Fuel amount and cost inputs
/// - Current kilometers
/// - Location/country selection
/// - Form validation
class AddFuelEntryScreen extends ConsumerStatefulWidget {
  const AddFuelEntryScreen({super.key});

  @override
  ConsumerState<AddFuelEntryScreen> createState() => _AddFuelEntryScreenState();
}

class _AddFuelEntryScreenState extends ConsumerState<AddFuelEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fuelAmountController = TextEditingController();
  final _priceController = TextEditingController();
  final _pricePerLiterController = TextEditingController();
  final _kilometersController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  int? _selectedVehicleId;
  String? _selectedCountry;
  String? _selectedCurrency;
  bool _isLoading = false;
  double? _previousKm;
  bool _autoCalculatePricePerLiter = true;
  bool _isFullTank = true;
  bool _isFirstEntryForVehicle = false;

  @override
  void initState() {
    super.initState();
    // Add listeners for real-time calculations
    _fuelAmountController.addListener(_onFormChanged);
    _priceController.addListener(_onFormChanged);
    _pricePerLiterController.addListener(_onPricePerLiterChanged);
    
    // Initialize currency with smart default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCurrency();
    });
  }

  @override
  void dispose() {
    _fuelAmountController.dispose();
    _priceController.dispose();
    _pricePerLiterController.dispose();
    _kilometersController.dispose();
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
              _buildKilometersSection(),
              const SizedBox(height: 24),
              _buildFuelAmountSection(),
              const SizedBox(height: 24),
              _buildFullTankSection(),
              const SizedBox(height: 24),
              _buildPriceSection(),
              const SizedBox(height: 24),
              _buildPricePerLiterSection(),
              const SizedBox(height: 24),
              _buildCountrySection(),
              const SizedBox(height: 24),
              _buildCurrencySection(),
              const SizedBox(height: 24),
              _buildConversionPreview(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleSelection() {
    final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        vehiclesAsync.when(
          data: (vehicleState) {
            if (vehicleState.vehicles.isEmpty) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                      borderRadius: BorderRadius.circular(4),
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No vehicles available. Add one first.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/vehicles'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Vehicle'),
                    ),
                  ),
                ],
              );
            }
            
            return DropdownButtonFormField<int>(
              value: _selectedVehicleId,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Select a vehicle',
                prefixIcon: Icon(Icons.directions_car),
              ),
              items: vehicleState.vehicles.map((vehicle) {
                return DropdownMenuItem<int>(
                  value: vehicle.id,
                  child: Text(vehicle.name),
                );
              }).toList(),
              onChanged: (value) async {
                setState(() {
                  _selectedVehicleId = value;
                });
                
                if (value != null) {
                  // Load previous km for validation
                  await _loadPreviousKmForVehicle(value);
                }
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a vehicle';
                }
                return null;
              },
            );
          },
          loading: () => DropdownButtonFormField<int>(
            items: const [],
            onChanged: null,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Loading vehicles...',
              prefixIcon: Icon(Icons.directions_car),
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Error loading vehicles: $error',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ),
        if (_previousKm != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Previous odometer: ${_previousKm!.toStringAsFixed(0)} km',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateSection() {
    final now = DateTime.now();
    final isDateInFuture = _selectedDate.isAfter(now);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDateInFuture 
                  ? Colors.red 
                  : Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: isDateInFuture 
                    ? Colors.red 
                    : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isDateInFuture ? Colors.red : null,
                  ),
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
        if (isDateInFuture) ...[
          const SizedBox(height: 4),
          Text(
            'Date cannot be in the future',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFuelAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fuel Amount *',
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
            helperText: 'Amount of fuel added',
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
              return 'Please enter a valid amount greater than 0';
            }
            if (amount > 200) {
              return 'Amount seems unusually high (>200L). Please verify.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildFullTankSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fill-up Type *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: _isFirstEntryForVehicle && !_isFullTank 
                ? Theme.of(context).colorScheme.error 
                : Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(8),
            color: _isFirstEntryForVehicle && !_isFullTank 
              ? Theme.of(context).colorScheme.errorContainer.withOpacity(0.1)
              : null,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    _isFullTank ? Icons.local_gas_station : Icons.local_gas_station_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isFullTank ? 'Full Tank' : 'Partial Refuel',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _isFullTank 
                            ? 'Tank filled to capacity'
                            : 'Partial fuel addition',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isFullTank,
                    onChanged: _isFirstEntryForVehicle 
                      ? null // Disable switch for first entry
                      : (value) {
                          setState(() {
                            _isFullTank = value;
                          });
                        },
                  ),
                ],
              ),
              if (_isFirstEntryForVehicle && !_isFullTank) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        size: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'First entry for a vehicle must be a full tank',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!_isFullTank) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Consumption will be calculated when you complete a full tank',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Price *',
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
            helperText: 'Total amount paid for fuel',
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
              return 'Please enter a valid price greater than 0';
            }
            
            // Check consistency with price per liter
            final fuelAmount = double.tryParse(_fuelAmountController.text);
            final pricePerLiter = double.tryParse(_pricePerLiterController.text);
            if (fuelAmount != null && pricePerLiter != null && pricePerLiter > 0) {
              final expectedPrice = fuelAmount * pricePerLiter;
              final difference = (price - expectedPrice).abs();
              if (difference > 0.01) {
                return 'Price (\$${price.toStringAsFixed(2)}) doesn\'t match fuel × price/L (\$${expectedPrice.toStringAsFixed(2)})';
              }
            }
            
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildKilometersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Odometer Reading *',
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
            helperText: 'Must be higher than previous entry',
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
            if (_previousKm != null && km < _previousKm!) {
              return 'Must be >= ${_previousKm!.toStringAsFixed(0)} km (previous entry)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPricePerLiterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Price per Liter *',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  'Auto-calculate',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                Switch(
                  value: _autoCalculatePricePerLiter,
                  onChanged: (value) {
                    setState(() {
                      _autoCalculatePricePerLiter = value;
                      if (value) {
                        _onFormChanged();
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _pricePerLiterController,
          enabled: !_autoCalculatePricePerLiter,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: _autoCalculatePricePerLiter 
              ? 'Calculated automatically' 
              : 'Enter price per liter',
            prefixText: '\$ ',
            prefixIcon: const Icon(Icons.attach_money),
            helperText: _autoCalculatePricePerLiter
              ? 'Calculated from total price ÷ fuel amount'
              : 'Manual price per liter entry',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter price per liter';
            }
            final pricePerLiter = double.tryParse(value);
            if (pricePerLiter == null || pricePerLiter <= 0) {
              return 'Please enter a valid price per liter';
            }
            if (pricePerLiter > 10) {
              return 'Price per liter seems unusually high (>\$10). Please verify.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCountrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Country *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        CountryDropdown(
          selectedCountry: _selectedCountry,
          onChanged: (country) {
            setState(() {
              _selectedCountry = country;
              // Update currency when country changes
              _updateCurrencyForCountry(country);
            });
          },
          hintText: 'Select a country',
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
      initialDate: _selectedDate.isAfter(DateTime.now()) 
        ? DateTime.now() 
        : _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Select fuel entry date',
      confirmText: 'SELECT',
      cancelText: 'CANCEL',
    );
    
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  void _onFormChanged() {
    if (_autoCalculatePricePerLiter) {
      final amount = double.tryParse(_fuelAmountController.text);
      final price = double.tryParse(_priceController.text);
      
      if (amount != null && price != null && amount > 0) {
        final pricePerLiter = price / amount;
        // Use 4 decimal places for better precision, but round to avoid floating point issues
        _pricePerLiterController.text = (pricePerLiter).toStringAsFixed(4);
      } else {
        _pricePerLiterController.text = '';
      }
    }
  }
  
  void _onPricePerLiterChanged() {
    if (!_autoCalculatePricePerLiter) {
      // When manually editing price per liter, update total price if fuel amount is available
      final amount = double.tryParse(_fuelAmountController.text);
      final pricePerLiter = double.tryParse(_pricePerLiterController.text);
      
      if (amount != null && pricePerLiter != null && amount > 0) {
        final totalPrice = amount * pricePerLiter;
        _priceController.text = totalPrice.toStringAsFixed(2);
      }
    }
  }
  
  Future<void> _loadPreviousKmForVehicle(int vehicleId) async {
    try {
      final latestEntry = await ref.read(latestFuelEntryForVehicleProvider(vehicleId).future);
      if (latestEntry != null) {
        setState(() {
          _previousKm = latestEntry.currentKm;
          _isFirstEntryForVehicle = false;
        });
      } else {
        // If no previous entry, get initial km from vehicle
        final vehicle = await ref.read(vehicleProvider(vehicleId).future);
        if (vehicle != null) {
          setState(() {
            _previousKm = vehicle.initialKm;
            _isFirstEntryForVehicle = true;
            _isFullTank = true; // Force full tank for first entry
          });
        }
      }
    } catch (e) {
      // Handle error silently or show a subtle warning
      setState(() {
        _previousKm = null;
        _isFirstEntryForVehicle = false;
      });
    }
  }

  Future<void> _saveEntry() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Additional validation checks
    if (_selectedVehicleId == null) {
      _showError('Please select a vehicle');
      return;
    }
    
    if (_selectedCountry == null || _selectedCountry!.isEmpty) {
      _showError('Please select a country');
      return;
    }
    
    if (_selectedCurrency == null || _selectedCurrency!.isEmpty) {
      _showError('Please select a currency');
      return;
    }
    
    if (_selectedDate.isAfter(DateTime.now())) {
      _showError('Date cannot be in the future');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse form values with better error handling
      final currentKm = double.parse(_kilometersController.text.trim());
      final fuelAmount = double.parse(_fuelAmountController.text.trim());
      final price = double.parse(_priceController.text.trim());
      final pricePerLiter = double.parse(_pricePerLiterController.text.trim());
      
      // Get user's primary currency for conversion
      final currencySettings = await ref.read(currencySettingsNotifierProvider.future);
      final userPrimaryCurrency = currencySettings.primaryCurrency;
      
      // Convert price to user's primary currency if different
      double convertedPrice = price;
      double? originalAmount;
      String transactionCurrency = _selectedCurrency!;
      
      if (_selectedCurrency! != userPrimaryCurrency) {
        try {
          final conversion = await ref.read(currencyServiceProvider).convertAmount(
            amount: price,
            fromCurrency: _selectedCurrency!,
            toCurrency: userPrimaryCurrency,
          );
          
          if (conversion != null) {
            convertedPrice = conversion.convertedAmount;
            originalAmount = price;
            // Store converted price, original amount, and transaction currency
          }
        } catch (e) {
          // If conversion fails, still save with original price but show warning
          convertedPrice = price;
          originalAmount = null; // No conversion happened
        }
      }
      
      // Create fuel entry model
      final fuelEntry = FuelEntryModel.create(
        vehicleId: _selectedVehicleId!,
        date: _selectedDate,
        currentKm: currentKm,
        fuelAmount: fuelAmount,
        price: convertedPrice,
        country: _selectedCountry!,
        pricePerLiter: pricePerLiter,
        consumption: _previousKm != null 
          ? FuelEntryModel.calculateConsumption(
              fuelAmount: fuelAmount,
              currentKm: currentKm,
              previousKm: _previousKm!,
            )
          : null,
        isFullTank: _isFullTank,
        currency: transactionCurrency,
        originalAmount: originalAmount,
      );
      
      // Validate the entry
      final validationErrors = fuelEntry.validate(
        previousKm: _previousKm,
        isFirstEntry: _isFirstEntryForVehicle,
      );
      if (validationErrors.isNotEmpty) {
        _showError(validationErrors.first);
        return;
      }
      
      // Save the entry
      await ref.read(fuelEntriesNotifierProvider.notifier).addFuelEntry(fuelEntry);
      
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
      _showError('Error saving entry: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// Build currency selection section
  Widget _buildCurrencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Currency *',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SmartCurrencySelector(
          selectedCurrency: _selectedCurrency,
          selectedCountry: _selectedCountry,
          onCurrencyChanged: (currency) {
            setState(() {
              _selectedCurrency = currency;
            });
          },
          helperText: _getCurrencyHelperText(),
        ),
        
        // Currency selection hints
        CurrencySelectionHints(
          selectedCountry: _selectedCountry,
          selectedCurrency: _selectedCurrency,
          showDetailed: true,
        ),
      ],
    );
  }

  /// Build conversion preview section
  Widget _buildConversionPreview() {
    final currencySettings = ref.watch(currencySettingsNotifierProvider);
    
    return currencySettings.when(
      data: (settings) {
        if (_selectedCurrency == null || 
            _selectedCurrency == settings.primaryCurrency ||
            _priceController.text.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return ConversionPreviewCard(
          originalAmount: _priceController.text,
          fromCurrency: _selectedCurrency!,
          toCurrency: settings.primaryCurrency,
          showRate: true,
          showTimestamp: false,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Update currency when country changes
  void _updateCurrencyForCountry(String? country) {
    if (country == null) {
      return;
    }
    
    final currencySettings = ref.read(currencySettingsNotifierProvider);
    currencySettings.whenData((settings) {
      final smartDefault = CountryCurrencyService.getSmartDefault(
        country, 
        settings.primaryCurrency,
      );
      
      // Only update if no currency is selected or if the new default is different
      if (_selectedCurrency == null || 
          (CountryCurrencyService.getPrimaryCurrency(country) != null &&
           _selectedCurrency != smartDefault)) {
        _selectedCurrency = smartDefault;
      }
    });
  }

  /// Get helper text for currency selector
  String? _getCurrencyHelperText() {
    if (_selectedCountry != null) {
      final primaryCurrency = CountryCurrencyService.getPrimaryCurrency(_selectedCountry!);
      if (primaryCurrency != null) {
        return 'Primary currency in $_selectedCountry: $primaryCurrency';
      }
    }
    return 'Currency for this transaction';
  }

  /// Initialize currency with smart default
  void _initializeCurrency() {
    final currencySettings = ref.read(currencySettingsNotifierProvider);
    currencySettings.whenData((settings) {
      if (_selectedCurrency == null) {
        _selectedCurrency = CountryCurrencyService.getSmartDefault(
          _selectedCountry,
          settings.primaryCurrency,
        );
      }
    });
  }
}