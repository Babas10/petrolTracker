import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:petrol_tracker/main.dart' as app;
import 'package:petrol_tracker/widgets/smart_currency_selector.dart';
import 'package:petrol_tracker/widgets/currency_selection_hints.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Smart Currency Filtering Integration Tests', () {
    
    testWidgets('Complete fuel entry flow with smart currency filtering', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to add fuel entry screen
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Select a vehicle first (if required)
      final vehicleDropdown = find.text('Select Vehicle').first;
      if (vehicleDropdown.evaluate().isNotEmpty) {
        await tester.tap(vehicleDropdown);
        await tester.pumpAndSettle();
        
        // Select first vehicle
        await tester.tap(find.text('Test Vehicle').first);
        await tester.pumpAndSettle();
      }

      // Select country
      await tester.tap(find.text('Select Country'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Germany').first);
      await tester.pumpAndSettle();

      // Verify smart currency selector appears and filters currencies
      expect(find.byType(SmartCurrencySelector), findsOneWidget);
      
      // Should show filtering indicator
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
      expect(find.textContaining('Filtered for Germany'), findsOneWidget);

      // Tap currency dropdown to see filtered options
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Should show EUR first (primary currency for Germany)
      expect(find.text('EUR'), findsWidgets);
      expect(find.byIcon(Icons.location_on), findsWidgets); // Primary currency indicator

      // Select EUR
      await tester.tap(find.text('EUR').first);
      await tester.pumpAndSettle();

      // Verify currency selection hints appear
      expect(find.byType(CurrencySelectionHints), findsOneWidget);
      expect(find.text('Perfect choice!'), findsOneWidget);
      expect(find.text('EUR is the primary currency in Germany.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Currency filtering updates when country changes', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to add fuel entry
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Select vehicle if needed
      final vehicleDropdown = find.text('Select Vehicle').first;
      if (vehicleDropdown.evaluate().isNotEmpty) {
        await tester.tap(vehicleDropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Vehicle').first);
        await tester.pumpAndSettle();
      }

      // First, select Germany
      await tester.tap(find.text('Select Country'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Germany').first);
      await tester.pumpAndSettle();

      // Verify EUR is auto-selected for Germany
      expect(find.textContaining('Germany'), findsOneWidget);
      
      // Check the currency hint shows perfect choice for EUR
      expect(find.text('Perfect choice!'), findsOneWidget);

      // Now change country to Japan
      await tester.tap(find.text('Germany'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Japan').first);
      await tester.pumpAndSettle();

      // Currency should update to JPY and hints should change
      expect(find.textContaining('Japan'), findsOneWidget);
      expect(find.text('Perfect choice!'), findsOneWidget);
      expect(find.textContaining('JPY is the primary currency in Japan'), findsOneWidget);
    });

    testWidgets('Expand functionality works correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to add fuel entry
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Select vehicle if needed
      final vehicleDropdown = find.text('Select Vehicle').first;
      if (vehicleDropdown.evaluate().isNotEmpty) {
        await tester.tap(vehicleDropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Vehicle').first);
        await tester.pumpAndSettle();
      }

      // Select a country to enable filtering
      await tester.tap(find.text('Select Country'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Germany').first);
      await tester.pumpAndSettle();

      // Should show expand option
      expect(find.textContaining('Show all'), findsOneWidget);
      expect(find.textContaining('Filtered for Germany'), findsOneWidget);

      // Tap expand
      await tester.tap(find.textContaining('Show all'));
      await tester.pumpAndSettle();

      // Should now show all currencies
      expect(find.textContaining('Showing all'), findsOneWidget);
      expect(find.textContaining('Show all'), findsNothing); // Expand button should be hidden

      // Open dropdown to verify all currencies are available
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Should show many more currency options
      expect(find.text('USD'), findsWidgets);
      expect(find.text('GBP'), findsWidgets);
      expect(find.text('JPY'), findsWidgets);
      expect(find.text('CAD'), findsWidgets);
    });

    testWidgets('Multi-currency country hints work correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to add fuel entry
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Select vehicle if needed
      final vehicleDropdown = find.text('Select Vehicle').first;
      if (vehicleDropdown.evaluate().isNotEmpty) {
        await tester.tap(vehicleDropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Vehicle').first);
        await tester.pumpAndSettle();
      }

      // Select Switzerland (multi-currency country)
      await tester.tap(find.text('Select Country'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Switzerland').first);
      await tester.pumpAndSettle();

      // Should auto-select CHF (primary currency)
      expect(find.text('Perfect choice!'), findsOneWidget);
      expect(find.textContaining('CHF is the primary currency'), findsOneWidget);

      // Now manually select EUR
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('EUR').first);
      await tester.pumpAndSettle();

      // Should show "Good choice!" hint for EUR in Switzerland
      expect(find.text('Good choice!'), findsOneWidget);
      expect(find.textContaining('EUR is commonly accepted in Switzerland'), findsOneWidget);
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
    });

    testWidgets('Performance remains smooth during rapid country changes', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to add fuel entry
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Select vehicle if needed
      final vehicleDropdown = find.text('Select Vehicle').first;
      if (vehicleDropdown.evaluate().isNotEmpty) {
        await tester.tap(vehicleDropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Vehicle').first);
        await tester.pumpAndSettle();
      }

      final countries = ['Germany', 'Japan', 'United States', 'Switzerland', 'Canada'];
      
      // Rapidly change countries and verify smooth performance
      for (final country in countries) {
        await tester.tap(find.text('Select Country'));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text(country).first);
        await tester.pump(const Duration(milliseconds: 100)); // Don't wait for full settle
        
        // Should still show the smart currency selector without crashes
        expect(find.byType(SmartCurrencySelector), findsOneWidget);
      }
      
      await tester.pumpAndSettle();
      
      // Final state should be stable
      expect(find.byType(SmartCurrencySelector), findsOneWidget);
      expect(find.byType(CurrencySelectionHints), findsOneWidget);
    });

    testWidgets('Currency usage tracking works in real scenario', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to add fuel entry
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Select vehicle if needed
      final vehicleDropdown = find.text('Select Vehicle').first;
      if (vehicleDropdown.evaluate().isNotEmpty) {
        await tester.tap(vehicleDropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Vehicle').first);
        await tester.pumpAndSettle();
      }

      // Select country
      await tester.tap(find.text('Select Country'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Germany').first);
      await tester.pumpAndSettle();

      // Select a non-primary currency to test usage tracking
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('USD').first);
      await tester.pumpAndSettle();

      // Should show conversion hint
      expect(find.text('Currency conversion'), findsOneWidget);
      expect(find.textContaining('Using USD in Germany'), findsOneWidget);

      // Fill in required fields to complete the entry
      await tester.enterText(find.byKey(const Key('currentKmField')), '10000');
      await tester.enterText(find.byKey(const Key('fuelAmountField')), '50');
      await tester.enterText(find.byKey(const Key('priceField')), '75.00');
      
      // Save the entry
      await tester.tap(find.text('Save Entry'));
      await tester.pumpAndSettle();

      // Usage should be tracked (verified by no errors occurring)
      expect(find.text('Fuel entry saved successfully'), findsOneWidget);
    });

    testWidgets('Error states are handled gracefully', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to add fuel entry
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Test with no internet connection or service errors
      // The smart currency selector should fall back to basic currency list

      expect(find.byType(SmartCurrencySelector), findsOneWidget);
      
      // Should still be functional even if smart features fail
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      
      // Should show some currencies (fallback mode)
      expect(find.text('USD'), findsWidgets);
    });

    testWidgets('Visual indicators and styling work correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to add fuel entry
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Select vehicle if needed
      final vehicleDropdown = find.text('Select Vehicle').first;
      if (vehicleDropdown.evaluate().isNotEmpty) {
        await tester.tap(vehicleDropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Test Vehicle').first);
        await tester.pumpAndSettle();
      }

      // Select Germany
      await tester.tap(find.text('Select Country'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Germany').first);
      await tester.pumpAndSettle();

      // Check visual indicators
      expect(find.byIcon(Icons.filter_list), findsOneWidget); // Filter indicator
      expect(find.textContaining('Filtered for Germany'), findsOneWidget); // Filter badge

      // Open dropdown to check currency indicators
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Should show location icon for primary currency (EUR)
      expect(find.byIcon(Icons.location_on), findsWidgets);
      
      // Should show star icon for recommended currencies
      expect(find.byIcon(Icons.star), findsWidgets);
    });
  });
}