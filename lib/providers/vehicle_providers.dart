import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/models/vehicle_statistics.dart';

part 'vehicle_providers.g.dart';

/// Ephemeral in-memory storage for vehicles (all platforms)
final Map<int, VehicleModel> _ephemeralVehicleStorage = <int, VehicleModel>{};
int _ephemeralVehicleIdCounter = 1;

/// Get next available ID for ephemeral vehicle storage
int _getNextEphemeralVehicleId() {
  return _ephemeralVehicleIdCounter++;
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
    if (error!.contains('unique constraint') || error!.contains('already exists')) {
      return 'A vehicle with this name already exists.';
    }
    if (error!.contains('foreign key') || error!.contains('existing fuel entries')) {
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

  /// Load all vehicles from ephemeral storage
  Future<VehicleState> _loadVehicles() async {
    try {
      // Use ephemeral in-memory storage for all platforms
      final vehicles = _ephemeralVehicleStorage.values.toList();
      return VehicleState(
        vehicles: vehicles,
        isDatabaseReady: true, // Always ready since it's in-memory
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
  Future<VehicleModel> addVehicle(VehicleModel vehicle) async {
    state = AsyncValue.data(
      state.value?.copyWith(
        currentOperation: VehicleOperation.adding,
        error: null,
      ) ?? const VehicleState(
        currentOperation: VehicleOperation.adding,
      )
    );

    try {
      // Use ephemeral in-memory storage for all platforms
      final id = _getNextEphemeralVehicleId();
      final newVehicle = vehicle.copyWith(id: id);
      _ephemeralVehicleStorage[id] = newVehicle;
      
      final currentState = state.value ?? const VehicleState();
      final updatedVehicles = [...currentState.vehicles, newVehicle];
      
      state = AsyncValue.data(
        currentState.copyWith(
          vehicles: updatedVehicles,
          currentOperation: VehicleOperation.none,
          error: null,
          lastUpdated: DateTime.now(),
        )
      );
      
      return newVehicle;
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      final currentState = state.value ?? const VehicleState();
      state = AsyncValue.data(
        currentState.copyWith(
          currentOperation: VehicleOperation.none,
          error: errorMessage,
        )
      );
      rethrow;
    }
  }

  /// Update an existing vehicle
  Future<void> updateVehicle(VehicleModel vehicle) async {
    if (vehicle.id == null) {
      throw ArgumentError('Vehicle ID is required for updates');
    }

    state = AsyncValue.data(
      state.value?.copyWith(
        currentOperation: VehicleOperation.updating,
        error: null,
      ) ?? const VehicleState(
        currentOperation: VehicleOperation.updating,
      )
    );

    try {
      // Update in ephemeral storage
      _ephemeralVehicleStorage[vehicle.id!] = vehicle;
      
      final currentState = state.value ?? const VehicleState();
      final updatedVehicles = currentState.vehicles
          .map((v) => v.id == vehicle.id ? vehicle : v)
          .toList();
      
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
      final currentState = state.value ?? const VehicleState();
      state = AsyncValue.data(
        currentState.copyWith(
          currentOperation: VehicleOperation.none,
          error: errorMessage,
        )
      );
    }
  }

  /// Delete a vehicle
  Future<void> deleteVehicle(int vehicleId) async {
    state = AsyncValue.data(
      state.value?.copyWith(
        currentOperation: VehicleOperation.deleting,
        error: null,
      ) ?? const VehicleState(
        currentOperation: VehicleOperation.deleting,
      )
    );

    try {
      // Remove from ephemeral storage
      _ephemeralVehicleStorage.remove(vehicleId);
      
      final currentState = state.value ?? const VehicleState();
      final updatedVehicles = currentState.vehicles
          .where((v) => v.id != vehicleId)
          .toList();
      
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
      final currentState = state.value ?? const VehicleState();
      state = AsyncValue.data(
        currentState.copyWith(
          currentOperation: VehicleOperation.none,
          error: errorMessage,
        )
      );
    }
  }

  /// Clear any error state
  void clearError() {
    final currentState = state.value;
    if (currentState != null && currentState.error != null) {
      state = AsyncValue.data(currentState.copyWith(error: null));
    }
  }

  /// Clear all vehicles (for testing purposes)
  Future<void> clearAllVehicles() async {
    state = AsyncValue.data(
      state.value?.copyWith(
        currentOperation: VehicleOperation.deleting,
        error: null,
      ) ?? const VehicleState(
        currentOperation: VehicleOperation.deleting,
      )
    );

    try {
      // Clear ephemeral storage
      _ephemeralVehicleStorage.clear();
      
      state = AsyncValue.data(
        const VehicleState(
          vehicles: [],
          isDatabaseReady: true,
          currentOperation: VehicleOperation.none,
          lastUpdated: null,
        )
      );
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      final currentState = state.value ?? const VehicleState();
      state = AsyncValue.data(
        currentState.copyWith(
          currentOperation: VehicleOperation.none,
          error: errorMessage,
        )
      );
    }
  }

  /// Convert exception to user-friendly error message
  String _getErrorMessage(dynamic error) {
    return 'An unexpected error occurred: ${error.toString()}';
  }
}

/// Provider for getting a specific vehicle by ID
@riverpod
Future<VehicleModel?> vehicle(Ref ref, int vehicleId) async {
  // Get from ephemeral storage
  return _ephemeralVehicleStorage[vehicleId];
}

/// Provider for checking if a vehicle name exists
@riverpod
Future<bool> vehicleNameExists(Ref ref, String vehicleName, {int? excludeId}) async {
  // Check ephemeral storage for all platforms
  return _ephemeralVehicleStorage.values.any((vehicle) => 
    vehicle.name.toLowerCase() == vehicleName.toLowerCase() && 
    vehicle.id != excludeId
  );
}

/// Provider for getting vehicle count
@riverpod
Future<int> vehicleCount(Ref ref) async {
  // Count from ephemeral storage
  return _ephemeralVehicleStorage.length;
}

/// Provider for getting vehicle statistics
@riverpod
Future<VehicleStatistics> vehicleStatistics(Ref ref, int vehicleId) async {
  // Return default statistics for ephemeral implementation
  // This will be enhanced when fuel entries are implemented
  return VehicleStatistics.empty(vehicleId);
}

/// Provider for getting vehicles with basic statistics
@riverpod
Future<List<Map<String, dynamic>>> vehiclesWithStats(Ref ref) async {
  // Return vehicles with basic stats from ephemeral storage
  final vehicles = _ephemeralVehicleStorage.values.toList();
  return vehicles.map((vehicle) => {
    'id': vehicle.id,
    'name': vehicle.name,
    'initialKm': vehicle.initialKm,
    'entryCount': 0, // Will be enhanced with fuel entries
    'avgConsumption': 0.0, // Will be enhanced with fuel entries
  }).toList();
}

/// Provider for checking ephemeral storage health
@riverpod
Future<bool> ephemeralStorageHealth(Ref ref) async {
  // Ephemeral storage is always healthy if we can access it
  try {
    _ephemeralVehicleStorage.length; // Simple access test
    return true;
  } catch (e) {
    return false;
  }
}