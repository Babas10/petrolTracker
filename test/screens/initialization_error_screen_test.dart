import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/screens/initialization_error_screen.dart';
import 'package:petrol_tracker/services/app_initialization_service.dart';

void main() {
  group('InitializationErrorScreen', () {
    late AppInitializationException testError;

    setUp(() {
      testError = const AppInitializationException(
        'Test initialization error',
        recoveryHint: 'Try restarting the application',
        canRetry: true,
      );
    });

    testWidgets('should display error information', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InitializationErrorScreen(error: testError),
        ),
      );

      // Should display error icon
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      
      // Should display title
      expect(find.text('Initialization Failed'), findsOneWidget);
      
      // Should display user-friendly error message
      expect(find.text(testError.userFriendlyMessage), findsOneWidget);
      
      // Should display recovery hint
      expect(find.text(testError.recoveryHint!), findsOneWidget);
    });

    testWidgets('should show retry button when error is retryable', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InitializationErrorScreen(error: testError),
        ),
      );

      // Should show retry button
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should hide retry button when error is not retryable', (tester) async {
      final nonRetryableError = AppInitializationException(
        'Critical error',
        canRetry: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: InitializationErrorScreen(error: nonRetryableError),
        ),
      );

      // Should not show retry button
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsNothing);
    });

    testWidgets('should show exit button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InitializationErrorScreen(error: testError),
        ),
      );

      // Should show exit button
      expect(find.widgetWithText(OutlinedButton, 'Exit App'), findsOneWidget);
      expect(find.byIcon(Icons.exit_to_app), findsOneWidget);
    });

    testWidgets('should call onRetry when retry button is pressed', (tester) async {
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: InitializationErrorScreen(
            error: testError,
            onRetry: () {
              retryCalled = true;
            },
          ),
        ),
      );

      // Tap retry button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
      await tester.pumpAndSettle();

      expect(retryCalled, isTrue);
    });

    testWidgets('should call onExit when exit button is pressed', (tester) async {
      bool exitCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: InitializationErrorScreen(
            error: testError,
            onExit: () {
              exitCalled = true;
            },
          ),
        ),
      );

      // Tap exit button
      await tester.tap(find.widgetWithText(OutlinedButton, 'Exit App'));
      await tester.pump();

      expect(exitCalled, isTrue);
    });

    testWidgets('should show loading state during retry', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InitializationErrorScreen(
            error: testError,
            onRetry: () async {
              // Simulate async retry operation
              await Future.delayed(const Duration(milliseconds: 100));
            },
          ),
        ),
      );

      // Tap retry button
      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
      await tester.pump();

      // Should show loading state
      expect(find.text('Retrying...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for retry to complete
      await tester.pumpAndSettle();

      // Should return to normal state
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should expand technical details section', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InitializationErrorScreen(error: testError),
        ),
      );

      // Find and tap the technical details expansion tile
      final expansionTile = find.widgetWithText(ExpansionTile, 'Technical Details');
      expect(expansionTile, findsOneWidget);

      await tester.tap(expansionTile);
      await tester.pumpAndSettle();

      // Should show technical details
      expect(find.text('Error Type'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(find.text(testError.message), findsOneWidget);
    });

    testWidgets('should show copy error details button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InitializationErrorScreen(error: testError),
        ),
      );

      // Expand technical details
      await tester.tap(find.widgetWithText(ExpansionTile, 'Technical Details'));
      await tester.pumpAndSettle();

      // Should show copy button
      expect(find.widgetWithText(OutlinedButton, 'Copy Error Details'), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('should display system information section', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InitializationErrorScreen(error: testError),
        ),
      );

      // Should show system information section
      expect(find.widgetWithText(ExpansionTile, 'System Information'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('should show loading for diagnostic information initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InitializationErrorScreen(error: testError),
        ),
      );

      // Should show loading state for diagnostic info
      expect(find.text('Loading diagnostic information...'), findsOneWidget);
    });

    testWidgets('should display help text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InitializationErrorScreen(error: testError),
        ),
      );

      // Should show help text
      expect(
        find.text('If the problem persists, try clearing app data or reinstalling the application.'),
        findsOneWidget,
      );
    });

    testWidgets('should handle error without recovery hint', (tester) async {
      final errorWithoutHint = const AppInitializationException('Simple error');

      await tester.pumpWidget(
        MaterialApp(
          home: InitializationErrorScreen(error: errorWithoutHint),
        ),
      );

      // Should not show recovery hint section
      expect(find.byIcon(Icons.lightbulb_outline), findsNothing);
    });

    testWidgets('should use error container color scheme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: InitializationErrorScreen(error: testError),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNotNull);
    });
  });

  group('AppInitializationException User Messages', () {
    testWidgets('should show database-specific message for database errors', (tester) async {
      final databaseError = const AppInitializationException('Database connection failed');

      await tester.pumpWidget(
        MaterialApp(
          home: InitializationErrorScreen(error: databaseError),
        ),
      );

      expect(find.text(databaseError.userFriendlyMessage), findsOneWidget);
      expect(databaseError.userFriendlyMessage, contains('database'));
    });

    testWidgets('should show platform-specific message for platform errors', (tester) async {
      final platformError = const AppInitializationException('Platform initialization failed');

      await tester.pumpWidget(
        MaterialApp(
          home: InitializationErrorScreen(error: platformError),
        ),
      );

      expect(find.text(platformError.userFriendlyMessage), findsOneWidget);
      expect(platformError.userFriendlyMessage, contains('platform'));
    });

    testWidgets('should show migration-specific message for migration errors', (tester) async {
      final migrationError = const AppInitializationException('Migration failed');

      await tester.pumpWidget(
        MaterialApp(
          home: InitializationErrorScreen(error: migrationError),
        ),
      );

      expect(find.text(migrationError.userFriendlyMessage), findsOneWidget);
      expect(migrationError.userFriendlyMessage, contains('database'));
    });

    testWidgets('should show generic message for unknown errors', (tester) async {
      final genericError = const AppInitializationException('Unknown error occurred');

      await tester.pumpWidget(
        MaterialApp(
          home: InitializationErrorScreen(error: genericError),
        ),
      );

      expect(find.text(genericError.userFriendlyMessage), findsOneWidget);
      expect(genericError.userFriendlyMessage, contains('application'));
    });
  });
}