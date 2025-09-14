// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing vehicles state

@ProviderFor(VehiclesNotifier)
const vehiclesProvider = VehiclesNotifierProvider._();

/// Notifier for managing vehicles state
final class VehiclesNotifierProvider
    extends $AsyncNotifierProvider<VehiclesNotifier, VehicleState> {
  /// Notifier for managing vehicles state
  const VehiclesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehiclesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehiclesNotifierHash();

  @$internal
  @override
  VehiclesNotifier create() => VehiclesNotifier();
}

String _$vehiclesNotifierHash() => r'b05b7cb85018541aa8ace59aca90fdf66e85e1ad';

/// Notifier for managing vehicles state

abstract class _$VehiclesNotifier extends $AsyncNotifier<VehicleState> {
  FutureOr<VehicleState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<VehicleState>, VehicleState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<VehicleState>, VehicleState>,
              AsyncValue<VehicleState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for getting a specific vehicle by ID

@ProviderFor(vehicle)
const vehicleProvider = VehicleFamily._();

/// Provider for getting a specific vehicle by ID

final class VehicleProvider
    extends
        $FunctionalProvider<
          AsyncValue<VehicleModel?>,
          VehicleModel?,
          FutureOr<VehicleModel?>
        >
    with $FutureModifier<VehicleModel?>, $FutureProvider<VehicleModel?> {
  /// Provider for getting a specific vehicle by ID
  const VehicleProvider._({
    required VehicleFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'vehicleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vehicleHash();

  @override
  String toString() {
    return r'vehicleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<VehicleModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<VehicleModel?> create(Ref ref) {
    final argument = this.argument as int;
    return vehicle(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VehicleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vehicleHash() => r'7d180ab5d5afcafd5556e43669685d2974bf2567';

/// Provider for getting a specific vehicle by ID

final class VehicleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<VehicleModel?>, int> {
  const VehicleFamily._()
    : super(
        retry: null,
        name: r'vehicleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for getting a specific vehicle by ID

  VehicleProvider call(int vehicleId) =>
      VehicleProvider._(argument: vehicleId, from: this);

  @override
  String toString() => r'vehicleProvider';
}

/// Provider for checking if a vehicle name exists

@ProviderFor(vehicleNameExists)
const vehicleNameExistsProvider = VehicleNameExistsFamily._();

/// Provider for checking if a vehicle name exists

final class VehicleNameExistsProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider for checking if a vehicle name exists
  const VehicleNameExistsProvider._({
    required VehicleNameExistsFamily super.from,
    required (String, {int? excludeId}) super.argument,
  }) : super(
         retry: null,
         name: r'vehicleNameExistsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vehicleNameExistsHash();

  @override
  String toString() {
    return r'vehicleNameExistsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as (String, {int? excludeId});
    return vehicleNameExists(ref, argument.$1, excludeId: argument.excludeId);
  }

  @override
  bool operator ==(Object other) {
    return other is VehicleNameExistsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vehicleNameExistsHash() => r'79de066b18f3893d0d5d3193d5829767f0a3aadc';

/// Provider for checking if a vehicle name exists

final class VehicleNameExistsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, (String, {int? excludeId})> {
  const VehicleNameExistsFamily._()
    : super(
        retry: null,
        name: r'vehicleNameExistsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for checking if a vehicle name exists

  VehicleNameExistsProvider call(String vehicleName, {int? excludeId}) =>
      VehicleNameExistsProvider._(
        argument: (vehicleName, excludeId: excludeId),
        from: this,
      );

  @override
  String toString() => r'vehicleNameExistsProvider';
}

/// Provider for getting vehicle count

@ProviderFor(vehicleCount)
const vehicleCountProvider = VehicleCountProvider._();

/// Provider for getting vehicle count

final class VehicleCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for getting vehicle count
  const VehicleCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return vehicleCount(ref);
  }
}

String _$vehicleCountHash() => r'88bf21f3243c57bcd92a6d29ce4cce5fc3eb30aa';

/// Provider for getting vehicle statistics

@ProviderFor(vehicleStatistics)
const vehicleStatisticsProvider = VehicleStatisticsFamily._();

/// Provider for getting vehicle statistics

final class VehicleStatisticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<VehicleStatistics>,
          VehicleStatistics,
          FutureOr<VehicleStatistics>
        >
    with
        $FutureModifier<VehicleStatistics>,
        $FutureProvider<VehicleStatistics> {
  /// Provider for getting vehicle statistics
  const VehicleStatisticsProvider._({
    required VehicleStatisticsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'vehicleStatisticsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vehicleStatisticsHash();

  @override
  String toString() {
    return r'vehicleStatisticsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<VehicleStatistics> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<VehicleStatistics> create(Ref ref) {
    final argument = this.argument as int;
    return vehicleStatistics(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is VehicleStatisticsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vehicleStatisticsHash() => r'75774f0d01c3644f1dc37be38c3ad2edde470dcb';

/// Provider for getting vehicle statistics

final class VehicleStatisticsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<VehicleStatistics>, int> {
  const VehicleStatisticsFamily._()
    : super(
        retry: null,
        name: r'vehicleStatisticsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for getting vehicle statistics

  VehicleStatisticsProvider call(int vehicleId) =>
      VehicleStatisticsProvider._(argument: vehicleId, from: this);

  @override
  String toString() => r'vehicleStatisticsProvider';
}

/// Provider for getting vehicles with basic statistics

@ProviderFor(vehiclesWithStats)
const vehiclesWithStatsProvider = VehiclesWithStatsProvider._();

/// Provider for getting vehicles with basic statistics

final class VehiclesWithStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          FutureOr<List<Map<String, dynamic>>>
        >
    with
        $FutureModifier<List<Map<String, dynamic>>>,
        $FutureProvider<List<Map<String, dynamic>>> {
  /// Provider for getting vehicles with basic statistics
  const VehiclesWithStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehiclesWithStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehiclesWithStatsHash();

  @$internal
  @override
  $FutureProviderElement<List<Map<String, dynamic>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Map<String, dynamic>>> create(Ref ref) {
    return vehiclesWithStats(ref);
  }
}

String _$vehiclesWithStatsHash() => r'dd371138f9aaa7a5c13aedc416b8560f098b7bc1';

/// Provider for checking ephemeral storage health

@ProviderFor(ephemeralStorageHealth)
const ephemeralStorageHealthProvider = EphemeralStorageHealthProvider._();

/// Provider for checking ephemeral storage health

final class EphemeralStorageHealthProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider for checking ephemeral storage health
  const EphemeralStorageHealthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ephemeralStorageHealthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ephemeralStorageHealthHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return ephemeralStorageHealth(ref);
  }
}

String _$ephemeralStorageHealthHash() =>
    r'31b5c59adf0a8ab9697df39df8e2e5d7c775c6b0';
