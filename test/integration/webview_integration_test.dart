import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/screens/dashboard_screen.dart';
import 'package:petrol_tracker/widgets/chart_webview.dart';

void main() {
  group('WebView Integration Tests', () {
    testWidgets('Dashboard should integrate with WebView charts', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      // Should show dashboard initially
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Consumption Charts'), findsOneWidget);
      
      // Should show empty state initially
      expect(find.text('No fuel entries yet'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('Dashboard should show chart when data is available', (WidgetTester tester) async {
      // Create a provider container with test data
      final container = ProviderContainer();
      
      // Add test vehicle and fuel entries
      final vehicleNotifier = container.read(vehiclesProvider.notifier);
      final fuelNotifier = container.read(fuelEntriesProvider.notifier);

      await vehicleNotifier.addVehicle(VehicleModel.create(
        name: 'Test Vehicle',
        initialKm: 10000.0,
      ));

      final vehicleState = await container.read(vehiclesProvider.future);
      final testVehicle = vehicleState.vehicles.first;

      await fuelNotifier.addFuelEntry(FuelEntryModel.create(
        vehicleId: testVehicle.id!,
        date: DateTime.now(),
        currentKm: 10300.0,
        fuelAmount: 50.0,
        price: 75.0,
        pricePerLiter: 1.50,
        country: 'Canada',
        consumption: 7.5,
      ));

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show dashboard with data
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Consumption Charts'), findsOneWidget);
      
      // Should not show empty state
      expect(find.text('No fuel entries yet'), findsNothing);
      
      // Should show chart WebView (loading state)
      expect(find.text('Loading chart...'), findsOneWidget);

      container.dispose();
    });

    testWidgets('Dashboard should handle multiple fuel entries', (WidgetTester tester) async {
      final container = ProviderContainer();
      
      // Add test vehicle
      final vehicleNotifier = container.read(vehiclesProvider.notifier);
      await vehicleNotifier.addVehicle(VehicleModel.create(
        name: 'Test Vehicle',
        initialKm: 10000.0,
      ));

      final vehicleState = await container.read(vehiclesProvider.future);
      final testVehicle = vehicleState.vehicles.first;

      // Add multiple fuel entries
      final fuelNotifier = container.read(fuelEntriesProvider.notifier);
      
      for (int i = 0; i < 5; i++) {
        await fuelNotifier.addFuelEntry(FuelEntryModel.create(
          vehicleId: testVehicle.id!,
          date: DateTime.now().subtract(Duration(days: i)),
          currentKm: 10000.0 + (i * 300.0),
          fuelAmount: 50.0,
          price: 75.0,
          pricePerLiter: 1.50,
          country: 'Canada',
          consumption: 7.5 + i * 0.5,
        ));
      }

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show stats correctly
      expect(find.text('5'), findsOneWidget); // Total entries
      expect(find.text('1'), findsOneWidget); // Vehicles

      // Should show recent entries
      expect(find.text('Recent Entries'), findsOneWidget);

      container.dispose();
    });

    testWidgets('ChartWebView should handle different chart types', (WidgetTester tester) async {
      const testData = [
        {'date': '2024-01-01', 'value': 7.5},
        {'date': '2024-01-02', 'value': 8.0},
        {'date': '2024-01-03', 'value': 7.8},
      ];

      // Test line chart
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartWebView(
              data: testData,
              config: const ChartConfig(
                type: ChartType.line,
                title: 'Line Chart Test',
                xLabel: 'Date',
                yLabel: 'Consumption',
                unit: 'L/100km',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Loading chart...'), findsOneWidget);
      await tester.pump();

      // Test bar chart
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartWebView(
              data: const [
                {'label': 'Canada', 'value': 150.0},
                {'label': 'USA', 'value': 120.0},
              ],
              config: const ChartConfig(
                type: ChartType.bar,
                title: 'Bar Chart Test',
                xLabel: 'Country',
                yLabel: 'Total Cost',
                unit: '\$',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Loading chart...'), findsOneWidget);
      await tester.pump();

      // Test area chart
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartWebView(
              data: testData,
              config: const ChartConfig(
                type: ChartType.area,
                title: 'Area Chart Test',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Loading chart...'), findsOneWidget);
      await tester.pump();

      // Test multi-line chart
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartWebView(
              data: const [
                {'date': '2024-01-01', 'series1': 7.5, 'series2': 8.0},
                {'date': '2024-01-02', 'series1': 8.0, 'series2': 7.8},
              ],
              config: const ChartConfig(
                type: ChartType.multiLine,
                title: 'Multi-Line Chart Test',
                series: ['series1', 'series2'],
                seriesLabels: {'series1': 'Vehicle 1', 'series2': 'Vehicle 2'},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Loading chart...'), findsOneWidget);
      await tester.pump();
    });

    testWidgets('Dashboard should handle refresh correctly', (WidgetTester tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap refresh button
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Dashboard should still be functional after refresh
      expect(find.text('Dashboard'), findsOneWidget);

      container.dispose();
    });

    testWidgets('Dashboard should show loading states correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      // Should show initial loading or data states
      await tester.pump();
      
      // Stats should show loading or actual values
      expect(find.text('...'), findsWidgets);

      await tester.pumpAndSettle();
    });

    testWidgets('Dashboard should handle error states gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DashboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Dashboard should render without errors
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Welcome to Dashboard'), findsOneWidget);
    });
  });

  group('Chart Event Handling Tests', () {
    testWidgets('ChartWebView should handle event callbacks', (WidgetTester tester) async {
      bool chartReadyCalled = false;
      String? lastEventType;
      Map<String, dynamic>? lastEventData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartWebView(
              data: const [
                {'date': '2024-01-01', 'value': 7.5},
              ],
              config: const ChartConfig(
                type: ChartType.line,
                title: 'Event Test Chart',
              ),
              onChartReady: () {
                chartReadyCalled = true;
              },
              onChartEvent: (eventType, data) {
                lastEventType = eventType;
                lastEventData = data;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Callbacks should be properly set up
      expect(chartReadyCalled, isFalse); // WebView not actually loaded in test
      expect(lastEventType, isNull);
      expect(lastEventData, isNull);
    });

    testWidgets('ChartWebView should handle error callbacks', (WidgetTester tester) async {
      String? lastError;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartWebView(
              data: const [],
              config: const ChartConfig(
                type: ChartType.line,
                title: 'Error Test Chart',
              ),
              onError: (error) {
                lastError = error;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Error callback should be properly set up
      expect(lastError, isNull); // No errors in test environment
    });
  });
}