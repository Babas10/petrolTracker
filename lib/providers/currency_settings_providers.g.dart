// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$currencySettingsRepositoryHash() =>
    r'bc782149deac2a32e846c0f4e76af4c611e38763';

/// Provider for the currency settings repository
///
/// Copied from [currencySettingsRepository].
@ProviderFor(currencySettingsRepository)
final currencySettingsRepositoryProvider =
    AutoDisposeProvider<CurrencySettingsRepository>.internal(
      currencySettingsRepository,
      name: r'currencySettingsRepositoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currencySettingsRepositoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrencySettingsRepositoryRef =
    AutoDisposeProviderRef<CurrencySettingsRepository>;
String _$primaryCurrencyHash() => r'be3dbf9202964f50766c23e3593a38a4f3aaee7c';

/// Provider for just the primary currency
///
/// Convenient provider for accessing just the primary currency without
/// loading the full settings object. Automatically updates when settings change.
///
/// Copied from [primaryCurrency].
@ProviderFor(primaryCurrency)
final primaryCurrencyProvider = AutoDisposeFutureProvider<String>.internal(
  primaryCurrency,
  name: r'primaryCurrencyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$primaryCurrencyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PrimaryCurrencyRef = AutoDisposeFutureProviderRef<String>;
String _$isFirstTimeUserHash() => r'2a824df7a22871aee7af4e5c3c76eaca48271239';

/// Provider for checking if this is a first-time user
///
/// Returns true if no currency settings have been stored yet.
/// Useful for showing onboarding or default currency selection.
///
/// Copied from [isFirstTimeUser].
@ProviderFor(isFirstTimeUser)
final isFirstTimeUserProvider = AutoDisposeFutureProvider<bool>.internal(
  isFirstTimeUser,
  name: r'isFirstTimeUserProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isFirstTimeUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsFirstTimeUserRef = AutoDisposeFutureProviderRef<bool>;
String _$currencyDisplayPreferencesHash() =>
    r'22ce755df76b0c9c35eb2706e562f991f8102db6';

/// Provider for currency display preferences
///
/// Extracts just the display-related settings for UI components.
///
/// Copied from [currencyDisplayPreferences].
@ProviderFor(currencyDisplayPreferences)
final currencyDisplayPreferencesProvider =
    AutoDisposeFutureProvider<CurrencyDisplayPreferences>.internal(
      currencyDisplayPreferences,
      name: r'currencyDisplayPreferencesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currencyDisplayPreferencesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrencyDisplayPreferencesRef =
    AutoDisposeFutureProviderRef<CurrencyDisplayPreferences>;
String _$currencySettingsNotifierHash() =>
    r'1e1e46272073b8bf349a602027eeef72a3d4d60e';

/// Provider for currency settings state management
///
/// Manages the user's currency preferences including primary currency,
/// display options, and persistence. Provides methods for updating
/// settings with automatic validation and persistence.
///
/// Copied from [CurrencySettingsNotifier].
@ProviderFor(CurrencySettingsNotifier)
final currencySettingsNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      CurrencySettingsNotifier,
      CurrencySettings
    >.internal(
      CurrencySettingsNotifier.new,
      name: r'currencySettingsNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currencySettingsNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrencySettingsNotifier = AutoDisposeAsyncNotifier<CurrencySettings>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
