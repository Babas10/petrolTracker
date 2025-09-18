import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:petrol_tracker/navigation/main_layout.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/currency_providers.dart';
import 'package:petrol_tracker/widgets/multi_currency_fuel_entry_card.dart';

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
  String? _selectedCurrencyFilter;
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
      appBar: widget.vehicleFilter != null 
          ? _VehicleAppBar(
              vehicleId: widget.vehicleFilter!,
              onSearchPressed: () {
                setState(() {
                  _showSearch = !_showSearch;
                  if (!_showSearch) {
                    _searchController.clear();
                    _searchQuery = '';
                  }
                });
              },
              onFilterPressed: _showFilterDialog,
              onSortPressed: (value) {
                setState(() {
                  if (value == _sortBy) {
                    _ascending = !_ascending;
                  } else {
                    _sortBy = value;
                    _ascending = true;
                  }
                });
              },
              onRefreshPressed: () {
                ref.refresh(fuelEntriesNotifierProvider);
              },
              showSearch: _showSearch,
              sortBy: _sortBy,
              ascending: _ascending,
            )
          : NavAppBar(
              title: 'Fuel Entries',
              actions: _buildActions(),
            ),
      body: Column(
        children: [
          if (_showSearch) _buildSearchBar(),
          _FilterChips(
            selectedCountryFilter: _selectedCountryFilter,
            selectedCurrencyFilter: _selectedCurrencyFilter,
            selectedDateRange: _selectedDateRange,
            onCountryFilterChanged: (country) {
              setState(() {
                _selectedCountryFilter = country;
              });
            },
            onCurrencyFilterChanged: (currency) {
              setState(() {
                _selectedCurrencyFilter = currency;
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
                _selectedCurrencyFilter = null;
                _selectedDateRange = null;
              });
            },
          ),
          Expanded(child: _EntriesList(
            vehicleFilter: widget.vehicleFilter,
            searchQuery: _searchQuery,
            countryFilter: _selectedCountryFilter,
            currencyFilter: _selectedCurrencyFilter,
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

  List<Widget> _buildActions() {
    return [
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
    ];
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        selectedCountry: _selectedCountryFilter,
        selectedCurrency: _selectedCurrencyFilter,
        selectedDateRange: _selectedDateRange,
        onCountryChanged: (country) {
          setState(() {
            _selectedCountryFilter = country;
          });
        },
        onCurrencyChanged: (currency) {
          setState(() {
            _selectedCurrencyFilter = currency;
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
            _selectedCurrencyFilter = null;
            _selectedDateRange = null;
          });
        },
      ),
    );
  }
}

/// Vehicle app bar with dynamic title for filtered entries
class _VehicleAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final int vehicleId;
  final VoidCallback onSearchPressed;
  final VoidCallback onFilterPressed;
  final ValueChanged<String> onSortPressed;
  final VoidCallback onRefreshPressed;
  final bool showSearch;
  final String sortBy;
  final bool ascending;

  const _VehicleAppBar({
    required this.vehicleId,
    required this.onSearchPressed,
    required this.onFilterPressed,
    required this.onSortPressed,
    required this.onRefreshPressed,
    required this.showSearch,
    required this.sortBy,
    required this.ascending,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleProvider(vehicleId));

    return vehicleAsync.when(
      data: (vehicle) => NavAppBar(
        title: vehicle?.name ?? 'Unknown Vehicle',
        actions: [
          IconButton(
            icon: Icon(showSearch ? Icons.close : Icons.search),
            onPressed: onSearchPressed,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: onFilterPressed,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: onSortPressed,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    const Text('Sort by Date'),
                    const Spacer(),
                    if (sortBy == 'date')
                      Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward),
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
                    if (sortBy == 'amount')
                      Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward),
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
                    if (sortBy == 'cost')
                      Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward),
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
                    if (sortBy == 'consumption')
                      Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefreshPressed,
          ),
        ],
      ),
      loading: () => NavAppBar(
        title: 'Loading...',
        actions: [
          IconButton(
            icon: Icon(showSearch ? Icons.close : Icons.search),
            onPressed: onSearchPressed,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: onFilterPressed,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefreshPressed,
          ),
        ],
      ),
      error: (_, __) => NavAppBar(
        title: 'Unknown Vehicle',
        actions: [
          IconButton(
            icon: Icon(showSearch ? Icons.close : Icons.search),
            onPressed: onSearchPressed,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: onFilterPressed,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefreshPressed,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Filter chips for quick filtering options
class _FilterChips extends StatefulWidget {
  final String? selectedCountryFilter;
  final String? selectedCurrencyFilter;
  final DateTimeRange? selectedDateRange;
  final ValueChanged<String?> onCountryFilterChanged;
  final ValueChanged<String?> onCurrencyFilterChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final VoidCallback onClearFilters;

  const _FilterChips({
    required this.selectedCountryFilter,
    required this.selectedCurrencyFilter,
    required this.selectedDateRange,
    required this.onCountryFilterChanged,
    required this.onCurrencyFilterChanged,
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
                           widget.selectedCurrencyFilter != null ||
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
            
            if (widget.selectedCurrencyFilter != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  label: Text('Currency: ${widget.selectedCurrencyFilter}'),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => widget.onCurrencyFilterChanged(null),
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
  final String? currencyFilter;
  final DateTimeRange? dateRange;
  final String sortBy;
  final bool ascending;

  const _EntriesList({
    this.vehicleFilter,
    required this.searchQuery,
    this.countryFilter,
    this.currencyFilter,
    this.dateRange,
    required this.sortBy,
    required this.ascending,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use different providers based on whether we're filtering by vehicle
    if (vehicleFilter != null) {
      return _buildVehicleFilteredEntries(context, ref);
    } else {
      return _buildAllEntries(context, ref);
    }
  }

  Widget _buildAllEntries(BuildContext context, WidgetRef ref) {
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
                       currencyFilter != null ||
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
              final primaryCurrency = ref.watch(primaryCurrencyProvider);
              return MultiCurrencyFuelEntryCard(
                entry: entries[index],
                primaryCurrency: primaryCurrency,
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(context, error.toString(), ref),
    );
  }

  Widget _buildVehicleFilteredEntries(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(fuelEntriesByVehicleProvider(vehicleFilter!));

    return entriesAsync.when(
      data: (entries) {
        // Apply remaining filters (excluding vehicle filter since it's already applied)
        final filteredEntries = _applyNonVehicleFilters(entries);

        // Apply sorting
        final sortedEntries = _applySorting(filteredEntries);

        if (sortedEntries.isEmpty) {
          return _EmptyEntriesState(
            hasFilters: searchQuery.isNotEmpty ||
                       countryFilter != null ||
                       currencyFilter != null ||
                       dateRange != null ||
                       vehicleFilter != null,
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await ref.refresh(fuelEntriesByVehicleProvider(vehicleFilter!).future);
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sortedEntries.length,
            itemBuilder: (context, index) {
              final primaryCurrency = ref.watch(primaryCurrencyProvider);
              return MultiCurrencyFuelEntryCard(
                entry: sortedEntries[index],
                primaryCurrency: primaryCurrency,
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
               entry.formattedPrice.toLowerCase().contains(query) ||
               entry.currency.toLowerCase().contains(query);
      }).toList();
    }

    // Country filter
    if (countryFilter != null) {
      filtered = filtered.where((entry) => entry.country == countryFilter).toList();
    }

    // Currency filter
    if (currencyFilter != null) {
      filtered = filtered.where((entry) => entry.currency == currencyFilter).toList();
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

  List<FuelEntryModel> _applyNonVehicleFilters(List<FuelEntryModel> entries) {
    var filtered = entries;

    // Search query filter
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((entry) {
        return entry.country.toLowerCase().contains(query) ||
               DateFormat('MMM d, yyyy').format(entry.date).toLowerCase().contains(query) ||
               entry.formattedPrice.toLowerCase().contains(query) ||
               entry.currency.toLowerCase().contains(query);
      }).toList();
    }

    // Country filter
    if (countryFilter != null) {
      filtered = filtered.where((entry) => entry.country == countryFilter).toList();
    }

    // Currency filter
    if (currencyFilter != null) {
      filtered = filtered.where((entry) => entry.currency == currencyFilter).toList();
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


/// Filter dialog for advanced filtering
class _FilterDialog extends StatefulWidget {
  final String? selectedCountry;
  final String? selectedCurrency;
  final DateTimeRange? selectedDateRange;
  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onCurrencyChanged;
  final ValueChanged<DateTimeRange?> onDateRangeChanged;
  final VoidCallback onClearFilters;

  const _FilterDialog({
    required this.selectedCountry,
    required this.selectedCurrency,
    required this.selectedDateRange,
    required this.onCountryChanged,
    required this.onCurrencyChanged,
    required this.onDateRangeChanged,
    required this.onClearFilters,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late String? _selectedCountry;
  late String? _selectedCurrency;
  late DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.selectedCountry;
    _selectedCurrency = widget.selectedCurrency;
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
            
            // Currency filter
            Text(
              'Currency',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Consumer(
              builder: (context, ref, child) {
                final availableCurrencies = ref.watch(availableCurrenciesProvider);
                return DropdownButtonFormField<String>(
                  value: _selectedCurrency,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'All currencies',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All currencies'),
                    ),
                    ...availableCurrencies.map((currency) => DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrency = value;
                    });
                  },
                );
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
            widget.onCurrencyChanged(_selectedCurrency);
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

