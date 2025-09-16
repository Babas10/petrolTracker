import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:petrol_tracker/services/currency_service.dart';

part 'currency_providers.g.dart';

/// Provider for the currency service
/// 
/// Provides access to the singleton instance of CurrencyService for
/// converting currencies and fetching exchange rates.
@riverpod
CurrencyService currencyService(CurrencyServiceRef ref) {
  return CurrencyService.instance;
}