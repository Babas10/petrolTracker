import 'package:drift/drift.dart';
import 'vehicles_table.dart';
import 'maintenance_categories_table.dart';

/// Database table for maintenance logs
/// 
/// Records all maintenance activities performed on vehicles.
/// Links to vehicles and maintenance categories with detailed tracking.
@DataClassName('MaintenanceLog')
class MaintenanceLogs extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();
  
  /// Vehicle this maintenance was performed on
  IntColumn get vehicleId => integer().references(Vehicles, #id, onDelete: KeyAction.cascade)();
  
  /// Category of maintenance (e.g., oil change, tire rotation)
  IntColumn get categoryId => integer().references(MaintenanceCategories, #id)();
  
  /// Title/name of the maintenance activity
  TextColumn get title => text().withLength(min: 1, max: 200)();
  
  /// Detailed description of the maintenance work
  TextColumn get description => text().nullable().withLength(max: 1000)();
  
  /// Date when the maintenance was performed
  DateTimeColumn get serviceDate => dateTime()();
  
  /// Odometer reading at time of service
  RealColumn get odometerReading => real()();
  
  /// Service provider (garage, self, dealer, etc.)
  TextColumn get serviceProvider => text().nullable().withLength(max: 200)();
  
  /// Cost of parts used
  RealColumn get partsCost => real().withDefault(const Constant(0.0))();
  
  /// Cost of labor
  RealColumn get laborCost => real().withDefault(const Constant(0.0))();
  
  /// Total cost (parts + labor + other)
  RealColumn get totalCost => real().withDefault(const Constant(0.0))();
  
  /// Currency code (e.g., USD, EUR, CAD)
  TextColumn get currency => text().withLength(min: 3, max: 3).withDefault(const Constant('USD'))();
  
  /// Hours of labor required
  RealColumn get laborHours => real().nullable()();
  
  /// Additional notes or comments
  TextColumn get notes => text().nullable().withLength(max: 2000)();
  
  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  /// Last updated timestamp
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

}