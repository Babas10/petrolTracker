import 'package:drift/drift.dart';

import 'vehicles_table.dart';

/// Table definition for fuel entries
/// 
/// This table stores individual fuel purchase records with all the necessary
/// information for calculating consumption and analyzing trends.
@DataClassName('FuelEntry')
class FuelEntries extends Table {
  /// Primary key - auto-incrementing integer
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key reference to the vehicle this entry belongs to
  IntColumn get vehicleId => integer().references(Vehicles, #id)();

  /// Date and time when the fuel was purchased
  DateTimeColumn get date => dateTime()();

  /// Current odometer reading at the time of fuel purchase (in kilometers)
  /// Must be greater than or equal to the previous entry for the same vehicle
  RealColumn get currentKm => real()();

  /// Amount of fuel purchased (in liters)
  /// Must be a positive number
  RealColumn get fuelAmount => real()();

  /// Total price paid for the fuel purchase
  /// Must be a positive number
  RealColumn get price => real()();

  /// Country where the fuel was purchased
  /// Used for price comparison analysis
  TextColumn get country => text().withLength(min: 2, max: 50)();

  /// Price per liter (calculated or manually entered)
  /// Usually calculated as price / fuelAmount but can be overridden
  RealColumn get pricePerLiter => real()();

  /// Calculated fuel consumption in L/100km
  /// This is calculated based on the distance traveled since the last entry
  /// and the fuel amount for this entry. Can be null for the first entry.
  RealColumn get consumption => real().nullable()();

  /// Indicates whether this was a full tank fill-up or a partial refuel
  /// Used for accurate consumption calculation - only full-to-full periods are used
  /// First entry for a vehicle must always be a full tank
  BoolColumn get isFullTank => boolean().withDefault(const Constant(true))();

  // Primary key is automatically set by autoIncrement()

  @override
  List<String> get customConstraints => [
    // Ensure the combination of vehicle and date is unique
    // (prevents duplicate entries for the same vehicle on the same date)
    'UNIQUE(vehicle_id, date)',
  ];
}