import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';

/// Reusable country selection widget with autocomplete and flags
/// 
/// Features:
/// - Country search with autocomplete
/// - Country flags display
/// - Recently used countries prioritization
/// - Customizable styling and behavior
/// - Accessibility support
class CountrySelectionWidget extends StatelessWidget {
  final String? selectedCountry;
  final ValueChanged<String?> onCountryChanged;
  final String? hintText;
  final bool showClearButton;
  final bool enabled;
  final InputDecoration? decoration;
  final TextStyle? textStyle;

  const CountrySelectionWidget({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
    this.hintText,
    this.showClearButton = true,
    this.enabled = true,
    this.decoration,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _showCountryPicker(context) : null,
      child: InputDecorator(
        decoration: decoration ?? InputDecoration(
          hintText: hintText ?? 'Select Country',
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: _buildSuffixIcon(context),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectedCountry != null) ...[
              _buildCountryDisplay(),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                selectedCountry ?? hintText ?? 'Select Country',
                style: textStyle ?? _getTextStyle(context),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryDisplay() {
    if (selectedCountry == null) return const SizedBox.shrink();
    
    try {
      // Try to get country by name for flag display
      final country = Country.tryParse(selectedCountry!);
      if (country != null) {
        return Text(
          country.flagEmoji,
          style: const TextStyle(fontSize: 18),
        );
      }
    } catch (e) {
      // Fallback for unknown countries
    }
    
    // Fallback: show a generic globe icon
    return const Icon(Icons.public, size: 18);
  }

  Widget? _buildSuffixIcon(BuildContext context) {
    if (!enabled) return null;
    
    if (selectedCountry != null && showClearButton) {
      return IconButton(
        icon: const Icon(Icons.clear, size: 18),
        onPressed: () => onCountryChanged(null),
        tooltip: 'Clear selection',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      );
    }
    
    return const Icon(Icons.arrow_drop_down);
  }

  TextStyle _getTextStyle(BuildContext context) {
    final theme = Theme.of(context);
    if (selectedCountry != null) {
      return theme.textTheme.bodyMedium ?? const TextStyle();
    } else {
      return theme.textTheme.bodyMedium?.copyWith(
        color: theme.hintColor,
      ) ?? TextStyle(color: theme.hintColor);
    }
  }

  void _showCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: false,
      showWorldWide: false,
      showSearch: true,
      useSafeArea: true,
      favorite: _getFavoriteCountries(),
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.circular(8),
        inputDecoration: InputDecoration(
          labelText: 'Search Country',
          hintText: 'Type country name...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        searchTextStyle: Theme.of(context).textTheme.bodyMedium,
        textStyle: Theme.of(context).textTheme.bodyMedium,
        backgroundColor: Theme.of(context).colorScheme.surface,
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.7,
        flagSize: 24,
        margin: const EdgeInsets.all(16),
      ),
      onSelect: (Country country) {
        onCountryChanged(country.name);
      },
    );
  }

  /// Get list of favorite/recently used countries
  /// These will appear at the top of the country picker
  List<String> _getFavoriteCountries() {
    return [
      'CA', // Canada
      'US', // United States
      'DE', // Germany
      'FR', // France
      'AU', // Australia
      'JP', // Japan
      'GB', // United Kingdom
      'MX', // Mexico
      'IT', // Italy
      'ES', // Spain
    ];
  }
}

/// Country filter widget specifically for chart filtering
/// 
/// This widget provides country filtering functionality with
/// additional features like "All Countries" option and entry counts
class CountryFilterWidget extends StatelessWidget {
  final String? selectedCountry;
  final ValueChanged<String?> onCountryChanged;
  final List<String> availableCountries;
  final Map<String, int>? entryCounts;
  final bool showEntryCounts;

  const CountryFilterWidget({
    super.key,
    required this.selectedCountry,
    required this.onCountryChanged,
    required this.availableCountries,
    this.entryCounts,
    this.showEntryCounts = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      value: selectedCountry,
      decoration: const InputDecoration(
        labelText: 'Country Filter',
        border: OutlineInputBorder(),
        isDense: true,
        prefixIcon: Icon(Icons.public, size: 18),
      ),
      items: _buildDropdownItems(context),
      onChanged: onCountryChanged,
      isExpanded: true,
    );
  }

  List<DropdownMenuItem<String?>> _buildDropdownItems(BuildContext context) {
    final items = <DropdownMenuItem<String?>>[];
    
    // Add "All Countries" option
    final totalEntries = entryCounts?.values.fold<int>(0, (sum, count) => sum + count) ?? 0;
    items.add(
      DropdownMenuItem<String?>(
        value: null,
        child: Row(
          children: [
            const Icon(Icons.public, size: 16),
            const SizedBox(width: 8),
            const Text('All Countries'),
            if (showEntryCounts && totalEntries > 0) ...[
              const Spacer(),
              Text(
                '($totalEntries)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
      ),
    );
    
    // Add individual countries
    for (final countryName in availableCountries) {
      items.add(
        DropdownMenuItem<String?>(
          value: countryName,
          child: Row(
            children: [
              _buildCountryFlag(countryName),
              const SizedBox(width: 8),
              Expanded(child: Text(countryName)),
              if (showEntryCounts && entryCounts != null) ...[
                const SizedBox(width: 8),
                Text(
                  '(${entryCounts![countryName] ?? 0})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    
    return items;
  }

  Widget _buildCountryFlag(String countryName) {
    try {
      // Try to get country by name for flag display
      final country = Country.tryParse(countryName);
      if (country != null) {
        return Text(
          country.flagEmoji,
          style: const TextStyle(fontSize: 16),
        );
      }
    } catch (e) {
      // Fallback for unknown countries
    }
    
    // Fallback: show a generic flag icon
    return const Icon(Icons.flag, size: 16);
  }
}

/// Extension to help with country parsing from names
extension CountryExtension on Country {
  static Country? tryParse(String countryName) {
    try {
      // Try to find country by name
      final countries = CountryService().getAll();
      return countries.firstWhere(
        (country) => country.name.toLowerCase() == countryName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}