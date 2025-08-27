import 'package:petrol_tracker/models/maintenance_log_model.dart';
import 'package:petrol_tracker/models/maintenance_category_model.dart';

/// Interface for maintenance data operations
/// 
/// Defines the contract for maintenance-related database operations.
/// This interface allows for different implementations (e.g., local database, remote API).
abstract class MaintenanceRepositoryInterface {
  // Maintenance Categories
  Future<List<MaintenanceCategoryModel>> getAllCategories();
  Future<MaintenanceCategoryModel?> getCategoryById(int id);
  Future<MaintenanceCategoryModel> addCategory(MaintenanceCategoryModel category);
  Future<void> updateCategory(MaintenanceCategoryModel category);
  Future<void> deleteCategory(int id);

  // Maintenance Logs
  Future<List<MaintenanceLogModel>> getAllMaintenanceLogs();
  Future<List<MaintenanceLogModel>> getMaintenanceLogsByVehicle(int vehicleId);
  Future<List<MaintenanceLogModel>> getMaintenanceLogsByCategory(int categoryId);
  Future<MaintenanceLogModel?> getMaintenanceLogById(int id);
  Future<MaintenanceLogModel> addMaintenanceLog(MaintenanceLogModel log);
  Future<void> updateMaintenanceLog(MaintenanceLogModel log);
  Future<void> deleteMaintenanceLog(int id);

  // Analytics
  Future<Map<String, double>> getMaintenanceCostsByCategory(int vehicleId);
  Future<double> getTotalMaintenanceCosts(int vehicleId);
  Future<List<MaintenanceLogModel>> getRecentMaintenance(int vehicleId, {int limit = 10});
  Future<Map<String, dynamic>> getMaintenanceStatistics(int vehicleId);
}