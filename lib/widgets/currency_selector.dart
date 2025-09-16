import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/utils/currency_validator.dart';
import 'package:petrol_tracker/services/country_currency_service.dart';
import 'package:petrol_tracker/providers/currency_settings_providers.dart';

/// A dropdown widget for selecting currencies with smart filtering and validation
/// 
/// This widget provides an intelligent currency selection experience by:
/// - Filtering currencies based on the selected country
/// - Prioritizing relevant currencies (country primary, user primary, major currencies)
/// - Providing proper validation and error handling
/// - Showing currency codes in a clean, scannable format
/// - Supporting major currency highlighting for better UX
class CurrencySelector extends ConsumerWidget {
  final String? selectedCurrency;
  final String? selectedCountry;
  final ValueChanged<String?> onChanged;
  final String? errorText;
  final bool enabled;
  final String? helperText;

  const CurrencySelector({
    super.key,
    this.selectedCurrency,
    this.selectedCountry,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    this.helperText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencySettingsAsync = ref.watch(currencySettingsNotifierProvider);
    
    return currencySettingsAsync.when(
      data: (settings) => _buildCurrencyDropdown(context, settings.primaryCurrency),
      loading: () => _buildLoadingDropdown(context),
      error: (_, __) => _buildErrorDropdown(context),
    );
  }

  Widget _buildCurrencyDropdown(BuildContext context, String userPrimaryCurrency) {
    final filteredCurrencies = CountryCurrencyService.getFilteredCurrencies(
      selectedCountry, 
      userPrimaryCurrency,
    );

    return DropdownButtonFormField<String>(
      value: selectedCurrency,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: 'Currency *',
        prefixIcon: const Icon(Icons.attach_money),
        helperText: helperText ?? _getHelperText(),
        errorText: errorText,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
      ),
      items: filteredCurrencies.map((currency) {
        final isMajor = CurrencyValidator.isMajorCurrency(currency);
        final isCountryPrimary = selectedCountry != null && 
            CountryCurrencyService.getPrimaryCurrency(selectedCountry!) == currency;
        
        return DropdownMenuItem<String>(
          value: currency,
          child: Row(
            children: [
              // Currency code
              Text(
                currency,
                style: TextStyle(
                  fontWeight: _getCurrencyWeight(isMajor, isCountryPrimary),
                  color: _getCurrencyColor(context, isCountryPrimary),
                ),
              ),
              const SizedBox(width: 8),
              // Currency symbol
              Text(
                '(${CurrencyValidator.getCurrencySymbol(currency)})',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              // Country primary indicator
              if (isCountryPrimary) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ],
          ),
        );
      }).toList(),
      validator: validateCurrency,
      isExpanded: true,
      hint: Text(
        'Select currency',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildLoadingDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: null,
      onChanged: null,
      decoration: InputDecoration(
        labelText: 'Currency *',
        prefixIcon: const Icon(Icons.attach_money),
        helperText: 'Loading currencies...',
        border: const OutlineInputBorder(),
        suffixIcon: const SizedBox(
          width: 20,
          height: 20,
          child: Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      items: const [],
      hint: const Text('Loading...'),
    );
  }

  Widget _buildErrorDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedCurrency,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: 'Currency *',
        prefixIcon: const Icon(Icons.attach_money),
        helperText: helperText ?? 'Using default currency list',
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
      items: CurrencyValidator.supportedCurrencies.map((currency) {
        return DropdownMenuItem<String>(
          value: currency,
          child: Text(currency),
        );
      }).toList(),
      validator: validateCurrency,
      isExpanded: true,
      hint: const Text('Select currency'),
    );
  }

  String? _getHelperText() {
    if (selectedCountry != null) {
      final primaryCurrency = CountryCurrencyService.getPrimaryCurrency(selectedCountry!);
      if (primaryCurrency != null) {
        return 'Primary currency in $selectedCountry: $primaryCurrency';
      }
    }
    return 'Currency for this transaction';
  }

  FontWeight _getCurrencyWeight(bool isMajor, bool isCountryPrimary) {
    if (isCountryPrimary) return FontWeight.w600;
    if (isMajor) return FontWeight.w500;
    return FontWeight.normal;
  }

  Color? _getCurrencyColor(BuildContext context, bool isCountryPrimary) {
    if (isCountryPrimary) {
      return Theme.of(context).colorScheme.primary;
    }
    return null;
  }

  /// Validates the selected currency
  static String? validateCurrency(String? currency) {
    if (currency == null || currency.isEmpty) {
      return 'Please select a currency';
    }
    
    if (!CurrencyValidator.isValidCurrency(currency)) {
      return 'Invalid currency selected';
    }
    
    return null;
  }

  /// Gets smart default currency based on country and user settings
  static String getSmartDefault({
    String? selectedCountry,
    required String userPrimaryCurrency,
  }) {
    return CountryCurrencyService.getSmartDefault(
      selectedCountry, 
      userPrimaryCurrency,
    );
  }

  /// Gets filtered currencies for external use
  static List<String> getFilteredCurrencies({
    String? selectedCountry,
    required String userPrimaryCurrency,
  }) {
    return CountryCurrencyService.getFilteredCurrencies(
      selectedCountry, 
      userPrimaryCurrency,
    );
  }
}

/// A simplified currency selector for cases where minimal UI is preferred
class SimpleCurrencySelector extends StatelessWidget {
  final String? selectedCurrency;
  final List<String> availableCurrencies;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const SimpleCurrencySelector({
    super.key,
    this.selectedCurrency,
    required this.availableCurrencies,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedCurrency,
      onChanged: enabled ? onChanged : null,
      underline: const SizedBox(),
      items: availableCurrencies.map((currency) {
        final isMajor = CurrencyValidator.isMajorCurrency(currency);
        
        return DropdownMenuItem<String>(
          value: currency,
          child: Text(
            currency,
            style: TextStyle(
              fontWeight: isMajor ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
      hint: const Text('Currency'),
      isExpanded: true,
    );
  }
}