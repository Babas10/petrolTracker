import 'package:drift/drift.dart';
import 'package:petrol_tracker/database/database.dart';
import 'package:petrol_tracker/database/database_service.dart';
import 'package:petrol_tracker/database/database_exceptions.dart';
import '../fuel_entry_model.dart';
import 'fuel_entry_repository_interface.dart';

/// Concrete implementation of FuelEntryRepositoryInterface using Drift
class FuelEntryRepository implements FuelEntryRepositoryInterface {
  final DatabaseService _databaseService;

  FuelEntryRepository({DatabaseService? databaseService})
      : _databaseService = databaseService ?? DatabaseService.instance;

  AppDatabase get _database => _databaseService.database;

  @override
  Future<List<FuelEntryModel>> getAllEntries() async {
    try {
      final entries = await (_database
          .select(_database.fuelEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

      return entries.map((e) => FuelEntryModel.fromEntity(e)).toList();
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to get all fuel entries',
      );
    }
  }

  @override
  Future<List<FuelEntryModel>> getEntriesByVehicle(int vehicleId) async {
    try {
      final entries = await (_database.select(_database.fuelEntries)
            ..where((t) => t.vehicleId.equals(vehicleId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

      return entries.map((e) => FuelEntryModel.fromEntity(e)).toList();
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to get fuel entries for vehicle: $vehicleId',
      );
    }
  }

  @override
  Future<List<FuelEntryModel>> getEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final entries = await (_database.select(_database.fuelEntries)
            ..where((t) =>
                t.date.isBiggerOrEqualValue(startDate) &
                t.date.isSmallerOrEqualValue(endDate))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

      return entries.map((e) => FuelEntryModel.fromEntity(e)).toList();
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to get fuel entries by date range',
      );
    }
  }

  @override
  Future<List<FuelEntryModel>> getEntriesByVehicleAndDateRange(
    int vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final entries = await (_database.select(_database.fuelEntries)
            ..where((t) =>
                t.vehicleId.equals(vehicleId) &
                t.date.isBiggerOrEqualValue(startDate) &
                t.date.isSmallerOrEqualValue(endDate))
            ..orderBy([(t) => OrderingTerm.desc(t.date)]))
          .get();

      return entries.map((e) => FuelEntryModel.fromEntity(e)).toList();
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to get fuel entries by vehicle and date range',
      );
    }
  }

  @override
  Future<FuelEntryModel?> getLatestEntryForVehicle(int vehicleId) async {
    try {
      final entry = await (_database.select(_database.fuelEntries)
            ..where((t) => t.vehicleId.equals(vehicleId))
            ..orderBy([(t) => OrderingTerm.desc(t.date)])
            ..limit(1))
          .getSingleOrNull();

      return entry != null ? FuelEntryModel.fromEntity(entry) : null;
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to get latest fuel entry for vehicle: $vehicleId',
      );
    }
  }

  @override
  Future<FuelEntryModel?> getEntryById(int id) async {
    try {
      final entry = await (_database.select(_database.fuelEntries)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      return entry != null ? FuelEntryModel.fromEntity(entry) : null;
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to get fuel entry by ID: $id',
      );
    }
  }

  @override
  Future<int> insertEntry(FuelEntryModel entry) async {
    try {
      // Get previous entry to validate km progression and calculate consumption
      final previousEntry = await getLatestEntryForVehicle(entry.vehicleId);
      final previousKm = previousEntry?.currentKm;

      // Validate the entry data
      final validationErrors = entry.validate(previousKm: previousKm);
      if (validationErrors.isNotEmpty) {
        throw DatabaseValidationException(
          'validation',
          entry.vehicleId.toString(),
          'Fuel entry validation failed: ${validationErrors.join(', ')}',
        );
      }

      // Calculate consumption if we have a previous entry
      final entryWithConsumption = previousKm != null
          ? entry.withCalculatedConsumption(previousKm)
          : entry;

      return await _database.into(_database.fuelEntries).insert(
        entryWithConsumption.toCompanion(),
      );
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to insert fuel entry',
      );
    }
  }

  @override
  Future<bool> updateEntry(FuelEntryModel entry) async {
    try {
      if (entry.id == null) {
        throw DatabaseValidationException(
          'id',
          entry.id?.toString() ?? 'null',
          'Cannot update fuel entry without ID',
        );
      }

      // Get previous entry to validate km progression
      final allEntries = await getEntriesByVehicle(entry.vehicleId);
      final sortedEntries = allEntries
        ..sort((a, b) => a.date.compareTo(b.date));

      // Find the entry before this one (by date)
      FuelEntryModel? previousEntry;
      for (int i = 0; i < sortedEntries.length; i++) {
        if (sortedEntries[i].id == entry.id && i > 0) {
          previousEntry = sortedEntries[i - 1];
          break;
        }
      }

      final previousKm = previousEntry?.currentKm;

      // Validate the entry data
      final validationErrors = entry.validate(previousKm: previousKm);
      if (validationErrors.isNotEmpty) {
        throw DatabaseValidationException(
          'validation',
          entry.vehicleId.toString(),
          'Fuel entry validation failed: ${validationErrors.join(', ')}',
        );
      }

      // Recalculate consumption if we have a previous entry
      final entryWithConsumption = previousKm != null
          ? entry.withCalculatedConsumption(previousKm)
          : entry;

      final rowsUpdated = await (_database.update(_database.fuelEntries)
            ..where((t) => t.id.equals(entry.id!)))
          .write(entryWithConsumption.toUpdateCompanion());

      return rowsUpdated > 0;
    } catch (e) {
      if (e is DatabaseException) rethrow;
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to update fuel entry',
      );
    }
  }

  @override
  Future<bool> deleteEntry(int id) async {
    try {
      final rowsDeleted = await (_database.delete(_database.fuelEntries)
            ..where((t) => t.id.equals(id)))
          .go();

      return rowsDeleted > 0;
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to delete fuel entry',
      );
    }
  }

  @override
  Future<int> deleteEntriesForVehicle(int vehicleId) async {
    try {
      return await (_database.delete(_database.fuelEntries)
            ..where((t) => t.vehicleId.equals(vehicleId)))
          .go();
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to delete fuel entries for vehicle: $vehicleId',
      );
    }
  }

  @override
  Future<int> getEntryCount() async {
    try {
      final result = await (_database
          .selectOnly(_database.fuelEntries)
          ..addColumns([_database.fuelEntries.id.count()]))
          .getSingle();

      return result.read(_database.fuelEntries.id.count()) ?? 0;
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to get fuel entry count',
      );
    }
  }

  @override
  Future<int> getEntryCountForVehicle(int vehicleId) async {
    try {
      final result = await (_database.selectOnly(_database.fuelEntries)
            ..where(_database.fuelEntries.vehicleId.equals(vehicleId))
            ..addColumns([_database.fuelEntries.id.count()]))
          .getSingle();

      return result.read(_database.fuelEntries.id.count()) ?? 0;
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to get fuel entry count for vehicle: $vehicleId',
      );
    }
  }

  @override
  Future<Map<String, List<FuelEntryModel>>> getEntriesGroupedByCountry() async {
    try {
      final entries = await getAllEntries();
      final grouped = <String, List<FuelEntryModel>>{};

      for (final entry in entries) {
        final country = entry.country;
        if (grouped.containsKey(country)) {
          grouped[country]!.add(entry);
        } else {
          grouped[country] = [entry];
        }
      }

      return grouped;
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to get fuel entries grouped by country',
      );
    }
  }

  @override
  Future<double?> getAverageConsumptionForVehicle(int vehicleId) async {
    try {
      final entries = await getEntriesByVehicle(vehicleId);
      final consumptionValues = entries
          .where((e) => e.consumption != null)
          .map((e) => e.consumption!)
          .toList();

      if (consumptionValues.isEmpty) return null;

      final sum = consumptionValues.reduce((a, b) => a + b);
      return sum / consumptionValues.length;
    } catch (e) {
      throw DatabaseExceptionHandler.handleException(
        e,
        'Failed to get average consumption for vehicle: $vehicleId',
      );
    }
  }
}