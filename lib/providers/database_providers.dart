import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:petrol_tracker/database/database.dart';
import 'package:petrol_tracker/database/database_service.dart';
import 'package:petrol_tracker/models/repositories/vehicle_repository.dart';
import 'package:petrol_tracker/models/repositories/fuel_entry_repository.dart';

part 'database_providers.g.dart';

/// Provides the main database instance
@Riverpod(keepAlive: true)
AppDatabase database(Ref ref) {
  return DatabaseService.instance.database;
}

/// Provides the database service instance
@Riverpod(keepAlive: true)
DatabaseService databaseService(Ref ref) {
  return DatabaseService.instance;
}

/// Provides the vehicle repository
@Riverpod(keepAlive: true)
VehicleRepository vehicleRepository(Ref ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return VehicleRepository(databaseService: databaseService);
}

/// Provides the fuel entry repository
@Riverpod(keepAlive: true)
FuelEntryRepository fuelEntryRepository(Ref ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return FuelEntryRepository(databaseService: databaseService);
}