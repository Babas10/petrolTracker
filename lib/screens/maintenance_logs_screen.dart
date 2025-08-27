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

/// Maintenance logs screen showing all maintenance activities
/// 
/// Features:
/// - List of all maintenance logs chronologically
/// - Filter by vehicle, category, date range
/// - Search functionality
/// - Maintenance statistics overview
/// - Quick add maintenance log action
class MaintenanceLogsScreen extends ConsumerStatefulWidget {
  final int? vehicleFilter;

  const MaintenanceLogsScreen({
    super.key,
    this.vehicleFilter,
  });

  @override
  ConsumerState<MaintenanceLogsScreen> createState() => _MaintenanceLogsScreenState();
}

class _MaintenanceLogsScreenState extends ConsumerState<MaintenanceLogsScreen> {
  VehicleModel? _selectedVehicle;
  MaintenanceCategoryModel? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeFilters() {
    // If a vehicle filter is provided, try to set it as selected
    if (widget.vehicleFilter != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadVehicleFilter();
      });
    }
  }

  Future<void> _loadVehicleFilter() async {
    try {
      final vehiclesAsync = ref.read(vehiclesNotifierProvider);
      vehiclesAsync.whenData((vehiclesState) {
        final vehicle = vehiclesState.vehicles.firstWhere(
          (v) => v.id == widget.vehicleFilter,
          orElse: () => vehiclesState.vehicles.first,
        );
        setState(() {
          _selectedVehicle = vehicle;
        });
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavAppBar(
        title: 'Maintenance Logs',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    Icon(Icons.filter_list),
                    SizedBox(width: 8),
                    Text('Filter'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'categories',
                child: Row(
                  children: [
                    Icon(Icons.category),
                    SizedBox(width: 8),
                    Text('Manage Categories'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltersRow(),
          _buildStatsCard(),
          Expanded(child: _buildMaintenanceLogsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMaintenanceDialog(),
        child: const Icon(Icons.add),
        tooltip: 'Add Maintenance Log',
      ),
    );
  }

  Widget _buildFiltersRow() {
    if (_selectedVehicle == null && _selectedCategory == null && _searchQuery.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedVehicle != null)
            Chip(
              label: Text(_selectedVehicle!.name),
              onDeleted: () => setState(() => _selectedVehicle = null),
              avatar: const Icon(Icons.directions_car, size: 18),
            ),
          if (_selectedCategory != null)
            Chip(
              label: Text(_selectedCategory!.name),
              onDeleted: () => setState(() => _selectedCategory = null),
              avatar: Icon(_selectedCategory!.icon, size: 18),
            ),
          if (_searchQuery.isNotEmpty)
            Chip(
              label: Text('Search: $_searchQuery'),
              onDeleted: () => setState(() {
                _searchQuery = '';
                _searchController.clear();
              }),
              avatar: const Icon(Icons.search, size: 18),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_selectedVehicle == null) {
      return const SizedBox.shrink();
    }

    final statsAsync = ref.watch(maintenanceStatisticsProvider(_selectedVehicle!.id!));

    return statsAsync.when(
      data: (stats) => Container(
        margin: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Logs',
                  '${stats['totalLogs']}',
                  Icons.build,
                ),
                _buildStatItem(
                  'Total Cost',
                  '\$${(stats['totalCosts'] as double).toStringAsFixed(2)}',
                  Icons.attach_money,
                ),
                _buildStatItem(
                  'Avg Cost',
                  '\$${(stats['averageCostPerLog'] as double).toStringAsFixed(2)}',
                  Icons.trending_up,
                ),
              ],
            ),
          ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildMaintenanceLogsList() {
    final logsAsync = _selectedVehicle != null 
      ? ref.watch(maintenanceLogsByVehicleProvider(_selectedVehicle!.id!))
      : ref.watch(maintenanceLogsProvider);

    return logsAsync.when(
      data: (logs) {
        final filteredLogs = _filterLogs(logs);
        
        if (filteredLogs.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredLogs.length,
          itemBuilder: (context, index) => _buildMaintenanceLogCard(filteredLogs[index]),
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
              'Failed to load maintenance logs',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(maintenanceLogsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  List<MaintenanceLogModel> _filterLogs(List<MaintenanceLogModel> logs) {
    return logs.where((log) {
      // Vehicle filter is already applied by the provider
      
      // Category filter
      if (_selectedCategory != null && log.categoryId != _selectedCategory!.id) {
        return false;
      }
      
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return log.title.toLowerCase().contains(query) ||
               (log.description?.toLowerCase().contains(query) ?? false) ||
               (log.serviceProvider?.toLowerCase().contains(query) ?? false);
      }
      
      return true;
    }).toList();
  }

  Widget _buildMaintenanceLogCard(MaintenanceLogModel log) {
    final categoriesAsync = ref.watch(maintenanceCategoriesProvider);
    
    return categoriesAsync.when(
      data: (categories) {
        final category = categories.firstWhere(
          (c) => c.id == log.categoryId,
          orElse: () => MaintenanceCategoryModel(
            id: 0,
            name: 'Unknown',
            iconName: 'build',
            color: '#757575',
            createdAt: DateTime.now(),
          ),
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: category.colorValue.withOpacity(0.1),
              child: Icon(
                category.icon,
                color: category.colorValue,
                size: 20,
              ),
            ),
            title: Text(
              log.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${DateFormat.yMMMd().format(log.serviceDate)} • ${log.odometerReading.toStringAsFixed(0)} km',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (log.serviceProvider?.isNotEmpty == true)
                  Text(
                    log.serviceProvider!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${log.totalCost.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  log.currency,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            onTap: () => _showMaintenanceLogDetails(log),
          ),
        );
      },
      loading: () => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.build)),
          title: Text(log.title),
          subtitle: Text(DateFormat.yMMMd().format(log.serviceDate)),
          trailing: Text('\$${log.totalCost.toStringAsFixed(2)}'),
        ),
      ),
      error: (_, __) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.error)),
          title: Text(log.title),
          subtitle: const Text('Failed to load category'),
          trailing: Text('\$${log.totalCost.toStringAsFixed(2)}'),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.build_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No maintenance logs found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first maintenance log to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddMaintenanceDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Maintenance Log'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Maintenance Logs'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search by title, description, or provider...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchQuery = _searchController.text;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showAddMaintenanceDialog() {
    // Navigate to add maintenance screen with optional vehicle filter
    if (_selectedVehicle != null) {
      context.push('/add-maintenance', extra: {'vehicleId': _selectedVehicle!.id});
    } else {
      context.push('/add-maintenance');
    }
  }

  void _showMaintenanceLogDetails(MaintenanceLogModel log) {
    final categoriesAsync = ref.read(maintenanceCategoriesProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.build, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                log.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Category
                categoriesAsync.when(
                  data: (categories) {
                    final category = categories.firstWhere(
                      (c) => c.id == log.categoryId,
                      orElse: () => MaintenanceCategoryModel(
                        id: 0,
                        name: 'Unknown',
                        iconName: 'build',
                        color: '#757575',
                        createdAt: DateTime.now(),
                      ),
                    );
                    return _buildDetailRow(
                      'Category',
                      category.name,
                      Icons.category,
                    );
                  },
                  loading: () => _buildDetailRow('Category', 'Loading...', Icons.category),
                  error: (_, __) => _buildDetailRow('Category', 'Unknown', Icons.category),
                ),
                
                // Service Date
                _buildDetailRow(
                  'Service Date',
                  DateFormat.yMMMd().format(log.serviceDate),
                  Icons.calendar_today,
                ),
                
                // Odometer Reading
                _buildDetailRow(
                  'Odometer',
                  '${log.odometerReading.toStringAsFixed(0)} km',
                  Icons.speed,
                ),
                
                // Cost
                _buildDetailRow(
                  'Total Cost',
                  '${log.currency} \$${log.totalCost.toStringAsFixed(2)}',
                  Icons.attach_money,
                ),
                
                // Service Provider (if available)
                if (log.serviceProvider?.isNotEmpty == true)
                  _buildDetailRow(
                    'Service Provider',
                    log.serviceProvider!,
                    Icons.store,
                  ),
                
                // Description (if available)
                if (log.description?.isNotEmpty == true)
                  _buildDetailSection(
                    'Description',
                    log.description!,
                    Icons.description,
                  ),
                
                // Notes (if available)
                if (log.notes?.isNotEmpty == true)
                  _buildDetailSection(
                    'Notes',
                    log.notes!,
                    Icons.notes,
                  ),
                
                const SizedBox(height: 16),
                
                // Created/Updated info
                Text(
                  'Created: ${DateFormat.yMMMd().add_jm().format(log.createdAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'filter':
        _showFilterDialog();
        break;
      case 'categories':
        context.go('/maintenance-categories');
        break;
      case 'refresh':
        ref.refresh(maintenanceLogsProvider);
        if (_selectedVehicle != null) {
          ref.refresh(maintenanceLogsByVehicleProvider(_selectedVehicle!.id!));
          ref.refresh(maintenanceStatisticsProvider(_selectedVehicle!.id!));
        }
        break;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Maintenance Logs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Vehicle filter
            Consumer(
              builder: (context, ref, child) {
                final vehiclesAsync = ref.watch(vehiclesNotifierProvider);
                return vehiclesAsync.when(
                  data: (vehiclesState) => DropdownButtonFormField<VehicleModel?>(
                    value: _selectedVehicle,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<VehicleModel?>(
                        value: null,
                        child: Text('All Vehicles'),
                      ),
                      ...vehiclesState.vehicles.map((vehicle) => DropdownMenuItem(
                        value: vehicle,
                        child: Text(vehicle.name),
                      )),
                    ],
                    onChanged: (vehicle) => setState(() => _selectedVehicle = vehicle),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Error loading vehicles'),
                );
              },
            ),
            const SizedBox(height: 16),
            // Category filter
            Consumer(
              builder: (context, ref, child) {
                final categoriesAsync = ref.watch(maintenanceCategoriesProvider);
                return categoriesAsync.when(
                  data: (categories) => DropdownButtonFormField<MaintenanceCategoryModel?>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<MaintenanceCategoryModel?>(
                        value: null,
                        child: Text('All Categories'),
                      ),
                      ...categories.map((category) => DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(category.icon, size: 20),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      )),
                    ],
                    onChanged: (category) => setState(() => _selectedCategory = category),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (_, __) => const Text('Error loading categories'),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedVehicle = null;
                _selectedCategory = null;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}