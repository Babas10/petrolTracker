import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/navigation/app_router.dart';
import 'package:petrol_tracker/screens/splash_screen.dart';
import 'package:petrol_tracker/screens/initialization_error_screen.dart';
import 'package:petrol_tracker/services/app_initialization_service.dart';
import 'package:petrol_tracker/providers/theme_providers.dart' hide ThemeMode;
import 'package:flutter/material.dart' as flutter show ThemeMode;

/// Main application widget that handles initialization flow
/// 
/// This widget manages the application startup sequence, displaying
/// appropriate screens based on the initialization state.
/// 
/// The app now supports dynamic theming with light/dark/system modes.
class PetrolTrackerApp extends ConsumerStatefulWidget {
  const PetrolTrackerApp({super.key});

  @override
  ConsumerState<PetrolTrackerApp> createState() => _PetrolTrackerAppState();
}

class _PetrolTrackerAppState extends ConsumerState<PetrolTrackerApp> {
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
    // Use a simple MaterialApp for the initialization flow
    // The actual theming will be handled by _MainApp
    return MaterialApp(
      title: 'Petrol Tracker',
      debugShowCheckedModeBanner: false,
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
}

/// Main application after successful initialization - now just returns router content
class _MainApp extends StatelessWidget {
  const _MainApp();

  @override
  Widget build(BuildContext context) {
    // Since main.dart handles theming, this just returns the router content
    return Router.withConfig(config: appRouter);
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