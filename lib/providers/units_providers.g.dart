// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'units_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$formattedConsumptionHash() =>
    r'ceda3667afd1ebcab2a6ea7b859de972721fd544';

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

/// Provider that returns formatted consumption with current units
///
/// Copied from [formattedConsumption].
@ProviderFor(formattedConsumption)
const formattedConsumptionProvider = FormattedConsumptionFamily();

/// Provider that returns formatted consumption with current units
///
/// Copied from [formattedConsumption].
class FormattedConsumptionFamily extends Family<String> {
  /// Provider that returns formatted consumption with current units
  ///
  /// Copied from [formattedConsumption].
  const FormattedConsumptionFamily();

  /// Provider that returns formatted consumption with current units
  ///
  /// Copied from [formattedConsumption].
  FormattedConsumptionProvider call(double consumption) {
    return FormattedConsumptionProvider(consumption);
  }

  @override
  FormattedConsumptionProvider getProviderOverride(
    covariant FormattedConsumptionProvider provider,
  ) {
    return call(provider.consumption);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'formattedConsumptionProvider';
}

/// Provider that returns formatted consumption with current units
///
/// Copied from [formattedConsumption].
class FormattedConsumptionProvider extends AutoDisposeProvider<String> {
  /// Provider that returns formatted consumption with current units
  ///
  /// Copied from [formattedConsumption].
  FormattedConsumptionProvider(double consumption)
    : this._internal(
        (ref) =>
            formattedConsumption(ref as FormattedConsumptionRef, consumption),
        from: formattedConsumptionProvider,
        name: r'formattedConsumptionProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$formattedConsumptionHash,
        dependencies: FormattedConsumptionFamily._dependencies,
        allTransitiveDependencies:
            FormattedConsumptionFamily._allTransitiveDependencies,
        consumption: consumption,
      );

  FormattedConsumptionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.consumption,
  }) : super.internal();

  final double consumption;

  @override
  Override overrideWith(
    String Function(FormattedConsumptionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FormattedConsumptionProvider._internal(
        (ref) => create(ref as FormattedConsumptionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        consumption: consumption,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String> createElement() {
    return _FormattedConsumptionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FormattedConsumptionProvider &&
        other.consumption == consumption;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, consumption.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FormattedConsumptionRef on AutoDisposeProviderRef<String> {
  /// The parameter `consumption` of this provider.
  double get consumption;
}

class _FormattedConsumptionProviderElement
    extends AutoDisposeProviderElement<String>
    with FormattedConsumptionRef {
  _FormattedConsumptionProviderElement(super.provider);

  @override
  double get consumption =>
      (origin as FormattedConsumptionProvider).consumption;
}

String _$formattedDistanceHash() => r'c0e056ed53ec9918a819199ff6a103200cb8635b';

/// Provider that returns formatted distance with current units
///
/// Copied from [formattedDistance].
@ProviderFor(formattedDistance)
const formattedDistanceProvider = FormattedDistanceFamily();

/// Provider that returns formatted distance with current units
///
/// Copied from [formattedDistance].
class FormattedDistanceFamily extends Family<String> {
  /// Provider that returns formatted distance with current units
  ///
  /// Copied from [formattedDistance].
  const FormattedDistanceFamily();

  /// Provider that returns formatted distance with current units
  ///
  /// Copied from [formattedDistance].
  FormattedDistanceProvider call(double distance) {
    return FormattedDistanceProvider(distance);
  }

  @override
  FormattedDistanceProvider getProviderOverride(
    covariant FormattedDistanceProvider provider,
  ) {
    return call(provider.distance);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'formattedDistanceProvider';
}

/// Provider that returns formatted distance with current units
///
/// Copied from [formattedDistance].
class FormattedDistanceProvider extends AutoDisposeProvider<String> {
  /// Provider that returns formatted distance with current units
  ///
  /// Copied from [formattedDistance].
  FormattedDistanceProvider(double distance)
    : this._internal(
        (ref) => formattedDistance(ref as FormattedDistanceRef, distance),
        from: formattedDistanceProvider,
        name: r'formattedDistanceProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$formattedDistanceHash,
        dependencies: FormattedDistanceFamily._dependencies,
        allTransitiveDependencies:
            FormattedDistanceFamily._allTransitiveDependencies,
        distance: distance,
      );

  FormattedDistanceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.distance,
  }) : super.internal();

  final double distance;

  @override
  Override overrideWith(String Function(FormattedDistanceRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: FormattedDistanceProvider._internal(
        (ref) => create(ref as FormattedDistanceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        distance: distance,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String> createElement() {
    return _FormattedDistanceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FormattedDistanceProvider && other.distance == distance;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, distance.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FormattedDistanceRef on AutoDisposeProviderRef<String> {
  /// The parameter `distance` of this provider.
  double get distance;
}

class _FormattedDistanceProviderElement
    extends AutoDisposeProviderElement<String>
    with FormattedDistanceRef {
  _FormattedDistanceProviderElement(super.provider);

  @override
  double get distance => (origin as FormattedDistanceProvider).distance;
}

String _$formattedVolumeHash() => r'1eab4203fc5cd6e4b02c9b665757aab7f5f9473e';

/// Provider that returns formatted volume with current units
///
/// Copied from [formattedVolume].
@ProviderFor(formattedVolume)
const formattedVolumeProvider = FormattedVolumeFamily();

/// Provider that returns formatted volume with current units
///
/// Copied from [formattedVolume].
class FormattedVolumeFamily extends Family<String> {
  /// Provider that returns formatted volume with current units
  ///
  /// Copied from [formattedVolume].
  const FormattedVolumeFamily();

  /// Provider that returns formatted volume with current units
  ///
  /// Copied from [formattedVolume].
  FormattedVolumeProvider call(double volume) {
    return FormattedVolumeProvider(volume);
  }

  @override
  FormattedVolumeProvider getProviderOverride(
    covariant FormattedVolumeProvider provider,
  ) {
    return call(provider.volume);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'formattedVolumeProvider';
}

/// Provider that returns formatted volume with current units
///
/// Copied from [formattedVolume].
class FormattedVolumeProvider extends AutoDisposeProvider<String> {
  /// Provider that returns formatted volume with current units
  ///
  /// Copied from [formattedVolume].
  FormattedVolumeProvider(double volume)
    : this._internal(
        (ref) => formattedVolume(ref as FormattedVolumeRef, volume),
        from: formattedVolumeProvider,
        name: r'formattedVolumeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$formattedVolumeHash,
        dependencies: FormattedVolumeFamily._dependencies,
        allTransitiveDependencies:
            FormattedVolumeFamily._allTransitiveDependencies,
        volume: volume,
      );

  FormattedVolumeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.volume,
  }) : super.internal();

  final double volume;

  @override
  Override overrideWith(String Function(FormattedVolumeRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: FormattedVolumeProvider._internal(
        (ref) => create(ref as FormattedVolumeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        volume: volume,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String> createElement() {
    return _FormattedVolumeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FormattedVolumeProvider && other.volume == volume;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, volume.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FormattedVolumeRef on AutoDisposeProviderRef<String> {
  /// The parameter `volume` of this provider.
  double get volume;
}

class _FormattedVolumeProviderElement extends AutoDisposeProviderElement<String>
    with FormattedVolumeRef {
  _FormattedVolumeProviderElement(super.provider);

  @override
  double get volume => (origin as FormattedVolumeProvider).volume;
}

String _$consumptionInCurrentUnitsHash() =>
    r'c8a4ec218a679283dae2613fdf8fe7e8353b5496';

/// Provider that returns consumption value in the current unit system
///
/// Copied from [consumptionInCurrentUnits].
@ProviderFor(consumptionInCurrentUnits)
const consumptionInCurrentUnitsProvider = ConsumptionInCurrentUnitsFamily();

/// Provider that returns consumption value in the current unit system
///
/// Copied from [consumptionInCurrentUnits].
class ConsumptionInCurrentUnitsFamily extends Family<double> {
  /// Provider that returns consumption value in the current unit system
  ///
  /// Copied from [consumptionInCurrentUnits].
  const ConsumptionInCurrentUnitsFamily();

  /// Provider that returns consumption value in the current unit system
  ///
  /// Copied from [consumptionInCurrentUnits].
  ConsumptionInCurrentUnitsProvider call(double metricConsumption) {
    return ConsumptionInCurrentUnitsProvider(metricConsumption);
  }

  @override
  ConsumptionInCurrentUnitsProvider getProviderOverride(
    covariant ConsumptionInCurrentUnitsProvider provider,
  ) {
    return call(provider.metricConsumption);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'consumptionInCurrentUnitsProvider';
}

/// Provider that returns consumption value in the current unit system
///
/// Copied from [consumptionInCurrentUnits].
class ConsumptionInCurrentUnitsProvider extends AutoDisposeProvider<double> {
  /// Provider that returns consumption value in the current unit system
  ///
  /// Copied from [consumptionInCurrentUnits].
  ConsumptionInCurrentUnitsProvider(double metricConsumption)
    : this._internal(
        (ref) => consumptionInCurrentUnits(
          ref as ConsumptionInCurrentUnitsRef,
          metricConsumption,
        ),
        from: consumptionInCurrentUnitsProvider,
        name: r'consumptionInCurrentUnitsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$consumptionInCurrentUnitsHash,
        dependencies: ConsumptionInCurrentUnitsFamily._dependencies,
        allTransitiveDependencies:
            ConsumptionInCurrentUnitsFamily._allTransitiveDependencies,
        metricConsumption: metricConsumption,
      );

  ConsumptionInCurrentUnitsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.metricConsumption,
  }) : super.internal();

  final double metricConsumption;

  @override
  Override overrideWith(
    double Function(ConsumptionInCurrentUnitsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConsumptionInCurrentUnitsProvider._internal(
        (ref) => create(ref as ConsumptionInCurrentUnitsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        metricConsumption: metricConsumption,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _ConsumptionInCurrentUnitsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConsumptionInCurrentUnitsProvider &&
        other.metricConsumption == metricConsumption;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, metricConsumption.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConsumptionInCurrentUnitsRef on AutoDisposeProviderRef<double> {
  /// The parameter `metricConsumption` of this provider.
  double get metricConsumption;
}

class _ConsumptionInCurrentUnitsProviderElement
    extends AutoDisposeProviderElement<double>
    with ConsumptionInCurrentUnitsRef {
  _ConsumptionInCurrentUnitsProviderElement(super.provider);

  @override
  double get metricConsumption =>
      (origin as ConsumptionInCurrentUnitsProvider).metricConsumption;
}

String _$distanceInCurrentUnitsHash() =>
    r'672f1d12b3d2a2a9137b17627785facc5d7c7476';

/// Provider that returns distance value in the current unit system
///
/// Copied from [distanceInCurrentUnits].
@ProviderFor(distanceInCurrentUnits)
const distanceInCurrentUnitsProvider = DistanceInCurrentUnitsFamily();

/// Provider that returns distance value in the current unit system
///
/// Copied from [distanceInCurrentUnits].
class DistanceInCurrentUnitsFamily extends Family<double> {
  /// Provider that returns distance value in the current unit system
  ///
  /// Copied from [distanceInCurrentUnits].
  const DistanceInCurrentUnitsFamily();

  /// Provider that returns distance value in the current unit system
  ///
  /// Copied from [distanceInCurrentUnits].
  DistanceInCurrentUnitsProvider call(double kilometers) {
    return DistanceInCurrentUnitsProvider(kilometers);
  }

  @override
  DistanceInCurrentUnitsProvider getProviderOverride(
    covariant DistanceInCurrentUnitsProvider provider,
  ) {
    return call(provider.kilometers);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'distanceInCurrentUnitsProvider';
}

/// Provider that returns distance value in the current unit system
///
/// Copied from [distanceInCurrentUnits].
class DistanceInCurrentUnitsProvider extends AutoDisposeProvider<double> {
  /// Provider that returns distance value in the current unit system
  ///
  /// Copied from [distanceInCurrentUnits].
  DistanceInCurrentUnitsProvider(double kilometers)
    : this._internal(
        (ref) => distanceInCurrentUnits(
          ref as DistanceInCurrentUnitsRef,
          kilometers,
        ),
        from: distanceInCurrentUnitsProvider,
        name: r'distanceInCurrentUnitsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$distanceInCurrentUnitsHash,
        dependencies: DistanceInCurrentUnitsFamily._dependencies,
        allTransitiveDependencies:
            DistanceInCurrentUnitsFamily._allTransitiveDependencies,
        kilometers: kilometers,
      );

  DistanceInCurrentUnitsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.kilometers,
  }) : super.internal();

  final double kilometers;

  @override
  Override overrideWith(
    double Function(DistanceInCurrentUnitsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DistanceInCurrentUnitsProvider._internal(
        (ref) => create(ref as DistanceInCurrentUnitsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        kilometers: kilometers,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _DistanceInCurrentUnitsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DistanceInCurrentUnitsProvider &&
        other.kilometers == kilometers;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, kilometers.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DistanceInCurrentUnitsRef on AutoDisposeProviderRef<double> {
  /// The parameter `kilometers` of this provider.
  double get kilometers;
}

class _DistanceInCurrentUnitsProviderElement
    extends AutoDisposeProviderElement<double>
    with DistanceInCurrentUnitsRef {
  _DistanceInCurrentUnitsProviderElement(super.provider);

  @override
  double get kilometers =>
      (origin as DistanceInCurrentUnitsProvider).kilometers;
}

String _$volumeInCurrentUnitsHash() =>
    r'ca3a54daa04bdb258da574c9641e828fbc9a3560';

/// Provider that returns volume value in the current unit system
///
/// Copied from [volumeInCurrentUnits].
@ProviderFor(volumeInCurrentUnits)
const volumeInCurrentUnitsProvider = VolumeInCurrentUnitsFamily();

/// Provider that returns volume value in the current unit system
///
/// Copied from [volumeInCurrentUnits].
class VolumeInCurrentUnitsFamily extends Family<double> {
  /// Provider that returns volume value in the current unit system
  ///
  /// Copied from [volumeInCurrentUnits].
  const VolumeInCurrentUnitsFamily();

  /// Provider that returns volume value in the current unit system
  ///
  /// Copied from [volumeInCurrentUnits].
  VolumeInCurrentUnitsProvider call(double liters) {
    return VolumeInCurrentUnitsProvider(liters);
  }

  @override
  VolumeInCurrentUnitsProvider getProviderOverride(
    covariant VolumeInCurrentUnitsProvider provider,
  ) {
    return call(provider.liters);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'volumeInCurrentUnitsProvider';
}

/// Provider that returns volume value in the current unit system
///
/// Copied from [volumeInCurrentUnits].
class VolumeInCurrentUnitsProvider extends AutoDisposeProvider<double> {
  /// Provider that returns volume value in the current unit system
  ///
  /// Copied from [volumeInCurrentUnits].
  VolumeInCurrentUnitsProvider(double liters)
    : this._internal(
        (ref) => volumeInCurrentUnits(ref as VolumeInCurrentUnitsRef, liters),
        from: volumeInCurrentUnitsProvider,
        name: r'volumeInCurrentUnitsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$volumeInCurrentUnitsHash,
        dependencies: VolumeInCurrentUnitsFamily._dependencies,
        allTransitiveDependencies:
            VolumeInCurrentUnitsFamily._allTransitiveDependencies,
        liters: liters,
      );

  VolumeInCurrentUnitsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.liters,
  }) : super.internal();

  final double liters;

  @override
  Override overrideWith(
    double Function(VolumeInCurrentUnitsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VolumeInCurrentUnitsProvider._internal(
        (ref) => create(ref as VolumeInCurrentUnitsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        liters: liters,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _VolumeInCurrentUnitsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VolumeInCurrentUnitsProvider && other.liters == liters;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, liters.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VolumeInCurrentUnitsRef on AutoDisposeProviderRef<double> {
  /// The parameter `liters` of this provider.
  double get liters;
}

class _VolumeInCurrentUnitsProviderElement
    extends AutoDisposeProviderElement<double>
    with VolumeInCurrentUnitsRef {
  _VolumeInCurrentUnitsProviderElement(super.provider);

  @override
  double get liters => (origin as VolumeInCurrentUnitsProvider).liters;
}

String _$unitsHash() => r'0dd2c2463a1dac2d850f079a2552358625876b47';

/// Provider for the current unit system
///
/// Copied from [Units].
@ProviderFor(Units)
final unitsProvider =
    AutoDisposeAsyncNotifierProvider<Units, UnitSystem>.internal(
      Units.new,
      name: r'unitsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$unitsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Units = AutoDisposeAsyncNotifier<UnitSystem>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
