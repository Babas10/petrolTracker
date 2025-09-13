/// Flutter Daily Currency Cache Service Example
/// 
/// This service implements the optimal daily caching pattern for the currency
/// microservice, fetching all rates once per day and caching them locally.
/// 
/// Usage:
/// 1. Call getAllRates() on first app usage each day
/// 2. Use convertCurrency() for all subsequent conversions
/// 3. Rates are cached locally and in memory for 24 hours

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const String _baseUrl = 'http://your-currency-microservice:8000/api/v1';
  static const String _apiKey = 'your-api-key-here';
  static const String _cacheKey = 'cached_currency_rates';
  static const String _cacheDateKey = 'cache_date';
  
  // In-memory cache for current session
  Map<String, double>? _cachedRates;
  DateTime? _lastFetchDate;
  
  /// Get all exchange rates, using daily cache pattern
  Future<Map<String, double>> getAllRates({String baseCurrency = 'USD'}) async {
    final today = DateTime.now();
    
    // Check if we need to fetch new rates (first time today)
    if (_shouldFetchNewRates(today)) {
      await _fetchAndCacheRates(baseCurrency);
    }
    
    return _cachedRates ?? {};
  }
  
  /// Convert amount from one currency to another using cached rates
  Future<double> convertCurrency({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
  }) async {
    // Ensure we have rates loaded
    final rates = await getAllRates();
    
    // Handle same currency
    if (fromCurrency == toCurrency) {
      return amount;
    }
    
    // Get rates for conversion
    final fromRate = rates[fromCurrency] ?? 1.0; // Assume USD base if not found
    final toRate = rates[toCurrency];
    
    if (toRate == null) {
      throw Exception('Currency $toCurrency not supported');
    }
    
    // Convert: amount * (toRate / fromRate)
    return amount * (toRate / fromRate);
  }
  
  /// Check if we need to fetch new rates
  bool _shouldFetchNewRates(DateTime today) {
    // First time loading
    if (_lastFetchDate == null || _cachedRates == null) {
      return true;
    }
    
    // Check if it's a new day
    return !_isSameDay(_lastFetchDate!, today);
  }
  
  /// Fetch rates from microservice and cache them
  Future<void> _fetchAndCacheRates(String baseCurrency) async {
    try {
      print('🔄 Fetching daily currency rates...');
      
      final response = await http.get(
        Uri.parse('$_baseUrl/rates/latest'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final rates = <String, double>{};
        
        // Parse rates from API response
        for (final entry in data.entries) {
          final rateData = entry.value as Map<String, dynamic>;
          rates[entry.key] = double.parse(rateData['rate'].toString());
        }
        
        // Cache in memory
        _cachedRates = rates;
        _lastFetchDate = DateTime.now();
        
        // Cache in local storage for persistence
        await _storeLocalCache(rates, _lastFetchDate!);
        
        print('✅ Cached ${rates.length} currency rates');
        
      } else {
        print('❌ Failed to fetch rates: ${response.statusCode}');
        // Try to load from local cache as fallback
        await _loadLocalCache();
      }
      
    } catch (e) {
      print('❌ Error fetching currency rates: $e');
      // Try to load from local cache as fallback
      await _loadLocalCache();
    }
  }
  
  /// Store rates in local storage for persistence across app restarts
  Future<void> _storeLocalCache(Map<String, double> rates, DateTime fetchDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratesJson = json.encode(rates);
      
      await prefs.setString(_cacheKey, ratesJson);
      await prefs.setString(_cacheDateKey, fetchDate.toIso8601String());
      
    } catch (e) {
      print('Warning: Could not store local cache: $e');
    }
  }
  
  /// Load rates from local storage
  Future<void> _loadLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratesJson = prefs.getString(_cacheKey);
      final cacheDateStr = prefs.getString(_cacheDateKey);
      
      if (ratesJson != null && cacheDateStr != null) {
        final rates = Map<String, double>.from(json.decode(ratesJson));
        final cacheDate = DateTime.parse(cacheDateStr);
        
        // Check if local cache is still valid (same day)
        if (_isSameDay(cacheDate, DateTime.now())) {
          _cachedRates = rates;
          _lastFetchDate = cacheDate;
          print('📱 Loaded ${rates.length} rates from local cache');
        } else {
          print('🗑️ Local cache expired, will fetch new rates');
        }
      }
      
    } catch (e) {
      print('Warning: Could not load local cache: $e');
    }
  }
  
  /// Check if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }
  
  /// Get cache information for debugging
  Map<String, dynamic> getCacheInfo() {
    return {
      'cached_rates_count': _cachedRates?.length ?? 0,
      'last_fetch_date': _lastFetchDate?.toIso8601String(),
      'is_cache_valid': _lastFetchDate != null && 
                       _isSameDay(_lastFetchDate!, DateTime.now()),
      'available_currencies': _cachedRates?.keys.toList() ?? [],
    };
  }
  
  /// Force refresh rates (useful for testing or manual refresh)
  Future<void> forceRefresh({String baseCurrency = 'USD'}) async {
    _cachedRates = null;
    _lastFetchDate = null;
    await _fetchAndCacheRates(baseCurrency);
  }
}

// Example usage in your Flutter app:
/*
class FuelEntryScreen extends StatefulWidget {
  @override
  _FuelEntryScreenState createState() => _FuelEntryScreenState();
}

class _FuelEntryScreenState extends State<FuelEntryScreen> {
  final CurrencyService _currencyService = CurrencyService();
  
  @override
  void initState() {
    super.initState();
    // Pre-load currencies on screen init
    _initializeCurrencies();
  }
  
  Future<void> _initializeCurrencies() async {
    try {
      await _currencyService.getAllRates();
      setState(() {}); // Refresh UI once rates are loaded
    } catch (e) {
      print('Error initializing currencies: $e');
    }
  }
  
  Future<void> _convertFuelCost() async {
    try {
      final convertedCost = await _currencyService.convertCurrency(
        amount: 50.0, // $50 USD
        fromCurrency: 'USD',
        toCurrency: 'EUR',
      );
      
      print('$50 USD = €${convertedCost.toStringAsFixed(2)}');
      
    } catch (e) {
      print('Conversion error: $e');
    }
  }
}
*/