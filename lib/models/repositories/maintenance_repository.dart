import 'package:drift/drift.dart';
import 'package:petrol_tracker/database/database.dart';
import 'package:petrol_tracker/models/maintenance_log_model.dart';
import 'package:petrol_tracker/models/maintenance_category_model.dart';
import 'package:petrol_tracker/models/repositories/maintenance_repository_interface.dart';

/// Drift-based implementation of maintenance repository
/// 
/// Provides database access for maintenance logs and categories using Drift ORM.
class MaintenanceRepository implements MaintenanceRepositoryInterface {
  final AppDatabase _database;

  const MaintenanceRepository(this._database);

  // Maintenance Categories

  @override
  Future<List<MaintenanceCategoryModel>> getAllCategories() async {
    final categories = await _database.select(_database.maintenanceCategories).get();
    return categories.map((e) => MaintenanceCategoryModel.fromEntity(e)).toList();
  }

  @override
  Future<MaintenanceCategoryModel?> getCategoryById(int id) async {
    final category = await (_database.select(_database.maintenanceCategories)
        ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    
    return category != null ? MaintenanceCategoryModel.fromEntity(category) : null;
  }

  @override
  Future<MaintenanceCategoryModel> addCategory(MaintenanceCategoryModel category) async {
    final id = await _database.into(_database.maintenanceCategories).insert(category.toCompanion());
    final insertedCategory = await getCategoryById(id);
    return insertedCategory!;
  }

  @override
  Future<void> updateCategory(MaintenanceCategoryModel category) async {
    await (_database.update(_database.maintenanceCategories)
        ..where((tbl) => tbl.id.equals(category.id!)))
        .write(category.toCompanion());
  }

  @override
  Future<void> deleteCategory(int id) async {
    await (_database.delete(_database.maintenanceCategories)
        ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  // Maintenance Logs

  @override
  Future<List<MaintenanceLogModel>> getAllMaintenanceLogs() async {
    final logs = await (_database.select(_database.maintenanceLogs)
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.serviceDate)]))
        .get();
    return logs.map((e) => MaintenanceLogModel.fromEntity(e)).toList();
  }

  @override
  Future<List<MaintenanceLogModel>> getMaintenanceLogsByVehicle(int vehicleId) async {
    final logs = await (_database.select(_database.maintenanceLogs)
        ..where((tbl) => tbl.vehicleId.equals(vehicleId))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.serviceDate)]))
        .get();
    return logs.map((e) => MaintenanceLogModel.fromEntity(e)).toList();
  }

  @override
  Future<List<MaintenanceLogModel>> getMaintenanceLogsByCategory(int categoryId) async {
    final logs = await (_database.select(_database.maintenanceLogs)
        ..where((tbl) => tbl.categoryId.equals(categoryId))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.serviceDate)]))
        .get();
    return logs.map((e) => MaintenanceLogModel.fromEntity(e)).toList();
  }

  @override
  Future<MaintenanceLogModel?> getMaintenanceLogById(int id) async {
    final log = await (_database.select(_database.maintenanceLogs)
        ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    
    return log != null ? MaintenanceLogModel.fromEntity(log) : null;
  }

  @override
  Future<MaintenanceLogModel> addMaintenanceLog(MaintenanceLogModel log) async {
    final id = await _database.into(_database.maintenanceLogs).insert(log.toCompanion());
    final insertedLog = await getMaintenanceLogById(id);
    return insertedLog!;
  }

  @override
  Future<void> updateMaintenanceLog(MaintenanceLogModel log) async {
    await (_database.update(_database.maintenanceLogs)
        ..where((tbl) => tbl.id.equals(log.id!)))
        .write(log.copyWith(updatedAt: DateTime.now()).toCompanion());
  }

  @override
  Future<void> deleteMaintenanceLog(int id) async {
    await (_database.delete(_database.maintenanceLogs)
        ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  // Analytics

  @override
  Future<Map<String, double>> getMaintenanceCostsByCategory(int vehicleId) async {
    final query = _database.selectOnly(_database.maintenanceLogs)
      ..addColumns([
        _database.maintenanceLogs.categoryId,
        _database.maintenanceLogs.totalCost.sum()
      ])
      ..where(_database.maintenanceLogs.vehicleId.equals(vehicleId))
      ..groupBy([_database.maintenanceLogs.categoryId]);

    final result = await query.get();
    final costsByCategory = <String, double>{};

    for (final row in result) {
      final categoryId = row.read(_database.maintenanceLogs.categoryId);
      final totalCost = row.read(_database.maintenanceLogs.totalCost.sum()) ?? 0.0;
      
      if (categoryId != null) {
        final category = await getCategoryById(categoryId);
        if (category != null) {
          costsByCategory[category.name] = totalCost;
        }
      }
    }

    return costsByCategory;
  }

  @override
  Future<double> getTotalMaintenanceCosts(int vehicleId) async {
    final query = _database.selectOnly(_database.maintenanceLogs)
      ..addColumns([_database.maintenanceLogs.totalCost.sum()])
      ..where(_database.maintenanceLogs.vehicleId.equals(vehicleId));

    final result = await query.getSingle();
    return result.read(_database.maintenanceLogs.totalCost.sum()) ?? 0.0;
  }

  @override
  Future<List<MaintenanceLogModel>> getRecentMaintenance(int vehicleId, {int limit = 10}) async {
    final logs = await (_database.select(_database.maintenanceLogs)
        ..where((tbl) => tbl.vehicleId.equals(vehicleId))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.serviceDate)])
        ..limit(limit))
        .get();
    return logs.map((e) => MaintenanceLogModel.fromEntity(e)).toList();
  }

  @override
  Future<Map<String, dynamic>> getMaintenanceStatistics(int vehicleId) async {
    final totalCosts = await getTotalMaintenanceCosts(vehicleId);
    final totalLogs = await (_database.select(_database.maintenanceLogs)
        ..where((tbl) => tbl.vehicleId.equals(vehicleId)))
        .get()
        .then((logs) => logs.length);

    final costsByCategory = await getMaintenanceCostsByCategory(vehicleId);
    final recentLogs = await getRecentMaintenance(vehicleId, limit: 5);

    return {
      'totalCosts': totalCosts,
      'totalLogs': totalLogs,
      'costsByCategory': costsByCategory,
      'recentLogs': recentLogs,
      'averageCostPerLog': totalLogs > 0 ? totalCosts / totalLogs : 0.0,
    };
  }
}