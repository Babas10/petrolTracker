// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vehicleHash() => r'3460a7847ad3dcb3c32a67771672be418b47de54';

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

/// Provider for getting a specific vehicle by ID
///
/// Copied from [vehicle].
@ProviderFor(vehicle)
const vehicleProvider = VehicleFamily();

/// Provider for getting a specific vehicle by ID
///
/// Copied from [vehicle].
class VehicleFamily extends Family<AsyncValue<VehicleModel?>> {
  /// Provider for getting a specific vehicle by ID
  ///
  /// Copied from [vehicle].
  const VehicleFamily();

  /// Provider for getting a specific vehicle by ID
  ///
  /// Copied from [vehicle].
  VehicleProvider call(int vehicleId) {
    return VehicleProvider(vehicleId);
  }

  @override
  VehicleProvider getProviderOverride(covariant VehicleProvider provider) {
    return call(provider.vehicleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'vehicleProvider';
}

/// Provider for getting a specific vehicle by ID
///
/// Copied from [vehicle].
class VehicleProvider extends AutoDisposeFutureProvider<VehicleModel?> {
  /// Provider for getting a specific vehicle by ID
  ///
  /// Copied from [vehicle].
  VehicleProvider(int vehicleId)
    : this._internal(
        (ref) => vehicle(ref as VehicleRef, vehicleId),
        from: vehicleProvider,
        name: r'vehicleProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$vehicleHash,
        dependencies: VehicleFamily._dependencies,
        allTransitiveDependencies: VehicleFamily._allTransitiveDependencies,
        vehicleId: vehicleId,
      );

  VehicleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.vehicleId,
  }) : super.internal();

  final int vehicleId;

  @override
  Override overrideWith(
    FutureOr<VehicleModel?> Function(VehicleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VehicleProvider._internal(
        (ref) => create(ref as VehicleRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        vehicleId: vehicleId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<VehicleModel?> createElement() {
    return _VehicleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VehicleProvider && other.vehicleId == vehicleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, vehicleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VehicleRef on AutoDisposeFutureProviderRef<VehicleModel?> {
  /// The parameter `vehicleId` of this provider.
  int get vehicleId;
}

class _VehicleProviderElement
    extends AutoDisposeFutureProviderElement<VehicleModel?>
    with VehicleRef {
  _VehicleProviderElement(super.provider);

  @override
  int get vehicleId => (origin as VehicleProvider).vehicleId;
}

String _$vehicleNameExistsHash() => r'34b3492c79609c9feb9b7755b1a09753a8b58629';

/// Provider for checking if a vehicle name exists
///
/// Copied from [vehicleNameExists].
@ProviderFor(vehicleNameExists)
const vehicleNameExistsProvider = VehicleNameExistsFamily();

/// Provider for checking if a vehicle name exists
///
/// Copied from [vehicleNameExists].
class VehicleNameExistsFamily extends Family<AsyncValue<bool>> {
  /// Provider for checking if a vehicle name exists
  ///
  /// Copied from [vehicleNameExists].
  const VehicleNameExistsFamily();

  /// Provider for checking if a vehicle name exists
  ///
  /// Copied from [vehicleNameExists].
  VehicleNameExistsProvider call(String vehicleName, {int? excludeId}) {
    return VehicleNameExistsProvider(vehicleName, excludeId: excludeId);
  }

  @override
  VehicleNameExistsProvider getProviderOverride(
    covariant VehicleNameExistsProvider provider,
  ) {
    return call(provider.vehicleName, excludeId: provider.excludeId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'vehicleNameExistsProvider';
}

/// Provider for checking if a vehicle name exists
///
/// Copied from [vehicleNameExists].
class VehicleNameExistsProvider extends AutoDisposeFutureProvider<bool> {
  /// Provider for checking if a vehicle name exists
  ///
  /// Copied from [vehicleNameExists].
  VehicleNameExistsProvider(String vehicleName, {int? excludeId})
    : this._internal(
        (ref) => vehicleNameExists(
          ref as VehicleNameExistsRef,
          vehicleName,
          excludeId: excludeId,
        ),
        from: vehicleNameExistsProvider,
        name: r'vehicleNameExistsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$vehicleNameExistsHash,
        dependencies: VehicleNameExistsFamily._dependencies,
        allTransitiveDependencies:
            VehicleNameExistsFamily._allTransitiveDependencies,
        vehicleName: vehicleName,
        excludeId: excludeId,
      );

  VehicleNameExistsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.vehicleName,
    required this.excludeId,
  }) : super.internal();

  final String vehicleName;
  final int? excludeId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(VehicleNameExistsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VehicleNameExistsProvider._internal(
        (ref) => create(ref as VehicleNameExistsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        vehicleName: vehicleName,
        excludeId: excludeId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _VehicleNameExistsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VehicleNameExistsProvider &&
        other.vehicleName == vehicleName &&
        other.excludeId == excludeId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, vehicleName.hashCode);
    hash = _SystemHash.combine(hash, excludeId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VehicleNameExistsRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `vehicleName` of this provider.
  String get vehicleName;

  /// The parameter `excludeId` of this provider.
  int? get excludeId;
}

class _VehicleNameExistsProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with VehicleNameExistsRef {
  _VehicleNameExistsProviderElement(super.provider);

  @override
  String get vehicleName => (origin as VehicleNameExistsProvider).vehicleName;
  @override
  int? get excludeId => (origin as VehicleNameExistsProvider).excludeId;
}

String _$vehicleCountHash() => r'ea60e68e5e77669104044bfd2614078d64dd01b1';

/// Provider for getting vehicle count
///
/// Copied from [vehicleCount].
@ProviderFor(vehicleCount)
final vehicleCountProvider = AutoDisposeFutureProvider<int>.internal(
  vehicleCount,
  name: r'vehicleCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$vehicleCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VehicleCountRef = AutoDisposeFutureProviderRef<int>;
String _$vehicleStatisticsHash() => r'637dc21f663b842a8c839012067947cba82ebccd';

/// Provider for getting vehicle statistics
///
/// Copied from [vehicleStatistics].
@ProviderFor(vehicleStatistics)
const vehicleStatisticsProvider = VehicleStatisticsFamily();

/// Provider for getting vehicle statistics
///
/// Copied from [vehicleStatistics].
class VehicleStatisticsFamily extends Family<AsyncValue<VehicleStatistics>> {
  /// Provider for getting vehicle statistics
  ///
  /// Copied from [vehicleStatistics].
  const VehicleStatisticsFamily();

  /// Provider for getting vehicle statistics
  ///
  /// Copied from [vehicleStatistics].
  VehicleStatisticsProvider call(int vehicleId) {
    return VehicleStatisticsProvider(vehicleId);
  }

  @override
  VehicleStatisticsProvider getProviderOverride(
    covariant VehicleStatisticsProvider provider,
  ) {
    return call(provider.vehicleId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'vehicleStatisticsProvider';
}

/// Provider for getting vehicle statistics
///
/// Copied from [vehicleStatistics].
class VehicleStatisticsProvider
    extends AutoDisposeFutureProvider<VehicleStatistics> {
  /// Provider for getting vehicle statistics
  ///
  /// Copied from [vehicleStatistics].
  VehicleStatisticsProvider(int vehicleId)
    : this._internal(
        (ref) => vehicleStatistics(ref as VehicleStatisticsRef, vehicleId),
        from: vehicleStatisticsProvider,
        name: r'vehicleStatisticsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$vehicleStatisticsHash,
        dependencies: VehicleStatisticsFamily._dependencies,
        allTransitiveDependencies:
            VehicleStatisticsFamily._allTransitiveDependencies,
        vehicleId: vehicleId,
      );

  VehicleStatisticsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.vehicleId,
  }) : super.internal();

  final int vehicleId;

  @override
  Override overrideWith(
    FutureOr<VehicleStatistics> Function(VehicleStatisticsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VehicleStatisticsProvider._internal(
        (ref) => create(ref as VehicleStatisticsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        vehicleId: vehicleId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<VehicleStatistics> createElement() {
    return _VehicleStatisticsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VehicleStatisticsProvider && other.vehicleId == vehicleId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, vehicleId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VehicleStatisticsRef on AutoDisposeFutureProviderRef<VehicleStatistics> {
  /// The parameter `vehicleId` of this provider.
  int get vehicleId;
}

class _VehicleStatisticsProviderElement
    extends AutoDisposeFutureProviderElement<VehicleStatistics>
    with VehicleStatisticsRef {
  _VehicleStatisticsProviderElement(super.provider);

  @override
  int get vehicleId => (origin as VehicleStatisticsProvider).vehicleId;
}

String _$vehiclesWithStatsHash() => r'02822d7378a0801b76700646ae79845596b42342';

/// Provider for getting vehicles with basic statistics
///
/// Copied from [vehiclesWithStats].
@ProviderFor(vehiclesWithStats)
final vehiclesWithStatsProvider =
    AutoDisposeFutureProvider<List<Map<String, dynamic>>>.internal(
      vehiclesWithStats,
      name: r'vehiclesWithStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$vehiclesWithStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VehiclesWithStatsRef =
    AutoDisposeFutureProviderRef<List<Map<String, dynamic>>>;
String _$ephemeralStorageHealthHash() =>
    r'c44eace610caaf06d032e436adc2140925e03fdc';

/// Provider for checking ephemeral storage health
///
/// Copied from [ephemeralStorageHealth].
@ProviderFor(ephemeralStorageHealth)
final ephemeralStorageHealthProvider = AutoDisposeFutureProvider<bool>.internal(
  ephemeralStorageHealth,
  name: r'ephemeralStorageHealthProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ephemeralStorageHealthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EphemeralStorageHealthRef = AutoDisposeFutureProviderRef<bool>;
String _$vehiclesNotifierHash() => r'aade0e2a5a71969fab5edcba067c96d0c3cd7b34';

/// Notifier for managing vehicles state
///
/// Copied from [VehiclesNotifier].
@ProviderFor(VehiclesNotifier)
final vehiclesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<VehiclesNotifier, VehicleState>.internal(
      VehiclesNotifier.new,
      name: r'vehiclesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$vehiclesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VehiclesNotifier = AutoDisposeAsyncNotifier<VehicleState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
