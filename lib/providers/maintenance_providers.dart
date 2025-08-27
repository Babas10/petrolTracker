import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/models/maintenance_log_model.dart';
import 'package:petrol_tracker/models/maintenance_category_model.dart';
import 'package:petrol_tracker/models/repositories/maintenance_repository.dart';
import 'package:petrol_tracker/providers/database_providers.dart';

// Repository Provider

/// Provider for the maintenance repository
final maintenanceRepositoryProvider = Provider<MaintenanceRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return MaintenanceRepository(database);
});

// Category Providers

/// Provider for all maintenance categories
final maintenanceCategoriesProvider = FutureProvider<List<MaintenanceCategoryModel>>((ref) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.getAllCategories();
});

/// Provider for a specific maintenance category by ID
final maintenanceCategoryProvider = FutureProvider.family<MaintenanceCategoryModel?, int>((ref, categoryId) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.getCategoryById(categoryId);
});

// Maintenance Log Providers

/// Provider for all maintenance logs
final maintenanceLogsProvider = FutureProvider<List<MaintenanceLogModel>>((ref) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.getAllMaintenanceLogs();
});

/// Provider for maintenance logs by vehicle ID
final maintenanceLogsByVehicleProvider = FutureProvider.family<List<MaintenanceLogModel>, int>((ref, vehicleId) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.getMaintenanceLogsByVehicle(vehicleId);
});

/// Provider for maintenance logs by category ID
final maintenanceLogsByCategoryProvider = FutureProvider.family<List<MaintenanceLogModel>, int>((ref, categoryId) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.getMaintenanceLogsByCategory(categoryId);
});

/// Provider for recent maintenance logs by vehicle
final recentMaintenanceLogsProvider = FutureProvider.family<List<MaintenanceLogModel>, ({int vehicleId, int limit})>((ref, params) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.getRecentMaintenance(params.vehicleId, limit: params.limit);
});

// Analytics Providers

/// Provider for maintenance costs by category for a vehicle
final maintenanceCostsByCategoryProvider = FutureProvider.family<Map<String, double>, int>((ref, vehicleId) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.getMaintenanceCostsByCategory(vehicleId);
});

/// Provider for total maintenance costs for a vehicle
final totalMaintenanceCostsProvider = FutureProvider.family<double, int>((ref, vehicleId) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.getTotalMaintenanceCosts(vehicleId);
});

/// Provider for maintenance statistics for a vehicle
final maintenanceStatisticsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, vehicleId) async {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return repository.getMaintenanceStatistics(vehicleId);
});

// Notifier for state management of maintenance logs
class MaintenanceLogsNotifier extends StateNotifier<AsyncValue<List<MaintenanceLogModel>>> {
  final MaintenanceRepository _repository;
  final Ref _ref;

  MaintenanceLogsNotifier(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadMaintenanceLogs();
  }

  Future<void> loadMaintenanceLogs() async {
    try {
      final logs = await _repository.getAllMaintenanceLogs();
      state = AsyncValue.data(logs);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<MaintenanceLogModel> addMaintenanceLog(MaintenanceLogModel log) async {
    final newLog = await _repository.addMaintenanceLog(log);
    
    // Refresh the state
    await loadMaintenanceLogs();
    
    // Invalidate related providers
    _ref.invalidate(maintenanceLogsByVehicleProvider(log.vehicleId));
    _ref.invalidate(maintenanceLogsByCategoryProvider(log.categoryId));
    _ref.invalidate(recentMaintenanceLogsProvider((vehicleId: log.vehicleId, limit: 10)));
    _ref.invalidate(totalMaintenanceCostsProvider(log.vehicleId));
    _ref.invalidate(maintenanceCostsByCategoryProvider(log.vehicleId));
    _ref.invalidate(maintenanceStatisticsProvider(log.vehicleId));
    
    return newLog;
  }

  Future<void> updateMaintenanceLog(MaintenanceLogModel log) async {
    await _repository.updateMaintenanceLog(log);
    
    // Refresh the state
    await loadMaintenanceLogs();
    
    // Invalidate related providers
    _ref.invalidate(maintenanceLogsByVehicleProvider(log.vehicleId));
    _ref.invalidate(maintenanceLogsByCategoryProvider(log.categoryId));
    _ref.invalidate(recentMaintenanceLogsProvider((vehicleId: log.vehicleId, limit: 10)));
    _ref.invalidate(totalMaintenanceCostsProvider(log.vehicleId));
    _ref.invalidate(maintenanceCostsByCategoryProvider(log.vehicleId));
    _ref.invalidate(maintenanceStatisticsProvider(log.vehicleId));
  }

  Future<void> deleteMaintenanceLog(MaintenanceLogModel log) async {
    await _repository.deleteMaintenanceLog(log.id!);
    
    // Refresh the state
    await loadMaintenanceLogs();
    
    // Invalidate related providers
    _ref.invalidate(maintenanceLogsByVehicleProvider(log.vehicleId));
    _ref.invalidate(maintenanceLogsByCategoryProvider(log.categoryId));
    _ref.invalidate(recentMaintenanceLogsProvider((vehicleId: log.vehicleId, limit: 10)));
    _ref.invalidate(totalMaintenanceCostsProvider(log.vehicleId));
    _ref.invalidate(maintenanceCostsByCategoryProvider(log.vehicleId));
    _ref.invalidate(maintenanceStatisticsProvider(log.vehicleId));
  }
}

/// Provider for maintenance logs notifier
final maintenanceLogsNotifierProvider = StateNotifierProvider<MaintenanceLogsNotifier, AsyncValue<List<MaintenanceLogModel>>>((ref) {
  final repository = ref.watch(maintenanceRepositoryProvider);
  return MaintenanceLogsNotifier(repository, ref);
});