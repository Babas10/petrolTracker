import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/navigation/app_router.dart';
import 'package:petrol_tracker/api/rest_api_provider.dart';
import 'package:petrol_tracker/debug/web_data_injector.dart';
import 'package:petrol_tracker/debug/web_auto_population.dart';
import 'package:petrol_tracker/providers/theme_providers.dart' hide ThemeMode;
import 'package:flutter/material.dart' as flutter show ThemeMode;

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

    // Auto-populate data for development (all platforms in debug mode)
    if (kDebugMode) {
      ref.watch(webAutoPopulationProvider);
    }

    // Watch the theme providers for dynamic theming
    final themeMode = ref.watch(themeModeProvider);
    final lightTheme = ref.watch(lightThemeProvider);
    final darkTheme = ref.watch(darkThemeProvider);

    return MaterialApp.router(
        title: 'Petrol Tracker',
        debugShowCheckedModeBanner: false,
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: themeMode.when(
          data: (mode) => mode.flutterThemeMode,
          loading: () => flutter.ThemeMode.system,
          error: (_, __) => flutter.ThemeMode.system,
        ),
        routerConfig: appRouter,
        builder: (context, child) => WebDataInjector(child: child ?? const SizedBox()),
      );
  }
}