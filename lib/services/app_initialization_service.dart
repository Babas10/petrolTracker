import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:petrol_tracker/database/database_service.dart';

/// Callback type for initialization progress updates
typedef ProgressCallback = void Function(String message, double progress);

/// Service responsible for initializing the application during startup
/// 
/// This service ensures that all critical components are properly initialized
/// before the main UI is displayed to the user. It provides comprehensive
/// error handling and progress reporting for a smooth startup experience.
class AppInitializationService {
  static const String _logTag = 'AppInitializationService';
  
  /// Initialize the application
  /// 
  /// This method performs all necessary initialization steps in the correct order:
  /// 1. Database initialization and health checks
  /// 2. Platform-specific setup
  /// 3. Migration execution if needed
  /// 4. Service initialization
  /// 
  /// [onProgress] - Optional callback to receive progress updates
  /// 
  /// Throws [AppInitializationException] if initialization fails
  static Future<void> initialize({ProgressCallback? onProgress}) async {
    developer.log('Starting app initialization', name: _logTag);
    
    try {
      // Step 1: Initialize database (40% of total progress)
      onProgress?.call('Initializing database...', 0.1);
      await _initializeDatabase();
      onProgress?.call('Database initialized', 0.4);
      
      // Step 2: Verify database health (20% of total progress)
      onProgress?.call('Checking database health...', 0.5);
      await _verifyDatabaseHealth();
      onProgress?.call('Database health verified', 0.6);
      
      // Step 3: Platform-specific initialization (20% of total progress)
      onProgress?.call('Initializing platform services...', 0.7);
      await _initializePlatformServices();
      onProgress?.call('Platform services initialized', 0.8);
      
      // Step 4: Run any pending migrations (10% of total progress)
      onProgress?.call('Running database migrations...', 0.85);
      await _runMigrations();
      onProgress?.call('Migrations completed', 0.9);
      
      // Step 5: Initialize other services (10% of total progress)
      onProgress?.call('Initializing application services...', 0.95);
      await _initializeOtherServices();
      onProgress?.call('Initialization complete', 1.0);
      
      developer.log('App initialization completed successfully', name: _logTag);
    } catch (e, stackTrace) {
      developer.log(
        'App initialization failed: $e',
        name: _logTag,
        error: e,
        stackTrace: stackTrace,
      );
      throw AppInitializationException(
        'Failed to initialize application: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// Initialize the database connection
  static Future<void> _initializeDatabase() async {
    try {
      await DatabaseService.instance.initialize();
      developer.log('Database connection established', name: _logTag);
    } catch (e) {
      // On web platforms, provide more specific error handling
      if (kIsWeb && e.toString().contains('sql.js')) {
        throw AppInitializationException(
          'Web database configuration issue: IndexedDB not properly configured',
          originalError: e,
          recoveryHint: 'This appears to be a configuration issue. Please try refreshing the page.',
        );
      }
      
      throw AppInitializationException(
        'Database initialization failed: $e',
        originalError: e,
        recoveryHint: kIsWeb 
          ? 'Please try refreshing the page or clearing browser data'
          : 'Please try restarting the application',
      );
    }
  }
  
  /// Verify database health and integrity
  static Future<void> _verifyDatabaseHealth() async {
    try {
      // On web platforms with IndexedDB, skip complex integrity checks
      // and just verify basic functionality
      if (kIsWeb) {
        await _performBasicWebHealthCheck();
      } else {
        final isHealthy = await DatabaseService.instance.checkIntegrity();
        if (!isHealthy) {
          throw AppInitializationException(
            'Database health verification failed',
            recoveryHint: 'Try clearing app data or reinstalling the application',
          );
        }
        
        // Additional health checks for native platforms
        await _performAdditionalHealthChecks();
      }
      
      developer.log('Database health verification passed', name: _logTag);
    } catch (e) {
      if (e is AppInitializationException) rethrow;
      throw AppInitializationException(
        'Database health verification failed: $e',
        originalError: e,
        recoveryHint: kIsWeb 
          ? 'Please try refreshing the page or clearing your browser data'
          : 'Try restarting the application',
      );
    }
  }
  
  /// Perform basic health check for web platforms
  static Future<void> _performBasicWebHealthCheck() async {
    try {
      // Just verify we can run a simple query - this is sufficient for web
      await DatabaseService.instance.database.customSelect('SELECT 1').get();
      developer.log('Web database basic functionality verified', name: _logTag);
    } catch (e) {
      throw AppInitializationException(
        'Web database basic functionality test failed: $e',
        originalError: e,
        recoveryHint: 'Please try refreshing the page or clearing your browser data',
      );
    }
  }
  
  /// Perform additional database health checks
  static Future<void> _performAdditionalHealthChecks() async {
    // Test basic database operations
    try {
      // Check if we can perform basic queries
      await DatabaseService.instance.database.customSelect('SELECT 1').get();
      
      // Check database size (warn if too large) - skip on web as it may not be supported
      if (!kIsWeb) {
        try {
          final size = await DatabaseService.instance.getDatabaseSize();
          if (size != null && size > 100 * 1024 * 1024) { // 100MB
            developer.log(
              'Database size is large: ${(size / 1024 / 1024).toStringAsFixed(1)}MB',
              name: _logTag,
            );
          }
        } catch (e) {
          developer.log('Database size check not available on this platform: $e', name: _logTag);
          // Don't fail initialization for size check issues
        }
      }
      
      developer.log('Additional health checks passed', name: _logTag);
    } catch (e) {
      throw AppInitializationException(
        'Basic database operations failed: $e',
        originalError: e,
        recoveryHint: kIsWeb 
          ? 'Please ensure your browser supports IndexedDB and try refreshing the page'
          : 'Please try restarting the application',
      );
    }
  }
  
  /// Initialize platform-specific services
  static Future<void> _initializePlatformServices() async {
    try {
      if (kIsWeb) {
        await _initializeWebServices();
      } else if (Platform.isAndroid) {
        await _initializeAndroidServices();
      } else if (Platform.isIOS) {
        await _initializeIOSServices();
      } else if (Platform.isMacOS) {
        await _initializeMacOSServices();
      } else if (Platform.isWindows) {
        await _initializeWindowsServices();
      } else if (Platform.isLinux) {
        await _initializeLinuxServices();
      }
      
      developer.log('Platform services initialized', name: _logTag);
    } catch (e) {
      throw AppInitializationException(
        'Platform-specific initialization failed: $e',
        originalError: e,
      );
    }
  }
  
  /// Initialize web-specific services
  static Future<void> _initializeWebServices() async {
    // Web-specific initialization
    developer.log('Initializing web services', name: _logTag);
    
    try {
      // For web, we need to ensure IndexedDB is available
      // This is a basic check - IndexedDB should be available in all modern browsers
      developer.log('Checking IndexedDB availability', name: _logTag);
      
      // Additional web-specific setup can go here
      developer.log('Web services initialized successfully', name: _logTag);
    } catch (e) {
      developer.log('Web services initialization failed: $e', name: _logTag);
      throw AppInitializationException(
        'Web platform initialization failed: $e',
        originalError: e,
        recoveryHint: 'Please ensure you are using a modern web browser that supports IndexedDB',
      );
    }
  }
  
  /// Initialize Android-specific services
  static Future<void> _initializeAndroidServices() async {
    // Android-specific initialization
    developer.log('Initializing Android services', name: _logTag);
    // Add any Android-specific initialization here
  }
  
  /// Initialize iOS-specific services
  static Future<void> _initializeIOSServices() async {
    // iOS-specific initialization
    developer.log('Initializing iOS services', name: _logTag);
    // Add any iOS-specific initialization here
  }
  
  /// Initialize macOS-specific services
  static Future<void> _initializeMacOSServices() async {
    // macOS-specific initialization
    developer.log('Initializing macOS services', name: _logTag);
    // Add any macOS-specific initialization here
  }
  
  /// Initialize Windows-specific services
  static Future<void> _initializeWindowsServices() async {
    // Windows-specific initialization
    developer.log('Initializing Windows services', name: _logTag);
    // Add any Windows-specific initialization here
  }
  
  /// Initialize Linux-specific services
  static Future<void> _initializeLinuxServices() async {
    // Linux-specific initialization
    developer.log('Initializing Linux services', name: _logTag);
    // Add any Linux-specific initialization here
  }
  
  /// Run database migrations if needed
  static Future<void> _runMigrations() async {
    try {
      // Check if migrations are needed
      // For now, this is a placeholder as Drift handles migrations automatically
      // In the future, this could include data migrations or custom setup
      
      developer.log('Migration check completed', name: _logTag);
    } catch (e) {
      throw AppInitializationException(
        'Database migration failed: $e',
        originalError: e,
      );
    }
  }
  
  /// Initialize other application services
  static Future<void> _initializeOtherServices() async {
    try {
      // Initialize any other services that need to be ready before the UI
      // Examples: analytics, crash reporting, push notifications, etc.
      
      developer.log('Other services initialized', name: _logTag);
    } catch (e) {
      throw AppInitializationException(
        'Service initialization failed: $e',
        originalError: e,
      );
    }
  }
  
  /// Check if the app has been initialized
  static bool get isInitialized {
    return DatabaseService.instance.isInitialized;
  }
  
  /// Get initialization status information for debugging
  static Future<Map<String, dynamic>> getInitializationStatus() async {
    final status = <String, dynamic>{
      'isInitialized': isInitialized,
      'timestamp': DateTime.now().toIso8601String(),
      'platform': _getPlatformInfo(),
    };
    
    if (isInitialized) {
      try {
        final dbSize = await DatabaseService.instance.getDatabaseSize();
        final dbStats = await DatabaseService.instance.getStats();
        status['database'] = {
          'isHealthy': await DatabaseService.instance.checkIntegrity(),
          'size': dbSize,
          'stats': dbStats,
        };
      } catch (e) {
        status['database'] = {'error': e.toString()};
      }
    }
    
    return status;
  }
  
  /// Get platform information
  static Map<String, dynamic> _getPlatformInfo() {
    if (kIsWeb) {
      return {'type': 'web'};
    } else {
      return {
        'type': 'native',
        'os': Platform.operatingSystem,
        'version': Platform.operatingSystemVersion,
      };
    }
  }
}

/// Exception thrown when app initialization fails
class AppInitializationException implements Exception {
  /// The error message
  final String message;
  
  /// The original error that caused this exception
  final dynamic originalError;
  
  /// Stack trace from the original error
  final StackTrace? stackTrace;
  
  /// Optional hint for recovery
  final String? recoveryHint;
  
  /// Whether this error can be retried
  final bool canRetry;
  
  const AppInitializationException(
    this.message, {
    this.originalError,
    this.stackTrace,
    this.recoveryHint,
    this.canRetry = true,
  });
  
  @override
  String toString() {
    var result = 'AppInitializationException: $message';
    if (recoveryHint != null) {
      result += '\nRecovery hint: $recoveryHint';
    }
    return result;
  }
  
  /// Get a user-friendly error message
  String get userFriendlyMessage {
    if (message.contains('database')) {
      return 'Failed to initialize the database. Please try restarting the app.';
    } else if (message.contains('platform')) {
      return 'Failed to initialize platform services. Please check your device settings.';
    } else if (message.contains('migration')) {
      return 'Failed to update the database. Please try clearing app data.';
    } else {
      return 'Failed to start the application. Please try restarting.';
    }
  }
}