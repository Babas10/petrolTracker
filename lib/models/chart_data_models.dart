/// Chart Data Models for Multi-Currency Support (Issue #132)
/// 
/// This file contains data models for chart visualization with
/// multi-currency support and metadata tracking.
library;

// Simple data classes without Freezed for now to avoid build_runner issues

/// Chart metadata containing currency and additional information
class ChartMetadata {
  final String currency;
  final int entryCount;
  final List<String> originalCurrencies;
  final double? totalVolume;
  final double? totalDistance;
  final Map<String, double>? currencyBreakdown;

  const ChartMetadata({
    required this.currency,
    required this.entryCount,
    required this.originalCurrencies,
    this.totalVolume,
    this.totalDistance,
    this.currencyBreakdown,
  });

  factory ChartMetadata.fromJson(Map<String, dynamic> json) {
    return ChartMetadata(
      currency: json['currency'] as String,
      entryCount: json['entryCount'] as int,
      originalCurrencies: (json['originalCurrencies'] as List<dynamic>).cast<String>(),
      totalVolume: json['totalVolume'] as double?,
      totalDistance: json['totalDistance'] as double?,
      currencyBreakdown: (json['currencyBreakdown'] as Map<String, dynamic>?)?.cast<String, double>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'entryCount': entryCount,
      'originalCurrencies': originalCurrencies,
      'totalVolume': totalVolume,
      'totalDistance': totalDistance,
      'currencyBreakdown': currencyBreakdown,
    };
  }
}

/// Individual chart data point with metadata
class ChartDataPoint {
  final DateTime date;
  final double value;
  final String label;
  final ChartMetadata metadata;

  const ChartDataPoint({
    required this.date,
    required this.value,
    required this.label,
    required this.metadata,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      date: DateTime.parse(json['date'] as String),
      value: json['value'] as double,
      label: json['label'] as String,
      metadata: ChartMetadata.fromJson(json['metadata'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'value': value,
      'label': label,
      'metadata': metadata.toJson(),
    };
  }
}

/// Chart configuration for currency-aware rendering
class ChartConfiguration {
  final String chartType;
  final String primaryCurrency;
  final bool showCurrencyBreakdown;
  final bool enableCurrencyTooltips;
  final String? currencyFormatter;
  final Map<String, dynamic>? additionalConfig;

  const ChartConfiguration({
    required this.chartType,
    required this.primaryCurrency,
    this.showCurrencyBreakdown = false,
    this.enableCurrencyTooltips = true,
    this.currencyFormatter,
    this.additionalConfig,
  });

  factory ChartConfiguration.fromJson(Map<String, dynamic> json) {
    return ChartConfiguration(
      chartType: json['chartType'] as String,
      primaryCurrency: json['primaryCurrency'] as String,
      showCurrencyBreakdown: json['showCurrencyBreakdown'] as bool? ?? false,
      enableCurrencyTooltips: json['enableCurrencyTooltips'] as bool? ?? true,
      currencyFormatter: json['currencyFormatter'] as String?,
      additionalConfig: json['additionalConfig'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chartType': chartType,
      'primaryCurrency': primaryCurrency,
      'showCurrencyBreakdown': showCurrencyBreakdown,
      'enableCurrencyTooltips': enableCurrencyTooltips,
      'currencyFormatter': currencyFormatter,
      'additionalConfig': additionalConfig,
    };
  }
}

/// Consumption analysis result with currency information
class ConsumptionAnalysis {
  final double totalVolume;
  final double totalCost;
  final double totalDistance;
  final double averageConsumption;
  final double costPerLiter;
  final double costPerKilometer;
  final String currency;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int entriesAnalyzed;
  final Map<String, CurrencyBreakdown> currencyBreakdown;

  const ConsumptionAnalysis({
    required this.totalVolume,
    required this.totalCost,
    required this.totalDistance,
    required this.averageConsumption,
    required this.costPerLiter,
    required this.costPerKilometer,
    required this.currency,
    required this.periodStart,
    required this.periodEnd,
    required this.entriesAnalyzed,
    required this.currencyBreakdown,
  });

  factory ConsumptionAnalysis.fromJson(Map<String, dynamic> json) {
    return ConsumptionAnalysis(
      totalVolume: json['totalVolume'] as double,
      totalCost: json['totalCost'] as double,
      totalDistance: json['totalDistance'] as double,
      averageConsumption: json['averageConsumption'] as double,
      costPerLiter: json['costPerLiter'] as double,
      costPerKilometer: json['costPerKilometer'] as double,
      currency: json['currency'] as String,
      periodStart: DateTime.parse(json['periodStart'] as String),
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      entriesAnalyzed: json['entriesAnalyzed'] as int,
      currencyBreakdown: (json['currencyBreakdown'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, CurrencyBreakdown.fromJson(v as Map<String, dynamic>))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalVolume': totalVolume,
      'totalCost': totalCost,
      'totalDistance': totalDistance,
      'averageConsumption': averageConsumption,
      'costPerLiter': costPerLiter,
      'costPerKilometer': costPerKilometer,
      'currency': currency,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'entriesAnalyzed': entriesAnalyzed,
      'currencyBreakdown': currencyBreakdown.map((k, v) => MapEntry(k, v.toJson())),
    };
  }
}

/// Currency breakdown information
class CurrencyBreakdown {
  final String currency;
  final double totalAmount;
  final int entryCount;
  final double? percentage;

  const CurrencyBreakdown({
    required this.currency,
    required this.totalAmount,
    required this.entryCount,
    this.percentage,
  });

  factory CurrencyBreakdown.fromJson(Map<String, dynamic> json) {
    return CurrencyBreakdown(
      currency: json['currency'] as String,
      totalAmount: json['totalAmount'] as double,
      entryCount: json['entryCount'] as int,
      percentage: json['percentage'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'totalAmount': totalAmount,
      'entryCount': entryCount,
      'percentage': percentage,
    };
  }

  CurrencyBreakdown copyWith({
    String? currency,
    double? totalAmount,
    int? entryCount,
    double? percentage,
  }) {
    return CurrencyBreakdown(
      currency: currency ?? this.currency,
      totalAmount: totalAmount ?? this.totalAmount,
      entryCount: entryCount ?? this.entryCount,
      percentage: percentage ?? this.percentage,
    );
  }
}

/// Chart data cache entry
class ChartDataCacheEntry {
  final String cacheKey;
  final List<ChartDataPoint> data;
  final DateTime timestamp;
  final String currency;
  final Duration ttl;

  const ChartDataCacheEntry({
    required this.cacheKey,
    required this.data,
    required this.timestamp,
    required this.currency,
    this.ttl = const Duration(minutes: 30),
  });

  factory ChartDataCacheEntry.fromJson(Map<String, dynamic> json) {
    return ChartDataCacheEntry(
      cacheKey: json['cacheKey'] as String,
      data: (json['data'] as List<dynamic>)
          .map((item) => ChartDataPoint.fromJson(item as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      currency: json['currency'] as String,
      ttl: Duration(milliseconds: json['ttl'] as int? ?? 1800000), // 30 minutes default
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cacheKey': cacheKey,
      'data': data.map((item) => item.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'currency': currency,
      'ttl': ttl.inMilliseconds,
    };
  }

  /// Check if cache entry is still valid
  bool get isValid {
    return DateTime.now().difference(timestamp) < ttl;
  }

  /// Check if cache entry is expired
  bool get isExpired => !isValid;
}

/// Chart data result wrapper with loading states
sealed class ChartDataResult {
  const ChartDataResult();
}

class ChartDataResultData extends ChartDataResult {
  final List<ChartDataPoint> chartData;
  
  const ChartDataResultData(this.chartData);
}

class ChartDataResultLoading extends ChartDataResult {
  const ChartDataResultLoading();
}

class ChartDataResultError extends ChartDataResult {
  final String message;
  final dynamic error;
  
  const ChartDataResultError(this.message, this.error);
}

/// Chart performance metrics
class ChartPerformanceMetrics {
  final Duration conversionTime;
  final Duration calculationTime;
  final Duration totalTime;
  final int entriesProcessed;
  final int conversionsPerformed;
  final bool cacheHit;

  const ChartPerformanceMetrics({
    required this.conversionTime,
    required this.calculationTime,
    required this.totalTime,
    required this.entriesProcessed,
    required this.conversionsPerformed,
    required this.cacheHit,
  });

  factory ChartPerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return ChartPerformanceMetrics(
      conversionTime: Duration(milliseconds: json['conversionTime'] as int),
      calculationTime: Duration(milliseconds: json['calculationTime'] as int),
      totalTime: Duration(milliseconds: json['totalTime'] as int),
      entriesProcessed: json['entriesProcessed'] as int,
      conversionsPerformed: json['conversionsPerformed'] as int,
      cacheHit: json['cacheHit'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversionTime': conversionTime.inMilliseconds,
      'calculationTime': calculationTime.inMilliseconds,
      'totalTime': totalTime.inMilliseconds,
      'entriesProcessed': entriesProcessed,
      'conversionsPerformed': conversionsPerformed,
      'cacheHit': cacheHit,
    };
  }
}

/// Chart error information
sealed class ChartError {
  const ChartError();
}

class ChartErrorConversionFailed extends ChartError {
  final String fromCurrency;
  final String toCurrency;
  final dynamic originalError;

  const ChartErrorConversionFailed(
    this.fromCurrency,
    this.toCurrency,
    this.originalError,
  );
}

class ChartErrorDataProcessingFailed extends ChartError {
  final String message;
  final dynamic originalError;

  const ChartErrorDataProcessingFailed(
    this.message,
    this.originalError,
  );
}

class ChartErrorInsufficientData extends ChartError {
  final String message;

  const ChartErrorInsufficientData(this.message);
}