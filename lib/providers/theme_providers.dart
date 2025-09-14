import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart' show ThemeData, ColorScheme, AppBarTheme, CardThemeData, FloatingActionButtonThemeData, TextTheme, TextStyle, Colors, RoundedRectangleBorder, BorderRadius, DividerThemeData, WidgetsBinding, Brightness, debugPrint;
import 'package:flutter/material.dart' as flutter show ThemeMode;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Temporarily commented out due to code generation issues
part 'theme_providers.g.dart';

/// Enum representing theme mode options
enum AppThemeMode {
  /// Follow system theme preference
  system,
  /// Always use light theme
  light,
  /// Always use dark theme
  dark,
}

/// Extension to convert AppThemeMode to Flutter's ThemeMode
extension AppThemeModeExtension on AppThemeMode {
  flutter.ThemeMode get flutterThemeMode {
    switch (this) {
      case AppThemeMode.system:
        return flutter.ThemeMode.system;
      case AppThemeMode.light:
        return flutter.ThemeMode.light;
      case AppThemeMode.dark:
        return flutter.ThemeMode.dark;
    }
  }
  
  String get displayName {
    switch (this) {
      case AppThemeMode.system:
        return 'Follow system';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }
}

/// Theme persistence service for storing user preferences
class ThemePersistenceService {
  static const String _fileName = 'theme_preferences.json';
  
  /// Get the theme preferences file
  static Future<File> _getThemeFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }
  
  /// Load theme preference from storage
  static Future<AppThemeMode> loadThemePreference() async {
    try {
      final file = await _getThemeFile();
      if (!await file.exists()) {
        return AppThemeMode.system; // Default to system
      }
      
      final contents = await file.readAsString();
      final data = jsonDecode(contents) as Map<String, dynamic>;
      final themeModeString = data['themeMode'] as String?;
      
      // Convert string back to enum
      switch (themeModeString) {
        case 'light':
          return AppThemeMode.light;
        case 'dark':
          return AppThemeMode.dark;
        case 'system':
        default:
          return AppThemeMode.system;
      }
    } catch (e) {
      // If there's any error loading, default to system
      debugPrint('Error loading theme preference: $e');
      return AppThemeMode.system;
    }
  }
  
  /// Save theme preference to storage
  static Future<void> saveThemePreference(AppThemeMode themeMode) async {
    try {
      final file = await _getThemeFile();
      final data = {
        'themeMode': themeMode.name,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
      // Don't throw - failing to save shouldn't crash the app
    }
  }
}

/// Provider for the current theme mode
@riverpod
class ThemeMode extends _$ThemeMode {
  @override
  Future<AppThemeMode> build() async {
    // Load saved theme preference on initialization
    return await ThemePersistenceService.loadThemePreference();
  }
  
  /// Change the theme mode and persist it
  Future<void> setThemeMode(AppThemeMode newThemeMode) async {
    // Update the state immediately for UI responsiveness
    state = AsyncValue.data(newThemeMode);
    
    // Persist the change
    await ThemePersistenceService.saveThemePreference(newThemeMode);
    
    // Provide haptic feedback
    if (newThemeMode != AppThemeMode.system) {
      HapticFeedback.selectionClick();
    }
  }
  
  /// Get the current theme mode synchronously (for UI)
  AppThemeMode get currentThemeMode {
    return state.value ?? AppThemeMode.system;
  }
}

/// Provider for comprehensive light theme configuration
@riverpod
ThemeData lightTheme(Ref ref) {
  // Watch theme mode to rebuild when it changes
  final themeMode = ref.watch(themeModeProvider);
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green, // Original seed color (0xFF4CAF50)
      brightness: Brightness.light,
      // Restore original Material Design 3 colors generated from Colors.green
      primary: const Color(0xFF366A3C), // Original MD3 green primary
      primaryContainer: const Color(0xFFB7F2BD), // Original MD3 green primary container
      secondary: const Color(0xFF526451), // Original MD3 green secondary
      secondaryContainer: const Color(0xFFD5E8D3), // Original MD3 green secondary container
      surface: const Color(0xFFFCFDF6), // Original MD3 surface
      surfaceContainer: const Color(0xFFF0F1EA), // Original MD3 surface container
      surfaceContainerHighest: const Color(0xFFE0E2DB), // Original MD3 surface container highest
    ),
    
    // Enhanced app bar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF366A3C), // Original MD3 primary color
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    
    // Card theme for consistent elevation
    cardTheme: CardThemeData(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Enhanced floating action button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF366A3C), // Original MD3 primary color
      foregroundColor: Colors.white,
      elevation: 4,
    ),
    
    // Enhanced text themes with original MD3 colors
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1D1B20), // Original MD3 on-surface
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1D1B20), // Original MD3 on-surface
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1D1B20), // Original MD3 on-surface
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFF1D1B20), // Original MD3 on-surface
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF49454F), // Original MD3 on-surface variant
      ),
    ),
  );
}

/// Provider for comprehensive dark theme configuration
@riverpod
ThemeData darkTheme(Ref ref) {
  // Watch theme mode to rebuild when it changes
  final themeMode = ref.watch(themeModeProvider);
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF10B981), // Green-500 (brighter for dark mode)
      brightness: Brightness.dark,
      // Override specific colors for dark mode with much darker surfaces
      primary: const Color(0xFF22C55E), // Brighter green for dark mode
      primaryContainer: const Color(0xFF065F46), // Green-800
      secondary: const Color(0xFF14B8A6), // Teal-500
      secondaryContainer: const Color(0xFF0F766E), // Teal-700
      surface: const Color(0xFF121212), // Standard dark surface
      surfaceContainer: const Color(0xFF1E1E1E), // Slightly lighter dark
      surfaceContainerHighest: const Color(0xFF2C2C2C), // Elevated surfaces
      onSurface: const Color(0xFFE1E1E1), // Light gray text
      onSurfaceVariant: const Color(0xFFBDBDBD), // Medium gray text
      background: const Color(0xFF121212), // Standard dark background
      onBackground: const Color(0xFFE1E1E1), // Light gray text on background
      // Make cards very dark
      surfaceVariant: const Color(0xFF1F1F1F),
    ),
    
    // Dark app bar theme with standard dark background
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F), // Standard dark app bar
      foregroundColor: Color(0xFFE1E1E1), // Light gray text
      elevation: 4,
      shadowColor: Colors.black26,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE1E1E1), // Light gray
      ),
    ),
    
    // Dark card theme with standard dark colors
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E), // Standard dark card color
      elevation: 4,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Dark scaffold background with standard dark color
    scaffoldBackgroundColor: const Color(0xFF121212), // Standard dark background
    
    // Dark floating action button
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF22C55E), // Brighter green for dark mode
      foregroundColor: Color(0xFF000000), // Dark text for contrast
      elevation: 6,
    ),
    
    // Dark text themes with standard colors
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Color(0xFFE1E1E1), // Standard light gray
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Color(0xFFE1E1E1), // Standard light gray
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Color(0xFFE1E1E1), // Standard light gray
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Color(0xFFBDBDBD), // Medium gray
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: Color(0xFF9E9E9E), // Slightly darker gray
      ),
    ),
    
    // Dark divider theme
    dividerTheme: const DividerThemeData(
      color: Color(0xFF424242), // Standard dark divider
      thickness: 1,
    ),
  );
}

/// Provider that returns the appropriate theme colors for charts
@riverpod
Map<String, String> chartThemeColors(Ref ref) {
  final themeMode = ref.watch(themeModeProvider);
  final currentPlatformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  
  // Determine if we should use dark colors
  final isDarkMode = themeMode.when(
    data: (mode) {
      switch (mode) {
        case AppThemeMode.dark:
          return true;
        case AppThemeMode.light:
          return false;
        case AppThemeMode.system:
          return currentPlatformBrightness == Brightness.dark;
      }
    },
    loading: () => currentPlatformBrightness == Brightness.dark,
    error: (_, __) => currentPlatformBrightness == Brightness.dark,
  );
  
  if (isDarkMode) {
    // Dark theme colors - standard dark mode
    return {
      'primaryColor': '#22C55E',      // Brighter green for dark mode
      'surfaceColor': '#121212',      // Standard dark surface
      'onSurfaceColor': '#E1E1E1',    // Light gray text
      'outlineColor': '#6E6E6E',      // Medium gray outlines
    };
  } else {
    // Light theme colors - restored original MD3 colors
    return {
      'primaryColor': '#366A3C',      // Original MD3 green primary
      'surfaceColor': '#FCFDF6',      // Original MD3 surface
      'onSurfaceColor': '#1D1B20',    // Original MD3 on-surface
      'outlineColor': '#79747E',      // Original MD3 outline
    };
  }
}