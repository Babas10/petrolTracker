import 'package:drift/drift.dart';

/// Table definition for user settings and preferences
/// 
/// This table stores user-specific configuration including currency preferences
/// and other app-wide settings.
@DataClassName('UserSetting')
class UserSettings extends Table {
  /// Primary key - auto-incrementing integer
  /// Note: This is designed as a single-user app, so typically only one row
  IntColumn get id => integer().autoIncrement()();

  /// User's preferred primary currency for display and calculations
  /// All fuel entry amounts will be converted to this currency for consistent display
  /// Must be a valid 3-character ISO 4217 currency code (e.g., 'USD', 'EUR', 'CHF')
  TextColumn get primaryCurrency => text().withLength(min: 3, max: 3).withDefault(const Constant('USD'))();

  /// When this settings record was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// When this settings record was last updated
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => [
    // Ensure primary_currency is uppercase (standard for currency codes)
    'CHECK(primary_currency = UPPER(primary_currency))',
  ];
}