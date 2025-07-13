// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_entry_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fuelEntriesByVehicleHash() =>
    r'e87c2dcef1d7dc563431618097ba20f2b9c6128f';

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

/// Provider for getting fuel entries by vehicle
///
/// Copied from [fuelEntriesByVehicle].
@ProviderFor(fuelEntriesByVehicle)
const fuelEntriesByVehicleProvider = FuelEntriesByVehicleFamily();

/// Provider for getting fuel entries by vehicle
///
/// Copied from [fuelEntriesByVehicle].
class FuelEntriesByVehicleFamily
    extends Family<AsyncValue<List<FuelEntryModel>>> {
  /// Provider for getting fuel entries by vehicle
  ///
  /// Copied from [fuelEntriesByVehicle].
  const FuelEntriesByVehicleFamily();

  /// Provider for getting fuel entries by vehicle
  ///
  /// Copied from [fuelEntriesByVehicle].
  FuelEntriesByVehicleProvider call(int vehicleId) {
    return FuelEntriesByVehicleProvider(vehicleId);
  }

  @override
  FuelEntriesByVehicleProvider getProviderOverride(
    covariant FuelEntriesByVehicleProvider provider,
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
  String? get name => r'fuelEntriesByVehicleProvider';
}

/// Provider for getting fuel entries by vehicle
///
/// Copied from [fuelEntriesByVehicle].
class FuelEntriesByVehicleProvider
    extends AutoDisposeFutureProvider<List<FuelEntryModel>> {
  /// Provider for getting fuel entries by vehicle
  ///
  /// Copied from [fuelEntriesByVehicle].
  FuelEntriesByVehicleProvider(int vehicleId)
    : this._internal(
        (ref) =>
            fuelEntriesByVehicle(ref as FuelEntriesByVehicleRef, vehicleId),
        from: fuelEntriesByVehicleProvider,
        name: r'fuelEntriesByVehicleProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fuelEntriesByVehicleHash,
        dependencies: FuelEntriesByVehicleFamily._dependencies,
        allTransitiveDependencies:
            FuelEntriesByVehicleFamily._allTransitiveDependencies,
        vehicleId: vehicleId,
      );

  FuelEntriesByVehicleProvider._internal(
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
    FutureOr<List<FuelEntryModel>> Function(FuelEntriesByVehicleRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FuelEntriesByVehicleProvider._internal(
        (ref) => create(ref as FuelEntriesByVehicleRef),
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
  AutoDisposeFutureProviderElement<List<FuelEntryModel>> createElement() {
    return _FuelEntriesByVehicleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FuelEntriesByVehicleProvider &&
        other.vehicleId == vehicleId;
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
mixin FuelEntriesByVehicleRef
    on AutoDisposeFutureProviderRef<List<FuelEntryModel>> {
  /// The parameter `vehicleId` of this provider.
  int get vehicleId;
}

class _FuelEntriesByVehicleProviderElement
    extends AutoDisposeFutureProviderElement<List<FuelEntryModel>>
    with FuelEntriesByVehicleRef {
  _FuelEntriesByVehicleProviderElement(super.provider);

  @override
  int get vehicleId => (origin as FuelEntriesByVehicleProvider).vehicleId;
}

String _$fuelEntriesByDateRangeHash() =>
    r'b585b3de01717cd60a36dcbbafa3ca483aae6495';

/// Provider for getting fuel entries by date range
///
/// Copied from [fuelEntriesByDateRange].
@ProviderFor(fuelEntriesByDateRange)
const fuelEntriesByDateRangeProvider = FuelEntriesByDateRangeFamily();

/// Provider for getting fuel entries by date range
///
/// Copied from [fuelEntriesByDateRange].
class FuelEntriesByDateRangeFamily
    extends Family<AsyncValue<List<FuelEntryModel>>> {
  /// Provider for getting fuel entries by date range
  ///
  /// Copied from [fuelEntriesByDateRange].
  const FuelEntriesByDateRangeFamily();

  /// Provider for getting fuel entries by date range
  ///
  /// Copied from [fuelEntriesByDateRange].
  FuelEntriesByDateRangeProvider call(DateTime startDate, DateTime endDate) {
    return FuelEntriesByDateRangeProvider(startDate, endDate);
  }

  @override
  FuelEntriesByDateRangeProvider getProviderOverride(
    covariant FuelEntriesByDateRangeProvider provider,
  ) {
    return call(provider.startDate, provider.endDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fuelEntriesByDateRangeProvider';
}

/// Provider for getting fuel entries by date range
///
/// Copied from [fuelEntriesByDateRange].
class FuelEntriesByDateRangeProvider
    extends AutoDisposeFutureProvider<List<FuelEntryModel>> {
  /// Provider for getting fuel entries by date range
  ///
  /// Copied from [fuelEntriesByDateRange].
  FuelEntriesByDateRangeProvider(DateTime startDate, DateTime endDate)
    : this._internal(
        (ref) => fuelEntriesByDateRange(
          ref as FuelEntriesByDateRangeRef,
          startDate,
          endDate,
        ),
        from: fuelEntriesByDateRangeProvider,
        name: r'fuelEntriesByDateRangeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fuelEntriesByDateRangeHash,
        dependencies: FuelEntriesByDateRangeFamily._dependencies,
        allTransitiveDependencies:
            FuelEntriesByDateRangeFamily._allTransitiveDependencies,
        startDate: startDate,
        endDate: endDate,
      );

  FuelEntriesByDateRangeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final DateTime startDate;
  final DateTime endDate;

  @override
  Override overrideWith(
    FutureOr<List<FuelEntryModel>> Function(FuelEntriesByDateRangeRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FuelEntriesByDateRangeProvider._internal(
        (ref) => create(ref as FuelEntriesByDateRangeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<FuelEntryModel>> createElement() {
    return _FuelEntriesByDateRangeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FuelEntriesByDateRangeProvider &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FuelEntriesByDateRangeRef
    on AutoDisposeFutureProviderRef<List<FuelEntryModel>> {
  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;
}

class _FuelEntriesByDateRangeProviderElement
    extends AutoDisposeFutureProviderElement<List<FuelEntryModel>>
    with FuelEntriesByDateRangeRef {
  _FuelEntriesByDateRangeProviderElement(super.provider);

  @override
  DateTime get startDate =>
      (origin as FuelEntriesByDateRangeProvider).startDate;
  @override
  DateTime get endDate => (origin as FuelEntriesByDateRangeProvider).endDate;
}

String _$fuelEntriesByVehicleAndDateRangeHash() =>
    r'26dda7d9ac0e868906715903bb854215e0790eaa';

/// Provider for getting fuel entries by vehicle and date range
///
/// Copied from [fuelEntriesByVehicleAndDateRange].
@ProviderFor(fuelEntriesByVehicleAndDateRange)
const fuelEntriesByVehicleAndDateRangeProvider =
    FuelEntriesByVehicleAndDateRangeFamily();

/// Provider for getting fuel entries by vehicle and date range
///
/// Copied from [fuelEntriesByVehicleAndDateRange].
class FuelEntriesByVehicleAndDateRangeFamily
    extends Family<AsyncValue<List<FuelEntryModel>>> {
  /// Provider for getting fuel entries by vehicle and date range
  ///
  /// Copied from [fuelEntriesByVehicleAndDateRange].
  const FuelEntriesByVehicleAndDateRangeFamily();

  /// Provider for getting fuel entries by vehicle and date range
  ///
  /// Copied from [fuelEntriesByVehicleAndDateRange].
  FuelEntriesByVehicleAndDateRangeProvider call(
    int vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return FuelEntriesByVehicleAndDateRangeProvider(
      vehicleId,
      startDate,
      endDate,
    );
  }

  @override
  FuelEntriesByVehicleAndDateRangeProvider getProviderOverride(
    covariant FuelEntriesByVehicleAndDateRangeProvider provider,
  ) {
    return call(provider.vehicleId, provider.startDate, provider.endDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fuelEntriesByVehicleAndDateRangeProvider';
}

/// Provider for getting fuel entries by vehicle and date range
///
/// Copied from [fuelEntriesByVehicleAndDateRange].
class FuelEntriesByVehicleAndDateRangeProvider
    extends AutoDisposeFutureProvider<List<FuelEntryModel>> {
  /// Provider for getting fuel entries by vehicle and date range
  ///
  /// Copied from [fuelEntriesByVehicleAndDateRange].
  FuelEntriesByVehicleAndDateRangeProvider(
    int vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) : this._internal(
        (ref) => fuelEntriesByVehicleAndDateRange(
          ref as FuelEntriesByVehicleAndDateRangeRef,
          vehicleId,
          startDate,
          endDate,
        ),
        from: fuelEntriesByVehicleAndDateRangeProvider,
        name: r'fuelEntriesByVehicleAndDateRangeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fuelEntriesByVehicleAndDateRangeHash,
        dependencies: FuelEntriesByVehicleAndDateRangeFamily._dependencies,
        allTransitiveDependencies:
            FuelEntriesByVehicleAndDateRangeFamily._allTransitiveDependencies,
        vehicleId: vehicleId,
        startDate: startDate,
        endDate: endDate,
      );

  FuelEntriesByVehicleAndDateRangeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final int vehicleId;
  final DateTime startDate;
  final DateTime endDate;

  @override
  Override overrideWith(
    FutureOr<List<FuelEntryModel>> Function(
      FuelEntriesByVehicleAndDateRangeRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FuelEntriesByVehicleAndDateRangeProvider._internal(
        (ref) => create(ref as FuelEntriesByVehicleAndDateRangeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        vehicleId: vehicleId,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<FuelEntryModel>> createElement() {
    return _FuelEntriesByVehicleAndDateRangeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FuelEntriesByVehicleAndDateRangeProvider &&
        other.vehicleId == vehicleId &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, vehicleId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FuelEntriesByVehicleAndDateRangeRef
    on AutoDisposeFutureProviderRef<List<FuelEntryModel>> {
  /// The parameter `vehicleId` of this provider.
  int get vehicleId;

  /// The parameter `startDate` of this provider.
  DateTime get startDate;

  /// The parameter `endDate` of this provider.
  DateTime get endDate;
}

class _FuelEntriesByVehicleAndDateRangeProviderElement
    extends AutoDisposeFutureProviderElement<List<FuelEntryModel>>
    with FuelEntriesByVehicleAndDateRangeRef {
  _FuelEntriesByVehicleAndDateRangeProviderElement(super.provider);

  @override
  int get vehicleId =>
      (origin as FuelEntriesByVehicleAndDateRangeProvider).vehicleId;
  @override
  DateTime get startDate =>
      (origin as FuelEntriesByVehicleAndDateRangeProvider).startDate;
  @override
  DateTime get endDate =>
      (origin as FuelEntriesByVehicleAndDateRangeProvider).endDate;
}

String _$latestFuelEntryForVehicleHash() =>
    r'392261ec09da1ba3cb2d2851ff5b6cc1977238c0';

/// Provider for getting the latest fuel entry for a vehicle
///
/// Copied from [latestFuelEntryForVehicle].
@ProviderFor(latestFuelEntryForVehicle)
const latestFuelEntryForVehicleProvider = LatestFuelEntryForVehicleFamily();

/// Provider for getting the latest fuel entry for a vehicle
///
/// Copied from [latestFuelEntryForVehicle].
class LatestFuelEntryForVehicleFamily
    extends Family<AsyncValue<FuelEntryModel?>> {
  /// Provider for getting the latest fuel entry for a vehicle
  ///
  /// Copied from [latestFuelEntryForVehicle].
  const LatestFuelEntryForVehicleFamily();

  /// Provider for getting the latest fuel entry for a vehicle
  ///
  /// Copied from [latestFuelEntryForVehicle].
  LatestFuelEntryForVehicleProvider call(int vehicleId) {
    return LatestFuelEntryForVehicleProvider(vehicleId);
  }

  @override
  LatestFuelEntryForVehicleProvider getProviderOverride(
    covariant LatestFuelEntryForVehicleProvider provider,
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
  String? get name => r'latestFuelEntryForVehicleProvider';
}

/// Provider for getting the latest fuel entry for a vehicle
///
/// Copied from [latestFuelEntryForVehicle].
class LatestFuelEntryForVehicleProvider
    extends AutoDisposeFutureProvider<FuelEntryModel?> {
  /// Provider for getting the latest fuel entry for a vehicle
  ///
  /// Copied from [latestFuelEntryForVehicle].
  LatestFuelEntryForVehicleProvider(int vehicleId)
    : this._internal(
        (ref) => latestFuelEntryForVehicle(
          ref as LatestFuelEntryForVehicleRef,
          vehicleId,
        ),
        from: latestFuelEntryForVehicleProvider,
        name: r'latestFuelEntryForVehicleProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$latestFuelEntryForVehicleHash,
        dependencies: LatestFuelEntryForVehicleFamily._dependencies,
        allTransitiveDependencies:
            LatestFuelEntryForVehicleFamily._allTransitiveDependencies,
        vehicleId: vehicleId,
      );

  LatestFuelEntryForVehicleProvider._internal(
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
    FutureOr<FuelEntryModel?> Function(LatestFuelEntryForVehicleRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LatestFuelEntryForVehicleProvider._internal(
        (ref) => create(ref as LatestFuelEntryForVehicleRef),
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
  AutoDisposeFutureProviderElement<FuelEntryModel?> createElement() {
    return _LatestFuelEntryForVehicleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LatestFuelEntryForVehicleProvider &&
        other.vehicleId == vehicleId;
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
mixin LatestFuelEntryForVehicleRef
    on AutoDisposeFutureProviderRef<FuelEntryModel?> {
  /// The parameter `vehicleId` of this provider.
  int get vehicleId;
}

class _LatestFuelEntryForVehicleProviderElement
    extends AutoDisposeFutureProviderElement<FuelEntryModel?>
    with LatestFuelEntryForVehicleRef {
  _LatestFuelEntryForVehicleProviderElement(super.provider);

  @override
  int get vehicleId => (origin as LatestFuelEntryForVehicleProvider).vehicleId;
}

String _$fuelEntryHash() => r'1f95bd02ca87257b349c335b44b9eb50dd990bc1';

/// Provider for getting a specific fuel entry by ID
///
/// Copied from [fuelEntry].
@ProviderFor(fuelEntry)
const fuelEntryProvider = FuelEntryFamily();

/// Provider for getting a specific fuel entry by ID
///
/// Copied from [fuelEntry].
class FuelEntryFamily extends Family<AsyncValue<FuelEntryModel?>> {
  /// Provider for getting a specific fuel entry by ID
  ///
  /// Copied from [fuelEntry].
  const FuelEntryFamily();

  /// Provider for getting a specific fuel entry by ID
  ///
  /// Copied from [fuelEntry].
  FuelEntryProvider call(int entryId) {
    return FuelEntryProvider(entryId);
  }

  @override
  FuelEntryProvider getProviderOverride(covariant FuelEntryProvider provider) {
    return call(provider.entryId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fuelEntryProvider';
}

/// Provider for getting a specific fuel entry by ID
///
/// Copied from [fuelEntry].
class FuelEntryProvider extends AutoDisposeFutureProvider<FuelEntryModel?> {
  /// Provider for getting a specific fuel entry by ID
  ///
  /// Copied from [fuelEntry].
  FuelEntryProvider(int entryId)
    : this._internal(
        (ref) => fuelEntry(ref as FuelEntryRef, entryId),
        from: fuelEntryProvider,
        name: r'fuelEntryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fuelEntryHash,
        dependencies: FuelEntryFamily._dependencies,
        allTransitiveDependencies: FuelEntryFamily._allTransitiveDependencies,
        entryId: entryId,
      );

  FuelEntryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.entryId,
  }) : super.internal();

  final int entryId;

  @override
  Override overrideWith(
    FutureOr<FuelEntryModel?> Function(FuelEntryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FuelEntryProvider._internal(
        (ref) => create(ref as FuelEntryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        entryId: entryId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<FuelEntryModel?> createElement() {
    return _FuelEntryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FuelEntryProvider && other.entryId == entryId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, entryId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FuelEntryRef on AutoDisposeFutureProviderRef<FuelEntryModel?> {
  /// The parameter `entryId` of this provider.
  int get entryId;
}

class _FuelEntryProviderElement
    extends AutoDisposeFutureProviderElement<FuelEntryModel?>
    with FuelEntryRef {
  _FuelEntryProviderElement(super.provider);

  @override
  int get entryId => (origin as FuelEntryProvider).entryId;
}

String _$fuelEntryCountHash() => r'f2dd214f39fd6928c5796dd67b2c6c0d52c1b62c';

/// Provider for getting fuel entry count
///
/// Copied from [fuelEntryCount].
@ProviderFor(fuelEntryCount)
final fuelEntryCountProvider = AutoDisposeFutureProvider<int>.internal(
  fuelEntryCount,
  name: r'fuelEntryCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fuelEntryCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FuelEntryCountRef = AutoDisposeFutureProviderRef<int>;
String _$fuelEntryCountForVehicleHash() =>
    r'1d58cc36f3b2d6c9ebdbbf85855d9211a8d466d5';

/// Provider for getting fuel entry count for a specific vehicle
///
/// Copied from [fuelEntryCountForVehicle].
@ProviderFor(fuelEntryCountForVehicle)
const fuelEntryCountForVehicleProvider = FuelEntryCountForVehicleFamily();

/// Provider for getting fuel entry count for a specific vehicle
///
/// Copied from [fuelEntryCountForVehicle].
class FuelEntryCountForVehicleFamily extends Family<AsyncValue<int>> {
  /// Provider for getting fuel entry count for a specific vehicle
  ///
  /// Copied from [fuelEntryCountForVehicle].
  const FuelEntryCountForVehicleFamily();

  /// Provider for getting fuel entry count for a specific vehicle
  ///
  /// Copied from [fuelEntryCountForVehicle].
  FuelEntryCountForVehicleProvider call(int vehicleId) {
    return FuelEntryCountForVehicleProvider(vehicleId);
  }

  @override
  FuelEntryCountForVehicleProvider getProviderOverride(
    covariant FuelEntryCountForVehicleProvider provider,
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
  String? get name => r'fuelEntryCountForVehicleProvider';
}

/// Provider for getting fuel entry count for a specific vehicle
///
/// Copied from [fuelEntryCountForVehicle].
class FuelEntryCountForVehicleProvider extends AutoDisposeFutureProvider<int> {
  /// Provider for getting fuel entry count for a specific vehicle
  ///
  /// Copied from [fuelEntryCountForVehicle].
  FuelEntryCountForVehicleProvider(int vehicleId)
    : this._internal(
        (ref) => fuelEntryCountForVehicle(
          ref as FuelEntryCountForVehicleRef,
          vehicleId,
        ),
        from: fuelEntryCountForVehicleProvider,
        name: r'fuelEntryCountForVehicleProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$fuelEntryCountForVehicleHash,
        dependencies: FuelEntryCountForVehicleFamily._dependencies,
        allTransitiveDependencies:
            FuelEntryCountForVehicleFamily._allTransitiveDependencies,
        vehicleId: vehicleId,
      );

  FuelEntryCountForVehicleProvider._internal(
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
    FutureOr<int> Function(FuelEntryCountForVehicleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FuelEntryCountForVehicleProvider._internal(
        (ref) => create(ref as FuelEntryCountForVehicleRef),
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
  AutoDisposeFutureProviderElement<int> createElement() {
    return _FuelEntryCountForVehicleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FuelEntryCountForVehicleProvider &&
        other.vehicleId == vehicleId;
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
mixin FuelEntryCountForVehicleRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `vehicleId` of this provider.
  int get vehicleId;
}

class _FuelEntryCountForVehicleProviderElement
    extends AutoDisposeFutureProviderElement<int>
    with FuelEntryCountForVehicleRef {
  _FuelEntryCountForVehicleProviderElement(super.provider);

  @override
  int get vehicleId => (origin as FuelEntryCountForVehicleProvider).vehicleId;
}

String _$fuelEntriesGroupedByCountryHash() =>
    r'b599daedfa3b38cc4d1f7abbabd159ecd2e0dea3';

/// Provider for getting fuel entries grouped by country
///
/// Copied from [fuelEntriesGroupedByCountry].
@ProviderFor(fuelEntriesGroupedByCountry)
final fuelEntriesGroupedByCountryProvider =
    AutoDisposeFutureProvider<Map<String, List<FuelEntryModel>>>.internal(
      fuelEntriesGroupedByCountry,
      name: r'fuelEntriesGroupedByCountryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fuelEntriesGroupedByCountryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FuelEntriesGroupedByCountryRef =
    AutoDisposeFutureProviderRef<Map<String, List<FuelEntryModel>>>;
String _$averageConsumptionForVehicleHash() =>
    r'4aa7020d919c1c5b8b34f8220c4f878bb2c8fece';

/// Provider for getting average consumption for a vehicle
///
/// Copied from [averageConsumptionForVehicle].
@ProviderFor(averageConsumptionForVehicle)
const averageConsumptionForVehicleProvider =
    AverageConsumptionForVehicleFamily();

/// Provider for getting average consumption for a vehicle
///
/// Copied from [averageConsumptionForVehicle].
class AverageConsumptionForVehicleFamily extends Family<AsyncValue<double?>> {
  /// Provider for getting average consumption for a vehicle
  ///
  /// Copied from [averageConsumptionForVehicle].
  const AverageConsumptionForVehicleFamily();

  /// Provider for getting average consumption for a vehicle
  ///
  /// Copied from [averageConsumptionForVehicle].
  AverageConsumptionForVehicleProvider call(int vehicleId) {
    return AverageConsumptionForVehicleProvider(vehicleId);
  }

  @override
  AverageConsumptionForVehicleProvider getProviderOverride(
    covariant AverageConsumptionForVehicleProvider provider,
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
  String? get name => r'averageConsumptionForVehicleProvider';
}

/// Provider for getting average consumption for a vehicle
///
/// Copied from [averageConsumptionForVehicle].
class AverageConsumptionForVehicleProvider
    extends AutoDisposeFutureProvider<double?> {
  /// Provider for getting average consumption for a vehicle
  ///
  /// Copied from [averageConsumptionForVehicle].
  AverageConsumptionForVehicleProvider(int vehicleId)
    : this._internal(
        (ref) => averageConsumptionForVehicle(
          ref as AverageConsumptionForVehicleRef,
          vehicleId,
        ),
        from: averageConsumptionForVehicleProvider,
        name: r'averageConsumptionForVehicleProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$averageConsumptionForVehicleHash,
        dependencies: AverageConsumptionForVehicleFamily._dependencies,
        allTransitiveDependencies:
            AverageConsumptionForVehicleFamily._allTransitiveDependencies,
        vehicleId: vehicleId,
      );

  AverageConsumptionForVehicleProvider._internal(
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
    FutureOr<double?> Function(AverageConsumptionForVehicleRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AverageConsumptionForVehicleProvider._internal(
        (ref) => create(ref as AverageConsumptionForVehicleRef),
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
  AutoDisposeFutureProviderElement<double?> createElement() {
    return _AverageConsumptionForVehicleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AverageConsumptionForVehicleProvider &&
        other.vehicleId == vehicleId;
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
mixin AverageConsumptionForVehicleRef on AutoDisposeFutureProviderRef<double?> {
  /// The parameter `vehicleId` of this provider.
  int get vehicleId;
}

class _AverageConsumptionForVehicleProviderElement
    extends AutoDisposeFutureProviderElement<double?>
    with AverageConsumptionForVehicleRef {
  _AverageConsumptionForVehicleProviderElement(super.provider);

  @override
  int get vehicleId =>
      (origin as AverageConsumptionForVehicleProvider).vehicleId;
}

String _$fuelEntriesNotifierHash() =>
    r'fa34d337c696380dadeaf28aaa86b193165b1855';

/// Notifier for managing fuel entries state
///
/// Copied from [FuelEntriesNotifier].
@ProviderFor(FuelEntriesNotifier)
final fuelEntriesNotifierProvider =
    AutoDisposeAsyncNotifierProvider<
      FuelEntriesNotifier,
      FuelEntryState
    >.internal(
      FuelEntriesNotifier.new,
      name: r'fuelEntriesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fuelEntriesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FuelEntriesNotifier = AutoDisposeAsyncNotifier<FuelEntryState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
