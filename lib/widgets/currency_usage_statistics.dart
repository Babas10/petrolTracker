/// Currency usage statistics widgets for multi-currency cost analysis
/// 
/// These widgets provide detailed views of currency usage patterns and
/// conversion statistics for Issue #129 implementation.
library;

import 'package:flutter/material.dart';
import 'package:petrol_tracker/models/multi_currency_cost_analysis.dart';

/// Detailed currency usage statistics widget with charts and breakdowns
class CurrencyUsageStatistics extends StatefulWidget {
  final CurrencyUsageSummary? currencyUsage;
  final MultiCurrencySpendingStats? spendingStats;
  final String primaryCurrency;
  final bool showConversionDetails;

  const CurrencyUsageStatistics({
    super.key,
    this.currencyUsage,
    this.spendingStats,
    required this.primaryCurrency,
    this.showConversionDetails = true,
  });

  @override
  State<CurrencyUsageStatistics> createState() => _CurrencyUsageStatisticsState();
}

class _CurrencyUsageStatisticsState extends State<CurrencyUsageStatistics> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(context),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUsageOverview(context),
              _buildConversionDetails(context),
              _buildCurrencyBreakdown(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(6),
        ),
        labelColor: Theme.of(context).colorScheme.onPrimary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Usage', icon: Icon(Icons.pie_chart, size: 18)),
          Tab(text: 'Conversions', icon: Icon(Icons.swap_horiz, size: 18)),
          Tab(text: 'Breakdown', icon: Icon(Icons.bar_chart, size: 18)),
        ],
      ),
    );
  }

  Widget _buildUsageOverview(BuildContext context) {
    if (widget.currencyUsage == null) {
      return _buildLoadingState(context);
    }

    final usage = widget.currencyUsage!;
    final currencies = usage.currenciesByUsage;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUsageSummaryCard(context, usage),
          const SizedBox(height: 16),
          _buildCurrencyUsageChart(context, usage),
          const SizedBox(height: 16),
          _buildTopCurrenciesList(context, currencies.take(5).toList(), usage),
        ],
      ),
    );
  }

  Widget _buildConversionDetails(BuildContext context) {
    if (widget.spendingStats == null) {
      return _buildLoadingState(context);
    }

    final stats = widget.spendingStats!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConversionSummaryCard(context, stats),
          const SizedBox(height: 16),
          if (stats.hasConversionFailures)
            _buildFailedConversionsCard(context, stats),
          const SizedBox(height: 16),
          _buildConversionRatesList(context, stats),
        ],
      ),
    );
  }

  Widget _buildCurrencyBreakdown(BuildContext context) {
    if (widget.spendingStats == null) {
      return _buildLoadingState(context);
    }

    final stats = widget.spendingStats!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTotalSpendingCard(context, stats),
          const SizedBox(height: 16),
          _buildCurrencyTotalsChart(context, stats.currencyBreakdown),
        ],
      ),
    );
  }

  Widget _buildUsageSummaryCard(BuildContext context, CurrencyUsageSummary usage) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Currency Usage Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Total Entries',
                    usage.totalEntries.toString(),
                    Icons.receipt_long,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Currencies Used',
                    usage.currencyEntryCount.length.toString(),
                    Icons.language,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Primary Currency',
                    usage.primaryCurrency,
                    Icons.star,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Most Used',
                    usage.mostUsedCurrency ?? 'None',
                    Icons.trending_up,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyUsageChart(BuildContext context, CurrencyUsageSummary usage) {
    final percentages = usage.currencyUsagePercentages;
    final currencies = usage.currenciesByUsage.take(6).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usage Distribution',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildPieChart(context, currencies, percentages),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(
    BuildContext context,
    List<String> currencies,
    Map<String, double> percentages,
  ) {
    // Simple pie chart visualization using containers and progress indicators
    return Column(
      children: currencies.map((currency) {
        final percentage = percentages[currency] ?? 0;
        final color = _getCurrencyColor(currency, currencies.indexOf(currency));
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Text(
                  currency,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 50,
                child: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopCurrenciesList(
    BuildContext context,
    List<String> currencies,
    CurrencyUsageSummary usage,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Currencies',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...currencies.map((currency) {
              final entryCount = usage.currencyEntryCount[currency] ?? 0;
              final percentage = usage.currencyUsagePercentages[currency] ?? 0;
              final totalAmount = usage.currencyTotalAmounts[currency];
              final isPrimary = currency == widget.primaryCurrency;

              return _buildCurrencyListItem(
                context,
                currency: currency,
                entryCount: entryCount,
                percentage: percentage,
                totalAmount: totalAmount,
                isPrimary: isPrimary,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyListItem(
    BuildContext context, {
    required String currency,
    required int entryCount,
    required double percentage,
    required CurrencyAwareAmount? totalAmount,
    required bool isPrimary,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 32,
            decoration: BoxDecoration(
              color: isPrimary 
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: isPrimary ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ) : null,
            ),
            child: Center(
              child: Text(
                currency,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isPrimary 
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
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
                      '$entryCount entries',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (totalAmount != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    totalAmount.toDisplayString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isPrimary) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.star,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConversionSummaryCard(BuildContext context, MultiCurrencySpendingStats stats) {
    final failedCount = stats.failedCurrencies.length;
    final totalCurrencies = stats.totalCurrencies;
    final successCount = totalCurrencies - failedCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conversion Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Successful',
                    successCount.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Failed',
                    failedCount.toString(),
                    Icons.error,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Success Rate',
                    totalCurrencies > 0 
                        ? '${((successCount / totalCurrencies) * 100).toStringAsFixed(1)}%'
                        : '0%',
                    Icons.trending_up,
                    totalCurrencies > 0 && successCount / totalCurrencies > 0.8 
                        ? Colors.green 
                        : Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'Target Currency',
                    stats.primaryCurrency,
                    Icons.flag,
                    Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailedConversionsCard(BuildContext context, MultiCurrencySpendingStats stats) {
    final failedCurrencies = stats.failedCurrencies;

    return Card(
      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Conversion Failures',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'The following currencies could not be converted to ${stats.primaryCurrency}:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: failedCurrencies.map((currency) {
                return Chip(
                  label: Text(currency),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              'Original amounts will be displayed for these currencies.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionRatesList(BuildContext context, MultiCurrencySpendingStats stats) {
    // This would show exchange rates used for conversions
    // For now, show a placeholder
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exchange Rates Used',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Exchange rates are fetched daily from the currency service.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'All conversions use the most recent available rates.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSpendingCard(BuildContext context, MultiCurrencySpendingStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Spending by Currency',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Spending',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Text(
                        stats.totalSpent.toDisplayString(),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.account_balance_wallet,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyTotalsChart(
    BuildContext context,
    Map<String, CurrencyAwareAmount> currencyBreakdown,
  ) {
    final sortedEntries = currencyBreakdown.entries.toList()
      ..sort((a, b) => b.value.displayAmount.compareTo(a.value.displayAmount));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Currency',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...sortedEntries.map((entry) {
              final currency = entry.key;
              final amount = entry.value;
              final isPrimary = currency == widget.primaryCurrency;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isPrimary 
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                        border: isPrimary ? Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ) : null,
                      ),
                      child: Center(
                        child: Text(
                          currency,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isPrimary 
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurfaceVariant,
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
                            amount.toDisplayString(),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (amount.isConverted && widget.showConversionDetails) ...[
                            const SizedBox(height: 2),
                            Text(
                              'from ${amount.originalAmount.toStringAsFixed(2)} ${amount.originalCurrency}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          if (amount.conversionFailed) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Conversion failed',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isPrimary) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.star,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
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
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Color _getCurrencyColor(String currency, int index) {
    const colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[index % colors.length];
  }
}