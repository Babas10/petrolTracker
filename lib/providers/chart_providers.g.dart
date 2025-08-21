// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$consumptionChartDataHash() =>
    r'a479704261fd7d33c8a7c47c51386695c2058611';

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

/// Provider for consumption chart data for a specific vehicle
/// Uses period-based consumption calculation (full tank to full tank)
///
/// Copied from [consumptionChartData].
@ProviderFor(consumptionChartData)
const consumptionChartDataProvider = ConsumptionChartDataFamily();

/// Provider for consumption chart data for a specific vehicle
/// Uses period-based consumption calculation (full tank to full tank)
///
/// Copied from [consumptionChartData].
class ConsumptionChartDataFamily
    extends Family<AsyncValue<List<ConsumptionDataPoint>>> {
  /// Provider for consumption chart data for a specific vehicle
  /// Uses period-based consumption calculation (full tank to full tank)
  ///
  /// Copied from [consumptionChartData].
  const ConsumptionChartDataFamily();

  /// Provider for consumption chart data for a specific vehicle
  /// Uses period-based consumption calculation (full tank to full tank)
  ///
  /// Copied from [consumptionChartData].
  ConsumptionChartDataProvider call(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
    String? countryFilter,
  }) {
    return ConsumptionChartDataProvider(
      vehicleId,
      startDate: startDate,
      endDate: endDate,
      countryFilter: countryFilter,
    );
  }

  @override
  ConsumptionChartDataProvider getProviderOverride(
    covariant ConsumptionChartDataProvider provider,
  ) {
    return call(
      provider.vehicleId,
      startDate: provider.startDate,
      endDate: provider.endDate,
      countryFilter: provider.countryFilter,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'consumptionChartDataProvider';
}

/// Provider for consumption chart data for a specific vehicle
/// Uses period-based consumption calculation (full tank to full tank)
///
/// Copied from [consumptionChartData].
class ConsumptionChartDataProvider
    extends AutoDisposeFutureProvider<List<ConsumptionDataPoint>> {
  /// Provider for consumption chart data for a specific vehicle
  /// Uses period-based consumption calculation (full tank to full tank)
  ///
  /// Copied from [consumptionChartData].
  ConsumptionChartDataProvider(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
    String? countryFilter,
  }) : this._internal(
         (ref) => consumptionChartData(
           ref as ConsumptionChartDataRef,
           vehicleId,
           startDate: startDate,
           endDate: endDate,
           countryFilter: countryFilter,
         ),
         from: consumptionChartDataProvider,
         name: r'consumptionChartDataProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$consumptionChartDataHash,
         dependencies: ConsumptionChartDataFamily._dependencies,
         allTransitiveDependencies:
             ConsumptionChartDataFamily._allTransitiveDependencies,
         vehicleId: vehicleId,
         startDate: startDate,
         endDate: endDate,
         countryFilter: countryFilter,
       );

  ConsumptionChartDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
    required this.countryFilter,
  }) : super.internal();

  final int vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? countryFilter;

  @override
  Override overrideWith(
    FutureOr<List<ConsumptionDataPoint>> Function(
      ConsumptionChartDataRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConsumptionChartDataProvider._internal(
        (ref) => create(ref as ConsumptionChartDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        vehicleId: vehicleId,
        startDate: startDate,
        endDate: endDate,
        countryFilter: countryFilter,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ConsumptionDataPoint>> createElement() {
    return _ConsumptionChartDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConsumptionChartDataProvider &&
        other.vehicleId == vehicleId &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.countryFilter == countryFilter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, vehicleId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);
    hash = _SystemHash.combine(hash, countryFilter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConsumptionChartDataRef
    on AutoDisposeFutureProviderRef<List<ConsumptionDataPoint>> {
  /// The parameter `vehicleId` of this provider.
  int get vehicleId;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;

  /// The parameter `countryFilter` of this provider.
  String? get countryFilter;
}

class _ConsumptionChartDataProviderElement
    extends AutoDisposeFutureProviderElement<List<ConsumptionDataPoint>>
    with ConsumptionChartDataRef {
  _ConsumptionChartDataProviderElement(super.provider);

  @override
  int get vehicleId => (origin as ConsumptionChartDataProvider).vehicleId;
  @override
  DateTime? get startDate => (origin as ConsumptionChartDataProvider).startDate;
  @override
  DateTime? get endDate => (origin as ConsumptionChartDataProvider).endDate;
  @override
  String? get countryFilter =>
      (origin as ConsumptionChartDataProvider).countryFilter;
}

String _$priceTrendChartDataHash() =>
    r'4ecd4057cd25d681b12098d4c823a544f83683ca';

/// Provider for price trend chart data
///
/// Copied from [priceTrendChartData].
@ProviderFor(priceTrendChartData)
const priceTrendChartDataProvider = PriceTrendChartDataFamily();

/// Provider for price trend chart data
///
/// Copied from [priceTrendChartData].
class PriceTrendChartDataFamily
    extends Family<AsyncValue<List<PriceTrendDataPoint>>> {
  /// Provider for price trend chart data
  ///
  /// Copied from [priceTrendChartData].
  const PriceTrendChartDataFamily();

  /// Provider for price trend chart data
  ///
  /// Copied from [priceTrendChartData].
  PriceTrendChartDataProvider call({DateTime? startDate, DateTime? endDate}) {
    return PriceTrendChartDataProvider(startDate: startDate, endDate: endDate);
  }

  @override
  PriceTrendChartDataProvider getProviderOverride(
    covariant PriceTrendChartDataProvider provider,
  ) {
    return call(startDate: provider.startDate, endDate: provider.endDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'priceTrendChartDataProvider';
}

/// Provider for price trend chart data
///
/// Copied from [priceTrendChartData].
class PriceTrendChartDataProvider
    extends AutoDisposeFutureProvider<List<PriceTrendDataPoint>> {
  /// Provider for price trend chart data
  ///
  /// Copied from [priceTrendChartData].
  PriceTrendChartDataProvider({DateTime? startDate, DateTime? endDate})
    : this._internal(
        (ref) => priceTrendChartData(
          ref as PriceTrendChartDataRef,
          startDate: startDate,
          endDate: endDate,
        ),
        from: priceTrendChartDataProvider,
        name: r'priceTrendChartDataProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$priceTrendChartDataHash,
        dependencies: PriceTrendChartDataFamily._dependencies,
        allTransitiveDependencies:
            PriceTrendChartDataFamily._allTransitiveDependencies,
        startDate: startDate,
        endDate: endDate,
      );

  PriceTrendChartDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Override overrideWith(
    FutureOr<List<PriceTrendDataPoint>> Function(
      PriceTrendChartDataRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PriceTrendChartDataProvider._internal(
        (ref) => create(ref as PriceTrendChartDataRef),
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
  AutoDisposeFutureProviderElement<List<PriceTrendDataPoint>> createElement() {
    return _PriceTrendChartDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PriceTrendChartDataProvider &&
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
mixin PriceTrendChartDataRef
    on AutoDisposeFutureProviderRef<List<PriceTrendDataPoint>> {
  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _PriceTrendChartDataProviderElement
    extends AutoDisposeFutureProviderElement<List<PriceTrendDataPoint>>
    with PriceTrendChartDataRef {
  _PriceTrendChartDataProviderElement(super.provider);

  @override
  DateTime? get startDate => (origin as PriceTrendChartDataProvider).startDate;
  @override
  DateTime? get endDate => (origin as PriceTrendChartDataProvider).endDate;
}

String _$monthlyConsumptionAveragesHash() =>
    r'82efc3de0d53f3ff88f819bd606e8da75394d9c0';

/// Provider for monthly consumption averages for a vehicle
///
/// Copied from [monthlyConsumptionAverages].
@ProviderFor(monthlyConsumptionAverages)
const monthlyConsumptionAveragesProvider = MonthlyConsumptionAveragesFamily();

/// Provider for monthly consumption averages for a vehicle
///
/// Copied from [monthlyConsumptionAverages].
class MonthlyConsumptionAveragesFamily
    extends Family<AsyncValue<Map<String, double>>> {
  /// Provider for monthly consumption averages for a vehicle
  ///
  /// Copied from [monthlyConsumptionAverages].
  const MonthlyConsumptionAveragesFamily();

  /// Provider for monthly consumption averages for a vehicle
  ///
  /// Copied from [monthlyConsumptionAverages].
  MonthlyConsumptionAveragesProvider call(int vehicleId, int year) {
    return MonthlyConsumptionAveragesProvider(vehicleId, year);
  }

  @override
  MonthlyConsumptionAveragesProvider getProviderOverride(
    covariant MonthlyConsumptionAveragesProvider provider,
  ) {
    return call(provider.vehicleId, provider.year);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monthlyConsumptionAveragesProvider';
}

/// Provider for monthly consumption averages for a vehicle
///
/// Copied from [monthlyConsumptionAverages].
class MonthlyConsumptionAveragesProvider
    extends AutoDisposeFutureProvider<Map<String, double>> {
  /// Provider for monthly consumption averages for a vehicle
  ///
  /// Copied from [monthlyConsumptionAverages].
  MonthlyConsumptionAveragesProvider(int vehicleId, int year)
    : this._internal(
        (ref) => monthlyConsumptionAverages(
          ref as MonthlyConsumptionAveragesRef,
          vehicleId,
          year,
        ),
        from: monthlyConsumptionAveragesProvider,
        name: r'monthlyConsumptionAveragesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$monthlyConsumptionAveragesHash,
        dependencies: MonthlyConsumptionAveragesFamily._dependencies,
        allTransitiveDependencies:
            MonthlyConsumptionAveragesFamily._allTransitiveDependencies,
        vehicleId: vehicleId,
        year: year,
      );

  MonthlyConsumptionAveragesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.vehicleId,
    required this.year,
  }) : super.internal();

  final int vehicleId;
  final int year;

  @override
  Override overrideWith(
    FutureOr<Map<String, double>> Function(
      MonthlyConsumptionAveragesRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlyConsumptionAveragesProvider._internal(
        (ref) => create(ref as MonthlyConsumptionAveragesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        vehicleId: vehicleId,
        year: year,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, double>> createElement() {
    return _MonthlyConsumptionAveragesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyConsumptionAveragesProvider &&
        other.vehicleId == vehicleId &&
        other.year == year;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, vehicleId.hashCode);
    hash = _SystemHash.combine(hash, year.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MonthlyConsumptionAveragesRef
    on AutoDisposeFutureProviderRef<Map<String, double>> {
  /// The parameter `vehicleId` of this provider.
  int get vehicleId;

  /// The parameter `year` of this provider.
  int get year;
}

class _MonthlyConsumptionAveragesProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, double>>
    with MonthlyConsumptionAveragesRef {
  _MonthlyConsumptionAveragesProviderElement(super.provider);

  @override
  int get vehicleId => (origin as MonthlyConsumptionAveragesProvider).vehicleId;
  @override
  int get year => (origin as MonthlyConsumptionAveragesProvider).year;
}

String _$costAnalysisDataHash() => r'7e3ffaf8db252a2e6aa88c0c728e65135c9471d3';

/// Provider for cost analysis data
///
/// Copied from [costAnalysisData].
@ProviderFor(costAnalysisData)
const costAnalysisDataProvider = CostAnalysisDataFamily();

/// Provider for cost analysis data
///
/// Copied from [costAnalysisData].
class CostAnalysisDataFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// Provider for cost analysis data
  ///
  /// Copied from [costAnalysisData].
  const CostAnalysisDataFamily();

  /// Provider for cost analysis data
  ///
  /// Copied from [costAnalysisData].
  CostAnalysisDataProvider call(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return CostAnalysisDataProvider(
      vehicleId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  CostAnalysisDataProvider getProviderOverride(
    covariant CostAnalysisDataProvider provider,
  ) {
    return call(
      provider.vehicleId,
      startDate: provider.startDate,
      endDate: provider.endDate,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'costAnalysisDataProvider';
}

/// Provider for cost analysis data
///
/// Copied from [costAnalysisData].
class CostAnalysisDataProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// Provider for cost analysis data
  ///
  /// Copied from [costAnalysisData].
  CostAnalysisDataProvider(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) : this._internal(
         (ref) => costAnalysisData(
           ref as CostAnalysisDataRef,
           vehicleId,
           startDate: startDate,
           endDate: endDate,
         ),
         from: costAnalysisDataProvider,
         name: r'costAnalysisDataProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$costAnalysisDataHash,
         dependencies: CostAnalysisDataFamily._dependencies,
         allTransitiveDependencies:
             CostAnalysisDataFamily._allTransitiveDependencies,
         vehicleId: vehicleId,
         startDate: startDate,
         endDate: endDate,
       );

  CostAnalysisDataProvider._internal(
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
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(CostAnalysisDataRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CostAnalysisDataProvider._internal(
        (ref) => create(ref as CostAnalysisDataRef),
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
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _CostAnalysisDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CostAnalysisDataProvider &&
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
mixin CostAnalysisDataRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `vehicleId` of this provider.
  int get vehicleId;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _CostAnalysisDataProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with CostAnalysisDataRef {
  _CostAnalysisDataProviderElement(super.provider);

  @override
  int get vehicleId => (origin as CostAnalysisDataProvider).vehicleId;
  @override
  DateTime? get startDate => (origin as CostAnalysisDataProvider).startDate;
  @override
  DateTime? get endDate => (origin as CostAnalysisDataProvider).endDate;
}

String _$countryPriceComparisonHash() =>
    r'4ff1863f6dce6149ec994d915af906da78624dc8';

/// Provider for country-wise fuel price comparison
///
/// Copied from [countryPriceComparison].
@ProviderFor(countryPriceComparison)
const countryPriceComparisonProvider = CountryPriceComparisonFamily();

/// Provider for country-wise fuel price comparison
///
/// Copied from [countryPriceComparison].
class CountryPriceComparisonFamily
    extends Family<AsyncValue<Map<String, double>>> {
  /// Provider for country-wise fuel price comparison
  ///
  /// Copied from [countryPriceComparison].
  const CountryPriceComparisonFamily();

  /// Provider for country-wise fuel price comparison
  ///
  /// Copied from [countryPriceComparison].
  CountryPriceComparisonProvider call({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return CountryPriceComparisonProvider(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  CountryPriceComparisonProvider getProviderOverride(
    covariant CountryPriceComparisonProvider provider,
  ) {
    return call(startDate: provider.startDate, endDate: provider.endDate);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'countryPriceComparisonProvider';
}

/// Provider for country-wise fuel price comparison
///
/// Copied from [countryPriceComparison].
class CountryPriceComparisonProvider
    extends AutoDisposeFutureProvider<Map<String, double>> {
  /// Provider for country-wise fuel price comparison
  ///
  /// Copied from [countryPriceComparison].
  CountryPriceComparisonProvider({DateTime? startDate, DateTime? endDate})
    : this._internal(
        (ref) => countryPriceComparison(
          ref as CountryPriceComparisonRef,
          startDate: startDate,
          endDate: endDate,
        ),
        from: countryPriceComparisonProvider,
        name: r'countryPriceComparisonProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$countryPriceComparisonHash,
        dependencies: CountryPriceComparisonFamily._dependencies,
        allTransitiveDependencies:
            CountryPriceComparisonFamily._allTransitiveDependencies,
        startDate: startDate,
        endDate: endDate,
      );

  CountryPriceComparisonProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Override overrideWith(
    FutureOr<Map<String, double>> Function(CountryPriceComparisonRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CountryPriceComparisonProvider._internal(
        (ref) => create(ref as CountryPriceComparisonRef),
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
  AutoDisposeFutureProviderElement<Map<String, double>> createElement() {
    return _CountryPriceComparisonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CountryPriceComparisonProvider &&
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
mixin CountryPriceComparisonRef
    on AutoDisposeFutureProviderRef<Map<String, double>> {
  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _CountryPriceComparisonProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, double>>
    with CountryPriceComparisonRef {
  _CountryPriceComparisonProviderElement(super.provider);

  @override
  DateTime? get startDate =>
      (origin as CountryPriceComparisonProvider).startDate;
  @override
  DateTime? get endDate => (origin as CountryPriceComparisonProvider).endDate;
}

String _$monthlySpendingDataHash() =>
    r'ebf947e213c8cee60e816d69758c74b3c87b303f';

/// Provider for monthly spending data (Issue #11)
///
/// Copied from [monthlySpendingData].
@ProviderFor(monthlySpendingData)
const monthlySpendingDataProvider = MonthlySpendingDataFamily();

/// Provider for monthly spending data (Issue #11)
///
/// Copied from [monthlySpendingData].
class MonthlySpendingDataFamily
    extends Family<AsyncValue<List<SpendingDataPoint>>> {
  /// Provider for monthly spending data (Issue #11)
  ///
  /// Copied from [monthlySpendingData].
  const MonthlySpendingDataFamily();

  /// Provider for monthly spending data (Issue #11)
  ///
  /// Copied from [monthlySpendingData].
  MonthlySpendingDataProvider call(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
    String? countryFilter,
  }) {
    return MonthlySpendingDataProvider(
      vehicleId,
      startDate: startDate,
      endDate: endDate,
      countryFilter: countryFilter,
    );
  }

  @override
  MonthlySpendingDataProvider getProviderOverride(
    covariant MonthlySpendingDataProvider provider,
  ) {
    return call(
      provider.vehicleId,
      startDate: provider.startDate,
      endDate: provider.endDate,
      countryFilter: provider.countryFilter,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'monthlySpendingDataProvider';
}

/// Provider for monthly spending data (Issue #11)
///
/// Copied from [monthlySpendingData].
class MonthlySpendingDataProvider
    extends AutoDisposeFutureProvider<List<SpendingDataPoint>> {
  /// Provider for monthly spending data (Issue #11)
  ///
  /// Copied from [monthlySpendingData].
  MonthlySpendingDataProvider(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
    String? countryFilter,
  }) : this._internal(
         (ref) => monthlySpendingData(
           ref as MonthlySpendingDataRef,
           vehicleId,
           startDate: startDate,
           endDate: endDate,
           countryFilter: countryFilter,
         ),
         from: monthlySpendingDataProvider,
         name: r'monthlySpendingDataProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$monthlySpendingDataHash,
         dependencies: MonthlySpendingDataFamily._dependencies,
         allTransitiveDependencies:
             MonthlySpendingDataFamily._allTransitiveDependencies,
         vehicleId: vehicleId,
         startDate: startDate,
         endDate: endDate,
         countryFilter: countryFilter,
       );

  MonthlySpendingDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
    required this.countryFilter,
  }) : super.internal();

  final int vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? countryFilter;

  @override
  Override overrideWith(
    FutureOr<List<SpendingDataPoint>> Function(MonthlySpendingDataRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MonthlySpendingDataProvider._internal(
        (ref) => create(ref as MonthlySpendingDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        vehicleId: vehicleId,
        startDate: startDate,
        endDate: endDate,
        countryFilter: countryFilter,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<SpendingDataPoint>> createElement() {
    return _MonthlySpendingDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlySpendingDataProvider &&
        other.vehicleId == vehicleId &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.countryFilter == countryFilter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, vehicleId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);
    hash = _SystemHash.combine(hash, countryFilter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MonthlySpendingDataRef
    on AutoDisposeFutureProviderRef<List<SpendingDataPoint>> {
  /// The parameter `vehicleId` of this provider.
  int get vehicleId;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;

  /// The parameter `countryFilter` of this provider.
  String? get countryFilter;
}

class _MonthlySpendingDataProviderElement
    extends AutoDisposeFutureProviderElement<List<SpendingDataPoint>>
    with MonthlySpendingDataRef {
  _MonthlySpendingDataProviderElement(super.provider);

  @override
  int get vehicleId => (origin as MonthlySpendingDataProvider).vehicleId;
  @override
  DateTime? get startDate => (origin as MonthlySpendingDataProvider).startDate;
  @override
  DateTime? get endDate => (origin as MonthlySpendingDataProvider).endDate;
  @override
  String? get countryFilter =>
      (origin as MonthlySpendingDataProvider).countryFilter;
}

String _$countrySpendingComparisonHash() =>
    r'd06c93cd3572220e0ca050795daea952d4e278b9';

/// Provider for country spending comparison (Issues #10, #11)
///
/// Copied from [countrySpendingComparison].
@ProviderFor(countrySpendingComparison)
const countrySpendingComparisonProvider = CountrySpendingComparisonFamily();

/// Provider for country spending comparison (Issues #10, #11)
///
/// Copied from [countrySpendingComparison].
class CountrySpendingComparisonFamily
    extends Family<AsyncValue<List<CountrySpendingDataPoint>>> {
  /// Provider for country spending comparison (Issues #10, #11)
  ///
  /// Copied from [countrySpendingComparison].
  const CountrySpendingComparisonFamily();

  /// Provider for country spending comparison (Issues #10, #11)
  ///
  /// Copied from [countrySpendingComparison].
  CountrySpendingComparisonProvider call(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return CountrySpendingComparisonProvider(
      vehicleId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  CountrySpendingComparisonProvider getProviderOverride(
    covariant CountrySpendingComparisonProvider provider,
  ) {
    return call(
      provider.vehicleId,
      startDate: provider.startDate,
      endDate: provider.endDate,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'countrySpendingComparisonProvider';
}

/// Provider for country spending comparison (Issues #10, #11)
///
/// Copied from [countrySpendingComparison].
class CountrySpendingComparisonProvider
    extends AutoDisposeFutureProvider<List<CountrySpendingDataPoint>> {
  /// Provider for country spending comparison (Issues #10, #11)
  ///
  /// Copied from [countrySpendingComparison].
  CountrySpendingComparisonProvider(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) : this._internal(
         (ref) => countrySpendingComparison(
           ref as CountrySpendingComparisonRef,
           vehicleId,
           startDate: startDate,
           endDate: endDate,
         ),
         from: countrySpendingComparisonProvider,
         name: r'countrySpendingComparisonProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$countrySpendingComparisonHash,
         dependencies: CountrySpendingComparisonFamily._dependencies,
         allTransitiveDependencies:
             CountrySpendingComparisonFamily._allTransitiveDependencies,
         vehicleId: vehicleId,
         startDate: startDate,
         endDate: endDate,
       );

  CountrySpendingComparisonProvider._internal(
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
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Override overrideWith(
    FutureOr<List<CountrySpendingDataPoint>> Function(
      CountrySpendingComparisonRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CountrySpendingComparisonProvider._internal(
        (ref) => create(ref as CountrySpendingComparisonRef),
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
  AutoDisposeFutureProviderElement<List<CountrySpendingDataPoint>>
  createElement() {
    return _CountrySpendingComparisonProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CountrySpendingComparisonProvider &&
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
mixin CountrySpendingComparisonRef
    on AutoDisposeFutureProviderRef<List<CountrySpendingDataPoint>> {
  /// The parameter `vehicleId` of this provider.
  int get vehicleId;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _CountrySpendingComparisonProviderElement
    extends AutoDisposeFutureProviderElement<List<CountrySpendingDataPoint>>
    with CountrySpendingComparisonRef {
  _CountrySpendingComparisonProviderElement(super.provider);

  @override
  int get vehicleId => (origin as CountrySpendingComparisonProvider).vehicleId;
  @override
  DateTime? get startDate =>
      (origin as CountrySpendingComparisonProvider).startDate;
  @override
  DateTime? get endDate =>
      (origin as CountrySpendingComparisonProvider).endDate;
}

String _$priceTrendsByCountryHash() =>
    r'8f24b139ee6e578d265f263c1f72dda25c5b1d4b';

/// Provider for price trends by country over time (Issue #10)
///
/// Copied from [priceTrendsByCountry].
@ProviderFor(priceTrendsByCountry)
const priceTrendsByCountryProvider = PriceTrendsByCountryFamily();

/// Provider for price trends by country over time (Issue #10)
///
/// Copied from [priceTrendsByCountry].
class PriceTrendsByCountryFamily
    extends Family<AsyncValue<Map<String, List<PriceTrendDataPoint>>>> {
  /// Provider for price trends by country over time (Issue #10)
  ///
  /// Copied from [priceTrendsByCountry].
  const PriceTrendsByCountryFamily();

  /// Provider for price trends by country over time (Issue #10)
  ///
  /// Copied from [priceTrendsByCountry].
  PriceTrendsByCountryProvider call(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return PriceTrendsByCountryProvider(
      vehicleId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  PriceTrendsByCountryProvider getProviderOverride(
    covariant PriceTrendsByCountryProvider provider,
  ) {
    return call(
      provider.vehicleId,
      startDate: provider.startDate,
      endDate: provider.endDate,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'priceTrendsByCountryProvider';
}

/// Provider for price trends by country over time (Issue #10)
///
/// Copied from [priceTrendsByCountry].
class PriceTrendsByCountryProvider
    extends AutoDisposeFutureProvider<Map<String, List<PriceTrendDataPoint>>> {
  /// Provider for price trends by country over time (Issue #10)
  ///
  /// Copied from [priceTrendsByCountry].
  PriceTrendsByCountryProvider(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) : this._internal(
         (ref) => priceTrendsByCountry(
           ref as PriceTrendsByCountryRef,
           vehicleId,
           startDate: startDate,
           endDate: endDate,
         ),
         from: priceTrendsByCountryProvider,
         name: r'priceTrendsByCountryProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$priceTrendsByCountryHash,
         dependencies: PriceTrendsByCountryFamily._dependencies,
         allTransitiveDependencies:
             PriceTrendsByCountryFamily._allTransitiveDependencies,
         vehicleId: vehicleId,
         startDate: startDate,
         endDate: endDate,
       );

  PriceTrendsByCountryProvider._internal(
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
  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Override overrideWith(
    FutureOr<Map<String, List<PriceTrendDataPoint>>> Function(
      PriceTrendsByCountryRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PriceTrendsByCountryProvider._internal(
        (ref) => create(ref as PriceTrendsByCountryRef),
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
  AutoDisposeFutureProviderElement<Map<String, List<PriceTrendDataPoint>>>
  createElement() {
    return _PriceTrendsByCountryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PriceTrendsByCountryProvider &&
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
mixin PriceTrendsByCountryRef
    on AutoDisposeFutureProviderRef<Map<String, List<PriceTrendDataPoint>>> {
  /// The parameter `vehicleId` of this provider.
  int get vehicleId;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;
}

class _PriceTrendsByCountryProviderElement
    extends
        AutoDisposeFutureProviderElement<Map<String, List<PriceTrendDataPoint>>>
    with PriceTrendsByCountryRef {
  _PriceTrendsByCountryProviderElement(super.provider);

  @override
  int get vehicleId => (origin as PriceTrendsByCountryProvider).vehicleId;
  @override
  DateTime? get startDate => (origin as PriceTrendsByCountryProvider).startDate;
  @override
  DateTime? get endDate => (origin as PriceTrendsByCountryProvider).endDate;
}

String _$spendingStatisticsHash() =>
    r'088980444cad1c2b1a667a8453e56a703e4c6dde';

/// Provider for comprehensive spending statistics (Issue #14)
///
/// Copied from [spendingStatistics].
@ProviderFor(spendingStatistics)
const spendingStatisticsProvider = SpendingStatisticsFamily();

/// Provider for comprehensive spending statistics (Issue #14)
///
/// Copied from [spendingStatistics].
class SpendingStatisticsFamily
    extends Family<AsyncValue<Map<String, dynamic>>> {
  /// Provider for comprehensive spending statistics (Issue #14)
  ///
  /// Copied from [spendingStatistics].
  const SpendingStatisticsFamily();

  /// Provider for comprehensive spending statistics (Issue #14)
  ///
  /// Copied from [spendingStatistics].
  SpendingStatisticsProvider call(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
    String? countryFilter,
  }) {
    return SpendingStatisticsProvider(
      vehicleId,
      startDate: startDate,
      endDate: endDate,
      countryFilter: countryFilter,
    );
  }

  @override
  SpendingStatisticsProvider getProviderOverride(
    covariant SpendingStatisticsProvider provider,
  ) {
    return call(
      provider.vehicleId,
      startDate: provider.startDate,
      endDate: provider.endDate,
      countryFilter: provider.countryFilter,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'spendingStatisticsProvider';
}

/// Provider for comprehensive spending statistics (Issue #14)
///
/// Copied from [spendingStatistics].
class SpendingStatisticsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// Provider for comprehensive spending statistics (Issue #14)
  ///
  /// Copied from [spendingStatistics].
  SpendingStatisticsProvider(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
    String? countryFilter,
  }) : this._internal(
         (ref) => spendingStatistics(
           ref as SpendingStatisticsRef,
           vehicleId,
           startDate: startDate,
           endDate: endDate,
           countryFilter: countryFilter,
         ),
         from: spendingStatisticsProvider,
         name: r'spendingStatisticsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$spendingStatisticsHash,
         dependencies: SpendingStatisticsFamily._dependencies,
         allTransitiveDependencies:
             SpendingStatisticsFamily._allTransitiveDependencies,
         vehicleId: vehicleId,
         startDate: startDate,
         endDate: endDate,
         countryFilter: countryFilter,
       );

  SpendingStatisticsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
    required this.countryFilter,
  }) : super.internal();

  final int vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? countryFilter;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(SpendingStatisticsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SpendingStatisticsProvider._internal(
        (ref) => create(ref as SpendingStatisticsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        vehicleId: vehicleId,
        startDate: startDate,
        endDate: endDate,
        countryFilter: countryFilter,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _SpendingStatisticsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SpendingStatisticsProvider &&
        other.vehicleId == vehicleId &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.countryFilter == countryFilter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, vehicleId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);
    hash = _SystemHash.combine(hash, countryFilter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SpendingStatisticsRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `vehicleId` of this provider.
  int get vehicleId;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;

  /// The parameter `countryFilter` of this provider.
  String? get countryFilter;
}

class _SpendingStatisticsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with SpendingStatisticsRef {
  _SpendingStatisticsProviderElement(super.provider);

  @override
  int get vehicleId => (origin as SpendingStatisticsProvider).vehicleId;
  @override
  DateTime? get startDate => (origin as SpendingStatisticsProvider).startDate;
  @override
  DateTime? get endDate => (origin as SpendingStatisticsProvider).endDate;
  @override
  String? get countryFilter =>
      (origin as SpendingStatisticsProvider).countryFilter;
}

String _$periodAverageConsumptionDataHash() =>
    r'0a056aeac40477cf83867f87d15f14fe9e4eacf0';

/// Provider for period-based average consumption data
///
/// Copied from [periodAverageConsumptionData].
@ProviderFor(periodAverageConsumptionData)
const periodAverageConsumptionDataProvider =
    PeriodAverageConsumptionDataFamily();

/// Provider for period-based average consumption data
///
/// Copied from [periodAverageConsumptionData].
class PeriodAverageConsumptionDataFamily
    extends Family<AsyncValue<List<PeriodAverageDataPoint>>> {
  /// Provider for period-based average consumption data
  ///
  /// Copied from [periodAverageConsumptionData].
  const PeriodAverageConsumptionDataFamily();

  /// Provider for period-based average consumption data
  ///
  /// Copied from [periodAverageConsumptionData].
  PeriodAverageConsumptionDataProvider call(
    int vehicleId,
    PeriodType periodType, {
    DateTime? startDate,
    DateTime? endDate,
    String? countryFilter,
  }) {
    return PeriodAverageConsumptionDataProvider(
      vehicleId,
      periodType,
      startDate: startDate,
      endDate: endDate,
      countryFilter: countryFilter,
    );
  }

  @override
  PeriodAverageConsumptionDataProvider getProviderOverride(
    covariant PeriodAverageConsumptionDataProvider provider,
  ) {
    return call(
      provider.vehicleId,
      provider.periodType,
      startDate: provider.startDate,
      endDate: provider.endDate,
      countryFilter: provider.countryFilter,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'periodAverageConsumptionDataProvider';
}

/// Provider for period-based average consumption data
///
/// Copied from [periodAverageConsumptionData].
class PeriodAverageConsumptionDataProvider
    extends AutoDisposeFutureProvider<List<PeriodAverageDataPoint>> {
  /// Provider for period-based average consumption data
  ///
  /// Copied from [periodAverageConsumptionData].
  PeriodAverageConsumptionDataProvider(
    int vehicleId,
    PeriodType periodType, {
    DateTime? startDate,
    DateTime? endDate,
    String? countryFilter,
  }) : this._internal(
         (ref) => periodAverageConsumptionData(
           ref as PeriodAverageConsumptionDataRef,
           vehicleId,
           periodType,
           startDate: startDate,
           endDate: endDate,
           countryFilter: countryFilter,
         ),
         from: periodAverageConsumptionDataProvider,
         name: r'periodAverageConsumptionDataProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$periodAverageConsumptionDataHash,
         dependencies: PeriodAverageConsumptionDataFamily._dependencies,
         allTransitiveDependencies:
             PeriodAverageConsumptionDataFamily._allTransitiveDependencies,
         vehicleId: vehicleId,
         periodType: periodType,
         startDate: startDate,
         endDate: endDate,
         countryFilter: countryFilter,
       );

  PeriodAverageConsumptionDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.vehicleId,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    required this.countryFilter,
  }) : super.internal();

  final int vehicleId;
  final PeriodType periodType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? countryFilter;

  @override
  Override overrideWith(
    FutureOr<List<PeriodAverageDataPoint>> Function(
      PeriodAverageConsumptionDataRef provider,
    )
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PeriodAverageConsumptionDataProvider._internal(
        (ref) => create(ref as PeriodAverageConsumptionDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        vehicleId: vehicleId,
        periodType: periodType,
        startDate: startDate,
        endDate: endDate,
        countryFilter: countryFilter,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<PeriodAverageDataPoint>>
  createElement() {
    return _PeriodAverageConsumptionDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PeriodAverageConsumptionDataProvider &&
        other.vehicleId == vehicleId &&
        other.periodType == periodType &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.countryFilter == countryFilter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, vehicleId.hashCode);
    hash = _SystemHash.combine(hash, periodType.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);
    hash = _SystemHash.combine(hash, countryFilter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin PeriodAverageConsumptionDataRef
    on AutoDisposeFutureProviderRef<List<PeriodAverageDataPoint>> {
  /// The parameter `vehicleId` of this provider.
  int get vehicleId;

  /// The parameter `periodType` of this provider.
  PeriodType get periodType;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;

  /// The parameter `countryFilter` of this provider.
  String? get countryFilter;
}

class _PeriodAverageConsumptionDataProviderElement
    extends AutoDisposeFutureProviderElement<List<PeriodAverageDataPoint>>
    with PeriodAverageConsumptionDataRef {
  _PeriodAverageConsumptionDataProviderElement(super.provider);

  @override
  int get vehicleId =>
      (origin as PeriodAverageConsumptionDataProvider).vehicleId;
  @override
  PeriodType get periodType =>
      (origin as PeriodAverageConsumptionDataProvider).periodType;
  @override
  DateTime? get startDate =>
      (origin as PeriodAverageConsumptionDataProvider).startDate;
  @override
  DateTime? get endDate =>
      (origin as PeriodAverageConsumptionDataProvider).endDate;
  @override
  String? get countryFilter =>
      (origin as PeriodAverageConsumptionDataProvider).countryFilter;
}

String _$consumptionStatisticsHash() =>
    r'362dd492f2fbe29d44e2828c95d5cfb1e6d6233f';

/// Provider for overall consumption statistics
/// Uses period-based consumption calculation (full tank to full tank)
///
/// Copied from [consumptionStatistics].
@ProviderFor(consumptionStatistics)
const consumptionStatisticsProvider = ConsumptionStatisticsFamily();

/// Provider for overall consumption statistics
/// Uses period-based consumption calculation (full tank to full tank)
///
/// Copied from [consumptionStatistics].
class ConsumptionStatisticsFamily
    extends Family<AsyncValue<Map<String, double>>> {
  /// Provider for overall consumption statistics
  /// Uses period-based consumption calculation (full tank to full tank)
  ///
  /// Copied from [consumptionStatistics].
  const ConsumptionStatisticsFamily();

  /// Provider for overall consumption statistics
  /// Uses period-based consumption calculation (full tank to full tank)
  ///
  /// Copied from [consumptionStatistics].
  ConsumptionStatisticsProvider call(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
    String? countryFilter,
  }) {
    return ConsumptionStatisticsProvider(
      vehicleId,
      startDate: startDate,
      endDate: endDate,
      countryFilter: countryFilter,
    );
  }

  @override
  ConsumptionStatisticsProvider getProviderOverride(
    covariant ConsumptionStatisticsProvider provider,
  ) {
    return call(
      provider.vehicleId,
      startDate: provider.startDate,
      endDate: provider.endDate,
      countryFilter: provider.countryFilter,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'consumptionStatisticsProvider';
}

/// Provider for overall consumption statistics
/// Uses period-based consumption calculation (full tank to full tank)
///
/// Copied from [consumptionStatistics].
class ConsumptionStatisticsProvider
    extends AutoDisposeFutureProvider<Map<String, double>> {
  /// Provider for overall consumption statistics
  /// Uses period-based consumption calculation (full tank to full tank)
  ///
  /// Copied from [consumptionStatistics].
  ConsumptionStatisticsProvider(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
    String? countryFilter,
  }) : this._internal(
         (ref) => consumptionStatistics(
           ref as ConsumptionStatisticsRef,
           vehicleId,
           startDate: startDate,
           endDate: endDate,
           countryFilter: countryFilter,
         ),
         from: consumptionStatisticsProvider,
         name: r'consumptionStatisticsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$consumptionStatisticsHash,
         dependencies: ConsumptionStatisticsFamily._dependencies,
         allTransitiveDependencies:
             ConsumptionStatisticsFamily._allTransitiveDependencies,
         vehicleId: vehicleId,
         startDate: startDate,
         endDate: endDate,
         countryFilter: countryFilter,
       );

  ConsumptionStatisticsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
    required this.countryFilter,
  }) : super.internal();

  final int vehicleId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? countryFilter;

  @override
  Override overrideWith(
    FutureOr<Map<String, double>> Function(ConsumptionStatisticsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ConsumptionStatisticsProvider._internal(
        (ref) => create(ref as ConsumptionStatisticsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        vehicleId: vehicleId,
        startDate: startDate,
        endDate: endDate,
        countryFilter: countryFilter,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, double>> createElement() {
    return _ConsumptionStatisticsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConsumptionStatisticsProvider &&
        other.vehicleId == vehicleId &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.countryFilter == countryFilter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, vehicleId.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);
    hash = _SystemHash.combine(hash, countryFilter.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConsumptionStatisticsRef
    on AutoDisposeFutureProviderRef<Map<String, double>> {
  /// The parameter `vehicleId` of this provider.
  int get vehicleId;

  /// The parameter `startDate` of this provider.
  DateTime? get startDate;

  /// The parameter `endDate` of this provider.
  DateTime? get endDate;

  /// The parameter `countryFilter` of this provider.
  String? get countryFilter;
}

class _ConsumptionStatisticsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, double>>
    with ConsumptionStatisticsRef {
  _ConsumptionStatisticsProviderElement(super.provider);

  @override
  int get vehicleId => (origin as ConsumptionStatisticsProvider).vehicleId;
  @override
  DateTime? get startDate =>
      (origin as ConsumptionStatisticsProvider).startDate;
  @override
  DateTime? get endDate => (origin as ConsumptionStatisticsProvider).endDate;
  @override
  String? get countryFilter =>
      (origin as ConsumptionStatisticsProvider).countryFilter;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
