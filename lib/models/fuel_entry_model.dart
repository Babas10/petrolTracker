import 'package:drift/drift.dart';
import 'package:petrol_tracker/database/database.dart';

/// Data model for FuelEntry with validation and business logic
class FuelEntryModel {
  final int? id;
  final int vehicleId;
  final DateTime date;
  final double currentKm;
  final double fuelAmount;
  final double price;
  final String country;
  final double pricePerLiter;
  final double? consumption;
  final bool isFullTank;

  const FuelEntryModel({
    this.id,
    required this.vehicleId,
    required this.date,
    required this.currentKm,
    required this.fuelAmount,
    required this.price,
    required this.country,
    required this.pricePerLiter,
    this.consumption,
    this.isFullTank = true,
  });

  /// Creates a FuelEntryModel from a Drift FuelEntry entity
  factory FuelEntryModel.fromEntity(FuelEntry entity) {
    return FuelEntryModel(
      id: entity.id,
      vehicleId: entity.vehicleId,
      date: entity.date,
      currentKm: entity.currentKm,
      fuelAmount: entity.fuelAmount,
      price: entity.price,
      country: entity.country,
      pricePerLiter: entity.pricePerLiter,
      consumption: entity.consumption,
      isFullTank: entity.isFullTank,
    );
  }

  /// Creates a FuelEntryModel for new entry creation
  factory FuelEntryModel.create({
    required int vehicleId,
    required DateTime date,
    required double currentKm,
    required double fuelAmount,
    required double price,
    required String country,
    required double pricePerLiter,
    double? consumption,
    bool isFullTank = true,
  }) {
    return FuelEntryModel(
      vehicleId: vehicleId,
      date: date,
      currentKm: currentKm,
      fuelAmount: fuelAmount,
      price: price,
      country: country,
      pricePerLiter: pricePerLiter,
      consumption: consumption,
      isFullTank: isFullTank,
    );
  }

  /// Converts to Drift FuelEntriesCompanion for database operations
  FuelEntriesCompanion toCompanion() {
    return FuelEntriesCompanion(
      vehicleId: Value(vehicleId),
      date: Value(date),
      currentKm: Value(currentKm),
      fuelAmount: Value(fuelAmount),
      price: Value(price),
      country: Value(country),
      pricePerLiter: Value(pricePerLiter),
      consumption: Value(consumption),
      isFullTank: Value(isFullTank),
    );
  }

  /// Converts to Drift FuelEntriesCompanion for updates
  FuelEntriesCompanion toUpdateCompanion() {
    return FuelEntriesCompanion(
      id: Value(id!),
      vehicleId: Value(vehicleId),
      date: Value(date),
      currentKm: Value(currentKm),
      fuelAmount: Value(fuelAmount),
      price: Value(price),
      country: Value(country),
      pricePerLiter: Value(pricePerLiter),
      consumption: Value(consumption),
      isFullTank: Value(isFullTank),
    );
  }

  /// Calculates fuel consumption in L/100km based on previous entry
  static double? calculateConsumption({
    required double fuelAmount,
    required double currentKm,
    required double previousKm,
  }) {
    final distance = currentKm - previousKm;
    if (distance <= 0) return null;
    return (fuelAmount / distance) * 100;
  }

  /// Creates a copy with calculated consumption
  FuelEntryModel withCalculatedConsumption(double? previousKm) {
    if (previousKm == null) return this;
    
    final calculatedConsumption = calculateConsumption(
      fuelAmount: fuelAmount,
      currentKm: currentKm,
      previousKm: previousKm,
    );

    return copyWith(consumption: calculatedConsumption);
  }

  /// Validates fuel entry data
  List<String> validate({double? previousKm, bool isFirstEntry = false}) {
    final errors = <String>[];

    // Vehicle ID validation
    if (vehicleId <= 0) {
      errors.add('Vehicle ID must be valid');
    }

    // First entry must be full tank
    if (isFirstEntry && !isFullTank) {
      errors.add('First fuel entry for a vehicle must be a full tank fill-up');
    }

    // Date validation
    if (date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      errors.add('Date cannot be in the future');
    }

    // Current km validation
    if (currentKm < 0) {
      errors.add('Current kilometers must be 0 or greater');
    }

    // Previous km validation (if provided)
    if (previousKm != null && currentKm < previousKm) {
      errors.add('Current kilometers must be greater than or equal to previous entry ($previousKm km)');
    }

    // Fuel amount validation
    if (fuelAmount <= 0) {
      errors.add('Fuel amount must be greater than 0');
    } else if (fuelAmount > 200) {
      errors.add('Fuel amount seems unusually high (>200L). Please verify.');
    }

    // Price validation
    if (price <= 0) {
      errors.add('Price must be greater than 0');
    }

    // Price per liter validation
    if (pricePerLiter <= 0) {
      errors.add('Price per liter must be greater than 0');
    } else if (pricePerLiter > 10) {
      errors.add('Price per liter seems unusually high (>${pricePerLiter.toStringAsFixed(2)}). Please verify.');
    }

    // Country validation
    if (country.trim().isEmpty) {
      errors.add('Country is required');
    } else if (country.trim().length < 2) {
      errors.add('Country name must be at least 2 characters');
    } else if (country.trim().length > 50) {
      errors.add('Country name must be less than 50 characters');
    }

    // Price consistency validation with tolerance for floating-point precision
    final expectedPrice = fuelAmount * pricePerLiter;
    final priceDifference = (price - expectedPrice).abs();
    // Use more generous tolerance (0.05) to handle different input formats and floating-point precision
    const tolerance = 0.05;
    if (priceDifference > tolerance) {
      errors.add('Price (${price.toStringAsFixed(2)}) does not match fuel amount × price per liter (${expectedPrice.toStringAsFixed(2)}). Difference: ${priceDifference.toStringAsFixed(3)}');
    }

    return errors;
  }

  /// Returns true if the fuel entry data is valid
  bool isValid({double? previousKm, bool isFirstEntry = false}) => validate(previousKm: previousKm, isFirstEntry: isFirstEntry).isEmpty;

  /// Calculated properties
  
  /// Average price per liter
  double get averagePricePerLiter => price / fuelAmount;

  /// Formatted consumption string
  String get formattedConsumption {
    if (consumption == null) return 'N/A';
    return '${consumption!.toStringAsFixed(1)} L/100km';
  }

  /// Formatted price string
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  /// Formatted fuel amount string  
  String get formattedFuelAmount => '${fuelAmount.toStringAsFixed(1)}L';

  /// Creates a copy with updated values
  FuelEntryModel copyWith({
    int? id,
    int? vehicleId,
    DateTime? date,
    double? currentKm,
    double? fuelAmount,
    double? price,
    String? country,
    double? pricePerLiter,
    double? consumption,
    bool? isFullTank,
  }) {
    return FuelEntryModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      currentKm: currentKm ?? this.currentKm,
      fuelAmount: fuelAmount ?? this.fuelAmount,
      price: price ?? this.price,
      country: country ?? this.country,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      consumption: consumption ?? this.consumption,
      isFullTank: isFullTank ?? this.isFullTank,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FuelEntryModel &&
        other.id == id &&
        other.vehicleId == vehicleId &&
        other.date == date &&
        other.currentKm == currentKm &&
        other.fuelAmount == fuelAmount &&
        other.price == price &&
        other.country == country &&
        other.pricePerLiter == pricePerLiter &&
        other.consumption == consumption &&
        other.isFullTank == isFullTank;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      vehicleId,
      date,
      currentKm,
      fuelAmount,
      price,
      country,
      pricePerLiter,
      consumption,
      isFullTank,
    );
  }

  @override
  String toString() {
    return 'FuelEntryModel(id: $id, vehicleId: $vehicleId, date: $date, currentKm: $currentKm, fuelAmount: $fuelAmount, price: $price, country: $country, pricePerLiter: $pricePerLiter, consumption: $consumption, isFullTank: $isFullTank)';
  }
}