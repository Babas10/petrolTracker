# Riverpod State Management Implementation

## Overview

This document describes the implementation of Issue #24: Riverpod state management for the Petrol Tracker Flutter application. The implementation provides a comprehensive state management solution using Riverpod with code generation.

## Implementation Details

### 1. Dependencies Added

Added the following Riverpod dependencies to `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.4

dev_dependencies:
  riverpod_generator: ^2.3.9
  riverpod_lint: ^2.3.7
```

### 2. Main Application Setup

Updated `lib/main.dart` to wrap the app with `ProviderScope`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: PetrolTrackerApp()));
}
```

### 3. Provider Structure

Created four main provider files in `lib/providers/`:

#### 3.1 Database Providers (`database_providers.dart`)

Core providers for database access:
- `databaseProvider` - Provides singleton AppDatabase instance
- `databaseServiceProvider` - Provides DatabaseService singleton
- `vehicleRepositoryProvider` - Provides VehicleRepository with dependency injection
- `fuelEntryRepositoryProvider` - Provides FuelEntryRepository with dependency injection

All database providers use `keepAlive: true` to maintain singleton behavior.

#### 3.2 Vehicle Providers (`vehicle_providers.dart`)

Vehicle state management with comprehensive CRUD operations:

**State Class:**
- `VehicleState` - Immutable state class containing:
  - `List<VehicleModel> vehicles`
  - `bool isLoading`
  - `String? error`

**Main Notifier:**
- `VehiclesNotifier` - AsyncNotifier for vehicle operations:
  - `addVehicle()` - Add new vehicle with validation
  - `updateVehicle()` - Update existing vehicle
  - `deleteVehicle()` - Delete vehicle with constraint checking
  - `refresh()` - Reload vehicles from repository
  - `clearError()` - Clear error state

**Individual Providers:**
- `vehicleProvider(int id)` - Get specific vehicle by ID
- `vehicleNameExistsProvider(String name, {int? excludeId})` - Check name uniqueness
- `vehicleCountProvider` - Get total vehicle count

#### 3.3 Fuel Entry Providers (`fuel_entry_providers.dart`)

Similar structure to vehicle providers but for fuel entries:

**State Class:**
- `FuelEntryState` - Contains entries list, loading state, and error

**Main Notifier:**
- `FuelEntriesNotifier` - AsyncNotifier with CRUD operations

**Query Providers:**
- `fuelEntriesByVehicleProvider(int vehicleId)`
- `fuelEntriesByDateRangeProvider(DateTime start, DateTime end)`
- `fuelEntriesByVehicleAndDateRangeProvider(int vehicleId, DateTime start, DateTime end)`
- `latestFuelEntryForVehicleProvider(int vehicleId)`
- `fuelEntryProvider(int entryId)`
- `fuelEntryCountProvider`
- `fuelEntryCountForVehicleProvider(int vehicleId)`
- `fuelEntriesGroupedByCountryProvider`
- `averageConsumptionForVehicleProvider(int vehicleId)`

#### 3.4 Chart Providers (`chart_providers.dart`)

Data transformation providers for analytics and visualization:

**Data Classes:**
- `ConsumptionDataPoint` - Date, consumption, kilometers
- `PriceTrendDataPoint` - Date, price per liter, country

**Chart Data Providers:**
- `consumptionChartDataProvider(int vehicleId, {DateTime? start, DateTime? end})`
- `priceTrendChartDataProvider({DateTime? start, DateTime? end})`
- `monthlyConsumptionAveragesProvider(int vehicleId, int year)`
- `costAnalysisDataProvider(int vehicleId, {DateTime? start, DateTime? end})`
- `countryPriceComparisonProvider({DateTime? start, DateTime? end})`

### 4. Key Design Patterns

#### 4.1 State Management Pattern

All notifiers follow a consistent pattern:
1. Use `AsyncNotifier<StateClass>` for state management
2. Implement loading states during operations
3. Handle errors gracefully with user-friendly messages
4. Update state optimistically where possible

#### 4.2 Error Handling

- Custom exception handling using `DatabaseExceptionHandler`
- User-friendly error messages through `getUserFriendlyMessage()`
- Error state management in notifier classes
- Graceful error recovery

#### 4.3 Code Generation

- Uses `@riverpod` annotations for automatic provider generation
- Generates type-safe provider references
- Automatic dependency injection
- Compile-time safety

### 5. Integration with Existing Architecture

The Riverpod implementation integrates seamlessly with the existing architecture:

- **Repository Pattern**: Providers inject and use existing repository classes
- **Model Classes**: Leverages existing VehicleModel and FuelEntryModel
- **Database Layer**: Works with existing Drift database setup
- **Error Handling**: Integrates with existing DatabaseException system

### 6. Testing

Comprehensive test suite covering:

#### 6.1 Unit Tests (`test/providers/providers_unit_test.dart`)
- State class behavior (equality, copyWith, etc.)
- Chart data class functionality
- Model validation and utilities
- Core functionality without database dependencies

#### 6.2 Provider Tests
- Database provider configuration
- State management operations
- Error handling scenarios
- Provider integration

### 7. Performance Considerations

- **Singleton Providers**: Database providers use `keepAlive: true`
- **Caching**: Automatic provider caching and invalidation
- **Optimistic Updates**: UI updates immediately, with rollback on error
- **Lazy Loading**: Providers only initialize when accessed

### 8. Usage Examples

#### 8.1 Reading Vehicle State

```dart
class VehicleListWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleState = ref.watch(vehiclesNotifierProvider);
    
    return vehicleState.when(
      data: (state) => ListView.builder(
        itemCount: state.vehicles.length,
        itemBuilder: (context, index) => VehicleTile(state.vehicles[index]),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

#### 8.2 Adding a Vehicle

```dart
class AddVehicleButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(vehiclesNotifierProvider.notifier);
    
    return ElevatedButton(
      onPressed: () async {
        final vehicle = VehicleModel.create(
          name: 'New Car',
          initialKm: 0.0,
        );
        await notifier.addVehicle(vehicle);
      },
      child: Text('Add Vehicle'),
    );
  }
}
```

#### 8.3 Chart Data

```dart
class ConsumptionChart extends ConsumerWidget {
  final int vehicleId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartData = ref.watch(consumptionChartDataProvider(vehicleId));
    
    return chartData.when(
      data: (data) => LineChart(data),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error loading chart: $error'),
    );
  }
}
```

## Migration Guide

### For Existing Code

1. **Wrap main app with ProviderScope** (already done)
2. **Replace StatefulWidget with ConsumerWidget** where state management is needed
3. **Use ref.watch() for reactive state access**
4. **Use ref.read() for one-time actions**
5. **Replace manual state management with provider notifiers**

### Best Practices

1. **Use ConsumerWidget** for widgets that read providers
2. **Use Consumer** for partial widget rebuilds
3. **Prefer ref.watch()** for reactive updates
4. **Use ref.read()** in event handlers
5. **Handle loading and error states** appropriately
6. **Keep providers focused and single-responsibility**

## Future Enhancements

1. **Provider Persistence**: Add state persistence for offline usage
2. **Advanced Caching**: Implement custom cache strategies
3. **Real-time Updates**: Add WebSocket support for multi-device sync
4. **Background Sync**: Implement background data synchronization
5. **Provider Debugging**: Add custom dev tools integration

## Conclusion

The Riverpod implementation provides a robust, type-safe, and scalable state management solution for the Petrol Tracker application. It maintains clean separation of concerns while providing reactive state management with excellent error handling and testing capabilities.