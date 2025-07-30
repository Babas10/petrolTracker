import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petrol_tracker/navigation/main_layout.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/services/chart_data_service.dart';
import 'package:petrol_tracker/widgets/chart_webview.dart';
import 'package:petrol_tracker/providers/chart_providers.dart';

/// Dashboard screen displaying charts overview and key metrics
/// 
/// Features:
/// - Interactive D3.js charts via WebView
/// - Real-time data from ephemeral storage
/// - Fuel consumption and cost analysis
/// - Recent entries summary
/// - Quick statistics
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            const _WelcomeCard(),
            const SizedBox(height: 16),
            _QuickStatsRow(ref: ref),
            const SizedBox(height: 16),
            _ChartSection(ref: ref),
            const SizedBox(height: 16),
            _AverageConsumptionSection(ref: ref),
            const SizedBox(height: 16),
            _RecentEntriesSection(ref: ref),
          ],
        ),
      ),
    );
  }
}

/// Welcome card showing user greeting and quick overview
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

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
                  Icons.dashboard,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Welcome to Dashboard',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Monitor your fuel consumption and track spending patterns',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick statistics row showing key metrics
class _QuickStatsRow extends ConsumerWidget {
  final WidgetRef ref;
  
  const _QuickStatsRow({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleState = ref.watch(vehiclesNotifierProvider);
    final fuelEntryState = ref.watch(fuelEntriesNotifierProvider);
    
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_gas_station,
            title: 'Total Entries',
            value: fuelEntryState.when(
              data: (state) => state.entries.length.toString(),
              loading: () => '...',
              error: (_, __) => 'Error',
            ),
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
  
  const _ChartSection({required this.ref});

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
              children: [
                Icon(
                  Icons.bar_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Consumption Charts',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.go('/consumption-chart'),
                  icon: const Icon(Icons.open_in_full, size: 16),
                  label: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: fuelEntryState.when(
                data: (state) {
                  if (state.entries.isEmpty) {
                    return _buildEmptyChartPlaceholder(context);
                  }
                  
                  // Transform data for chart
                  final chartData = ChartDataService.transformConsumptionData(
                    state.entries.where((e) => e.consumption != null).toList(),
                  );
                  
                  if (chartData.isEmpty) {
                    return _buildNoConsumptionDataPlaceholder(context);
                  }
                  
                  return ChartWebView(
                    data: chartData.toChartData(),
                    config: const ChartConfig(
                      type: ChartType.line,
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
}

/// Recent entries section showing latest fuel entries
class _RecentEntriesSection extends ConsumerWidget {
  final WidgetRef ref;
  
  const _RecentEntriesSection({required this.ref});

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
  
  const _AverageConsumptionSection({required this.ref});

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
                Text(
                  'Average Consumption by Period',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.go('/average-consumption-chart'),
                  icon: const Icon(Icons.open_in_full, size: 16),
                  label: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: vehicleState.when(
                data: (state) {
                  if (state.vehicles.isEmpty) {
                    return _buildEmptyVehiclesPlaceholder(context);
                  }
                  
                  // Show statistics for the first vehicle as a preview
                  final firstVehicle = state.vehicles.first;
                  if (firstVehicle.id == null) {
                    return _buildEmptyVehiclesPlaceholder(context);
                  }
                  
                  return _buildAverageConsumptionPreview(context, ref, firstVehicle.id!);
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
  
  Widget _buildAverageConsumptionPreview(BuildContext context, WidgetRef ref, int vehicleId) {
    final statisticsAsync = ref.watch(consumptionStatisticsProvider(vehicleId));
    
    return statisticsAsync.when(
      data: (stats) {
        return Row(
          children: [
            Expanded(
              child: _buildStatPreviewCard(
                context,
                'Overall Average',
                '${stats['average']?.toStringAsFixed(1)} L/100km',
                Icons.analytics,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatPreviewCard(
                context,
                'Best Efficiency',
                '${stats['minimum']?.toStringAsFixed(1)} L/100km',
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
      error: (error, stack) => _buildErrorPlaceholder(context),
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
}