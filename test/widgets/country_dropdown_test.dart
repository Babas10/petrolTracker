import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/widgets/country_dropdown.dart';

void main() {
  group('CountryDropdown', () {
    testWidgets('should build without errors', (tester) async {
      String? selectedCountry;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryDropdown(
              selectedCountry: selectedCountry,
              onChanged: (value) {
                selectedCountry = value;
              },
            ),
          ),
        ),
      );

      expect(find.byType(CountryDropdown), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });

    testWidgets('should display hint text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryDropdown(
              selectedCountry: null,
              onChanged: (value) {},
              hintText: 'Choose a country',
            ),
          ),
        ),
      );

      expect(find.text('Choose a country'), findsOneWidget);
    });

    testWidgets('should display selected country', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryDropdown(
              selectedCountry: 'Canada',
              onChanged: (value) {},
            ),
          ),
        ),
      );

      expect(find.text('Canada'), findsOneWidget);
    });

    testWidgets('should show country options when tapped', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryDropdown(
              selectedCountry: null,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Tap the dropdown to open it
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Should show search field
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search countries...'), findsOneWidget);

      // Should show some common countries
      expect(find.text('Canada'), findsOneWidget);
      expect(find.text('United States'), findsOneWidget);
      expect(find.text('Germany'), findsOneWidget);
      expect(find.text('France'), findsOneWidget);
    });

    testWidgets('should filter countries when searching', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryDropdown(
              selectedCountry: null,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Search for 'can'
      await tester.enterText(find.byType(TextField), 'can');
      await tester.pumpAndSettle();

      // Should show Canada but not United States
      expect(find.text('Canada'), findsOneWidget);
      expect(find.text('United States'), findsNothing);
    });

    testWidgets('should call onChanged when country is selected', (tester) async {
      String? selectedCountry;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryDropdown(
              selectedCountry: selectedCountry,
              onChanged: (value) {
                selectedCountry = value;
              },
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Select Canada
      await tester.tap(find.text('Canada').last);
      await tester.pumpAndSettle();

      expect(selectedCountry, equals('Canada'));
    });

    testWidgets('should validate empty selection', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CountryDropdown(
                selectedCountry: null,
                onChanged: (value) {},
              ),
            ),
          ),
        ),
      );

      // Validate form without selecting a country
      final isValid = formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(isValid, isFalse);
      expect(find.text('Please select a country'), findsOneWidget);
    });

    testWidgets('should display error text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryDropdown(
              selectedCountry: null,
              onChanged: (value) {},
              errorText: 'Country is required',
            ),
          ),
        ),
      );

      expect(find.text('Country is required'), findsOneWidget);
    });

    testWidgets('should handle case-insensitive search', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryDropdown(
              selectedCountry: null,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Search with different cases
      await tester.enterText(find.byType(TextField), 'CANADA');
      await tester.pumpAndSettle();

      expect(find.text('Canada'), findsOneWidget);

      // Clear and try lowercase
      await tester.enterText(find.byType(TextField), 'canada');
      await tester.pumpAndSettle();

      expect(find.text('Canada'), findsOneWidget);
    });

    testWidgets('should show no results when search does not match', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryDropdown(
              selectedCountry: null,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Search for non-existent country
      await tester.enterText(find.byType(TextField), 'Atlantis');
      await tester.pumpAndSettle();

      // Should not show any countries except the search field
      expect(find.text('Canada'), findsNothing);
      expect(find.text('United States'), findsNothing);
      expect(find.byType(TextField), findsOneWidget); // Search field should still be there
    });

    testWidgets('should clear search and show all countries when search is cleared', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryDropdown(
              selectedCountry: null,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Search for something specific
      await tester.enterText(find.byType(TextField), 'can');
      await tester.pumpAndSettle();

      expect(find.text('Canada'), findsOneWidget);
      expect(find.text('United States'), findsNothing);

      // Clear the search
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      // Should show all countries again
      expect(find.text('Canada'), findsOneWidget);
      expect(find.text('United States'), findsOneWidget);
      expect(find.text('Germany'), findsOneWidget);
    });

    testWidgets('should include common countries in the list', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryDropdown(
              selectedCountry: null,
              onChanged: (value) {},
            ),
          ),
        ),
      );

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Check for some common countries
      expect(find.text('Canada'), findsOneWidget);
      expect(find.text('United States'), findsOneWidget);
      expect(find.text('Germany'), findsOneWidget);
      expect(find.text('France'), findsOneWidget);
      expect(find.text('United Kingdom'), findsOneWidget);
      expect(find.text('Australia'), findsOneWidget);
      expect(find.text('Japan'), findsOneWidget);
      expect(find.text('Brazil'), findsOneWidget);
    });
  });
}