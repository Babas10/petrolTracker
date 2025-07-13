import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/navigation/app_router.dart';
import 'package:petrol_tracker/screens/splash_screen.dart';
import 'package:petrol_tracker/screens/initialization_error_screen.dart';
import 'package:petrol_tracker/services/app_initialization_service.dart';

/// Main application widget that handles initialization flow
/// 
/// This widget manages the application startup sequence, displaying
/// appropriate screens based on the initialization state.
class PetrolTrackerApp extends StatefulWidget {
  const PetrolTrackerApp({super.key});

  @override
  State<PetrolTrackerApp> createState() => _PetrolTrackerAppState();
}

class _PetrolTrackerAppState extends State<PetrolTrackerApp> {
  AppInitializationState _initializationState = AppInitializationState.initializing;
  AppInitializationException? _initializationError;
  
  @override
  void initState() {
    super.initState();
    _startInitialization();
  }
  
  Future<void> _startInitialization() async {
    setState(() {
      _initializationState = AppInitializationState.initializing;
      _initializationError = null;
    });
    
    try {
      await AppInitializationService.initialize();
      
      if (mounted) {
        setState(() {
          _initializationState = AppInitializationState.completed;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initializationState = AppInitializationState.failed;
          _initializationError = e is AppInitializationException 
              ? e 
              : AppInitializationException('Unknown error: $e');
        });
      }
    }
  }
  
  void _handleRetry() {
    _startInitialization();
  }
  
  void _handleExit() {
    SystemNavigator.pop();
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Petrol Tracker',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: _buildInitializationFlow(),
    );
  }
  
  Widget _buildInitializationFlow() {
    switch (_initializationState) {
      case AppInitializationState.initializing:
        return SplashScreen(
          onInitializationComplete: () {
            setState(() {
              _initializationState = AppInitializationState.completed;
            });
          },
          onInitializationError: (error) {
            setState(() {
              _initializationState = AppInitializationState.failed;
              _initializationError = error;
            });
          },
        );
        
      case AppInitializationState.failed:
        return InitializationErrorScreen(
          error: _initializationError!,
          onRetry: _handleRetry,
          onExit: _handleExit,
        );
        
      case AppInitializationState.completed:
        return const _MainApp();
    }
  }
  
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.light,
      ),
    );
  }
  
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
      ),
    );
  }
}

/// Main application after successful initialization
class _MainApp extends StatelessWidget {
  const _MainApp();

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        title: 'Petrol Tracker',
        debugShowCheckedModeBanner: false,
        theme: Theme.of(context),
        routerConfig: appRouter,
      ),
    );
  }
}

/// Enum representing the initialization state
enum AppInitializationState {
  /// App is currently initializing
  initializing,
  
  /// Initialization completed successfully
  completed,
  
  /// Initialization failed
  failed,
}