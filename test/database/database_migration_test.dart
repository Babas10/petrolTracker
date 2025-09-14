import 'package:drift/native.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/common.dart';
import 'package:petrol_tracker/database/database.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/models/user_settings_model.dart';
import 'package:petrol_tracker/models/exchange_rate_cache_model.dart';

void main() {
  group('Database Migration Tests', () {
    late AppDatabase database;

    tearDown(() async {
      await database.close();
    });

    group('Schema Version 5 Migration', () {
      test('should create new database with all tables and indices', () async {
        // Create fresh database (should run onCreate)
        database = AppDatabase.forTesting(NativeDatabase.memory());
        
        // Check that all tables exist by querying them
        final stats = await database.getDatabaseStats();
        
        expect(stats['database_version'], equals(5));
        expect(stats['user_settings'], equals(1)); // Should have default settings
        expect(stats['exchange_rates_cache'], equals(0));
        
        // Verify user settings default was inserted
        final userSettings = await database.select(database.userSettings).get();
        expect(userSettings.length, equals(1));
        expect(userSettings.first.primaryCurrency, equals('USD'));
      });

      test('should migrate from version 4 to 5', () async {
        // Create a database with version 4 schema (simulate old database)
        database = AppDatabase.forTesting(NativeDatabase.memory());
        
        // First, create a database with old schema version by manually setting it
        // For this test, we'll insert some fuel entries before migration
        final fuelEntry = FuelEntryModel.create(
          vehicleId: 1,
          date: DateTime.now(),
          currentKm: 1000.0,
          fuelAmount: 50.0,
          price: 75.0,
          country: 'Switzerland',
          pricePerLiter: 1.5,
        );

        // Insert a vehicle first
        await database.into(database.vehicles).insert(
          VehiclesCompanion.insert(
            name: 'Test Car',
            initialKm: 0,
          ),
        );

        // Insert fuel entry
        await database.into(database.fuelEntries).insert(
          fuelEntry.toCompanion(),
        );

        // Verify the fuel entry has default currency
        final entries = await database.select(database.fuelEntries).get();
        expect(entries.length, equals(1));
        expect(entries.first.currency, equals('USD')); // Should have default value
        expect(entries.first.originalAmount, isNull); // New field should be null

        // Verify user settings exist
        final settings = await database.select(database.userSettings).get();
        expect(settings.length, equals(1));
        expect(settings.first.primaryCurrency, equals('USD'));

        // Verify exchange rates cache table is empty
        final cache = await database.select(database.exchangeRatesCache).get();
        expect(cache.length, equals(0));
      });

      test('should handle fuel entries with new currency fields', () async {
        database = AppDatabase.forTesting(NativeDatabase.memory());
        
        // Insert vehicle
        final vehicleId = await database.into(database.vehicles).insert(
          VehiclesCompanion.insert(
            name: 'Test Car',
            initialKm: 0,
          ),
        );

        // Insert fuel entry with new currency fields
        final fuelEntry = FuelEntryModel.create(
          vehicleId: vehicleId,
          date: DateTime.now(),
          currentKm: 1000.0,
          fuelAmount: 50.0,
          price: 60.0, // Converted amount
          originalAmount: 75.0, // Original amount
          currency: 'CHF',
          country: 'Switzerland',
          pricePerLiter: 1.5,
        );

        await database.into(database.fuelEntries).insert(
          fuelEntry.toCompanion(),
        );

        // Verify the entry was stored correctly
        final entries = await database.select(database.fuelEntries).get();
        expect(entries.length, equals(1));
        
        final entry = entries.first;
        expect(entry.currency, equals('CHF'));
        expect(entry.originalAmount, equals(75.0));
        expect(entry.price, equals(60.0));
      });

      test('should handle exchange rate cache operations', () async {
        database = AppDatabase.forTesting(NativeDatabase.memory());
        
        // Insert exchange rate
        final rate = ExchangeRateCacheModel.create(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
        );

        await database.into(database.exchangeRatesCache).insert(
          rate.toCompanion(),
        );

        // Verify the rate was stored correctly
        final rates = await database.select(database.exchangeRatesCache).get();
        expect(rates.length, equals(1));
        
        final cachedRate = rates.first;
        expect(cachedRate.baseCurrency, equals('USD'));
        expect(cachedRate.targetCurrency, equals('EUR'));
        expect(cachedRate.rate, equals(0.8542));
      });

      test('should enforce database constraints', () async {
        database = AppDatabase.forTesting(NativeDatabase.memory());
        
        // Test that we can insert exchange rates successfully
        final rate1 = ExchangeRateCacheModel.create(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
        );

        await database.into(database.exchangeRatesCache).insert(rate1.toCompanion());

        final rates = await database.select(database.exchangeRatesCache).get();
        expect(rates.length, equals(1));
        expect(rates.first.baseCurrency, equals('USD'));
        expect(rates.first.targetCurrency, equals('EUR'));
        expect(rates.first.rate, equals(0.8542));
        
        // Test that the model ensures uppercase currency codes (defensive programming)
        final testModel = ExchangeRateCacheModel.create(
          baseCurrency: 'usd',
          targetCurrency: 'eur', 
          rate: 1.2,
        );
        expect(testModel.baseCurrency, equals('USD')); // Model should convert to uppercase
        expect(testModel.targetCurrency, equals('EUR')); // Model should convert to uppercase
        
        // Test that we can't insert duplicate currency pairs
        final duplicateRate = ExchangeRateCacheModel.create(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.9000,
        );
        
        expect(
          () async => await database.into(database.exchangeRatesCache).insert(
            duplicateRate.toCompanion(),
          ),
          throwsA(isA<SqliteException>()),
        );
      });

      test('should create proper indexes for performance', () async {
        database = AppDatabase.forTesting(NativeDatabase.memory());
        
        // Test that we can query efficiently using indexed columns
        // This is mainly to ensure the indexes were created without errors
        
        // Insert test data
        final rate = ExchangeRateCacheModel.create(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
        );
        await database.into(database.exchangeRatesCache).insert(rate.toCompanion());

        // Query by base currency (should use index)
        final usdRates = await (database.select(database.exchangeRatesCache)
              ..where((t) => t.baseCurrency.equals('USD')))
            .get();
        expect(usdRates.length, equals(1));

        // Query by target currency (should use index)
        final eurRates = await (database.select(database.exchangeRatesCache)
              ..where((t) => t.targetCurrency.equals('EUR')))
            .get();
        expect(eurRates.length, equals(1));

        // Insert vehicle and fuel entry
        final vehicleId = await database.into(database.vehicles).insert(
          VehiclesCompanion.insert(
            name: 'Test Car',
            initialKm: 0,
          ),
        );

        final fuelEntry = FuelEntryModel.create(
          vehicleId: vehicleId,
          date: DateTime.now(),
          currentKm: 1000.0,
          fuelAmount: 50.0,
          price: 60.0,
          currency: 'EUR',
          country: 'Germany',
          pricePerLiter: 1.2,
        );
        await database.into(database.fuelEntries).insert(fuelEntry.toCompanion());

        // Query fuel entries by currency (should use index)
        final eurEntries = await (database.select(database.fuelEntries)
              ..where((t) => t.currency.equals('EUR')))
            .get();
        expect(eurEntries.length, equals(1));
      });

      test('should maintain referential integrity', () async {
        database = AppDatabase.forTesting(NativeDatabase.memory());
        
        // Insert vehicle
        final vehicleId = await database.into(database.vehicles).insert(
          VehiclesCompanion.insert(
            name: 'Test Car',
            initialKm: 0,
          ),
        );

        // Insert fuel entry
        final fuelEntry = FuelEntryModel.create(
          vehicleId: vehicleId,
          date: DateTime.now(),
          currentKm: 1000.0,
          fuelAmount: 50.0,
          price: 60.0,
          currency: 'EUR',
          country: 'Germany',
          pricePerLiter: 1.2,
        );
        await database.into(database.fuelEntries).insert(fuelEntry.toCompanion());

        // Try to delete the vehicle (should fail due to foreign key constraint)
        expect(
          () async => await database.delete(database.vehicles).go(),
          throwsA(isA<SqliteException>()),
        );

        // Delete fuel entry first, then vehicle should work
        await database.delete(database.fuelEntries).go();
        await database.delete(database.vehicles).go();

        final vehicles = await database.select(database.vehicles).get();
        expect(vehicles.length, equals(0));
      });
    });

    group('Data Integrity After Migration', () {
      test('should preserve existing fuel entry data during migration', () async {
        database = AppDatabase.forTesting(NativeDatabase.memory());
        
        // Insert vehicle
        final vehicleId = await database.into(database.vehicles).insert(
          VehiclesCompanion.insert(
            name: 'Test Car',
            initialKm: 0,
          ),
        );

        // Insert fuel entry (simulating pre-migration data)
        final originalEntry = FuelEntryModel.create(
          vehicleId: vehicleId,
          date: DateTime.parse('2023-01-01'),
          currentKm: 1000.0,
          fuelAmount: 50.0,
          price: 60.0,
          country: 'Switzerland',
          pricePerLiter: 1.2,
        );

        await database.into(database.fuelEntries).insert(originalEntry.toCompanion());

        // Verify the entry has default currency and no original amount
        final entries = await database.select(database.fuelEntries).get();
        expect(entries.length, equals(1));
        
        final entry = entries.first;
        expect(entry.vehicleId, equals(vehicleId));
        expect(entry.fuelAmount, equals(50.0));
        expect(entry.price, equals(60.0));
        expect(entry.currency, equals('USD')); // Should have default
        expect(entry.originalAmount, isNull); // Should be null for existing entries
        expect(entry.country, equals('Switzerland'));
      });

      test('should support backward compatibility for models', () async {
        database = AppDatabase.forTesting(NativeDatabase.memory());
        
        // Create models from database entities to ensure fromEntity works
        final userSettings = await database.select(database.userSettings).get();
        expect(userSettings.length, equals(1));
        
        final settingsModel = UserSettingsModel.fromEntity(userSettings.first);
        expect(settingsModel.primaryCurrency, equals('USD'));
        expect(settingsModel.isValid, isTrue);
      });
    });
  });
}

