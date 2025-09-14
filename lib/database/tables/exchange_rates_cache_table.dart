import 'package:drift/drift.dart';

/// Table definition for local exchange rate caching
/// 
/// This table stores exchange rates fetched from the currency microservice
/// to enable offline currency conversion and reduce API calls.
@DataClassName('ExchangeRateCache')
class ExchangeRatesCache extends Table {
  /// Primary key - auto-incrementing integer
  IntColumn get id => integer().autoIncrement()();

  /// Base currency code (3-character ISO 4217 code)
  /// This is the currency that other rates are relative to
  TextColumn get baseCurrency => text().withLength(min: 3, max: 3)();

  /// Target currency code (3-character ISO 4217 code)
  /// This is the currency being converted to
  TextColumn get targetCurrency => text().withLength(min: 3, max: 3)();

  /// Exchange rate from base currency to target currency
  /// E.g., if base=USD, target=EUR, rate=0.8542, then 1 USD = 0.8542 EUR
  RealColumn get rate => real()();

  /// Date when this rate was fetched from the microservice
  /// Used to determine if the rate is still fresh (within 24 hours)
  DateTimeColumn get lastUpdated => dateTime().withDefault(currentDateAndTime)();

  /// When this cache entry was created in the local database
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => [
    // Ensure unique combination of base and target currency
    'UNIQUE(base_currency, target_currency)',
    // Ensure currency codes are uppercase (standard for currency codes)
    'CHECK(base_currency = UPPER(base_currency))',
    'CHECK(target_currency = UPPER(target_currency))',
    // Ensure rate is positive
    'CHECK(rate > 0)',
    // Prevent same currency conversion (should always be 1.0, handled in code)
    'CHECK(base_currency != target_currency)',
  ];
}