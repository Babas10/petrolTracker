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
  int get schemaVersion => 4;

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
        
        if (from < 4) {
          // Migration from v3 to v4: Update maintenance categories with comprehensive list
          // Clear existing basic categories and insert comprehensive ones
          await customStatement('DELETE FROM maintenance_categories WHERE is_system = 1');
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
      // Engine & Fluids
      {'name': 'Engine Oil & Filter', 'iconName': 'local_car_wash', 'color': '#FF5722'},
      {'name': 'Coolant / Antifreeze', 'iconName': 'ac_unit', 'color': '#2196F3'},
      {'name': 'Transmission Fluid', 'iconName': 'settings', 'color': '#FF9800'},
      {'name': 'Brake Fluid', 'iconName': 'local_shipping', 'color': '#F44336'},
      {'name': 'Power Steering Fluid', 'iconName': 'tune', 'color': '#9C27B0'},
      {'name': 'Differential / Transfer Case Oil', 'iconName': 'build_circle', 'color': '#607D8B'},
      
      // Filters & Air Systems
      {'name': 'Air Filter', 'iconName': 'filter_alt', 'color': '#4CAF50'},
      {'name': 'Cabin / Pollen Filter', 'iconName': 'air', 'color': '#00BCD4'},
      {'name': 'Fuel Filter', 'iconName': 'local_gas_station', 'color': '#FFC107'},
      
      // Brakes
      {'name': 'Brake Pads', 'iconName': 'speed', 'color': '#F44336'},
      {'name': 'Brake Rotors / Drums', 'iconName': 'album', 'color': '#E91E63'},
      {'name': 'Brake Lines / Hoses', 'iconName': 'linear_scale', 'color': '#9E9E9E'},
      {'name': 'ABS System Check', 'iconName': 'security', 'color': '#FF5722'},
      
      // Tires & Wheels
      {'name': 'Tire Rotation', 'iconName': 'tire_repair', 'color': '#9C27B0'},
      {'name': 'Tire Replacement', 'iconName': 'cached', 'color': '#673AB7'},
      {'name': 'Wheel Alignment', 'iconName': 'straighten', 'color': '#3F51B5'},
      {'name': 'Balancing', 'iconName': 'balance', 'color': '#2196F3'},
      {'name': 'Tire Pressure Checks', 'iconName': 'compress', 'color': '#03DAC6'},
      
      // Battery & Electrical
      {'name': 'Battery Replacement / Test', 'iconName': 'battery_full', 'color': '#FFC107'},
      {'name': 'Alternator / Starter Check', 'iconName': 'electrical_services', 'color': '#FF9800'},
      {'name': 'Lights (Headlights, Taillights, Indicators)', 'iconName': 'lightbulb', 'color': '#FFEB3B'},
      {'name': 'Fuses & Relays', 'iconName': 'power', 'color': '#795548'},
      
      // Suspension & Steering
      {'name': 'Shocks / Struts', 'iconName': 'car_repair', 'color': '#607D8B'},
      {'name': 'Ball Joints / Control Arms', 'iconName': 'join_inner', 'color': '#546E7A'},
      {'name': 'Tie Rods', 'iconName': 'link', 'color': '#78909C'},
      {'name': 'Power Steering System', 'iconName': 'control_camera', 'color': '#90A4AE'},
      
      // Exhaust & Emissions
      {'name': 'Muffler / Exhaust System', 'iconName': 'cloud', 'color': '#9E9E9E'},
      {'name': 'Catalytic Converter', 'iconName': 'eco', 'color': '#4CAF50'},
      {'name': 'Emissions Testing', 'iconName': 'science', 'color': '#8BC34A'},
      
      // Belts & Hoses
      {'name': 'Timing Belt / Chain', 'iconName': 'watch', 'color': '#FF9800'},
      {'name': 'Serpentine Belt', 'iconName': 'waves', 'color': '#FF5722'},
      {'name': 'Radiator Hoses / Heater Hoses', 'iconName': 'device_thermostat', 'color': '#F44336'},
      
      // Heating & Air Conditioning
      {'name': 'A/C Service / Refrigerant Recharge', 'iconName': 'ac_unit', 'color': '#2196F3'},
      {'name': 'Heater Core', 'iconName': 'whatshot', 'color': '#FF5722'},
      {'name': 'Blower Motor', 'iconName': 'air', 'color': '#00BCD4'},
      
      // Body & Interior
      {'name': 'Windshield / Wipers', 'iconName': 'visibility', 'color': '#03DAC6'},
      {'name': 'Door Locks / Windows', 'iconName': 'door_front', 'color': '#009688'},
      {'name': 'Seat Belts', 'iconName': 'airline_seat_legroom_normal', 'color': '#4CAF50'},
      {'name': 'Rust Treatment', 'iconName': 'healing', 'color': '#795548'},
      
      // Scheduled Maintenance
      {'name': 'Annual Service', 'iconName': 'event', 'color': '#9C27B0'},
      {'name': 'Major Service (60k/100k km)', 'iconName': 'build', 'color': '#673AB7'},
      {'name': 'Inspection Stickers / Certifications', 'iconName': 'verified', 'color': '#3F51B5'},
      
      // Repairs & Miscellaneous
      {'name': 'Unexpected Repairs', 'iconName': 'warning', 'color': '#FF9800'},
      {'name': 'Recalls / Warranty Work', 'iconName': 'policy', 'color': '#2196F3'},
      {'name': 'Accessories (Tow Hitch, Roof Rack, etc.)', 'iconName': 'extension', 'color': '#607D8B'},
      
      // General
      {'name': 'Other', 'iconName': 'more_horiz', 'color': '#757575'},
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

