import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/models/maintenance_log_model.dart';
import 'package:petrol_tracker/models/maintenance_category_model.dart';

// Ephemeral storage for maintenance data
final Map<int, MaintenanceLogModel> _ephemeralMaintenanceLogStorage = <int, MaintenanceLogModel>{};
final Map<int, MaintenanceCategoryModel> _ephemeralCategoryStorage = <int, MaintenanceCategoryModel>{};

int _ephemeralMaintenanceLogIdCounter = 1;
int _ephemeralCategoryIdCounter = 1;

/// Get next available ID for ephemeral maintenance log storage
int _getNextMaintenanceLogId() {
  return _ephemeralMaintenanceLogIdCounter++;
}

/// Get next available ID for ephemeral category storage
int _getNextCategoryId() {
  return _ephemeralCategoryIdCounter++;
}

/// Initialize default maintenance categories in ephemeral storage
void _initializeDefaultCategories() {
  if (_ephemeralCategoryStorage.isNotEmpty) return; // Already initialized
  
  final defaultCategories = [
    // Engine & Fluids
    {'name': 'Engine Oil & Filter', 'iconName': 'local_car_wash', 'color': '#FF5722'},
    {'name': 'Coolant / Antifreeze', 'iconName': 'ac_unit', 'color': '#2196F3'},
    {'name': 'Transmission Fluid', 'iconName': 'settings', 'color': '#FF9800'},
    {'name': 'Brake Fluid', 'iconName': 'local_shipping', 'color': '#F44336'},
    {'name': 'Power Steering Fluid', 'iconName': 'tune', 'color': '#9C27B0'},
    {'name': 'Differential / Transfer Case Oil', 'iconName': 'build_circle', 'color': '#607D8B'},
    
    // Filters & Air Systems
    {'name': 'Air Filter', 'iconName': 'filter_alt', 'color': '#4CAF50'},
    {'name': 'Cabin / Pollen Filter', 'iconName': 'air', 'color': '#00BCD4'},
    {'name': 'Fuel Filter', 'iconName': 'local_gas_station', 'color': '#FFC107'},
    
    // Brakes
    {'name': 'Brake Pads', 'iconName': 'speed', 'color': '#F44336'},
    {'name': 'Brake Rotors / Drums', 'iconName': 'album', 'color': '#E91E63'},
    {'name': 'Brake Lines / Hoses', 'iconName': 'linear_scale', 'color': '#9E9E9E'},
    {'name': 'ABS System Check', 'iconName': 'security', 'color': '#FF5722'},
    
    // Tires & Wheels
    {'name': 'Tire Rotation', 'iconName': 'tire_repair', 'color': '#9C27B0'},
    {'name': 'Tire Replacement', 'iconName': 'cached', 'color': '#673AB7'},
    {'name': 'Wheel Alignment', 'iconName': 'straighten', 'color': '#3F51B5'},
    {'name': 'Balancing', 'iconName': 'balance', 'color': '#2196F3'},
    {'name': 'Tire Pressure Checks', 'iconName': 'compress', 'color': '#03DAC6'},
    
    // Battery & Electrical
    {'name': 'Battery Replacement / Test', 'iconName': 'battery_full', 'color': '#FFC107'},
    {'name': 'Alternator / Starter Check', 'iconName': 'electrical_services', 'color': '#FF9800'},
    {'name': 'Lights (Headlights, Taillights, Indicators)', 'iconName': 'lightbulb', 'color': '#FFEB3B'},
    {'name': 'Fuses & Relays', 'iconName': 'power', 'color': '#795548'},
    
    // Suspension & Steering
    {'name': 'Shocks / Struts', 'iconName': 'car_repair', 'color': '#607D8B'},
    {'name': 'Ball Joints / Control Arms', 'iconName': 'join_inner', 'color': '#546E7A'},
    {'name': 'Tie Rods', 'iconName': 'link', 'color': '#78909C'},
    {'name': 'Power Steering System', 'iconName': 'control_camera', 'color': '#90A4AE'},
    
    // Exhaust & Emissions
    {'name': 'Muffler / Exhaust System', 'iconName': 'cloud', 'color': '#9E9E9E'},
    {'name': 'Catalytic Converter', 'iconName': 'eco', 'color': '#4CAF50'},
    {'name': 'Emissions Testing', 'iconName': 'science', 'color': '#8BC34A'},
    
    // Belts & Hoses
    {'name': 'Timing Belt / Chain', 'iconName': 'watch', 'color': '#FF9800'},
    {'name': 'Serpentine Belt', 'iconName': 'waves', 'color': '#FF5722'},
    {'name': 'Radiator Hoses / Heater Hoses', 'iconName': 'device_thermostat', 'color': '#F44336'},
    
    // Heating & Air Conditioning
    {'name': 'A/C Service / Refrigerant Recharge', 'iconName': 'ac_unit', 'color': '#2196F3'},
    {'name': 'Heater Core', 'iconName': 'whatshot', 'color': '#FF5722'},
    {'name': 'Blower Motor', 'iconName': 'air', 'color': '#00BCD4'},
    
    // Body & Interior
    {'name': 'Windshield / Wipers', 'iconName': 'visibility', 'color': '#03DAC6'},
    {'name': 'Door Locks / Windows', 'iconName': 'door_front', 'color': '#009688'},
    {'name': 'Seat Belts', 'iconName': 'airline_seat_legroom_normal', 'color': '#4CAF50'},
    {'name': 'Rust Treatment', 'iconName': 'healing', 'color': '#795548'},
    
    // Scheduled Maintenance
    {'name': 'Annual Service', 'iconName': 'event', 'color': '#9C27B0'},
    {'name': 'Major Service (60k/100k km)', 'iconName': 'build', 'color': '#673AB7'},
    {'name': 'Inspection Stickers / Certifications', 'iconName': 'verified', 'color': '#3F51B5'},
    
    // Repairs & Miscellaneous
    {'name': 'Unexpected Repairs', 'iconName': 'warning', 'color': '#FF9800'},
    {'name': 'Recalls / Warranty Work', 'iconName': 'policy', 'color': '#2196F3'},
    {'name': 'Accessories (Tow Hitch, Roof Rack, etc.)', 'iconName': 'extension', 'color': '#607D8B'},
    
    // General
    {'name': 'Other', 'iconName': 'more_horiz', 'color': '#757575'},
  ];
  
  for (final categoryData in defaultCategories) {
    final id = _getNextCategoryId();
    final category = MaintenanceCategoryModel(
      id: id,
      name: categoryData['name']!,
      iconName: categoryData['iconName']!,
      color: categoryData['color']!,
      isSystem: true,
      createdAt: DateTime.now(),
    );
    _ephemeralCategoryStorage[id] = category;
  }
}

// Category Providers

/// Provider for all maintenance categories
final maintenanceCategoriesProvider = FutureProvider<List<MaintenanceCategoryModel>>((ref) async {
  _initializeDefaultCategories();
  final categories = _ephemeralCategoryStorage.values.toList();
  categories.sort((a, b) => a.name.compareTo(b.name));
  return categories;
});

/// Provider for a specific maintenance category by ID
final maintenanceCategoryProvider = FutureProvider.family<MaintenanceCategoryModel?, int>((ref, categoryId) async {
  _initializeDefaultCategories();
  return _ephemeralCategoryStorage[categoryId];
});

// Maintenance Log Providers

/// Provider for all maintenance logs
final maintenanceLogsProvider = FutureProvider<List<MaintenanceLogModel>>((ref) async {
  final logs = _ephemeralMaintenanceLogStorage.values.toList();
  logs.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
  return logs;
});

/// Provider for maintenance logs by vehicle ID
final maintenanceLogsByVehicleProvider = FutureProvider.family<List<MaintenanceLogModel>, int>((ref, vehicleId) async {
  final allLogs = _ephemeralMaintenanceLogStorage.values.toList();
  final filteredLogs = allLogs.where((log) => log.vehicleId == vehicleId).toList();
  filteredLogs.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
  return filteredLogs;
});

/// Provider for maintenance logs by category ID
final maintenanceLogsByCategoryProvider = FutureProvider.family<List<MaintenanceLogModel>, int>((ref, categoryId) async {
  final allLogs = _ephemeralMaintenanceLogStorage.values.toList();
  final filteredLogs = allLogs.where((log) => log.categoryId == categoryId).toList();
  filteredLogs.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
  return filteredLogs;
});

/// Provider for recent maintenance logs by vehicle
final recentMaintenanceLogsProvider = FutureProvider.family<List<MaintenanceLogModel>, ({int vehicleId, int limit})>((ref, params) async {
  final allLogs = _ephemeralMaintenanceLogStorage.values.toList();
  final filteredLogs = allLogs.where((log) => log.vehicleId == params.vehicleId).toList();
  filteredLogs.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
  return filteredLogs.take(params.limit).toList();
});

// Analytics Providers

/// Provider for maintenance costs by category for a vehicle
final maintenanceCostsByCategoryProvider = FutureProvider.family<Map<String, double>, int>((ref, vehicleId) async {
  _initializeDefaultCategories();
  final allLogs = _ephemeralMaintenanceLogStorage.values.toList();
  final vehicleLogs = allLogs.where((log) => log.vehicleId == vehicleId).toList();
  
  final Map<String, double> costsByCategory = <String, double>{};
  
  for (final log in vehicleLogs) {
    final category = _ephemeralCategoryStorage[log.categoryId];
    if (category != null) {
      costsByCategory[category.name] = (costsByCategory[category.name] ?? 0) + log.totalCost;
    }
  }
  
  return costsByCategory;
});

/// Provider for total maintenance costs for a vehicle
final totalMaintenanceCostsProvider = FutureProvider.family<double, int>((ref, vehicleId) async {
  final allLogs = _ephemeralMaintenanceLogStorage.values.toList();
  final vehicleLogs = allLogs.where((log) => log.vehicleId == vehicleId).toList();
  return vehicleLogs.fold<double>(0.0, (sum, log) => sum + log.totalCost);
});

/// Provider for maintenance statistics for a vehicle
final maintenanceStatisticsProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, vehicleId) async {
  final allLogs = _ephemeralMaintenanceLogStorage.values.toList();
  final vehicleLogs = allLogs.where((log) => log.vehicleId == vehicleId).toList();
  
  final totalLogs = vehicleLogs.length;
  final totalCosts = vehicleLogs.fold<double>(0.0, (sum, log) => sum + log.totalCost);
  final averageCostPerLog = totalLogs > 0 ? totalCosts / totalLogs : 0.0;
  
  return {
    'totalLogs': totalLogs,
    'totalCosts': totalCosts,
    'averageCostPerLog': averageCostPerLog,
  };
});

// Notifier for state management of maintenance categories (ephemeral)
class MaintenanceCategoriesNotifier extends StateNotifier<AsyncValue<List<MaintenanceCategoryModel>>> {
  final Ref _ref;

  MaintenanceCategoriesNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      _initializeDefaultCategories();
      final categories = _ephemeralCategoryStorage.values.toList();
      categories.sort((a, b) => a.name.compareTo(b.name));
      state = AsyncValue.data(categories);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<MaintenanceCategoryModel> addCategory(MaintenanceCategoryModel category) async {
    final id = _getNextCategoryId();
    final newCategory = category.copyWith(
      id: id,
      createdAt: DateTime.now(),
    );
    
    // Add to ephemeral storage
    _ephemeralCategoryStorage[id] = newCategory;
    
    // Refresh the state
    await loadCategories();
    return newCategory;
  }

  Future<void> updateCategory(MaintenanceCategoryModel category) async {
    if (category.id != null) {
      _ephemeralCategoryStorage[category.id!] = category;
      await loadCategories();
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    _ephemeralCategoryStorage.remove(categoryId);
    await loadCategories();
  }
}

// Notifier for state management of maintenance logs (ephemeral)
class MaintenanceLogsNotifier extends StateNotifier<AsyncValue<List<MaintenanceLogModel>>> {
  final Ref _ref;

  MaintenanceLogsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadMaintenanceLogs();
  }

  Future<void> loadMaintenanceLogs() async {
    try {
      final logs = _ephemeralMaintenanceLogStorage.values.toList();
      logs.sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
      state = AsyncValue.data(logs);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<MaintenanceLogModel> addMaintenanceLog(MaintenanceLogModel log) async {
    final id = _getNextMaintenanceLogId();
    final newLog = log.copyWith(
      id: id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    // Add to ephemeral storage
    _ephemeralMaintenanceLogStorage[id] = newLog;
    
    // Refresh the state
    await loadMaintenanceLogs();
    
    // Invalidate related providers
    _ref.invalidate(maintenanceLogsProvider);
    _ref.invalidate(maintenanceLogsByVehicleProvider(log.vehicleId));
    _ref.invalidate(maintenanceLogsByCategoryProvider(log.categoryId));
    _ref.invalidate(recentMaintenanceLogsProvider((vehicleId: log.vehicleId, limit: 10)));
    _ref.invalidate(totalMaintenanceCostsProvider(log.vehicleId));
    _ref.invalidate(maintenanceCostsByCategoryProvider(log.vehicleId));
    _ref.invalidate(maintenanceStatisticsProvider(log.vehicleId));
    
    return newLog;
  }

  Future<void> updateMaintenanceLog(MaintenanceLogModel log) async {
    if (log.id != null) {
      final updatedLog = log.copyWith(updatedAt: DateTime.now());
      _ephemeralMaintenanceLogStorage[log.id!] = updatedLog;
      
      // Refresh the state
      await loadMaintenanceLogs();
      
      // Invalidate related providers
      _ref.invalidate(maintenanceLogsProvider);
      _ref.invalidate(maintenanceLogsByVehicleProvider(log.vehicleId));
      _ref.invalidate(maintenanceLogsByCategoryProvider(log.categoryId));
      _ref.invalidate(recentMaintenanceLogsProvider((vehicleId: log.vehicleId, limit: 10)));
      _ref.invalidate(totalMaintenanceCostsProvider(log.vehicleId));
      _ref.invalidate(maintenanceCostsByCategoryProvider(log.vehicleId));
      _ref.invalidate(maintenanceStatisticsProvider(log.vehicleId));
    }
  }

  Future<void> deleteMaintenanceLog(MaintenanceLogModel log) async {
    if (log.id != null) {
      _ephemeralMaintenanceLogStorage.remove(log.id!);
      
      // Refresh the state
      await loadMaintenanceLogs();
      
      // Invalidate related providers
      _ref.invalidate(maintenanceLogsProvider);
      _ref.invalidate(maintenanceLogsByVehicleProvider(log.vehicleId));
      _ref.invalidate(maintenanceLogsByCategoryProvider(log.categoryId));
      _ref.invalidate(recentMaintenanceLogsProvider((vehicleId: log.vehicleId, limit: 10)));
      _ref.invalidate(totalMaintenanceCostsProvider(log.vehicleId));
      _ref.invalidate(maintenanceCostsByCategoryProvider(log.vehicleId));
      _ref.invalidate(maintenanceStatisticsProvider(log.vehicleId));
    }
  }
}

/// Provider for maintenance categories notifier (ephemeral)
final maintenanceCategoriesNotifierProvider = StateNotifierProvider<MaintenanceCategoriesNotifier, AsyncValue<List<MaintenanceCategoryModel>>>((ref) {
  return MaintenanceCategoriesNotifier(ref);
});

/// Provider for maintenance logs notifier (ephemeral)
final maintenanceLogsNotifierProvider = StateNotifierProvider<MaintenanceLogsNotifier, AsyncValue<List<MaintenanceLogModel>>>((ref) {
  return MaintenanceLogsNotifier(ref);
});