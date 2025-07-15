import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/models/vehicle_statistics.dart';
import 'package:petrol_tracker/database/database_exceptions.dart';
import 'database_providers.dart';

part 'vehicle_providers.g.dart';

/// Web-only in-memory storage for vehicles (temporary workaround)
final Map<int, VehicleModel> _webVehicleStorage = <int, VehicleModel>{};
int _webVehicleIdCounter = 1;

/// Get next available ID for web vehicle storage
int _getNextWebVehicleId() {
  return _webVehicleIdCounter++;
}

/// Enum for different vehicle operations
enum VehicleOperation {
  loading,
  adding,
  updating,
  deleting,
  none,
}

/// Enhanced state class for vehicle operations
class VehicleState {
  final List<VehicleModel> vehicles;
  final bool isLoading;
  final String? error;
  final VehicleOperation currentOperation;
  final Map<int, VehicleStatistics> statistics;
  final bool isDatabaseReady;
  final DateTime? lastUpdated;

  const VehicleState({
    this.vehicles = const [],
    this.isLoading = false,
    this.error,
    this.currentOperation = VehicleOperation.none,
    this.statistics = const {},
    this.isDatabaseReady = false,
    this.lastUpdated,
  });

  /// Check if we have any vehicles
  bool get hasVehicles => vehicles.isNotEmpty;

  /// Check if a specific operation is in progress
  bool get isOperationInProgress => currentOperation != VehicleOperation.none;

  /// Get user-friendly error message
  String? get userFriendlyError {
    if (error == null) return null;
    
    // Convert technical error to user-friendly message
    if (error!.contains('database')) {
      return 'Database connection issue. Please try again.';
    }
    if (error!.contains('unique constraint')) {
      return 'A vehicle with this name already exists.';
    }
    if (error!.contains('foreign key')) {
      return 'Cannot delete vehicle with existing fuel entries.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  VehicleState copyWith({
    List<VehicleModel>? vehicles,
    bool? isLoading,
    String? error,
    VehicleOperation? currentOperation,
    Map<int, VehicleStatistics>? statistics,
    bool? isDatabaseReady,
    DateTime? lastUpdated,
  }) {
    return VehicleState(
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentOperation: currentOperation ?? this.currentOperation,
      statistics: statistics ?? this.statistics,
      isDatabaseReady: isDatabaseReady ?? this.isDatabaseReady,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleState &&
        other.vehicles == vehicles &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.currentOperation == currentOperation &&
        other.isDatabaseReady == isDatabaseReady;
  }

  @override
  int get hashCode => Object.hash(
    vehicles,
    isLoading,
    error,
    currentOperation,
    isDatabaseReady,
  );
}

/// Notifier for managing vehicles state
@riverpod
class VehiclesNotifier extends _$VehiclesNotifier {
  @override
  Future<VehicleState> build() async {
    return _loadVehicles();
  }

  /// Load all vehicles from the repository
  Future<VehicleState> _loadVehicles() async {
    try {
      // For web platforms, use in-memory storage as temporary workaround
      if (kIsWeb) {
        final vehicles = _webVehicleStorage.values.toList();
        return VehicleState(
          vehicles: vehicles,
          isDatabaseReady: true,
          lastUpdated: DateTime.now(),
        );
      }
      
      final repository = ref.read(vehicleRepositoryProvider);
      
      // Ensure database is ready
      await repository.ensureDatabaseReady();
      
      final vehicles = await repository.getAllVehicles();
      
      return VehicleState(
        vehicles: vehicles,
        isDatabaseReady: true,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      return VehicleState(
        error: errorMessage,
        isDatabaseReady: false,
      );
    }
  }

  /// Refresh the vehicles list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadVehicles());
  }

  /// Add a new vehicle
  Future<void> addVehicle(VehicleModel vehicle) async {
    state = AsyncValue.data(
      state.valueOrNull?.copyWith(
        currentOperation: VehicleOperation.adding,
        error: null,
      ) ?? const VehicleState(
        currentOperation: VehicleOperation.adding,
      )
    );

    try {
      late final VehicleModel newVehicle;
      
      if (kIsWeb) {
        // Use in-memory storage for web platforms
        final id = _getNextWebVehicleId();
        newVehicle = vehicle.copyWith(id: id);
        _webVehicleStorage[id] = newVehicle;
      } else {
        final repository = ref.read(vehicleRepositoryProvider);
        final id = await repository.insertVehicle(vehicle);
        newVehicle = vehicle.copyWith(id: id);
      }
      
      final currentState = state.valueOrNull ?? const VehicleState();
      final updatedVehicles = [...currentState.vehicles, newVehicle];
      
      state = AsyncValue.data(
        currentState.copyWith(
          vehicles: updatedVehicles,
          currentOperation: VehicleOperation.none,
          error: null,
          lastUpdated: DateTime.now(),
        )
      );
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      final currentState = state.valueOrNull ?? const VehicleState();
      state = AsyncValue.data(
        currentState.copyWith(
          currentOperation: VehicleOperation.none,
          error: errorMessage,
        )
      );
    }
  }

  /// Update an existing vehicle
  Future<void> updateVehicle(VehicleModel vehicle) async {
    if (vehicle.id == null) {
      throw ArgumentError('Vehicle ID is required for updates');
    }

    state = AsyncValue.data(
      state.valueOrNull?.copyWith(isLoading: true) ?? 
      const VehicleState(isLoading: true)
    );

    try {
      final repository = ref.read(vehicleRepositoryProvider);
      final success = await repository.updateVehicle(vehicle);
      
      if (success) {
        final currentState = state.valueOrNull ?? const VehicleState();
        final updatedVehicles = currentState.vehicles
            .map((v) => v.id == vehicle.id ? vehicle : v)
            .toList();
        
        state = AsyncValue.data(
          currentState.copyWith(
            vehicles: updatedVehicles,
            isLoading: false,
            error: null,
          )
        );
      } else {
        throw DatabaseExceptionHandler.handleException(
          Exception('Failed to update vehicle'),
          'Vehicle update operation',
        );
      }
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      final currentState = state.valueOrNull ?? const VehicleState();
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          error: errorMessage,
        )
      );
    }
  }

  /// Delete a vehicle
  Future<void> deleteVehicle(int vehicleId) async {
    state = AsyncValue.data(
      state.valueOrNull?.copyWith(isLoading: true) ?? 
      const VehicleState(isLoading: true)
    );

    try {
      final repository = ref.read(vehicleRepositoryProvider);
      final success = await repository.deleteVehicle(vehicleId);
      
      if (success) {
        final currentState = state.valueOrNull ?? const VehicleState();
        final updatedVehicles = currentState.vehicles
            .where((v) => v.id != vehicleId)
            .toList();
        
        state = AsyncValue.data(
          currentState.copyWith(
            vehicles: updatedVehicles,
            isLoading: false,
            error: null,
          )
        );
      } else {
        throw DatabaseExceptionHandler.handleException(
          Exception('Failed to delete vehicle'),
          'Vehicle delete operation',
        );
      }
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      final currentState = state.valueOrNull ?? const VehicleState();
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          error: errorMessage,
        )
      );
    }
  }

  /// Clear any error state
  void clearError() {
    final currentState = state.valueOrNull;
    if (currentState != null && currentState.error != null) {
      state = AsyncValue.data(currentState.copyWith(error: null));
    }
  }

  /// Convert exception to user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is DatabaseException) {
      return DatabaseExceptionHandler.getUserFriendlyMessage(error);
    }
    return 'An unexpected error occurred: ${error.toString()}';
  }
}

/// Provider for getting a specific vehicle by ID
@riverpod
Future<VehicleModel?> vehicle(VehicleRef ref, int vehicleId) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.getVehicleById(vehicleId);
}

/// Provider for checking if a vehicle name exists
@riverpod
Future<bool> vehicleNameExists(VehicleNameExistsRef ref, String vehicleName, {int? excludeId}) async {
  if (kIsWeb) {
    // Check in-memory storage for web platforms
    return _webVehicleStorage.values.any((vehicle) => 
      vehicle.name.toLowerCase() == vehicleName.toLowerCase() && 
      vehicle.id != excludeId
    );
  }
  
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.vehicleNameExists(vehicleName, excludeId: excludeId);
}

/// Provider for getting vehicle count
@riverpod
Future<int> vehicleCount(VehicleCountRef ref) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.getVehicleCount();
}

/// Provider for getting vehicle statistics
@riverpod
Future<VehicleStatistics> vehicleStatistics(VehicleStatisticsRef ref, int vehicleId) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.getVehicleStatistics(vehicleId);
}

/// Provider for getting vehicles with basic statistics
@riverpod
Future<List<Map<String, dynamic>>> vehiclesWithStats(VehiclesWithStatsRef ref) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.getVehiclesWithBasicStats();
}

/// Provider for checking database health
@riverpod
Future<bool> databaseHealth(DatabaseHealthRef ref) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.checkDatabaseHealth();
}