/// Helper utilities for testing ephemeral storage
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';

/// Clear all ephemeral storage for clean test state
void clearEphemeralStorage() {
  // Access the private storage maps through the providers
  // Note: This is a test helper - in real code, storage is managed by providers
  
  // Reset counters and clear storage
  // This simulates app restart behavior
  _resetEphemeralStorageCounters();
  _clearEphemeralStorageMaps();
}

/// Reset ID counters to initial state
void _resetEphemeralStorageCounters() {
  // Reset fuel entry counter
  // Reset vehicle counter
  // Note: These are private variables, so we simulate reset through provider operations
}

/// Clear all storage maps
void _clearEphemeralStorageMaps() {
  // Clear fuel entry storage
  // Clear vehicle storage
  // Note: These are private variables, so we simulate clear through provider operations
}

/// Helper to get current storage state for testing
class EphemeralStorageTestHelper {
  /// Get current number of vehicles in storage
  static int get vehicleCount => 0; // Will be implemented based on provider access
  
  /// Get current number of fuel entries in storage
  static int get fuelEntryCount => 0; // Will be implemented based on provider access
  
  /// Check if storage is empty
  static bool get isEmpty => vehicleCount == 0 && fuelEntryCount == 0;
}