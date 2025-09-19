/// Error handling providers for currency operations
/// 
/// This file contains specialized providers for handling errors and failures
/// in currency-related operations with graceful degradation strategies.
library;

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petrol_tracker/services/currency_service.dart';
import 'package:petrol_tracker/providers/currency_providers.dart';

part 'currency_error_handling_providers.g.dart';

/// Provider for currency error monitoring and recovery
/// 
/// Monitors currency operation failures and implements automatic
/// recovery strategies for common error scenarios.
@riverpod
class CurrencyErrorMonitor extends _$CurrencyErrorMonitor {
  Timer? _retryTimer;
  final Map<String, int> _retryCounters = <String, int>{};
  final Map<String, DateTime> _lastRetryAttempts = <String, DateTime>{};
  
  @override
  CurrencyErrorState build() {
    ref.onDispose(() {
      _retryTimer?.cancel();
    });
    
    return const CurrencyErrorState();
  }
  
  /// Record a currency operation error
  void recordError(CurrencyError error) {
    final currentState = state;
    final updatedErrors = List<CurrencyError>.from(currentState.recentErrors)..add(error);
    
    // Keep only recent errors (last 50)
    if (updatedErrors.length > 50) {
      updatedErrors.removeRange(0, updatedErrors.length - 50);
    }
    
    state = currentState.copyWith(
      recentErrors: updatedErrors,
      lastError: error,
      errorCount: currentState.errorCount + 1,
    );
    
    // Attempt automatic recovery for certain error types
    _attemptAutoRecovery(error);
  }
  
  Future<void> _attemptAutoRecovery(CurrencyError error) async {
    switch (error.type) {
      case CurrencyErrorType.networkFailure:
        await _handleNetworkFailure(error);
        break;
      case CurrencyErrorType.rateExpired:
        await _handleExpiredRates(error);
        break;
      case CurrencyErrorType.conversionFailed:
        await _handleConversionFailure(error);
        break;
      case CurrencyErrorType.serviceUnavailable:
        await _handleServiceUnavailable(error);
        break;
      default:
        // No automatic recovery for other error types
        break;
    }
  }
  
  Future<void> _handleNetworkFailure(CurrencyError error) async {
    final retryKey = 'network_${error.operation}';
    final retryCount = _retryCounters[retryKey] ?? 0;
    
    if (retryCount < 3) {
      _retryCounters[retryKey] = retryCount + 1;
      _lastRetryAttempts[retryKey] = DateTime.now();
      
      // Exponential backoff: 1s, 4s, 16s
      final delaySeconds = 1 << (retryCount * 2);
      
      _retryTimer?.cancel();
      _retryTimer = Timer(Duration(seconds: delaySeconds), () {
        _performRetry(error);
      });
    }
  }
  
  Future<void> _handleExpiredRates(CurrencyError error) async {
    if (error.context['currency'] is String) {
      final currency = error.context['currency'] as String;
      try {
        final currencyService = ref.read(currencyServiceProvider);
        await currencyService.fetchDailyRates(currency);
        
        // Clear the error since we successfully refreshed
        _clearErrorsForOperation(error.operation);
      } catch (e) {
        // If refresh fails, record as a new error
        recordError(CurrencyError(
          type: CurrencyErrorType.serviceUnavailable,
          operation: 'rate_refresh',
          message: 'Failed to refresh expired rates: $e',
          context: {'originalError': error},
        ));
      }
    }
  }
  
  Future<void> _handleConversionFailure(CurrencyError error) async {
    // Try alternative conversion paths or fallback to cached rates
    if (error.context['fromCurrency'] is String && 
        error.context['toCurrency'] is String) {
      final fromCurrency = error.context['fromCurrency'] as String;
      final toCurrency = error.context['toCurrency'] as String;
      
      try {
        final currencyService = ref.read(currencyServiceProvider);
        
        // Try conversion via USD as intermediate currency
        if (fromCurrency != 'USD' && toCurrency != 'USD') {
          final toUsd = await currencyService.convertAmount(
            amount: 1.0,
            fromCurrency: fromCurrency,
            toCurrency: 'USD',
          );
          
          if (toUsd != null) {
            final fromUsd = await currencyService.convertAmount(
              amount: toUsd.convertedAmount,
              fromCurrency: 'USD',
              toCurrency: toCurrency,
            );
            
            if (fromUsd != null) {
              // Success! Clear the conversion error
              _clearErrorsForOperation(error.operation);
            }
          }
        }
      } catch (e) {
        // Alternative conversion also failed
      }
    }
  }
  
  Future<void> _handleServiceUnavailable(CurrencyError error) async {
    // For service unavailable, we mainly rely on cached data
    // and notify user about offline mode
    final currentState = state;
    state = currentState.copyWith(
      isOfflineMode: true,
      offlineModeMessage: 'Currency service temporarily unavailable. Using cached exchange rates.',
    );
  }
  
  Future<void> _performRetry(CurrencyError error) async {
    try {
      // Attempt to perform the failed operation again
      switch (error.operation) {
        case 'fetch_rates':
          if (error.context['currency'] is String) {
            final currency = error.context['currency'] as String;
            final currencyService = ref.read(currencyServiceProvider);
            await currencyService.fetchDailyRates(currency);
            _clearErrorsForOperation(error.operation);
          }
          break;
        case 'convert_currency':
          // Retry conversion will be handled by the conversion provider
          ref.invalidate(currencyConversionProvider);
          break;
        default:
          break;
      }
    } catch (e) {
      // Retry failed, but we don't record this as a new error
      // to avoid infinite retry loops
    }
  }
  
  void _clearErrorsForOperation(String operation) {
    final currentState = state;
    final filteredErrors = currentState.recentErrors
        .where((error) => error.operation != operation)
        .toList();
    
    state = currentState.copyWith(
      recentErrors: filteredErrors,
      isOfflineMode: false,
      offlineModeMessage: null,
    );
  }
  
  /// Clear all errors
  void clearErrors() {
    state = const CurrencyErrorState();
    _retryCounters.clear();
    _lastRetryAttempts.clear();
  }
  
  /// Get error summary for the last hour
  ErrorSummary getRecentErrorSummary() {
    final currentState = state;
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    
    final recentErrors = currentState.recentErrors
        .where((error) => error.timestamp.isAfter(oneHourAgo))
        .toList();
    
    final errorsByType = <CurrencyErrorType, int>{};
    for (final error in recentErrors) {
      errorsByType[error.type] = (errorsByType[error.type] ?? 0) + 1;
    }
    
    return ErrorSummary(
      totalErrors: recentErrors.length,
      errorsByType: errorsByType,
      isOfflineMode: currentState.isOfflineMode,
      hasActiveRetries: _retryCounters.isNotEmpty,
    );
  }
}

/// Provider for fallback currency conversion strategies
/// 
/// Provides alternative conversion methods when primary conversion fails.
@riverpod
Future<CurrencyConversion?> fallbackCurrencyConversion(
  FallbackCurrencyConversionRef ref,
  double amount,
  String fromCurrency,
  String toCurrency,
) async {
  // First try the normal conversion
  try {
    final normalConversion = await ref.watch(currencyConversionProvider(
      amount,
      fromCurrency,
      toCurrency,
    ).future);
    
    if (normalConversion != null) {
      return normalConversion;
    }
  } catch (e) {
    ref.read(currencyErrorMonitorProvider.notifier).recordError(
      CurrencyError(
        type: CurrencyErrorType.conversionFailed,
        operation: 'convert_currency',
        message: 'Primary conversion failed: $e',
        context: {
          'fromCurrency': fromCurrency,
          'toCurrency': toCurrency,
          'amount': amount,
        },
      ),
    );
  }
  
  // Try fallback strategies
  return await _tryFallbackStrategies(ref, amount, fromCurrency, toCurrency);
}

Future<CurrencyConversion?> _tryFallbackStrategies(
  FallbackCurrencyConversionRef ref,
  double amount,
  String fromCurrency,
  String toCurrency,
) async {
  final currencyService = ref.read(currencyServiceProvider);
  
  // Strategy 1: Try conversion via USD
  if (fromCurrency != 'USD' && toCurrency != 'USD') {
    try {
      final toUsd = await currencyService.convertAmount(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: 'USD',
      );
      
      if (toUsd != null) {
        final fromUsd = await currencyService.convertAmount(
          amount: toUsd.convertedAmount,
          fromCurrency: 'USD',
          toCurrency: toCurrency,
        );
        
        if (fromUsd != null) {
          // Create a combined conversion result
          return CurrencyConversion(
            originalAmount: amount,
            originalCurrency: fromCurrency,
            convertedAmount: fromUsd.convertedAmount,
            targetCurrency: toCurrency,
            exchangeRate: fromUsd.convertedAmount / amount,
            rateDate: fromUsd.rateDate,
          );
        }
      }
    } catch (e) {
      // Strategy 1 failed, continue to next strategy
    }
  }
  
  // Strategy 2: Try conversion via EUR (if not already involved)
  if (fromCurrency != 'EUR' && toCurrency != 'EUR' && 
      fromCurrency != 'USD' && toCurrency != 'USD') {
    try {
      final toEur = await currencyService.convertAmount(
        amount: amount,
        fromCurrency: fromCurrency,
        toCurrency: 'EUR',
      );
      
      if (toEur != null) {
        final fromEur = await currencyService.convertAmount(
          amount: toEur.convertedAmount,
          fromCurrency: 'EUR',
          toCurrency: toCurrency,
        );
        
        if (fromEur != null) {
          return CurrencyConversion(
            originalAmount: amount,
            originalCurrency: fromCurrency,
            convertedAmount: fromEur.convertedAmount,
            targetCurrency: toCurrency,
            exchangeRate: fromEur.convertedAmount / amount,
            rateDate: fromEur.rateDate,
          );
        }
      }
    } catch (e) {
      // Strategy 2 failed, continue to next strategy
    }
  }
  
  // Strategy 3: Use historical/approximate rates if available
  try {
    return await _tryApproximateConversion(ref, amount, fromCurrency, toCurrency);
  } catch (e) {
    // All strategies failed
  }
  
  // Record the complete failure
  ref.read(currencyErrorMonitorProvider.notifier).recordError(
    CurrencyError(
      type: CurrencyErrorType.conversionFailed,
      operation: 'fallback_conversion',
      message: 'All conversion strategies failed',
      context: {
        'fromCurrency': fromCurrency,
        'toCurrency': toCurrency,
        'amount': amount,
      },
    ),
  );
  
  return null;
}

Future<CurrencyConversion?> _tryApproximateConversion(
  FallbackCurrencyConversionRef ref,
  double amount,
  String fromCurrency,
  String toCurrency,
) async {
  // This is a simplified approximation - in a real app you might
  // have historical rates or use approximate ratios
  final approximateRates = <String, double>{
    'USD_EUR': 0.85,
    'EUR_USD': 1.18,
    'USD_GBP': 0.73,
    'GBP_USD': 1.37,
    'EUR_GBP': 0.86,
    'GBP_EUR': 1.16,
    'USD_CAD': 1.25,
    'CAD_USD': 0.80,
    'USD_AUD': 1.35,
    'AUD_USD': 0.74,
    'USD_JPY': 110.0,
    'JPY_USD': 0.009,
  };
  
  final rateKey = '${fromCurrency}_$toCurrency';
  final rate = approximateRates[rateKey];
  
  if (rate != null) {
    return CurrencyConversion(
      originalAmount: amount,
      originalCurrency: fromCurrency,
      convertedAmount: amount * rate,
      targetCurrency: toCurrency,
      exchangeRate: rate,
      rateDate: DateTime.now().subtract(const Duration(days: 1)), // Mark as old
    );
  }
  
  return null;
}

/// Provider for currency operation circuit breaker
/// 
/// Implements circuit breaker pattern to prevent cascading failures
/// in currency operations.
@riverpod
class CurrencyCircuitBreaker extends _$CurrencyCircuitBreaker {
  static const int _failureThreshold = 5;
  static const Duration _recoveryTimeout = Duration(minutes: 5);
  
  @override
  CircuitBreakerState build() {
    return const CircuitBreakerState();
  }
  
  /// Check if operation is allowed
  bool isOperationAllowed(String operation) {
    final currentState = state;
    final operationState = currentState.operationStates[operation];
    
    if (operationState == null) {
      return true; // New operation, allow it
    }
    
    switch (operationState.status) {
      case CircuitStatus.closed:
        return true;
      case CircuitStatus.open:
        // Check if recovery timeout has passed
        if (DateTime.now().difference(operationState.lastFailure) > _recoveryTimeout) {
          // Move to half-open state
          _updateOperationState(operation, operationState.copyWith(
            status: CircuitStatus.halfOpen,
          ));
          return true;
        }
        return false;
      case CircuitStatus.halfOpen:
        return true; // Allow limited testing
    }
  }
  
  /// Record operation success
  void recordSuccess(String operation) {
    final currentState = state;
    final operationState = currentState.operationStates[operation];
    
    if (operationState != null) {
      if (operationState.status == CircuitStatus.halfOpen) {
        // Recovery successful, close the circuit
        _updateOperationState(operation, operationState.copyWith(
          status: CircuitStatus.closed,
          failureCount: 0,
          successCount: operationState.successCount + 1,
        ));
      } else {
        _updateOperationState(operation, operationState.copyWith(
          successCount: operationState.successCount + 1,
        ));
      }
    } else {
      // New operation, create state
      _updateOperationState(operation, OperationState(
        status: CircuitStatus.closed,
        failureCount: 0,
        successCount: 1,
        lastFailure: DateTime.now(),
      ));
    }
  }
  
  /// Record operation failure
  void recordFailure(String operation) {
    final currentState = state;
    final operationState = currentState.operationStates[operation] ??
        OperationState(
          status: CircuitStatus.closed,
          failureCount: 0,
          successCount: 0,
          lastFailure: DateTime.now(),
        );
    
    final newFailureCount = operationState.failureCount + 1;
    final newStatus = newFailureCount >= _failureThreshold 
        ? CircuitStatus.open 
        : operationState.status;
    
    _updateOperationState(operation, operationState.copyWith(
      status: newStatus,
      failureCount: newFailureCount,
      lastFailure: DateTime.now(),
    ));
  }
  
  void _updateOperationState(String operation, OperationState operationState) {
    final currentState = state;
    final updatedStates = Map<String, OperationState>.from(currentState.operationStates);
    updatedStates[operation] = operationState;
    
    state = currentState.copyWith(operationStates: updatedStates);
  }
  
  /// Reset circuit breaker for an operation
  void resetOperation(String operation) {
    final currentState = state;
    final updatedStates = Map<String, OperationState>.from(currentState.operationStates);
    updatedStates.remove(operation);
    
    state = currentState.copyWith(operationStates: updatedStates);
  }
  
  /// Get circuit breaker status for all operations
  Map<String, CircuitStatus> getAllOperationStatuses() {
    return state.operationStates.map((key, value) => MapEntry(key, value.status));
  }
}

/// Error types for currency operations
enum CurrencyErrorType {
  networkFailure,
  rateExpired,
  conversionFailed,
  serviceUnavailable,
  invalidCurrency,
  rateNotFound,
  cacheError,
  unknown,
}

/// Currency error data class
class CurrencyError {
  final CurrencyErrorType type;
  final String operation;
  final String message;
  final Map<String, dynamic> context;
  final DateTime timestamp;
  
  CurrencyError({
    required this.type,
    required this.operation,
    required this.message,
    this.context = const {},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencyError &&
        other.type == type &&
        other.operation == operation &&
        other.message == message &&
        other.timestamp == timestamp;
  }
  
  @override
  int get hashCode {
    return Object.hash(type, operation, message, timestamp);
  }
}

/// Currency error state
class CurrencyErrorState {
  final List<CurrencyError> recentErrors;
  final CurrencyError? lastError;
  final int errorCount;
  final bool isOfflineMode;
  final String? offlineModeMessage;
  
  const CurrencyErrorState({
    this.recentErrors = const [],
    this.lastError,
    this.errorCount = 0,
    this.isOfflineMode = false,
    this.offlineModeMessage,
  });
  
  CurrencyErrorState copyWith({
    List<CurrencyError>? recentErrors,
    CurrencyError? lastError,
    int? errorCount,
    bool? isOfflineMode,
    String? offlineModeMessage,
  }) {
    return CurrencyErrorState(
      recentErrors: recentErrors ?? this.recentErrors,
      lastError: lastError ?? this.lastError,
      errorCount: errorCount ?? this.errorCount,
      isOfflineMode: isOfflineMode ?? this.isOfflineMode,
      offlineModeMessage: offlineModeMessage ?? this.offlineModeMessage,
    );
  }
}

/// Error summary data class
class ErrorSummary {
  final int totalErrors;
  final Map<CurrencyErrorType, int> errorsByType;
  final bool isOfflineMode;
  final bool hasActiveRetries;
  
  const ErrorSummary({
    required this.totalErrors,
    required this.errorsByType,
    required this.isOfflineMode,
    required this.hasActiveRetries,
  });
  
  bool get hasErrors => totalErrors > 0;
  bool get hasNetworkErrors => errorsByType[CurrencyErrorType.networkFailure] != null;
  bool get hasRateErrors => errorsByType[CurrencyErrorType.rateExpired] != null;
}

/// Circuit breaker status
enum CircuitStatus {
  closed,  // Normal operation
  open,    // Failing, reject requests
  halfOpen, // Testing if service recovered
}

/// Operation state for circuit breaker
class OperationState {
  final CircuitStatus status;
  final int failureCount;
  final int successCount;
  final DateTime lastFailure;
  
  const OperationState({
    required this.status,
    required this.failureCount,
    required this.successCount,
    required this.lastFailure,
  });
  
  OperationState copyWith({
    CircuitStatus? status,
    int? failureCount,
    int? successCount,
    DateTime? lastFailure,
  }) {
    return OperationState(
      status: status ?? this.status,
      failureCount: failureCount ?? this.failureCount,
      successCount: successCount ?? this.successCount,
      lastFailure: lastFailure ?? this.lastFailure,
    );
  }
}

/// Circuit breaker state
class CircuitBreakerState {
  final Map<String, OperationState> operationStates;
  
  const CircuitBreakerState({
    this.operationStates = const {},
  });
  
  CircuitBreakerState copyWith({
    Map<String, OperationState>? operationStates,
  }) {
    return CircuitBreakerState(
      operationStates: operationStates ?? this.operationStates,
    );
  }
}