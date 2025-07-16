import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';

part 'fuel_entry_providers.g.dart';

/// Ephemeral in-memory storage for fuel entries (all platforms)
final Map<int, FuelEntryModel> _ephemeralFuelEntryStorage = <int, FuelEntryModel>{};
int _ephemeralFuelEntryIdCounter = 1;

/// Get next available ID for ephemeral fuel entry storage
int _getNextEphemeralFuelEntryId() {
  return _ephemeralFuelEntryIdCounter++;
}

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

  /// Load all fuel entries from ephemeral storage
  Future<FuelEntryState> _loadFuelEntries() async {
    try {
      final entries = _ephemeralFuelEntryStorage.values.toList();
      // Sort by date descending (newest first)
      entries.sort((a, b) => b.date.compareTo(a.date));
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
      // Add to ephemeral storage
      final id = _getNextEphemeralFuelEntryId();
      final newEntry = entry.copyWith(id: id);
      _ephemeralFuelEntryStorage[id] = newEntry;
      
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
      // Update in ephemeral storage
      _ephemeralFuelEntryStorage[entry.id!] = entry;
      
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
      // Remove from ephemeral storage
      _ephemeralFuelEntryStorage.remove(entryId);
      
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
    return 'An unexpected error occurred: ${error.toString()}';
  }
}

/// Provider for getting fuel entries by vehicle
@riverpod
Future<List<FuelEntryModel>> fuelEntriesByVehicle(
  FuelEntriesByVehicleRef ref,
  int vehicleId,
) async {
  final allEntries = _ephemeralFuelEntryStorage.values.toList();
  final filteredEntries = allEntries.where((entry) => entry.vehicleId == vehicleId).toList();
  // Sort by date descending (newest first)
  filteredEntries.sort((a, b) => b.date.compareTo(a.date));
  return filteredEntries;
}

/// Provider for getting fuel entries by date range
@riverpod
Future<List<FuelEntryModel>> fuelEntriesByDateRange(
  FuelEntriesByDateRangeRef ref,
  DateTime startDate,
  DateTime endDate,
) async {
  final allEntries = _ephemeralFuelEntryStorage.values.toList();
  final filteredEntries = allEntries.where((entry) => 
    entry.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
    entry.date.isBefore(endDate.add(const Duration(days: 1)))
  ).toList();
  // Sort by date descending (newest first)
  filteredEntries.sort((a, b) => b.date.compareTo(a.date));
  return filteredEntries;
}

/// Provider for getting fuel entries by vehicle and date range
@riverpod
Future<List<FuelEntryModel>> fuelEntriesByVehicleAndDateRange(
  FuelEntriesByVehicleAndDateRangeRef ref,
  int vehicleId,
  DateTime startDate,
  DateTime endDate,
) async {
  final allEntries = _ephemeralFuelEntryStorage.values.toList();
  final filteredEntries = allEntries.where((entry) => 
    entry.vehicleId == vehicleId &&
    entry.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
    entry.date.isBefore(endDate.add(const Duration(days: 1)))
  ).toList();
  // Sort by date descending (newest first)
  filteredEntries.sort((a, b) => b.date.compareTo(a.date));
  return filteredEntries;
}

/// Provider for getting the latest fuel entry for a vehicle
@riverpod
Future<FuelEntryModel?> latestFuelEntryForVehicle(
  LatestFuelEntryForVehicleRef ref,
  int vehicleId,
) async {
  final allEntries = _ephemeralFuelEntryStorage.values.toList();
  final vehicleEntries = allEntries.where((entry) => entry.vehicleId == vehicleId).toList();
  if (vehicleEntries.isEmpty) return null;
  
  // Sort by date descending and return the first (latest)
  vehicleEntries.sort((a, b) => b.date.compareTo(a.date));
  return vehicleEntries.first;
}

/// Provider for getting a specific fuel entry by ID
@riverpod
Future<FuelEntryModel?> fuelEntry(FuelEntryRef ref, int entryId) async {
  return _ephemeralFuelEntryStorage[entryId];
}

/// Provider for getting fuel entry count
@riverpod
Future<int> fuelEntryCount(FuelEntryCountRef ref) async {
  return _ephemeralFuelEntryStorage.length;
}

/// Provider for getting fuel entry count for a specific vehicle
@riverpod
Future<int> fuelEntryCountForVehicle(
  FuelEntryCountForVehicleRef ref,
  int vehicleId,
) async {
  final allEntries = _ephemeralFuelEntryStorage.values;
  return allEntries.where((entry) => entry.vehicleId == vehicleId).length;
}

/// Provider for getting fuel entries grouped by country
@riverpod
Future<Map<String, List<FuelEntryModel>>> fuelEntriesGroupedByCountry(
  FuelEntriesGroupedByCountryRef ref,
) async {
  final allEntries = _ephemeralFuelEntryStorage.values.toList();
  final Map<String, List<FuelEntryModel>> groupedEntries = {};
  
  for (final entry in allEntries) {
    final country = entry.country;
    if (!groupedEntries.containsKey(country)) {
      groupedEntries[country] = [];
    }
    groupedEntries[country]!.add(entry);
  }
  
  // Sort each country's entries by date descending
  for (final entries in groupedEntries.values) {
    entries.sort((a, b) => b.date.compareTo(a.date));
  }
  
  return groupedEntries;
}

/// Provider for getting average consumption for a vehicle
@riverpod
Future<double?> averageConsumptionForVehicle(
  AverageConsumptionForVehicleRef ref,
  int vehicleId,
) async {
  final allEntries = _ephemeralFuelEntryStorage.values.toList();
  final vehicleEntries = allEntries.where((entry) => 
    entry.vehicleId == vehicleId && entry.consumption != null
  ).toList();
  
  if (vehicleEntries.isEmpty) return null;
  
  final totalConsumption = vehicleEntries
      .map((entry) => entry.consumption!)
      .reduce((a, b) => a + b);
  
  return totalConsumption / vehicleEntries.length;
}