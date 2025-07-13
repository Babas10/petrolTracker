import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:petrol_tracker/navigation/main_layout.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';

/// Fuel entries screen displaying list of all fuel entries
/// 
/// This screen will eventually show:
/// - List of fuel entries with filtering and sorting
/// - Search functionality
/// - Entry details and actions
/// - Export functionality
class FuelEntriesScreen extends ConsumerStatefulWidget {
  final int? vehicleFilter;
  
  const FuelEntriesScreen({super.key, this.vehicleFilter});

  @override
  ConsumerState<FuelEntriesScreen> createState() => _FuelEntriesScreenState();
}

class _FuelEntriesScreenState extends ConsumerState<FuelEntriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'date';
  bool _ascending = false;
  String _searchQuery = '';
  String? _selectedCountryFilter;
  DateTimeRange? _selectedDateRange;
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavAppBar(
        title: widget.vehicleFilter != null ? 'Vehicle Entries' : 'Fuel Entries',
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                if (value == _sortBy) {
                  _ascending = !_ascending;
                } else {
                  _sortBy = value;
                  _ascending = true;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    const Text('Sort by Date'),
                    const Spacer(),
                    if (_sortBy == 'date')
                      Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'amount',
                child: Row(
                  children: [
                    const Icon(Icons.local_gas_station),
                    const SizedBox(width: 8),
                    const Text('Sort by Amount'),
                    const Spacer(),
                    if (_sortBy == 'amount')
                      Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'cost',
                child: Row(
                  children: [
                    const Icon(Icons.attach_money),
                    const SizedBox(width: 8),
                    const Text('Sort by Cost'),
                    const Spacer(),
                    if (_sortBy == 'cost')
                      Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'consumption',
                child: Row(
                  children: [
                    const Icon(Icons.speed),
                    const SizedBox(width: 8),
                    const Text('Sort by Consumption'),
                    const Spacer(),
                    if (_sortBy == 'consumption')
                      Icon(_ascending ? Icons.arrow_upward : Icons.arrow_downward),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.refresh(fuelEntriesNotifierProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearch) _buildSearchBar(),
          _FilterChips(
            selectedCountryFilter: _selectedCountryFilter,
            selectedDateRange: _selectedDateRange,
            onCountryFilterChanged: (country) {
              setState(() {
                _selectedCountryFilter = country;
              });
            },
            onDateRangeChanged: (range) {
              setState(() {
                _selectedDateRange = range;
              });
            },
            onClearFilters: () {
              setState(() {
                _selectedCountryFilter = null;
                _selectedDateRange = null;
              });
            },
          ),
          Expanded(child: _EntriesList(
            vehicleFilter: widget.vehicleFilter,
            searchQuery: _searchQuery,
            countryFilter: _selectedCountryFilter,
            dateRange: _selectedDateRange,
            sortBy: _sortBy,
            ascending: _ascending,
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-entry'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by vehicle, country, or date...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        selectedCountry: _selectedCountryFilter,
        selectedDateRange: _selectedDateRange,
        onCountryChanged: (country) {
          setState(() {
            _selectedCountryFilter = country;
          });
        },
        onDateRangeChanged: (range) {
          setState(() {
            _selectedDateRange = range;
          });
        },
        onClearFilters: () {
          setState(() {
            _selectedCountryFilter = null;
            _selectedDateRange = null;
          });
        },
      ),
    );
  }
}

/// Filter chips for quick filtering options
class _FilterChips extends StatefulWidget {
  final String? selectedCountryFilter;
  final DateTimeRange? selectedDateRange;
  final ValueChanged<String?> onCountryFilterChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final VoidCallback onClearFilters;

  const _FilterChips({
    required this.selectedCountryFilter,
    required this.selectedDateRange,
    required this.onCountryFilterChanged,
    required this.onDateRangeChanged,
    required this.onClearFilters,
  });

  @override
  State<_FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<_FilterChips> {
  String? _selectedTimeFilter;

  @override
  Widget build(BuildContext context) {
    final timeFilters = [
      ('thisWeek', 'This Week'),
      ('thisMonth', 'This Month'),
      ('thisYear', 'This Year'),
    ];

    final hasActiveFilters = widget.selectedCountryFilter != null ||
                           widget.selectedDateRange != null ||
                           _selectedTimeFilter != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Time period filters
            ...timeFilters.map((filter) {
              final isSelected = _selectedTimeFilter == filter.$1;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter.$2),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTimeFilter = selected ? filter.$1 : null;
                    });
                    if (selected) {
                      _applyTimeFilter(filter.$1);
                    } else {
                      widget.onDateRangeChanged(null);
                    }
                  },
                ),
              );
            }),
            
            // Active filters display
            if (widget.selectedCountryFilter != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text('Country: ${widget.selectedCountryFilter}'),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => widget.onCountryFilterChanged(null),
                ),
              ),
            
            if (widget.selectedDateRange != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text(
                    'Date: ${DateFormat('MMM d').format(widget.selectedDateRange!.start)} - ${DateFormat('MMM d').format(widget.selectedDateRange!.end)}',
                  ),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    widget.onDateRangeChanged(null);
                    setState(() {
                      _selectedTimeFilter = null;
                    });
                  },
                ),
              ),
            
            // Clear all filters
            if (hasActiveFilters)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ActionChip(
                  label: const Text('Clear All'),
                  onPressed: () {
                    widget.onClearFilters();
                    setState(() {
                      _selectedTimeFilter = null;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _applyTimeFilter(String filter) {
    final now = DateTime.now();
    DateTimeRange? range;

    switch (filter) {
      case 'thisWeek':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        range = DateTimeRange(
          start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
          end: now,
        );
        break;
      case 'thisMonth':
        range = DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
        break;
      case 'thisYear':
        range = DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        );
        break;
    }

    widget.onDateRangeChanged(range);
  }
}

/// List of fuel entries
class _EntriesList extends ConsumerWidget {
  final int? vehicleFilter;
  final String searchQuery;
  final String? countryFilter;
  final DateTimeRange? dateRange;
  final String sortBy;
  final bool ascending;

  const _EntriesList({
    this.vehicleFilter,
    required this.searchQuery,
    this.countryFilter,
    this.dateRange,
    required this.sortBy,
    required this.ascending,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(fuelEntriesNotifierProvider);

    return entriesAsync.when(
      data: (entryState) {
        if (entryState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (entryState.error != null) {
          return _buildErrorState(context, entryState.error!, ref);
        }

        List<FuelEntryModel> entries = entryState.entries;

        // Apply filters
        entries = _applyFilters(entries);

        // Apply sorting
        entries = _applySorting(entries);

        if (entries.isEmpty) {
          return _EmptyEntriesState(
            hasFilters: searchQuery.isNotEmpty ||
                       countryFilter != null ||
                       dateRange != null ||
                       vehicleFilter != null,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.refresh(fuelEntriesNotifierProvider.future);
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return _FuelEntryCard(
                entry: entries[index],
                ref: ref,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, error.toString(), ref),
    );
  }

  List<FuelEntryModel> _applyFilters(List<FuelEntryModel> entries) {
    var filtered = entries;

    // Vehicle filter
    if (vehicleFilter != null) {
      filtered = filtered.where((entry) => entry.vehicleId == vehicleFilter).toList();
    }

    // Search query filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((entry) {
        return entry.country.toLowerCase().contains(query) ||
               DateFormat('MMM d, yyyy').format(entry.date).toLowerCase().contains(query) ||
               entry.formattedPrice.toLowerCase().contains(query);
      }).toList();
    }

    // Country filter
    if (countryFilter != null) {
      filtered = filtered.where((entry) => entry.country == countryFilter).toList();
    }

    // Date range filter
    if (dateRange != null) {
      filtered = filtered.where((entry) {
        return entry.date.isAfter(dateRange!.start.subtract(const Duration(days: 1))) &&
               entry.date.isBefore(dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  List<FuelEntryModel> _applySorting(List<FuelEntryModel> entries) {
    final sortedEntries = List<FuelEntryModel>.from(entries);

    sortedEntries.sort((a, b) {
      int comparison;
      switch (sortBy) {
        case 'date':
          comparison = a.date.compareTo(b.date);
          break;
        case 'amount':
          comparison = a.fuelAmount.compareTo(b.fuelAmount);
          break;
        case 'cost':
          comparison = a.price.compareTo(b.price);
          break;
        case 'consumption':
          final aConsumption = a.consumption ?? 0;
          final bConsumption = b.consumption ?? 0;
          comparison = aConsumption.compareTo(bConsumption);
          break;
        default:
          comparison = a.date.compareTo(b.date);
      }
      return ascending ? comparison : -comparison;
    });

    return sortedEntries;
  }

  Widget _buildErrorState(BuildContext context, String error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'Error Loading Entries',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.refresh(fuelEntriesNotifierProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state when no entries exist
class _EmptyEntriesState extends StatelessWidget {
  final bool hasFilters;
  
  const _EmptyEntriesState({required this.hasFilters});

  @override
  Widget build(BuildContext context) {
    if (hasFilters) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 24),
              Text(
                'No Entries Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Try adjusting your search terms or filters to find the entries you\'re looking for.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: () => context.go('/add-entry'),
                icon: const Icon(Icons.add),
                label: const Text('Add New Entry'),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_gas_station_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            Text(
              'No Fuel Entries Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start tracking your fuel consumption by adding your first entry.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/add-entry'),
              icon: const Icon(Icons.add),
              label: const Text('Add First Entry'),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => context.go('/vehicles'),
              icon: const Icon(Icons.directions_car),
              label: const Text('Add Vehicle First'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual fuel entry card widget
class _FuelEntryCard extends ConsumerWidget {
  final FuelEntryModel entry;
  final WidgetRef ref;

  const _FuelEntryCard({
    required this.entry,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleProvider(entry.vehicleId));

    return Dismissible(
      key: ValueKey(entry.id),
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
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.local_gas_station,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          title: vehicleAsync.when(
            data: (vehicle) => Text(
              vehicle?.name ?? 'Unknown Vehicle',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            loading: () => const Text('Loading vehicle...'),
            error: (_, __) => const Text('Unknown Vehicle'),
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
                  Text(
                    DateFormat('MMM d, yyyy').format(entry.date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.public,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entry.country,
                    style: Theme.of(context).textTheme.bodySmall,
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
                    '${entry.fuelAmount.toStringAsFixed(1)}L',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '\$${entry.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (entry.consumption != null)
                    Row(
                      children: [
                        Icon(
                          Icons.speed,
                          size: 16,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry.consumption!.toStringAsFixed(1)} L/100km',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                    '${entry.currentKm.toStringAsFixed(0)} km',
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
                    '\$${entry.pricePerLiter.toStringAsFixed(3)}/L',
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
                  // TODO: Navigate to edit screen
                  context.go('/add-entry'); // For now, goes to add screen
                  break;
                case 'delete':
                  _deleteEntry(context);
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
          onTap: () {
            _showEntryDetails(context);
          },
        ),
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
    if (confirmed == true && entry.id != null) {
      try {
        await ref.read(fuelEntriesNotifierProvider.notifier).deleteFuelEntry(entry.id!);
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

  void _showEntryDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _EntryDetailsDialog(entry: entry),
    );
  }
}

/// Filter dialog for advanced filtering
class _FilterDialog extends StatefulWidget {
  final String? selectedCountry;
  final DateTimeRange? selectedDateRange;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final VoidCallback onClearFilters;

  const _FilterDialog({
    required this.selectedCountry,
    required this.selectedDateRange,
    required this.onCountryChanged,
    required this.onDateRangeChanged,
    required this.onClearFilters,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late String? _selectedCountry;
  late DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.selectedCountry;
    _selectedDateRange = widget.selectedDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Entries'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country filter
            Text(
              'Country',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'All countries',
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All countries'),
                ),
                // TODO: Load countries from fuel entries
                const DropdownMenuItem<String>(
                  value: 'Canada',
                  child: Text('Canada'),
                ),
                const DropdownMenuItem<String>(
                  value: 'United States',
                  child: Text('United States'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Date range filter
            Text(
              'Date Range',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _selectDateRange,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.date_range,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _selectedDateRange != null
                          ? '${DateFormat('MMM d, yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MMM d, yyyy').format(_selectedDateRange!.end)}'
                          : 'Select date range',
                    ),
                    const Spacer(),
                    if (_selectedDateRange != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedDateRange = null;
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onClearFilters();
            Navigator.of(context).pop();
          },
          child: const Text('Clear All'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onCountryChanged(_selectedCountry);
            widget.onDateRangeChanged(_selectedDateRange);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Future<void> _selectDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    
    if (range != null) {
      setState(() {
        _selectedDateRange = range;
      });
    }
  }
}

/// Entry details dialog
class _EntryDetailsDialog extends ConsumerWidget {
  final FuelEntryModel entry;

  const _EntryDetailsDialog({required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleProvider(entry.vehicleId));

    return AlertDialog(
      title: const Text('Entry Details'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            vehicleAsync.when(
              data: (vehicle) => _buildDetailRow(
                context,
                'Vehicle',
                vehicle?.name ?? 'Unknown Vehicle',
                Icons.directions_car,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => _buildDetailRow(
                context,
                'Vehicle',
                'Unknown Vehicle',
                Icons.directions_car,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'Date',
              DateFormat('EEEE, MMM d, yyyy').format(entry.date),
              Icons.calendar_today,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'Country',
              entry.country,
              Icons.public,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'Odometer Reading',
              '${entry.currentKm.toStringAsFixed(0)} km',
              Icons.speed,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'Fuel Amount',
              '${entry.fuelAmount.toStringAsFixed(1)} L',
              Icons.local_gas_station,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'Total Price',
              '\$${entry.price.toStringAsFixed(2)}',
              Icons.attach_money,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'Price per Liter',
              '\$${entry.pricePerLiter.toStringAsFixed(3)}/L',
              Icons.calculate,
            ),
            if (entry.consumption != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow(
                context,
                'Consumption',
                '${entry.consumption!.toStringAsFixed(1)} L/100km',
                Icons.trending_up,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // TODO: Navigate to edit screen
            context.go('/add-entry');
          },
          child: const Text('Edit'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}