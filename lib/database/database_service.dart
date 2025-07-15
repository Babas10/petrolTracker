import 'dart:developer' as developer;

import 'database.dart';

/// Singleton service for managing the database connection
/// 
/// This service provides a single point of access to the database throughout
/// the application. It handles initialization, connection management, and
/// graceful shutdown.
class DatabaseService {
  static DatabaseService? _instance;
  static AppDatabase? _database;

  /// Private constructor for singleton pattern
  DatabaseService._();

  /// Get the singleton instance of DatabaseService
  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// Get the database instance
  /// 
  /// This will create the database connection if it doesn't exist yet.
  /// The connection will be reused for subsequent calls.
  AppDatabase get database {
    _database ??= AppDatabase();
    return _database!;
  }

  /// Check if the database is initialized
  bool get isInitialized => _database != null;

  /// Initialize the database connection
  /// 
  /// This method is optional - the database will be automatically initialized
  /// on first access. However, calling this explicitly allows you to handle
  /// any initialization errors upfront.
  Future<void> initialize() async {
    if (_database == null) {
      _database = AppDatabase();
      
      // Test the connection by running a simple query
      try {
        await _database!.customSelect('SELECT 1').get();
        developer.log('Database initialized successfully');
      } catch (e) {
        developer.log('Database initialization failed: $e');
        rethrow;
      }
    }
  }

  /// Close the database connection
  /// 
  /// Call this when the app is shutting down to ensure all data is saved
  /// and resources are properly released.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      _instance = null;
      developer.log('Database connection closed');
    }
  }

  /// Get database statistics for debugging and monitoring
  Future<Map<String, dynamic>> getStats() async {
    return await database.getDatabaseStats();
  }

  /// Clear all data from the database
  /// 
  /// ⚠️ **WARNING**: This will permanently delete all data!
  /// This method should only be used for testing or when the user
  /// explicitly requests a data reset.
  Future<void> clearAllData() async {
    await database.clearAllData();
    developer.log('All database data cleared');
  }

  /// Run a database transaction
  /// 
  /// This is a convenience method for running multiple database operations
  /// as a single atomic transaction.
  Future<T> transaction<T>(Future<T> Function() action) async {
    return await database.transaction(action);
  }

  /// Check database integrity
  /// 
  /// Runs SQLite's built-in integrity check to verify the database
  /// is not corrupted. On web platforms, this may not be supported
  /// so we fall back to a basic functionality test.
  Future<bool> checkIntegrity() async {
    try {
      // Try the full integrity check first
      final result = await database.customSelect('PRAGMA integrity_check').get();
      final isOk = result.isNotEmpty && 
                   result.first.data['integrity_check'] == 'ok';
      
      if (isOk) {
        developer.log('Database integrity check: OK');
      } else {
        developer.log('Database integrity check: FAILED');
        developer.log('Result: ${result.map((r) => r.data).toList()}');
      }
      
      return isOk;
    } catch (e) {
      developer.log('Database integrity check error: $e');
      
      // On web or other platforms where PRAGMA integrity_check might not work,
      // fall back to a basic functionality test
      try {
        await database.customSelect('SELECT 1').get();
        developer.log('Database basic functionality check: OK (fallback)');
        return true;
      } catch (fallbackError) {
        developer.log('Database basic functionality check failed: $fallbackError');
        return false;
      }
    }
  }

  /// Get database file size in bytes
  /// 
  /// Note: This may not be supported on all platforms (e.g., web with IndexedDB)
  Future<int?> getDatabaseSize() async {
    try {
      final result = await database.customSelect('PRAGMA page_count').get();
      final pageCount = result.first.data['page_count'] as int;
      
      final pageSizeResult = await database.customSelect('PRAGMA page_size').get();
      final pageSize = pageSizeResult.first.data['page_size'] as int;
      
      return pageCount * pageSize;
    } catch (e) {
      developer.log('Error getting database size (may not be supported on this platform): $e');
      return null;
    }
  }

  /// Vacuum the database to reclaim space
  /// 
  /// This operation rebuilds the database file, removing unused space.
  /// It can take some time for large databases.
  Future<void> vacuum() async {
    try {
      await database.customStatement('VACUUM');
      developer.log('Database vacuum completed');
    } catch (e) {
      developer.log('Database vacuum failed: $e');
      rethrow;
    }
  }
}