// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the main database instance

@ProviderFor(database)
const databaseProvider = DatabaseProvider._();

/// Provides the main database instance

final class DatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// Provides the main database instance
  const DatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return database(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$databaseHash() => r'772b920829a0a5b16419f248cf9e9891f53cf5f8';

/// Provides the database service instance

@ProviderFor(databaseService)
const databaseServiceProvider = DatabaseServiceProvider._();

/// Provides the database service instance

final class DatabaseServiceProvider
    extends
        $FunctionalProvider<DatabaseService, DatabaseService, DatabaseService>
    with $Provider<DatabaseService> {
  /// Provides the database service instance
  const DatabaseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseServiceHash();

  @$internal
  @override
  $ProviderElement<DatabaseService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DatabaseService create(Ref ref) {
    return databaseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DatabaseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DatabaseService>(value),
    );
  }
}

String _$databaseServiceHash() => r'e0eeb57a46c4332cd9683224b259a22afb2cd152';

/// Provides the vehicle repository

@ProviderFor(vehicleRepository)
const vehicleRepositoryProvider = VehicleRepositoryProvider._();

/// Provides the vehicle repository

final class VehicleRepositoryProvider
    extends
        $FunctionalProvider<
          VehicleRepository,
          VehicleRepository,
          VehicleRepository
        >
    with $Provider<VehicleRepository> {
  /// Provides the vehicle repository
  const VehicleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleRepositoryHash();

  @$internal
  @override
  $ProviderElement<VehicleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VehicleRepository create(Ref ref) {
    return vehicleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VehicleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VehicleRepository>(value),
    );
  }
}

String _$vehicleRepositoryHash() => r'9add4b1fb80e4695a31ce70b55e85b94f58c00e2';

/// Provides the fuel entry repository

@ProviderFor(fuelEntryRepository)
const fuelEntryRepositoryProvider = FuelEntryRepositoryProvider._();

/// Provides the fuel entry repository

final class FuelEntryRepositoryProvider
    extends
        $FunctionalProvider<
          FuelEntryRepository,
          FuelEntryRepository,
          FuelEntryRepository
        >
    with $Provider<FuelEntryRepository> {
  /// Provides the fuel entry repository
  const FuelEntryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fuelEntryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fuelEntryRepositoryHash();

  @$internal
  @override
  $ProviderElement<FuelEntryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FuelEntryRepository create(Ref ref) {
    return fuelEntryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FuelEntryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FuelEntryRepository>(value),
    );
  }
}

String _$fuelEntryRepositoryHash() =>
    r'8514637f63b7ea41ff33f9e8f8849efbf8106e3f';
