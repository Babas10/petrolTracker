import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/navigation/main_layout.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/chart_providers.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/units_providers.dart';
import 'package:petrol_tracker/widgets/chart_webview.dart';
import 'package:petrol_tracker/widgets/country_selection_widget.dart';
import 'package:petrol_tracker/widgets/period_detail_modal.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';

/// Predefined time periods for analysis
enum TimePeriod {
  oneMonth,
  threeMonths,
  sixMonths,
  oneYear,
  allTime,
}

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
  ChartType _selectedChartType = ChartType.area;
  DateTimeRange? _selectedDateRange;
  TimePeriod _selectedTimePeriod = TimePeriod.allTime;
  String? _selectedCountry;
  bool _showStatistics = true;
  bool _hasInitializedVehicle = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavAppBar(
        title: 'Fuel Consumption Analysis',
        actions: [
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4, // Reduced by 20% (0.5 → 0.4)
                    child: _buildChartContent(),
                  ),
                  if (_showStatistics) _buildStatisticsPanel(),
                ],
              ),
            ),
          ),
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
          _buildVehicleSelector(),
          const SizedBox(height: 12),
          _buildCountryFilter(),
          const SizedBox(height: 12),
          _buildTimePeriodButtons(),
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

        // Auto-select first vehicle if not initialized
        if (!_hasInitializedVehicle && vehicles.isNotEmpty) {
          _selectedVehicle = vehicles.first;
          _hasInitializedVehicle = true;
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


  Widget _buildCountryFilter() {
    if (_selectedVehicle == null) {
      return const SizedBox.shrink(); // Don't show country filter if no vehicle selected
    }

    final entriesState = ref.watch(fuelEntriesByVehicleProvider(_selectedVehicle!.id!));
    
    return entriesState.when(
      data: (entries) {
        // Get unique countries from the selected vehicle's entries
        final countries = entries
            .map((entry) => entry.country)
            .toSet()
            .toList();
        
        if (countries.length <= 1) {
          return const SizedBox.shrink(); // Don't show filter if only one country
        }

        // Calculate entry counts per country
        final entryCounts = <String, int>{};
        for (final entry in entries) {
          entryCounts[entry.country] = (entryCounts[entry.country] ?? 0) + 1;
        }

        return CountryFilterWidget(
          selectedCountry: _selectedCountry,
          onCountryChanged: (country) {
            setState(() {
              _selectedCountry = country;
            });
          },
          availableCountries: countries,
          entryCounts: entryCounts,
          showEntryCounts: true,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }


  Widget _buildTimePeriodButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Period of Interest',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTimePeriodChip('1M', TimePeriod.oneMonth),
            _buildTimePeriodChip('3M', TimePeriod.threeMonths),
            _buildTimePeriodChip('6M', TimePeriod.sixMonths),
            _buildTimePeriodChip('1Y', TimePeriod.oneYear),
            _buildTimePeriodChip('All Time', TimePeriod.allTime),
          ],
        ),
      ],
    );
  }

  Widget _buildTimePeriodChip(String label, TimePeriod period) {
    final isSelected = _selectedTimePeriod == period;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedTimePeriod = period;
            // Clear date range when using time period buttons
            _selectedDateRange = null;
          });
        }
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected 
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
      ),
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
    // Get vehicle entries to determine the date range
    final vehicleEntriesAsync = ref.watch(fuelEntriesByVehicleProvider(_selectedVehicle!.id!));
    
    return vehicleEntriesAsync.when(
      data: (entries) {
        final dateRange = _getDateRangeFromEntries(_selectedTimePeriod, entries);
        final effectiveDateRange = _selectedDateRange ?? dateRange;
        
        final chartDataAsync = ref.watch(enhancedConsumptionChartDataProvider(
          _selectedVehicle!.id!,
          startDate: effectiveDateRange?.start,
          endDate: effectiveDateRange?.end,
          countryFilter: _selectedCountry,
        ));
        
        return _buildSingleVehicleChartContent(chartDataAsync, ref);
      },
      loading: () => _buildLoadingPlaceholder(),
      error: (error, stack) => _buildErrorPlaceholder(error.toString()),
    );
  }
  
  Widget _buildSingleVehicleChartContent(AsyncValue<List<EnhancedConsumptionDataPoint>> chartDataAsync, WidgetRef ref) {
    final unitSystem = ref.watch(unitsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart takes full available space with no margins
        Expanded(
          child: Container(
            width: double.infinity,
            child: chartDataAsync.when(
              data: (consumptionData) {
                if (consumptionData.isEmpty) {
                  return _buildEmptyChartPlaceholder();
                }

                return unitSystem.when(
                  data: (units) {
                    // Transform to enhanced chart format with period metadata
                    final chartData = consumptionData.map((point) => {
                      'date': point.date.toIso8601String().split('T')[0],
                      'value': units == UnitSystem.metric 
                          ? point.consumption 
                          : UnitConverter.consumptionToImperial(point.consumption),
                      'km': units == UnitSystem.metric 
                          ? point.kilometers 
                          : UnitConverter.distanceToImperial(point.kilometers),
                      // Enhanced metadata for visual distinction and tooltips
                      'isComplexPeriod': point.isComplexPeriod,
                      'isSimplePeriod': point.isSimplePeriod,
                      'periodComposition': point.periodComposition,
                      'totalEntries': point.totalEntries,
                      'partialEntries': point.partialEntries,
                      'totalFuel': units == UnitSystem.metric 
                          ? point.totalFuel 
                          : UnitConverter.volumeToImperial(point.totalFuel),
                      'totalDistance': units == UnitSystem.metric 
                          ? point.totalDistance 
                          : UnitConverter.distanceToImperial(point.totalDistance),
                      'formattedDuration': point.formattedDuration,
                      // Data for period detail modal
                      'periodData': {
                        'date': point.date.toIso8601String(),
                        'consumption': units == UnitSystem.metric 
                            ? point.consumption 
                            : UnitConverter.consumptionToImperial(point.consumption),
                        'kilometers': units == UnitSystem.metric 
                            ? point.kilometers 
                            : UnitConverter.distanceToImperial(point.kilometers),
                        'totalEntries': point.totalEntries,
                        'partialEntries': point.partialEntries,
                        'periodComposition': point.periodComposition,
                        'entryIds': point.entryIds,
                        'periodStart': point.periodStart.toIso8601String(),
                        'periodEnd': point.periodEnd.toIso8601String(),
                        'totalFuel': units == UnitSystem.metric 
                            ? point.totalFuel 
                            : UnitConverter.volumeToImperial(point.totalFuel),
                        'totalDistance': units == UnitSystem.metric 
                            ? point.totalDistance 
                            : UnitConverter.distanceToImperial(point.totalDistance),
                        'totalCost': point.totalCost,
                        'hasPartialRefuels': point.hasPartialRefuels,
                      },
                    }).toList();

                    return ChartWebView(
                      data: chartData,
                      config: ChartConfig(
                        type: _selectedChartType,
                        title: 'Consumption Analysis (${units.consumptionUnit})',
                        xLabel: 'Date',
                        yLabel: 'Consumption (${units.consumptionUnit})',
                        unit: units.consumptionUnit,
                        className: 'consumption-chart',
                      ),
                      onChartEvent: _handleChartEvent,
                      onError: (error) {
                        debugPrint('Chart error: $error');
                      },
                    );
                  },
                  loading: () => _buildLoadingPlaceholder(),
                  error: (_, __) {
                    // Fallback to metric units if units loading fails
                    final chartData = consumptionData.map((point) => {
                      'date': point.date.toIso8601String().split('T')[0],
                      'value': point.consumption,
                      'km': point.kilometers,
                      'isComplexPeriod': point.isComplexPeriod,
                      'isSimplePeriod': point.isSimplePeriod,
                      'periodComposition': point.periodComposition,
                      'totalEntries': point.totalEntries,
                      'partialEntries': point.partialEntries,
                      'totalFuel': point.totalFuel,
                      'totalDistance': point.totalDistance,
                      'formattedDuration': point.formattedDuration,
                      'periodData': {
                        'date': point.date.toIso8601String(),
                        'consumption': point.consumption,
                        'kilometers': point.kilometers,
                        'totalEntries': point.totalEntries,
                        'partialEntries': point.partialEntries,
                        'periodComposition': point.periodComposition,
                        'entryIds': point.entryIds,
                        'periodStart': point.periodStart.toIso8601String(),
                        'periodEnd': point.periodEnd.toIso8601String(),
                        'totalFuel': point.totalFuel,
                        'totalDistance': point.totalDistance,
                        'totalCost': point.totalCost,
                        'hasPartialRefuels': point.hasPartialRefuels,
                      },
                    }).toList();

                    return ChartWebView(
                      data: chartData,
                      config: const ChartConfig(
                        type: ChartType.area,
                        title: 'Consumption Analysis (L/100km)',
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
                );
              },
              loading: () => _buildLoadingPlaceholder(),
              error: (error, stack) => _buildErrorPlaceholder(error.toString()),
            ),
          ),
        ),
      ],
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
        
        final chartDataAsync = ref.watch(enhancedConsumptionChartDataProvider(
          vehicle.id!,
          startDate: _selectedDateRange?.start,
          endDate: _selectedDateRange?.end,
          countryFilter: _selectedCountry,
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
                          // Enhanced metadata for visual distinction and tooltips
                          'isComplexPeriod': point.isComplexPeriod,
                          'isSimplePeriod': point.isSimplePeriod,
                          'periodComposition': point.periodComposition,
                          'totalEntries': point.totalEntries,
                          'partialEntries': point.partialEntries,
                          'totalFuel': point.totalFuel,
                          'totalDistance': point.totalDistance,
                          'formattedDuration': point.formattedDuration,
                          // Data for period detail modal
                          'periodData': {
                            'date': point.date.toIso8601String(),
                            'consumption': point.consumption,
                            'kilometers': point.kilometers,
                            'totalEntries': point.totalEntries,
                            'partialEntries': point.partialEntries,
                            'periodComposition': point.periodComposition,
                            'entryIds': point.entryIds,
                            'periodStart': point.periodStart.toIso8601String(),
                            'periodEnd': point.periodEnd.toIso8601String(),
                            'totalFuel': point.totalFuel,
                            'totalDistance': point.totalDistance,
                            'totalCost': point.totalCost,
                            'hasPartialRefuels': point.hasPartialRefuels,
                          },
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
    // Get vehicle entries to determine the date range
    final vehicleEntriesAsync = ref.watch(fuelEntriesByVehicleProvider(_selectedVehicle!.id!));
    
    return vehicleEntriesAsync.when(
      data: (entries) {
        final dateRange = _getDateRangeFromEntries(_selectedTimePeriod, entries);
        final effectiveDateRange = _selectedDateRange ?? dateRange;
        
        final chartDataAsync = ref.watch(enhancedConsumptionChartDataProvider(
          _selectedVehicle!.id!,
          startDate: effectiveDateRange?.start,
          endDate: effectiveDateRange?.end,
          countryFilter: _selectedCountry,
        ));
        
        return _buildVehicleStatisticsContent(chartDataAsync);
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Text('Statistics error: $error'),
    );
  }
  
  Widget _buildVehicleStatisticsContent(AsyncValue<List<EnhancedConsumptionDataPoint>> chartDataAsync) {
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
                  Expanded(
                    child: _buildStatCard('Average', '${average.toStringAsFixed(1)} L/100km', Icons.analytics),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('Best', '${minConsumption.toStringAsFixed(1)} L/100km', Icons.trending_down),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('Worst', '${maxConsumption.toStringAsFixed(1)} L/100km', Icons.trending_up),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('Distance', '${totalDistance.toStringAsFixed(0)} km', Icons.route),
                  ),
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
              fontSize: 12, // Slightly smaller to ensure fitting
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 10, // Smaller to ensure fitting
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
        // Enhanced tooltips are handled by the chart itself using the period metadata
        break;
      case 'click':
        // Show period detail modal when clicking on a chart data point
        _handlePeriodDetailClick(data);
        break;
      default:
        debugPrint('Unhandled chart event: $eventType');
    }
  }

  void _handlePeriodDetailClick(Map<String, dynamic> data) {
    try {
      
      final periodData = data['periodData'] as Map<String, dynamic>?;
      if (periodData == null) {
        debugPrint('No period data available for detail modal');
        return;
      }


      // Reconstruct EnhancedConsumptionDataPoint from the data with safe type casting
      final enhancedPoint = EnhancedConsumptionDataPoint(
        date: DateTime.parse(periodData['date'].toString()),
        consumption: double.tryParse(periodData['consumption'].toString()) ?? 0.0,
        kilometers: double.tryParse(periodData['kilometers'].toString()) ?? 0.0,
        totalEntries: int.tryParse(periodData['totalEntries'].toString()) ?? 0,
        partialEntries: int.tryParse(periodData['partialEntries'].toString()) ?? 0,
        periodComposition: periodData['periodComposition']?.toString() ?? '',
        entryIds: (periodData['entryIds'] as List?)?.cast<int>() ?? [],
        periodStart: DateTime.tryParse(periodData['periodStart'].toString()) ?? DateTime.now(),
        periodEnd: DateTime.tryParse(periodData['periodEnd'].toString()) ?? DateTime.now(),
        totalFuel: double.tryParse(periodData['totalFuel'].toString()) ?? 0.0,
        totalDistance: double.tryParse(periodData['totalDistance'].toString()) ?? 0.0,
        totalCost: double.tryParse(periodData['totalCost'].toString()) ?? 0.0,
        hasPartialRefuels: periodData['hasPartialRefuels'] == true,
      );

      // Show the period detail modal
      showPeriodDetailModal(context, enhancedPoint);
    } catch (e) {
      debugPrint('Error showing period detail modal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading period details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _refreshData() {
    ref.invalidate(vehiclesNotifierProvider);
    ref.invalidate(enhancedConsumptionChartDataProvider);
  }




  /// Get date range from selected time period 
  DateTimeRange? _getDateRangeFromEntries(TimePeriod period, List<FuelEntryModel> entries) {
    if (period == TimePeriod.allTime) {
      return null; // No date filtering for all time
    }
    
    if (entries.isEmpty) {
final calculatedRange = _calculateDateRange(period, DateTime.now());
      return calculatedRange;
    }
    
    
    // Use the MINIMUM of current date and most recent entry date as end date
    // This prevents looking for data in the future beyond what exists
    final now = DateTime.now();
    final currentDate = DateTime(now.year, now.month, now.day);
    
    // Find the actual most recent entry date (entries might not be sorted as expected)
    final mostRecentEntryDate = entries.isNotEmpty 
        ? entries.map((e) => e.date).reduce((a, b) => a.isAfter(b) ? a : b)
        : currentDate;
        
    // Use the earlier date to avoid looking beyond available data
    final endDate = currentDate.isBefore(mostRecentEntryDate) 
        ? currentDate 
        : mostRecentEntryDate;
    
final calculatedRange = _calculateDateRange(period, endDate);
    
    return calculatedRange;
  }
  
  /// Calculate date range based on period and reference date
  DateTimeRange _calculateDateRange(TimePeriod period, DateTime referenceDate) {
    DateTime startDate;
    
    switch (period) {
      case TimePeriod.oneMonth:
        startDate = _subtractMonths(referenceDate, 1);
        break;
      case TimePeriod.threeMonths:
        startDate = _subtractMonths(referenceDate, 3);
        break;
      case TimePeriod.sixMonths:
        startDate = _subtractMonths(referenceDate, 6);
        break;
      case TimePeriod.oneYear:
        startDate = _subtractMonths(referenceDate, 12);
        break;
      case TimePeriod.allTime:
        startDate = DateTime(2020);
        break;
    }
    
    return DateTimeRange(start: startDate, end: referenceDate);
  }

  /// Safely subtract months from a date, handling month boundaries properly
  DateTime _subtractMonths(DateTime date, int monthsToSubtract) {
    int targetYear = date.year;
    int targetMonth = date.month - monthsToSubtract;
    
    // Handle year boundary
    while (targetMonth <= 0) {
      targetYear--;
      targetMonth += 12;
    }
    
    // Handle day boundary - if the target month doesn't have enough days,
    // use the last day of that month
    int targetDay = date.day;
    int maxDaysInTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
    if (targetDay > maxDaysInTargetMonth) {
      targetDay = maxDaysInTargetMonth;
    }
    
    return DateTime(targetYear, targetMonth, targetDay);
  }
}