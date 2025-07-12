import 'package:drift/drift.dart';

/// Table definition for vehicles
/// 
/// This table stores information about user's vehicles that they track
/// fuel consumption for.
@DataClassName('Vehicle')
class Vehicles extends Table {
  /// Primary key - auto-incrementing integer
  IntColumn get id => integer().autoIncrement()();

  /// Name/description of the vehicle (e.g., "Honda Civic 2020", "Work Car")
  /// Must not be empty and should be unique per user
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Initial kilometer reading when the vehicle was added to tracking
  /// This is used as a baseline for consumption calculations
  RealColumn get initialKm => real()();

  /// When this vehicle record was created
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  // Primary key is automatically set by autoIncrement()

  @override
  List<String> get customConstraints => [
    // Ensure vehicle names are unique (case-insensitive)
    'UNIQUE(name COLLATE NOCASE)',
  ];
}