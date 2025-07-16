import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';

/// Widget tests for ephemeral storage functionality
void main() {
  group('Ephemeral Storage Widget Tests', () {
    
    testWidgets('should display vehicles from ephemeral storage', (WidgetTester tester) async {
      // Create a test widget that consumes the vehicle provider
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final vehicleAsyncValue = ref.watch(vehiclesNotifierProvider);
                
                return vehicleAsyncValue.when(
                  data: (state) => Scaffold(
                    body: ListView.builder(
                      itemCount: state.vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = state.vehicles[index];
                        return ListTile(
                          key: Key('vehicle-${vehicle.id}'),
                          title: Text(vehicle.name),
                          subtitle: Text('${vehicle.initialKm} km'),
                        );
                      },
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),
          ),
        ),
      );
      
      // Initially should show empty list
      await tester.pump();
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
      
      // Add a vehicle through the provider
      final container = ProviderScope.containerOf(tester.element(find.byType(Consumer)));
      final vehicleNotifier = container.read(vehiclesNotifierProvider.notifier);
      
      await vehicleNotifier.addVehicle(VehicleModel.create(
        name: 'Test Vehicle',
        initialKm: 10000.0,
      ));
      
      // Rebuild widget and verify vehicle appears
      await tester.pump();
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Test Vehicle'), findsOneWidget);
      expect(find.text('10000.0 km'), findsOneWidget);
    });
    
    testWidgets('should display fuel entries from ephemeral storage', (WidgetTester tester) async {
      // Create a test widget that consumes the fuel entry provider
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final fuelAsyncValue = ref.watch(fuelEntriesNotifierProvider);
                
                return fuelAsyncValue.when(
                  data: (state) => Scaffold(
                    body: ListView.builder(
                      itemCount: state.entries.length,
                      itemBuilder: (context, index) {
                        final entry = state.entries[index];
                        return ListTile(
                          key: Key('fuel-entry-${entry.id}'),
                          title: Text('${entry.fuelAmount}L'),
                          subtitle: Text('${entry.currentKm} km - ${entry.country}'),
                        );
                      },
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),
          ),
        ),
      );
      
      // Initially should show empty list
      await tester.pump();
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
      
      // Add a fuel entry through the provider
      final container = ProviderScope.containerOf(tester.element(find.byType(Consumer)));
      final fuelNotifier = container.read(fuelEntriesNotifierProvider.notifier);
      
      await fuelNotifier.addFuelEntry(FuelEntryModel.create(
        vehicleId: 1,
        date: DateTime.now(),
        currentKm: 10300.0,
        fuelAmount: 50.0,
        price: 75.0,
        pricePerLiter: 1.50,
        country: 'Canada',
      ));
      
      // Rebuild widget and verify fuel entry appears
      await tester.pump();
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('50.0L'), findsOneWidget);
      expect(find.text('10300.0 km - Canada'), findsOneWidget);
    });
    
    testWidgets('should handle real-time updates to ephemeral storage', (WidgetTester tester) async {
      // Create a test widget that shows a counter of vehicles
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final vehicleCount = ref.watch(vehicleCountProvider);
                
                return vehicleCount.when(
                  data: (count) => Scaffold(
                    body: Column(
                      children: [
                        Text('Vehicle Count: $count', key: const Key('vehicle-count')),
                        ElevatedButton(
                          key: const Key('add-vehicle-btn'),
                          onPressed: () {
                            ref.read(vehiclesNotifierProvider.notifier).addVehicle(
                              VehicleModel.create(
                                name: 'Dynamic Vehicle ${DateTime.now().millisecondsSinceEpoch}',
                                initialKm: 10000.0,
                              ),
                            );
                          },
                          child: const Text('Add Vehicle'),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),
          ),
        ),
      );
      
      // Initially should show count of 0
      await tester.pump();
      expect(find.text('Vehicle Count: 0'), findsOneWidget);
      
      // Tap the add button
      await tester.tap(find.byKey(const Key('add-vehicle-btn')));
      await tester.pump();
      
      // Count should update to 1
      expect(find.text('Vehicle Count: 1'), findsOneWidget);
      
      // Tap the add button again
      await tester.tap(find.byKey(const Key('add-vehicle-btn')));
      await tester.pump();
      
      // Count should update to 2
      expect(find.text('Vehicle Count: 2'), findsOneWidget);
    });
    
    testWidgets('should handle vehicle deletion in real-time', (WidgetTester tester) async {
      // Create a test widget that shows vehicles with delete buttons
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final vehicleAsyncValue = ref.watch(vehiclesNotifierProvider);
                
                return vehicleAsyncValue.when(
                  data: (state) => Scaffold(
                    body: Column(
                      children: [
                        ElevatedButton(
                          key: const Key('add-vehicle-btn'),
                          onPressed: () {
                            ref.read(vehiclesNotifierProvider.notifier).addVehicle(
                              VehicleModel.create(
                                name: 'Deletable Vehicle',
                                initialKm: 10000.0,
                              ),
                            );
                          },
                          child: const Text('Add Vehicle'),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.vehicles.length,
                            itemBuilder: (context, index) {
                              final vehicle = state.vehicles[index];
                              return ListTile(
                                key: Key('vehicle-${vehicle.id}'),
                                title: Text(vehicle.name),
                                trailing: ElevatedButton(
                                  key: Key('delete-vehicle-${vehicle.id}'),
                                  onPressed: () {
                                    ref.read(vehiclesNotifierProvider.notifier).deleteVehicle(vehicle.id!);
                                  },
                                  child: const Text('Delete'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),
          ),
        ),
      );
      
      // Initially should show empty list
      await tester.pump();
      expect(find.byType(ListTile), findsNothing);
      
      // Add a vehicle
      await tester.tap(find.byKey(const Key('add-vehicle-btn')));
      await tester.pump();
      
      // Should show the vehicle
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Deletable Vehicle'), findsOneWidget);
      
      // Delete the vehicle
      await tester.tap(find.byKey(const Key('delete-vehicle-1')));
      await tester.pump();
      
      // Should show empty list again
      expect(find.byType(ListTile), findsNothing);
    });
    
    testWidgets('should handle fuel entry filtering by vehicle', (WidgetTester tester) async {
      // Create a test widget that filters fuel entries by vehicle
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final fuelEntries = ref.watch(fuelEntriesByVehicleProvider(1));
                
                return fuelEntries.when(
                  data: (entries) => Scaffold(
                    body: Column(
                      children: [
                        Text('Entries for Vehicle 1: ${entries.length}', key: const Key('entry-count')),
                        ElevatedButton(
                          key: const Key('add-entry-btn'),
                          onPressed: () {
                            ref.read(fuelEntriesNotifierProvider.notifier).addFuelEntry(
                              FuelEntryModel.create(
                                vehicleId: 1,
                                date: DateTime.now(),
                                currentKm: 10000.0 + (entries.length * 300),
                                fuelAmount: 50.0,
                                price: 75.0,
                                pricePerLiter: 1.50,
                                country: 'Canada',
                              ),
                            );
                          },
                          child: const Text('Add Entry'),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              return ListTile(
                                key: Key('entry-${entry.id}'),
                                title: Text('${entry.fuelAmount}L'),
                                subtitle: Text('${entry.currentKm} km'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),
          ),
        ),
      );
      
      // Initially should show 0 entries
      await tester.pump();
      expect(find.text('Entries for Vehicle 1: 0'), findsOneWidget);
      
      // Add an entry
      await tester.tap(find.byKey(const Key('add-entry-btn')));
      await tester.pump();
      
      // Should show 1 entry
      expect(find.text('Entries for Vehicle 1: 1'), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
      
      // Add another entry
      await tester.tap(find.byKey(const Key('add-entry-btn')));
      await tester.pump();
      
      // Should show 2 entries
      expect(find.text('Entries for Vehicle 1: 2'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
    });
    
    testWidgets('should handle errors gracefully in ephemeral storage', (WidgetTester tester) async {
      // Create a test widget that handles errors
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final vehicleAsyncValue = ref.watch(vehiclesNotifierProvider);
                
                return vehicleAsyncValue.when(
                  data: (state) => Scaffold(
                    body: Column(
                      children: [
                        Text('Database Ready: ${state.isDatabaseReady}', key: const Key('db-ready')),
                        if (state.error != null)
                          Text('Error: ${state.error}', key: const Key('error-text')),
                        Text('Vehicles: ${state.vehicles.length}', key: const Key('vehicle-count')),
                      ],
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),
          ),
        ),
      );
      
      // Should show database ready (ephemeral storage is always ready)
      await tester.pump();
      expect(find.text('Database Ready: true'), findsOneWidget);
      expect(find.text('Vehicles: 0'), findsOneWidget);
      expect(find.byKey(const Key('error-text')), findsNothing);
    });
    
    testWidgets('should handle provider refresh correctly', (WidgetTester tester) async {
      // Create a test widget with refresh capability
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final vehicleAsyncValue = ref.watch(vehiclesNotifierProvider);
                
                return vehicleAsyncValue.when(
                  data: (state) => Scaffold(
                    body: Column(
                      children: [
                        Text('Vehicles: ${state.vehicles.length}', key: const Key('vehicle-count')),
                        ElevatedButton(
                          key: const Key('refresh-btn'),
                          onPressed: () {
                            ref.read(vehiclesNotifierProvider.notifier).refresh();
                          },
                          child: const Text('Refresh'),
                        ),
                        ElevatedButton(
                          key: const Key('add-vehicle-btn'),
                          onPressed: () {
                            ref.read(vehiclesNotifierProvider.notifier).addVehicle(
                              VehicleModel.create(
                                name: 'Refresh Test Vehicle',
                                initialKm: 10000.0,
                              ),
                            );
                          },
                          child: const Text('Add Vehicle'),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                );
              },
            ),
          ),
        ),
      );
      
      // Initially should show 0 vehicles
      await tester.pump();
      expect(find.text('Vehicles: 0'), findsOneWidget);
      
      // Add a vehicle
      await tester.tap(find.byKey(const Key('add-vehicle-btn')));
      await tester.pump();
      
      // Should show 1 vehicle
      expect(find.text('Vehicles: 1'), findsOneWidget);
      
      // Refresh the provider
      await tester.tap(find.byKey(const Key('refresh-btn')));
      await tester.pump();
      
      // Should still show 1 vehicle (ephemeral storage persists during session)
      expect(find.text('Vehicles: 1'), findsOneWidget);
    });
  });
}