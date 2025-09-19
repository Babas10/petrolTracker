# Multi-Currency Chart Services Documentation (Issue #132)

## Overview

This document provides comprehensive documentation for the multi-currency chart services implementation that enables accurate chart visualization and analysis across different currencies. All chart data is converted to the user's primary currency while preserving original currency information for transparency.

## Architecture

### Core Components

```
┌─────────────────────────────────────────────────────────┐
│                    Chart Architecture                   │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────┐    ┌──────────────────────────┐    │
│  │ MultiCurrency   │    │ MultiCurrency            │    │
│  │ ChartData       │◄───┤ ConsumptionCalculation   │    │
│  │ Service         │    │ Service                  │    │
│  └─────────────────┘    └──────────────────────────┘    │
│           │                          │                  │
│           ▼                          ▼                  │
│  ┌─────────────────┐    ┌──────────────────────────┐    │
│  │ Chart Providers │    │ Chart Models             │    │
│  │ (Riverpod)      │    │ (Freezed)                │    │
│  └─────────────────┘    └──────────────────────────┘    │
│           │                          │                  │
│           ▼                          ▼                  │
│  ┌─────────────────┐    ┌──────────────────────────┐    │
│  │ MultiCurrency   │    │ Chart Widgets            │    │
│  │ Chart Widget    │    │ (Currency-aware)         │    │
│  └─────────────────┘    └──────────────────────────┘    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Services

### 1. MultiCurrencyChartDataService

**Location**: `lib/services/multi_currency_chart_data_service.dart`

#### Purpose
Generates chart-ready data with automatic currency conversion to the user's primary currency.

#### Key Features
- **Currency Conversion**: Automatically converts all amounts to primary currency
- **Multi-Chart Support**: Handles cost, consumption, efficiency, and price charts
- **Period Grouping**: Groups data by daily, weekly, monthly, quarterly, or yearly periods
- **Metadata Tracking**: Preserves original currency information and conversion details

#### Usage Example

```dart
// Initialize service
final chartService = MultiCurrencyChartDataService(
  currencyService: CurrencyService.instance,
  primaryCurrency: 'USD',
);

// Generate cost chart data
final costData = await chartService.generateCostChart(
  entries: fuelEntries,
  period: ChartPeriod.monthly,
  dateRange: DateRange(
    start: DateTime(2023, 1, 1),
    end: DateTime(2023, 12, 31),
  ),
);

// Generate consumption chart data
final consumptionData = await chartService.generateConsumptionChart(
  entries: fuelEntries,
  period: ChartPeriod.weekly,
  dateRange: dateRange,
);
```

#### Chart Types

1. **Cost Chart**: Total spending by period
   ```dart
   final costChart = await service.generateCostChart(
     entries: entries,
     period: ChartPeriod.monthly,
     dateRange: dateRange,
   );
   ```

2. **Consumption Chart**: Fuel consumption (L/100km) by period
   ```dart
   final consumptionChart = await service.generateConsumptionChart(
     entries: entries,
     period: ChartPeriod.weekly,
     dateRange: dateRange,
   );
   ```

3. **Efficiency Chart**: Cost per kilometer by period
   ```dart
   final efficiencyChart = await service.generateEfficiencyChart(
     entries: entries,
     period: ChartPeriod.daily,
     dateRange: dateRange,
   );
   ```

4. **Price Chart**: Average price per liter by period
   ```dart
   final priceChart = await service.generatePriceChart(
     entries: entries,
     period: ChartPeriod.monthly,
     dateRange: dateRange,
   );
   ```

### 2. MultiCurrencyConsumptionCalculationService

**Location**: `lib/services/multi_currency_consumption_calculation_service.dart`

#### Purpose
Calculates fuel consumption metrics with proper currency conversion for accurate cost analysis.

#### Key Features
- **Comprehensive Analysis**: Calculates volume, cost, distance, and efficiency metrics
- **Vehicle Grouping**: Analyzes consumption by individual vehicles
- **Trend Analysis**: Generates monthly consumption trends
- **Currency Breakdown**: Provides detailed currency usage statistics

#### Usage Example

```dart
// Initialize service
final consumptionService = MultiCurrencyConsumptionCalculationService(
  currencyService: CurrencyService.instance,
  primaryCurrency: 'USD',
);

// Calculate consumption analysis
final analysis = await consumptionService.calculateConsumption(
  entries: fuelEntries,
  periodStart: DateTime(2023, 1, 1),
  periodEnd: DateTime(2023, 12, 31),
);

// Access metrics
print('Total Volume: ${analysis.totalVolume} L');
print('Total Cost: ${analysis.totalCost} ${analysis.currency}');
print('Average Consumption: ${analysis.averageConsumption} L/100km');
print('Cost per Liter: ${analysis.costPerLiter} ${analysis.currency}/L');
```

#### Analysis Methods

1. **Basic Consumption Analysis**
   ```dart
   final analysis = await service.calculateConsumption(
     entries: entries,
     periodStart: startDate,
     periodEnd: endDate,
   );
   ```

2. **Consumption by Vehicle**
   ```dart
   final vehicleAnalysis = await service.calculateConsumptionByVehicle(
     entries: entries,
     periodStart: startDate,
     periodEnd: endDate,
   );
   ```

3. **Monthly Trends**
   ```dart
   final trends = await service.calculateMonthlyTrends(
     entries: entries,
     periodStart: startDate,
     periodEnd: endDate,
   );
   ```

4. **Efficiency Metrics**
   ```dart
   final metrics = await service.calculateEfficiencyMetrics(
     entries: entries,
   );
   ```

## Data Models

### ChartDataPoint

```dart
@freezed
class ChartDataPoint with _$ChartDataPoint {
  const factory ChartDataPoint({
    required DateTime date,
    required double value,
    required String label,
    required ChartMetadata metadata,
  }) = _ChartDataPoint;
}
```

### ChartMetadata

```dart
@freezed
class ChartMetadata with _$ChartMetadata {
  const factory ChartMetadata({
    required String currency,
    required int entryCount,
    required List<String> originalCurrencies,
    double? totalVolume,
    double? totalDistance,
    Map<String, double>? currencyBreakdown,
  }) = _ChartMetadata;
}
```

### ConsumptionAnalysis

```dart
@freezed
class ConsumptionAnalysis with _$ConsumptionAnalysis {
  const factory ConsumptionAnalysis({
    required double totalVolume,
    required double totalCost,
    required double totalDistance,
    required double averageConsumption,
    required double costPerLiter,
    required double costPerKilometer,
    required String currency,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int entriesAnalyzed,
    required Map<String, CurrencyBreakdown> currencyBreakdown,
  }) = _ConsumptionAnalysis;
}
```

## Providers

### Chart Data Provider

```dart
// Provider for multi-currency chart data
final multiCurrencyChartDataProvider = FutureProvider.family<
  List<ChartDataPoint>, 
  ChartDataParams
>((ref, params) async {
  final primaryCurrency = ref.watch(primaryCurrencyProvider);
  final chartService = ref.read(multiCurrencyChartDataServiceProvider(primaryCurrency));
  
  // Implementation details...
});
```

### Usage in Widgets

```dart
class ChartScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartParams = ChartDataParams(
      chartType: ChartType.cost,
      period: ChartPeriod.monthly,
      vehicleId: selectedVehicleId,
    );
    
    final chartDataAsync = ref.watch(multiCurrencyChartDataProvider(chartParams));
    
    return chartDataAsync.when(
      data: (data) => MultiCurrencyChart(
        chartType: ChartType.cost,
        period: ChartPeriod.monthly,
        onDataPointTap: (point) => _showDataPointDetails(point),
      ),
      loading: () => const ChartLoadingWidget(),
      error: (error, stack) => ChartErrorWidget(error: error),
    );
  }
}
```

## Widget Components

### MultiCurrencyChart

**Location**: `lib/widgets/multi_currency_chart.dart`

#### Features
- **Currency Header**: Shows primary currency and multi-currency indicators
- **Interactive Charts**: Tap-to-drill-down functionality
- **Currency Breakdown**: Modal sheet with detailed currency information
- **Loading States**: Proper loading and error state handling

#### Usage

```dart
MultiCurrencyChart(
  chartType: ChartType.cost,
  period: ChartPeriod.monthly,
  dateRange: DateRange(
    start: DateTime(2023, 1, 1),
    end: DateTime(2023, 12, 31),
  ),
  vehicleId: 1,
  onDataPointTap: (dataPoint) {
    // Handle data point interaction
    showDataPointDetails(dataPoint);
  },
)
```

### CurrencyChartHeader

Displays currency conversion information:
- Primary currency indicator
- Multi-currency badge (when applicable)
- Currency breakdown button

### ChartMetadataFooter

Shows chart statistics:
- Total entries processed
- Number of time periods
- Number of currencies involved

## Currency Conversion

### Automatic Conversion Process

1. **Currency Detection**: Extracts currency from country field in fuel entries
2. **Conversion Request**: Uses CurrencyService to convert amounts to primary currency
3. **Fallback Handling**: Keeps original amounts if conversion fails
4. **Metadata Preservation**: Stores original currency information for transparency

### Currency Mapping

The service includes comprehensive country-to-currency mapping:

```dart
String _extractCurrencyFromCountry(String country) {
  switch (country.toLowerCase()) {
    case 'united states':
    case 'usa':
    case 'us':
      return 'USD';
    case 'germany':
    case 'france':
    case 'italy':
    // ... other Eurozone countries
      return 'EUR';
    case 'united kingdom':
    case 'uk':
      return 'GBP';
    // ... more mappings
    default:
      return 'USD'; // Default fallback
  }
}
```

## Performance Optimization

### Caching Strategy

The implementation includes intelligent caching:

```dart
// Chart data cache with TTL
final chartDataCacheProvider = StateNotifierProvider<
  ChartDataCacheNotifier, 
  Map<String, ChartDataCacheEntry>
>((ref) {
  return ChartDataCacheNotifier();
});
```

### Cache Features
- **TTL Support**: 30-minute default cache expiration
- **Currency-Aware**: Cache invalidation when primary currency changes
- **Memory Management**: Automatic cleanup of expired entries

### Batch Processing

For large datasets, the service supports:
- Batch currency conversions
- Efficient grouping algorithms
- Optimized distance calculations

## Error Handling

### Conversion Failures

When currency conversion fails:
1. **Graceful Degradation**: Keep original amounts
2. **User Notification**: Include conversion failure indicators in metadata
3. **Partial Success**: Process successful conversions, mark failures

### Data Validation

- **Distance Sanity Checks**: Filter unreasonable distance values (>10,000 km between entries)
- **Amount Validation**: Ensure positive values for calculations
- **Date Range Filtering**: Proper boundary checking for time periods

## Testing

### Test Coverage

The implementation includes comprehensive tests:

1. **Service Tests**
   - Currency conversion scenarios
   - Chart data generation
   - Period grouping logic
   - Error handling

2. **Provider Tests**
   - State management
   - Cache functionality
   - Parameter handling

3. **Widget Tests**
   - Chart rendering
   - User interactions
   - Loading states

### Example Test

```dart
test('should generate cost chart with currency conversion', () async {
  // Arrange
  final entries = [
    FuelEntryModel(/* USD entry */),
    FuelEntryModel(/* EUR entry */),
  ];
  
  when(mockCurrencyService.convertAmount(
    amount: 80.0,
    fromCurrency: 'EUR',
    toCurrency: 'USD',
  )).thenAnswer((_) async => ConversionResult(convertedAmount: 85.0));

  // Act
  final result = await service.generateCostChart(
    entries: entries,
    period: ChartPeriod.monthly,
    dateRange: dateRange,
  );

  // Assert
  expect(result.first.value, equals(185.0)); // 100 + 85 (converted)
  expect(result.first.metadata.originalCurrencies, contains('EUR'));
});
```

## Integration Guide

### Step 1: Add Dependencies

Ensure these services are available:
- `CurrencyService` - for currency conversion
- `FuelEntryProviders` - for data access
- `CurrencyProviders` - for primary currency settings

### Step 2: Initialize Services

```dart
// In your app initialization
final chartService = MultiCurrencyChartDataService(
  currencyService: CurrencyService.instance,
  primaryCurrency: userPrimaryCurrency,
);
```

### Step 3: Use Providers

```dart
// In your widget
final chartData = ref.watch(multiCurrencyChartDataProvider(params));
```

### Step 4: Display Charts

```dart
// Use the MultiCurrencyChart widget
MultiCurrencyChart(
  chartType: ChartType.cost,
  period: ChartPeriod.monthly,
  // ... other parameters
)
```

## Migration from Existing Charts

### For Existing Chart Screens

1. **Replace Chart Data Sources**: Update providers to use multi-currency versions
2. **Update Chart Widgets**: Replace with `MultiCurrencyChart`
3. **Add Currency Headers**: Include currency conversion indicators
4. **Test Currency Scenarios**: Verify behavior with multi-currency data

### Migration Example

**Before:**
```dart
final chartData = ref.watch(costChartDataProvider(vehicleId));
return ChartWidget(data: chartData);
```

**After:**
```dart
final chartParams = ChartDataParams(
  chartType: ChartType.cost,
  period: ChartPeriod.monthly,
  vehicleId: vehicleId,
);
final chartData = ref.watch(multiCurrencyChartDataProvider(chartParams));
return MultiCurrencyChart(
  chartType: ChartType.cost,
  period: ChartPeriod.monthly,
  vehicleId: vehicleId,
);
```

## Best Practices

### 1. Currency Consistency
- Always specify the primary currency when initializing services
- Handle currency changes by invalidating related providers
- Provide clear indicators when displaying converted amounts

### 2. Performance
- Use caching for frequently accessed chart data
- Implement proper loading states for async operations
- Optimize batch conversions for large datasets

### 3. User Experience
- Show original currency information alongside converted amounts
- Provide currency breakdown functionality
- Handle conversion failures gracefully

### 4. Error Handling
- Implement proper fallback strategies for conversion failures
- Validate input data before processing
- Provide meaningful error messages to users

## Future Enhancements

### Planned Features
1. **Historical Exchange Rates**: Use historical rates for past entries
2. **Currency Rate Caching**: Improved caching strategy for exchange rates
3. **Offline Support**: Local fallback rates for offline scenarios
4. **Custom Currency Formatting**: User-defined currency display preferences

### Extension Points
- **Custom Chart Types**: Framework for adding new chart types
- **Advanced Analytics**: More sophisticated consumption analysis
- **Export Functionality**: Export charts with currency conversion details
- **Real-time Updates**: Live currency rate updates for charts

## Troubleshooting

### Common Issues

1. **Charts Not Loading**
   - Check currency service availability
   - Verify fuel entry data exists
   - Ensure primary currency is set

2. **Conversion Failures**
   - Check internet connectivity for rate fetching
   - Verify currency codes are valid
   - Review country-to-currency mapping

3. **Performance Issues**
   - Enable chart data caching
   - Reduce date range for large datasets
   - Check for memory leaks in providers

### Debug Tips

```dart
// Enable debug logging
final chartService = MultiCurrencyChartDataService(
  currencyService: CurrencyService.instance,
  primaryCurrency: 'USD',
);

// Check conversion metadata
final chartData = await chartService.generateCostChart(/*...*/);
for (final point in chartData) {
  print('Original currencies: ${point.metadata.originalCurrencies}');
  print('Conversion status: ${point.metadata.currencyBreakdown}');
}
```

---

This documentation provides comprehensive coverage of the multi-currency chart services implementation for Issue #132. The system ensures accurate chart visualization across different currencies while maintaining transparency about conversions and preserving original currency information for user reference.