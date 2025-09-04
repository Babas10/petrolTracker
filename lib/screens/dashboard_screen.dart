import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petrol_tracker/navigation/main_layout.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/units_providers.dart';
import 'package:petrol_tracker/services/chart_data_service.dart';
import 'package:petrol_tracker/widgets/chart_webview.dart';
import 'package:petrol_tracker/providers/chart_providers.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';

/// Dashboard screen displaying charts overview and key metrics
/// 
/// Features:
/// - Interactive D3.js charts via WebView
/// - Real-time data from ephemeral storage
/// - Fuel consumption and cost analysis
/// - Recent entries summary
/// - Quick statistics
/// - Vehicle selector for dynamic data switching
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  VehicleModel? _selectedVehicle;
  bool _hasInitializedVehicle = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavAppBar(
        title: 'Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(fuelEntriesNotifierProvider);
              ref.invalidate(vehiclesNotifierProvider);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVehicleSelector(),
            const SizedBox(height: 16),
            _QuickStatsRow(ref: ref, selectedVehicle: _selectedVehicle),
            const SizedBox(height: 16),
            _ChartSection(ref: ref, selectedVehicle: _selectedVehicle),
            const SizedBox(height: 16),
            _AverageConsumptionSection(ref: ref, selectedVehicle: _selectedVehicle),
            const SizedBox(height: 16),
            _CostAnalysisSection(ref: ref, selectedVehicle: _selectedVehicle),
            const SizedBox(height: 16),
            _RecentEntriesSection(ref: ref, selectedVehicle: _selectedVehicle),
          ],
        ),
      ),
    );
  }
}

/// Quick statistics row showing key metrics
class _QuickStatsRow extends ConsumerWidget {
  final WidgetRef ref;
  final VehicleModel? selectedVehicle;
  
  const _QuickStatsRow({required this.ref, this.selectedVehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleState = ref.watch(vehiclesNotifierProvider);
    
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_gas_station,
            title: selectedVehicle != null ? 'Vehicle Entries' : 'Total Entries',
            value: selectedVehicle != null
                ? _buildVehicleEntryCount(ref)
                : _buildTotalEntryCount(ref),
            subtitle: 'fuel entries',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.directions_car,
            title: 'Vehicles',
            value: vehicleState.when(
              data: (state) => state.vehicles.length.toString(),
              loading: () => '...',
              error: (_, __) => 'Error',
            ),
            subtitle: 'registered',
          ),
        ),
      ],
    );
  }

  String _buildVehicleEntryCount(WidgetRef ref) {
    if (selectedVehicle?.id == null) return '0';
    
    final entriesAsync = ref.watch(fuelEntriesByVehicleProvider(selectedVehicle!.id!));
    return entriesAsync.when(
      data: (entries) => entries.length.toString(),
      loading: () => '...',
      error: (_, __) => 'Error',
    );
  }

  String _buildTotalEntryCount(WidgetRef ref) {
    final fuelEntryState = ref.watch(fuelEntriesNotifierProvider);
    return fuelEntryState.when(
      data: (state) => state.entries.length.toString(),
      loading: () => '...',
      error: (_, __) => 'Error',
    );
  }
}

/// Individual statistics card
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Charts section with interactive D3.js charts
class _ChartSection extends ConsumerWidget {
  final WidgetRef ref;
  final VehicleModel? selectedVehicle;
  
  const _ChartSection({required this.ref, this.selectedVehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (selectedVehicle == null) {
      return _buildNoVehicleSelectedCard(context);
    }
    
    final vehicleEntriesAsync = ref.watch(fuelEntriesByVehicleProvider(selectedVehicle!.id!));
    final unitSystem = ref.watch(unitsProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Consumption Chart - ${selectedVehicle!.name}',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.go('/consumption-chart'),
                  icon: const Icon(Icons.open_in_full, size: 16),
                  label: const Text('View Chart'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: vehicleEntriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return _buildEmptyChartPlaceholder(context);
                  }
                  
                  // Transform data for chart
                  final rawChartData = ChartDataService.transformConsumptionData(
                    entries.where((e) => e.consumption != null).toList(),
                  );
                  
                  if (rawChartData.isEmpty) {
                    return _buildNoConsumptionDataPlaceholder(context);
                  }
                  
                  // Optimize for dashboard display (max 5 points)
                  final chartData = ChartDataService.optimizeForDashboard(
                    rawChartData,
                    maxPoints: 5,
                  );
                  
                  return unitSystem.when(
                    data: (units) => ChartWebView(
                      data: chartData.toChartData(),
                      config: ChartConfig(
                        type: ChartType.area,
                        title: 'Fuel Consumption Over Time',
                        xLabel: 'Date',
                        yLabel: 'Consumption (${units.consumptionUnit})',
                        unit: units.consumptionUnit,
                        className: 'consumption',
                      ),
                      onChartEvent: (eventType, data) {
                        _handleChartEvent(context, eventType, data);
                      },
                      onError: (error) {
                        debugPrint('Chart error: $error');
                      },
                    ),
                    loading: () => _buildLoadingPlaceholder(context),
                    error: (_, __) => ChartWebView(
                      data: chartData.toChartData(),
                      config: const ChartConfig(
                        type: ChartType.area,
                        title: 'Fuel Consumption Over Time',
                        xLabel: 'Date',
                        yLabel: 'Consumption (L/100km)',
                        unit: 'L/100km',
                        className: 'consumption',
                      ),
                      onChartEvent: (eventType, data) {
                        _handleChartEvent(context, eventType, data);
                      },
                      onError: (error) {
                        debugPrint('Chart error: $error');
                      },
                    ),
                  );
                },
                loading: () => _buildLoadingPlaceholder(context),
                error: (error, stack) => _buildErrorPlaceholder(context, error.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyChartPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'No fuel entries yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add fuel entries to see visualizations',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNoConsumptionDataPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'No consumption data available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Consumption is calculated automatically from consecutive entries',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
  
  Widget _buildErrorPlaceholder(BuildContext context, String error) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 8),
          Text(
            'Error loading chart',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  void _handleChartEvent(BuildContext context, String eventType, Map<String, dynamic> data) {
    switch (eventType) {
      case 'dataPointClicked':
        _showDataPointDetails(context, data);
        break;
      case 'chartRendered':
        debugPrint('Chart rendered with ${data['dataPoints']} data points');
        break;
      case 'retryRequested':
        ref.invalidate(fuelEntriesNotifierProvider);
        break;
    }
  }
  
  void _showDataPointDetails(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entry Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data['date'] != null) Text('Date: ${data['date']}'),
            if (data['value'] != null) Text('Consumption: ${data['value']} L/100km'),
            if (data['fuelAmount'] != null) Text('Fuel Amount: ${data['fuelAmount']}L'),
            if (data['currentKm'] != null) Text('Odometer: ${data['currentKm']} km'),
          ],
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
  
  Widget _buildConsumptionStatisticsPreview(BuildContext context, WidgetRef ref, int vehicleId) {
    final statisticsAsync = ref.watch(consumptionStatisticsProvider(
      vehicleId,
      countryFilter: null, // Show all countries on dashboard
    ));
    final unitSystem = ref.watch(unitsProvider);
    
    return statisticsAsync.when(
      data: (stats) {
        return unitSystem.when(
          data: (units) {
            // Convert consumption values if needed
            final averageConsumption = stats['average'] as double?;
            final minimumConsumption = stats['minimum'] as double?;
            
            final displayAverage = averageConsumption != null 
                ? (units == UnitSystem.metric 
                    ? averageConsumption 
                    : UnitConverter.consumptionToImperial(averageConsumption))
                : null;
                
            final displayMinimum = minimumConsumption != null 
                ? (units == UnitSystem.metric 
                    ? minimumConsumption 
                    : UnitConverter.consumptionToImperial(minimumConsumption))
                : null;
            
            return Row(
              children: [
                Expanded(
                  child: _buildStatPreviewCard(
                    context,
                    'Overall Average',
                    displayAverage != null 
                        ? '${displayAverage.toStringAsFixed(1)} ${units.consumptionUnit}'
                        : 'N/A',
                    Icons.analytics,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatPreviewCard(
                    context,
                    'Best Efficiency',
                    displayMinimum != null 
                        ? '${displayMinimum.toStringAsFixed(1)} ${units.consumptionUnit}'
                        : 'N/A',
                    Icons.trending_down,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatPreviewCard(
                    context,
                    'Total Entries',
                    '${stats['count']?.toInt()}',
                    Icons.confirmation_num,
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) {
            // Fallback to metric units if units loading fails
            final averageConsumption = stats['average'] as double?;
            final minimumConsumption = stats['minimum'] as double?;
            
            return Row(
              children: [
                Expanded(
                  child: _buildStatPreviewCard(
                    context,
                    'Overall Average',
                    averageConsumption != null 
                        ? '${averageConsumption.toStringAsFixed(1)} L/100km'
                        : 'N/A',
                    Icons.analytics,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatPreviewCard(
                    context,
                    'Best Efficiency',
                    minimumConsumption != null 
                        ? '${minimumConsumption.toStringAsFixed(1)} L/100km'
                        : 'N/A',
                    Icons.trending_down,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatPreviewCard(
                    context,
                    'Total Entries',
                    '${stats['count']?.toInt()}',
                    Icons.confirmation_num,
                  ),
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorPlaceholder(context, 'Error loading statistics'),
    );
  }
  
  Widget _buildStatPreviewCard(BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyVehiclesPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car,
            size: 32,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'No vehicles available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoVehicleSelectedCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text(
                  'Consumption Charts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_car,
                    size: 48,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select a vehicle above to view consumption charts',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent entries section showing latest fuel entries
class _RecentEntriesSection extends ConsumerWidget {
  final WidgetRef ref;
  final VehicleModel? selectedVehicle;
  
  const _RecentEntriesSection({required this.ref, this.selectedVehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuelEntryState = ref.watch(fuelEntriesNotifierProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Entries',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to entries screen
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: fuelEntryState.when(
                data: (state) {
                  if (state.entries.isEmpty) {
                    return _buildEmptyEntriesPlaceholder(context);
                  }
                  
                  final recentEntries = state.entries.take(3).toList();
                  return ListView.separated(
                    itemCount: recentEntries.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final entry = recentEntries[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.local_gas_station,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          '${entry.fuelAmount.toStringAsFixed(1)}L - ${entry.country}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        subtitle: Text(
                          '${entry.date.day}/${entry.date.month}/${entry.date.year} • \$${entry.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        trailing: entry.consumption != null
                            ? Text(
                                '${entry.consumption!.toStringAsFixed(1)} L/100km',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              )
                            : null,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildErrorPlaceholder(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyEntriesPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 32,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'No recent entries',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 32,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 8),
          Text(
            'Error loading entries',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

/// Average consumption section showing period-based statistics
class _AverageConsumptionSection extends ConsumerWidget {
  final WidgetRef ref;
  final VehicleModel? selectedVehicle;
  
  const _AverageConsumptionSection({required this.ref, this.selectedVehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleState = ref.watch(vehiclesNotifierProvider);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Average Consumption by Period',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => context.go('/average-consumption-chart'),
                  icon: const Icon(Icons.open_in_full, size: 18),
                  tooltip: 'Period Analysis',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: selectedVehicle == null
                  ? _buildNoVehicleSelectedForPeriod(context)
                  : _buildAverageConsumptionChart(context, ref, selectedVehicle!.id!),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAverageConsumptionChart(BuildContext context, WidgetRef ref, int vehicleId) {
    final chartDataAsync = ref.watch(periodAverageConsumptionDataProvider(
      vehicleId,
      PeriodType.monthly, // Default to monthly view for dashboard
      countryFilter: null, // Show all countries on dashboard
    ));
    final unitSystem = ref.watch(unitsProvider);
    
    return chartDataAsync.when(
      data: (periodData) {
        if (periodData.isEmpty) {
          return _buildEmptyVehiclesPlaceholder(context);
        }

        return unitSystem.when(
          data: (units) {
            // Optimize data for dashboard display (max 6 monthly points to avoid label overlap)
            final optimizedPeriodData = periodData.length > 6
                ? _optimizePeriodData(periodData, maxPoints: 6)
                : periodData;

            // Transform to chart format with unit conversion
            final chartData = optimizedPeriodData.map((point) => {
              'date': point.date.toIso8601String().split('T')[0],
              'value': units == UnitSystem.metric 
                  ? point.averageConsumption 
                  : UnitConverter.consumptionToImperial(point.averageConsumption),
              'label': point.periodLabel,
              'count': point.entryCount,
            }).toList();

            return ChartWebView(
              data: chartData,
              config: ChartConfig(
                type: ChartType.bar,
                title: 'Average Consumption by Month',
                xLabel: 'Month',
                yLabel: 'Average Consumption (${units.consumptionUnit})',
                unit: units.consumptionUnit,
                className: 'period-average-chart',
              ),
              onChartEvent: (eventType, data) {
                // Handle chart events if needed
                debugPrint('Average consumption chart event: $eventType');
              },
              onError: (error) {
                debugPrint('Average consumption chart error: $error');
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) {
            // Fallback to metric units if units loading fails
            final optimizedPeriodData = periodData.length > 6
                ? _optimizePeriodData(periodData, maxPoints: 6)
                : periodData;

            final chartData = optimizedPeriodData.map((point) => {
              'date': point.date.toIso8601String().split('T')[0],
              'value': point.averageConsumption,
              'label': point.periodLabel,
              'count': point.entryCount,
            }).toList();

            return ChartWebView(
              data: chartData,
              config: const ChartConfig(
                type: ChartType.bar,
                title: 'Average Consumption by Month',
                xLabel: 'Month',
                yLabel: 'Average Consumption (L/100km)',
                unit: 'L/100km',
                className: 'period-average-chart',
              ),
              onChartEvent: (eventType, data) {
                debugPrint('Average consumption chart event: $eventType');
              },
              onError: (error) {
                debugPrint('Average consumption chart error: $error');
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorPlaceholder(context),
    );
  }

  /// Optimize period data for dashboard display by showing the most recent periods
  List<dynamic> _optimizePeriodData(List<dynamic> data, {required int maxPoints}) {
    if (data.length <= maxPoints) {
      return data;
    }

    // For dashboard display, show the most recent periods (months)
    // This gives users the latest trend which is most relevant for dashboard
    return data.length > maxPoints
        ? data.sublist(data.length - maxPoints)
        : data;
  }
  
  Widget _buildStatPreviewCard(BuildContext context, String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyVehiclesPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car,
            size: 32,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 8),
          Text(
            'No vehicles available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorPlaceholder(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 32,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 8),
          Text(
            'Error loading statistics',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoVehicleSelectedForPeriod(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a vehicle above to view period analysis',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Cost analysis section showing spending overview and quick access
class _CostAnalysisSection extends ConsumerWidget {
  final WidgetRef ref;
  final VehicleModel? selectedVehicle;
  
  const _CostAnalysisSection({required this.ref, this.selectedVehicle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
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
                  'Cost Analysis',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.go('/cost-analysis'),
                  icon: const Icon(Icons.analytics, size: 16),
                  label: const Text('Full Analysis'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            selectedVehicle == null
                ? _buildNoVehicleSelectedForCost(context)
                : _buildCostPreview(context, ref, selectedVehicle!),
          ],
        ),
      ),
    );
  }

  Widget _buildCostPreview(BuildContext context, WidgetRef ref, VehicleModel vehicle) {
    final statisticsAsync = ref.watch(spendingStatisticsProvider(vehicle.id!));
    
    return statisticsAsync.when(
      data: (stats) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildCostStatCard(
                    context,
                    'Total Spent',
                    '\$${stats['totalSpent'].toStringAsFixed(0)}',
                    Icons.payments,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCostStatCard(
                    context,
                    'Avg per Fill-up',
                    '\$${stats['averagePerFillUp'].toStringAsFixed(0)}',
                    Icons.local_gas_station,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCostStatCard(
                    context,
                    'Monthly Avg',
                    '\$${stats['averagePerMonth'].toStringAsFixed(0)}',
                    Icons.calendar_month,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCostStatCard(
                    context,
                    'Countries',
                    '${stats['totalCountries']}',
                    Icons.public,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Most Expensive: ${stats['mostExpensiveCountry']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Cheapest: ${stats['cheapestCountry']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Based on ${stats['totalFillUps']} fill-ups',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildCostErrorPlaceholder(context),
    );
  }

  Widget _buildCostStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
    );
  }

  Widget _buildNoVehiclesMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Add a vehicle to see cost analysis',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostErrorPlaceholder(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 24,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 4),
            Text(
              'Error loading cost data',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoVehicleSelectedForCost(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Select a vehicle above to view cost analysis',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

extension _DashboardScreenStateExtension on _DashboardScreenState {
  Widget _buildVehicleSelector() {
    final vehiclesState = ref.watch(vehiclesNotifierProvider);
    
    return vehiclesState.when(
      data: (vehicleState) {
        final vehicles = vehicleState.vehicles;
        
        if (vehicles.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_car,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "No vehicles available",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Auto-select first vehicle if not initialized
        if (!_hasInitializedVehicle && vehicles.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _selectedVehicle = vehicles.first;
              _hasInitializedVehicle = true;
            });
          });
        }

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
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Selected Vehicle",
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<VehicleModel>(
                  value: _selectedVehicle,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    prefixIcon: const Icon(Icons.directions_car, size: 18),
                    fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    filled: true,
                  ),
                  items: vehicles.map((vehicle) => DropdownMenuItem<VehicleModel>(
                    value: vehicle,
                    child: Text(
                      vehicle.name,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )).toList(),
                  onChanged: (vehicle) {
                    setState(() {
                      _selectedVehicle = vehicle;
                    });
                  },
                  hint: Text(
                    "Select a vehicle to view its data",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text(
                "Loading vehicles...",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Error loading vehicles: \$error",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
