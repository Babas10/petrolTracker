import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/services/country_currency_service.dart';
import 'package:petrol_tracker/services/smart_currency_provider.dart';
import 'package:petrol_tracker/services/currency_usage_tracker.dart';
import 'package:petrol_tracker/providers/currency_settings_providers.dart';
import 'package:petrol_tracker/utils/currency_validator.dart';

/// Smart currency selector with dynamic filtering based on country selection
/// 
/// This widget provides an intelligent currency selection experience by:
/// - Filtering currencies based on the selected country in real-time
/// - Learning from user preferences and usage patterns
/// - Showing visual indicators for recommended currencies
/// - Providing option to expand to all currencies when needed
/// - Maintaining smooth performance with optimized filtering
class SmartCurrencySelector extends ConsumerStatefulWidget {
  final String? selectedCountry;
  final String? selectedCurrency;
  final Function(String?) onCurrencyChanged;
  final String? errorText;
  final String? helperText;
  final bool enabled;

  const SmartCurrencySelector({
    super.key,
    this.selectedCountry,
    this.selectedCurrency,
    required this.onCurrencyChanged,
    this.errorText,
    this.helperText,
    this.enabled = true,
  });

  @override
  ConsumerState<SmartCurrencySelector> createState() => _SmartCurrencySelectorState();
}

class _SmartCurrencySelectorState extends ConsumerState<SmartCurrencySelector> {
  List<String> _availableCurrencies = [];
  bool _isLoadingCurrencies = false;
  bool _showAllCurrencies = false;
  Map<String, String> _currencyReasons = {};

  @override
  void initState() {
    super.initState();
    _updateAvailableCurrencies();
  }

  @override
  void didUpdateWidget(SmartCurrencySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update currency list when country changes
    if (widget.selectedCountry != oldWidget.selectedCountry) {
      _showAllCurrencies = false; // Reset expand state when country changes
      _updateAvailableCurrencies();
    }
  }

  Future<void> _updateAvailableCurrencies() async {
    if (!mounted) return;

    setState(() {
      _isLoadingCurrencies = true;
    });

    try {
      final currencySettings = await ref.read(currencySettingsNotifierProvider.future);
      final userDefaultCurrency = currencySettings.primaryCurrency;

      List<String> smartCurrencies;
      Map<String, String> reasons = {};

      if (_showAllCurrencies) {
        // Show all supported currencies
        smartCurrencies = CurrencyValidator.supportedCurrencies;
        for (final currency in smartCurrencies) {
          reasons[currency] = 'All available currencies';
        }
      } else if (widget.selectedCountry == null || widget.selectedCountry!.isEmpty) {
        // No country selected - show major currencies and user default
        smartCurrencies = <String>[
          userDefaultCurrency,
          'USD', 'EUR', 'GBP', 'JPY', 'CHF', 'CAD', 'AUD'
        ].toSet().toList();
        for (final currency in smartCurrencies) {
          if (currency == userDefaultCurrency) {
            reasons[currency] = 'Your default currency';
          } else {
            reasons[currency] = 'Major international currency';
          }
        }
      } else {
        // Get smart suggestions based on country and user history
        smartCurrencies = await SmartCurrencyProvider.getSmartSuggestions(
          country: widget.selectedCountry!,
          userDefaultCurrency: userDefaultCurrency,
          includeUsageHistory: true,
          includeRegionalCurrencies: true,
          maxSuggestions: 8,
        );

        // Get detailed suggestions for reasoning
        final detailedSuggestions = CountryCurrencyService.getDetailedCurrencySuggestions(
          widget.selectedCountry!,
          userDefaultCurrency,
          includeRegionalCurrencies: true,
          maxSuggestions: 8,
        );

        for (final suggestion in detailedSuggestions) {
          reasons[suggestion.currencyCode] = suggestion.reasonDescription;
        }
      }

      if (mounted) {
        setState(() {
          _availableCurrencies = smartCurrencies;
          _currencyReasons = reasons;
          _isLoadingCurrencies = false;
        });

        // Auto-select primary currency if user hasn't selected one yet
        if (widget.selectedCurrency == null && smartCurrencies.isNotEmpty) {
          widget.onCurrencyChanged(smartCurrencies.first);
        }
      }
    } catch (e) {
      // Fallback to all currencies on error
      if (mounted) {
        setState(() {
          _availableCurrencies = CurrencyValidator.supportedCurrencies;
          _currencyReasons = {};
          _isLoadingCurrencies = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Loading indicator
        if (_isLoadingCurrencies)
          const LinearProgressIndicator(minHeight: 2),
        
        // Currency dropdown
        DropdownButtonFormField<String>(
          value: widget.selectedCurrency,
          decoration: InputDecoration(
            labelText: 'Currency *',
            prefixIcon: const Icon(Icons.attach_money),
            helperText: widget.helperText ?? _getHelperText(),
            errorText: widget.errorText,
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
            // Show filtering indicator
            suffixIcon: _buildSuffixIcon(),
          ),
          items: _availableCurrencies.map((currency) {
            final currencyInfo = CountryCurrencyService.getCurrencyInfo(currency);
            final isRecommended = _isRecommendedCurrency(currency);
            final isPrimary = _isPrimaryCurrency(currency);
            
            return DropdownMenuItem(
              value: currency,
              child: Row(
                children: [
                  // Currency code
                  Text(
                    currency,
                    style: TextStyle(
                      fontWeight: isPrimary ? FontWeight.w600 : 
                                 isRecommended ? FontWeight.w500 : FontWeight.normal,
                      color: isPrimary ? Theme.of(context).colorScheme.primary : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Currency symbol
                  Text(
                    '(${currencyInfo?.symbol ?? currency})',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  // Recommendation indicators
                  if (isPrimary) ...[
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ] else if (isRecommended) ...[
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
          onChanged: widget.enabled ? (String? newCurrency) {
            if (newCurrency != null) {
              widget.onCurrencyChanged(newCurrency);
              _recordCurrencyUsage(newCurrency);
            }
          } : null,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a currency';
            }
            return null;
          },
          isExpanded: true,
          hint: Text(
            'Select currency',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        
        // Expand option
        if (_shouldShowExpandOption()) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showAllCurrencies = true;
              });
              _updateAvailableCurrencies();
            },
            icon: const Icon(Icons.expand_more, size: 16),
            label: Text(
              'Show all ${CurrencyValidator.supportedCurrencies.length} currencies',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],

        // Show filtered indicator when not showing all
        if (!_showAllCurrencies && _availableCurrencies.length < CurrencyValidator.supportedCurrencies.length) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.filter_list,
                  size: 14,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 4),
                Text(
                  'Filtered for ${widget.selectedCountry ?? "preferences"}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 4),
                InkWell(
                  onTap: () {
                    setState(() {
                      _showAllCurrencies = true;
                    });
                    _updateAvailableCurrencies();
                  },
                  child: Icon(
                    Icons.clear,
                    size: 14,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (_isLoadingCurrencies) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    
    if (!_showAllCurrencies && _availableCurrencies.length < CurrencyValidator.supportedCurrencies.length) {
      return Tooltip(
        message: 'Currencies filtered for ${widget.selectedCountry ?? "your preferences"}',
        child: const Icon(Icons.filter_list, size: 20),
      );
    }
    
    return null;
  }

  String _getHelperText() {
    if (_isLoadingCurrencies) {
      return 'Loading currency suggestions...';
    }

    if (widget.selectedCountry == null || widget.selectedCountry!.isEmpty) {
      return 'Select a country to see relevant currencies';
    }
    
    final totalCurrencies = CurrencyValidator.supportedCurrencies.length;
    final filteredCount = _availableCurrencies.length;
    
    if (_showAllCurrencies) {
      return 'Showing all $totalCurrencies supported currencies';
    }
    
    if (filteredCount <= 3) {
      return 'Top currency suggestions for ${widget.selectedCountry}';
    }
    
    return 'Showing $filteredCount relevant currencies (of $totalCurrencies total)';
  }

  bool _isRecommendedCurrency(String currency) {
    if (widget.selectedCountry == null) return false;
    
    // Primary currency for the country is recommended
    final primaryCurrency = CountryCurrencyService.getPrimaryCurrency(widget.selectedCountry!);
    if (currency == primaryCurrency) return true;
    
    // User's default currency is recommended
    final currencySettings = ref.read(currencySettingsNotifierProvider);
    return currencySettings.when(
      data: (settings) => currency == settings.primaryCurrency,
      loading: () => false,
      error: (_, __) => false,
    );
  }

  bool _isPrimaryCurrency(String currency) {
    if (widget.selectedCountry == null) return false;
    
    final primaryCurrency = CountryCurrencyService.getPrimaryCurrency(widget.selectedCountry!);
    return currency == primaryCurrency;
  }

  bool _shouldShowExpandOption() {
    return !_showAllCurrencies && 
           _availableCurrencies.length < CurrencyValidator.supportedCurrencies.length &&
           _availableCurrencies.length <= 8 &&
           !_isLoadingCurrencies;
  }

  void _recordCurrencyUsage(String currency) {
    if (widget.selectedCountry != null && widget.selectedCountry!.isNotEmpty) {
      // Record usage asynchronously without blocking UI
      CurrencyUsageTracker.recordCurrencyUsage(
        widget.selectedCountry!, 
        currency,
        context: 'fuel_entry',
      ).catchError((e) {
        // Silent error handling - usage tracking shouldn't break the UI
        debugPrint('Failed to record currency usage: $e');
      });
    }
  }

  /// Get the reason why a currency was suggested (for tooltips)
  String? getCurrencyReason(String currency) {
    return _currencyReasons[currency];
  }
}