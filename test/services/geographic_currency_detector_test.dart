import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/services/geographic_currency_detector.dart';
import 'package:petrol_tracker/models/currency_info.dart';

void main() {
  group('GeographicCurrencyDetector Tests', () {
    
    group('Regional Currency Detection', () {
      test('should detect European regional currencies', () {
        final currencies = GeographicCurrencyDetector.getNearbyCountryCurrencies('Germany');
        
        expect(currencies, isNotEmpty);
        expect(currencies, contains('EUR'));
        expect(currencies, contains('CHF'));
        expect(currencies, contains('GBP'));
        expect(currencies.length, lessThanOrEqualTo(5)); // Default maxSuggestions
        
        // Should be European region currencies
        final europeanCurrencies = CurrencyRegionConfig.regionCurrencies[CurrencyRegion.europe] ?? [];
        for (final currency in currencies) {
          expect(europeanCurrencies, contains(currency));
        }
      });
      
      test('should detect North American regional currencies', () {
        final currencies = GeographicCurrencyDetector.getNearbyCountryCurrencies('United States');
        
        expect(currencies, isNotEmpty);
        expect(currencies, contains('USD'));
        expect(currencies, contains('CAD'));
        expect(currencies, contains('MXN'));
        
        final northAmericanCurrencies = CurrencyRegionConfig.regionCurrencies[CurrencyRegion.northAmerica] ?? [];
        for (final currency in currencies) {
          expect(northAmericanCurrencies, contains(currency));
        }
      });
      
      test('should detect Asian Pacific regional currencies', () {
        final currencies = GeographicCurrencyDetector.getNearbyCountryCurrencies('Japan');
        
        expect(currencies, isNotEmpty);
        expect(currencies, contains('JPY'));
        expect(currencies, contains('KRW'));
        expect(currencies, contains('CNY'));
        
        final asiaPacificCurrencies = CurrencyRegionConfig.regionCurrencies[CurrencyRegion.asiaPacific] ?? [];
        for (final currency in currencies) {
          expect(asiaPacificCurrencies, contains(currency));
        }
      });
      
      test('should respect maxSuggestions parameter', () {
        final currencies = GeographicCurrencyDetector.getNearbyCountryCurrencies(
          'Germany',
          maxSuggestions: 3,
        );
        
        expect(currencies.length, lessThanOrEqualTo(3));
        expect(currencies, isNotEmpty);
      });
      
      test('should return fallback for unknown countries', () {
        final currencies = GeographicCurrencyDetector.getNearbyCountryCurrencies(
          'Unknown Country',
        );
        
        expect(currencies, isNotEmpty);
        expect(currencies, contains('USD'));
        expect(currencies, contains('EUR'));
        expect(currencies, contains('GBP'));
      });
    });

    group('Country Region Identification', () {
      test('should correctly identify countries in European region', () {
        expect(GeographicCurrencyDetector.isCountryInRegion('Germany', CurrencyRegion.europe), isTrue);
        expect(GeographicCurrencyDetector.isCountryInRegion('France', CurrencyRegion.europe), isTrue);
        expect(GeographicCurrencyDetector.isCountryInRegion('Switzerland', CurrencyRegion.europe), isTrue);
        expect(GeographicCurrencyDetector.isCountryInRegion('United Kingdom', CurrencyRegion.europe), isTrue);
        expect(GeographicCurrencyDetector.isCountryInRegion('Norway', CurrencyRegion.europe), isTrue);
        
        // Should not be in other regions
        expect(GeographicCurrencyDetector.isCountryInRegion('Germany', CurrencyRegion.northAmerica), isFalse);
        expect(GeographicCurrencyDetector.isCountryInRegion('Germany', CurrencyRegion.asiaPacific), isFalse);
      });
      
      test('should correctly identify countries in North American region', () {
        expect(GeographicCurrencyDetector.isCountryInRegion('United States', CurrencyRegion.northAmerica), isTrue);
        expect(GeographicCurrencyDetector.isCountryInRegion('Canada', CurrencyRegion.northAmerica), isTrue);
        expect(GeographicCurrencyDetector.isCountryInRegion('Mexico', CurrencyRegion.northAmerica), isTrue);
      });
      
      test('should correctly identify countries in Asia Pacific region', () {
        expect(GeographicCurrencyDetector.isCountryInRegion('Japan', CurrencyRegion.asiaPacific), isTrue);
        expect(GeographicCurrencyDetector.isCountryInRegion('China', CurrencyRegion.asiaPacific), isTrue);
        expect(GeographicCurrencyDetector.isCountryInRegion('India', CurrencyRegion.asiaPacific), isTrue);
        expect(GeographicCurrencyDetector.isCountryInRegion('Singapore', CurrencyRegion.asiaPacific), isTrue);
      });
      
      test('should return correct region for countries', () {
        expect(GeographicCurrencyDetector.getCountryRegion('Germany'), equals(CurrencyRegion.europe));
        expect(GeographicCurrencyDetector.getCountryRegion('United States'), equals(CurrencyRegion.northAmerica));
        expect(GeographicCurrencyDetector.getCountryRegion('Japan'), equals(CurrencyRegion.asiaPacific));
        expect(GeographicCurrencyDetector.getCountryRegion('Australia'), equals(CurrencyRegion.oceania));
        expect(GeographicCurrencyDetector.getCountryRegion('Brazil'), equals(CurrencyRegion.southAmerica));
        
        expect(GeographicCurrencyDetector.getCountryRegion('Unknown Country'), isNull);
      });
    });

    group('Regional Country Lists', () {
      test('should return countries in European region', () {
        final europeanCountries = GeographicCurrencyDetector.getCountriesInRegion(CurrencyRegion.europe);
        
        expect(europeanCountries, isNotEmpty);
        expect(europeanCountries, contains('Germany'));
        expect(europeanCountries, contains('France'));
        expect(europeanCountries, contains('United Kingdom'));
        expect(europeanCountries, contains('Switzerland'));
        expect(europeanCountries, contains('Norway'));
        expect(europeanCountries, contains('Sweden'));
        expect(europeanCountries, contains('Denmark'));
        
        // Should be sorted alphabetically
        final sortedCountries = List<String>.from(europeanCountries)..sort();
        expect(europeanCountries, equals(sortedCountries));
      });
      
      test('should return countries in other regions', () {
        final northAmericanCountries = GeographicCurrencyDetector.getCountriesInRegion(CurrencyRegion.northAmerica);
        expect(northAmericanCountries, contains('United States'));
        expect(northAmericanCountries, contains('Canada'));
        expect(northAmericanCountries, contains('Mexico'));
        
        final asiaPacificCountries = GeographicCurrencyDetector.getCountriesInRegion(CurrencyRegion.asiaPacific);
        expect(asiaPacificCountries, contains('Japan'));
        expect(asiaPacificCountries, contains('China'));
        expect(asiaPacificCountries, contains('India'));
        
        final oceaniaCountries = GeographicCurrencyDetector.getCountriesInRegion(CurrencyRegion.oceania);
        expect(oceaniaCountries, contains('Australia'));
        expect(oceaniaCountries, contains('New Zealand'));
      });
    });

    group('Border Currency Suggestions', () {
      test('should provide border currencies for European countries', () {
        final switzerlandBorder = GeographicCurrencyDetector.getBorderCurrencySuggestions('Switzerland');
        expect(switzerlandBorder, contains('CHF'));
        expect(switzerlandBorder, contains('EUR'));
        
        final ukBorder = GeographicCurrencyDetector.getBorderCurrencySuggestions('United Kingdom');
        expect(ukBorder, contains('GBP'));
        expect(ukBorder, contains('EUR'));
      });
      
      test('should provide border currencies for North American countries', () {
        final canadaBorder = GeographicCurrencyDetector.getBorderCurrencySuggestions('Canada');
        expect(canadaBorder, contains('CAD'));
        expect(canadaBorder, contains('USD'));
        
        final mexicoBorder = GeographicCurrencyDetector.getBorderCurrencySuggestions('Mexico');
        expect(mexicoBorder, contains('MXN'));
        expect(mexicoBorder, contains('USD'));
      });
      
      test('should provide border currencies for Asian countries', () {
        final hongKongBorder = GeographicCurrencyDetector.getBorderCurrencySuggestions('Hong Kong');
        expect(hongKongBorder, isNotEmpty);
        // Check that it returns either specific border currencies or regional fallback
        expect(hongKongBorder.length, greaterThan(0));
        
        final singaporeBorder = GeographicCurrencyDetector.getBorderCurrencySuggestions('Singapore');
        expect(singaporeBorder, isNotEmpty);
        expect(singaporeBorder.length, greaterThan(0));
      });
      
      test('should fallback to regional currencies for countries without specific border data', () {
        final borderCurrencies = GeographicCurrencyDetector.getBorderCurrencySuggestions('Unknown Country');
        
        expect(borderCurrencies, isNotEmpty);
        expect(borderCurrencies.length, lessThanOrEqualTo(3)); // Should be limited
      });
    });

    group('Travel Corridor Currencies', () {
      test('should provide travel corridor currencies for European routes', () {
        final germanyToSwitzerland = GeographicCurrencyDetector.getTravelCorridorCurrencies('Germany', 'Switzerland');
        expect(germanyToSwitzerland, contains('EUR'));
        expect(germanyToSwitzerland, contains('CHF'));
        
        final ukToFrance = GeographicCurrencyDetector.getTravelCorridorCurrencies('United Kingdom', 'France');
        expect(ukToFrance, contains('GBP'));
        expect(ukToFrance, contains('EUR'));
      });
      
      test('should provide travel corridor currencies for North American routes', () {
        final usToCanada = GeographicCurrencyDetector.getTravelCorridorCurrencies('United States', 'Canada');
        expect(usToCanada, contains('USD'));
        expect(usToCanada, contains('CAD'));
        
        final canadaToUs = GeographicCurrencyDetector.getTravelCorridorCurrencies('Canada', 'United States');
        expect(canadaToUs, contains('CAD'));
        expect(canadaToUs, contains('USD'));
      });
      
      test('should provide travel corridor currencies for Asian routes', () {
        final japanToKorea = GeographicCurrencyDetector.getTravelCorridorCurrencies('Japan', 'South Korea');
        expect(japanToKorea, contains('JPY'));
        expect(japanToKorea, contains('KRW'));
        expect(japanToKorea, contains('USD')); // International fallback
        
        final singaporeToMalaysia = GeographicCurrencyDetector.getTravelCorridorCurrencies('Singapore', 'Malaysia');
        expect(singaporeToMalaysia, contains('SGD'));
        expect(singaporeToMalaysia, contains('MYR'));
      });
      
      test('should combine regional currencies for unknown corridors', () {
        final unknownCorridor = GeographicCurrencyDetector.getTravelCorridorCurrencies('Germany', 'Unknown Country');
        
        expect(unknownCorridor, isNotEmpty);
        expect(unknownCorridor, contains('USD')); // Should include USD as international fallback
      });
    });

    group('Economic Zone Currencies', () {
      test('should provide Eurozone currencies', () {
        final germanZone = GeographicCurrencyDetector.getEconomicZoneCurrencies('Germany');
        expect(germanZone, contains('EUR'));
        
        final franceZone = GeographicCurrencyDetector.getEconomicZoneCurrencies('France');
        expect(franceZone, contains('EUR'));
        
        final italyZone = GeographicCurrencyDetector.getEconomicZoneCurrencies('Italy');
        expect(italyZone, contains('EUR'));
      });
      
      test('should provide USMCA currencies', () {
        final usZone = GeographicCurrencyDetector.getEconomicZoneCurrencies('United States');
        expect(usZone, contains('USD'));
        expect(usZone, contains('CAD'));
        expect(usZone, contains('MXN'));
        
        final canadaZone = GeographicCurrencyDetector.getEconomicZoneCurrencies('Canada');
        expect(canadaZone, contains('CAD'));
        expect(canadaZone, contains('USD'));
        expect(canadaZone, contains('MXN'));
      });
      
      test('should provide ASEAN currencies', () {
        final singaporeZone = GeographicCurrencyDetector.getEconomicZoneCurrencies('Singapore');
        expect(singaporeZone, contains('SGD'));
        expect(singaporeZone, contains('MYR'));
        expect(singaporeZone, contains('THB'));
        expect(singaporeZone, contains('IDR'));
        expect(singaporeZone, contains('PHP'));
        
        final thailandZone = GeographicCurrencyDetector.getEconomicZoneCurrencies('Thailand');
        expect(thailandZone, contains('THB'));
        expect(thailandZone, contains('SGD'));
        expect(thailandZone, contains('MYR'));
      });
      
      test('should provide GCC currencies', () {
        final uaeZone = GeographicCurrencyDetector.getEconomicZoneCurrencies('United Arab Emirates');
        expect(uaeZone, contains('AED'));
        expect(uaeZone, contains('SAR'));
        expect(uaeZone, contains('QAR'));
        expect(uaeZone, contains('USD'));
        
        final saudiZone = GeographicCurrencyDetector.getEconomicZoneCurrencies('Saudi Arabia');
        expect(saudiZone, contains('SAR'));
        expect(saudiZone, contains('AED'));
        expect(saudiZone, contains('USD'));
      });
      
      test('should fallback to regional currencies for countries without economic zone data', () {
        final unknownZone = GeographicCurrencyDetector.getEconomicZoneCurrencies('Unknown Country');
        
        expect(unknownZone, isNotEmpty);
        // Should fallback to regional detection
      });
    });

    group('Comprehensive Geographic Suggestions', () {
      test('should combine multiple geographic factors', () {
        final comprehensive = GeographicCurrencyDetector.getComprehensiveGeographicSuggestions('Germany');
        
        expect(comprehensive, isNotEmpty);
        expect(comprehensive, contains('EUR')); // Regional
        expect(comprehensive, contains('USD')); // International fallback
        expect(comprehensive, contains('GBP')); // International fallback
        expect(comprehensive, contains('JPY')); // International fallback
        
        // Should respect default maxSuggestions (10)
        expect(comprehensive.length, lessThanOrEqualTo(10));
      });
      
      test('should respect maxSuggestions for comprehensive suggestions', () {
        final comprehensive = GeographicCurrencyDetector.getComprehensiveGeographicSuggestions(
          'Switzerland',
          maxSuggestions: 5,
        );
        
        expect(comprehensive.length, lessThanOrEqualTo(5));
        expect(comprehensive, isNotEmpty);
      });
      
      test('should provide diverse suggestions combining all factors', () {
        final comprehensive = GeographicCurrencyDetector.getComprehensiveGeographicSuggestions('Singapore');
        
        expect(comprehensive, isNotEmpty);
        
        // Should include various types of suggestions:
        expect(comprehensive, contains('SGD')); // Regional/border/zone
        expect(comprehensive, contains('USD')); // International/border
        
        // Should not have duplicates
        final uniqueCurrencies = comprehensive.toSet();
        expect(comprehensive.length, equals(uniqueCurrencies.length));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle empty and null inputs gracefully', () {
        final emptyCurrencies = GeographicCurrencyDetector.getNearbyCountryCurrencies('');
        expect(emptyCurrencies, isNotEmpty); // Should return fallback
        
        final nullRegion = GeographicCurrencyDetector.getCountryRegion('');
        expect(nullRegion, isNull);
      });
      
      test('should handle unknown countries consistently', () {
        final unknownCurrencies = GeographicCurrencyDetector.getNearbyCountryCurrencies('Unknown Country');
        expect(unknownCurrencies, contains('USD'));
        expect(unknownCurrencies, contains('EUR'));
        expect(unknownCurrencies, contains('GBP'));
      });
      
      test('should not return empty lists for valid regions', () {
        for (final region in CurrencyRegion.values) {
          final countries = GeographicCurrencyDetector.getCountriesInRegion(region);
          if (CurrencyRegionConfig.regionCurrencies.containsKey(region)) {
            expect(countries, isNotEmpty, reason: 'Region $region should have countries');
          }
        }
      });
    });

    group('Performance', () {
      test('should handle multiple rapid calls efficiently', () {
        final countries = ['Germany', 'United States', 'Japan', 'Australia', 'Brazil'];
        final stopwatch = Stopwatch()..start();
        
        for (int i = 0; i < 100; i++) {
          final country = countries[i % countries.length];
          GeographicCurrencyDetector.getNearbyCountryCurrencies(country);
          GeographicCurrencyDetector.getBorderCurrencySuggestions(country);
          GeographicCurrencyDetector.getCountryRegion(country);
        }
        
        stopwatch.stop();
        
        // Should complete 300 operations in reasonable time (under 100ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });
  });
}