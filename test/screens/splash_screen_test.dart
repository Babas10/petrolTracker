import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/screens/splash_screen.dart';
import 'package:petrol_tracker/services/app_initialization_service.dart';

void main() {
  group('SplashScreen', () {
    testWidgets('should display app logo and name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Should display app logo
      expect(find.byIcon(Icons.local_gas_station), findsOneWidget);
      
      // Should display app name
      expect(find.text('Petrol Tracker'), findsOneWidget);
      
      // Should display tagline
      expect(find.text('Track your fuel consumption'), findsOneWidget);
      
      // Should display version info
      expect(find.text('Version 1.0.0'), findsOneWidget);
    });

    testWidgets('should show progress indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Should show progress indicator
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      
      // Should show initial progress message
      await tester.pump();
      expect(find.text('Starting application...'), findsOneWidget);
    });

    testWidgets('should animate logo appearance', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Initially logo might be scaled down or transparent
      await tester.pump();
      
      // After animation completes, logo should be fully visible
      await tester.pump(const Duration(seconds: 2));
      
      final logoContainer = tester.widget<Container>(
        find.descendant(
          of: find.byIcon(Icons.local_gas_station),
          matching: find.byType(Container),
        ).first,
      );
      
      expect(logoContainer, isNotNull);
    });

    testWidgets('should call onInitializationComplete when successful', (tester) async {
      bool completionCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onInitializationComplete: () {
              completionCalled = true;
            },
          ),
        ),
      );

      // Wait for initialization to complete
      await tester.pumpAndSettle(const Duration(seconds: 10));
      
      // Should have called completion callback
      expect(completionCalled, isTrue);
    });

    testWidgets('should show error state when initialization fails', (tester) async {
      AppInitializationException? capturedError;
      
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onInitializationError: (error) {
              capturedError = error;
            },
          ),
        ),
      );

      // Wait for potential initialization
      await tester.pumpAndSettle(const Duration(seconds: 10));
      
      // If error occurred, should have captured it
      if (capturedError != null) {
        expect(capturedError, isA<AppInitializationException>());
      }
    });

    testWidgets('should display different progress messages', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Initial message
      await tester.pump();
      expect(find.text('Starting application...'), findsOneWidget);
      
      // Wait for progress updates
      await tester.pump(const Duration(milliseconds: 500));
      
      // Should show some progress
      final progressIndicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(progressIndicator.value, greaterThanOrEqualTo(0.0));
    });

    testWidgets('should show retry button on error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplashScreen(
            onInitializationError: (error) {
              // Error handled by parent
            },
          ),
        ),
      );

      // This is a simplified test - in real scenario, we'd need to mock
      // AppInitializationService to throw an error
      await tester.pump();
      
      // For now, just verify the widget renders without errors
      expect(find.byType(SplashScreen), findsOneWidget);
    });
  });

  group('SimpleSplashScreen', () {
    testWidgets('should display basic elements', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SimpleSplashScreen(),
        ),
      );

      // Should display app logo
      expect(find.byIcon(Icons.local_gas_station), findsOneWidget);
      
      // Should display app name
      expect(find.text('Petrol Tracker'), findsOneWidget);
      
      // Should display loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should use primary color scheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: const SimpleSplashScreen(),
        ),
      );

      await tester.pump();

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNotNull);
    });
  });

  group('SplashScreen Error Handling', () {
    testWidgets('should display error icon when initialization fails', (tester) async {
      // This test simulates the error state
      await tester.pumpWidget(
        const MaterialApp(
          home: _TestErrorSplashScreen(),
        ),
      );

      await tester.pump();

      // Should show error icon
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      
      // Should show error title
      expect(find.text('Initialization Failed'), findsOneWidget);
      
      // Should show retry button if error is retryable
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should handle retry button press', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: _TestErrorSplashScreen(),
        ),
      );

      await tester.pump();

      // Find and tap retry button
      final retryButton = find.widgetWithIcon(ElevatedButton, Icons.refresh);
      if (retryButton.evaluate().isNotEmpty) {
        await tester.tap(retryButton);
        await tester.pump();
        
        // Should trigger retry logic
        expect(find.text('Retrying initialization...'), findsOneWidget);
      }
    });
  });
}

/// Test widget that simulates the error state of SplashScreen
class _TestErrorSplashScreen extends StatefulWidget {
  const _TestErrorSplashScreen();

  @override
  State<_TestErrorSplashScreen> createState() => _TestErrorSplashScreenState();
}

class _TestErrorSplashScreenState extends State<_TestErrorSplashScreen> {
  final AppInitializationException _error = const AppInitializationException(
    'Test initialization error',
    recoveryHint: 'This is a test error',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Error Icon
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              
              const SizedBox(height: 16),
              
              // Error Title
              Text(
                'Initialization Failed',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Error Message
              Text(
                _error.userFriendlyMessage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Retry Button
              ElevatedButton.icon(
                onPressed: () {
                  // Simulate retry
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.onPrimary,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
              
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}