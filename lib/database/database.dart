import 'package:drift/drift.dart';

import 'connection/connection.dart';
import 'tables/vehicles_table.dart';
import 'tables/fuel_entries_table.dart';

part 'database.g.dart';

/// Main database class for the Petrol Tracker application
/// 
/// This class handles all database operations using Drift ORM with SQLite.
/// It includes tables for vehicles and fuel entries with proper relationships.
@DriftDatabase(tables: [Vehicles, FuelEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());
  
  /// Test constructor for in-memory database (native platforms only)
  AppDatabase.memory() : super(openConnection());

  @override
  int get schemaVersion => 2;

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
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Migration from v1 to v2: Add is_full_tank column
          await m.addColumn(fuelEntries, fuelEntries.isFullTank);
          
          // Set all existing entries as full tank (backward compatibility)
          await customStatement('UPDATE fuel_entries SET is_full_tank = 1 WHERE is_full_tank IS NULL');
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

  /// Get database statistics for debugging
  Future<Map<String, dynamic>> getDatabaseStats() async {
    final vehicleCount = await (select(vehicles).get()).then((list) => list.length);
    final fuelEntryCount = await (select(fuelEntries).get()).then((list) => list.length);
    
    return {
      'vehicles': vehicleCount,
      'fuel_entries': fuelEntryCount,
      'database_version': schemaVersion,
    };
  }

  /// Clear all data from the database (for testing/reset)
  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(fuelEntries).go();
      await delete(vehicles).go();
    });
  }
}

