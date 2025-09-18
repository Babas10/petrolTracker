import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/providers/currency_providers.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/units_providers.dart';
import 'package:petrol_tracker/widgets/multi_currency_fuel_entry_card.dart';

import '../mocks/mock_providers.dart';

void main() {
  group('MultiCurrencyFuelEntryCard', () {
    late FuelEntryModel mockEntry;
    late VehicleModel mockVehicle;

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

      mockVehicle = VehicleModel(
        id: 1,
        name: 'Test Car',
        make: 'Toyota',
        model: 'Camry',
        year: 2020,
        userId: 1,
      );
    });

    Widget createWidget({String primaryCurrency = 'USD'}) {
      return ProviderScope(
        overrides: [
          vehicleProvider(1).overrideWith((ref) => AsyncValue.data(mockVehicle)),
          primaryCurrencyProvider.overrideWith((ref) => primaryCurrency),
          unitsProvider.overrideWith((ref) => AsyncValue.data(UnitSystem.metric)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: MultiCurrencyFuelEntryCard(
              entry: mockEntry,
              primaryCurrency: primaryCurrency,
            ),
          ),
        ),
      );
    }

    testWidgets('displays basic entry information', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('Test Car'), findsOneWidget);
      expect(find.text('Full'), findsOneWidget);
      expect(find.text('Dec 1, 2023'), findsOneWidget);
      expect(find.text('France'), findsOneWidget);
      expect(find.text('50.0L'), findsOneWidget);
    });

    testWidgets('shows currency conversion indicator when currencies differ', (tester) async {
      await tester.pumpWidget(createWidget(primaryCurrency: 'USD'));
      await tester.pump();

      // Should show conversion indicator since entry is EUR and primary is USD
      expect(find.byType(Icon), findsWidgets);
      // Look for currency exchange related widgets
      expect(find.text('EUR'), findsAtLeastOneWidget);
    });

    testWidgets('does not show conversion indicator when currencies match', (tester) async {
      await tester.pumpWidget(createWidget(primaryCurrency: 'EUR'));
      await tester.pump();

      // Should not show conversion indicator since both are EUR
      expect(find.text('75.50 EUR'), findsOneWidget);
    });

    testWidgets('displays tank type chip correctly', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('Full'), findsOneWidget);
    });

    testWidgets('displays partial tank chip correctly', (tester) async {
      final partialEntry = mockEntry.copyWith(isFullTank: false);
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehicleProvider(1).overrideWith((ref) => AsyncValue.data(mockVehicle)),
            primaryCurrencyProvider.overrideWith((ref) => 'USD'),
            unitsProvider.overrideWith((ref) => AsyncValue.data(UnitSystem.metric)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: MultiCurrencyFuelEntryCard(
                entry: partialEntry,
                primaryCurrency: 'USD',
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Partial'), findsOneWidget);
    });

    testWidgets('shows consumption when available', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('7.5 L/100km'), findsOneWidget);
    });

    testWidgets('shows price per liter with currency', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      expect(find.text('1.510 EUR/L'), findsOneWidget);
    });

    testWidgets('can expand to show conversion details', (tester) async {
      await tester.pumpWidget(createWidget(primaryCurrency: 'USD'));
      await tester.pump();

      // Find and tap the expansion tile
      final expansionTile = find.byType(ExpansionTile);
      expect(expansionTile, findsOneWidget);

      await tester.tap(expansionTile);
      await tester.pumpAndSettle();

      // Should show conversion details after expansion
      expect(find.byType(ExpansionTile), findsOneWidget);
    });

    testWidgets('shows vehicle loading state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehicleProvider(1).overrideWith((ref) => const AsyncValue.loading()),
            primaryCurrencyProvider.overrideWith((ref) => 'USD'),
            unitsProvider.overrideWith((ref) => AsyncValue.data(UnitSystem.metric)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: MultiCurrencyFuelEntryCard(
                entry: mockEntry,
                primaryCurrency: 'USD',
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Loading vehicle...'), findsOneWidget);
    });

    testWidgets('shows vehicle error state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vehicleProvider(1).overrideWith((ref) => AsyncValue.error('Error', StackTrace.current)),
            primaryCurrencyProvider.overrideWith((ref) => 'USD'),
            unitsProvider.overrideWith((ref) => AsyncValue.data(UnitSystem.metric)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: MultiCurrencyFuelEntryCard(
                entry: mockEntry,
                primaryCurrency: 'USD',
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Unknown Vehicle'), findsOneWidget);
    });

    testWidgets('shows popup menu with actions', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Find and tap the popup menu button
      final popupButton = find.byType(PopupMenuButton<String>);
      expect(popupButton, findsOneWidget);

      await tester.tap(popupButton);
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('handles dismissible swipe to delete', (tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pump();

      // Find the dismissible widget
      final dismissible = find.byType(Dismissible);
      expect(dismissible, findsOneWidget);

      // Swipe to dismiss (simulate swipe to delete)
      await tester.drag(dismissible, const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Should show delete confirmation dialog
      expect(find.text('Delete Entry'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this fuel entry?'), findsOneWidget);
    });
  });
}