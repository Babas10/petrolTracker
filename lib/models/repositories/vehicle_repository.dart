import 'package:drift/drift.dart';
import 'package:petrol_tracker/database/database.dart';
import 'package:petrol_tracker/database/database_service.dart';
import 'package:petrol_tracker/database/database_exceptions.dart';
import '../vehicle_model.dart';
import '../vehicle_statistics.dart';
import '../fuel_entry_model.dart';
import 'vehicle_repository_interface.dart';

/// Concrete implementation of VehicleRepositoryInterface using Drift
class VehicleRepository implements VehicleRepositoryInterface {
  final DatabaseService _databaseService;

  VehicleRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  AppDatabase get _database => _databaseService.database;

  @override
  Future<List<VehicleModel>> getAllVehicles() async {
    try {
      final vehicles = await (_database
          .select(_database.vehicles)
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

      return vehicles.map((v) => VehicleModel.fromEntity(v)).toList();
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to get all vehicles',
      );
    }
  }

  @override
  Future<VehicleModel?> getVehicleById(int id) async {
    try {
      final vehicle = await (_database.select(_database.vehicles)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      return vehicle != null ? VehicleModel.fromEntity(vehicle) : null;
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to get vehicle by ID: $id',
      );
    }
  }

  @override
  Future<int> insertVehicle(VehicleModel vehicle) async {
    try {
      // Validate the vehicle data
      final validationErrors = vehicle.validate();
      if (validationErrors.isNotEmpty) {
        throw DatabaseValidationException(
          'validation',
          vehicle.name,
          'Vehicle validation failed: ${validationErrors.join(', ')}',
        );
      }

      // Check if name already exists
      final nameExists = await vehicleNameExists(vehicle.name);
      if (nameExists) {
        throw DatabaseConstraintException(
          'unique_name',
          'vehicles',
          'A vehicle with the name "${vehicle.name}" already exists',
        );
      }

      return await _database.into(_database.vehicles).insert(
        vehicle.toCompanion(),
      );
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to insert vehicle',
      );
    }
  }

  @override
  Future<bool> updateVehicle(VehicleModel vehicle) async {
    try {
      if (vehicle.id == null) {
        throw DatabaseValidationException(
          'id',
          vehicle.id?.toString() ?? 'null',
          'Cannot update vehicle without ID',
        );
      }

      // Validate the vehicle data
      final validationErrors = vehicle.validate();
      if (validationErrors.isNotEmpty) {
        throw DatabaseValidationException(
          'validation',
          vehicle.name,
          'Vehicle validation failed: ${validationErrors.join(', ')}',
        );
      }

      // Check if name already exists (excluding current vehicle)
      final nameExists = await vehicleNameExists(
        vehicle.name,
        excludeId: vehicle.id,
      );
      if (nameExists) {
        throw DatabaseConstraintException(
          'unique_name',
          'vehicles',
          'A vehicle with the name "${vehicle.name}" already exists',
        );
      }

      final rowsUpdated = await (_database.update(_database.vehicles)
            ..where((t) => t.id.equals(vehicle.id!)))
          .write(vehicle.toUpdateCompanion());

      return rowsUpdated > 0;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to update vehicle',
      );
    }
  }

  @override
  Future<bool> deleteVehicle(int id) async {
    try {
      // Check if vehicle has fuel entries
      final entryCount = await (_database.selectOnly(_database.fuelEntries)
            ..addColumns([_database.fuelEntries.id.count()])
            ..where(_database.fuelEntries.vehicleId.equals(id)))
          .getSingle()
          .then((row) => row.read(_database.fuelEntries.id.count()) ?? 0);

      if (entryCount > 0) {
        throw DatabaseConstraintException(
          'foreign_key',
          'vehicles',
          'Vehicle has $entryCount fuel entries. Delete them first.',
        );
      }

      final rowsDeleted = await (_database.delete(_database.vehicles)
            ..where((t) => t.id.equals(id)))
          .go();

      return rowsDeleted > 0;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to delete vehicle',
      );
    }
  }

  @override
  Future<bool> vehicleNameExists(String name, {int? excludeId}) async {
    try {
      var query = _database.select(_database.vehicles)
        ..where((t) => t.name.lower().equals(name.toLowerCase()));

      if (excludeId != null) {
        query = query..where((t) => t.id.equals(excludeId).not());
      }

      final result = await query.getSingleOrNull();
      return result != null;
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to check if vehicle name exists',
      );
    }
  }

  @override
  Future<int> getVehicleCount() async {
    try {
      final result = await (_database
          .selectOnly(_database.vehicles)
          ..addColumns([_database.vehicles.id.count()]))
          .getSingle();

      return result.read(_database.vehicles.id.count()) ?? 0;
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to get vehicle count',
      );
    }
  }

  /// Get comprehensive statistics for a vehicle
  Future<VehicleStatistics> getVehicleStatistics(int vehicleId) async {
    try {
      // Get all fuel entries for this vehicle
      final fuelEntries = await (_database
          .select(_database.fuelEntries)
          ..where((t) => t.vehicleId.equals(vehicleId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

      // Convert to models for statistics calculation
      final entryModels = fuelEntries.map((entry) => FuelEntryModel.fromEntity(entry)).toList();

      return VehicleStatistics.fromEntries(vehicleId, entryModels);
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to get vehicle statistics for vehicle $vehicleId',
      );
    }
  }

  /// Initialize database with proper error handling
  Future<void> ensureDatabaseReady() async {
    try {
      await _databaseService.initialize();
      
      // Test connection with a simple query
      await _database.customSelect('SELECT 1').get();
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to initialize database',
      );
    }
  }

  /// Verify database integrity
  Future<bool> checkDatabaseHealth() async {
    try {
      return await _databaseService.checkIntegrity();
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to check database health',
      );
    }
  }

  /// Get vehicles with their basic statistics
  Future<List<Map<String, dynamic>>> getVehiclesWithBasicStats() async {
    try {
      final vehicles = await getAllVehicles();
      final result = <Map<String, dynamic>>[];

      for (final vehicle in vehicles) {
        // Get entry count for this vehicle
        final entryCount = await (_database
            .selectOnly(_database.fuelEntries)
            ..addColumns([_database.fuelEntries.id.count()])
            ..where(_database.fuelEntries.vehicleId.equals(vehicle.id!)))
            .getSingle()
            .then((row) => row.read(_database.fuelEntries.id.count()) ?? 0);

        // Get latest entry for this vehicle
        final latestEntry = await (_database
            .select(_database.fuelEntries)
            ..where((t) => t.vehicleId.equals(vehicle.id!))
            ..orderBy([(t) => OrderingTerm.desc(t.date)])
            ..limit(1))
            .getSingleOrNull();

        result.add({
          'vehicle': vehicle,
          'entryCount': entryCount,
          'latestEntry': latestEntry != null ? FuelEntryModel.fromEntity(latestEntry) : null,
        });
      }

      return result;
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to get vehicles with statistics',
      );
    }
  }
}