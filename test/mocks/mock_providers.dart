import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:petrol_tracker/models/vehicle_model.dart';
import 'package:petrol_tracker/providers/units_providers.dart';

// Mock for vehicle provider that returns AsyncValue
class MockVehicleProvider extends StateNotifier<AsyncValue<VehicleModel?>> {
  MockVehicleProvider(VehicleModel? vehicle) : super(AsyncValue.data(vehicle));
  
  void setVehicle(VehicleModel? vehicle) {
    state = AsyncValue.data(vehicle);
  }
  
  void setLoading() {
    state = const AsyncValue.loading();
  }
  
  void setError(Object error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }
}

// Mock for units provider
class MockUnitsProvider extends StateNotifier<AsyncValue<UnitSystem>> {
  MockUnitsProvider(UnitSystem unitSystem) : super(AsyncValue.data(unitSystem));
  
  void setUnitSystem(UnitSystem unitSystem) {
    state = AsyncValue.data(unitSystem);
  }
  
  void setLoading() {
    state = const AsyncValue.loading();
  }
  
  void setError(Object error, StackTrace stackTrace) {
    state = AsyncValue.error(error, stackTrace);
  }
}

// Mock for currency provider
class MockPrimaryCurrencyNotifier extends StateNotifier<String> {
  MockPrimaryCurrencyNotifier(String currency) : super(currency);
  
  void setCurrency(String currency) {
    state = currency;
  }
}