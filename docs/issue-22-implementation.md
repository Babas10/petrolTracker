# Issue #22: Configure SQLite Database with Drift

## Overview

This document details the implementation of Issue #22 - "Configure SQLite database with Drift" for the Petrol Tracker application.

## Issue Description

Setup local database layer using SQLite with Drift package for data persistence, including table definitions, migrations, and error handling.

## Implementation Summary

### ✅ Completed Tasks

1. **Drift Dependencies Setup**
   - Added drift ORM dependencies to pubspec.yaml
   - Configured build_runner for code generation
   - Added sqlite3 and path provider dependencies

2. **Database Configuration**
   - Created main database class `AppDatabase` with Drift annotations
   - Implemented proper connection management with LazyDatabase
   - Added test constructor for in-memory database testing

3. **Table Definitions**
   - Created `Vehicles` table with proper constraints and relationships
   - Created `FuelEntries` table with foreign key to vehicles
   - Added comprehensive column definitions with validation

4. **Database Migrations and Optimization**
   - Implemented migration strategy with proper versioning
   - Added database indexes for performance optimization
   - Configured WAL mode and foreign key constraints

5. **Database Service Layer**
   - Created `DatabaseService` singleton for connection management
   - Implemented lifecycle management (initialize/close)
   - Added utility methods for maintenance operations

6. **Error Handling**
   - Created comprehensive exception hierarchy
   - Implemented `DatabaseExceptionHandler` for error conversion
   - Added user-friendly error messages

7. **Testing Infrastructure**
   - Created comprehensive test suite covering all database operations
   - Implemented in-memory database for testing
   - Added tests for constraints, transactions, and error handling

## Technical Details

### Database Schema

#### Vehicles Table
```sql
CREATE TABLE vehicles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE COLLATE NOCASE,
  initial_km REAL NOT NULL,
  created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now'))
);
```

#### Fuel Entries Table
```sql
CREATE TABLE fuel_entries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  vehicle_id INTEGER NOT NULL,
  date INTEGER NOT NULL,
  current_km REAL NOT NULL,
  fuel_amount REAL NOT NULL,
  price REAL NOT NULL,
  country TEXT NOT NULL,
  price_per_liter REAL NOT NULL,
  consumption REAL,
  FOREIGN KEY (vehicle_id) REFERENCES vehicles (id),
  UNIQUE(vehicle_id, date)
);
```

### Performance Optimizations

1. **Indexes Created**
   - `idx_fuel_entries_vehicle_id` - For filtering by vehicle
   - `idx_fuel_entries_date` - For date range queries
   - `idx_fuel_entries_country` - For country-based analysis

2. **Database Configuration**
   - WAL mode enabled for better concurrency
   - Foreign keys enforced for data integrity
   - Busy timeout set to 30 seconds

### Key Features Implemented

#### Connection Management
```dart
class DatabaseService {
  static DatabaseService? _instance;
  static AppDatabase? _database;
  
  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }
  
  AppDatabase get database {
    _database ??= AppDatabase();
    return _database!;
  }
}
```

#### Migration Strategy
```dart
@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // Create performance indexes
      await customStatement('CREATE INDEX...');
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Future migration logic
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      await customStatement('PRAGMA journal_mode = WAL');
    },
  );
}
```

#### Exception Handling
```dart
class DatabaseExceptionHandler {
  static DatabaseException handleException(dynamic error, [String? context]) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('foreign key constraint')) {
      return DatabaseForeignKeyException(...);
    }
    if (errorStr.contains('unique constraint')) {
      return DatabaseConstraintException(...);
    }
    // ... other error types
  }
}
```

## Files Created/Modified

### New Files
- `lib/database/database.dart` - Main database configuration
- `lib/database/database_service.dart` - Singleton service layer
- `lib/database/database_exceptions.dart` - Exception handling
- `lib/database/tables/vehicles_table.dart` - Vehicles table definition
- `lib/database/tables/fuel_entries_table.dart` - Fuel entries table definition
- `test/database_test.dart` - Comprehensive test suite
- `lib/database/database.g.dart` - Generated Drift code
- `docs/issue-22-implementation.md` - This documentation

### Modified Files
- `pubspec.yaml` - Added Drift dependencies and sqlite3

## Verification

### Code Quality
- ✅ `flutter analyze` passes with only minor linting suggestions
- ✅ All database tests pass (8/8)
- ✅ Main app tests continue to pass
- ✅ Code generation successful with no errors

### Functionality Testing
- ✅ Database initialization and connection management
- ✅ CRUD operations for vehicles and fuel entries
- ✅ Foreign key constraints enforcement
- ✅ Unique constraints validation
- ✅ Transaction handling
- ✅ Data integrity checks
- ✅ Exception handling and error conversion

### Performance Features
- ✅ Proper indexing for common queries
- ✅ WAL mode for better concurrency
- ✅ Connection pooling and lifecycle management
- ✅ In-memory testing support

## Database Statistics

The database service provides runtime statistics:
```dart
{
  'vehicles': 0,           // Number of vehicles
  'fuel_entries': 0,       // Number of fuel entries  
  'database_version': 1,   // Schema version
}
```

## Error Handling Examples

```dart
try {
  await database.into(database.vehicles).insert(duplicateVehicle);
} catch (e) {
  final dbException = DatabaseExceptionHandler.handleException(e);
  final userMessage = DatabaseExceptionHandler.getUserFriendlyMessage(dbException);
  // userMessage: "This item already exists. Please use a different name or value."
}
```

## Next Steps

This database foundation enables the following subsequent issues:

1. **Issue #23**: Implement data models and repositories
2. **Issue #24**: Setup Riverpod state management  
3. **Issue #1**: Vehicle management screen
4. **Issue #2**: Fuel entry form with validation

## Maintenance Operations

The database service provides maintenance utilities:
- `vacuum()` - Reclaim unused space
- `checkIntegrity()` - Verify database integrity
- `getDatabaseSize()` - Get database file size
- `clearAllData()` - Reset all data (testing/development)

## Conclusion

Issue #22 has been successfully implemented, providing a robust, well-tested database foundation for the Petrol Tracker application. The implementation includes proper error handling, performance optimizations, comprehensive testing, and follows Drift best practices for Flutter applications.