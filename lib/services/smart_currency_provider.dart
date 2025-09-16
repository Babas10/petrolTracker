import 'dart:developer' as developer;
import 'country_currency_service.dart';
import 'geographic_currency_detector.dart';
import 'currency_usage_tracker.dart';
import 'currency_metadata.dart';
import '../models/currency_info.dart';

/// Advanced currency suggestion service that combines multiple intelligence sources
/// 
/// This service provides the most intelligent currency suggestions by combining:
/// - Country-specific currency mappings
/// - User's historical usage patterns
/// - Geographic and regional relationships
/// - Economic zone considerations
/// - Multi-currency country support
/// 
/// It serves as the primary interface for getting smart currency suggestions
/// throughout the application.
class SmartCurrencyProvider {
  
  /// Get intelligent currency suggestions for a country
  /// 
  /// This is the main method that combines all intelligence sources to provide
  /// the most relevant currency suggestions for a user in a specific country.
  /// 
  /// Intelligence sources (in priority order):
  /// 1. User's historical preferences for this country
  /// 2. Primary currency of the selected country
  /// 3. User's default/primary currency
  /// 4. Multi-currency country alternatives
  /// 5. Geographic and regional currencies
  /// 6. International fallback currencies
  /// 
  /// [country] - The selected country
  /// [userDefaultCurrency] - User's primary/default currency
  /// [includeUsageHistory] - Whether to include historical usage patterns (default: true)
  /// [includeRegionalCurrencies] - Whether to include geographic suggestions (default: true)
  /// [maxSuggestions] - Maximum number of suggestions (default: 8)
  /// 
  /// Returns a list of currency codes ordered by relevance and intelligence
  static Future<List<String>> getSmartSuggestions({
    required String country,
    required String userDefaultCurrency,
    bool includeUsageHistory = true,
    bool includeRegionalCurrencies = true,
    int maxSuggestions = 8,
  }) async {
    try {
      final suggestions = <String>[];
      final addedCurrencies = <String>{};
      
      // 1. User's historical preferences for this country (highest priority)
      if (includeUsageHistory) {
        final historicalPreferences = await CurrencyUsageTracker.getPreferredCurrencies(
          country,
          maxResults: 3,
        );
        
        for (final currency in historicalPreferences) {
          if (suggestions.length >= maxSuggestions) break;
          if (!addedCurrencies.contains(currency)) {
            suggestions.add(currency);
            addedCurrencies.add(currency);
          }
        }
      }
      
      // 2. Primary currency of the selected country
      final primaryCurrency = CountryCurrencyService.getPrimaryCurrency(country);
      if (primaryCurrency != null && !addedCurrencies.contains(primaryCurrency)) {
        suggestions.add(primaryCurrency);
        addedCurrencies.add(primaryCurrency);
      }
      
      // 3. User's default currency (if not already added)
      if (userDefaultCurrency.isNotEmpty && !addedCurrencies.contains(userDefaultCurrency)) {
        suggestions.add(userDefaultCurrency);
        addedCurrencies.add(userDefaultCurrency);
      }
      
      // 4. Multi-currency country alternatives
      if (CountryCurrencyService.isMultiCurrencyCountry(country)) {
        final multiCurrencies = CountryCurrencyService.getAllCountryCurrencies(country);
        for (final currency in multiCurrencies) {
          if (suggestions.length >= maxSuggestions) break;
          if (!addedCurrencies.contains(currency)) {
            suggestions.add(currency);
            addedCurrencies.add(currency);
          }
        }
      }
      
      // 5. Geographic and regional currencies
      if (includeRegionalCurrencies && suggestions.length < maxSuggestions) {
        final regionalCurrencies = GeographicCurrencyDetector.getNearbyCountryCurrencies(
          country,
          maxSuggestions: maxSuggestions - suggestions.length,
        );
        
        for (final currency in regionalCurrencies) {
          if (suggestions.length >= maxSuggestions) break;
          if (!addedCurrencies.contains(currency)) {
            suggestions.add(currency);
            addedCurrencies.add(currency);
          }
        }
      }
      
      // 6. International fallback currencies
      if (suggestions.length < maxSuggestions) {
        const internationalCurrencies = ['USD', 'EUR', 'GBP', 'JPY'];
        for (final currency in internationalCurrencies) {
          if (suggestions.length >= maxSuggestions) break;
          if (!addedCurrencies.contains(currency)) {
            suggestions.add(currency);
            addedCurrencies.add(currency);
          }
        }
      }
      
      return suggestions;
      
    } catch (e) {
      developer.log('Error getting smart currency suggestions: $e');
      
      // Fallback to basic suggestions
      return CountryCurrencyService.getFilteredCurrencies(
        country,
        userDefaultCurrency,
        maxSuggestions: maxSuggestions,
      );
    }
  }
  
  /// Get detailed currency suggestions with explanations
  /// 
  /// This method provides the same intelligent suggestions but with detailed
  /// reasoning for each suggestion. Useful for debugging and user interfaces
  /// that want to explain why currencies are suggested.
  /// 
  /// [country] - The selected country
  /// [userDefaultCurrency] - User's primary/default currency
  /// [includeUsageHistory] - Whether to include historical usage patterns
  /// [includeRegionalCurrencies] - Whether to include geographic suggestions
  /// [maxSuggestions] - Maximum number of suggestions
  /// 
  /// Returns a list of DetailedCurrencySuggestion objects with reasoning
  static Future<List<DetailedCurrencySuggestion>> getDetailedSmartSuggestions({
    required String country,
    required String userDefaultCurrency,
    bool includeUsageHistory = true,
    bool includeRegionalCurrencies = true,
    int maxSuggestions = 8,
  }) async {
    try {
      final suggestions = <DetailedCurrencySuggestion>[];
      final addedCurrencies = <String>{};
      
      // 1. User's historical preferences
      if (includeUsageHistory) {
        final historicalPreferences = await CurrencyUsageTracker.getPreferredCurrencies(
          country,
          maxResults: 3,
        );
        
        final usageFrequency = await CurrencyUsageTracker.getCurrencyFrequencyForCountry(country);
        
        for (int i = 0; i < historicalPreferences.length; i++) {
          if (suggestions.length >= maxSuggestions) break;
          
          final currency = historicalPreferences[i];
          if (!addedCurrencies.contains(currency)) {
            final usageCount = usageFrequency[currency] ?? 0;
            suggestions.add(DetailedCurrencySuggestion(
              currencyCode: currency,
              reason: SuggestionReason.historicalUsage,
              explanation: 'You used this $usageCount time(s) in $country recently',
              confidence: _calculateHistoricalConfidence(i, usageCount),
              metadata: {'usage_count': usageCount, 'rank': i + 1},
            ));
            addedCurrencies.add(currency);
          }
        }
      }
      
      // 2. Primary country currency
      final primaryCurrency = CountryCurrencyService.getPrimaryCurrency(country);
      if (primaryCurrency != null && !addedCurrencies.contains(primaryCurrency)) {
        suggestions.add(DetailedCurrencySuggestion(
          currencyCode: primaryCurrency,
          reason: SuggestionReason.primaryCurrency,
          explanation: 'Official currency of $country',
          confidence: 0.95,
          metadata: {'country': country},
        ));
        addedCurrencies.add(primaryCurrency);
      }
      
      // 3. User default currency
      if (userDefaultCurrency.isNotEmpty && !addedCurrencies.contains(userDefaultCurrency)) {
        suggestions.add(DetailedCurrencySuggestion(
          currencyCode: userDefaultCurrency,
          reason: SuggestionReason.userDefault,
          explanation: 'Your default currency setting',
          confidence: 0.85,
          metadata: {'is_default': true},
        ));
        addedCurrencies.add(userDefaultCurrency);
      }
      
      // 4. Multi-currency alternatives
      if (CountryCurrencyService.isMultiCurrencyCountry(country)) {
        final multiCurrencies = CountryCurrencyService.getAllCountryCurrencies(country);
        for (final currency in multiCurrencies) {
          if (suggestions.length >= maxSuggestions) break;
          if (!addedCurrencies.contains(currency)) {
            suggestions.add(DetailedCurrencySuggestion(
              currencyCode: currency,
              reason: SuggestionReason.multiCurrency,
              explanation: 'Commonly accepted in $country',
              confidence: 0.75,
              metadata: {'multi_currency_country': true},
            ));
            addedCurrencies.add(currency);
          }
        }
      }
      
      // 5. Regional currencies
      if (includeRegionalCurrencies && suggestions.length < maxSuggestions) {
        final region = GeographicCurrencyDetector.getCountryRegion(country);
        final regionalCurrencies = GeographicCurrencyDetector.getNearbyCountryCurrencies(
          country,
          maxSuggestions: maxSuggestions - suggestions.length,
        );
        
        for (final currency in regionalCurrencies) {
          if (suggestions.length >= maxSuggestions) break;
          if (!addedCurrencies.contains(currency)) {
            final regionName = region?.name ?? 'region';
            suggestions.add(DetailedCurrencySuggestion(
              currencyCode: currency,
              reason: SuggestionReason.regional,
              explanation: 'Common in $regionName region',
              confidence: 0.60,
              metadata: {'region': regionName},
            ));
            addedCurrencies.add(currency);
          }
        }
      }
      
      // 6. International fallbacks
      if (suggestions.length < maxSuggestions) {
        const internationalCurrencies = [
          {'code': 'USD', 'explanation': 'Widely accepted internationally'},
          {'code': 'EUR', 'explanation': 'Major international currency'},
          {'code': 'GBP', 'explanation': 'International reserve currency'},
          {'code': 'JPY', 'explanation': 'Major Asian currency'},
        ];
        
        for (final currencyInfo in internationalCurrencies) {
          if (suggestions.length >= maxSuggestions) break;
          
          final currency = currencyInfo['code']!;
          if (!addedCurrencies.contains(currency)) {
            suggestions.add(DetailedCurrencySuggestion(
              currencyCode: currency,
              reason: SuggestionReason.international,
              explanation: currencyInfo['explanation']!,
              confidence: 0.50,
              metadata: {'is_international': true},
            ));
            addedCurrencies.add(currency);
          }
        }
      }
      
      return suggestions;
      
    } catch (e) {
      developer.log('Error getting detailed smart suggestions: $e');
      
      // Fallback to basic suggestions with minimal reasoning
      final basicSuggestions = await getSmartSuggestions(
        country: country,
        userDefaultCurrency: userDefaultCurrency,
        includeUsageHistory: includeUsageHistory,
        includeRegionalCurrencies: includeRegionalCurrencies,
        maxSuggestions: maxSuggestions,
      );
      
      return basicSuggestions.map((currency) => DetailedCurrencySuggestion(
        currencyCode: currency,
        reason: SuggestionReason.fallback,
        explanation: 'Basic suggestion',
        confidence: 0.30,
        metadata: {},
      )).toList();
    }
  }
  
  /// Get currency suggestions optimized for travel scenarios
  /// 
  /// This method provides currency suggestions specifically optimized for
  /// travel between countries, considering travel corridors and common
  /// multi-currency usage patterns.
  /// 
  /// [fromCountry] - Origin country
  /// [toCountry] - Destination country
  /// [userDefaultCurrency] - User's primary currency
  /// [maxSuggestions] - Maximum suggestions to return
  /// 
  /// Returns currencies useful for travel between the specified countries
  static Future<List<String>> getTravelOptimizedSuggestions({
    required String fromCountry,
    required String toCountry,
    required String userDefaultCurrency,
    int maxSuggestions = 6,
  }) async {
    try {
      final suggestions = <String>{};
      
      // 1. Travel corridor currencies
      final corridorCurrencies = GeographicCurrencyDetector.getTravelCorridorCurrencies(
        fromCountry,
        toCountry,
      );
      suggestions.addAll(corridorCurrencies);
      
      // 2. Destination country currencies
      final destinationCurrencies = CountryCurrencyService.getAllCountryCurrencies(toCountry);
      suggestions.addAll(destinationCurrencies);
      
      // 3. User's historical usage in both countries
      final fromUsage = await CurrencyUsageTracker.getPreferredCurrencies(fromCountry, maxResults: 2);
      final toUsage = await CurrencyUsageTracker.getPreferredCurrencies(toCountry, maxResults: 2);
      suggestions.addAll(fromUsage);
      suggestions.addAll(toUsage);
      
      // 4. User default currency
      suggestions.add(userDefaultCurrency);
      
      // 5. International currencies for backup
      suggestions.addAll(['USD', 'EUR']);
      
      return suggestions.take(maxSuggestions).toList();
      
    } catch (e) {
      developer.log('Error getting travel-optimized suggestions: $e');
      
      // Fallback
      return getSmartSuggestions(
        country: toCountry,
        userDefaultCurrency: userDefaultCurrency,
        maxSuggestions: maxSuggestions,
      );
    }
  }
  
  /// Record currency usage and update intelligence models
  /// 
  /// This method should be called whenever a user selects a currency for a country.
  /// It updates the historical usage patterns that improve future suggestions.
  /// 
  /// [country] - The country where currency was used
  /// [currency] - The selected currency
  /// [context] - Optional context (e.g., 'fuel_entry', 'expense')
  static Future<void> recordCurrencySelection(
    String country,
    String currency, {
    String? context,
  }) async {
    try {
      await CurrencyUsageTracker.recordCurrencyUsage(
        country,
        currency,
        context: context,
      );
      
      developer.log('Recorded currency selection: $currency in $country');
      
    } catch (e) {
      developer.log('Error recording currency selection: $e');
      // Don't throw - this is not critical functionality
    }
  }
  
  /// Get analytics and insights about currency usage patterns
  /// 
  /// Returns comprehensive analytics for debugging and optimization purposes
  static Future<Map<String, dynamic>> getUsageAnalytics() async {
    try {
      final analytics = <String, dynamic>{};
      
      // Basic usage statistics
      final usageStats = await CurrencyUsageTracker.getUsageStatistics();
      analytics['usage_statistics'] = usageStats;
      
      // Most used currencies globally
      final globalPreferred = await CurrencyUsageTracker.getGloballyPreferredCurrencies();
      analytics['globally_preferred_currencies'] = globalPreferred;
      
      // Currency metadata coverage
      final supportedCurrencies = CurrencyMetadata.getSupportedCurrencies();
      analytics['supported_currencies_count'] = supportedCurrencies.length;
      analytics['international_currencies'] = CurrencyMetadata.getInternationalCurrencies();
      
      // Country coverage
      final supportedCountries = CountryCurrencyService.getSupportedCountries();
      analytics['supported_countries_count'] = supportedCountries.length;
      
      // Multi-currency country analysis
      final multiCurrencyCountries = supportedCountries
          .where((country) => CountryCurrencyService.isMultiCurrencyCountry(country))
          .toList();
      analytics['multi_currency_countries_count'] = multiCurrencyCountries.length;
      analytics['multi_currency_countries'] = multiCurrencyCountries;
      
      return analytics;
      
    } catch (e) {
      developer.log('Error getting usage analytics: $e');
      return {'error': 'Failed to retrieve analytics'};
    }
  }
  
  // Private helper methods
  
  static double _calculateHistoricalConfidence(int rank, int usageCount) {
    // Higher confidence for more recent and frequent usage
    final recencyScore = 1.0 - (rank * 0.15); // Decrease by 15% for each rank
    final frequencyScore = (usageCount / 10.0).clamp(0.0, 1.0); // Max out at 10 uses
    
    return ((recencyScore + frequencyScore) / 2.0).clamp(0.5, 1.0);
  }
}

/// Enum for different types of suggestion reasons
enum SuggestionReason {
  historicalUsage,
  primaryCurrency,
  userDefault,
  multiCurrency,
  regional,
  international,
  travel,
  fallback,
}

/// Detailed currency suggestion with reasoning and metadata
class DetailedCurrencySuggestion {
  final String currencyCode;
  final SuggestionReason reason;
  final String explanation;
  final double confidence; // 0.0 to 1.0
  final Map<String, dynamic> metadata;
  
  const DetailedCurrencySuggestion({
    required this.currencyCode,
    required this.reason,
    required this.explanation,
    required this.confidence,
    required this.metadata,
  });
  
  /// Get currency information from metadata service
  CurrencyInfo? get currencyInfo {
    return CurrencyMetadata.getCurrencyInfo(currencyCode);
  }
  
  /// Get human-readable reason description
  String get reasonDescription {
    switch (reason) {
      case SuggestionReason.historicalUsage:
        return 'Based on your usage history';
      case SuggestionReason.primaryCurrency:
        return 'Official country currency';
      case SuggestionReason.userDefault:
        return 'Your default currency';
      case SuggestionReason.multiCurrency:
        return 'Commonly accepted locally';
      case SuggestionReason.regional:
        return 'Regional currency';
      case SuggestionReason.international:
        return 'International currency';
      case SuggestionReason.travel:
        return 'Good for travel';
      case SuggestionReason.fallback:
        return 'Fallback suggestion';
    }
  }
  
  /// Get confidence level description
  String get confidenceLevel {
    if (confidence >= 0.9) return 'Very High';
    if (confidence >= 0.8) return 'High';
    if (confidence >= 0.7) return 'Good';
    if (confidence >= 0.6) return 'Medium';
    if (confidence >= 0.5) return 'Low';
    return 'Very Low';
  }
  
  @override
  String toString() {
    return 'DetailedCurrencySuggestion('
        'currency: $currencyCode, '
        'reason: ${reasonDescription}, '
        'confidence: ${confidenceLevel}, '
        'explanation: $explanation)';
  }
}