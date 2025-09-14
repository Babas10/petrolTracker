import 'package:drift/drift.dart';
import 'package:petrol_tracker/database/database.dart';

/// Data model for UserSettings with validation and business logic
class UserSettingsModel {
  final int? id;
  final String primaryCurrency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSettingsModel({
    this.id,
    required this.primaryCurrency,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a UserSettingsModel from a Drift UserSetting entity
  factory UserSettingsModel.fromEntity(UserSetting entity) {
    return UserSettingsModel(
      id: entity.id,
      primaryCurrency: entity.primaryCurrency,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Creates a UserSettingsModel for new settings creation with defaults
  factory UserSettingsModel.create({
    String primaryCurrency = 'USD',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();
    return UserSettingsModel(
      primaryCurrency: primaryCurrency,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  /// Converts to Drift UserSettingsCompanion for database operations
  UserSettingsCompanion toCompanion() {
    return UserSettingsCompanion(
      primaryCurrency: Value(primaryCurrency),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  /// Converts to Drift UserSettingsCompanion for updates
  UserSettingsCompanion toUpdateCompanion() {
    return UserSettingsCompanion(
      id: Value(id!),
      primaryCurrency: Value(primaryCurrency),
      createdAt: Value(createdAt),
      updatedAt: Value(DateTime.now()), // Always update timestamp on updates
    );
  }

  /// Validates user settings data
  List<String> validate() {
    final errors = <String>[];

    // Primary currency validation
    if (primaryCurrency.isEmpty) {
      errors.add('Primary currency is required');
    } else if (primaryCurrency.length != 3) {
      errors.add('Primary currency must be a 3-character currency code (e.g., USD, EUR)');
    } else if (primaryCurrency != primaryCurrency.toUpperCase()) {
      errors.add('Primary currency code must be uppercase (e.g., USD, not usd)');
    }

    // Date validation
    if (createdAt.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      errors.add('Created date cannot be in the future');
    }

    if (updatedAt.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      errors.add('Updated date cannot be in the future');
    }

    if (updatedAt.isBefore(createdAt)) {
      errors.add('Updated date cannot be before created date');
    }

    return errors;
  }

  /// Returns true if the user settings data is valid
  bool get isValid => validate().isEmpty;

  /// Creates a copy with updated values (automatically updates timestamp)
  UserSettingsModel copyWith({
    int? id,
    String? primaryCurrency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettingsModel(
      id: id ?? this.id,
      primaryCurrency: primaryCurrency ?? this.primaryCurrency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(), // Auto-update timestamp
    );
  }

  /// Creates a copy with updated primary currency
  UserSettingsModel withPrimaryCurrency(String newPrimaryCurrency) {
    return copyWith(primaryCurrency: newPrimaryCurrency);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSettingsModel &&
        other.id == id &&
        other.primaryCurrency == primaryCurrency &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      primaryCurrency,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserSettingsModel(id: $id, primaryCurrency: $primaryCurrency, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  /// Common currency codes for validation
  static const List<String> supportedCurrencies = [
    'USD', 'EUR', 'GBP', 'CHF', 'JPY', 'CAD', 'AUD', 'NZD', 'SEK', 'NOK', 
    'DKK', 'PLN', 'CZK', 'HUF', 'RON', 'BGN', 'HRK', 'ISK', 'TRY', 'RUB',
    'CNY', 'INR', 'KRW', 'SGD', 'HKD', 'THB', 'MYR', 'PHP', 'IDR', 'VND',
    'BRL', 'ARS', 'CLP', 'COP', 'MXN', 'PEN', 'UYU', 'ZAR', 'EGP', 'MAD'
  ];

  /// Check if the currency is supported
  bool get isCurrencySupported => supportedCurrencies.contains(primaryCurrency);
}