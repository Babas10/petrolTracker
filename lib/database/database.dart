import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:sqlite3/sqlite3.dart';

import 'tables/vehicles_table.dart';
import 'tables/fuel_entries_table.dart';

part 'database.g.dart';

/// Main database class for the Petrol Tracker application
/// 
/// This class handles all database operations using Drift ORM with SQLite.
/// It includes tables for vehicles and fuel entries with proper relationships.
@DriftDatabase(tables: [Vehicles, FuelEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  /// Test constructor for in-memory database
  AppDatabase.memory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

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
        // Future migration logic will go here
        // Example:
        // if (from < 2) {
        //   // Migration from v1 to v2
        //   await m.addColumn(fuelEntries, fuelEntries.newColumn);
        // }
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

/// Creates and configures the database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Ensure sqlite3 is properly initialized on mobile platforms
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Make sqlite3 pick a more suitable location for temporary files
    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    // Get the application documents directory
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'petrol_tracker.db'));

    return NativeDatabase.createInBackground(
      file,
      logStatements: true, // Set to false in production
    );
  });
}