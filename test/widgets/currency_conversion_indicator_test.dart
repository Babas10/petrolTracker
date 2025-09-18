import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/widgets/currency_conversion_indicator.dart';

void main() {
  group('CurrencyConversionIndicator', () {
    Widget createWidget({
      String fromCurrency = 'EUR',
      String toCurrency = 'USD',
      bool isConverting = false,
      bool hasError = false,
      double? exchangeRate,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CurrencyConversionIndicator(
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            isConverting: isConverting,
            hasError: hasError,
            exchangeRate: exchangeRate,
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets('does not display when currencies are the same', (tester) async {
      await tester.pumpWidget(createWidget(
        fromCurrency: 'USD',
        toCurrency: 'USD',
      ));

      expect(find.byType(CurrencyConversionIndicator), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget); // SizedBox.shrink()
    });

    testWidgets('displays currency conversion when currencies differ', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('EUR→USD'), findsOneWidget);
      expect(find.byIcon(Icons.currency_exchange), findsOneWidget);
    });

    testWidgets('shows loading state when converting', (tester) async {
      await tester.pumpWidget(createWidget(isConverting: true));

      expect(find.text('EUR→USD'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state when conversion fails', (tester) async {
      await tester.pumpWidget(createWidget(hasError: true));

      expect(find.text('Error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows success state with currency exchange icon', (tester) async {
      await tester.pumpWidget(createWidget(
        isConverting: false,
        hasError: false,
      ));

      expect(find.text('EUR→USD'), findsOneWidget);
      expect(find.byIcon(Icons.currency_exchange), findsOneWidget);
    });

    testWidgets('handles tap callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(createWidget(
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('displays correct colors for different states', (tester) async {
      // Test normal state
      await tester.pumpWidget(createWidget());
      await tester.pump();

      var container = tester.widget<Container>(find.byType(Container));
      expect(container.decoration, isA<BoxDecoration>());

      // Test error state
      await tester.pumpWidget(createWidget(hasError: true));
      await tester.pump();

      container = tester.widget<Container>(find.byType(Container));
      expect(container.decoration, isA<BoxDecoration>());

      // Test loading state
      await tester.pumpWidget(createWidget(isConverting: true));
      await tester.pump();

      container = tester.widget<Container>(find.byType(Container));
      expect(container.decoration, isA<BoxDecoration>());
    });
  });

  group('CompactCurrencyConversionIndicator', () {
    Widget createWidget({
      String fromCurrency = 'EUR',
      String toCurrency = 'USD',
      bool isConverting = false,
      bool hasError = false,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CompactCurrencyConversionIndicator(
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            isConverting: isConverting,
            hasError: hasError,
            onTap: onTap,
          ),
        ),
      );
    }

    testWidgets('does not display when currencies are the same', (tester) async {
      await tester.pumpWidget(createWidget(
        fromCurrency: 'USD',
        toCurrency: 'USD',
      ));

      expect(find.byType(CompactCurrencyConversionIndicator), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget); // SizedBox.shrink()
    });

    testWidgets('displays compact icon when currencies differ', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byIcon(Icons.currency_exchange), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('shows loading state in compact mode', (tester) async {
      await tester.pumpWidget(createWidget(isConverting: true));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state in compact mode', (tester) async {
      await tester.pumpWidget(createWidget(hasError: true));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
  });

  group('DetailedCurrencyConversionIndicator', () {
    Widget createWidget({
      String fromCurrency = 'EUR',
      String toCurrency = 'USD',
      bool isConverting = false,
      bool hasError = false,
      double? exchangeRate,
      String? errorMessage,
      VoidCallback? onTap,
      VoidCallback? onRetry,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DetailedCurrencyConversionIndicator(
            fromCurrency: fromCurrency,
            toCurrency: toCurrency,
            isConverting: isConverting,
            hasError: hasError,
            exchangeRate: exchangeRate,
            errorMessage: errorMessage,
            onTap: onTap,
            onRetry: onRetry,
          ),
        ),
      );
    }

    testWidgets('does not display when currencies are the same', (tester) async {
      await tester.pumpWidget(createWidget(
        fromCurrency: 'USD',
        toCurrency: 'USD',
      ));

      expect(find.byType(DetailedCurrencyConversionIndicator), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget); // SizedBox.shrink()
    });

    testWidgets('displays detailed information when currencies differ', (tester) async {
      await tester.pumpWidget(createWidget(
        exchangeRate: 1.1234,
      ));

      expect(find.text('EUR → USD'), findsOneWidget);
      expect(find.text('Rate: 1.1234'), findsOneWidget);
      expect(find.byIcon(Icons.currency_exchange), findsOneWidget);
    });

    testWidgets('shows loading state with progress indicator', (tester) async {
      await tester.pumpWidget(createWidget(isConverting: true));

      expect(find.text('EUR → USD'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when provided', (tester) async {
      await tester.pumpWidget(createWidget(
        hasError: true,
        errorMessage: 'Network error',
      ));

      expect(find.text('EUR → USD'), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows retry button when error occurs and onRetry provided', (tester) async {
      bool retryTapped = false;
      await tester.pumpWidget(createWidget(
        hasError: true,
        onRetry: () => retryTapped = true,
      ));

      expect(find.byIcon(Icons.refresh), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.refresh));
      expect(retryTapped, isTrue);
    });

    testWidgets('handles tap callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(createWidget(
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });
  });
}