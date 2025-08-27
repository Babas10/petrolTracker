import 'package:drift/drift.dart';

import 'connection/connection.dart';
import 'tables/vehicles_table.dart';
import 'tables/fuel_entries_table.dart';
import 'tables/maintenance_categories_table.dart';
import 'tables/maintenance_logs_table.dart';
import 'tables/maintenance_schedules_table.dart';

part 'database.g.dart';

/// Main database class for the Petrol Tracker application
/// 
/// This class handles all database operations using Drift ORM with SQLite.
/// It includes tables for vehicles, fuel entries, and maintenance tracking with proper relationships.
@DriftDatabase(tables: [Vehicles, FuelEntries, MaintenanceCategories, MaintenanceLogs, MaintenanceSchedules])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());
  
  /// Test constructor for in-memory database (native platforms only)
  AppDatabase.memory() : super(openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        
        // Create indexes for better performance
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_fuel_entries_vehicle_id 
          ON fuel_entries (vehicle_id);
        ''');
        
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_fuel_entries_date 
          ON fuel_entries (date);
        ''');
        
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_fuel_entries_country 
          ON fuel_entries (country);
        ''');
        
        // Create indexes for maintenance tables
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_maintenance_logs_vehicle_id 
          ON maintenance_logs (vehicle_id);
        ''');
        
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_maintenance_logs_service_date 
          ON maintenance_logs (service_date);
        ''');
        
        await customStatement('''
          CREATE INDEX IF NOT EXISTS idx_maintenance_schedules_vehicle_id 
          ON maintenance_schedules (vehicle_id);
        ''');
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Migration from v1 to v2: Add is_full_tank column
          await m.addColumn(fuelEntries, fuelEntries.isFullTank);
          
          // Set all existing entries as full tank (backward compatibility)
          await customStatement('UPDATE fuel_entries SET is_full_tank = 1 WHERE is_full_tank IS NULL');
        }
        
        if (from < 3) {
          // Migration from v2 to v3: Add maintenance tables
          await m.createTable(maintenanceCategories);
          await m.createTable(maintenanceLogs);
          await m.createTable(maintenanceSchedules);
          
          // Create indexes for maintenance tables
          await customStatement('''
            CREATE INDEX IF NOT EXISTS idx_maintenance_logs_vehicle_id 
            ON maintenance_logs (vehicle_id);
          ''');
          
          await customStatement('''
            CREATE INDEX IF NOT EXISTS idx_maintenance_logs_service_date 
            ON maintenance_logs (service_date);
          ''');
          
          await customStatement('''
            CREATE INDEX IF NOT EXISTS idx_maintenance_schedules_vehicle_id 
            ON maintenance_schedules (vehicle_id);
          ''');
          
          // Insert default maintenance categories
          await _insertDefaultMaintenanceCategories();
        }
      },
      beforeOpen: (details) async {
        // Enable foreign keys
        await customStatement('PRAGMA foreign_keys = ON');
        
        // Enable WAL mode for better performance
        await customStatement('PRAGMA journal_mode = WAL');
        
        // Set busy timeout
        await customStatement('PRAGMA busy_timeout = 30000');
      },
    );
  }

  /// Close the database connection
  /// Call this when the app is shutting down
  @override
  Future<void> close() async {
    await super.close();
  }

  /// Insert default maintenance categories during migration
  Future<void> _insertDefaultMaintenanceCategories() async {
    final defaultCategories = [
      {'name': 'Oil & Fluids', 'iconName': 'local_car_wash', 'color': '#FF5722'},
      {'name': 'Filters', 'iconName': 'filter_alt', 'color': '#2196F3'},
      {'name': 'Engine', 'iconName': 'settings', 'color': '#4CAF50'},
      {'name': 'Electrical', 'iconName': 'electrical_services', 'color': '#FFC107'},
      {'name': 'Tires', 'iconName': 'tire_repair', 'color': '#9C27B0'},
      {'name': 'Brakes', 'iconName': 'speed', 'color': '#F44336'},
      {'name': 'Suspension', 'iconName': 'car_repair', 'color': '#607D8B'},
      {'name': 'Inspection', 'iconName': 'search', 'color': '#795548'},
      {'name': 'Cleaning', 'iconName': 'cleaning_services', 'color': '#00BCD4'},
      {'name': 'Other', 'iconName': 'build', 'color': '#757575'},
    ];

    for (final category in defaultCategories) {
      await into(maintenanceCategories).insert(
        MaintenanceCategoriesCompanion.insert(
          name: category['name']!,
          iconName: category['iconName']!,
          color: category['color']!,
          isSystem: const Value(true),
        ),
      );
    }
  }

  /// Get database statistics for debugging
  Future<Map<String, dynamic>> getDatabaseStats() async {
    final vehicleCount = await (select(vehicles).get()).then((list) => list.length);
    final fuelEntryCount = await (select(fuelEntries).get()).then((list) => list.length);
    final maintenanceLogCount = await (select(maintenanceLogs).get()).then((list) => list.length);
    final maintenanceCategoryCount = await (select(maintenanceCategories).get()).then((list) => list.length);
    final maintenanceScheduleCount = await (select(maintenanceSchedules).get()).then((list) => list.length);
    
    return {
      'vehicles': vehicleCount,
      'fuel_entries': fuelEntryCount,
      'maintenance_logs': maintenanceLogCount,
      'maintenance_categories': maintenanceCategoryCount,
      'maintenance_schedules': maintenanceScheduleCount,
      'database_version': schemaVersion,
    };
  }

  /// Clear all data from the database (for testing/reset)
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(maintenanceSchedules).go();
      await delete(maintenanceLogs).go();
      await delete(fuelEntries).go();
      await delete(vehicles).go();
      // Don't delete categories as they are system-defined
    });
  }
}

