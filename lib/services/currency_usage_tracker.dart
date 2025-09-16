import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

/// Service for tracking user's historical currency usage patterns
/// 
/// This service analyzes user behavior to provide personalized currency
/// suggestions based on past usage. It tracks which currencies users
/// frequently select for specific countries and provides intelligent
/// recommendations based on this historical data.
/// 
/// Features:
/// - Track currency usage per country
/// - Store recent currency selections
/// - Analyze usage patterns and frequencies
/// - Provide personalized suggestions
/// - Respect user privacy with local-only storage
class CurrencyUsageTracker {
  
  // Storage keys for SharedPreferences
  static const String _usagePrefix = 'currency_usage_';
  static const String _globalUsageKey = 'currency_global_usage';
  static const String _recentUsageKey = 'currency_recent_usage';
  static const String _userPreferencesKey = 'currency_user_preferences';
  
  // Configuration
  static const int _maxCountryHistory = 8; // Keep last 8 selections per country
  static const int _maxGlobalHistory = 20; // Keep last 20 global selections
  static const int _maxRecentUsage = 50; // Keep last 50 recent usages for analysis
  
  /// Record a currency selection for a specific country
  /// 
  /// This method tracks when a user selects a currency for a specific country.
  /// It maintains a history of recent selections to understand user preferences.
  /// 
  /// [country] - The country where the currency was used
  /// [currency] - The currency code that was selected
  /// [context] - Optional context (e.g., 'fuel_entry', 'expense_entry')
  /// 
  /// Example:
  /// ```dart
  /// await CurrencyUsageTracker.recordCurrencyUsage('Switzerland', 'CHF');
  /// await CurrencyUsageTracker.recordCurrencyUsage('France', 'EUR', context: 'fuel_entry');
  /// ```
  static Future<void> recordCurrencyUsage(
    String country, 
    String currency, {
    String? context,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      // 1. Record country-specific usage
      await _recordCountryUsage(prefs, country, currency, timestamp);
      
      // 2. Record global usage patterns
      await _recordGlobalUsage(prefs, currency, timestamp);
      
      // 3. Record recent usage for analysis
      await _recordRecentUsage(prefs, country, currency, timestamp, context);
      
      // 4. Update usage statistics
      await _updateUsageStatistics(prefs, country, currency);
      
      developer.log('Recorded currency usage: $currency in $country');
      
    } catch (e) {
      developer.log('Error recording currency usage: $e');
      // Don't throw error - usage tracking is not critical functionality
    }
  }
  
  /// Get user's preferred currencies for a specific country
  /// 
  /// Returns currencies ordered by usage frequency and recency for the given country.
  /// 
  /// [country] - The country to get preferences for
  /// [maxResults] - Maximum number of currencies to return (default: 5)
  /// 
  /// Returns a list of currency codes ordered by preference (most used first)
  static Future<List<String>> getPreferredCurrencies(
    String country, {
    int maxResults = 5,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usageKey = '$_usagePrefix$country';
      final usageData = prefs.getString(usageKey);
      
      if (usageData == null) {
        return [];
      }
      
      final usageList = json.decode(usageData) as List<dynamic>;
      final recentCurrencies = <String>[];
      
      // Extract currencies from usage history, maintaining order (most recent first)
      for (final item in usageList) {
        if (item is Map<String, dynamic>) {
          final currency = item['currency'] as String?;
          if (currency != null && !recentCurrencies.contains(currency)) {
            recentCurrencies.add(currency);
          }
        }
      }
      
      return recentCurrencies.take(maxResults).toList();
      
    } catch (e) {
      developer.log('Error getting preferred currencies for $country: $e');
      return [];
    }
  }
  
  /// Get currency usage frequency for a specific country
  /// 
  /// [country] - The country to analyze
  /// 
  /// Returns a map of currency codes to usage count
  static Future<Map<String, int>> getCurrencyFrequencyForCountry(String country) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usageKey = '$_usagePrefix$country';
      final usageData = prefs.getString(usageKey);
      
      if (usageData == null) {
        return {};
      }
      
      final usageList = json.decode(usageData) as List<dynamic>;
      final frequency = <String, int>{};
      
      for (final item in usageList) {
        if (item is Map<String, dynamic>) {
          final currency = item['currency'] as String?;
          if (currency != null) {
            frequency[currency] = (frequency[currency] ?? 0) + 1;
          }
        }
      }
      
      return frequency;
      
    } catch (e) {
      developer.log('Error getting currency frequency for $country: $e');
      return {};
    }
  }
  
  /// Get globally most used currencies by the user
  /// 
  /// [maxResults] - Maximum number of currencies to return (default: 10)
  /// 
  /// Returns currencies ordered by global usage frequency
  static Future<List<String>> getGloballyPreferredCurrencies({int maxResults = 10}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final globalUsageData = prefs.getString(_globalUsageKey);
      
      if (globalUsageData == null) {
        return [];
      }
      
      final globalUsage = json.decode(globalUsageData) as Map<String, dynamic>;
      final sortedCurrencies = globalUsage.entries.toList()
        ..sort((a, b) => (b.value as int).compareTo(a.value as int));
      
      return sortedCurrencies
          .map((entry) => entry.key)
          .take(maxResults)
          .toList();
      
    } catch (e) {
      developer.log('Error getting globally preferred currencies: $e');
      return [];
    }
  }
  
  /// Get usage statistics and analytics
  /// 
  /// Returns comprehensive usage statistics for analysis and debugging
  static Future<Map<String, dynamic>> getUsageStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stats = <String, dynamic>{};
      
      // Global usage data
      final globalUsageData = prefs.getString(_globalUsageKey);
      if (globalUsageData != null) {
        final globalUsage = json.decode(globalUsageData) as Map<String, dynamic>;
        stats['global_currency_usage'] = globalUsage;
        stats['total_global_entries'] = globalUsage.values
            .fold<int>(0, (sum, count) => sum + (count as int));
      }
      
      // Recent usage analysis
      final recentUsageData = prefs.getString(_recentUsageKey);
      if (recentUsageData != null) {
        final recentUsage = json.decode(recentUsageData) as List<dynamic>;
        stats['recent_usage_count'] = recentUsage.length;
        
        // Analyze recent usage patterns
        final recentCountries = <String>{};
        final recentCurrencies = <String>{};
        
        for (final item in recentUsage) {
          if (item is Map<String, dynamic>) {
            final country = item['country'] as String?;
            final currency = item['currency'] as String?;
            if (country != null) recentCountries.add(country);
            if (currency != null) recentCurrencies.add(currency);
          }
        }
        
        stats['countries_used_recently'] = recentCountries.length;
        stats['currencies_used_recently'] = recentCurrencies.length;
      }
      
      // Country-specific usage counts
      final countryUsageCounts = <String, int>{};
      final allKeys = prefs.getKeys().where((key) => key.startsWith(_usagePrefix));
      
      for (final key in allKeys) {
        final country = key.substring(_usagePrefix.length);
        final usageData = prefs.getString(key);
        if (usageData != null) {
          final usageList = json.decode(usageData) as List<dynamic>;
          countryUsageCounts[country] = usageList.length;
        }
      }
      
      stats['country_usage_counts'] = countryUsageCounts;
      stats['countries_with_usage_data'] = countryUsageCounts.length;
      
      return stats;
      
    } catch (e) {
      developer.log('Error getting usage statistics: $e');
      return {'error': 'Failed to retrieve usage statistics'};
    }
  }
  
  /// Get smart currency ranking based on usage patterns
  /// 
  /// This method combines multiple factors to rank currencies:
  /// - Recent usage frequency
  /// - Global usage patterns
  /// - Country-specific preferences
  /// - Recency bias (more recent = higher priority)
  /// 
  /// [country] - The country context
  /// [availableCurrencies] - List of currencies to rank
  /// 
  /// Returns currencies sorted by smart ranking algorithm
  static Future<List<String>> getSmartCurrencyRanking(
    String country,
    List<String> availableCurrencies,
  ) async {
    try {
      if (availableCurrencies.isEmpty) return [];
      
      final scores = <String, double>{};
      
      // Initialize all currencies with base score
      for (final currency in availableCurrencies) {
        scores[currency] = 0.0;
      }
      
      // 1. Country-specific preferences (weight: 0.5)
      final countryFrequency = await getCurrencyFrequencyForCountry(country);
      final maxCountryUsage = countryFrequency.values.fold<int>(0, (a, b) => a > b ? a : b);
      
      if (maxCountryUsage > 0) {
        countryFrequency.forEach((currency, count) {
          if (scores.containsKey(currency)) {
            scores[currency] = scores[currency]! + (count / maxCountryUsage) * 0.5;
          }
        });
      }
      
      // 2. Global preferences (weight: 0.3)
      final globalPreferred = await getGloballyPreferredCurrencies();
      for (int i = 0; i < globalPreferred.length; i++) {
        final currency = globalPreferred[i];
        if (scores.containsKey(currency)) {
          // Higher score for higher global ranking
          final globalScore = (globalPreferred.length - i) / globalPreferred.length;
          scores[currency] = scores[currency]! + globalScore * 0.3;
        }
      }
      
      // 3. Recent usage recency bonus (weight: 0.2)
      final recentPreferred = await getPreferredCurrencies(country);
      for (int i = 0; i < recentPreferred.length; i++) {
        final currency = recentPreferred[i];
        if (scores.containsKey(currency)) {
          // Higher score for more recent usage
          final recencyScore = (recentPreferred.length - i) / recentPreferred.length;
          scores[currency] = scores[currency]! + recencyScore * 0.2;
        }
      }
      
      // Sort by score (highest first)
      final sortedCurrencies = scores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      return sortedCurrencies.map((entry) => entry.key).toList();
      
    } catch (e) {
      developer.log('Error in smart currency ranking: $e');
      // Return original list as fallback
      return availableCurrencies;
    }
  }
  
  /// Clear all usage tracking data
  /// 
  /// This method removes all stored usage data. Use with caution.
  static Future<void> clearAllUsageData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove all usage-related keys
      final keysToRemove = prefs.getKeys().where((key) => 
          key.startsWith(_usagePrefix) ||
          key == _globalUsageKey ||
          key == _recentUsageKey ||
          key == _userPreferencesKey
      );
      
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
      
      developer.log('Cleared all currency usage data');
      
    } catch (e) {
      developer.log('Error clearing usage data: $e');
      throw Exception('Failed to clear usage data: $e');
    }
  }
  
  /// Clear usage data for a specific country
  /// 
  /// [country] - The country to clear data for
  static Future<void> clearCountryUsageData(String country) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usageKey = '$_usagePrefix$country';
      await prefs.remove(usageKey);
      
      developer.log('Cleared usage data for country: $country');
      
    } catch (e) {
      developer.log('Error clearing country usage data: $e');
      throw Exception('Failed to clear country usage data: $e');
    }
  }
  
  // Private helper methods
  
  static Future<void> _recordCountryUsage(
    SharedPreferences prefs,
    String country,
    String currency,
    int timestamp,
  ) async {
    final usageKey = '$_usagePrefix$country';
    final existingData = prefs.getString(usageKey);
    
    List<dynamic> usageList;
    if (existingData != null) {
      usageList = json.decode(existingData) as List<dynamic>;
    } else {
      usageList = [];
    }
    
    // Add new usage record
    usageList.insert(0, {
      'currency': currency,
      'timestamp': timestamp,
    });
    
    // Limit history size
    if (usageList.length > _maxCountryHistory) {
      usageList = usageList.take(_maxCountryHistory).toList();
    }
    
    await prefs.setString(usageKey, json.encode(usageList));
  }
  
  static Future<void> _recordGlobalUsage(
    SharedPreferences prefs,
    String currency,
    int timestamp,
  ) async {
    final existingData = prefs.getString(_globalUsageKey);
    
    Map<String, dynamic> globalUsage;
    if (existingData != null) {
      globalUsage = json.decode(existingData) as Map<String, dynamic>;
    } else {
      globalUsage = {};
    }
    
    // Increment usage count
    globalUsage[currency] = (globalUsage[currency] as int? ?? 0) + 1;
    
    await prefs.setString(_globalUsageKey, json.encode(globalUsage));
  }
  
  static Future<void> _recordRecentUsage(
    SharedPreferences prefs,
    String country,
    String currency,
    int timestamp,
    String? context,
  ) async {
    final existingData = prefs.getString(_recentUsageKey);
    
    List<dynamic> recentUsage;
    if (existingData != null) {
      recentUsage = json.decode(existingData) as List<dynamic>;
    } else {
      recentUsage = [];
    }
    
    // Add new recent usage record
    final usageRecord = {
      'country': country,
      'currency': currency,
      'timestamp': timestamp,
    };
    
    if (context != null) {
      usageRecord['context'] = context;
    }
    
    recentUsage.insert(0, usageRecord);
    
    // Limit recent usage history
    if (recentUsage.length > _maxRecentUsage) {
      recentUsage = recentUsage.take(_maxRecentUsage).toList();
    }
    
    await prefs.setString(_recentUsageKey, json.encode(recentUsage));
  }
  
  static Future<void> _updateUsageStatistics(
    SharedPreferences prefs,
    String country,
    String currency,
  ) async {
    // Update user preferences metadata
    final prefsData = prefs.getString(_userPreferencesKey);
    
    Map<String, dynamic> userPrefs;
    if (prefsData != null) {
      userPrefs = json.decode(prefsData) as Map<String, dynamic>;
    } else {
      userPrefs = {
        'first_usage': DateTime.now().millisecondsSinceEpoch,
        'countries_used': <String>[],
        'currencies_used': <String>[],
      };
    }
    
    // Update last usage
    userPrefs['last_usage'] = DateTime.now().millisecondsSinceEpoch;
    
    // Update countries and currencies lists
    final countriesUsed = List<String>.from(userPrefs['countries_used'] ?? []);
    final currenciesUsed = List<String>.from(userPrefs['currencies_used'] ?? []);
    
    if (!countriesUsed.contains(country)) {
      countriesUsed.add(country);
    }
    if (!currenciesUsed.contains(currency)) {
      currenciesUsed.add(currency);
    }
    
    userPrefs['countries_used'] = countriesUsed;
    userPrefs['currencies_used'] = currenciesUsed;
    
    await prefs.setString(_userPreferencesKey, json.encode(userPrefs));
  }
}