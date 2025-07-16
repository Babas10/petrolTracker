import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/services/ephemeral_initialization_service.dart';

void main() {
  group('EphemeralInitializationService', () {
    test('should initialize successfully', () async {
      // Test that initialization completes without errors
      await expectLater(
        EphemeralInitializationService.initialize(),
        completes,
      );
    });
    
    test('should report as initialized', () {
      expect(EphemeralInitializationService.isInitialized, isTrue);
    });
    
    test('should return initialization status', () async {
      final status = await EphemeralInitializationService.getInitializationStatus();
      
      expect(status, isA<Map<String, dynamic>>());
      expect(status['isInitialized'], isTrue);
      expect(status['storageType'], equals('ephemeral'));
      expect(status['timestamp'], isNotNull);
      expect(status['platform'], isA<Map<String, dynamic>>());
      
      final platform = status['platform'] as Map<String, dynamic>;
      expect(platform['type'], equals('all-platforms'));
      expect(platform['storage'], equals('in-memory'));
      expect(platform['persistence'], equals('session-only'));
    });
    
    test('should handle multiple initialization calls', () async {
      // Multiple calls should not cause issues
      await EphemeralInitializationService.initialize();
      await EphemeralInitializationService.initialize();
      await EphemeralInitializationService.initialize();
      
      expect(EphemeralInitializationService.isInitialized, isTrue);
    });
    
    test('should maintain consistent state', () async {
      // Test that initialization state is consistent across calls
      final status1 = await EphemeralInitializationService.getInitializationStatus();
      final status2 = await EphemeralInitializationService.getInitializationStatus();
      
      expect(status1['isInitialized'], equals(status2['isInitialized']));
      expect(status1['storageType'], equals(status2['storageType']));
      expect(status1['platform'], equals(status2['platform']));
    });
  });
}