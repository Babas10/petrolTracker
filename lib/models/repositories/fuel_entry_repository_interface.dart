import '../fuel_entry_model.dart';

/// Interface for fuel entry repository operations
/// This allows for easy testing and dependency injection
abstract class FuelEntryRepositoryInterface {
  /// Get all fuel entries from the database
  Future<List<FuelEntryModel>> getAllEntries();

  /// Get fuel entries for a specific vehicle
  Future<List<FuelEntryModel>> getEntriesByVehicle(int vehicleId);

  /// Get fuel entries within a date range
  Future<List<FuelEntryModel>> getEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get fuel entries for a vehicle within a date range
  Future<List<FuelEntryModel>> getEntriesByVehicleAndDateRange(
    int vehicleId,
    DateTime startDate,
    DateTime endDate,
  );

  /// Get the latest fuel entry for a vehicle
  Future<FuelEntryModel?> getLatestEntryForVehicle(int vehicleId);

  /// Get a fuel entry by its ID
  Future<FuelEntryModel?> getEntryById(int id);

  /// Insert a new fuel entry
  Future<int> insertEntry(FuelEntryModel entry);

  /// Update an existing fuel entry
  Future<bool> updateEntry(FuelEntryModel entry);

  /// Delete a fuel entry by ID
  Future<bool> deleteEntry(int id);

  /// Delete all fuel entries for a vehicle
  Future<int> deleteEntriesForVehicle(int vehicleId);

  /// Get fuel entry count
  Future<int> getEntryCount();

  /// Get fuel entry count for a specific vehicle
  Future<int> getEntryCountForVehicle(int vehicleId);

  /// Get entries grouped by country
  Future<Map<String, List<FuelEntryModel>>> getEntriesGroupedByCountry();

  /// Get average consumption for a vehicle
  Future<double?> getAverageConsumptionForVehicle(int vehicleId);
}