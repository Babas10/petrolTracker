/// Custom exceptions for database operations.
/// 
/// These exceptions provide better error handling and user-friendly
/// error messages for database-related issues.
library;

/// Base class for all database exceptions
abstract class DatabaseException implements Exception {
  final String message;
  final dynamic originalError;

  const DatabaseException(this.message, [this.originalError]);

  @override
  String toString() {
    return 'DatabaseException: $message${originalError != null ? ' (${originalError.toString()})' : ''}';
  }
}

/// Exception thrown when database initialization fails
class DatabaseInitializationException extends DatabaseException {
  const DatabaseInitializationException(String message, [dynamic originalError])
      : super(message, originalError);

  @override
  String toString() => 'DatabaseInitializationException: $message';
}

/// Exception thrown when a database connection fails
class DatabaseConnectionException extends DatabaseException {
  const DatabaseConnectionException(String message, [dynamic originalError])
      : super(message, originalError);

  @override
  String toString() => 'DatabaseConnectionException: $message';
}

/// Exception thrown when database migration fails
class DatabaseMigrationException extends DatabaseException {
  final int fromVersion;
  final int toVersion;

  const DatabaseMigrationException(
    this.fromVersion,
    this.toVersion,
    String message, [
    dynamic originalError,
  ]) : super(message, originalError);

  @override
  String toString() => 
      'DatabaseMigrationException: Failed to migrate from v$fromVersion to v$toVersion - $message';
}

/// Exception thrown when a constraint violation occurs
class DatabaseConstraintException extends DatabaseException {
  final String constraintName;
  final String tableName;

  const DatabaseConstraintException(
    this.constraintName,
    this.tableName,
    String message, [
    dynamic originalError,
  ]) : super(message, originalError);

  @override
  String toString() => 
      'DatabaseConstraintException: Constraint "$constraintName" violated in table "$tableName" - $message';
}

/// Exception thrown when a foreign key constraint is violated
class DatabaseForeignKeyException extends DatabaseConstraintException {
  final String referencedTable;

  const DatabaseForeignKeyException(
    String constraintName,
    String tableName,
    this.referencedTable,
    String message, [
    dynamic originalError,
  ]) : super(constraintName, tableName, message, originalError);

  @override
  String toString() => 
      'DatabaseForeignKeyException: Foreign key constraint "$constraintName" violated - cannot reference "$referencedTable" - $message';
}

/// Exception thrown when database validation fails
class DatabaseValidationException extends DatabaseException {
  final String fieldName;
  final dynamic fieldValue;

  const DatabaseValidationException(
    this.fieldName,
    this.fieldValue,
    String message, [
    dynamic originalError,
  ]) : super(message, originalError);

  @override
  String toString() => 
      'DatabaseValidationException: Validation failed for field "$fieldName" with value "$fieldValue" - $message';
}

/// Exception thrown when database corruption is detected
class DatabaseCorruptionException extends DatabaseException {
  const DatabaseCorruptionException(String message, [dynamic originalError])
      : super(message, originalError);

  @override
  String toString() => 'DatabaseCorruptionException: $message';
}

/// Exception thrown when database operations timeout
class DatabaseTimeoutException extends DatabaseException {
  final Duration timeout;

  const DatabaseTimeoutException(this.timeout, String message, [dynamic originalError])
      : super(message, originalError);

  @override
  String toString() => 
      'DatabaseTimeoutException: Operation timed out after ${timeout.inMilliseconds}ms - $message';
}

/// Generic database exception for unclassified errors
class _GenericDatabaseException extends DatabaseException {
  const _GenericDatabaseException(String message, [dynamic originalError])
      : super(message, originalError);
}

/// Utility class for converting common database errors to custom exceptions
class DatabaseExceptionHandler {
  /// Convert a generic exception to a more specific database exception
  static DatabaseException handleException(dynamic error, [String? context]) {
    final errorStr = error.toString().toLowerCase();
    final contextStr = context ?? 'Database operation';

    // Foreign key constraint violations
    if (errorStr.contains('foreign key constraint')) {
      return DatabaseForeignKeyException(
        'foreign_key',
        'unknown',
        'unknown',
        '$contextStr failed due to foreign key constraint violation',
        error,
      );
    }

    // Unique constraint violations
    if (errorStr.contains('unique constraint')) {
      return DatabaseConstraintException(
        'unique',
        'unknown',
        '$contextStr failed due to unique constraint violation',
        error,
      );
    }

    // Check constraint violations
    if (errorStr.contains('check constraint')) {
      return DatabaseConstraintException(
        'check',
        'unknown',
        '$contextStr failed due to check constraint violation',
        error,
      );
    }

    // Database corruption
    if (errorStr.contains('database disk image is malformed') ||
        errorStr.contains('database corruption')) {
      return DatabaseCorruptionException(
        '$contextStr failed due to database corruption',
        error,
      );
    }

    // Connection issues
    if (errorStr.contains('unable to open database') ||
        errorStr.contains('database is locked')) {
      return DatabaseConnectionException(
        '$contextStr failed due to connection issues',
        error,
      );
    }

    // Generic database exception - create a concrete implementation
    return _GenericDatabaseException(
      '$contextStr failed: ${error.toString()}',
      error,
    );
  }

  /// Check if an exception is recoverable
  static bool isRecoverable(DatabaseException exception) {
    return exception is! DatabaseCorruptionException &&
           exception is! DatabaseInitializationException;
  }

  /// Get user-friendly error message
  static String getUserFriendlyMessage(DatabaseException exception) {
    if (exception is DatabaseForeignKeyException) {
      return 'Cannot perform this operation because it would break data relationships.';
    }
    
    if (exception is DatabaseConstraintException) {
      if (exception.constraintName == 'unique') {
        return 'This item already exists. Please use a different name or value.';
      }
      return 'The data provided does not meet the requirements.';
    }

    if (exception is DatabaseCorruptionException) {
      return 'The database appears to be corrupted. Please contact support.';
    }

    if (exception is DatabaseConnectionException) {
      return 'Unable to connect to the database. Please try again.';
    }

    if (exception is DatabaseTimeoutException) {
      return 'The operation took too long. Please try again.';
    }

    return 'A database error occurred. Please try again.';
  }
}