import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/navigation/main_layout.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/chart_providers.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/widgets/chart_webview.dart';
import 'package:petrol_tracker/widgets/country_selection_widget.dart';
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

/// Dedicated screen for average consumption by period visualization
/// 
/// Features:
/// - Period-based average consumption analysis (weekly, monthly, yearly)
/// - Vehicle selection and predefined time period filtering
/// - Numeric statistics display with visual charts
/// - Period comparison and trend analysis
/// - Interactive charts with period-specific insights
class AverageConsumptionChartScreen extends ConsumerStatefulWidget {
  const AverageConsumptionChartScreen({super.key});

  @override
  ConsumerState<AverageConsumptionChartScreen> createState() => _AverageConsumptionChartScreenState();
}

class _AverageConsumptionChartScreenState extends ConsumerState<AverageConsumptionChartScreen> {
  VehicleModel? _selectedVehicle;
  final PeriodType _selectedPeriodType = PeriodType.monthly;
  TimePeriod _selectedTimePeriod = TimePeriod.allTime;
  String? _selectedCountry;
  final bool _showStatistics = true;
  final bool _showNumericView = false;
  bool _hasInitializedVehicle = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavAppBar(
        title: 'Average Consumption by Period',
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
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: _showNumericView ? _buildNumericView() : _buildChartView(),
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
          items: vehicles.map((vehicle) => DropdownMenuItem<VehicleModel>(
            value: vehicle,
            child: Text(vehicle.name),
          )).toList(),
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
      showCheckmark: false,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedTimePeriod = period;
          });
        }
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: isSelected 
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
      ),
    );
  }


  Widget _buildChartView() {
    if (_selectedVehicle == null) {
      return _buildLoadingPlaceholder();
    }

    // Get vehicle entries to determine the date range
    final vehicleEntriesAsync = ref.watch(fuelEntriesByVehicleProvider(_selectedVehicle!.id!));
    
    return vehicleEntriesAsync.when(
      data: (entries) {
        final dateRange = _getDateRangeFromEntries(_selectedTimePeriod, entries);
        final chartDataAsync = ref.watch(periodAverageConsumptionDataProvider(
          _selectedVehicle!.id!,
          _selectedPeriodType,
          startDate: dateRange?.start,
          endDate: dateRange?.end,
          countryFilter: _selectedCountry,
        ));
        
        return _buildChartContent(chartDataAsync);
      },
      loading: () => _buildLoadingPlaceholder(),
      error: (error, stack) => _buildErrorPlaceholder(error.toString()),
    );
  }
  
  Widget _buildChartContent(AsyncValue<List<PeriodAverageDataPoint>> chartDataAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: chartDataAsync.when(
        data: (periodData) {
          if (periodData.isEmpty) {
            return _buildEmptyChartPlaceholder();
          }

          // Transform to chart format
          final chartData = periodData.map((point) => {
            'date': point.date.toIso8601String().split('T')[0],
            'value': point.averageConsumption,
            'label': point.periodLabel,
            'count': point.entryCount,
          }).toList();

          return ChartWebView(
            data: chartData,
            config: ChartConfig(
              type: ChartType.bar,
              title: null,
              xLabel: _getPeriodDisplayName(),
              yLabel: 'Average Consumption (L/100km)',
              unit: 'L/100km',
              className: 'period-average-chart',
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
    );
  }

  Widget _buildNumericView() {
    if (_selectedVehicle == null) {
      return _buildLoadingPlaceholder();
    }

    // Get vehicle entries to determine the date range
    final vehicleEntriesAsync = ref.watch(fuelEntriesByVehicleProvider(_selectedVehicle!.id!));
    
    return vehicleEntriesAsync.when(
      data: (entries) {
        final dateRange = _getDateRangeFromEntries(_selectedTimePeriod, entries);
        final chartDataAsync = ref.watch(periodAverageConsumptionDataProvider(
          _selectedVehicle!.id!,
          _selectedPeriodType,
          startDate: dateRange?.start,
          endDate: dateRange?.end,
          countryFilter: _selectedCountry,
        ));
        
        return _buildNumericContent(chartDataAsync);
      },
      loading: () => _buildLoadingPlaceholder(),
      error: (error, stack) => _buildErrorPlaceholder(error.toString()),
    );
  }
  
  Widget _buildNumericContent(AsyncValue<List<PeriodAverageDataPoint>> chartDataAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: chartDataAsync.when(
        data: (periodData) {
          if (periodData.isEmpty) {
            return _buildEmptyChartPlaceholder();
          }

          return ListView.separated(
            itemCount: periodData.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final data = periodData[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  data.periodLabel,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                subtitle: Text(
                  '${data.entryCount} fuel ${data.entryCount == 1 ? 'entry' : 'entries'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${data.averageConsumption.toStringAsFixed(2)} L/100km',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Average',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => _buildLoadingPlaceholder(),
        error: (error, stack) => _buildErrorPlaceholder(error.toString()),
      ),
    );
  }

  Widget _buildStatisticsPanel() {
    if (_selectedVehicle == null) {
      return _buildOverallStatistics();
    }

    // Get vehicle entries to determine the date range
    final vehicleEntriesAsync = ref.watch(fuelEntriesByVehicleProvider(_selectedVehicle!.id!));
    
    return vehicleEntriesAsync.when(
      data: (entries) {
        final dateRange = _getDateRangeFromEntries(_selectedTimePeriod, entries);
        final statisticsAsync = ref.watch(consumptionStatisticsProvider(
          _selectedVehicle!.id!,
          startDate: dateRange?.start,
          endDate: dateRange?.end,
          countryFilter: _selectedCountry,
        ));
        
        return _buildStatisticsContent(statisticsAsync);
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Text('Statistics error: $error'),
    );
  }
  
  Widget _buildStatisticsContent(AsyncValue<Map<String, double>> statisticsAsync) {
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
      child: statisticsAsync.when(
        data: (stats) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overall Statistics',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStatCard('Average', '${stats['average']?.toStringAsFixed(1)} L/100km', Icons.analytics),
                  _buildStatCard('Best', '${stats['minimum']?.toStringAsFixed(1)} L/100km', Icons.trending_down),
                  _buildStatCard('Worst', '${stats['maximum']?.toStringAsFixed(1)} L/100km', Icons.trending_up),
                  _buildStatCard('Total Entries', '${stats['count']?.toInt()}', Icons.confirmation_num),
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
            'Select a vehicle to see detailed consumption statistics',
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
            'Add more fuel entries to see period averages',
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
          Text('Loading period data...'),
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
            'Error loading data',
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
        // Navigate to detailed period view
        break;
      default:
        debugPrint('Unhandled chart event: $eventType');
    }
  }


  void _refreshData() {
    ref.invalidate(vehiclesNotifierProvider);
    ref.invalidate(periodAverageConsumptionDataProvider);
    ref.invalidate(consumptionStatisticsProvider);
  }


  /// Get date range from selected time period starting from the last fuel entry
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
    switch (period) {
      case TimePeriod.oneMonth:
        return DateTimeRange(
          start: DateTime(referenceDate.year, referenceDate.month - 1, 1),
          end: referenceDate,
        );
      case TimePeriod.threeMonths:
        return DateTimeRange(
          start: DateTime(referenceDate.year, referenceDate.month - 3, 1),
          end: referenceDate,
        );
      case TimePeriod.sixMonths:
        return DateTimeRange(
          start: DateTime(referenceDate.year, referenceDate.month - 6, 1),
          end: referenceDate,
        );
      case TimePeriod.oneYear:
        return DateTimeRange(
          start: DateTime(referenceDate.year - 1, referenceDate.month, 1),
          end: referenceDate,
        );
      case TimePeriod.allTime:
        return DateTimeRange(start: DateTime(2020), end: referenceDate);
    }
  }

  String _getPeriodDisplayName() {
    switch (_selectedPeriodType) {
      case PeriodType.weekly:
        return 'Week';
      case PeriodType.monthly:
        return 'Month';
      case PeriodType.yearly:
        return 'Year';
    }
  }
}