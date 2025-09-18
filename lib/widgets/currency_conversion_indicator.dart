import 'package:flutter/material.dart';

/// Visual indicator for currency conversion status with different states:
/// - Converting (loading animation)
/// - Converted successfully (exchange icon with currencies)
/// - Conversion failed (error icon)
/// - No conversion needed (not displayed)
class CurrencyConversionIndicator extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final bool isConverting;
  final bool hasError;
  final double? exchangeRate;
  final VoidCallback? onTap;

  const CurrencyConversionIndicator({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    this.isConverting = false,
    this.hasError = false,
    this.exchangeRate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show indicator if currencies are the same
    if (fromCurrency == toCurrency) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: _getBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(context),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(context),
            const SizedBox(width: 4),
            _buildCurrencyText(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (isConverting) {
      return SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (hasError) {
      return Icon(
        Icons.error_outline,
        size: 12,
        color: Theme.of(context).colorScheme.error,
      );
    }

    return Icon(
      Icons.currency_exchange,
      size: 12,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildCurrencyText(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      color: _getTextColor(context),
      fontWeight: FontWeight.w500,
      fontSize: 10,
    );

    if (isConverting) {
      return Text(
        '$fromCurrency→$toCurrency',
        style: textStyle,
      );
    }

    if (hasError) {
      return Text(
        'Error',
        style: textStyle?.copyWith(
          color: Theme.of(context).colorScheme.error,
        ),
      );
    }

    return Text(
      '$fromCurrency→$toCurrency',
      style: textStyle,
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (hasError) {
      return Theme.of(context).colorScheme.errorContainer;
    }
    if (isConverting) {
      return Theme.of(context).colorScheme.surfaceVariant;
    }
    return Theme.of(context).colorScheme.primaryContainer;
  }

  Color _getBorderColor(BuildContext context) {
    if (hasError) {
      return Theme.of(context).colorScheme.error.withOpacity(0.3);
    }
    if (isConverting) {
      return Theme.of(context).colorScheme.outline.withOpacity(0.3);
    }
    return Theme.of(context).colorScheme.primary.withOpacity(0.3);
  }

  Color _getTextColor(BuildContext context) {
    if (hasError) {
      return Theme.of(context).colorScheme.onErrorContainer;
    }
    if (isConverting) {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
    return Theme.of(context).colorScheme.onPrimaryContainer;
  }
}

/// Compact version of the currency conversion indicator for use in tight spaces
class CompactCurrencyConversionIndicator extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final bool isConverting;
  final bool hasError;
  final VoidCallback? onTap;

  const CompactCurrencyConversionIndicator({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    this.isConverting = false,
    this.hasError = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show indicator if currencies are the same
    if (fromCurrency == toCurrency) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: _getBackgroundColor(context),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _buildIcon(context),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (isConverting) {
      return SizedBox(
        width: 10,
        height: 10,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (hasError) {
      return Icon(
        Icons.error_outline,
        size: 10,
        color: Theme.of(context).colorScheme.error,
      );
    }

    return Icon(
      Icons.currency_exchange,
      size: 10,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (hasError) {
      return Theme.of(context).colorScheme.errorContainer;
    }
    if (isConverting) {
      return Theme.of(context).colorScheme.surfaceVariant;
    }
    return Theme.of(context).colorScheme.primaryContainer;
  }
}

/// Extended currency conversion indicator with exchange rate display
class DetailedCurrencyConversionIndicator extends StatelessWidget {
  final String fromCurrency;
  final String toCurrency;
  final bool isConverting;
  final bool hasError;
  final double? exchangeRate;
  final String? errorMessage;
  final VoidCallback? onTap;
  final VoidCallback? onRetry;

  const DetailedCurrencyConversionIndicator({
    super.key,
    required this.fromCurrency,
    required this.toCurrency,
    this.isConverting = false,
    this.hasError = false,
    this.exchangeRate,
    this.errorMessage,
    this.onTap,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show indicator if currencies are the same
    if (fromCurrency == toCurrency) {
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: _getBackgroundColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(context),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIcon(context),
                const SizedBox(width: 6),
                Text(
                  '$fromCurrency → $toCurrency',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _getTextColor(context),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (hasError && onRetry != null) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: onRetry,
                    child: Icon(
                      Icons.refresh,
                      size: 14,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
            if (exchangeRate != null && !isConverting && !hasError) ...[
              const SizedBox(height: 2),
              Text(
                'Rate: ${exchangeRate!.toStringAsFixed(4)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: _getTextColor(context).withOpacity(0.7),
                  fontSize: 9,
                ),
              ),
            ],
            if (hasError && errorMessage != null) ...[
              const SizedBox(height: 2),
              Text(
                errorMessage!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 9,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (isConverting) {
      return SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (hasError) {
      return Icon(
        Icons.error_outline,
        size: 14,
        color: Theme.of(context).colorScheme.error,
      );
    }

    return Icon(
      Icons.currency_exchange,
      size: 14,
      color: Theme.of(context).colorScheme.primary,
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (hasError) {
      return Theme.of(context).colorScheme.errorContainer;
    }
    if (isConverting) {
      return Theme.of(context).colorScheme.surfaceVariant;
    }
    return Theme.of(context).colorScheme.primaryContainer;
  }

  Color _getBorderColor(BuildContext context) {
    if (hasError) {
      return Theme.of(context).colorScheme.error.withOpacity(0.3);
    }
    if (isConverting) {
      return Theme.of(context).colorScheme.outline.withOpacity(0.3);
    }
    return Theme.of(context).colorScheme.primary.withOpacity(0.3);
  }

  Color _getTextColor(BuildContext context) {
    if (hasError) {
      return Theme.of(context).colorScheme.onErrorContainer;
    }
    if (isConverting) {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
    return Theme.of(context).colorScheme.onPrimaryContainer;
  }
}