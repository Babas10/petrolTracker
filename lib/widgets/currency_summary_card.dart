/// Currency summary card widget for multi-currency cost analysis
/// 
/// This widget displays currency usage statistics and conversion transparency
/// for Issue #129 multi-currency dashboard implementation.
library;

import 'package:flutter/material.dart';
import 'package:petrol_tracker/models/multi_currency_cost_analysis.dart';

/// Card showing currency usage summary and conversion details
class CurrencySummaryCard extends StatelessWidget {
  final CurrencyUsageSummary? currencyUsage;
  final String primaryCurrency;
  final bool showConversionDetails;
  final VoidCallback? onTap;

  const CurrencySummaryCard({
    super.key,
    this.currencyUsage,
    required this.primaryCurrency,
    this.showConversionDetails = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (currencyUsage == null) {
      return _buildLoadingCard(context);
    }

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildCurrencyIndicator(context),
              const SizedBox(height: 16),
              _buildUsageBreakdown(context),
              if (showConversionDetails && currencyUsage!.isMultiCurrency) ...[
                const SizedBox(height: 16),
                _buildConversionSummary(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.account_balance_wallet,
            size: 20,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Currency Usage',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Primary: $primaryCurrency',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (currencyUsage!.isMultiCurrency)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Multi-Currency',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCurrencyIndicator(BuildContext context) {
    final totalEntries = currencyUsage!.totalEntries;
    final currencies = currencyUsage!.currenciesByUsage;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.pie_chart,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${currencies.length} ${currencies.length == 1 ? 'Currency' : 'Currencies'} Used',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Across $totalEntries entries',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            currencies.length.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageBreakdown(BuildContext context) {
    final currencies = currencyUsage!.currenciesByUsage;
    final percentages = currencyUsage!.currencyUsagePercentages;
    final totalAmounts = currencyUsage!.currencyTotalAmounts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Usage Breakdown',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ...currencies.take(5).map((currency) {
          final percentage = percentages[currency] ?? 0;
          final entryCount = currencyUsage!.currencyEntryCount[currency] ?? 0;
          final totalAmount = totalAmounts[currency];
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildCurrencyUsageRow(
              context,
              currency: currency,
              percentage: percentage,
              entryCount: entryCount,
              totalAmount: totalAmount,
              isPrimary: currency == primaryCurrency,
            ),
          );
        }),
        if (currencies.length > 5)
          Text(
            '+${currencies.length - 5} more currencies',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildCurrencyUsageRow(
    BuildContext context, {
    required String currency,
    required double percentage,
    required int entryCount,
    required CurrencyAwareAmount? totalAmount,
    required bool isPrimary,
  }) {
    return Row(
      children: [
        // Currency indicator
        Container(
          width: 32,
          height: 24,
          decoration: BoxDecoration(
            color: isPrimary 
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
            border: isPrimary ? Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 1,
            ) : null,
          ),
          child: Center(
            child: Text(
              currency,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isPrimary 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Usage bar
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$entryCount entries',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPrimary 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                  ),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Amount
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (totalAmount != null) ...[
              Text(
                totalAmount.toDisplayString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (totalAmount.isConverted && showConversionDetails)
                Text(
                  'from ${totalAmount.originalAmount.toStringAsFixed(0)} ${totalAmount.originalCurrency}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildConversionSummary(BuildContext context) {
    final failedCurrencies = currencyUsage!.currencyTotalAmounts.values
        .where((amount) => amount.conversionFailed)
        .length;
    
    final successfulConversions = currencyUsage!.currencyTotalAmounts.values
        .where((amount) => amount.isConverted)
        .length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: failedCurrencies > 0 
            ? Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.3)
            : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: failedCurrencies > 0
              ? Theme.of(context).colorScheme.error.withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                failedCurrencies > 0 ? Icons.warning_amber : Icons.check_circle,
                size: 16,
                color: failedCurrencies > 0
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Conversion Status',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (failedCurrencies > 0) ...[
            Text(
              '⚠️ $failedCurrencies conversion${failedCurrencies == 1 ? '' : 's'} failed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            Text(
              'Original amounts will be displayed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ] else ...[
            Text(
              '✅ All amounts converted to $primaryCurrency',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (successfulConversions > 0)
              Text(
                '$successfulConversions conversion${successfulConversions == 1 ? '' : 's'} applied',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact currency indicator for showing primary currency in headers
class CurrencyIndicatorChip extends StatelessWidget {
  final String currency;
  final String? label;
  final VoidCallback? onTap;
  final bool showConversionWarning;

  const CurrencyIndicatorChip({
    super.key,
    required this.currency,
    this.label,
    this.onTap,
    this.showConversionWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          border: showConversionWarning ? Border.all(
            color: Theme.of(context).colorScheme.error,
            width: 1,
          ) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showConversionWarning) ...[
              Icon(
                Icons.warning_amber,
                size: 14,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              Icons.currency_exchange,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 4),
            Text(
              currency,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget showing conversion transparency for a specific amount
class ConversionTransparencyWidget extends StatelessWidget {
  final CurrencyAwareAmount amount;
  final bool showDetails;

  const ConversionTransparencyWidget({
    super.key,
    required this.amount,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!amount.needsConversion) {
      return Text(
        amount.toDisplayString(),
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          amount.toDisplayString(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        if (showDetails) ...[
          const SizedBox(height: 2),
          if (amount.conversionFailed) ...[
            Text(
              'Conversion failed - showing original amount',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else if (amount.isConverted) ...[
            Text(
              'from ${amount.originalAmount.toStringAsFixed(2)} ${amount.originalCurrency}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (amount.exchangeRate != null)
              Text(
                'Rate: ${amount.exchangeRate!.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
          ],
        ],
      ],
    );
  }
}