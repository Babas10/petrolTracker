// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseHash() => r'b9333287adedf45761e6e47210847950a741314d';

/// Provides the main database instance
///
/// Copied from [database].
@ProviderFor(database)
final databaseProvider = Provider<AppDatabase>.internal(
  database,
  name: r'databaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$databaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseRef = ProviderRef<AppDatabase>;
String _$databaseServiceHash() => r'd52cb29bc412b76d62b73999ccbfec01b9b4d63c';

/// Provides the database service instance
///
/// Copied from [databaseService].
@ProviderFor(databaseService)
final databaseServiceProvider = Provider<DatabaseService>.internal(
  databaseService,
  name: r'databaseServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$databaseServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseServiceRef = ProviderRef<DatabaseService>;
String _$vehicleRepositoryHash() => r'811f0163ddefd4e4812188085d411974237b6f64';

/// Provides the vehicle repository
///
/// Copied from [vehicleRepository].
@ProviderFor(vehicleRepository)
final vehicleRepositoryProvider = Provider<VehicleRepository>.internal(
  vehicleRepository,
  name: r'vehicleRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$vehicleRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VehicleRepositoryRef = ProviderRef<VehicleRepository>;
String _$fuelEntryRepositoryHash() =>
    r'7a900452b4787bc26ce86750712e23a122cf854e';

/// Provides the fuel entry repository
///
/// Copied from [fuelEntryRepository].
@ProviderFor(fuelEntryRepository)
final fuelEntryRepositoryProvider = Provider<FuelEntryRepository>.internal(
  fuelEntryRepository,
  name: r'fuelEntryRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fuelEntryRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FuelEntryRepositoryRef = ProviderRef<FuelEntryRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
