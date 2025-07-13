import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/services/app_initialization_service.dart';
import 'package:petrol_tracker/database/database_service.dart';

void main() {
  group('AppInitializationService', () {
    setUp(() {
      // Reset database state before each test
      if (DatabaseService.instance.isInitialized) {
        DatabaseService.instance.close();
      }
    });

    tearDown(() async {
      // Clean up after each test
      if (DatabaseService.instance.isInitialized) {
        await DatabaseService.instance.close();
      }
    });

    test('should initialize successfully with valid setup', () async {
      List<String> progressMessages = [];
      List<double> progressValues = [];

      await AppInitializationService.initialize(
        onProgress: (message, progress) {
          progressMessages.add(message);
          progressValues.add(progress);
        },
      );

      // Verify initialization completed
      expect(AppInitializationService.isInitialized, isTrue);
      expect(DatabaseService.instance.isInitialized, isTrue);

      // Verify progress was reported
      expect(progressMessages, isNotEmpty);
      expect(progressValues, isNotEmpty);
      expect(progressValues.first, greaterThanOrEqualTo(0.0));
      expect(progressValues.last, equals(1.0));

      // Verify progress messages are meaningful
      expect(progressMessages.any((msg) => msg.contains('database')), isTrue);
      expect(progressMessages.any((msg) => msg.contains('complete')), isTrue);
    });

    test('should report progress correctly', () async {
      List<double> progressValues = [];

      await AppInitializationService.initialize(
        onProgress: (message, progress) {
          progressValues.add(progress);
        },
      );

      // Verify progress is monotonically increasing
      for (int i = 1; i < progressValues.length; i++) {
        expect(progressValues[i], greaterThanOrEqualTo(progressValues[i - 1]));
      }

      // Verify progress starts at 0 and ends at 1
      expect(progressValues.first, lessThanOrEqualTo(0.1));
      expect(progressValues.last, equals(1.0));
    });

    test('should handle database initialization errors', () async {
      // This test would require mocking DatabaseService to throw an error
      // For now, we'll test the exception structure

      try {
        // Force close database to simulate an error condition
        await DatabaseService.instance.close();
        
        // This should not throw since the service handles reinitialization
        await AppInitializationService.initialize();
        
        expect(AppInitializationService.isInitialized, isTrue);
      } catch (e) {
        expect(e, isA<AppInitializationException>());
        expect((e as AppInitializationException).canRetry, isTrue);
      }
    });

    test('should provide initialization status', () async {
      await AppInitializationService.initialize();

      final status = await AppInitializationService.getInitializationStatus();

      expect(status, isA<Map<String, dynamic>>());
      expect(status['isInitialized'], isTrue);
      expect(status['timestamp'], isNotNull);
      expect(status['platform'], isNotNull);
      expect(status['database'], isNotNull);
    });

    test('should handle multiple initialization calls gracefully', () async {
      // First initialization
      await AppInitializationService.initialize();
      expect(AppInitializationService.isInitialized, isTrue);

      // Second initialization should not cause issues
      await AppInitializationService.initialize();
      expect(AppInitializationService.isInitialized, isTrue);
    });

    test('should provide platform information', () async {
      await AppInitializationService.initialize();
      final status = await AppInitializationService.getInitializationStatus();
      
      expect(status['platform'], isNotNull);
      expect(status['platform']['type'], isNotNull);
      
      // Platform type should be either 'web' or 'native'
      final platformType = status['platform']['type'] as String;
      expect(['web', 'native'], contains(platformType));
    });
  });

  group('AppInitializationException', () {
    test('should create exception with message', () {
      const exception = AppInitializationException('Test error');

      expect(exception.message, equals('Test error'));
      expect(exception.canRetry, isTrue);
      expect(exception.recoveryHint, isNull);
      expect(exception.originalError, isNull);
    });

    test('should create exception with recovery hint', () {
      const exception = AppInitializationException(
        'Test error',
        recoveryHint: 'Try restarting',
        canRetry: false,
      );

      expect(exception.message, equals('Test error'));
      expect(exception.recoveryHint, equals('Try restarting'));
      expect(exception.canRetry, isFalse);
    });

    test('should create exception with original error', () {
      final originalError = Exception('Original error');
      final exception = AppInitializationException(
        'Test error',
        originalError: originalError,
      );

      expect(exception.message, equals('Test error'));
      expect(exception.originalError, equals(originalError));
    });

    test('should provide user-friendly messages', () {
      const databaseException = AppInitializationException('database connection failed');
      expect(databaseException.userFriendlyMessage, contains('database'));

      const platformException = AppInitializationException('platform services failed');
      expect(platformException.userFriendlyMessage, contains('platform'));

      const migrationException = AppInitializationException('migration failed');
      expect(migrationException.userFriendlyMessage, contains('database'));

      const genericException = AppInitializationException('unknown error');
      expect(genericException.userFriendlyMessage, contains('application'));
    });

    test('should format toString correctly', () {
      const exception = AppInitializationException(
        'Test error',
        recoveryHint: 'Try again',
      );

      final stringRepresentation = exception.toString();
      expect(stringRepresentation, contains('AppInitializationException'));
      expect(stringRepresentation, contains('Test error'));
      expect(stringRepresentation, contains('Recovery hint'));
      expect(stringRepresentation, contains('Try again'));
    });

    test('should format toString without recovery hint', () {
      const exception = AppInitializationException('Test error');

      final stringRepresentation = exception.toString();
      expect(stringRepresentation, contains('AppInitializationException'));
      expect(stringRepresentation, contains('Test error'));
      expect(stringRepresentation, isNot(contains('Recovery hint')));
    });
  });

  group('Database Health Checks', () {
    test('should verify database integrity during initialization', () async {
      await AppInitializationService.initialize();

      // Verify database is healthy
      final isHealthy = await DatabaseService.instance.checkIntegrity();
      expect(isHealthy, isTrue);
    });

    test('should include database information in status', () async {
      await AppInitializationService.initialize();
      final status = await AppInitializationService.getInitializationStatus();

      expect(status['database'], isNotNull);
      expect(status['database']['isHealthy'], isNotNull);
      expect(status['database']['size'], isNotNull);
      expect(status['database']['stats'], isNotNull);
    });
  });
}