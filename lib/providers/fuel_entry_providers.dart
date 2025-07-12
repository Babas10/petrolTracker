import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/database/database_exceptions.dart';
import 'database_providers.dart';

part 'fuel_entry_providers.g.dart';

/// State class for fuel entry operations
class FuelEntryState {
  final List<FuelEntryModel> entries;
  final bool isLoading;
  final String? error;

  const FuelEntryState({
    this.entries = const [],
    this.isLoading = false,
    this.error,
  });

  FuelEntryState copyWith({
    List<FuelEntryModel>? entries,
    bool? isLoading,
    String? error,
  }) {
    return FuelEntryState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FuelEntryState &&
        other.entries == entries &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(entries, isLoading, error);
}

/// Notifier for managing fuel entries state
@riverpod
class FuelEntriesNotifier extends _$FuelEntriesNotifier {
  @override
  Future<FuelEntryState> build() async {
    return _loadFuelEntries();
  }

  /// Load all fuel entries from the repository
  Future<FuelEntryState> _loadFuelEntries() async {
    try {
      final repository = ref.read(fuelEntryRepositoryProvider);
      final entries = await repository.getAllEntries();
      return FuelEntryState(entries: entries);
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      return FuelEntryState(error: errorMessage);
    }
  }

  /// Refresh the fuel entries list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadFuelEntries());
  }

  /// Add a new fuel entry
  Future<void> addFuelEntry(FuelEntryModel entry) async {
    state = AsyncValue.data(
      state.valueOrNull?.copyWith(isLoading: true) ?? 
      const FuelEntryState(isLoading: true)
    );

    try {
      final repository = ref.read(fuelEntryRepositoryProvider);
      final id = await repository.insertEntry(entry);
      
      // Create the entry with the new ID
      final newEntry = entry.copyWith(id: id);
      
      final currentState = state.valueOrNull ?? const FuelEntryState();
      final updatedEntries = [newEntry, ...currentState.entries];
      
      state = AsyncValue.data(
        currentState.copyWith(
          entries: updatedEntries,
          isLoading: false,
          error: null,
        )
      );
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      final currentState = state.valueOrNull ?? const FuelEntryState();
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          error: errorMessage,
        )
      );
    }
  }

  /// Update an existing fuel entry
  Future<void> updateFuelEntry(FuelEntryModel entry) async {
    if (entry.id == null) {
      throw ArgumentError('Fuel entry ID is required for updates');
    }

    state = AsyncValue.data(
      state.valueOrNull?.copyWith(isLoading: true) ?? 
      const FuelEntryState(isLoading: true)
    );

    try {
      final repository = ref.read(fuelEntryRepositoryProvider);
      final success = await repository.updateEntry(entry);
      
      if (success) {
        final currentState = state.valueOrNull ?? const FuelEntryState();
        final updatedEntries = currentState.entries
            .map((e) => e.id == entry.id ? entry : e)
            .toList();
        
        state = AsyncValue.data(
          currentState.copyWith(
            entries: updatedEntries,
            isLoading: false,
            error: null,
          )
        );
      } else {
        throw DatabaseExceptionHandler.handleException(
          Exception('Failed to update fuel entry'),
          'Fuel entry update operation',
        );
      }
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      final currentState = state.valueOrNull ?? const FuelEntryState();
      state = AsyncValue.data(
        currentState.copyWith(
          isLoading: false,
          error: errorMessage,
        )
      );
    }
  }

  /// Delete a fuel entry
  Future<void> deleteFuelEntry(int entryId) async {
    state = AsyncValue.data(
      state.valueOrNull?.copyWith(isLoading: true) ?? 
      const FuelEntryState(isLoading: true)
    );

    try {
      final repository = ref.read(fuelEntryRepositoryProvider);
      final success = await repository.deleteEntry(entryId);
      
      if (success) {
        final currentState = state.valueOrNull ?? const FuelEntryState();
        final updatedEntries = currentState.entries
            .where((e) => e.id != entryId)
            .toList();
        
        state = AsyncValue.data(
          currentState.copyWith(
            entries: updatedEntries,
            isLoading: false,
            error: null,
          )
        );
      } else {
        throw DatabaseExceptionHandler.handleException(
          Exception('Failed to delete fuel entry'),
          'Fuel entry delete operation',
        );
      }
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      final currentState = state.valueOrNull ?? const FuelEntryState();
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

/// Provider for getting fuel entries by vehicle
@riverpod
Future<List<FuelEntryModel>> fuelEntriesByVehicle(
  FuelEntriesByVehicleRef ref,
  int vehicleId,
) async {
  final repository = ref.watch(fuelEntryRepositoryProvider);
  return repository.getEntriesByVehicle(vehicleId);
}

/// Provider for getting fuel entries by date range
@riverpod
Future<List<FuelEntryModel>> fuelEntriesByDateRange(
  FuelEntriesByDateRangeRef ref,
  DateTime startDate,
  DateTime endDate,
) async {
  final repository = ref.watch(fuelEntryRepositoryProvider);
  return repository.getEntriesByDateRange(startDate, endDate);
}

/// Provider for getting fuel entries by vehicle and date range
@riverpod
Future<List<FuelEntryModel>> fuelEntriesByVehicleAndDateRange(
  FuelEntriesByVehicleAndDateRangeRef ref,
  int vehicleId,
  DateTime startDate,
  DateTime endDate,
) async {
  final repository = ref.watch(fuelEntryRepositoryProvider);
  return repository.getEntriesByVehicleAndDateRange(vehicleId, startDate, endDate);
}

/// Provider for getting the latest fuel entry for a vehicle
@riverpod
Future<FuelEntryModel?> latestFuelEntryForVehicle(
  LatestFuelEntryForVehicleRef ref,
  int vehicleId,
) async {
  final repository = ref.watch(fuelEntryRepositoryProvider);
  return repository.getLatestEntryForVehicle(vehicleId);
}

/// Provider for getting a specific fuel entry by ID
@riverpod
Future<FuelEntryModel?> fuelEntry(FuelEntryRef ref, int entryId) async {
  final repository = ref.watch(fuelEntryRepositoryProvider);
  return repository.getEntryById(entryId);
}

/// Provider for getting fuel entry count
@riverpod
Future<int> fuelEntryCount(FuelEntryCountRef ref) async {
  final repository = ref.watch(fuelEntryRepositoryProvider);
  return repository.getEntryCount();
}

/// Provider for getting fuel entry count for a specific vehicle
@riverpod
Future<int> fuelEntryCountForVehicle(
  FuelEntryCountForVehicleRef ref,
  int vehicleId,
) async {
  final repository = ref.watch(fuelEntryRepositoryProvider);
  return repository.getEntryCountForVehicle(vehicleId);
}

/// Provider for getting fuel entries grouped by country
@riverpod
Future<Map<String, List<FuelEntryModel>>> fuelEntriesGroupedByCountry(
  FuelEntriesGroupedByCountryRef ref,
) async {
  final repository = ref.watch(fuelEntryRepositoryProvider);
  return repository.getEntriesGroupedByCountry();
}

/// Provider for getting average consumption for a vehicle
@riverpod
Future<double?> averageConsumptionForVehicle(
  AverageConsumptionForVehicleRef ref,
  int vehicleId,
) async {
  final repository = ref.watch(fuelEntryRepositoryProvider);
  return repository.getAverageConsumptionForVehicle(vehicleId);
}