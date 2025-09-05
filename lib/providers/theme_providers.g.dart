// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lightThemeHash() => r'2916a6dade0511569853d07cdb5bcbffda4b597e';

/// Provider for comprehensive light theme configuration
///
/// Copied from [lightTheme].
@ProviderFor(lightTheme)
final lightThemeProvider = AutoDisposeProvider<ThemeData>.internal(
  lightTheme,
  name: r'lightThemeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lightThemeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LightThemeRef = AutoDisposeProviderRef<ThemeData>;
String _$darkThemeHash() => r'd25429f73bca3d201992967cb60b89e0d9a81e6b';

/// Provider for comprehensive dark theme configuration
///
/// Copied from [darkTheme].
@ProviderFor(darkTheme)
final darkThemeProvider = AutoDisposeProvider<ThemeData>.internal(
  darkTheme,
  name: r'darkThemeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$darkThemeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DarkThemeRef = AutoDisposeProviderRef<ThemeData>;
String _$chartThemeColorsHash() => r'7e7ef820125087a32f3bd356cccf3ac43da28905';

/// Provider that returns the appropriate theme colors for charts
///
/// Copied from [chartThemeColors].
@ProviderFor(chartThemeColors)
final chartThemeColorsProvider =
    AutoDisposeProvider<Map<String, String>>.internal(
      chartThemeColors,
      name: r'chartThemeColorsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chartThemeColorsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChartThemeColorsRef = AutoDisposeProviderRef<Map<String, String>>;
String _$themeModeHash() => r'9ad4935da91bab626faecbbfac4e04d736140730';

/// Provider for the current theme mode
///
/// Copied from [ThemeMode].
@ProviderFor(ThemeMode)
final themeModeProvider =
    AutoDisposeAsyncNotifierProvider<ThemeMode, AppThemeMode>.internal(
      ThemeMode.new,
      name: r'themeModeProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$themeModeHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ThemeMode = AutoDisposeAsyncNotifier<AppThemeMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
