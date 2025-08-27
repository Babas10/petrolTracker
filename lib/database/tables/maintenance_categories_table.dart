import 'package:drift/drift.dart';

/// Database table for maintenance categories
/// 
/// Defines predefined and custom categories for maintenance activities.
/// Categories help organize different types of maintenance work (oil, filters, etc.)
@DataClassName('MaintenanceCategory')
class MaintenanceCategories extends Table {
  /// Primary key
  IntColumn get id => integer().autoIncrement()();
  
  /// Category name (e.g., "Oil & Fluids", "Filters", "Engine")
  TextColumn get name => text().withLength(min: 1, max: 100)();
  
  /// Icon name for the category (Material Icons)
  TextColumn get iconName => text().withLength(min: 1, max: 50)();
  
  /// Hex color code for the category (e.g., "#FF5722")
  TextColumn get color => text().withLength(min: 7, max: 7)();
  
  /// Whether this is a system-defined category (cannot be deleted)
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  
  /// Creation timestamp
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

}