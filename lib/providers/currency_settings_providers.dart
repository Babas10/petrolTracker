import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/currency/currency_settings.dart';
import '../models/repositories/currency_settings_repository.dart';
import '../utils/currency_validator.dart';

part 'currency_settings_providers.g.dart';

/// Provider for the currency settings repository
@riverpod
CurrencySettingsRepository currencySettingsRepository(CurrencySettingsRepositoryRef ref) {
  return CurrencySettingsRepository();
}

/// Provider for currency settings state management
/// 
/// Manages the user's currency preferences including primary currency,
/// display options, and persistence. Provides methods for updating
/// settings with automatic validation and persistence.
@riverpod
class CurrencySettingsNotifier extends _$CurrencySettingsNotifier {
  /// Initialize currency settings by loading from storage
  @override
  Future<CurrencySettings> build() async {
    final repository = ref.read(currencySettingsRepositoryProvider);
    return await repository.loadSettings();
  }

  /// Update the primary currency
  /// 
  /// Validates the new currency and updates the settings if valid.
  /// Automatically persists the change and triggers UI updates.
  /// 
  /// Example:
  /// ```dart
  /// await ref.read(currencySettingsNotifierProvider.notifier).updatePrimaryCurrency('EUR');
  /// ```
  Future<void> updatePrimaryCurrency(String newCurrency) async {
    // Validate currency
    if (!CurrencyValidator.isValidCurrency(newCurrency)) {
      throw ArgumentError('Invalid currency code: $newCurrency');
    }

    final repository = ref.read(currencySettingsRepositoryProvider);
    
    // Update state optimistically
    final currentState = await future;
    final updatedSettings = currentState.updatePrimaryCurrency(newCurrency);
    state = AsyncValue.data(updatedSettings);
    
    try {
      // Persist to storage
      await repository.saveSettings(updatedSettings);
    } catch (e) {
      // Revert optimistic update on error
      state = AsyncValue.data(currentState);
      rethrow;
    }
  }

  /// Update display preferences
  /// 
  /// Updates currency display settings like showing original amounts,
  /// exchange rates, and conversion indicators.
  /// 
  /// Example:
  /// ```dart
  /// await ref.read(currencySettingsNotifierProvider.notifier).updateDisplaySettings(
  ///   showOriginalAmounts: false,
  ///   showExchangeRates: true,
  /// );
  /// ```
  Future<void> updateDisplaySettings({
    bool? showOriginalAmounts,
    bool? showExchangeRates,
    bool? showConversionIndicators,
    int? decimalPlaces,
  }) async {
    final repository = ref.read(currencySettingsRepositoryProvider);
    final currentState = await future;
    
    final updatedSettings = currentState.copyWith(
      showOriginalAmounts: showOriginalAmounts ?? currentState.showOriginalAmounts,
      showExchangeRates: showExchangeRates ?? currentState.showExchangeRates,
      showConversionIndicators: showConversionIndicators ?? currentState.showConversionIndicators,
      decimalPlaces: decimalPlaces ?? currentState.decimalPlaces,
      lastUpdated: DateTime.now(),
    );

    // Validate decimal places
    if (updatedSettings.decimalPlaces < 0 || updatedSettings.decimalPlaces > 4) {
      throw ArgumentError('Decimal places must be between 0 and 4');
    }

    // Update state and persist
    state = AsyncValue.data(updatedSettings);
    await repository.saveSettings(updatedSettings);
  }

  /// Update rate refresh settings
  /// 
  /// Updates settings related to exchange rate fetching and caching.
  /// 
  /// Example:
  /// ```dart
  /// await ref.read(currencySettingsNotifierProvider.notifier).updateRateSettings(
  ///   autoUpdateRates: true,
  ///   maxRateAgeHours: 12,
  /// );
  /// ```
  Future<void> updateRateSettings({
    bool? autoUpdateRates,
    int? maxRateAgeHours,
  }) async {
    final repository = ref.read(currencySettingsRepositoryProvider);
    final currentState = await future;
    
    final updatedSettings = currentState.copyWith(
      autoUpdateRates: autoUpdateRates ?? currentState.autoUpdateRates,
      maxRateAgeHours: maxRateAgeHours ?? currentState.maxRateAgeHours,
      lastUpdated: DateTime.now(),
    );

    // Validate max rate age
    if (updatedSettings.maxRateAgeHours <= 0 || updatedSettings.maxRateAgeHours > 168) {
      throw ArgumentError('Max rate age must be between 1 and 168 hours (7 days)');
    }

    // Update state and persist
    state = AsyncValue.data(updatedSettings);
    await repository.saveSettings(updatedSettings);
  }

  /// Add a currency to favorites
  /// 
  /// Adds the specified currency to the user's favorites list.
  /// Validates the currency code before adding.
  /// 
  /// Example:
  /// ```dart
  /// await ref.read(currencySettingsNotifierProvider.notifier).addFavoriteCurrency('EUR');
  /// ```
  Future<void> addFavoriteCurrency(String currency) async {
    if (!CurrencyValidator.isValidCurrency(currency)) {
      throw ArgumentError('Invalid currency code: $currency');
    }

    final repository = ref.read(currencySettingsRepositoryProvider);
    final currentState = await future;
    
    final updatedSettings = currentState.addFavoriteCurrency(currency);
    state = AsyncValue.data(updatedSettings);
    await repository.saveSettings(updatedSettings);
  }

  /// Remove a currency from favorites
  /// 
  /// Removes the specified currency from the user's favorites list.
  /// 
  /// Example:
  /// ```dart
  /// await ref.read(currencySettingsNotifierProvider.notifier).removeFavoriteCurrency('EUR');
  /// ```
  Future<void> removeFavoriteCurrency(String currency) async {
    final repository = ref.read(currencySettingsRepositoryProvider);
    final currentState = await future;
    
    final updatedSettings = currentState.removeFavoriteCurrency(currency);
    state = AsyncValue.data(updatedSettings);
    await repository.saveSettings(updatedSettings);
  }

  /// Reset settings to defaults
  /// 
  /// Resets all currency settings to their default values.
  /// Useful for app reset functionality.
  /// 
  /// Example:
  /// ```dart
  /// await ref.read(currencySettingsNotifierProvider.notifier).resetToDefaults();
  /// ```
  Future<void> resetToDefaults() async {
    const defaultSettings = CurrencySettingsModel();
    final repository = ref.read(currencySettingsRepositoryProvider);
    
    state = AsyncValue.data(defaultSettings);
    await repository.saveSettings(defaultSettings);
    
    // Invalidate dependent providers
    ref.invalidate(primaryCurrencyProvider);
  }

  /// Refresh settings from storage
  /// 
  /// Forces a reload of settings from persistent storage.
  /// Useful if settings might have been modified externally.
  /// 
  /// Example:
  /// ```dart
  /// await ref.read(currencySettingsNotifierProvider.notifier).refresh();
  /// ```
  Future<void> refresh() async {
    final repository = ref.read(currencySettingsRepositoryProvider);
    final freshSettings = await repository.loadSettings();
    state = AsyncValue.data(freshSettings);
  }
}

/// Provider for just the primary currency
/// 
/// Convenient provider for accessing just the primary currency without
/// loading the full settings object. Automatically updates when settings change.
@riverpod
Future<String> primaryCurrency(PrimaryCurrencyRef ref) async {
  final settings = await ref.watch(currencySettingsNotifierProvider.future);
  return settings.primaryCurrency;
}

/// Provider for checking if this is a first-time user
/// 
/// Returns true if no currency settings have been stored yet.
/// Useful for showing onboarding or default currency selection.
@riverpod
Future<bool> isFirstTimeUser(IsFirstTimeUserRef ref) async {
  final repository = ref.read(currencySettingsRepositoryProvider);
  return !(await repository.hasStoredSettings());
}

/// Provider for currency display preferences
/// 
/// Extracts just the display-related settings for UI components.
@riverpod
Future<CurrencyDisplayPreferences> currencyDisplayPreferences(CurrencyDisplayPreferencesRef ref) async {
  final settings = await ref.watch(currencySettingsNotifierProvider.future);
  return CurrencyDisplayPreferences(
    showOriginalAmounts: settings.showOriginalAmounts,
    showExchangeRates: settings.showExchangeRates,
    showConversionIndicators: settings.showConversionIndicators,
    decimalPlaces: settings.decimalPlaces,
  );
}

/// Data class for currency display preferences
/// 
/// Simplified model containing only display-related settings
/// for easier consumption by UI components.
class CurrencyDisplayPreferences {
  final bool showOriginalAmounts;
  final bool showExchangeRates;
  final bool showConversionIndicators;
  final int decimalPlaces;

  const CurrencyDisplayPreferences({
    required this.showOriginalAmounts,
    required this.showExchangeRates,
    required this.showConversionIndicators,
    required this.decimalPlaces,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencyDisplayPreferences &&
        other.showOriginalAmounts == showOriginalAmounts &&
        other.showExchangeRates == showExchangeRates &&
        other.showConversionIndicators == showConversionIndicators &&
        other.decimalPlaces == decimalPlaces;
  }

  @override
  int get hashCode {
    return Object.hash(
      showOriginalAmounts,
      showExchangeRates,
      showConversionIndicators,
      decimalPlaces,
    );
  }
}

/// Convenient typedef for the currency settings model
typedef CurrencySettingsModel = CurrencySettings;