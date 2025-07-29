import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/navigation/main_layout.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/chart_providers.dart';
import 'package:petrol_tracker/widgets/chart_webview.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';

/// Dedicated screen for fuel consumption over time visualization
/// 
/// Features:
/// - Interactive consumption charts with D3.js/fl_chart
/// - Vehicle selection and date range filtering  
/// - Statistical analysis and insights
/// - Multiple chart types (line, area, bar)
/// - Export and sharing capabilities
class FuelConsumptionChartScreen extends ConsumerStatefulWidget {
  const FuelConsumptionChartScreen({super.key});

  @override
  ConsumerState<FuelConsumptionChartScreen> createState() => _FuelConsumptionChartScreenState();
}

class _FuelConsumptionChartScreenState extends ConsumerState<FuelConsumptionChartScreen> {
  VehicleModel? _selectedVehicle;
  ChartType _selectedChartType = ChartType.line;
  DateTimeRange? _selectedDateRange;
  bool _showStatistics = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavAppBar(
        title: 'Fuel Consumption Analysis',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showChartSettings,
            tooltip: 'Chart Settings',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildControlPanel(),
          Expanded(
            child: _buildChartContent(),
          ),
          if (_showStatistics) _buildStatisticsPanel(),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildVehicleSelector()),
              const SizedBox(width: 16),
              Expanded(child: _buildChartTypeSelector()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDateRangeSelector()),
              const SizedBox(width: 16),
              _buildActionButtons(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSelector() {
    final vehiclesState = ref.watch(vehiclesNotifierProvider);
    
    return vehiclesState.when(
      data: (vehicleState) {
        final vehicles = vehicleState.vehicles;
        
        if (vehicles.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                'No vehicles available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          );
        }

        return DropdownButtonFormField<VehicleModel>(
          value: _selectedVehicle,
          decoration: const InputDecoration(
            labelText: 'Select Vehicle',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem<VehicleModel>(
              value: null,
              child: Text('All Vehicles'),
            ),
            ...vehicles.map((vehicle) => DropdownMenuItem<VehicleModel>(
              value: vehicle,
              child: Text(vehicle.name),
            )),
          ],
          onChanged: (vehicle) {
            setState(() {
              _selectedVehicle = vehicle;
            });
          },
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildChartTypeSelector() {
    return DropdownButtonFormField<ChartType>(
      value: _selectedChartType,
      decoration: const InputDecoration(
        labelText: 'Chart Type',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: const [
        DropdownMenuItem(
          value: ChartType.line,
          child: Row(
            children: [
              Icon(Icons.show_chart, size: 16),
              SizedBox(width: 8),
              Text('Line Chart'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: ChartType.area,
          child: Row(
            children: [
              Icon(Icons.area_chart, size: 16),
              SizedBox(width: 8),
              Text('Area Chart'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: ChartType.bar,
          child: Row(
            children: [
              Icon(Icons.bar_chart, size: 16),
              SizedBox(width: 8),
              Text('Bar Chart'),
            ],
          ),
        ),
      ],
      onChanged: (chartType) {
        if (chartType != null) {
          setState(() {
            _selectedChartType = chartType;
          });
        }
      },
    );
  }

  Widget _buildDateRangeSelector() {
    return OutlinedButton.icon(
      onPressed: _selectDateRange,
      icon: const Icon(Icons.date_range, size: 16),
      label: Text(
        _selectedDateRange == null
            ? 'All Time'
            : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 40),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _clearFilters,
          icon: const Icon(Icons.clear),
          tooltip: 'Clear Filters',
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _showStatistics = !_showStatistics;
            });
          },
          icon: Icon(_showStatistics ? Icons.analytics : Icons.analytics_outlined),
          tooltip: 'Toggle Statistics',
        ),
      ],
    );
  }

  Widget _buildChartContent() {
    if (_selectedVehicle == null) {
      return _buildMultiVehicleChart();
    } else {
      return _buildSingleVehicleChart();
    }
  }

  Widget _buildSingleVehicleChart() {
    final chartDataAsync = ref.watch(consumptionChartDataProvider(
      _selectedVehicle!.id!,
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
    ));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timeline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Consumption Over Time - ${_selectedVehicle!.name}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: chartDataAsync.when(
                  data: (consumptionData) {
                    if (consumptionData.isEmpty) {
                      return _buildEmptyChartPlaceholder();
                    }

                    // Transform to chart format
                    final chartData = consumptionData.map((point) => {
                      'date': point.date.toIso8601String().split('T')[0],
                      'value': point.consumption,
                      'km': point.kilometers,
                    }).toList();

                    return ChartWebView(
                      data: chartData,
                      config: ChartConfig(
                        type: _selectedChartType,
                        title: 'Fuel Consumption Trend',
                        xLabel: 'Date',
                        yLabel: 'Consumption (L/100km)',
                        unit: 'L/100km',
                        className: 'consumption-chart',
                      ),
                      onChartEvent: _handleChartEvent,
                      onError: (error) {
                        debugPrint('Chart error: $error');
                      },
                    );
                  },
                  loading: () => _buildLoadingPlaceholder(),
                  error: (error, stack) => _buildErrorPlaceholder(error.toString()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultiVehicleChart() {
    final vehiclesState = ref.watch(vehiclesNotifierProvider);
    
    return vehiclesState.when(
      data: (vehicleState) {
        if (vehicleState.vehicles.isEmpty) {
          return _buildNoVehiclesPlaceholder();
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.compare,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vehicle Consumption Comparison',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildVehicleComparisonChart(vehicleState.vehicles),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => _buildLoadingPlaceholder(),
      error: (error, stack) => _buildErrorPlaceholder(error.toString()),
    );
  }

  Widget _buildVehicleComparisonChart(List<VehicleModel> vehicles) {
    // For now, show individual charts for each vehicle
    // TODO: Implement multi-series chart when provider supports it
    return ListView.separated(
      itemCount: vehicles.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        if (vehicle.id == null) return const SizedBox();
        
        final chartDataAsync = ref.watch(consumptionChartDataProvider(
          vehicle.id!,
          startDate: _selectedDateRange?.start,
          endDate: _selectedDateRange?.end,
        ));

        return SizedBox(
          height: 200,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.name,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: chartDataAsync.when(
                      data: (consumptionData) {
                        if (consumptionData.isEmpty) {
                          return _buildMiniEmptyPlaceholder();
                        }

                        final chartData = consumptionData.map((point) => {
                          'date': point.date.toIso8601String().split('T')[0],
                          'value': point.consumption,
                        }).toList();

                        return ChartWebView(
                          data: chartData,
                          config: ChartConfig(
                            type: ChartType.line,
                            xLabel: 'Date',
                            yLabel: 'L/100km',
                            unit: 'L/100km',
                            className: 'mini-consumption-chart',
                          ),
                          height: 150,
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => Center(
                        child: Text('Error: ${error.toString()}'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsPanel() {
    if (_selectedVehicle == null) {
      return _buildOverallStatistics();
    } else {
      return _buildVehicleStatistics();
    }
  }

  Widget _buildVehicleStatistics() {
    final chartDataAsync = ref.watch(consumptionChartDataProvider(
      _selectedVehicle!.id!,
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
    ));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: chartDataAsync.when(
        data: (consumptionData) {
          if (consumptionData.isEmpty) {
            return Text(
              'No consumption data available for statistics',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            );
          }

          final consumptions = consumptionData.map((d) => d.consumption).toList();
          final average = consumptions.reduce((a, b) => a + b) / consumptions.length;
          final minConsumption = consumptions.reduce((a, b) => a < b ? a : b);
          final maxConsumption = consumptions.reduce((a, b) => a > b ? a : b);
          final totalDistance = consumptionData.isNotEmpty 
              ? consumptionData.last.kilometers - consumptionData.first.kilometers
              : 0.0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consumption Statistics',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStatCard('Average', '${average.toStringAsFixed(1)} L/100km', Icons.analytics),
                  _buildStatCard('Best', '${minConsumption.toStringAsFixed(1)} L/100km', Icons.trending_down),
                  _buildStatCard('Worst', '${maxConsumption.toStringAsFixed(1)} L/100km', Icons.trending_up),
                  _buildStatCard('Distance', '${totalDistance.toStringAsFixed(0)} km', Icons.route),
                ],
              ),
            ],
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (error, stack) => Text('Statistics error: $error'),
      ),
    );
  }

  Widget _buildOverallStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overall Statistics',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Select a specific vehicle to see detailed consumption statistics',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Placeholder widgets
  Widget _buildEmptyChartPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No consumption data available',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add more fuel entries to see consumption trends',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniEmptyPlaceholder() {
    return Center(
      child: Text(
        'No data',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }

  Widget _buildNoVehiclesPlaceholder() {
    return Center(
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
            'No vehicles found',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a vehicle first to track fuel consumption',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading chart data...'),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading chart',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  // Event handlers
  void _handleChartEvent(String eventType, Map<String, dynamic> data) {
    switch (eventType) {
      case 'hover':
        // Show detailed tooltip
        break;
      case 'click':
        // Navigate to detailed entry view
        break;
      default:
        debugPrint('Unhandled chart event: $eventType');
    }
  }

  void _showChartSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chart Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Show Statistics Panel'),
              value: _showStatistics,
              onChanged: (value) {
                setState(() {
                  _showStatistics = value;
                });
                Navigator.of(context).pop();
              },
            ),
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

  void _refreshData() {
    ref.invalidate(vehiclesNotifierProvider);
    ref.invalidate(consumptionChartDataProvider);
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedVehicle = null;
      _selectedDateRange = null;
      _selectedChartType = ChartType.line;
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}