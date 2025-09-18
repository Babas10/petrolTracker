import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petrol_tracker/services/currency_service.dart';

part 'currency_providers.g.dart';

/// Provider for the currency service
/// 
/// Provides access to the singleton instance of CurrencyService for
/// converting currencies and fetching exchange rates.
@riverpod
CurrencyService currencyService(Ref ref) {
  return CurrencyService.instance;
}

/// Provider for user's primary currency preference
final primaryCurrencyProvider = StateNotifierProvider<PrimaryCurrencyNotifier, String>((ref) {
  return PrimaryCurrencyNotifier();
});

class PrimaryCurrencyNotifier extends StateNotifier<String> {
  static const String _key = 'primary_currency';
  static const String _defaultCurrency = 'USD';

  PrimaryCurrencyNotifier() : super(_defaultCurrency) {
    _loadPrimaryCurrency();
  }

  Future<void> _loadPrimaryCurrency() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCurrency = prefs.getString(_key);
      if (savedCurrency != null && savedCurrency.isNotEmpty) {
        state = savedCurrency;
      }
    } catch (e) {
      // Keep default currency if loading fails
    }
  }

  Future<void> setPrimaryCurrency(String currency) async {
    if (currency.length == 3 && currency == currency.toUpperCase()) {
      state = currency;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_key, currency);
      } catch (e) {
        // Continue with state update even if saving fails
      }
    }
  }
}

/// Provider for available currencies in the fuel entries
final availableCurrenciesProvider = Provider<List<String>>((ref) {
  // For now, return common currencies
  // This could be enhanced to dynamically load from fuel entries
  return [
    'USD', 'EUR', 'GBP', 'CAD', 'AUD', 'JPY', 'CHF', 'CNY', 'INR', 'BRL',
    'MXN', 'SGD', 'HKD', 'NZD', 'SEK', 'NOK', 'DKK', 'PLN', 'CZK', 'HUF',
  ];
});

/// Provider for currency filter in the fuel entries screen
final currencyFilterProvider = StateProvider<String?>((ref) => null);