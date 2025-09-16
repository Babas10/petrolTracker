import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/services/currency_service.dart' show CurrencyConversion;
import 'package:petrol_tracker/utils/currency_formatter.dart';
import 'package:petrol_tracker/providers/currency_providers.dart';

/// A widget that displays real-time currency conversion preview
/// 
/// Shows conversion information when the selected currency differs from
/// the user's primary currency. Provides visual feedback about exchange
/// rates and converted amounts to help users understand the transaction value.
class ConversionPreviewCard extends ConsumerWidget {
  final String originalAmount;
  final String fromCurrency;
  final String toCurrency;
  final EdgeInsets? margin;
  final bool showRate;
  final bool showTimestamp;

  const ConversionPreviewCard({
    super.key,
    required this.originalAmount,
    required this.fromCurrency,
    required this.toCurrency,
    this.margin,
    this.showRate = true,
    this.showTimestamp = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Don't show preview if currencies are the same
    if (fromCurrency == toCurrency) {
      return const SizedBox.shrink();
    }

    // Don't show preview if amount is empty or invalid
    if (originalAmount.isEmpty) {
      return const SizedBox.shrink();
    }

    final amount = double.tryParse(originalAmount);
    if (amount == null || amount <= 0) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<CurrencyConversion?>(
      future: ref.read(currencyServiceProvider).convertAmount(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard(context);
        }

        if (snapshot.hasError) {
          return _buildErrorCard(context, snapshot.error.toString());
        }

        if (snapshot.hasData && snapshot.data != null) {
          return _buildConversionCard(context, snapshot.data!);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildConversionCard(BuildContext context, CurrencyConversion conversion) {
    final theme = Theme.of(context);
    
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and title
              Row(
                children: [
                  Icon(
                    Icons.currency_exchange,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Conversion Preview',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (showTimestamp)
                    Text(
                      _formatTimestamp(conversion.rateDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Conversion display
              Row(
                children: [
                  // Original amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatAmount(
                          conversion.originalAmount,
                          conversion.originalCurrency,
                        ),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Arrow
                  Icon(
                    Icons.arrow_forward,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Converted amount
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'To',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatAmount(
                            conversion.convertedAmount,
                            conversion.targetCurrency,
                          ),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Exchange rate info
              if (showRate) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rate: 1 ${conversion.originalCurrency} = ${_formatRate(conversion.exchangeRate)} ${conversion.targetCurrency}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text(
              'Converting $fromCurrency to $toCurrency...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    final theme = Theme.of(context);
    
    return Card(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      elevation: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.error.withOpacity(0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: theme.colorScheme.error,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Conversion Error',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    Text(
                      'Unable to fetch exchange rate. You can still save the entry.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRate(double rate) {
    if (rate >= 1) {
      return rate.toStringAsFixed(4);
    } else {
      return rate.toStringAsFixed(6);
    }
  }

  String _formatTimestamp(DateTime rateDate) {
    final now = DateTime.now();
    final difference = now.difference(rateDate);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

/// A compact inline conversion preview for use in form fields
class InlineConversionPreview extends ConsumerWidget {
  final String originalAmount;
  final String fromCurrency;
  final String toCurrency;

  const InlineConversionPreview({
    super.key,
    required this.originalAmount,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (fromCurrency == toCurrency || originalAmount.isEmpty) {
      return const SizedBox.shrink();
    }

    final amount = double.tryParse(originalAmount);
    if (amount == null || amount <= 0) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<CurrencyConversion?>(
      future: ref.read(currencyServiceProvider).convertAmount(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          final conversion = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '≈ ${CurrencyFormatter.formatAmount(conversion.convertedAmount, toCurrency)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Converting...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}