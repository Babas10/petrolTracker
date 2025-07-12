import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/database/database_exceptions.dart';
import 'database_providers.dart';

part 'vehicle_providers.g.dart';

/// State class for vehicle operations
class VehicleState {
  final List<VehicleModel> vehicles;
  final bool isLoading;
  final String? error;

  const VehicleState({
    this.vehicles = const [],
    this.isLoading = false,
    this.error,
  });

  VehicleState copyWith({
    List<VehicleModel>? vehicles,
    bool? isLoading,
    String? error,
  }) {
    return VehicleState(
      vehicles: vehicles ?? this.vehicles,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleState &&
        other.vehicles == vehicles &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(vehicles, isLoading, error);
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
      final repository = ref.read(vehicleRepositoryProvider);
      final vehicles = await repository.getAllVehicles();
      return VehicleState(vehicles: vehicles);
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      return VehicleState(error: errorMessage);
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
      state.valueOrNull?.copyWith(isLoading: true) ?? 
      const VehicleState(isLoading: true)
    );

    try {
      final repository = ref.read(vehicleRepositoryProvider);
      final id = await repository.insertVehicle(vehicle);
      
      // Create the vehicle with the new ID
      final newVehicle = vehicle.copyWith(id: id);
      
      final currentState = state.valueOrNull ?? const VehicleState();
      final updatedVehicles = [...currentState.vehicles, newVehicle];
      
      state = AsyncValue.data(
        currentState.copyWith(
          vehicles: updatedVehicles,
          isLoading: false,
          error: null,
        )
      );
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
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.vehicleNameExists(vehicleName, excludeId: excludeId);
}

/// Provider for getting vehicle count
@riverpod
Future<int> vehicleCount(VehicleCountRef ref) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return repository.getVehicleCount();
}