import 'package:flutter/material.dart';

/// A dropdown widget for selecting countries with search functionality
class CountryDropdown extends StatefulWidget {
  final String? selectedCountry;
  final ValueChanged<String?> onChanged;
  final String? hintText;
  final String? errorText;

  const CountryDropdown({
    super.key,
    this.selectedCountry,
    required this.onChanged,
    this.hintText,
    this.errorText,
  });

  @override
  State<CountryDropdown> createState() => _CountryDropdownState();
}

class _CountryDropdownState extends State<CountryDropdown> {
  static const List<String> _countries = [
    'Afghanistan',
    'Albania',
    'Algeria',
    'Argentina',
    'Armenia',
    'Australia',
    'Austria',
    'Azerbaijan',
    'Bahrain',
    'Bangladesh',
    'Belarus',
    'Belgium',
    'Bolivia',
    'Bosnia and Herzegovina',
    'Brazil',
    'Bulgaria',
    'Cambodia',
    'Canada',
    'Chile',
    'China',
    'Colombia',
    'Croatia',
    'Czech Republic',
    'Denmark',
    'Ecuador',
    'Egypt',
    'Estonia',
    'Finland',
    'France',
    'Georgia',
    'Germany',
    'Ghana',
    'Greece',
    'Hungary',
    'Iceland',
    'India',
    'Indonesia',
    'Iran',
    'Iraq',
    'Ireland',
    'Israel',
    'Italy',
    'Japan',
    'Jordan',
    'Kazakhstan',
    'Kenya',
    'Kuwait',
    'Latvia',
    'Lebanon',
    'Lithuania',
    'Luxembourg',
    'Malaysia',
    'Mexico',
    'Morocco',
    'Netherlands',
    'New Zealand',
    'Nigeria',
    'Norway',
    'Pakistan',
    'Peru',
    'Philippines',
    'Poland',
    'Portugal',
    'Qatar',
    'Romania',
    'Russia',
    'Saudi Arabia',
    'Serbia',
    'Singapore',
    'Slovakia',
    'Slovenia',
    'South Africa',
    'South Korea',
    'Spain',
    'Sri Lanka',
    'Sweden',
    'Switzerland',
    'Thailand',
    'Turkey',
    'Ukraine',
    'United Arab Emirates',
    'United Kingdom',
    'United States',
    'Uruguay',
    'Venezuela',
    'Vietnam',
  ];

  List<String> _filteredCountries = _countries;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCountries = _countries
          .where((country) => country.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: widget.selectedCountry,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: widget.hintText ?? 'Select a country',
            prefixIcon: const Icon(Icons.public),
            errorText: widget.errorText,
          ),
          items: [
            // Search field
            DropdownMenuItem<String>(
              enabled: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search countries...',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
            ),
            const DropdownMenuItem<String>(
              value: null,
              enabled: false,
              child: Divider(),
            ),
            // Country options
            ..._filteredCountries.map((country) => DropdownMenuItem<String>(
              value: country,
              child: Text(country),
            )),
          ],
          onChanged: widget.onChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a country';
            }
            return null;
          },
          isExpanded: true,
          menuMaxHeight: 300,
        ),
      ],
    );
  }
}