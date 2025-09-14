// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fuel_entry_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing fuel entries state

@ProviderFor(FuelEntriesNotifier)
const fuelEntriesProvider = FuelEntriesNotifierProvider._();

/// Notifier for managing fuel entries state
final class FuelEntriesNotifierProvider
    extends $AsyncNotifierProvider<FuelEntriesNotifier, FuelEntryState> {
  /// Notifier for managing fuel entries state
  const FuelEntriesNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fuelEntriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fuelEntriesNotifierHash();

  @$internal
  @override
  FuelEntriesNotifier create() => FuelEntriesNotifier();
}

String _$fuelEntriesNotifierHash() =>
    r'184d95053cdbf2051480f8015e6b576a2ca23ef0';

/// Notifier for managing fuel entries state

abstract class _$FuelEntriesNotifier extends $AsyncNotifier<FuelEntryState> {
  FutureOr<FuelEntryState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<FuelEntryState>, FuelEntryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FuelEntryState>, FuelEntryState>,
              AsyncValue<FuelEntryState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for getting fuel entries by vehicle

@ProviderFor(fuelEntriesByVehicle)
const fuelEntriesByVehicleProvider = FuelEntriesByVehicleFamily._();

/// Provider for getting fuel entries by vehicle

final class FuelEntriesByVehicleProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FuelEntryModel>>,
          List<FuelEntryModel>,
          FutureOr<List<FuelEntryModel>>
        >
    with
        $FutureModifier<List<FuelEntryModel>>,
        $FutureProvider<List<FuelEntryModel>> {
  /// Provider for getting fuel entries by vehicle
  const FuelEntriesByVehicleProvider._({
    required FuelEntriesByVehicleFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'fuelEntriesByVehicleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fuelEntriesByVehicleHash();

  @override
  String toString() {
    return r'fuelEntriesByVehicleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<FuelEntryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FuelEntryModel>> create(Ref ref) {
    final argument = this.argument as int;
    return fuelEntriesByVehicle(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FuelEntriesByVehicleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fuelEntriesByVehicleHash() =>
    r'5fd2b79b3161a90d6c817393961cce114ff7dc63';

/// Provider for getting fuel entries by vehicle

final class FuelEntriesByVehicleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<FuelEntryModel>>, int> {
  const FuelEntriesByVehicleFamily._()
    : super(
        retry: null,
        name: r'fuelEntriesByVehicleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for getting fuel entries by vehicle

  FuelEntriesByVehicleProvider call(int vehicleId) =>
      FuelEntriesByVehicleProvider._(argument: vehicleId, from: this);

  @override
  String toString() => r'fuelEntriesByVehicleProvider';
}

/// Provider for getting fuel entries by date range

@ProviderFor(fuelEntriesByDateRange)
const fuelEntriesByDateRangeProvider = FuelEntriesByDateRangeFamily._();

/// Provider for getting fuel entries by date range

final class FuelEntriesByDateRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FuelEntryModel>>,
          List<FuelEntryModel>,
          FutureOr<List<FuelEntryModel>>
        >
    with
        $FutureModifier<List<FuelEntryModel>>,
        $FutureProvider<List<FuelEntryModel>> {
  /// Provider for getting fuel entries by date range
  const FuelEntriesByDateRangeProvider._({
    required FuelEntriesByDateRangeFamily super.from,
    required (DateTime, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'fuelEntriesByDateRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fuelEntriesByDateRangeHash();

  @override
  String toString() {
    return r'fuelEntriesByDateRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<FuelEntryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FuelEntryModel>> create(Ref ref) {
    final argument = this.argument as (DateTime, DateTime);
    return fuelEntriesByDateRange(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is FuelEntriesByDateRangeProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fuelEntriesByDateRangeHash() =>
    r'6b627459117190925fbf3a749ba133946f9b9a44';

/// Provider for getting fuel entries by date range

final class FuelEntriesByDateRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<FuelEntryModel>>,
          (DateTime, DateTime)
        > {
  const FuelEntriesByDateRangeFamily._()
    : super(
        retry: null,
        name: r'fuelEntriesByDateRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for getting fuel entries by date range

  FuelEntriesByDateRangeProvider call(DateTime startDate, DateTime endDate) =>
      FuelEntriesByDateRangeProvider._(
        argument: (startDate, endDate),
        from: this,
      );

  @override
  String toString() => r'fuelEntriesByDateRangeProvider';
}

/// Provider for getting fuel entries by vehicle and date range

@ProviderFor(fuelEntriesByVehicleAndDateRange)
const fuelEntriesByVehicleAndDateRangeProvider =
    FuelEntriesByVehicleAndDateRangeFamily._();

/// Provider for getting fuel entries by vehicle and date range

final class FuelEntriesByVehicleAndDateRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FuelEntryModel>>,
          List<FuelEntryModel>,
          FutureOr<List<FuelEntryModel>>
        >
    with
        $FutureModifier<List<FuelEntryModel>>,
        $FutureProvider<List<FuelEntryModel>> {
  /// Provider for getting fuel entries by vehicle and date range
  const FuelEntriesByVehicleAndDateRangeProvider._({
    required FuelEntriesByVehicleAndDateRangeFamily super.from,
    required (int, DateTime, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'fuelEntriesByVehicleAndDateRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fuelEntriesByVehicleAndDateRangeHash();

  @override
  String toString() {
    return r'fuelEntriesByVehicleAndDateRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<FuelEntryModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FuelEntryModel>> create(Ref ref) {
    final argument = this.argument as (int, DateTime, DateTime);
    return fuelEntriesByVehicleAndDateRange(
      ref,
      argument.$1,
      argument.$2,
      argument.$3,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FuelEntriesByVehicleAndDateRangeProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fuelEntriesByVehicleAndDateRangeHash() =>
    r'e961efb61828e184051945e456e3e404b168051d';

/// Provider for getting fuel entries by vehicle and date range

final class FuelEntriesByVehicleAndDateRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<FuelEntryModel>>,
          (int, DateTime, DateTime)
        > {
  const FuelEntriesByVehicleAndDateRangeFamily._()
    : super(
        retry: null,
        name: r'fuelEntriesByVehicleAndDateRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for getting fuel entries by vehicle and date range

  FuelEntriesByVehicleAndDateRangeProvider call(
    int vehicleId,
    DateTime startDate,
    DateTime endDate,
  ) => FuelEntriesByVehicleAndDateRangeProvider._(
    argument: (vehicleId, startDate, endDate),
    from: this,
  );

  @override
  String toString() => r'fuelEntriesByVehicleAndDateRangeProvider';
}

/// Provider for getting the latest fuel entry for a vehicle

@ProviderFor(latestFuelEntryForVehicle)
const latestFuelEntryForVehicleProvider = LatestFuelEntryForVehicleFamily._();

/// Provider for getting the latest fuel entry for a vehicle

final class LatestFuelEntryForVehicleProvider
    extends
        $FunctionalProvider<
          AsyncValue<FuelEntryModel?>,
          FuelEntryModel?,
          FutureOr<FuelEntryModel?>
        >
    with $FutureModifier<FuelEntryModel?>, $FutureProvider<FuelEntryModel?> {
  /// Provider for getting the latest fuel entry for a vehicle
  const LatestFuelEntryForVehicleProvider._({
    required LatestFuelEntryForVehicleFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'latestFuelEntryForVehicleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$latestFuelEntryForVehicleHash();

  @override
  String toString() {
    return r'latestFuelEntryForVehicleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FuelEntryModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FuelEntryModel?> create(Ref ref) {
    final argument = this.argument as int;
    return latestFuelEntryForVehicle(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LatestFuelEntryForVehicleProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$latestFuelEntryForVehicleHash() =>
    r'b5c25b484f301c78308dda7f4e97de3c4f2d17c9';

/// Provider for getting the latest fuel entry for a vehicle

final class LatestFuelEntryForVehicleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FuelEntryModel?>, int> {
  const LatestFuelEntryForVehicleFamily._()
    : super(
        retry: null,
        name: r'latestFuelEntryForVehicleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for getting the latest fuel entry for a vehicle

  LatestFuelEntryForVehicleProvider call(int vehicleId) =>
      LatestFuelEntryForVehicleProvider._(argument: vehicleId, from: this);

  @override
  String toString() => r'latestFuelEntryForVehicleProvider';
}

/// Provider for getting a specific fuel entry by ID

@ProviderFor(fuelEntry)
const fuelEntryProvider = FuelEntryFamily._();

/// Provider for getting a specific fuel entry by ID

final class FuelEntryProvider
    extends
        $FunctionalProvider<
          AsyncValue<FuelEntryModel?>,
          FuelEntryModel?,
          FutureOr<FuelEntryModel?>
        >
    with $FutureModifier<FuelEntryModel?>, $FutureProvider<FuelEntryModel?> {
  /// Provider for getting a specific fuel entry by ID
  const FuelEntryProvider._({
    required FuelEntryFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'fuelEntryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fuelEntryHash();

  @override
  String toString() {
    return r'fuelEntryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FuelEntryModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FuelEntryModel?> create(Ref ref) {
    final argument = this.argument as int;
    return fuelEntry(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FuelEntryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fuelEntryHash() => r'34f4a7c390c9587e6a4adb842a39a6d5a95a7f43';

/// Provider for getting a specific fuel entry by ID

final class FuelEntryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FuelEntryModel?>, int> {
  const FuelEntryFamily._()
    : super(
        retry: null,
        name: r'fuelEntryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for getting a specific fuel entry by ID

  FuelEntryProvider call(int entryId) =>
      FuelEntryProvider._(argument: entryId, from: this);

  @override
  String toString() => r'fuelEntryProvider';
}

/// Provider for getting fuel entry count

@ProviderFor(fuelEntryCount)
const fuelEntryCountProvider = FuelEntryCountProvider._();

/// Provider for getting fuel entry count

final class FuelEntryCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for getting fuel entry count
  const FuelEntryCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fuelEntryCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fuelEntryCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return fuelEntryCount(ref);
  }
}

String _$fuelEntryCountHash() => r'39b48514e8ee5bb726028a1abe442d9d1c5bedcd';

/// Provider for getting fuel entry count for a specific vehicle

@ProviderFor(fuelEntryCountForVehicle)
const fuelEntryCountForVehicleProvider = FuelEntryCountForVehicleFamily._();

/// Provider for getting fuel entry count for a specific vehicle

final class FuelEntryCountForVehicleProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for getting fuel entry count for a specific vehicle
  const FuelEntryCountForVehicleProvider._({
    required FuelEntryCountForVehicleFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'fuelEntryCountForVehicleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fuelEntryCountForVehicleHash();

  @override
  String toString() {
    return r'fuelEntryCountForVehicleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as int;
    return fuelEntryCountForVehicle(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FuelEntryCountForVehicleProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fuelEntryCountForVehicleHash() =>
    r'5aa2e9016c401f8eb67def0325696f0d984a037a';

/// Provider for getting fuel entry count for a specific vehicle

final class FuelEntryCountForVehicleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, int> {
  const FuelEntryCountForVehicleFamily._()
    : super(
        retry: null,
        name: r'fuelEntryCountForVehicleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for getting fuel entry count for a specific vehicle

  FuelEntryCountForVehicleProvider call(int vehicleId) =>
      FuelEntryCountForVehicleProvider._(argument: vehicleId, from: this);

  @override
  String toString() => r'fuelEntryCountForVehicleProvider';
}

/// Provider for getting fuel entries grouped by country

@ProviderFor(fuelEntriesGroupedByCountry)
const fuelEntriesGroupedByCountryProvider =
    FuelEntriesGroupedByCountryProvider._();

/// Provider for getting fuel entries grouped by country

final class FuelEntriesGroupedByCountryProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, List<FuelEntryModel>>>,
          Map<String, List<FuelEntryModel>>,
          FutureOr<Map<String, List<FuelEntryModel>>>
        >
    with
        $FutureModifier<Map<String, List<FuelEntryModel>>>,
        $FutureProvider<Map<String, List<FuelEntryModel>>> {
  /// Provider for getting fuel entries grouped by country
  const FuelEntriesGroupedByCountryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fuelEntriesGroupedByCountryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fuelEntriesGroupedByCountryHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, List<FuelEntryModel>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, List<FuelEntryModel>>> create(Ref ref) {
    return fuelEntriesGroupedByCountry(ref);
  }
}

String _$fuelEntriesGroupedByCountryHash() =>
    r'faa29a1192fbb8820ed5994eb02ecaec9248cb2e';

/// Provider for getting average consumption for a vehicle

@ProviderFor(averageConsumptionForVehicle)
const averageConsumptionForVehicleProvider =
    AverageConsumptionForVehicleFamily._();

/// Provider for getting average consumption for a vehicle

final class AverageConsumptionForVehicleProvider
    extends $FunctionalProvider<AsyncValue<double?>, double?, FutureOr<double?>>
    with $FutureModifier<double?>, $FutureProvider<double?> {
  /// Provider for getting average consumption for a vehicle
  const AverageConsumptionForVehicleProvider._({
    required AverageConsumptionForVehicleFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'averageConsumptionForVehicleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$averageConsumptionForVehicleHash();

  @override
  String toString() {
    return r'averageConsumptionForVehicleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<double?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<double?> create(Ref ref) {
    final argument = this.argument as int;
    return averageConsumptionForVehicle(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AverageConsumptionForVehicleProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$averageConsumptionForVehicleHash() =>
    r'be55a727345fa8a74dc20fd27be9bee6ffd91657';

/// Provider for getting average consumption for a vehicle

final class AverageConsumptionForVehicleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<double?>, int> {
  const AverageConsumptionForVehicleFamily._()
    : super(
        retry: null,
        name: r'averageConsumptionForVehicleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for getting average consumption for a vehicle

  AverageConsumptionForVehicleProvider call(int vehicleId) =>
      AverageConsumptionForVehicleProvider._(argument: vehicleId, from: this);

  @override
  String toString() => r'averageConsumptionForVehicleProvider';
}
