import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/widgets/currency_selection_hints.dart';

void main() {
  group('CurrencySelectionHints Tests', () {
    
    Widget createTestWidget({
      String? selectedCountry,
      String? selectedCurrency,
      bool showDetailed = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CurrencySelectionHints(
            selectedCountry: selectedCountry,
            selectedCurrency: selectedCurrency,
            showDetailed: showDetailed,
          ),
        ),
      );
    }

    group('Widget Visibility', () {
      testWidgets('should not display when country is null', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: null,
          selectedCurrency: 'USD',
        ));

        expect(find.byType(Container), findsNothing);
      });

      testWidgets('should not display when currency is null', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Germany',
          selectedCurrency: null,
        ));

        expect(find.byType(Container), findsNothing);
      });

      testWidgets('should display when both country and currency are provided', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Germany',
          selectedCurrency: 'EUR',
        ));

        expect(find.byType(Container), findsOneWidget);
      });
    });

    group('Primary Currency Hints', () {
      testWidgets('should show perfect choice hint for primary currency', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Germany',
          selectedCurrency: 'EUR',
        ));

        expect(find.text('Perfect choice!'), findsOneWidget);
        expect(find.text('EUR is the primary currency in Germany.'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });

      testWidgets('should show perfect choice hint for other primary currencies', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'United States',
          selectedCurrency: 'USD',
        ));

        expect(find.text('Perfect choice!'), findsOneWidget);
        expect(find.text('USD is the primary currency in United States.'), findsOneWidget);
      });

      testWidgets('should show perfect choice hint for Japan with JPY', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Japan',
          selectedCurrency: 'JPY',
        ));

        expect(find.text('Perfect choice!'), findsOneWidget);
        expect(find.text('JPY is the primary currency in Japan.'), findsOneWidget);
      });
    });

    group('Multi-Currency Country Hints', () {
      testWidgets('should show good choice hint for commonly accepted currency', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Switzerland',
          selectedCurrency: 'EUR',
        ));

        expect(find.text('Good choice!'), findsOneWidget);
        expect(find.textContaining('EUR is commonly accepted in Switzerland'), findsOneWidget);
        expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      });

      testWidgets('should show good choice hint for Canada with USD', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Canada',
          selectedCurrency: 'USD',
        ));

        expect(find.text('Good choice!'), findsOneWidget);
        expect(find.textContaining('USD is commonly accepted in Canada'), findsOneWidget);
      });

      testWidgets('should show good choice hint for Mexico with USD', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Mexico',
          selectedCurrency: 'USD',
        ));

        expect(find.text('Good choice!'), findsOneWidget);
        expect(find.textContaining('USD is commonly accepted in Mexico'), findsOneWidget);
      });
    });

    group('Currency Conversion Hints', () {
      testWidgets('should show conversion hint for different currency', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Germany',
          selectedCurrency: 'USD',
        ));

        expect(find.text('Currency conversion'), findsOneWidget);
        expect(find.textContaining('Using USD in Germany. Primary currency is EUR.'), findsOneWidget);
        expect(find.byIcon(Icons.info), findsOneWidget);
      });

      testWidgets('should show conversion hint for Japan with USD', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Japan',
          selectedCurrency: 'USD',
        ));

        expect(find.text('Currency conversion'), findsOneWidget);
        expect(find.textContaining('Using USD in Japan. Primary currency is JPY.'), findsOneWidget);
      });
    });

    group('Unknown/International Currency Hints', () {
      testWidgets('should show international currency hint for unknown country', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Unknown Country',
          selectedCurrency: 'USD',
        ));

        expect(find.text('International currency'), findsOneWidget);
        expect(find.text('Using USD for this entry.'), findsOneWidget);
        expect(find.byIcon(Icons.help_outline), findsOneWidget);
      });
    });

    group('Detailed Information', () {
      testWidgets('should show detailed info when showDetailed is true', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Germany',
          selectedCurrency: 'EUR',
          showDetailed: true,
        ));

        // Should show currency symbol and decimal places info
        expect(find.textContaining('Symbol:'), findsOneWidget);
        expect(find.textContaining('Decimal places:'), findsOneWidget);
      });

      testWidgets('should not show detailed info when showDetailed is false', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Germany',
          selectedCurrency: 'EUR',
          showDetailed: false,
        ));

        // Should not show detailed currency info
        expect(find.textContaining('Symbol:'), findsNothing);
        expect(find.textContaining('Decimal places:'), findsNothing);
      });

      testWidgets('should show detailed info for multi-currency hint', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Switzerland',
          selectedCurrency: 'EUR',
          showDetailed: true,
        ));

        expect(find.textContaining('This currency is widely used'), findsOneWidget);
      });

      testWidgets('should show detailed info for conversion hint', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Germany',
          selectedCurrency: 'USD',
          showDetailed: true,
        ));

        expect(find.textContaining('Your amount will be displayed'), findsOneWidget);
      });
    });

    group('Visual Styling', () {
      testWidgets('should have proper color coding for different hint types', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Germany',
          selectedCurrency: 'EUR',
        ));

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        
        // Should have green background for perfect choice
        expect(decoration.color, Colors.green.withOpacity(0.1));
      });

      testWidgets('should have blue styling for good choice hint', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Switzerland',
          selectedCurrency: 'EUR',
        ));

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        
        // Should have blue background for good choice
        expect(decoration.color, Colors.blue.withOpacity(0.1));
      });

      testWidgets('should have orange styling for conversion hint', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Germany',
          selectedCurrency: 'USD',
        ));

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        
        // Should have orange background for conversion
        expect(decoration.color, Colors.orange.withOpacity(0.1));
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle countries without currency mapping', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Antarctica',
          selectedCurrency: 'USD',
        ));

        // Should show international currency hint
        expect(find.text('International currency'), findsOneWidget);
      });

      testWidgets('should handle empty strings gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: '',
          selectedCurrency: '',
        ));

        // Should not crash - empty strings are treated as null
        expect(find.byType(CurrencySelectionHints), findsOneWidget);
      });

      testWidgets('should handle special characters in country names', (WidgetTester tester) async {
        await tester.pumpWidget(createTestWidget(
          selectedCountry: 'Côte d\'Ivoire',
          selectedCurrency: 'USD',
        ));

        // Should handle special characters without crashing
        expect(find.byType(Container), findsOneWidget);
      });
    });
  });

  group('AdvancedCurrencyHints Tests', () {
    Widget createAdvancedTestWidget({
      String? selectedCountry,
      String? selectedCurrency,
      String? userPrimaryCurrency,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: AdvancedCurrencyHints(
            selectedCountry: selectedCountry,
            selectedCurrency: selectedCurrency,
            userPrimaryCurrency: userPrimaryCurrency,
          ),
        ),
      );
    }

    group('Regional Information', () {
      testWidgets('should show regional info for multi-currency countries', (WidgetTester tester) async {
        await tester.pumpWidget(createAdvancedTestWidget(
          selectedCountry: 'Switzerland',
          selectedCurrency: 'CHF',
          userPrimaryCurrency: 'USD',
        ));

        expect(find.text('Other currencies in Switzerland'), findsOneWidget);
        expect(find.byIcon(Icons.language), findsOneWidget);
      });

      testWidgets('should display currency chips for other accepted currencies', (WidgetTester tester) async {
        await tester.pumpWidget(createAdvancedTestWidget(
          selectedCountry: 'Switzerland',
          selectedCurrency: 'CHF',
          userPrimaryCurrency: 'USD',
        ));

        // Should show EUR as chip since Switzerland accepts both CHF and EUR
        expect(find.byType(Chip), findsWidgets);
        expect(find.text('EUR'), findsOneWidget);
      });

      testWidgets('should not show regional info for single-currency countries', (WidgetTester tester) async {
        await tester.pumpWidget(createAdvancedTestWidget(
          selectedCountry: 'Germany',
          selectedCurrency: 'EUR',
          userPrimaryCurrency: 'USD',
        ));

        // Germany only uses EUR, so no regional info should be shown
        expect(find.text('Other currencies in Germany'), findsNothing);
      });
    });

    group('Integration with Basic Hints', () {
      testWidgets('should include basic hints along with advanced features', (WidgetTester tester) async {
        await tester.pumpWidget(createAdvancedTestWidget(
          selectedCountry: 'Switzerland',
          selectedCurrency: 'CHF',
          userPrimaryCurrency: 'USD',
        ));

        // Should show both basic and advanced hints
        expect(find.text('Perfect choice!'), findsOneWidget);
        expect(find.text('Other currencies in Switzerland'), findsOneWidget);
      });
    });
  });
}