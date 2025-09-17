import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/navigation/main_layout.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/chart_providers.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/multi_currency_chart_providers.dart';
import 'package:petrol_tracker/widgets/chart_webview.dart';
import 'package:petrol_tracker/widgets/country_selection_widget.dart';
import 'package:petrol_tracker/widgets/currency_summary_card.dart';
import 'package:petrol_tracker/widgets/currency_usage_statistics.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';

/// Predefined time periods for cost analysis
enum CostTimePeriod {
  oneMonth,
  sixMonths,
  oneYear,
  allTime,
}

/// Comprehensive Cost Analysis Dashboard (Issues #10, #11, #14, #129)
/// 
/// Features:
/// - Monthly spending breakdown charts with multi-currency conversion
/// - Price trends by country comparison
/// - Country spending pie charts
/// - Comprehensive spending statistics in user's primary currency
/// - Time period filtering (1M, 6M, 1Y, all-time)
/// - Multi-country spending visualization
/// - Currency usage tracking and conversion transparency
/// - Multi-currency dashboard indicators
class CostAnalysisDashboardScreen extends ConsumerStatefulWidget {
  const CostAnalysisDashboardScreen({super.key});

  @override
  ConsumerState<CostAnalysisDashboardScreen> createState() => _CostAnalysisDashboardScreenState();
}

class _CostAnalysisDashboardScreenState extends ConsumerState<CostAnalysisDashboardScreen> {
  VehicleModel? _selectedVehicle;
  CostTimePeriod _selectedTimePeriod = CostTimePeriod.allTime;
  String? _selectedCountry;
  bool _showStatistics = true;
  bool _showCurrencyDetails = true;
  bool _hasInitializedVehicle = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavAppBar(
        title: 'Cost Analysis Dashboard',
        actions: [
          // Currency indicator in app bar
          if (_selectedVehicle != null) _buildAppBarCurrencyIndicator(),
          IconButton(
            icon: Icon(_showStatistics ? Icons.analytics : Icons.analytics_outlined),
            onPressed: () {
              setState(() {
                _showStatistics = !_showStatistics;
              });
            },
            tooltip: _showStatistics ? 'Hide Statistics' : 'Show Statistics',
          ),
          IconButton(
            icon: Icon(_showCurrencyDetails ? Icons.currency_exchange : Icons.currency_exchange_outlined),
            onPressed: () {
              setState(() {
                _showCurrencyDetails = !_showCurrencyDetails;
              });
            },
            tooltip: _showCurrencyDetails ? 'Hide Currency Details' : 'Show Currency Details',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Currency summary card
                  if (_showCurrencyDetails && _selectedVehicle != null) ...[
                    _buildCurrencySummarySection(),
                    const SizedBox(height: 16),
                  ],
                  if (_showStatistics) ...[
                    _buildMultiCurrencySpendingStatisticsSection(),
                    const SizedBox(height: 16),
                  ],
                  _buildMultiCurrencyMonthlySpendingChart(),
                  const SizedBox(height: 16),
                  _buildMultiCurrencyCountrySpendingComparison(),
                  const SizedBox(height: 16),
                  _buildPriceTrendsChart(),
                  if (_showCurrencyDetails && _selectedVehicle != null) ...[
                    const SizedBox(height: 16),
                    _buildCurrencyUsageStatisticsSection(),
                  ],
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
          Row(
            children: [
              Expanded(child: _buildVehicleSelector()),
              const SizedBox(width: 16),
              Expanded(child: _buildTimePeriodSelector()),
            ],
          ),
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
            prefixIcon: Icon(Icons.directions_car, size: 18),
          ),
          items: vehicles.map((vehicle) => DropdownMenuItem<VehicleModel>(
            value: vehicle,
            child: Text(vehicle.name),
          )).toList(),
          onChanged: (vehicle) {
            setState(() {
              _selectedVehicle = vehicle;
              _selectedCountry = null; // Reset country filter when vehicle changes
            });
          },
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildTimePeriodSelector() {
    return DropdownButtonFormField<CostTimePeriod>(
      value: _selectedTimePeriod,
      decoration: const InputDecoration(
        labelText: 'Time Period',
        border: OutlineInputBorder(),
        isDense: true,
        prefixIcon: Icon(Icons.schedule, size: 18),
      ),
      items: const [
        DropdownMenuItem(
          value: CostTimePeriod.oneMonth,
          child: Row(
            children: [
              Icon(Icons.calendar_view_month, size: 16),
              SizedBox(width: 8),
              Text('Last Month'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: CostTimePeriod.sixMonths,
          child: Row(
            children: [
              Icon(Icons.date_range, size: 16),
              SizedBox(width: 8),
              Text('Last 6 Months'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: CostTimePeriod.oneYear,
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 16),
              SizedBox(width: 8),
              Text('Last Year'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: CostTimePeriod.allTime,
          child: Row(
            children: [
              Icon(Icons.all_inclusive, size: 16),
              SizedBox(width: 8),
              Text('All Time'),
            ],
          ),
        ),
      ],
      onChanged: (period) {
        if (period != null) {
          setState(() {
            _selectedTimePeriod = period;
          });
        }
      },
    );
  }

  Widget _buildCountryFilter() {
    if (_selectedVehicle == null) {
      return const SizedBox.shrink();
    }

    final entriesState = ref.watch(fuelEntriesByVehicleProvider(_selectedVehicle!.id!));
    
    return entriesState.when(
      data: (entries) {
        final countries = entries
            .map((entry) => entry.country)
            .toSet()
            .toList();
        
        if (countries.length <= 1) {
          return const SizedBox.shrink();
        }

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
          'Quick Analysis Period',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTimePeriodChip('1 Month', CostTimePeriod.oneMonth),
            _buildTimePeriodChip('6 Months', CostTimePeriod.sixMonths),
            _buildTimePeriodChip('1 Year', CostTimePeriod.oneYear),
            _buildTimePeriodChip('All Time', CostTimePeriod.allTime),
          ],
        ),
      ],
    );
  }

  Widget _buildTimePeriodChip(String label, CostTimePeriod period) {
    final isSelected = _selectedTimePeriod == period;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedTimePeriod = period;
          });
        }
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }

  Widget _buildSpendingStatisticsSection() {
    if (_selectedVehicle == null) {
      return _buildNoDataCard('Select a vehicle to view spending statistics');
    }

    final dateRange = _getDateRangeFromPeriod(_selectedTimePeriod);
    final statisticsAsync = ref.watch(spendingStatisticsProvider(
      _selectedVehicle!.id!,
      startDate: dateRange?.start,
      endDate: dateRange?.end,
      countryFilter: _selectedCountry,
    ));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Spending Statistics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            statisticsAsync.when(
              data: (stats) => _buildStatisticsGrid(stats),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.0,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Total Spent',
          '\$${stats['totalSpent'].toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildStatCard(
          'Average per Fill-up',
          '\$${stats['averagePerFillUp'].toStringAsFixed(2)}',
          Icons.local_gas_station,
          Colors.blue,
        ),
        _buildStatCard(
          'Monthly Average',
          '\$${stats['averagePerMonth'].toStringAsFixed(2)}',
          Icons.calendar_month,
          Colors.orange,
        ),
        _buildStatCard(
          'Total Fill-ups',
          '${stats['totalFillUps']}',
          Icons.format_list_numbered,
          Colors.purple,
        ),
        _buildStatCard(
          'Most Expensive',
          '\$${stats['mostExpensiveFillUp'].toStringAsFixed(2)}',
          Icons.trending_up,
          Colors.red,
        ),
        _buildStatCard(
          'Cheapest',
          '\$${stats['cheapestFillUp'].toStringAsFixed(2)}',
          Icons.trending_down,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

  Widget _buildMonthlySpendingChart() {
    if (_selectedVehicle == null) {
      return _buildNoDataCard('Select a vehicle to view monthly spending');
    }

    final dateRange = _getDateRangeFromPeriod(_selectedTimePeriod);
    final chartDataAsync = ref.watch(monthlySpendingDataProvider(
      _selectedVehicle!.id!,
      startDate: dateRange?.start,
      endDate: dateRange?.end,
      countryFilter: _selectedCountry,
    ));

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
                  'Monthly Spending Breakdown',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: chartDataAsync.when(
                data: (spendingData) {
                  if (spendingData.isEmpty) {
                    return const Center(child: Text('No spending data available'));
                  }
                  
                  // For now, show a simple chart representation
                  // In a real implementation, you'd use ChartWebView with D3.js
                  return _buildSimpleBarChart(spendingData);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountrySpendingComparison() {
    if (_selectedVehicle == null) {
      return _buildNoDataCard('Select a vehicle to compare country spending');
    }

    final dateRange = _getDateRangeFromPeriod(_selectedTimePeriod);
    final comparisonAsync = ref.watch(countrySpendingComparisonProvider(
      _selectedVehicle!.id!,
      startDate: dateRange?.start,
      endDate: dateRange?.end,
    ));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Spending by Country',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            comparisonAsync.when(
              data: (countryData) {
                if (countryData.isEmpty) {
                  return const Center(child: Text('No country spending data available'));
                }
                
                return _buildCountrySpendingList(countryData);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceTrendsChart() {
    if (_selectedVehicle == null) {
      return _buildNoDataCard('Select a vehicle to view price trends');
    }

    final dateRange = _getDateRangeFromPeriod(_selectedTimePeriod);
    final trendsAsync = ref.watch(priceTrendsByCountryProvider(
      _selectedVehicle!.id!,
      startDate: dateRange?.start,
      endDate: dateRange?.end,
    ));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.show_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Price Trends by Country',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: trendsAsync.when(
                data: (trendsData) {
                  if (trendsData.isEmpty) {
                    return const Center(child: Text('No price trend data available'));
                  }
                  
                  return _buildPriceTrendsSummary(trendsData);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleBarChart(List<SpendingDataPoint> data) {
    final maxAmount = data.map((d) => d.amount).reduce((a, b) => a > b ? a : b);
    
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: data.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final dataPoint = data[index];
        final height = (dataPoint.amount / maxAmount * 250).clamp(10.0, 250.0);
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '\$${dataPoint.amount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Container(
              width: 40,
              height: height,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 50,
              child: Text(
                dataPoint.periodLabel,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCountrySpendingList(List<CountrySpendingDataPoint> data) {
    return Column(
      children: data.map((countryData) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              // Country flag (simplified)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    countryData.country.substring(0, 2).toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      countryData.country,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${countryData.entryCount} fill-ups • Avg: \$${countryData.averagePricePerLiter.toStringAsFixed(2)}/L',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '\$${countryData.totalSpent.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceTrendsSummary(Map<String, List<PriceTrendDataPoint>> trendsData) {
    return Column(
      children: trendsData.entries.map((entry) {
        final country = entry.key;
        final trends = entry.value;
        
        if (trends.isEmpty) return const SizedBox.shrink();
        
        final firstPrice = trends.first.pricePerLiter;
        final lastPrice = trends.last.pricePerLiter;
        final change = lastPrice - firstPrice;
        final changePercent = firstPrice > 0 ? (change / firstPrice * 100) : 0.0;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(
                country,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '\$${firstPrice.toStringAsFixed(2)} → \$${lastPrice.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: change >= 0 ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${change >= 0 ? '+' : ''}${changePercent.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: change >= 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoDataCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  DateTimeRange? _getDateRangeFromPeriod(CostTimePeriod period) {
    final now = DateTime.now();
    
    switch (period) {
      case CostTimePeriod.oneMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 1, now.day),
          end: now,
        );
      case CostTimePeriod.sixMonths:
        return DateTimeRange(
          start: DateTime(now.year, now.month - 6, now.day),
          end: now,
        );
      case CostTimePeriod.oneYear:
        return DateTimeRange(
          start: DateTime(now.year - 1, now.month, now.day),
          end: now,
        );
      case CostTimePeriod.allTime:
        return null; // No filtering
    }
  }

  /// App bar currency indicator widget
  Widget _buildAppBarCurrencyIndicator() {
    final currencyIndicatorAsync = ref.watch(dashboardCurrencyIndicatorProvider(_selectedVehicle!.id!));
    
    return currencyIndicatorAsync.when(
      data: (data) {
        final primaryCurrency = data['primaryCurrency'] as String;
        final hasMultiCurrency = data['hasMultiCurrency'] as bool;
        final totalCurrencies = data['totalCurrencies'] as int;
        
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: CurrencyIndicatorChip(
            currency: primaryCurrency,
            label: hasMultiCurrency ? '$totalCurrencies currencies' : null,
            showConversionWarning: false,
            onTap: () {
              setState(() {
                _showCurrencyDetails = !_showCurrencyDetails;
              });
            },
          ),
        );
      },
      loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Currency summary section
  Widget _buildCurrencySummarySection() {
    if (_selectedVehicle == null) return const SizedBox.shrink();

    final dateRange = _getDateRangeFromPeriod(_selectedTimePeriod);
    final currencyUsageAsync = ref.watch(currencyUsageSummaryProvider(
      _selectedVehicle!.id!,
      startDate: dateRange?.start,
      endDate: dateRange?.end,
      countryFilter: _selectedCountry,
    ));

    return currencyUsageAsync.when(
      data: (currencyUsage) {
        return CurrencySummaryCard(
          currencyUsage: currencyUsage,
          primaryCurrency: currencyUsage.primaryCurrency,
          showConversionDetails: _showCurrencyDetails,
          onTap: () {
            setState(() {
              _showCurrencyDetails = !_showCurrencyDetails;
            });
          },
        );
      },
      loading: () => const CurrencySummaryCard(primaryCurrency: 'USD'),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading currency usage: $error'),
        ),
      ),
    );
  }

  /// Multi-currency spending statistics section
  Widget _buildMultiCurrencySpendingStatisticsSection() {
    if (_selectedVehicle == null) {
      return _buildNoDataCard('Select a vehicle to view spending statistics');
    }

    final dateRange = _getDateRangeFromPeriod(_selectedTimePeriod);
    final enhancedStatsAsync = ref.watch(enhancedSpendingStatisticsProvider(
      _selectedVehicle!.id!,
      startDate: dateRange?.start,
      endDate: dateRange?.end,
      countryFilter: _selectedCountry,
    ));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Multi-Currency Spending Statistics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (_showCurrencyDetails) 
                  Icon(
                    Icons.currency_exchange,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            enhancedStatsAsync.when(
              data: (stats) => _buildEnhancedStatisticsGrid(stats),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }

  /// Enhanced statistics grid with currency conversion info
  Widget _buildEnhancedStatisticsGrid(Map<String, dynamic> stats) {
    final primaryCurrency = stats['primaryCurrency'] as String;
    final hasConversionFailures = stats['hasConversionFailures'] as bool;
    final totalCurrencies = stats['totalCurrencies'] as int;

    return Column(
      children: [
        // Show conversion status if relevant
        if (_showCurrencyDetails && totalCurrencies > 1) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasConversionFailures 
                  ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  hasConversionFailures ? Icons.warning_amber : Icons.check_circle,
                  size: 16,
                  color: hasConversionFailures 
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasConversionFailures 
                        ? 'Some currency conversions failed - amounts in original currencies'
                        : 'All amounts converted to $primaryCurrency',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        // Statistics grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.0,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildStatCard(
              'Total Spent',
              '${stats['totalSpent'].toStringAsFixed(2)} $primaryCurrency',
              Icons.attach_money,
              Colors.green,
            ),
            _buildStatCard(
              'Average per Fill-up',
              '${stats['averagePerFillUp'].toStringAsFixed(2)} $primaryCurrency',
              Icons.local_gas_station,
              Colors.blue,
            ),
            _buildStatCard(
              'Monthly Average',
              '${stats['averagePerMonth'].toStringAsFixed(2)} $primaryCurrency',
              Icons.calendar_month,
              Colors.orange,
            ),
            _buildStatCard(
              'Currencies Used',
              '${stats['totalCurrencies']}',
              Icons.language,
              Colors.purple,
            ),
            _buildStatCard(
              'Most Expensive',
              '${stats['mostExpensiveFillUp'].toStringAsFixed(2)} $primaryCurrency',
              Icons.trending_up,
              Colors.red,
            ),
            _buildStatCard(
              'Cheapest',
              '${stats['cheapestFillUp'].toStringAsFixed(2)} $primaryCurrency',
              Icons.trending_down,
              Colors.teal,
            ),
          ],
        ),
      ],
    );
  }

  /// Multi-currency monthly spending chart
  Widget _buildMultiCurrencyMonthlySpendingChart() {
    if (_selectedVehicle == null) {
      return _buildNoDataCard('Select a vehicle to view monthly spending');
    }

    final dateRange = _getDateRangeFromPeriod(_selectedTimePeriod);
    final chartDataAsync = ref.watch(multiCurrencyMonthlySpendingDataProvider(
      _selectedVehicle!.id!,
      startDate: dateRange?.start,
      endDate: dateRange?.end,
      countryFilter: _selectedCountry,
    ));

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
                  'Monthly Spending Breakdown',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (_showCurrencyDetails) 
                  Icon(
                    Icons.currency_exchange,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: chartDataAsync.when(
                data: (spendingData) {
                  if (spendingData.isEmpty) {
                    return const Center(child: Text('No spending data available'));
                  }
                  
                  return _buildSimpleMultiCurrencyBarChart(spendingData);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Multi-currency country spending comparison
  Widget _buildMultiCurrencyCountrySpendingComparison() {
    if (_selectedVehicle == null) {
      return _buildNoDataCard('Select a vehicle to compare country spending');
    }

    final dateRange = _getDateRangeFromPeriod(_selectedTimePeriod);
    final comparisonAsync = ref.watch(multiCurrencyCountrySpendingComparisonProvider(
      _selectedVehicle!.id!,
      startDate: dateRange?.start,
      endDate: dateRange?.end,
    ));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Multi-Currency Spending by Country',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (_showCurrencyDetails) 
                  Icon(
                    Icons.currency_exchange,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            comparisonAsync.when(
              data: (countryData) {
                if (countryData.isEmpty) {
                  return const Center(child: Text('No country spending data available'));
                }
                
                return _buildMultiCurrencyCountrySpendingList(countryData);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ],
        ),
      ),
    );
  }

  /// Currency usage statistics section
  Widget _buildCurrencyUsageStatisticsSection() {
    if (_selectedVehicle == null) return const SizedBox.shrink();

    final dateRange = _getDateRangeFromPeriod(_selectedTimePeriod);
    final currencyUsageAsync = ref.watch(currencyUsageSummaryProvider(
      _selectedVehicle!.id!,
      startDate: dateRange?.start,
      endDate: dateRange?.end,
      countryFilter: _selectedCountry,
    ));

    final spendingStatsAsync = ref.watch(multiCurrencySpendingStatisticsProvider(
      _selectedVehicle!.id!,
      startDate: dateRange?.start,
      endDate: dateRange?.end,
      countryFilter: _selectedCountry,
    ));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Currency Usage Statistics',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AsyncValue.guard(() async {
              final currencyUsage = await currencyUsageAsync.future;
              final spendingStats = await spendingStatsAsync.future;
              return (currencyUsage, spendingStats);
            }).when(
              data: (data) {
                final (currencyUsage, spendingStats) = data;
                return CurrencyUsageStatistics(
                  currencyUsage: currencyUsage,
                  spendingStats: spendingStats,
                  primaryCurrency: currencyUsage.primaryCurrency,
                  showConversionDetails: _showCurrencyDetails,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error loading currency statistics: $error'),
            ),
          ],
        ),
      ),
    );
  }

  /// Simple multi-currency bar chart
  Widget _buildSimpleMultiCurrencyBarChart(List<dynamic> data) {
    final maxAmount = data.map((d) => d.amount.displayAmount as double).reduce((a, b) => a > b ? a : b);
    
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: data.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final dataPoint = data[index];
        final amount = dataPoint.amount;
        final height = (amount.displayAmount / maxAmount * 250).clamp(10.0, 250.0);
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_showCurrencyDetails && amount.isConverted) ...[
              Text(
                'orig: ${amount.originalAmount.toStringAsFixed(0)} ${amount.originalCurrency}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 8),
              ),
              const SizedBox(height: 2),
            ],
            Text(
              '${amount.displayAmount.toStringAsFixed(0)} ${amount.displayCurrency}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Container(
              width: 40,
              height: height,
              decoration: BoxDecoration(
                color: amount.conversionFailed 
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 50,
              child: Text(
                dataPoint.periodLabel,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Multi-currency country spending list
  Widget _buildMultiCurrencyCountrySpendingList(List<dynamic> data) {
    return Column(
      children: data.map((countryData) {
        final totalSpent = countryData.totalSpent;
        final avgPrice = countryData.averagePricePerLiter;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              // Country flag (simplified)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    countryData.country.substring(0, 2).toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          countryData.country,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (countryData.isMultiCurrency) 
                          Icon(
                            Icons.language,
                            size: 16,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${countryData.entryCount} fill-ups • Avg: ${avgPrice.toDisplayString()}/L',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        ConversionTransparencyWidget(
                          amount: totalSpent,
                          showDetails: false,
                        ),
                      ],
                    ),
                    if (_showCurrencyDetails && totalSpent.isConverted) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Converted from ${totalSpent.originalAmount.toStringAsFixed(2)} ${totalSpent.originalCurrency}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _refreshData() {
    ref.invalidate(monthlySpendingDataProvider);
    ref.invalidate(countrySpendingComparisonProvider);
    ref.invalidate(priceTrendsByCountryProvider);
    ref.invalidate(spendingStatisticsProvider);
    // Invalidate multi-currency providers
    ref.invalidate(multiCurrencySpendingStatisticsProvider);
    ref.invalidate(multiCurrencyMonthlySpendingDataProvider);
    ref.invalidate(multiCurrencyCountrySpendingComparisonProvider);
    ref.invalidate(currencyUsageSummaryProvider);
    ref.invalidate(dashboardCurrencyIndicatorProvider);
  }
}