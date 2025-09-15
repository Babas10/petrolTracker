import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../currency/currency_settings.dart';
import '../../utils/currency_validator.dart';

/// Repository for persisting and retrieving currency settings
/// 
/// Handles storage of user currency preferences using SharedPreferences.
/// Provides methods for loading, saving, and managing currency settings
/// with proper validation and error handling.
class CurrencySettingsRepository {
  /// Key for storing currency settings in SharedPreferences
  static const String _settingsKey = 'currency_settings';
  
  /// Key for storing primary currency (for backward compatibility)
  static const String _primaryCurrencyKey = 'primary_currency';
  
  /// Default currency settings if none are found
  static const CurrencySettings _defaultSettings = CurrencySettings();

  /// Load currency settings from persistent storage
  /// 
  /// Returns stored settings or default settings if none exist.
  /// Validates loaded settings and falls back to defaults if invalid.
  /// 
  /// Example:
  /// ```dart
  /// final repository = CurrencySettingsRepository();
  /// final settings = await repository.loadSettings();
  /// print(settings.primaryCurrency); // "USD" or user's choice
  /// ```
  Future<CurrencySettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try to load full settings first
      final settingsJson = prefs.getString(_settingsKey);
      if (settingsJson != null) {
        final decoded = jsonDecode(settingsJson) as Map<String, dynamic>;
        final settings = CurrencySettings.fromJson(decoded);
        
        // Validate loaded settings
        if (_isValidSettings(settings)) {
          return settings;
        }
      }
      
      // Fallback: check for legacy primary currency setting
      final legacyPrimaryCurrency = prefs.getString(_primaryCurrencyKey);
      if (legacyPrimaryCurrency != null && 
          CurrencyValidator.isValidCurrency(legacyPrimaryCurrency)) {
        return _defaultSettings.copyWith(
          primaryCurrency: legacyPrimaryCurrency,
          lastUpdated: DateTime.now(),
        );
      }
      
      // Return default settings
      return _defaultSettings;
    } catch (e) {
      // If any error occurs, return default settings
      return _defaultSettings;
    }
  }

  /// Save currency settings to persistent storage
  /// 
  /// Validates settings before saving and updates the lastUpdated timestamp.
  /// Throws an exception if the settings are invalid.
  /// 
  /// Example:
  /// ```dart
  /// final repository = CurrencySettingsRepository();
  /// final settings = CurrencySettings(primaryCurrency: 'EUR');
  /// await repository.saveSettings(settings);
  /// ```
  Future<void> saveSettings(CurrencySettings settings) async {
    // Validate settings before saving
    if (!_isValidSettings(settings)) {
      throw ArgumentError('Invalid currency settings: primary currency must be supported');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Update lastUpdated timestamp
      final updatedSettings = settings.copyWith(lastUpdated: DateTime.now());
      
      // Save as JSON
      final settingsJson = jsonEncode(updatedSettings.toJson());
      await prefs.setString(_settingsKey, settingsJson);
      
      // Also save primary currency separately for backward compatibility
      await prefs.setString(_primaryCurrencyKey, updatedSettings.primaryCurrency);
    } catch (e) {
      throw Exception('Failed to save currency settings: $e');
    }
  }

  /// Update only the primary currency
  /// 
  /// Convenience method to update just the primary currency while preserving
  /// other settings. Validates the new currency before updating.
  /// 
  /// Example:
  /// ```dart
  /// final repository = CurrencySettingsRepository();
  /// await repository.updatePrimaryCurrency('EUR');
  /// ```
  Future<void> updatePrimaryCurrency(String newCurrency) async {
    final normalizedCurrency = newCurrency.toUpperCase();
    if (!CurrencyValidator.isValidCurrency(normalizedCurrency)) {
      throw ArgumentError('Invalid currency code: $newCurrency');
    }

    final currentSettings = await loadSettings();
    final updatedSettings = currentSettings.updatePrimaryCurrency(normalizedCurrency);
    await saveSettings(updatedSettings);
  }

  /// Get the current primary currency
  /// 
  /// Quick way to get just the primary currency without loading full settings.
  /// Returns 'USD' as default if no settings are found.
  /// 
  /// Example:
  /// ```dart
  /// final repository = CurrencySettingsRepository();
  /// final currency = await repository.getPrimaryCurrency();
  /// print(currency); // "USD" or user's selection
  /// ```
  Future<String> getPrimaryCurrency() async {
    try {
      final settings = await loadSettings();
      return settings.primaryCurrency;
    } catch (e) {
      return _defaultSettings.primaryCurrency;
    }
  }

  /// Add a currency to favorites
  /// 
  /// Adds the specified currency to the user's favorites list if it's valid
  /// and not already in the list.
  /// 
  /// Example:
  /// ```dart
  /// final repository = CurrencySettingsRepository();
  /// await repository.addFavoriteCurrency('EUR');
  /// ```
  Future<void> addFavoriteCurrency(String currency) async {
    final normalizedCurrency = currency.toUpperCase();
    if (!CurrencyValidator.isValidCurrency(normalizedCurrency)) {
      throw ArgumentError('Invalid currency code: $currency');
    }

    final currentSettings = await loadSettings();
    final updatedSettings = currentSettings.addFavoriteCurrency(normalizedCurrency);
    await saveSettings(updatedSettings);
  }

  /// Remove a currency from favorites
  /// 
  /// Removes the specified currency from the user's favorites list.
  /// 
  /// Example:
  /// ```dart
  /// final repository = CurrencySettingsRepository();
  /// await repository.removeFavoriteCurrency('EUR');
  /// ```
  Future<void> removeFavoriteCurrency(String currency) async {
    final currentSettings = await loadSettings();
    final updatedSettings = currentSettings.removeFavoriteCurrency(currency);
    await saveSettings(updatedSettings);
  }

  /// Clear all stored settings
  /// 
  /// Removes all currency settings from persistent storage.
  /// Useful for app reset or data clearing functionality.
  /// 
  /// Example:
  /// ```dart
  /// final repository = CurrencySettingsRepository();
  /// await repository.clearSettings();
  /// ```
  Future<void> clearSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_settingsKey);
      await prefs.remove(_primaryCurrencyKey);
    } catch (e) {
      throw Exception('Failed to clear currency settings: $e');
    }
  }

  /// Check if settings exist in storage
  /// 
  /// Returns true if any currency settings are stored, false otherwise.
  /// Useful for determining if this is a first-time user.
  /// 
  /// Example:
  /// ```dart
  /// final repository = CurrencySettingsRepository();
  /// final hasSettings = await repository.hasStoredSettings();
  /// if (!hasSettings) {
  ///   // Show onboarding or currency selection
  /// }
  /// ```
  Future<bool> hasStoredSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_settingsKey) || prefs.containsKey(_primaryCurrencyKey);
    } catch (e) {
      return false;
    }
  }

  /// Get storage size information
  /// 
  /// Returns information about the storage usage for currency settings.
  /// Useful for debugging or data management features.
  /// 
  /// Returns a map with keys: 'hasSettings', 'settingsSize', 'lastUpdated'
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);
      final hasSettings = settingsJson != null;
      
      DateTime? lastUpdated;
      if (hasSettings) {
        try {
          final decoded = jsonDecode(settingsJson!) as Map<String, dynamic>;
          final settings = CurrencySettings.fromJson(decoded);
          lastUpdated = settings.lastUpdated;
        } catch (e) {
          // Ignore parsing errors
        }
      }
      
      return {
        'hasSettings': hasSettings,
        'settingsSize': settingsJson?.length ?? 0,
        'lastUpdated': lastUpdated?.toIso8601String(),
      };
    } catch (e) {
      return {
        'hasSettings': false,
        'settingsSize': 0,
        'lastUpdated': null,
      };
    }
  }

  /// Validate currency settings
  /// 
  /// Internal method to validate settings before saving or after loading.
  /// Ensures the primary currency is supported and settings are consistent.
  bool _isValidSettings(CurrencySettings settings) {
    // Check primary currency
    if (!CurrencyValidator.isValidCurrency(settings.primaryCurrency)) {
      return false;
    }
    
    // Check decimal places are reasonable
    if (settings.decimalPlaces < 0 || settings.decimalPlaces > 4) {
      return false;
    }
    
    // Check max rate age is reasonable
    if (settings.maxRateAgeHours <= 0 || settings.maxRateAgeHours > 168) { // Max 7 days
      return false;
    }
    
    // Check all favorite currencies are valid
    for (final currency in settings.favoriteCurrencies) {
      if (!CurrencyValidator.isValidCurrency(currency)) {
        return false;
      }
    }
    
    return true;
  }
}