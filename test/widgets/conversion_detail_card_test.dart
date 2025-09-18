import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/widgets/conversion_detail_card.dart';

void main() {
  group('ConversionDetailCard', () {
    late FuelEntryModel mockEntry;

    setUp(() {
      mockEntry = FuelEntryModel(
        id: 1,
        vehicleId: 1,
        date: DateTime(2023, 12, 1),
        currentKm: 100000,
        fuelAmount: 50.0,
        price: 75.50,
        originalAmount: 100.0,
        currency: 'EUR',
        country: 'France',
        pricePerLiter: 1.51,
        consumption: 7.5,
        isFullTank: true,
      );
    });

    Widget createWidget({
      double? convertedAmount,
      double? exchangeRate,
      String targetCurrency = 'USD',
      String? error,
      bool isLoading = false,
      DateTime? conversionTimestamp,
      VoidCallback? onRetry,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ConversionDetailCard(
            entry: mockEntry,
            convertedAmount: convertedAmount,
            exchangeRate: exchangeRate,
            targetCurrency: targetCurrency,
            error: error,
            isLoading: isLoading,
            conversionTimestamp: conversionTimestamp,
            onRetry: onRetry,
          ),
        ),
      );
    }

    testWidgets('displays loading state', (tester) async {
      await tester.pumpWidget(createWidget(isLoading: true));

      expect(find.text('Currency Conversion'), findsOneWidget);
      expect(find.text('Converting EUR to USD...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsAtLeastOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error state with retry button', (tester) async {
      bool retryTapped = false;
      await tester.pumpWidget(createWidget(
        error: 'Network connection failed',
        onRetry: () => retryTapped = true,
      ));

      expect(find.text('Currency Conversion'), findsOneWidget);
      expect(find.text('Conversion Failed'), findsOneWidget);
      expect(find.text('Network connection failed'), findsOneWidget);
      expect(find.text('Original Amount:'), findsOneWidget);
      expect(find.text('75.50 EUR'), findsOneWidget);
      expect(find.text('Retry Conversion'), findsOneWidget);

      await tester.tap(find.text('Retry Conversion'));
      expect(retryTapped, isTrue);
    });

    testWidgets('displays error state without retry button', (tester) async {
      await tester.pumpWidget(createWidget(
        error: 'Conversion service unavailable',
      ));

      expect(find.text('Conversion Failed'), findsOneWidget);
      expect(find.text('Conversion service unavailable'), findsOneWidget);
      expect(find.text('Retry Conversion'), findsNothing);
    });

    testWidgets('displays successful conversion details', (tester) async {
      await tester.pumpWidget(createWidget(
        convertedAmount: 83.05,
        exchangeRate: 1.1,
        conversionTimestamp: DateTime(2023, 12, 1, 14, 30),
      ));

      expect(find.text('Currency Conversion'), findsOneWidget);
      expect(find.text('Original'), findsOneWidget);
      expect(find.text('75.50 EUR'), findsOneWidget);
      expect(find.text('Converted'), findsOneWidget);
      expect(find.text('83.05 USD'), findsOneWidget);
      expect(find.text('Exchange Rate'), findsOneWidget);
      expect(find.text('1 EUR = 1.1000 USD'), findsOneWidget);
      expect(find.text('Calculation'), findsOneWidget);
      expect(find.text('75.50 × 1.1000 = 83.05'), findsOneWidget);
      expect(find.text('Entry Date'), findsOneWidget);
      expect(find.text('Dec 1, 2023'), findsOneWidget);
      expect(find.text('Conversion Time'), findsOneWidget);
      expect(find.text('Dec 1, 2023 14:30'), findsOneWidget);
    });

    testWidgets('displays per-liter conversion breakdown', (tester) async {
      await tester.pumpWidget(createWidget(
        convertedAmount: 83.05,
        exchangeRate: 1.1,
      ));

      expect(find.text('Price per Liter Breakdown'), findsOneWidget);
      expect(find.text('Original:'), findsOneWidget);
      expect(find.text('1.510 EUR/L'), findsOneWidget);
      expect(find.text('Converted:'), findsOneWidget);
      expect(find.text('1.661 USD/L'), findsOneWidget); // 1.51 * 1.1 = 1.661
    });

    testWidgets('displays no conversion state when currencies match', (tester) async {
      await tester.pumpWidget(createWidget(
        targetCurrency: 'EUR', // Same as entry currency
      ));

      expect(find.text('Currency Conversion'), findsOneWidget);
      expect(find.text('No currency conversion needed. Entry is already in EUR.'), findsOneWidget);
    });

    testWidgets('displays conversion without timestamp', (tester) async {
      await tester.pumpWidget(createWidget(
        convertedAmount: 83.05,
        exchangeRate: 1.1,
      ));

      expect(find.text('Conversion Time'), findsNothing);
    });

    testWidgets('handles missing conversion data gracefully', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Currency Conversion'), findsOneWidget);
      // Should show the no conversion state or handle gracefully
    });
  });

  group('CompactConversionDetailCard', () {
    late FuelEntryModel mockEntry;

    setUp(() {
      mockEntry = FuelEntryModel(
        id: 1,
        vehicleId: 1,
        date: DateTime(2023, 12, 1),
        currentKm: 100000,
        fuelAmount: 50.0,
        price: 75.50,
        currency: 'EUR',
        country: 'France',
        pricePerLiter: 1.51,
        isFullTank: true,
      );
    });

    Widget createWidget({
      double? convertedAmount,
      double? exchangeRate,
      String targetCurrency = 'USD',
      String? error,
      bool isLoading = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CompactConversionDetailCard(
            entry: mockEntry,
            convertedAmount: convertedAmount,
            exchangeRate: exchangeRate,
            targetCurrency: targetCurrency,
            error: error,
            isLoading: isLoading,
          ),
        ),
      );
    }

    testWidgets('displays loading state compactly', (tester) async {
      await tester.pumpWidget(createWidget(isLoading: true));

      expect(find.text('Converting...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error state compactly', (tester) async {
      await tester.pumpWidget(createWidget(error: 'Failed'));

      expect(find.text('Conversion failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays successful conversion compactly', (tester) async {
      await tester.pumpWidget(createWidget(
        convertedAmount: 83.05,
        exchangeRate: 1.1,
      ));

      expect(find.text('83.05 USD'), findsOneWidget);
      expect(find.text('Rate: 1.1000'), findsOneWidget);
      expect(find.byIcon(Icons.currency_exchange), findsOneWidget);
    });

    testWidgets('does not display when no conversion data', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(CompactConversionDetailCard), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget); // SizedBox.shrink()
    });

    testWidgets('uses proper container styling', (tester) async {
      await tester.pumpWidget(createWidget(
        convertedAmount: 83.05,
        exchangeRate: 1.1,
      ));

      final container = find.byType(Container);
      expect(container, findsOneWidget);

      final containerWidget = tester.widget<Container>(container);
      expect(containerWidget.decoration, isA<BoxDecoration>());
      expect(containerWidget.padding, isNotNull);
    });
  });
}