import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/api/rest_api_service.dart';

/// Global container reference for the REST API
/// This will be set by the main app to ensure data sharing
ProviderContainer? _globalContainer;

void setGlobalContainer(ProviderContainer container) {
  _globalContainer = container;
}

/// Provider for the REST API Service
/// This is a singleton that starts the server on first access
final restApiServiceProvider = Provider<RestApiService>((ref) {
  // Use the global container that the app is using
  final container = _globalContainer ?? ref.container;
  return RestApiService(container: container);
});

/// Provider for starting the REST API server
/// This provider manages the lifecycle of the REST API server
final restApiServerProvider = FutureProvider<void>((ref) async {
  final service = ref.read(restApiServiceProvider);
  await service.start();
  
  // Cleanup when provider is disposed
  ref.onDispose(() async {
    await service.stop();
  });
});

/// Provider for checking if REST API is available
final restApiAvailableProvider = Provider<bool>((ref) {
  // Only available in debug mode AND on non-web platforms
  bool isDebug = false;
  assert(() {
    isDebug = true;
    return true;
  }());
  
  // Import kIsWeb from foundation
  const bool isWeb = kIsWeb;
  
  return isDebug && !isWeb;
});