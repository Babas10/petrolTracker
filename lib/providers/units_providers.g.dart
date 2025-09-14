// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'units_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for the current unit system

@ProviderFor(Units)
const unitsProvider = UnitsProvider._();

/// Provider for the current unit system
final class UnitsProvider extends $AsyncNotifierProvider<Units, UnitSystem> {
  /// Provider for the current unit system
  const UnitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unitsHash();

  @$internal
  @override
  Units create() => Units();
}

String _$unitsHash() => r'635049e8bbe300c072b40ef5522a444bab1e0dab';

/// Provider for the current unit system

abstract class _$Units extends $AsyncNotifier<UnitSystem> {
  FutureOr<UnitSystem> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<UnitSystem>, UnitSystem>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UnitSystem>, UnitSystem>,
              AsyncValue<UnitSystem>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider that returns formatted consumption with current units

@ProviderFor(formattedConsumption)
const formattedConsumptionProvider = FormattedConsumptionFamily._();

/// Provider that returns formatted consumption with current units

final class FormattedConsumptionProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provider that returns formatted consumption with current units
  const FormattedConsumptionProvider._({
    required FormattedConsumptionFamily super.from,
    required double super.argument,
  }) : super(
         retry: null,
         name: r'formattedConsumptionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$formattedConsumptionHash();

  @override
  String toString() {
    return r'formattedConsumptionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    final argument = this.argument as double;
    return formattedConsumption(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FormattedConsumptionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$formattedConsumptionHash() =>
    r'945ec34d695c7e86b9be6984512b17233601d0fe';

/// Provider that returns formatted consumption with current units

final class FormattedConsumptionFamily extends $Family
    with $FunctionalFamilyOverride<String, double> {
  const FormattedConsumptionFamily._()
    : super(
        retry: null,
        name: r'formattedConsumptionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider that returns formatted consumption with current units

  FormattedConsumptionProvider call(double consumption) =>
      FormattedConsumptionProvider._(argument: consumption, from: this);

  @override
  String toString() => r'formattedConsumptionProvider';
}

/// Provider that returns formatted distance with current units

@ProviderFor(formattedDistance)
const formattedDistanceProvider = FormattedDistanceFamily._();

/// Provider that returns formatted distance with current units

final class FormattedDistanceProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provider that returns formatted distance with current units
  const FormattedDistanceProvider._({
    required FormattedDistanceFamily super.from,
    required double super.argument,
  }) : super(
         retry: null,
         name: r'formattedDistanceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$formattedDistanceHash();

  @override
  String toString() {
    return r'formattedDistanceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    final argument = this.argument as double;
    return formattedDistance(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FormattedDistanceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$formattedDistanceHash() => r'de02a32293984d553e7892dcae461a2135d0314b';

/// Provider that returns formatted distance with current units

final class FormattedDistanceFamily extends $Family
    with $FunctionalFamilyOverride<String, double> {
  const FormattedDistanceFamily._()
    : super(
        retry: null,
        name: r'formattedDistanceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider that returns formatted distance with current units

  FormattedDistanceProvider call(double distance) =>
      FormattedDistanceProvider._(argument: distance, from: this);

  @override
  String toString() => r'formattedDistanceProvider';
}

/// Provider that returns formatted volume with current units

@ProviderFor(formattedVolume)
const formattedVolumeProvider = FormattedVolumeFamily._();

/// Provider that returns formatted volume with current units

final class FormattedVolumeProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// Provider that returns formatted volume with current units
  const FormattedVolumeProvider._({
    required FormattedVolumeFamily super.from,
    required double super.argument,
  }) : super(
         retry: null,
         name: r'formattedVolumeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$formattedVolumeHash();

  @override
  String toString() {
    return r'formattedVolumeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    final argument = this.argument as double;
    return formattedVolume(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FormattedVolumeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$formattedVolumeHash() => r'6cfbd5ff3dc1f038280483fb9c65ef98989d396a';

/// Provider that returns formatted volume with current units

final class FormattedVolumeFamily extends $Family
    with $FunctionalFamilyOverride<String, double> {
  const FormattedVolumeFamily._()
    : super(
        retry: null,
        name: r'formattedVolumeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider that returns formatted volume with current units

  FormattedVolumeProvider call(double volume) =>
      FormattedVolumeProvider._(argument: volume, from: this);

  @override
  String toString() => r'formattedVolumeProvider';
}

/// Provider that returns consumption value in the current unit system

@ProviderFor(consumptionInCurrentUnits)
const consumptionInCurrentUnitsProvider = ConsumptionInCurrentUnitsFamily._();

/// Provider that returns consumption value in the current unit system

final class ConsumptionInCurrentUnitsProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Provider that returns consumption value in the current unit system
  const ConsumptionInCurrentUnitsProvider._({
    required ConsumptionInCurrentUnitsFamily super.from,
    required double super.argument,
  }) : super(
         retry: null,
         name: r'consumptionInCurrentUnitsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$consumptionInCurrentUnitsHash();

  @override
  String toString() {
    return r'consumptionInCurrentUnitsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as double;
    return consumptionInCurrentUnits(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ConsumptionInCurrentUnitsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$consumptionInCurrentUnitsHash() =>
    r'8511090ebefa2fcb9e524ee419fe0fe5ae80fecc';

/// Provider that returns consumption value in the current unit system

final class ConsumptionInCurrentUnitsFamily extends $Family
    with $FunctionalFamilyOverride<double, double> {
  const ConsumptionInCurrentUnitsFamily._()
    : super(
        retry: null,
        name: r'consumptionInCurrentUnitsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider that returns consumption value in the current unit system

  ConsumptionInCurrentUnitsProvider call(double metricConsumption) =>
      ConsumptionInCurrentUnitsProvider._(
        argument: metricConsumption,
        from: this,
      );

  @override
  String toString() => r'consumptionInCurrentUnitsProvider';
}

/// Provider that returns distance value in the current unit system

@ProviderFor(distanceInCurrentUnits)
const distanceInCurrentUnitsProvider = DistanceInCurrentUnitsFamily._();

/// Provider that returns distance value in the current unit system

final class DistanceInCurrentUnitsProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Provider that returns distance value in the current unit system
  const DistanceInCurrentUnitsProvider._({
    required DistanceInCurrentUnitsFamily super.from,
    required double super.argument,
  }) : super(
         retry: null,
         name: r'distanceInCurrentUnitsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$distanceInCurrentUnitsHash();

  @override
  String toString() {
    return r'distanceInCurrentUnitsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as double;
    return distanceInCurrentUnits(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DistanceInCurrentUnitsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$distanceInCurrentUnitsHash() =>
    r'd33365946e7b0b4ce9025e5d42ee037acbd3e109';

/// Provider that returns distance value in the current unit system

final class DistanceInCurrentUnitsFamily extends $Family
    with $FunctionalFamilyOverride<double, double> {
  const DistanceInCurrentUnitsFamily._()
    : super(
        retry: null,
        name: r'distanceInCurrentUnitsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider that returns distance value in the current unit system

  DistanceInCurrentUnitsProvider call(double kilometers) =>
      DistanceInCurrentUnitsProvider._(argument: kilometers, from: this);

  @override
  String toString() => r'distanceInCurrentUnitsProvider';
}

/// Provider that returns volume value in the current unit system

@ProviderFor(volumeInCurrentUnits)
const volumeInCurrentUnitsProvider = VolumeInCurrentUnitsFamily._();

/// Provider that returns volume value in the current unit system

final class VolumeInCurrentUnitsProvider
    extends $FunctionalProvider<double, double, double>
    with $Provider<double> {
  /// Provider that returns volume value in the current unit system
  const VolumeInCurrentUnitsProvider._({
    required VolumeInCurrentUnitsFamily super.from,
    required double super.argument,
  }) : super(
         retry: null,
         name: r'volumeInCurrentUnitsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$volumeInCurrentUnitsHash();

  @override
  String toString() {
    return r'volumeInCurrentUnitsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<double> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  double create(Ref ref) {
    final argument = this.argument as double;
    return volumeInCurrentUnits(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VolumeInCurrentUnitsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$volumeInCurrentUnitsHash() =>
    r'a656c426e1fde0dcc03ddb3940ec343082cbda08';

/// Provider that returns volume value in the current unit system

final class VolumeInCurrentUnitsFamily extends $Family
    with $FunctionalFamilyOverride<double, double> {
  const VolumeInCurrentUnitsFamily._()
    : super(
        retry: null,
        name: r'volumeInCurrentUnitsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider that returns volume value in the current unit system

  VolumeInCurrentUnitsProvider call(double liters) =>
      VolumeInCurrentUnitsProvider._(argument: liters, from: this);

  @override
  String toString() => r'volumeInCurrentUnitsProvider';
}
