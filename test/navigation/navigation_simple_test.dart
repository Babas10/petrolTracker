import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/navigation/app_router.dart';
import 'package:petrol_tracker/navigation/main_layout.dart';

void main() {
  group('Navigation Basic Tests', () {
    testWidgets('App should load without errors', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have basic navigation structure
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Welcome to Dashboard'), findsOneWidget);
    });

    testWidgets('Bottom navigation should have all tabs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have all navigation destinations
      expect(find.byType(NavigationDestination), findsNWidgets(5));
      
      // Should have the tab labels
      expect(find.text('Entries'), findsOneWidget);
      expect(find.text('Add Entry'), findsOneWidget);
      expect(find.text('Vehicles'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Should navigate to different screens', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: appRouter,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to Entries
      await tester.tap(find.text('Entries'));
      await tester.pumpAndSettle();
      expect(find.text('No Fuel Entries Yet'), findsOneWidget);

      // Navigate to Vehicles
      await tester.tap(find.text('Vehicles'));
      await tester.pumpAndSettle();
      expect(find.text('No Vehicles Yet'), findsOneWidget);

      // Navigate to Settings
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Appearance'), findsOneWidget);
    });

    group('AppRoute enum', () {
      test('Should have correct paths', () {
        expect(AppRoute.dashboard.path, equals('/'));
        expect(AppRoute.entries.path, equals('/entries'));
        expect(AppRoute.addEntry.path, equals('/add-entry'));
        expect(AppRoute.vehicles.path, equals('/vehicles'));
        expect(AppRoute.settings.path, equals('/settings'));
      });
    });

    group('NavAppBar', () {
      testWidgets('Should display title correctly', (tester) async {
        const title = 'Test Screen';

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              appBar: NavAppBar(title: title),
            ),
          ),
        );

        expect(find.text(title), findsOneWidget);
      });

      testWidgets('Should show actions when provided', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              appBar: NavAppBar(
                title: 'Test',
                actions: [
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: null,
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('Should show back button when requested', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              appBar: NavAppBar(
                title: 'Test',
                showBackButton: true,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      });
    });
  });
}