// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_currency_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localCurrencyConverterHash() =>
    r'8ac6f900f8b83e339885506aac27f97256171292';

/// Provider for the local currency converter singleton
///
/// Provides access to the enhanced local currency conversion system
/// with advanced caching, fallback strategies, and batch operations.
///
/// Copied from [localCurrencyConverter].
@ProviderFor(localCurrencyConverter)
final localCurrencyConverterProvider =
    AutoDisposeProvider<LocalCurrencyConverter>.internal(
      localCurrencyConverter,
      name: r'localCurrencyConverterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$localCurrencyConverterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LocalCurrencyConverterRef =
    AutoDisposeProviderRef<LocalCurrencyConverter>;
String _$exchangeRateCacheHash() => r'2ebd96c5fe2cd78647ba966a3ec51745f852caa6';

/// Provider for the exchange rate cache singleton
///
/// Provides access to the advanced exchange rate caching system
/// with intelligent management and performance monitoring.
///
/// Copied from [exchangeRateCache].
@ProviderFor(exchangeRateCache)
final exchangeRateCacheProvider =
    AutoDisposeProvider<ExchangeRateCache>.internal(
      exchangeRateCache,
      name: r'exchangeRateCacheProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$exchangeRateCacheHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ExchangeRateCacheRef = AutoDisposeProviderRef<ExchangeRateCache>;
String _$canConvertLocallyHash() => r'6912db26aecfecf47a7ed42ea04e68acc39ef69f';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for checking if local conversion is available between two currencies
///
/// This is useful for UI components to show/hide conversion features
/// based on actual rate availability.
///
/// Copied from [canConvertLocally].
@ProviderFor(canConvertLocally)
const canConvertLocallyProvider = CanConvertLocallyFamily();

/// Provider for checking if local conversion is available between two currencies
///
/// This is useful for UI components to show/hide conversion features
/// based on actual rate availability.
///
/// Copied from [canConvertLocally].
class CanConvertLocallyFamily extends Family<AsyncValue<bool>> {
  /// Provider for checking if local conversion is available between two currencies
  ///
  /// This is useful for UI components to show/hide conversion features
  /// based on actual rate availability.
  ///
  /// Copied from [canConvertLocally].
  const CanConvertLocallyFamily();

  /// Provider for checking if local conversion is available between two currencies
  ///
  /// This is useful for UI components to show/hide conversion features
  /// based on actual rate availability.
  ///
  /// Copied from [canConvertLocally].
  CanConvertLocallyProvider call(String fromCurrency, String toCurrency) {
    return CanConvertLocallyProvider(fromCurrency, toCurrency);
  }

  @override
  CanConvertLocallyProvider getProviderOverride(
    covariant CanConvertLocallyProvider provider,
  ) {
    return call(provider.fromCurrency, provider.toCurrency);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'canConvertLocallyProvider';
}

/// Provider for checking if local conversion is available between two currencies
///
/// This is useful for UI components to show/hide conversion features
/// based on actual rate availability.
///
/// Copied from [canConvertLocally].
class CanConvertLocallyProvider extends AutoDisposeFutureProvider<bool> {
  /// Provider for checking if local conversion is available between two currencies
  ///
  /// This is useful for UI components to show/hide conversion features
  /// based on actual rate availability.
  ///
  /// Copied from [canConvertLocally].
  CanConvertLocallyProvider(String fromCurrency, String toCurrency)
    : this._internal(
        (ref) => canConvertLocally(
          ref as CanConvertLocallyRef,
          fromCurrency,
          toCurrency,
        ),
        from: canConvertLocallyProvider,
        name: r'canConvertLocallyProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$canConvertLocallyHash,
        dependencies: CanConvertLocallyFamily._dependencies,
        allTransitiveDependencies:
            CanConvertLocallyFamily._allTransitiveDependencies,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      );

  CanConvertLocallyProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.fromCurrency,
    required this.toCurrency,
  }) : super.internal();

  final String fromCurrency;
  final String toCurrency;

  @override
  Override overrideWith(
    FutureOr<bool> Function(CanConvertLocallyRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CanConvertLocallyProvider._internal(
        (ref) => create(ref as CanConvertLocallyRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _CanConvertLocallyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CanConvertLocallyProvider &&
        other.fromCurrency == fromCurrency &&
        other.toCurrency == toCurrency;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, fromCurrency.hashCode);
    hash = _SystemHash.combine(hash, toCurrency.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CanConvertLocallyRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `fromCurrency` of this provider.
  String get fromCurrency;

  /// The parameter `toCurrency` of this provider.
  String get toCurrency;
}

class _CanConvertLocallyProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with CanConvertLocallyRef {
  _CanConvertLocallyProviderElement(super.provider);

  @override
  String get fromCurrency => (origin as CanConvertLocallyProvider).fromCurrency;
  @override
  String get toCurrency => (origin as CanConvertLocallyProvider).toCurrency;
}

String _$availableRatesHash() => r'bbaa43f6c1d0baccb17270706725dd3b36056921';

/// Provider for getting available exchange rates for a base currency
///
/// Returns all cached exchange rates for the specified currency.
/// Useful for displaying available conversion options to users.
///
/// Copied from [availableRates].
@ProviderFor(availableRates)
const availableRatesProvider = AvailableRatesFamily();

/// Provider for getting available exchange rates for a base currency
///
/// Returns all cached exchange rates for the specified currency.
/// Useful for displaying available conversion options to users.
///
/// Copied from [availableRates].
class AvailableRatesFamily extends Family<AsyncValue<Map<String, double>>> {
  /// Provider for getting available exchange rates for a base currency
  ///
  /// Returns all cached exchange rates for the specified currency.
  /// Useful for displaying available conversion options to users.
  ///
  /// Copied from [availableRates].
  const AvailableRatesFamily();

  /// Provider for getting available exchange rates for a base currency
  ///
  /// Returns all cached exchange rates for the specified currency.
  /// Useful for displaying available conversion options to users.
  ///
  /// Copied from [availableRates].
  AvailableRatesProvider call(String baseCurrency) {
    return AvailableRatesProvider(baseCurrency);
  }

  @override
  AvailableRatesProvider getProviderOverride(
    covariant AvailableRatesProvider provider,
  ) {
    return call(provider.baseCurrency);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'availableRatesProvider';
}

/// Provider for getting available exchange rates for a base currency
///
/// Returns all cached exchange rates for the specified currency.
/// Useful for displaying available conversion options to users.
///
/// Copied from [availableRates].
class AvailableRatesProvider
    extends AutoDisposeFutureProvider<Map<String, double>> {
  /// Provider for getting available exchange rates for a base currency
  ///
  /// Returns all cached exchange rates for the specified currency.
  /// Useful for displaying available conversion options to users.
  ///
  /// Copied from [availableRates].
  AvailableRatesProvider(String baseCurrency)
    : this._internal(
        (ref) => availableRates(ref as AvailableRatesRef, baseCurrency),
        from: availableRatesProvider,
        name: r'availableRatesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$availableRatesHash,
        dependencies: AvailableRatesFamily._dependencies,
        allTransitiveDependencies:
            AvailableRatesFamily._allTransitiveDependencies,
        baseCurrency: baseCurrency,
      );

  AvailableRatesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.baseCurrency,
  }) : super.internal();

  final String baseCurrency;

  @override
  Override overrideWith(
    FutureOr<Map<String, double>> Function(AvailableRatesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AvailableRatesProvider._internal(
        (ref) => create(ref as AvailableRatesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        baseCurrency: baseCurrency,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, double>> createElement() {
    return _AvailableRatesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailableRatesProvider &&
        other.baseCurrency == baseCurrency;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, baseCurrency.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AvailableRatesRef on AutoDisposeFutureProviderRef<Map<String, double>> {
  /// The parameter `baseCurrency` of this provider.
  String get baseCurrency;
}

class _AvailableRatesProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, double>>
    with AvailableRatesRef {
  _AvailableRatesProviderElement(super.provider);

  @override
  String get baseCurrency => (origin as AvailableRatesProvider).baseCurrency;
}

String _$cacheHealthHash() => r'1ac1bedfe3c75dd5b9a3a62eec9e6a59ac4de8b6';

/// Provider for cache health monitoring
///
/// Provides real-time information about the health of the currency cache.
/// Useful for displaying cache status in admin/debug screens.
///
/// Copied from [cacheHealth].
@ProviderFor(cacheHealth)
final cacheHealthProvider =
    AutoDisposeFutureProvider<CacheHealthReport>.internal(
      cacheHealth,
      name: r'cacheHealthProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cacheHealthHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CacheHealthRef = AutoDisposeFutureProviderRef<CacheHealthReport>;
String _$cacheStatisticsHash() => r'50192c93471424a3469503da7be43547c78109a5';

/// Provider for cache statistics
///
/// Provides detailed statistics about cache usage and performance.
/// Useful for monitoring and optimization.
///
/// Copied from [cacheStatistics].
@ProviderFor(cacheStatistics)
final cacheStatisticsProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
      cacheStatistics,
      name: r'cacheStatisticsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cacheStatisticsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CacheStatisticsRef = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
