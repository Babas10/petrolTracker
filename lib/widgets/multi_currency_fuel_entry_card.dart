import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/units_providers.dart';
import 'package:petrol_tracker/services/local_currency_converter.dart';
import 'package:petrol_tracker/widgets/currency_conversion_indicator.dart';
import 'package:petrol_tracker/widgets/conversion_detail_card.dart';

/// Multi-currency fuel entry card that displays original currency and converted amounts
/// with visual indicators for currency conversions and expandable conversion details.
class MultiCurrencyFuelEntryCard extends ConsumerStatefulWidget {
  final FuelEntryModel entry;
  final String? primaryCurrency;
  final bool showConversionDetails;

  const MultiCurrencyFuelEntryCard({
    super.key,
    required this.entry,
    this.primaryCurrency = 'USD',
    this.showConversionDetails = false,
  });

  @override
  ConsumerState<MultiCurrencyFuelEntryCard> createState() => _MultiCurrencyFuelEntryCardState();
}

class _MultiCurrencyFuelEntryCardState extends ConsumerState<MultiCurrencyFuelEntryCard> {
  double? _convertedAmount;
  double? _exchangeRate;
  bool _isConverting = false;
  String? _conversionError;

  @override
  void initState() {
    super.initState();
    _convertCurrencyIfNeeded();
  }

  @override
  void didUpdateWidget(MultiCurrencyFuelEntryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry.currency != widget.entry.currency ||
        oldWidget.primaryCurrency != widget.primaryCurrency) {
      _convertCurrencyIfNeeded();
    }
  }

  Future<void> _convertCurrencyIfNeeded() async {
    final primaryCurrency = widget.primaryCurrency ?? 'USD';
    
    if (widget.entry.currency == primaryCurrency) {
      setState(() {
        _convertedAmount = widget.entry.price;
        _exchangeRate = 1.0;
        _isConverting = false;
        _conversionError = null;
      });
      return;
    }

    setState(() {
      _isConverting = true;
      _conversionError = null;
    });

    try {
      final converter = LocalCurrencyConverter.instance;
      final result = await converter.convertAmount(
        amount: widget.entry.price,
        fromCurrency: widget.entry.currency,
        toCurrency: primaryCurrency,
      );

      if (result != null) {
        setState(() {
          _convertedAmount = result.convertedAmount;
          _exchangeRate = result.exchangeRate;
          _isConverting = false;
        });
      } else {
        // For now, show original currency when conversion fails
        // This allows the feature to work even without exchange rates
        setState(() {
          _convertedAmount = null;
          _exchangeRate = null;
          _isConverting = false;
          _conversionError = null; // Don't show error, just use original currency
        });
      }
    } catch (e) {
      setState(() {
        _convertedAmount = null;
        _exchangeRate = null;
        _isConverting = false;
        _conversionError = null; // Don't show error, just use original currency
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleAsync = ref.watch(vehicleProvider(widget.entry.vehicleId));
    final primaryCurrency = widget.primaryCurrency ?? 'USD';
    final needsConversion = widget.entry.currency != primaryCurrency;

    return Dismissible(
      key: ValueKey(widget.entry.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _showDeleteConfirmation(context),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.onError,
            ),
            Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onError,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 2,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.all(16),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.local_gas_station,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            title: vehicleAsync.when(
              data: (vehicle) => Row(
                children: [
                  Expanded(
                    child: Text(
                      vehicle?.name ?? 'Unknown Vehicle',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _TankTypeChip(isFullTank: widget.entry.isFullTank),
                  const SizedBox(width: 8),
                  if (needsConversion && (_isConverting || _convertedAmount != null))
                    CurrencyConversionIndicator(
                      fromCurrency: widget.entry.currency,
                      toCurrency: primaryCurrency,
                      isConverting: _isConverting,
                      hasError: _conversionError != null,
                    ),
                ],
              ),
              loading: () => Row(
                children: [
                  const Expanded(child: Text('Loading vehicle...')),
                  const SizedBox(width: 8),
                  _TankTypeChip(isFullTank: widget.entry.isFullTank),
                  const SizedBox(width: 8),
                  if (needsConversion && (_isConverting || _convertedAmount != null))
                    CurrencyConversionIndicator(
                      fromCurrency: widget.entry.currency,
                      toCurrency: primaryCurrency,
                      isConverting: _isConverting,
                      hasError: _conversionError != null,
                    ),
                ],
              ),
              error: (_, __) => Row(
                children: [
                  const Expanded(child: Text('Unknown Vehicle')),
                  const SizedBox(width: 8),
                  _TankTypeChip(isFullTank: widget.entry.isFullTank),
                  const SizedBox(width: 8),
                  if (needsConversion && (_isConverting || _convertedAmount != null))
                    CurrencyConversionIndicator(
                      fromCurrency: widget.entry.currency,
                      toCurrency: primaryCurrency,
                      isConverting: _isConverting,
                      hasError: _conversionError != null,
                    ),
                ],
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        DateFormat('MMM d, yyyy').format(widget.entry.date),
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.public,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        widget.entry.country,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.local_gas_station,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.entry.fuelAmount.toStringAsFixed(1)}L',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: _buildPriceDisplay(),
                    ),
                    const Spacer(),
                    if (widget.entry.consumption != null)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.speed,
                              size: 16,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Consumer(
                                builder: (context, ref, child) {
                                  final unitSystem = ref.watch(unitsProvider);
                                  return unitSystem.when(
                                    data: (units) {
                                      final displayConsumption = units == UnitSystem.metric 
                                          ? widget.entry.consumption! 
                                          : UnitConverter.consumptionToImperial(widget.entry.consumption!);
                                      return Text(
                                        '${displayConsumption.toStringAsFixed(1)} ${units.consumptionUnit}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    },
                                    loading: () => Text(
                                      '${widget.entry.consumption!.toStringAsFixed(1)} L/100km',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    error: (_, __) => Text(
                                      '${widget.entry.consumption!.toStringAsFixed(1)} L/100km',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.speed,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.entry.currentKm.toStringAsFixed(0)} km',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.calculate,
                      size: 16,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.entry.pricePerLiter.toStringAsFixed(3)} ${widget.entry.currency}/L',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    context.go('/add-entry');
                    break;
                  case 'delete':
                    _deleteEntry(context);
                    break;
                  case 'conversion_details':
                    _showConversionDetails();
                    break;
                }
              },
              itemBuilder: (context) => [
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
                if (needsConversion && (_convertedAmount != null || _conversionError != null))
                  const PopupMenuItem(
                    value: 'conversion_details',
                    child: Row(
                      children: [
                        Icon(Icons.currency_exchange),
                        SizedBox(width: 8),
                        Text('Conversion Details'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
            children: [
              if (needsConversion && (_isConverting || _convertedAmount != null || _conversionError != null))
                ConversionDetailCard(
                  entry: widget.entry,
                  convertedAmount: _convertedAmount,
                  exchangeRate: _exchangeRate,
                  targetCurrency: primaryCurrency,
                  error: _conversionError,
                  isLoading: _isConverting,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceDisplay() {
    final primaryCurrency = widget.primaryCurrency ?? 'USD';
    final needsConversion = widget.entry.currency != primaryCurrency;

    if (!needsConversion) {
      return Text(
        '${widget.entry.price.toStringAsFixed(2)} ${widget.entry.currency}',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    if (_isConverting) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 4),
          Text(
            '${widget.entry.price.toStringAsFixed(2)} ${widget.entry.currency}',
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    if (_conversionError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${widget.entry.price.toStringAsFixed(2)} ${widget.entry.currency}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Conversion failed',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    if (_convertedAmount != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_convertedAmount!.toStringAsFixed(2)} $primaryCurrency',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${widget.entry.price.toStringAsFixed(2)} ${widget.entry.currency}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    }

    return Text(
      '${widget.entry.price.toStringAsFixed(2)} ${widget.entry.currency}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  void _showConversionDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Currency Conversion Details'),
        content: ConversionDetailCard(
          entry: widget.entry,
          convertedAmount: _convertedAmount,
          exchangeRate: _exchangeRate,
          targetCurrency: widget.primaryCurrency ?? 'USD',
          error: _conversionError,
          isLoading: _isConverting,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (_conversionError != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _convertCurrencyIfNeeded();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'Are you sure you want to delete this fuel entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
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

  void _deleteEntry(BuildContext context) async {
    final confirmed = await _showDeleteConfirmation(context);
    if (confirmed == true && widget.entry.id != null) {
      try {
        await ref.read(fuelEntriesNotifierProvider.notifier).deleteFuelEntry(widget.entry.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entry deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting entry: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

/// Tank type indicator chip widget
class _TankTypeChip extends StatelessWidget {
  final bool isFullTank;

  const _TankTypeChip({
    required this.isFullTank,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        isFullTank ? 'Full' : 'Partial',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      visualDensity: VisualDensity.compact,
      side: BorderSide.none,
    );
  }
}