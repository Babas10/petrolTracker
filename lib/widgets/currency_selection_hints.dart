import 'package:flutter/material.dart';
import 'package:petrol_tracker/services/country_currency_service.dart';

/// Widget that provides helpful hints about currency selection
/// 
/// Shows contextual information about the selected currency and country,
/// helping users understand their currency choice and providing
/// educational information about currency usage in different countries.
class CurrencySelectionHints extends StatelessWidget {
  final String? selectedCountry;
  final String? selectedCurrency;
  final bool showDetailed;

  const CurrencySelectionHints({
    super.key,
    this.selectedCountry,
    this.selectedCurrency,
    this.showDetailed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCountry == null || selectedCurrency == null) {
      return const SizedBox.shrink();
    }

    final hintInfo = _getHintInfo();
    if (hintInfo == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hintInfo.backgroundColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hintInfo.backgroundColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hintInfo.icon,
            size: 16,
            color: hintInfo.backgroundColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hintInfo.title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: hintInfo.backgroundColor,
                  ),
                ),
                if (hintInfo.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    hintInfo.description!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                if (showDetailed && hintInfo.detailedInfo != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    hintInfo.detailedInfo!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  CurrencyHintInfo? _getHintInfo() {
    final primaryCurrency = CountryCurrencyService.getPrimaryCurrency(selectedCountry!);
    final isMultiCurrency = CountryCurrencyService.isMultiCurrencyCountry(selectedCountry!);
    final currencyInfo = CountryCurrencyService.getCurrencyInfo(selectedCurrency!);
    
    if (selectedCurrency == primaryCurrency) {
      // Perfect match - using primary currency
      return CurrencyHintInfo(
        icon: Icons.check_circle,
        backgroundColor: Colors.green,
        title: 'Perfect choice!',
        description: '$selectedCurrency is the primary currency in $selectedCountry.',
        detailedInfo: currencyInfo != null 
          ? 'Symbol: ${currencyInfo.symbol} • Decimal places: ${currencyInfo.decimalPlaces}'
          : null,
      );
    }
    
    if (isMultiCurrency && selectedCurrency != primaryCurrency) {
      final allCurrencies = CountryCurrencyService.getAllCountryCurrencies(selectedCountry!);
      if (allCurrencies.contains(selectedCurrency!)) {
        // Good choice - commonly accepted currency
        return CurrencyHintInfo(
          icon: Icons.thumb_up,
          backgroundColor: Colors.blue,
          title: 'Good choice!',
          description: '$selectedCurrency is commonly accepted in $selectedCountry alongside $primaryCurrency.',
          detailedInfo: 'This currency is widely used in tourist areas and international businesses.',
        );
      }
    }
    
    // Using different currency - will need conversion
    if (primaryCurrency != null) {
      return CurrencyHintInfo(
        icon: Icons.info,
        backgroundColor: Colors.orange,
        title: 'Currency conversion',
        description: 'Using $selectedCurrency in $selectedCountry. Primary currency is $primaryCurrency.',
        detailedInfo: 'Your amount will be displayed in both currencies for easy comparison.',
      );
    }
    
    // Unknown country or currency combination
    return CurrencyHintInfo(
      icon: Icons.help_outline,
      backgroundColor: Colors.grey,
      title: 'International currency',
      description: 'Using $selectedCurrency for this entry.',
      detailedInfo: null,
    );
  }
}

/// Information about a currency hint
class CurrencyHintInfo {
  final IconData icon;
  final Color backgroundColor;
  final String title;
  final String? description;
  final String? detailedInfo;

  const CurrencyHintInfo({
    required this.icon,
    required this.backgroundColor,
    required this.title,
    this.description,
    this.detailedInfo,
  });
}

/// Advanced currency hints with conversion rates and regional information
class AdvancedCurrencyHints extends StatelessWidget {
  final String? selectedCountry;
  final String? selectedCurrency;
  final String? userPrimaryCurrency;

  const AdvancedCurrencyHints({
    super.key,
    this.selectedCountry,
    this.selectedCurrency,
    this.userPrimaryCurrency,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCountry == null || selectedCurrency == null) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // Basic hint
        CurrencySelectionHints(
          selectedCountry: selectedCountry,
          selectedCurrency: selectedCurrency,
          showDetailed: true,
        ),
        
        // Additional regional information
        if (_shouldShowRegionalInfo()) ...[
          const SizedBox(height: 8),
          _buildRegionalInfo(context),
        ],
      ],
    );
  }

  bool _shouldShowRegionalInfo() {
    final isMultiCurrency = CountryCurrencyService.isMultiCurrencyCountry(selectedCountry!);
    return isMultiCurrency && selectedCurrency != null;
  }

  Widget _buildRegionalInfo(BuildContext context) {
    final allCurrencies = CountryCurrencyService.getAllCountryCurrencies(selectedCountry!);
    final otherCurrencies = allCurrencies.where((c) => c != selectedCurrency).toList();

    if (otherCurrencies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.language,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Other currencies in $selectedCountry',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: otherCurrencies.map((currency) {
              final currencyInfo = CountryCurrencyService.getCurrencyInfo(currency);
              return Chip(
                label: Text(
                  currency,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                avatar: Text(
                  currencyInfo?.symbol ?? currency[0],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}