import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/navigation/app_router.dart';
import 'package:petrol_tracker/api/rest_api_provider.dart';
import 'package:petrol_tracker/debug/web_data_injector.dart';
import 'package:petrol_tracker/debug/web_auto_population.dart';

/// Main entry point for the Petrol Tracker application
/// 
/// This function starts the app with ephemeral (in-memory) data storage.
/// All data is temporary and will be lost when the app is restarted.
void main() {
  // Create a provider container for the entire app
  final container = ProviderContainer();
  
  // Set the global container for REST API to use the same data
  if (kDebugMode) {
    setGlobalContainer(container);
  }
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PetrolTrackerApp(),
    ),
  );
}

/// Root application widget with ephemeral data storage
class PetrolTrackerApp extends ConsumerWidget {
  const PetrolTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Start REST API server in debug mode on non-web platforms
    if (kDebugMode && !kIsWeb) {
      ref.watch(restApiServerProvider);
    }

    // Auto-populate data on web platform for development
    if (kDebugMode && kIsWeb) {
      ref.watch(webAutoPopulationProvider);
    }

    return MaterialApp.router(
        title: 'Petrol Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ),
        ),
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
        builder: (context, child) => WebDataInjector(child: child ?? const SizedBox()),
      );
  }
}