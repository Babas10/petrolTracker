import 'package:drift/drift.dart';
import 'package:petrol_tracker/database/database.dart';

/// Data model for ExchangeRateCache with validation and business logic
class ExchangeRateCacheModel {
  final int? id;
  final String baseCurrency;
  final String targetCurrency;
  final double rate;
  final DateTime lastUpdated;
  final DateTime createdAt;

  const ExchangeRateCacheModel({
    this.id,
    required this.baseCurrency,
    required this.targetCurrency,
    required this.rate,
    required this.lastUpdated,
    required this.createdAt,
  });

  /// Creates an ExchangeRateCacheModel from a Drift ExchangeRateCache entity
  factory ExchangeRateCacheModel.fromEntity(ExchangeRateCache entity) {
    return ExchangeRateCacheModel(
      id: entity.id,
      baseCurrency: entity.baseCurrency,
      targetCurrency: entity.targetCurrency,
      rate: entity.rate,
      lastUpdated: entity.lastUpdated,
      createdAt: entity.createdAt,
    );
  }

  /// Creates an ExchangeRateCacheModel for new cache entry creation
  factory ExchangeRateCacheModel.create({
    required String baseCurrency,
    required String targetCurrency,
    required double rate,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) {
    final now = DateTime.now();
    return ExchangeRateCacheModel(
      baseCurrency: baseCurrency.toUpperCase(),
      targetCurrency: targetCurrency.toUpperCase(),
      rate: rate,
      lastUpdated: lastUpdated ?? now,
      createdAt: createdAt ?? now,
    );
  }

  /// Converts to Drift ExchangeRatesCacheCompanion for database operations
  ExchangeRatesCacheCompanion toCompanion() {
    return ExchangeRatesCacheCompanion(
      baseCurrency: Value(baseCurrency),
      targetCurrency: Value(targetCurrency),
      rate: Value(rate),
      lastUpdated: Value(lastUpdated),
      createdAt: Value(createdAt),
    );
  }

  /// Converts to Drift ExchangeRatesCacheCompanion for updates
  ExchangeRatesCacheCompanion toUpdateCompanion() {
    return ExchangeRatesCacheCompanion(
      id: Value(id!),
      baseCurrency: Value(baseCurrency),
      targetCurrency: Value(targetCurrency),
      rate: Value(rate),
      lastUpdated: Value(lastUpdated),
      createdAt: Value(createdAt),
    );
  }

  /// Validates exchange rate cache data
  List<String> validate() {
    final errors = <String>[];

    // Base currency validation
    if (baseCurrency.isEmpty) {
      errors.add('Base currency is required');
    } else if (baseCurrency.length != 3) {
      errors.add('Base currency must be a 3-character currency code (e.g., USD, EUR)');
    } else if (baseCurrency != baseCurrency.toUpperCase()) {
      errors.add('Base currency code must be uppercase (e.g., USD, not usd)');
    }

    // Target currency validation
    if (targetCurrency.isEmpty) {
      errors.add('Target currency is required');
    } else if (targetCurrency.length != 3) {
      errors.add('Target currency must be a 3-character currency code (e.g., USD, EUR)');
    } else if (targetCurrency != targetCurrency.toUpperCase()) {
      errors.add('Target currency code must be uppercase (e.g., EUR, not eur)');
    }

    // Same currency check
    if (baseCurrency == targetCurrency) {
      errors.add('Base and target currencies must be different');
    }

    // Rate validation
    if (rate <= 0) {
      errors.add('Exchange rate must be greater than 0');
    } else if (rate > 10000) {
      errors.add('Exchange rate seems unreasonably high (>${rate.toStringAsFixed(2)}). Please verify.');
    }

    // Date validation
    if (lastUpdated.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      errors.add('Last updated date cannot be in the future');
    }

    if (createdAt.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      errors.add('Created date cannot be in the future');
    }

    return errors;
  }

  /// Returns true if the exchange rate data is valid
  bool get isValid => validate().isEmpty;

  /// Check if the cached rate is fresh (within 24 hours)
  bool get isFresh {
    final now = DateTime.now();
    final age = now.difference(lastUpdated);
    return age.inHours < 24;
  }

  /// Get the age of the cached rate in hours
  int get ageInHours {
    final now = DateTime.now();
    return now.difference(lastUpdated).inHours;
  }

  /// Convert an amount using this cached exchange rate
  double convertAmount(double amount) {
    return amount * rate;
  }

  /// Get the inverse rate (for reverse conversion)
  double get inverseRate => 1.0 / rate;

  /// Convert an amount using the inverse rate
  double convertAmountReverse(double amount) {
    return amount * inverseRate;
  }

  /// Creates a copy with updated values
  ExchangeRateCacheModel copyWith({
    int? id,
    String? baseCurrency,
    String? targetCurrency,
    double? rate,
    DateTime? lastUpdated,
    DateTime? createdAt,
  }) {
    return ExchangeRateCacheModel(
      id: id ?? this.id,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      targetCurrency: targetCurrency ?? this.targetCurrency,
      rate: rate ?? this.rate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Creates a copy with updated rate and timestamp
  ExchangeRateCacheModel withUpdatedRate(double newRate, {DateTime? timestamp}) {
    return copyWith(
      rate: newRate,
      lastUpdated: timestamp ?? DateTime.now(),
    );
  }

  /// Format the exchange rate for display
  String get formattedRate => rate.toStringAsFixed(4);

  /// Format the currency pair for display
  String get currencyPair => '$baseCurrency/$targetCurrency';

  /// Format the full rate information for display
  String get displayString => '1 $baseCurrency = ${formattedRate} $targetCurrency';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExchangeRateCacheModel &&
        other.id == id &&
        other.baseCurrency == baseCurrency &&
        other.targetCurrency == targetCurrency &&
        other.rate == rate &&
        other.lastUpdated == lastUpdated &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      baseCurrency,
      targetCurrency,
      rate,
      lastUpdated,
      createdAt,
    );
  }

  @override
  String toString() {
    return 'ExchangeRateCacheModel(id: $id, baseCurrency: $baseCurrency, targetCurrency: $targetCurrency, rate: $rate, lastUpdated: $lastUpdated, createdAt: $createdAt)';
  }
}