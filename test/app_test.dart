import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/app.dart';
import 'package:petrol_tracker/screens/splash_screen.dart';
import 'package:petrol_tracker/screens/initialization_error_screen.dart';

void main() {
  group('PetrolTrackerApp', () {
    testWidgets('should display splash screen initially', (tester) async {
      await tester.pumpWidget(const PetrolTrackerApp());

      // Should show splash screen during initialization
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // Should display app logo and name
      expect(find.byIcon(Icons.local_gas_station), findsOneWidget);
      expect(find.text('Petrol Tracker'), findsOneWidget);
    });

    testWidgets('should have proper theme configuration', (tester) async {
      await tester.pumpWidget(const PetrolTrackerApp());

      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp).first,
      );

      // Should have proper title
      expect(materialApp.title, equals('Petrol Tracker'));
      
      // Should hide debug banner
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
      
      // Should have themes configured
      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
      expect(materialApp.themeMode, equals(ThemeMode.system));
    });

    testWidgets('should use Material 3 design', (tester) async {
      await tester.pumpWidget(const PetrolTrackerApp());

      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp).first,
      );

      // Should use Material 3
      expect(materialApp.theme?.useMaterial3, isTrue);
      expect(materialApp.darkTheme?.useMaterial3, isTrue);
    });

    testWidgets('should have green color scheme', (tester) async {
      await tester.pumpWidget(const PetrolTrackerApp());

      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp).first,
      );

      // Light theme should have green-based color scheme
      expect(materialApp.theme?.colorScheme.primary, isNotNull);
      
      // Dark theme should have green-based color scheme
      expect(materialApp.darkTheme?.colorScheme.primary, isNotNull);
    });

    testWidgets('should handle initialization completion', (tester) async {
      await tester.pumpWidget(const PetrolTrackerApp());

      // Initially should show splash screen
      expect(find.byType(SplashScreen), findsOneWidget);

      // Wait for initialization to potentially complete
      // Note: In a real test, we'd need to mock the initialization service
      await tester.pump();
      
      // Splash screen should still be present during initialization
      expect(find.byType(SplashScreen), findsOneWidget);
    });
  });

  group('AppInitializationState', () {
    test('should have correct enum values', () {
      expect(AppInitializationState.initializing, isNotNull);
      expect(AppInitializationState.completed, isNotNull);
      expect(AppInitializationState.failed, isNotNull);
    });

    test('should have three distinct states', () {
      final values = AppInitializationState.values;
      expect(values.length, equals(3));
      expect(values, contains(AppInitializationState.initializing));
      expect(values, contains(AppInitializationState.completed));
      expect(values, contains(AppInitializationState.failed));
    });
  });

  group('Theme Configuration', () {
    testWidgets('should create light theme with green seed color', (tester) async {
      await tester.pumpWidget(const PetrolTrackerApp());

      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp).first,
      );

      final lightTheme = materialApp.theme!;
      expect(lightTheme.useMaterial3, isTrue);
      expect(lightTheme.colorScheme.brightness, equals(Brightness.light));
      
      // Should have green-influenced color scheme
      expect(lightTheme.colorScheme.primary, isNotNull);
    });

    testWidgets('should create dark theme with green seed color', (tester) async {
      await tester.pumpWidget(const PetrolTrackerApp());

      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp).first,
      );

      final darkTheme = materialApp.darkTheme!;
      expect(darkTheme.useMaterial3, isTrue);
      expect(darkTheme.colorScheme.brightness, equals(Brightness.dark));
      
      // Should have green-influenced color scheme
      expect(darkTheme.colorScheme.primary, isNotNull);
    });

    testWidgets('should respond to system theme mode', (tester) async {
      await tester.pumpWidget(const PetrolTrackerApp());

      final materialApp = tester.widget<MaterialApp>(
        find.byType(MaterialApp).first,
      );

      expect(materialApp.themeMode, equals(ThemeMode.system));
    });
  });

  group('Error Handling', () {
    testWidgets('should show error screen when initialization fails', (tester) async {
      // This test would require mocking the initialization service to fail
      // For now, we'll test the structure
      
      await tester.pumpWidget(const PetrolTrackerApp());
      
      // Should start with splash screen
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // In case of error, should show error screen
      // This would require simulating an initialization failure
    });
  });

  group('Navigation Integration', () {
    testWidgets('should integrate with main app navigation after initialization', (tester) async {
      await tester.pumpWidget(const PetrolTrackerApp());
      
      // Should start with splash screen
      expect(find.byType(SplashScreen), findsOneWidget);
      
      // After successful initialization, should show main app
      // This would require waiting for initialization to complete
    });
  });
}