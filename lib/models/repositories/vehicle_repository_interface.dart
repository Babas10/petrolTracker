import '../vehicle_model.dart';

/// Interface for vehicle repository operations
/// This allows for easy testing and dependency injection
abstract class VehicleRepositoryInterface {
  /// Get all vehicles from the database
  Future<List<VehicleModel>> getAllVehicles();

  /// Get a vehicle by its ID
  Future<VehicleModel?> getVehicleById(int id);

  /// Insert a new vehicle
  Future<int> insertVehicle(VehicleModel vehicle);

  /// Update an existing vehicle
  Future<bool> updateVehicle(VehicleModel vehicle);

  /// Delete a vehicle by ID
  Future<bool> deleteVehicle(int id);

  /// Check if a vehicle name already exists (case-insensitive)
  Future<bool> vehicleNameExists(String name, {int? excludeId});

  /// Get vehicle count
  Future<int> getVehicleCount();
}