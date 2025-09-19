/// Multi-Currency Chart Widget for Issue #132
/// 
/// This widget provides currency-aware chart visualization with proper
/// conversion indicators and multi-currency metadata display.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/models/chart_data_models.dart' as models;
import 'package:petrol_tracker/services/multi_currency_chart_data_service.dart';
import 'package:petrol_tracker/providers/multi_currency_chart_providers.dart';
import 'package:petrol_tracker/widgets/chart_webview.dart' as webview;

/// Multi-currency aware chart widget
class MultiCurrencyChart extends ConsumerWidget {
  final ChartType chartType;
  final ChartPeriod period;
  final DateRange? dateRange;
  final int? vehicleId;
  final void Function(models.ChartDataPoint)? onDataPointTap;

  const MultiCurrencyChart({
    super.key,
    required this.chartType,
    required this.period,
    this.dateRange,
    this.vehicleId,
    this.onDataPointTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartParams = ChartDataParams(
      chartType: chartType,
      period: period,
      dateRange: dateRange,
      vehicleId: vehicleId,
    );
    
    final chartDataAsync = ref.watch(multiCurrencyChartDataProvider(chartParams));
    final chartConfig = ref.watch(chartConfigurationProvider(chartType));
    
    return chartDataAsync.when(
      data: (data) => _buildChart(context, data, chartConfig),
      loading: () => const ChartLoadingWidget(),
      error: (error, stack) => ChartErrorWidget(
        error: error,
        onRetry: () => ref.refresh(multiCurrencyChartDataProvider(chartParams)),
      ),
    );
  }

  Widget _buildChart(
    BuildContext context,
    List<models.ChartDataPoint> data,
    models.ChartConfiguration config,
  ) {
    if (data.isEmpty) {
      return const ChartEmptyDataWidget();
    }

    return Column(
      children: [
        // Currency indicator header
        CurrencyChartHeader(
          primaryCurrency: config.primaryCurrency,
          originalCurrencies: _getOriginalCurrencies(data),
          showBreakdown: config.showCurrencyBreakdown,
          onCurrencyBreakdownTap: () => _showCurrencyBreakdown(context, data),
        ),
        
        // Chart visualization
        Expanded(
          child: webview.ChartWebView(
            data: _convertToWebViewData(data),
            config: webview.ChartConfig(
              type: config.chartType,
              primaryCurrency: config.primaryCurrency,
            ),
            onDataPointTap: onDataPointTap != null 
                ? (index) => onDataPointTap!(data[index])
                : null,
          ),
        ),
        
        // Chart legend and metadata
        if (config.showCurrencyBreakdown)
          ChartMetadataFooter(chartData: data),
      ],
    );
  }

  List<String> _getOriginalCurrencies(List<models.ChartDataPoint> data) {
    final currencies = <String>{};
    for (final point in data) {
      currencies.addAll(point.metadata.originalCurrencies);
    }
    return currencies.toList()..sort();
  }

  List<Map<String, dynamic>> _convertToWebViewData(List<models.ChartDataPoint> data) {
    return data.map((point) => {
      'date': point.date.toIso8601String(),
      'value': point.value,
      'label': point.label,
      'currency': point.metadata.currency,
      'entryCount': point.metadata.entryCount,
      'originalCurrencies': point.metadata.originalCurrencies,
    }).toList();
  }

  void _showCurrencyBreakdown(BuildContext context, List<models.ChartDataPoint> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CurrencyBreakdownSheet(chartData: data),
    );
  }
}

/// Currency indicator header for charts
class CurrencyChartHeader extends StatelessWidget {
  final String primaryCurrency;
  final List<String> originalCurrencies;
  final bool showBreakdown;
  final VoidCallback? onCurrencyBreakdownTap;

  const CurrencyChartHeader({
    super.key,
    required this.primaryCurrency,
    required this.originalCurrencies,
    this.showBreakdown = true,
    this.onCurrencyBreakdownTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasMultipleCurrencies = originalCurrencies.length > 1;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Amounts in $primaryCurrency',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          
          if (hasMultipleCurrencies) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.language,
                    size: 12,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${originalCurrencies.length} currencies',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const Spacer(),
          
          if (showBreakdown && hasMultipleCurrencies && onCurrencyBreakdownTap != null)
            IconButton(
              icon: const Icon(Icons.pie_chart_outline),
              iconSize: 20,
              onPressed: onCurrencyBreakdownTap,
              tooltip: 'Currency Breakdown',
              visualDensity: VisualDensity.compact,
            ),
        ],
      ),
    );
  }
}

/// Chart metadata footer
class ChartMetadataFooter extends StatelessWidget {
  final List<models.ChartDataPoint> chartData;

  const ChartMetadataFooter({
    super.key,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    final totalEntries = chartData.fold<int>(
      0,
      (sum, point) => sum + point.metadata.entryCount,
    );
    
    final allCurrencies = <String>{};
    for (final point in chartData) {
      allCurrencies.addAll(point.metadata.originalCurrencies);
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMetadataItem(
            context,
            Icons.receipt_long,
            'Entries',
            totalEntries.toString(),
          ),
          _buildMetadataItem(
            context,
            Icons.timeline,
            'Periods',
            chartData.length.toString(),
          ),
          _buildMetadataItem(
            context,
            Icons.currency_exchange,
            'Currencies',
            allCurrencies.length.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

/// Currency breakdown bottom sheet
class CurrencyBreakdownSheet extends StatelessWidget {
  final List<models.ChartDataPoint> chartData;

  const CurrencyBreakdownSheet({
    super.key,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    final currencyBreakdown = _calculateCurrencyBreakdown();
    
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Currency Breakdown',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              
              // Currency breakdown list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: currencyBreakdown.length,
                  itemBuilder: (context, index) {
                    final currency = currencyBreakdown.keys.elementAt(index);
                    final breakdown = currencyBreakdown[currency]!;
                    
                    return CurrencyBreakdownTile(
                      currency: currency,
                      breakdown: breakdown,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, CurrencyBreakdownData> _calculateCurrencyBreakdown() {
    final breakdown = <String, CurrencyBreakdownData>{};
    
    for (final point in chartData) {
      for (final currency in point.metadata.originalCurrencies) {
        if (breakdown.containsKey(currency)) {
          breakdown[currency] = breakdown[currency]!.copyWith(
            totalPoints: breakdown[currency]!.totalPoints + 1,
            totalEntries: breakdown[currency]!.totalEntries + point.metadata.entryCount,
          );
        } else {
          breakdown[currency] = CurrencyBreakdownData(
            currency: currency,
            totalPoints: 1,
            totalEntries: point.metadata.entryCount,
          );
        }
      }
    }
    
    return breakdown;
  }
}

/// Currency breakdown tile
class CurrencyBreakdownTile extends StatelessWidget {
  final String currency;
  final CurrencyBreakdownData breakdown;

  const CurrencyBreakdownTile({
    super.key,
    required this.currency,
    required this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  currency,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getCurrencyName(currency),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${breakdown.totalEntries} entries • ${breakdown.totalPoints} data points',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrencyName(String currencyCode) {
    const currencyNames = {
      'USD': 'US Dollar',
      'EUR': 'Euro',
      'GBP': 'British Pound',
      'CAD': 'Canadian Dollar',
      'AUD': 'Australian Dollar',
      'JPY': 'Japanese Yen',
      'CHF': 'Swiss Franc',
      'CNY': 'Chinese Yuan',
      'INR': 'Indian Rupee',
      'BRL': 'Brazilian Real',
      'MXN': 'Mexican Peso',
      'SGD': 'Singapore Dollar',
      'HKD': 'Hong Kong Dollar',
      'NZD': 'New Zealand Dollar',
      'SEK': 'Swedish Krona',
      'NOK': 'Norwegian Krone',
      'DKK': 'Danish Krone',
      'PLN': 'Polish Złoty',
      'CZK': 'Czech Koruna',
      'HUF': 'Hungarian Forint',
    };
    
    return currencyNames[currencyCode] ?? currencyCode;
  }
}

/// Chart loading widget
class ChartLoadingWidget extends StatelessWidget {
  const ChartLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading chart data...'),
          ],
        ),
      ),
    );
  }
}

/// Chart error widget
class ChartErrorWidget extends StatelessWidget {
  final dynamic error;
  final VoidCallback? onRetry;

  const ChartErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
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
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load chart data',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Chart empty data widget
class ChartEmptyDataWidget extends StatelessWidget {
  const ChartEmptyDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No data available',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add some fuel entries to see chart data',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Currency breakdown data class
class CurrencyBreakdownData {
  final String currency;
  final int totalPoints;
  final int totalEntries;

  const CurrencyBreakdownData({
    required this.currency,
    required this.totalPoints,
    required this.totalEntries,
  });

  CurrencyBreakdownData copyWith({
    String? currency,
    int? totalPoints,
    int? totalEntries,
  }) {
    return CurrencyBreakdownData(
      currency: currency ?? this.currency,
      totalPoints: totalPoints ?? this.totalPoints,
      totalEntries: totalEntries ?? this.totalEntries,
    );
  }
}