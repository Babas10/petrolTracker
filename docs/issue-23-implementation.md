# Issue #23: Implement Data Models and Repositories

## Overview

This document details the implementation of Issue #23 - "Implement data models and repositories" for the Petrol Tracker application.

## Issue Description

Create data models and repository pattern for fuel tracking functionality with proper validation, business logic, and CRUD operations.

## Implementation Summary

### ✅ Completed Tasks

1. **Data Models Creation**
   - Created `VehicleModel` with comprehensive validation and business logic
   - Created `FuelEntryModel` with consumption calculation and validation
   - Implemented proper data conversion between models and Drift entities

2. **Repository Pattern Implementation**
   - Created repository interfaces for testing and dependency injection
   - Implemented `VehicleRepository` with full CRUD operations
   - Implemented `FuelEntryRepository` with advanced querying capabilities
   - Added comprehensive error handling and validation

3. **Validation and Business Logic**
   - Implemented robust validation for all data models
   - Added automatic fuel consumption calculation
   - Created user-friendly error messages and validation feedback
   - Implemented data integrity constraints

4. **Testing Infrastructure**
   - Created comprehensive unit tests for all models (40 tests)
   - Implemented integration tests for database operations (6 tests)
   - Added validation testing for edge cases and error conditions
   - Created test infrastructure for future repository testing

## Technical Details

### Data Models

#### VehicleModel
```dart
class VehicleModel {
  final int? id;
  final String name;
  final double initialKm;
  final DateTime createdAt;
}
```

**Key Features:**
- Factory constructors for entity conversion and creation
- Comprehensive validation (name length, initial km constraints)
- Drift companion conversion for database operations
- Immutable design with copyWith functionality

#### FuelEntryModel
```dart
class FuelEntryModel {
  final int? id;
  final int vehicleId;
  final DateTime date;
  final double currentKm;
  final double fuelAmount;
  final double price;
  final String country;
  final double pricePerLiter;
  final double? consumption;
}
```

**Key Features:**
- Automatic consumption calculation (L/100km)
- Price consistency validation
- Km progression validation against previous entries
- Formatted property getters for UI display
- Business logic for fuel efficiency analysis

### Repository Pattern

#### Repository Interfaces
- `VehicleRepositoryInterface` - Contract for vehicle operations
- `FuelEntryRepositoryInterface` - Contract for fuel entry operations
- Enable dependency injection and testing isolation

#### Repository Implementations

##### VehicleRepository
```dart
class VehicleRepository implements VehicleRepositoryInterface {
  // CRUD Operations
  Future<List<VehicleModel>> getAllVehicles();
  Future<VehicleModel?> getVehicleById(int id);
  Future<int> insertVehicle(VehicleModel vehicle);
  Future<bool> updateVehicle(VehicleModel vehicle);
  Future<bool> deleteVehicle(int id);
  
  // Business Logic
  Future<bool> vehicleNameExists(String name, {int? excludeId});
  Future<int> getVehicleCount();
}
```

##### FuelEntryRepository
```dart
class FuelEntryRepository implements FuelEntryRepositoryInterface {
  // Basic CRUD
  Future<List<FuelEntryModel>> getAllEntries();
  Future<FuelEntryModel?> getEntryById(int id);
  Future<int> insertEntry(FuelEntryModel entry);
  Future<bool> updateEntry(FuelEntryModel entry);
  Future<bool> deleteEntry(int id);
  
  // Advanced Queries
  Future<List<FuelEntryModel>> getEntriesByVehicle(int vehicleId);
  Future<List<FuelEntryModel>> getEntriesByDateRange(DateTime start, DateTime end);
  Future<FuelEntryModel?> getLatestEntryForVehicle(int vehicleId);
  Future<Map<String, List<FuelEntryModel>>> getEntriesGroupedByCountry();
  Future<double?> getAverageConsumptionForVehicle(int vehicleId);
}
```

### Validation System

#### Vehicle Validation Rules
- **Name**: Required, 2-100 characters, unique (case-insensitive)
- **Initial km**: Required, >= 0
- **Created at**: Automatically set to current time

#### Fuel Entry Validation Rules
- **Vehicle ID**: Required, must reference existing vehicle
- **Date**: Required, cannot be in future
- **Current km**: Required, >= 0, must be >= previous entry km
- **Fuel amount**: Required, > 0, warning if > 200L
- **Price**: Required, > 0
- **Price per liter**: Required, > 0, warning if > $10
- **Country**: Required, 2-50 characters
- **Price consistency**: Total price must match fuel amount × price per liter

#### Error Handling
```dart
// Validation errors return user-friendly messages
final errors = vehicle.validate();
// ["Vehicle name is required", "Initial kilometers must be 0 or greater"]

// Database exceptions are properly handled
try {
  await repository.insertVehicle(vehicle);
} catch (DatabaseConstraintException e) {
  // Handle duplicate name, foreign key violations, etc.
}
```

### Business Logic Features

#### Automatic Consumption Calculation
```dart
static double? calculateConsumption({
  required double fuelAmount,
  required double currentKm,
  required double previousKm,
}) {
  final distance = currentKm - previousKm;
  if (distance <= 0) return null;
  return (fuelAmount / distance) * 100; // L/100km
}
```

#### Data Integrity
- Prevents vehicle deletion with existing fuel entries
- Validates km progression between entries
- Ensures price consistency across entry data
- Maintains referential integrity with proper foreign keys

#### Formatted Properties
```dart
// User-friendly display formats
String get formattedConsumption => '${consumption!.toStringAsFixed(1)} L/100km';
String get formattedPrice => '\$${price.toStringAsFixed(2)}';
String get formattedFuelAmount => '${fuelAmount.toStringAsFixed(1)}L';
```

## Files Created/Modified

### New Files
- `lib/models/vehicle_model.dart` - Vehicle data model with validation
- `lib/models/fuel_entry_model.dart` - Fuel entry data model with business logic
- `lib/models/repositories/vehicle_repository_interface.dart` - Vehicle repository contract
- `lib/models/repositories/fuel_entry_repository_interface.dart` - Fuel entry repository contract
- `lib/models/repositories/vehicle_repository.dart` - Vehicle repository implementation
- `lib/models/repositories/fuel_entry_repository.dart` - Fuel entry repository implementation
- `test/models/vehicle_model_test.dart` - Vehicle model unit tests (15 tests)
- `test/models/fuel_entry_model_test.dart` - Fuel entry model unit tests (25 tests)
- `test/models/repositories/simple_repository_test.dart` - Integration tests (6 tests)
- `docs/issue-23-implementation.md` - This documentation

### Modified Files
- None (all new functionality)

## Testing Results

### Test Coverage Summary
- **Vehicle Model Tests**: 15/15 passing ✅
- **Fuel Entry Model Tests**: 25/25 passing ✅
- **Integration Tests**: 6/6 passing ✅
- **Total Tests**: 46/46 passing ✅

### Test Categories
1. **Model Creation and Conversion**
   - Factory constructors from entities
   - Companion conversion for database operations
   - copyWith functionality for immutable updates

2. **Validation Testing**
   - Valid data acceptance
   - Invalid data rejection with proper error messages
   - Edge cases and boundary conditions
   - Cross-field validation (price consistency, km progression)

3. **Business Logic Testing**
   - Consumption calculation accuracy
   - Formatted property outputs
   - Data integrity constraints
   - Equality and hashing behavior

4. **Integration Testing**
   - Database round-trip operations
   - Model-to-entity conversion accuracy
   - Validation integration with database layer

## Key Achievements

### ✅ All Requirements Met
- **Vehicle Model**: All properties and validation implemented
- **FuelEntry Model**: All properties with consumption calculation
- **Repository Pattern**: Full CRUD operations with interfaces
- **Data Validation**: Comprehensive validation rules implemented
- **Error Handling**: Proper exception handling throughout
- **Testing**: Extensive test coverage for reliability

### ✅ Additional Features Implemented
- **Automatic Consumption Calculation**: Business logic for fuel efficiency
- **Formatted Properties**: User-friendly display formats
- **Advanced Queries**: Date ranges, grouping, statistics
- **Data Integrity**: Prevents orphaned records and inconsistent data
- **Price Validation**: Ensures mathematical consistency
- **Case-Insensitive Uniqueness**: Better user experience for vehicle names

### ✅ Architecture Benefits
- **Separation of Concerns**: Models, repositories, and validation are clearly separated
- **Testability**: Interface-based design enables comprehensive testing
- **Maintainability**: Clear structure and documentation for future development
- **Extensibility**: Easy to add new validation rules or business logic
- **Type Safety**: Full Dart type safety with null safety compliance

## Performance Considerations

### Database Optimizations
- Repository methods use efficient Drift queries
- Proper use of indexes from previous database setup
- Minimal data conversion overhead
- Lazy loading where appropriate

### Memory Efficiency
- Immutable models prevent accidental mutations
- Efficient data structures for collections
- Proper disposal of resources in tests

## Error Handling Strategy

### Validation Errors
```dart
// Returns list of human-readable error messages
List<String> validate({double? previousKm}) {
  final errors = <String>[];
  // Validation logic...
  return errors;
}
```

### Database Errors
```dart
// Converts database exceptions to user-friendly messages
try {
  await repository.insertVehicle(vehicle);
} catch (DatabaseConstraintException e) {
  final userMessage = DatabaseExceptionHandler.getUserFriendlyMessage(e);
  // Display to user
}
```

## Next Steps

This implementation provides a solid foundation for the following subsequent issues:

1. **Issue #24**: Riverpod state management integration
2. **Issue #25**: Navigation structure with repository injection
3. **Issue #1**: Vehicle management screens using these models
4. **Issue #2**: Fuel entry forms with validation integration

## API Documentation

### VehicleModel API
```dart
// Creation
VehicleModel.create({required String name, required double initialKm})
VehicleModel.fromEntity(Vehicle entity)

// Validation
List<String> validate()
bool get isValid

// Conversion
VehiclesCompanion toCompanion()
VehiclesCompanion toUpdateCompanion()

// Utilities
VehicleModel copyWith({...})
```

### FuelEntryModel API
```dart
// Creation
FuelEntryModel.create({required vehicleId, required date, ...})
FuelEntryModel.fromEntity(FuelEntry entity)

// Business Logic
static double? calculateConsumption({...})
FuelEntryModel withCalculatedConsumption(double? previousKm)

// Validation
List<String> validate({double? previousKm})
bool isValid({double? previousKm})

// Formatted Properties
String get formattedConsumption
String get formattedPrice
String get formattedFuelAmount
double get averagePricePerLiter
```

### Repository APIs
```dart
// VehicleRepository
Future<List<VehicleModel>> getAllVehicles()
Future<VehicleModel?> getVehicleById(int id)
Future<int> insertVehicle(VehicleModel vehicle)
Future<bool> updateVehicle(VehicleModel vehicle)
Future<bool> deleteVehicle(int id)
Future<bool> vehicleNameExists(String name, {int? excludeId})

// FuelEntryRepository
Future<List<FuelEntryModel>> getAllEntries()
Future<List<FuelEntryModel>> getEntriesByVehicle(int vehicleId)
Future<List<FuelEntryModel>> getEntriesByDateRange(DateTime start, DateTime end)
Future<FuelEntryModel?> getLatestEntryForVehicle(int vehicleId)
Future<double?> getAverageConsumptionForVehicle(int vehicleId)
```

## Conclusion

Issue #23 has been successfully implemented, providing a robust, well-tested foundation for data models and repositories in the Petrol Tracker application. The implementation includes comprehensive validation, business logic, error handling, and follows Flutter/Dart best practices for maintainable and scalable code.

The 46 passing tests ensure reliability and provide confidence for future development. The repository pattern enables easy testing and dependency injection for the upcoming state management and UI implementation phases.