import 'package:drift/drift.dart';
import 'vehicles_table.dart';
import 'maintenance_categories_table.dart';

/// Database table for maintenance schedules and reminders
/// 
/// Defines recurring maintenance schedules based on time or mileage intervals.
/// Used to remind users about upcoming maintenance activities.
@DataClassName('MaintenanceSchedule')
class MaintenanceSchedules extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();
  
  /// Vehicle this schedule applies to
  IntColumn get vehicleId => integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();
  
  /// Category of maintenance this schedule is for
  IntColumn get categoryId => integer().references(MaintenanceCategories, #id)();
  
  /// Title/name of the scheduled maintenance
  TextColumn get title => text().withLength(min: 1, max: 200)();
  
  /// Kilometers interval for recurring maintenance (e.g., every 5000 km)
  RealColumn get intervalKm => real().nullable()();
  
  /// Months interval for recurring maintenance (e.g., every 6 months)
  IntColumn get intervalMonths => integer().nullable()();
  
  /// Date of last service for this schedule
  DateTimeColumn get lastServiceDate => dateTime().nullable()();
  
  /// Odometer reading at last service
  RealColumn get lastServiceKm => real().nullable()();
  
  /// Next due date (calculated based on intervals)
  DateTimeColumn get nextDueDate => dateTime().nullable()();
  
  /// Next due odometer reading (calculated based on intervals)
  RealColumn get nextDueKm => real().nullable()();
  
  /// Whether this schedule is active
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

}