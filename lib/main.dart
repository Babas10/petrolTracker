import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/navigation/app_router.dart';

/// Main entry point for the Petrol Tracker application
/// 
/// This function starts the app with ephemeral (in-memory) data storage.
/// All data is temporary and will be lost when the app is restarted.
void main() {
  runApp(const ProviderScope(child: PetrolTrackerApp()));
}

/// Root application widget with ephemeral data storage
class PetrolTrackerApp extends StatelessWidget {
  const PetrolTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
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
    );
  }
}