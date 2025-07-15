import 'package:flutter/material.dart';
import 'package:petrol_tracker/services/app_initialization_service.dart';

/// Splash screen displayed during app initialization
/// 
/// This screen provides visual feedback to users while the app is loading
/// and initializing critical services like the database. It shows progress
/// indicators, status messages, and handles any initialization errors.
class SplashScreen extends StatefulWidget {
  /// Callback when initialization completes successfully
  final VoidCallback? onInitializationComplete;
  
  /// Callback when initialization fails
  final Function(AppInitializationException)? onInitializationError;
  
  const SplashScreen({
    super.key,
    this.onInitializationComplete,
    this.onInitializationError,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _progressOpacity;
  
  String _currentMessage = 'Starting application...';
  double _progress = 0.0;
  bool _hasError = false;
  AppInitializationException? _error;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startInitialization();
  }
  
  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    super.dispose();
  }
  
  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _logoScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
    ));
    
    _progressOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeIn,
    ));
    
    // Start logo animation
    _logoController.forward();
    
    // Start progress animation after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }
  
  Future<void> _startInitialization() async {
    try {
      await AppInitializationService.initialize(
        onProgress: (message, progress) {
          if (mounted) {
            setState(() {
              _currentMessage = message;
              _progress = progress;
            });
          }
        },
      );
      
      // Wait a bit to show completion
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        widget.onInitializationComplete?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _error = e is AppInitializationException 
              ? e 
              : AppInitializationException('Unknown error: $e');
        });
        widget.onInitializationError?.call(_error!);
      }
    }
  }
  
  Future<void> _retryInitialization() async {
    setState(() {
      _hasError = false;
      _error = null;
      _progress = 0.0;
      _currentMessage = 'Retrying initialization...';
    });
    
    await _startInitialization();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // App Logo
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: _buildLogo(context),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 48),
              
              // App Name
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Text(
                      'Petrol Tracker',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Tagline
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value * 0.8,
                    child: Text(
                      'Track your fuel consumption',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              
              const Spacer(flex: 1),
              
              // Progress Section
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _progressOpacity.value,
                    child: _hasError 
                        ? _buildErrorSection(context)
                        : _buildProgressSection(context),
                  );
                },
              ),
              
              const Spacer(flex: 1),
              
              // Version Info
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _progressOpacity.value * 0.6,
                    child: Text(
                      'Version 1.0.0',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLogo(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.onPrimary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.local_gas_station,
        size: 60,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
  
  Widget _buildProgressSection(BuildContext context) {
    return Column(
      children: [
        // Progress Indicator
        SizedBox(
          width: double.infinity,
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.onPrimary,
            ),
            minHeight: 4,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Status Message
        Text(
          _currentMessage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        // Progress Percentage
        Text(
          '${(_progress * 100).toInt()}%',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
  
  Widget _buildErrorSection(BuildContext context) {
    return Column(
      children: [
        // Error Icon
        Icon(
          Icons.error_outline,
          size: 48,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        
        const SizedBox(height: 16),
        
        // Error Title
        Text(
          'Initialization Failed',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        // Error Message
        Text(
          _error?.userFriendlyMessage ?? 'An unknown error occurred',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
        
        if (_error?.recoveryHint != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!.recoveryHint!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
        
        const SizedBox(height: 24),
        
        // Retry Button
        if (_error?.canRetry == true)
          ElevatedButton.icon(
            onPressed: _retryInitialization,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
      ],
    );
  }
}

/// Simple splash screen for immediate display while setting up the animated version
class SimpleSplashScreen extends StatelessWidget {
  const SimpleSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Icon(
                Icons.local_gas_station,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Petrol Tracker',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}