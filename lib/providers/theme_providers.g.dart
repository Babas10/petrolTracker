// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the current theme mode

@ProviderFor(ThemeMode)
const themeModeProvider = ThemeModeProvider._();

/// Provider for the current theme mode
final class ThemeModeProvider
    extends $AsyncNotifierProvider<ThemeMode, AppThemeMode> {
  /// Provider for the current theme mode
  const ThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeHash();

  @$internal
  @override
  ThemeMode create() => ThemeMode();
}

String _$themeModeHash() => r'1c525d6157bc55d35e564fde1f2c4c912cc76cda';

/// Provider for the current theme mode

abstract class _$ThemeMode extends $AsyncNotifier<AppThemeMode> {
  FutureOr<AppThemeMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<AppThemeMode>, AppThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppThemeMode>, AppThemeMode>,
              AsyncValue<AppThemeMode>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for comprehensive light theme configuration

@ProviderFor(lightTheme)
const lightThemeProvider = LightThemeProvider._();

/// Provider for comprehensive light theme configuration

final class LightThemeProvider
    extends $FunctionalProvider<ThemeData, ThemeData, ThemeData>
    with $Provider<ThemeData> {
  /// Provider for comprehensive light theme configuration
  const LightThemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lightThemeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lightThemeHash();

  @$internal
  @override
  $ProviderElement<ThemeData> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeData create(Ref ref) {
    return lightTheme(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeData>(value),
    );
  }
}

String _$lightThemeHash() => r'288b1ea5851f16f19b3f92cc6149f36b36f1cbac';

/// Provider for comprehensive dark theme configuration

@ProviderFor(darkTheme)
const darkThemeProvider = DarkThemeProvider._();

/// Provider for comprehensive dark theme configuration

final class DarkThemeProvider
    extends $FunctionalProvider<ThemeData, ThemeData, ThemeData>
    with $Provider<ThemeData> {
  /// Provider for comprehensive dark theme configuration
  const DarkThemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'darkThemeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$darkThemeHash();

  @$internal
  @override
  $ProviderElement<ThemeData> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeData create(Ref ref) {
    return darkTheme(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeData>(value),
    );
  }
}

String _$darkThemeHash() => r'3c42c798789b4f29efac53cc6d45e87411c2d2d3';

/// Provider that returns the appropriate theme colors for charts

@ProviderFor(chartThemeColors)
const chartThemeColorsProvider = ChartThemeColorsProvider._();

/// Provider that returns the appropriate theme colors for charts

final class ChartThemeColorsProvider
    extends
        $FunctionalProvider<
          Map<String, String>,
          Map<String, String>,
          Map<String, String>
        >
    with $Provider<Map<String, String>> {
  /// Provider that returns the appropriate theme colors for charts
  const ChartThemeColorsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chartThemeColorsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chartThemeColorsHash();

  @$internal
  @override
  $ProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, String> create(Ref ref) {
    return chartThemeColors(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, String>>(value),
    );
  }
}

String _$chartThemeColorsHash() => r'ef60b11b76a080ba019a95b2968ec800ed462fe1';
