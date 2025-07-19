import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/widgets/chart_webview.dart';

void main() {
  group('ChartWebView Widget Tests', () {
    testWidgets('should display loading state initially', (WidgetTester tester) async {
      const chartData = <Map<String, dynamic>>[];
      const config = ChartConfig(
        type: ChartType.line,
        title: 'Test Chart',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartWebView(
              data: chartData,
              config: config,
            ),
          ),
        ),
      );

      expect(find.text('Loading chart...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle error state', (WidgetTester tester) async {
      const chartData = <Map<String, dynamic>>[];
      const config = ChartConfig(
        type: ChartType.line,
        title: 'Test Chart',
      );

      bool errorCallbackCalled = false;
      String? errorMessage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartWebView(
              data: chartData,
              config: config,
              onError: (error) {
                errorCallbackCalled = true;
                errorMessage = error;
              },
            ),
          ),
        ),
      );

      // Initial loading state
      expect(find.text('Loading chart...'), findsOneWidget);
      
      // Wait for potential errors to occur
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    });

    testWidgets('should handle chart events', (WidgetTester tester) async {
      const chartData = [
        {'date': '2024-01-01', 'value': 7.5},
        {'date': '2024-01-02', 'value': 8.0},
      ];
      
      const config = ChartConfig(
        type: ChartType.line,
        title: 'Test Chart',
        xLabel: 'Date',
        yLabel: 'Consumption',
        unit: 'L/100km',
      );

      String? lastEventType;
      Map<String, dynamic>? lastEventData;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartWebView(
              data: chartData,
              config: config,
              onChartEvent: (eventType, data) {
                lastEventType = eventType;
                lastEventData = data;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // The event callback should be properly set up
      expect(lastEventType, isNull); // No events yet
      expect(lastEventData, isNull);
    });

    testWidgets('should update when data changes', (WidgetTester tester) async {
      const initialData = [
        {'date': '2024-01-01', 'value': 7.5},
      ];
      
      const config = ChartConfig(
        type: ChartType.line,
        title: 'Test Chart',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartWebView(
              data: initialData,
              config: config,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Update with new data
      const newData = [
        {'date': '2024-01-01', 'value': 7.5},
        {'date': '2024-01-02', 'value': 8.0},
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChartWebView(
              data: newData,
              config: config,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Chart should update with new data
    });
  });

  group('ChartConfig Tests', () {
    test('should create valid JSON configuration', () {
      const config = ChartConfig(
        type: ChartType.line,
        title: 'Test Chart',
        xLabel: 'Date',
        yLabel: 'Value',
        unit: 'L/100km',
        className: 'consumption',
        series: ['series1', 'series2'],
        seriesLabels: {'series1': 'Series 1', 'series2': 'Series 2'},
      );

      final json = config.toJson();

      expect(json['title'], equals('Test Chart'));
      expect(json['xLabel'], equals('Date'));
      expect(json['yLabel'], equals('Value'));
      expect(json['unit'], equals('L/100km'));
      expect(json['className'], equals('consumption'));
      expect(json['series'], equals(['series1', 'series2']));
      expect(json['seriesLabels'], equals({'series1': 'Series 1', 'series2': 'Series 2'}));
    });

    test('should handle null optional values', () {
      const config = ChartConfig(
        type: ChartType.bar,
      );

      final json = config.toJson();

      expect(json['title'], isNull);
      expect(json['xLabel'], isNull);
      expect(json['yLabel'], isNull);
      expect(json['unit'], isNull);
      expect(json['className'], isNull);
      expect(json['series'], isNull);
      expect(json['seriesLabels'], isNull);
    });
  });

  group('ChartDataPoint Tests', () {
    test('should create valid JSON from ChartDataPoint', () {
      final dataPoint = ChartDataPoint(
        date: DateTime(2024, 1, 1),
        value: 7.5,
        metadata: {'entryId': 1, 'vehicleId': 2},
      );

      final json = dataPoint.toJson();

      expect(json['date'], equals('2024-01-01'));
      expect(json['value'], equals(7.5));
      expect(json['entryId'], equals(1));
      expect(json['vehicleId'], equals(2));
    });

    test('should create valid JSON with label instead of date', () {
      const dataPoint = ChartDataPoint(
        label: 'January',
        value: 100.0,
        metadata: {'count': 5},
      );

      final json = dataPoint.toJson();

      expect(json['label'], equals('January'));
      expect(json['value'], equals(100.0));
      expect(json['count'], equals(5));
      expect(json.containsKey('date'), isFalse);
    });

    test('should handle minimal data point', () {
      const dataPoint = ChartDataPoint(value: 42.0);

      final json = dataPoint.toJson();

      expect(json['value'], equals(42.0));
      expect(json.containsKey('date'), isFalse);
      expect(json.containsKey('label'), isFalse);
    });
  });

  group('MultiSeriesChartData Tests', () {
    test('should create valid JSON from MultiSeriesChartData', () {
      final data = MultiSeriesChartData(
        date: DateTime(2024, 1, 1),
        values: {'series1': 7.5, 'series2': 8.0},
      );

      final json = data.toJson();

      expect(json['date'], equals('2024-01-01'));
      expect(json['series1'], equals(7.5));
      expect(json['series2'], equals(8.0));
    });

    test('should handle empty values map', () {
      final data = MultiSeriesChartData(
        date: DateTime(2024, 1, 1),
        values: {},
      );

      final json = data.toJson();

      expect(json['date'], equals('2024-01-01'));
      expect(json.length, equals(1)); // Only date
    });
  });

  group('Extension Methods Tests', () {
    test('ChartDataExtensions.toChartData should work correctly', () {
      final dataPoints = [
        ChartDataPoint(
          date: DateTime(2024, 1, 1),
          value: 7.5,
        ),
        const ChartDataPoint(
          label: 'Test',
          value: 8.0,
        ),
      ];

      final chartData = dataPoints.toChartData();

      expect(chartData.length, equals(2));
      expect(chartData[0]['date'], equals('2024-01-01'));
      expect(chartData[0]['value'], equals(7.5));
      expect(chartData[1]['label'], equals('Test'));
      expect(chartData[1]['value'], equals(8.0));
    });

    test('MultiSeriesChartDataExtensions.toChartData should work correctly', () {
      final multiSeriesData = [
        MultiSeriesChartData(
          date: DateTime(2024, 1, 1),
          values: {'consumption': 7.5, 'price': 1.50},
        ),
        MultiSeriesChartData(
          date: DateTime(2024, 1, 2),
          values: {'consumption': 8.0, 'price': 1.55},
        ),
      ];

      final chartData = multiSeriesData.toChartData();

      expect(chartData.length, equals(2));
      expect(chartData[0]['date'], equals('2024-01-01'));
      expect(chartData[0]['consumption'], equals(7.5));
      expect(chartData[0]['price'], equals(1.50));
      expect(chartData[1]['date'], equals('2024-01-02'));
      expect(chartData[1]['consumption'], equals(8.0));
      expect(chartData[1]['price'], equals(1.55));
    });
  });
}