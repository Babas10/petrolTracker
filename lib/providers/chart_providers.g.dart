// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chart_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for consumption chart data for a specific vehicle
/// Uses period-based consumption calculation (full tank to full tank)

@ProviderFor(consumptionChartData)
const consumptionChartDataProvider = ConsumptionChartDataFamily._();

/// Provider for consumption chart data for a specific vehicle
/// Uses period-based consumption calculation (full tank to full tank)

final class ConsumptionChartDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ConsumptionDataPoint>>,
          List<ConsumptionDataPoint>,
          FutureOr<List<ConsumptionDataPoint>>
        >
    with
        $FutureModifier<List<ConsumptionDataPoint>>,
        $FutureProvider<List<ConsumptionDataPoint>> {
  /// Provider for consumption chart data for a specific vehicle
  /// Uses period-based consumption calculation (full tank to full tank)
  const ConsumptionChartDataProvider._({
    required ConsumptionChartDataFamily super.from,
    required (
      int, {
      DateTime? startDate,
      DateTime? endDate,
      String? countryFilter,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'consumptionChartDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$consumptionChartDataHash();

  @override
  String toString() {
    return r'consumptionChartDataProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<ConsumptionDataPoint>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ConsumptionDataPoint>> create(Ref ref) {
    final argument =
        this.argument
            as (
              int, {
              DateTime? startDate,
              DateTime? endDate,
              String? countryFilter,
            });
    return consumptionChartData(
      ref,
      argument.$1,
      startDate: argument.startDate,
      endDate: argument.endDate,
      countryFilter: argument.countryFilter,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ConsumptionChartDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$consumptionChartDataHash() =>
    r'376823a576f259657d7d898cf06de50c1e0a4125';

/// Provider for consumption chart data for a specific vehicle
/// Uses period-based consumption calculation (full tank to full tank)

final class ConsumptionChartDataFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<ConsumptionDataPoint>>,
          (int, {DateTime? startDate, DateTime? endDate, String? countryFilter})
        > {
  const ConsumptionChartDataFamily._()
    : super(
        retry: null,
        name: r'consumptionChartDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for consumption chart data for a specific vehicle
  /// Uses period-based consumption calculation (full tank to full tank)

  ConsumptionChartDataProvider call(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
    String? countryFilter,
  }) => ConsumptionChartDataProvider._(
    argument: (
      vehicleId,
      startDate: startDate,
      endDate: endDate,
      countryFilter: countryFilter,
    ),
    from: this,
  );

  @override
  String toString() => r'consumptionChartDataProvider';
}

/// Provider for enhanced consumption chart data with period composition details

@ProviderFor(enhancedConsumptionChartData)
const enhancedConsumptionChartDataProvider =
    EnhancedConsumptionChartDataFamily._();

/// Provider for enhanced consumption chart data with period composition details

final class EnhancedConsumptionChartDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EnhancedConsumptionDataPoint>>,
          List<EnhancedConsumptionDataPoint>,
          FutureOr<List<EnhancedConsumptionDataPoint>>
        >
    with
        $FutureModifier<List<EnhancedConsumptionDataPoint>>,
        $FutureProvider<List<EnhancedConsumptionDataPoint>> {
  /// Provider for enhanced consumption chart data with period composition details
  const EnhancedConsumptionChartDataProvider._({
    required EnhancedConsumptionChartDataFamily super.from,
    required (
      int, {
      DateTime? startDate,
      DateTime? endDate,
      String? countryFilter,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'enhancedConsumptionChartDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$enhancedConsumptionChartDataHash();

  @override
  String toString() {
    return r'enhancedConsumptionChartDataProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<EnhancedConsumptionDataPoint>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<EnhancedConsumptionDataPoint>> create(Ref ref) {
    final argument =
        this.argument
            as (
              int, {
              DateTime? startDate,
              DateTime? endDate,
              String? countryFilter,
            });
    return enhancedConsumptionChartData(
      ref,
      argument.$1,
      startDate: argument.startDate,
      endDate: argument.endDate,
      countryFilter: argument.countryFilter,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EnhancedConsumptionChartDataProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$enhancedConsumptionChartDataHash() =>
    r'cf11151287a791d146a4575aa93d4d1a02f0dff3';

/// Provider for enhanced consumption chart data with period composition details

final class EnhancedConsumptionChartDataFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<EnhancedConsumptionDataPoint>>,
          (int, {DateTime? startDate, DateTime? endDate, String? countryFilter})
        > {
  const EnhancedConsumptionChartDataFamily._()
    : super(
        retry: null,
        name: r'enhancedConsumptionChartDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for enhanced consumption chart data with period composition details

  EnhancedConsumptionChartDataProvider call(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
    String? countryFilter,
  }) => EnhancedConsumptionChartDataProvider._(
    argument: (
      vehicleId,
      startDate: startDate,
      endDate: endDate,
      countryFilter: countryFilter,
    ),
    from: this,
  );

  @override
  String toString() => r'enhancedConsumptionChartDataProvider';
}

/// Provider for price trend chart data

@ProviderFor(priceTrendChartData)
const priceTrendChartDataProvider = PriceTrendChartDataFamily._();

/// Provider for price trend chart data

final class PriceTrendChartDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PriceTrendDataPoint>>,
          List<PriceTrendDataPoint>,
          FutureOr<List<PriceTrendDataPoint>>
        >
    with
        $FutureModifier<List<PriceTrendDataPoint>>,
        $FutureProvider<List<PriceTrendDataPoint>> {
  /// Provider for price trend chart data
  const PriceTrendChartDataProvider._({
    required PriceTrendChartDataFamily super.from,
    required ({DateTime? startDate, DateTime? endDate}) super.argument,
  }) : super(
         retry: null,
         name: r'priceTrendChartDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$priceTrendChartDataHash();

  @override
  String toString() {
    return r'priceTrendChartDataProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<PriceTrendDataPoint>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PriceTrendDataPoint>> create(Ref ref) {
    final argument =
        this.argument as ({DateTime? startDate, DateTime? endDate});
    return priceTrendChartData(
      ref,
      startDate: argument.startDate,
      endDate: argument.endDate,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PriceTrendChartDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$priceTrendChartDataHash() =>
    r'96301c2665258b8f92d479ae23a9592118bfc3fb';

/// Provider for price trend chart data

final class PriceTrendChartDataFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PriceTrendDataPoint>>,
          ({DateTime? startDate, DateTime? endDate})
        > {
  const PriceTrendChartDataFamily._()
    : super(
        retry: null,
        name: r'priceTrendChartDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for price trend chart data

  PriceTrendChartDataProvider call({DateTime? startDate, DateTime? endDate}) =>
      PriceTrendChartDataProvider._(
        argument: (startDate: startDate, endDate: endDate),
        from: this,
      );

  @override
  String toString() => r'priceTrendChartDataProvider';
}

/// Provider for monthly consumption averages for a vehicle

@ProviderFor(monthlyConsumptionAverages)
const monthlyConsumptionAveragesProvider = MonthlyConsumptionAveragesFamily._();

/// Provider for monthly consumption averages for a vehicle

final class MonthlyConsumptionAveragesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, double>>,
          Map<String, double>,
          FutureOr<Map<String, double>>
        >
    with
        $FutureModifier<Map<String, double>>,
        $FutureProvider<Map<String, double>> {
  /// Provider for monthly consumption averages for a vehicle
  const MonthlyConsumptionAveragesProvider._({
    required MonthlyConsumptionAveragesFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'monthlyConsumptionAveragesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthlyConsumptionAveragesHash();

  @override
  String toString() {
    return r'monthlyConsumptionAveragesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, double>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, double>> create(Ref ref) {
    final argument = this.argument as (int, int);
    return monthlyConsumptionAverages(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlyConsumptionAveragesProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthlyConsumptionAveragesHash() =>
    r'c9403b1956352a835092c2e2d05f51e840fdd4a1';

/// Provider for monthly consumption averages for a vehicle

final class MonthlyConsumptionAveragesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<String, double>>, (int, int)> {
  const MonthlyConsumptionAveragesFamily._()
    : super(
        retry: null,
        name: r'monthlyConsumptionAveragesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for monthly consumption averages for a vehicle

  MonthlyConsumptionAveragesProvider call(int vehicleId, int year) =>
      MonthlyConsumptionAveragesProvider._(
        argument: (vehicleId, year),
        from: this,
      );

  @override
  String toString() => r'monthlyConsumptionAveragesProvider';
}

/// Provider for cost analysis data

@ProviderFor(costAnalysisData)
const costAnalysisDataProvider = CostAnalysisDataFamily._();

/// Provider for cost analysis data

final class CostAnalysisDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  /// Provider for cost analysis data
  const CostAnalysisDataProvider._({
    required CostAnalysisDataFamily super.from,
    required (int, {DateTime? startDate, DateTime? endDate}) super.argument,
  }) : super(
         retry: null,
         name: r'costAnalysisDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$costAnalysisDataHash();

  @override
  String toString() {
    return r'costAnalysisDataProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    final argument =
        this.argument as (int, {DateTime? startDate, DateTime? endDate});
    return costAnalysisData(
      ref,
      argument.$1,
      startDate: argument.startDate,
      endDate: argument.endDate,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CostAnalysisDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$costAnalysisDataHash() => r'ea7c996237285a35373160e5fce643da3dfcd630';

/// Provider for cost analysis data

final class CostAnalysisDataFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<String, dynamic>>,
          (int, {DateTime? startDate, DateTime? endDate})
        > {
  const CostAnalysisDataFamily._()
    : super(
        retry: null,
        name: r'costAnalysisDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for cost analysis data

  CostAnalysisDataProvider call(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) => CostAnalysisDataProvider._(
    argument: (vehicleId, startDate: startDate, endDate: endDate),
    from: this,
  );

  @override
  String toString() => r'costAnalysisDataProvider';
}

/// Provider for country-wise fuel price comparison

@ProviderFor(countryPriceComparison)
const countryPriceComparisonProvider = CountryPriceComparisonFamily._();

/// Provider for country-wise fuel price comparison

final class CountryPriceComparisonProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, double>>,
          Map<String, double>,
          FutureOr<Map<String, double>>
        >
    with
        $FutureModifier<Map<String, double>>,
        $FutureProvider<Map<String, double>> {
  /// Provider for country-wise fuel price comparison
  const CountryPriceComparisonProvider._({
    required CountryPriceComparisonFamily super.from,
    required ({DateTime? startDate, DateTime? endDate}) super.argument,
  }) : super(
         retry: null,
         name: r'countryPriceComparisonProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$countryPriceComparisonHash();

  @override
  String toString() {
    return r'countryPriceComparisonProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, double>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, double>> create(Ref ref) {
    final argument =
        this.argument as ({DateTime? startDate, DateTime? endDate});
    return countryPriceComparison(
      ref,
      startDate: argument.startDate,
      endDate: argument.endDate,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CountryPriceComparisonProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$countryPriceComparisonHash() =>
    r'25128dd2e46838613c915ebbbf9d7dd4fad8af39';

/// Provider for country-wise fuel price comparison

final class CountryPriceComparisonFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<String, double>>,
          ({DateTime? startDate, DateTime? endDate})
        > {
  const CountryPriceComparisonFamily._()
    : super(
        retry: null,
        name: r'countryPriceComparisonProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for country-wise fuel price comparison

  CountryPriceComparisonProvider call({
    DateTime? startDate,
    DateTime? endDate,
  }) => CountryPriceComparisonProvider._(
    argument: (startDate: startDate, endDate: endDate),
    from: this,
  );

  @override
  String toString() => r'countryPriceComparisonProvider';
}

/// Provider for monthly spending data (Issue #11)

@ProviderFor(monthlySpendingData)
const monthlySpendingDataProvider = MonthlySpendingDataFamily._();

/// Provider for monthly spending data (Issue #11)

final class MonthlySpendingDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SpendingDataPoint>>,
          List<SpendingDataPoint>,
          FutureOr<List<SpendingDataPoint>>
        >
    with
        $FutureModifier<List<SpendingDataPoint>>,
        $FutureProvider<List<SpendingDataPoint>> {
  /// Provider for monthly spending data (Issue #11)
  const MonthlySpendingDataProvider._({
    required MonthlySpendingDataFamily super.from,
    required (
      int, {
      DateTime? startDate,
      DateTime? endDate,
      String? countryFilter,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'monthlySpendingDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$monthlySpendingDataHash();

  @override
  String toString() {
    return r'monthlySpendingDataProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SpendingDataPoint>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SpendingDataPoint>> create(Ref ref) {
    final argument =
        this.argument
            as (
              int, {
              DateTime? startDate,
              DateTime? endDate,
              String? countryFilter,
            });
    return monthlySpendingData(
      ref,
      argument.$1,
      startDate: argument.startDate,
      endDate: argument.endDate,
      countryFilter: argument.countryFilter,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MonthlySpendingDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$monthlySpendingDataHash() =>
    r'd26d7aa96ef092030df895db4a0be614ee2217ca';

/// Provider for monthly spending data (Issue #11)

final class MonthlySpendingDataFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SpendingDataPoint>>,
          (int, {DateTime? startDate, DateTime? endDate, String? countryFilter})
        > {
  const MonthlySpendingDataFamily._()
    : super(
        retry: null,
        name: r'monthlySpendingDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for monthly spending data (Issue #11)

  MonthlySpendingDataProvider call(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
    String? countryFilter,
  }) => MonthlySpendingDataProvider._(
    argument: (
      vehicleId,
      startDate: startDate,
      endDate: endDate,
      countryFilter: countryFilter,
    ),
    from: this,
  );

  @override
  String toString() => r'monthlySpendingDataProvider';
}

/// Provider for country spending comparison (Issues #10, #11)

@ProviderFor(countrySpendingComparison)
const countrySpendingComparisonProvider = CountrySpendingComparisonFamily._();

/// Provider for country spending comparison (Issues #10, #11)

final class CountrySpendingComparisonProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CountrySpendingDataPoint>>,
          List<CountrySpendingDataPoint>,
          FutureOr<List<CountrySpendingDataPoint>>
        >
    with
        $FutureModifier<List<CountrySpendingDataPoint>>,
        $FutureProvider<List<CountrySpendingDataPoint>> {
  /// Provider for country spending comparison (Issues #10, #11)
  const CountrySpendingComparisonProvider._({
    required CountrySpendingComparisonFamily super.from,
    required (int, {DateTime? startDate, DateTime? endDate}) super.argument,
  }) : super(
         retry: null,
         name: r'countrySpendingComparisonProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$countrySpendingComparisonHash();

  @override
  String toString() {
    return r'countrySpendingComparisonProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<CountrySpendingDataPoint>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CountrySpendingDataPoint>> create(Ref ref) {
    final argument =
        this.argument as (int, {DateTime? startDate, DateTime? endDate});
    return countrySpendingComparison(
      ref,
      argument.$1,
      startDate: argument.startDate,
      endDate: argument.endDate,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CountrySpendingComparisonProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$countrySpendingComparisonHash() =>
    r'83f5f7a7006031fd39c103ff4b68abf81f358606';

/// Provider for country spending comparison (Issues #10, #11)

final class CountrySpendingComparisonFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<CountrySpendingDataPoint>>,
          (int, {DateTime? startDate, DateTime? endDate})
        > {
  const CountrySpendingComparisonFamily._()
    : super(
        retry: null,
        name: r'countrySpendingComparisonProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for country spending comparison (Issues #10, #11)

  CountrySpendingComparisonProvider call(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) => CountrySpendingComparisonProvider._(
    argument: (vehicleId, startDate: startDate, endDate: endDate),
    from: this,
  );

  @override
  String toString() => r'countrySpendingComparisonProvider';
}

/// Provider for price trends by country over time (Issue #10)

@ProviderFor(priceTrendsByCountry)
const priceTrendsByCountryProvider = PriceTrendsByCountryFamily._();

/// Provider for price trends by country over time (Issue #10)

final class PriceTrendsByCountryProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, List<PriceTrendDataPoint>>>,
          Map<String, List<PriceTrendDataPoint>>,
          FutureOr<Map<String, List<PriceTrendDataPoint>>>
        >
    with
        $FutureModifier<Map<String, List<PriceTrendDataPoint>>>,
        $FutureProvider<Map<String, List<PriceTrendDataPoint>>> {
  /// Provider for price trends by country over time (Issue #10)
  const PriceTrendsByCountryProvider._({
    required PriceTrendsByCountryFamily super.from,
    required (int, {DateTime? startDate, DateTime? endDate}) super.argument,
  }) : super(
         retry: null,
         name: r'priceTrendsByCountryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$priceTrendsByCountryHash();

  @override
  String toString() {
    return r'priceTrendsByCountryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, List<PriceTrendDataPoint>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, List<PriceTrendDataPoint>>> create(Ref ref) {
    final argument =
        this.argument as (int, {DateTime? startDate, DateTime? endDate});
    return priceTrendsByCountry(
      ref,
      argument.$1,
      startDate: argument.startDate,
      endDate: argument.endDate,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PriceTrendsByCountryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$priceTrendsByCountryHash() =>
    r'53d25ae7499a357a6f8a3390fbe05b42a138e54e';

/// Provider for price trends by country over time (Issue #10)

final class PriceTrendsByCountryFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<String, List<PriceTrendDataPoint>>>,
          (int, {DateTime? startDate, DateTime? endDate})
        > {
  const PriceTrendsByCountryFamily._()
    : super(
        retry: null,
        name: r'priceTrendsByCountryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for price trends by country over time (Issue #10)

  PriceTrendsByCountryProvider call(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) => PriceTrendsByCountryProvider._(
    argument: (vehicleId, startDate: startDate, endDate: endDate),
    from: this,
  );

  @override
  String toString() => r'priceTrendsByCountryProvider';
}

/// Provider for comprehensive spending statistics (Issue #14)

@ProviderFor(spendingStatistics)
const spendingStatisticsProvider = SpendingStatisticsFamily._();

/// Provider for comprehensive spending statistics (Issue #14)

final class SpendingStatisticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  /// Provider for comprehensive spending statistics (Issue #14)
  const SpendingStatisticsProvider._({
    required SpendingStatisticsFamily super.from,
    required (
      int, {
      DateTime? startDate,
      DateTime? endDate,
      String? countryFilter,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'spendingStatisticsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$spendingStatisticsHash();

  @override
  String toString() {
    return r'spendingStatisticsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    final argument =
        this.argument
            as (
              int, {
              DateTime? startDate,
              DateTime? endDate,
              String? countryFilter,
            });
    return spendingStatistics(
      ref,
      argument.$1,
      startDate: argument.startDate,
      endDate: argument.endDate,
      countryFilter: argument.countryFilter,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SpendingStatisticsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$spendingStatisticsHash() =>
    r'191e947dc974e48d0d422e95ee66b146dd265100';

/// Provider for comprehensive spending statistics (Issue #14)

final class SpendingStatisticsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<String, dynamic>>,
          (int, {DateTime? startDate, DateTime? endDate, String? countryFilter})
        > {
  const SpendingStatisticsFamily._()
    : super(
        retry: null,
        name: r'spendingStatisticsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for comprehensive spending statistics (Issue #14)

  SpendingStatisticsProvider call(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
    String? countryFilter,
  }) => SpendingStatisticsProvider._(
    argument: (
      vehicleId,
      startDate: startDate,
      endDate: endDate,
      countryFilter: countryFilter,
    ),
    from: this,
  );

  @override
  String toString() => r'spendingStatisticsProvider';
}

/// Provider for period-based average consumption data

@ProviderFor(periodAverageConsumptionData)
const periodAverageConsumptionDataProvider =
    PeriodAverageConsumptionDataFamily._();

/// Provider for period-based average consumption data

final class PeriodAverageConsumptionDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PeriodAverageDataPoint>>,
          List<PeriodAverageDataPoint>,
          FutureOr<List<PeriodAverageDataPoint>>
        >
    with
        $FutureModifier<List<PeriodAverageDataPoint>>,
        $FutureProvider<List<PeriodAverageDataPoint>> {
  /// Provider for period-based average consumption data
  const PeriodAverageConsumptionDataProvider._({
    required PeriodAverageConsumptionDataFamily super.from,
    required (
      int,
      PeriodType, {
      DateTime? startDate,
      DateTime? endDate,
      String? countryFilter,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'periodAverageConsumptionDataProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$periodAverageConsumptionDataHash();

  @override
  String toString() {
    return r'periodAverageConsumptionDataProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<PeriodAverageDataPoint>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PeriodAverageDataPoint>> create(Ref ref) {
    final argument =
        this.argument
            as (
              int,
              PeriodType, {
              DateTime? startDate,
              DateTime? endDate,
              String? countryFilter,
            });
    return periodAverageConsumptionData(
      ref,
      argument.$1,
      argument.$2,
      startDate: argument.startDate,
      endDate: argument.endDate,
      countryFilter: argument.countryFilter,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PeriodAverageConsumptionDataProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$periodAverageConsumptionDataHash() =>
    r'43ec30fd1cd7da9c194acf3edcf33c000243c039';

/// Provider for period-based average consumption data

final class PeriodAverageConsumptionDataFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<PeriodAverageDataPoint>>,
          (
            int,
            PeriodType, {
            DateTime? startDate,
            DateTime? endDate,
            String? countryFilter,
          })
        > {
  const PeriodAverageConsumptionDataFamily._()
    : super(
        retry: null,
        name: r'periodAverageConsumptionDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for period-based average consumption data

  PeriodAverageConsumptionDataProvider call(
    int vehicleId,
    PeriodType periodType, {
    DateTime? startDate,
    DateTime? endDate,
    String? countryFilter,
  }) => PeriodAverageConsumptionDataProvider._(
    argument: (
      vehicleId,
      periodType,
      startDate: startDate,
      endDate: endDate,
      countryFilter: countryFilter,
    ),
    from: this,
  );

  @override
  String toString() => r'periodAverageConsumptionDataProvider';
}

/// Provider for overall consumption statistics
/// Uses period-based consumption calculation (full tank to full tank)

@ProviderFor(consumptionStatistics)
const consumptionStatisticsProvider = ConsumptionStatisticsFamily._();

/// Provider for overall consumption statistics
/// Uses period-based consumption calculation (full tank to full tank)

final class ConsumptionStatisticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, double>>,
          Map<String, double>,
          FutureOr<Map<String, double>>
        >
    with
        $FutureModifier<Map<String, double>>,
        $FutureProvider<Map<String, double>> {
  /// Provider for overall consumption statistics
  /// Uses period-based consumption calculation (full tank to full tank)
  const ConsumptionStatisticsProvider._({
    required ConsumptionStatisticsFamily super.from,
    required (
      int, {
      DateTime? startDate,
      DateTime? endDate,
      String? countryFilter,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'consumptionStatisticsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$consumptionStatisticsHash();

  @override
  String toString() {
    return r'consumptionStatisticsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, double>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, double>> create(Ref ref) {
    final argument =
        this.argument
            as (
              int, {
              DateTime? startDate,
              DateTime? endDate,
              String? countryFilter,
            });
    return consumptionStatistics(
      ref,
      argument.$1,
      startDate: argument.startDate,
      endDate: argument.endDate,
      countryFilter: argument.countryFilter,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ConsumptionStatisticsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$consumptionStatisticsHash() =>
    r'b1d3526faaf5a707d96f60dfd87937afcbf33c31';

/// Provider for overall consumption statistics
/// Uses period-based consumption calculation (full tank to full tank)

final class ConsumptionStatisticsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<String, double>>,
          (int, {DateTime? startDate, DateTime? endDate, String? countryFilter})
        > {
  const ConsumptionStatisticsFamily._()
    : super(
        retry: null,
        name: r'consumptionStatisticsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for overall consumption statistics
  /// Uses period-based consumption calculation (full tank to full tank)

  ConsumptionStatisticsProvider call(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
    String? countryFilter,
  }) => ConsumptionStatisticsProvider._(
    argument: (
      vehicleId,
      startDate: startDate,
      endDate: endDate,
      countryFilter: countryFilter,
    ),
    from: this,
  );

  @override
  String toString() => r'consumptionStatisticsProvider';
}
