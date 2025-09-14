import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/models/fuel_entry_model.dart';
import 'package:petrol_tracker/database/database.dart';

void main() {
  group('FuelEntryModel Tests', () {
    final testDate = DateTime(2024, 1, 15);

    test('creates fuel entry model correctly', () {
      final entry = FuelEntryModel(
        id: 1,
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        currency: 'USD',
        country: 'Canada',
        pricePerLiter: 1.45,
        consumption: 8.5,
        isFullTank: true,
      );

      expect(entry.id, equals(1));
      expect(entry.vehicleId, equals(1));
      expect(entry.date, equals(testDate));
      expect(entry.currentKm, equals(50200.0));
      expect(entry.fuelAmount, equals(40.0));
      expect(entry.price, equals(58.0));
      expect(entry.country, equals('Canada'));
      expect(entry.pricePerLiter, equals(1.45));
      expect(entry.consumption, equals(8.5));
    });

    test('creates fuel entry model from entity', () {
      final entity = FuelEntry(
        id: 1,
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        currency: 'USD',
        country: 'Canada',
        pricePerLiter: 1.45,
        consumption: 8.5,
        isFullTank: true,
      );

      final entry = FuelEntryModel.fromEntity(entity);

      expect(entry.id, equals(1));
      expect(entry.vehicleId, equals(1));
      expect(entry.date, equals(testDate));
      expect(entry.currentKm, equals(50200.0));
      expect(entry.fuelAmount, equals(40.0));
      expect(entry.price, equals(58.0));
      expect(entry.country, equals('Canada'));
      expect(entry.pricePerLiter, equals(1.45));
      expect(entry.consumption, equals(8.5));
    });

    test('creates fuel entry model for new creation', () {
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        country: 'Canada',
        pricePerLiter: 1.45,
      );

      expect(entry.id, isNull);
      expect(entry.vehicleId, equals(1));
      expect(entry.date, equals(testDate));
      expect(entry.currentKm, equals(50200.0));
      expect(entry.fuelAmount, equals(40.0));
      expect(entry.price, equals(58.0));
      expect(entry.country, equals('Canada'));
      expect(entry.pricePerLiter, equals(1.45));
      expect(entry.consumption, isNull);
    });

    test('converts to companion correctly', () {
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        country: 'Canada',
        pricePerLiter: 1.45,
        consumption: 8.5,
      );

      final companion = entry.toCompanion();

      expect(companion.vehicleId.value, equals(1));
      expect(companion.date.value, equals(testDate));
      expect(companion.currentKm.value, equals(50200.0));
      expect(companion.fuelAmount.value, equals(40.0));
      expect(companion.price.value, equals(58.0));
      expect(companion.country.value, equals('Canada'));
      expect(companion.pricePerLiter.value, equals(1.45));
      expect(companion.consumption.value, equals(8.5));
    });

    test('converts to update companion correctly', () {
      final entry = FuelEntryModel(
        id: 1,
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        currency: 'USD',
        country: 'Canada',
        pricePerLiter: 1.45,
        consumption: 8.5,
        isFullTank: true,
      );

      final companion = entry.toUpdateCompanion();

      expect(companion.id.value, equals(1));
      expect(companion.vehicleId.value, equals(1));
      expect(companion.date.value, equals(testDate));
      expect(companion.currentKm.value, equals(50200.0));
      expect(companion.fuelAmount.value, equals(40.0));
      expect(companion.price.value, equals(58.0));
      expect(companion.country.value, equals('Canada'));
      expect(companion.pricePerLiter.value, equals(1.45));
      expect(companion.consumption.value, equals(8.5));
    });

    test('calculates consumption correctly', () {
      final consumption = FuelEntryModel.calculateConsumption(
        fuelAmount: 40.0,
        currentKm: 50200.0,
        previousKm: 49800.0,
      );

      // 40L for 400km = 10L/100km
      expect(consumption, equals(10.0));
    });

    test('calculates consumption returns null for invalid distance', () {
      final consumption = FuelEntryModel.calculateConsumption(
        fuelAmount: 40.0,
        currentKm: 50200.0,
        previousKm: 50200.0, // Same km
      );

      expect(consumption, isNull);
    });

    test('withCalculatedConsumption works correctly', () {
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        country: 'Canada',
        pricePerLiter: 1.45,
      );

      final updatedEntry = entry.withCalculatedConsumption(49800.0);

      expect(updatedEntry.consumption, equals(10.0));
      expect(updatedEntry.vehicleId, equals(entry.vehicleId));
      expect(updatedEntry.fuelAmount, equals(entry.fuelAmount));
    });

    test('validates correctly - valid entry', () {
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        country: 'Canada',
        pricePerLiter: 1.45,
      );

      final errors = entry.validate(previousKm: 50000.0);
      expect(errors, isEmpty);
      expect(entry.isValid(previousKm: 50000.0), isTrue);
    });

    test('validates correctly - invalid vehicle ID', () {
      final entry = FuelEntryModel.create(
        vehicleId: 0,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        country: 'Canada',
        pricePerLiter: 1.45,
      );

      final errors = entry.validate();
      expect(errors, contains('Vehicle ID must be valid'));
      expect(entry.isValid(), isFalse);
    });

    test('validates correctly - future date', () {
      final futureDate = DateTime.now().add(const Duration(days: 2));
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: futureDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        country: 'Canada',
        pricePerLiter: 1.45,
      );

      final errors = entry.validate();
      expect(errors, contains('Date cannot be in the future'));
      expect(entry.isValid(), isFalse);
    });

    test('validates correctly - negative current km', () {
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: -100.0,
        fuelAmount: 40.0,
        price: 58.0,
        country: 'Canada',
        pricePerLiter: 1.45,
      );

      final errors = entry.validate();
      expect(errors, contains('Current kilometers must be 0 or greater'));
      expect(entry.isValid(), isFalse);
    });

    test('validates correctly - km less than previous', () {
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50000.0,
        fuelAmount: 40.0,
        price: 58.0,
        country: 'Canada',
        pricePerLiter: 1.45,
      );

      final errors = entry.validate(previousKm: 50500.0);
      expect(errors, contains('Current kilometers must be greater than or equal to previous entry (50500.0 km)'));
      expect(entry.isValid(previousKm: 50500.0), isFalse);
    });

    test('validates correctly - zero fuel amount', () {
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 0.0,
        price: 58.0,
        country: 'Canada',
        pricePerLiter: 1.45,
      );

      final errors = entry.validate();
      expect(errors, contains('Fuel amount must be greater than 0'));
      expect(entry.isValid(), isFalse);
    });

    test('validates correctly - excessive fuel amount', () {
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 250.0,
        price: 58.0,
        country: 'Canada',
        pricePerLiter: 1.45,
      );

      final errors = entry.validate();
      expect(errors, contains('Fuel amount seems unusually high (>200L). Please verify.'));
    });

    test('validates correctly - zero price', () {
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 0.0,
        country: 'Canada',
        pricePerLiter: 1.45,
      );

      final errors = entry.validate();
      expect(errors, contains('Price must be greater than 0'));
      expect(entry.isValid(), isFalse);
    });

    test('validates correctly - high price per liter', () {
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 480.0,
        country: 'Canada',
        pricePerLiter: 12.0,
      );

      final errors = entry.validate();
      expect(errors, contains('Price per liter seems unusually high (>12.00). Please verify.'));
    });

    test('validates correctly - empty country', () {
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        country: '',
        pricePerLiter: 1.45,
      );

      final errors = entry.validate();
      expect(errors, contains('Country is required'));
      expect(entry.isValid(), isFalse);
    });

    test('validates correctly - short country name', () {
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        country: 'A',
        pricePerLiter: 1.45,
      );

      final errors = entry.validate();
      expect(errors, contains('Country name must be at least 2 characters'));
      expect(entry.isValid(), isFalse);
    });

    test('validates correctly - price consistency', () {
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 60.0, // Should be 40 * 1.45 = 58.0
        country: 'Canada',
        pricePerLiter: 1.45,
      );

      final errors = entry.validate();
      expect(errors.first, contains('Price (60.00) does not match fuel amount × price per liter (58.00)'));
      expect(entry.isValid(), isFalse);
    });

    test('validates correctly - price consistency with integer format (Issue #44)', () {
      // Test the specific issue: user enters 52 (integer) for 40L fuel
      // Auto-calculated price per liter: 52 ÷ 40 = 1.3000
      // Validation should pass as 40 × 1.3000 = 52.0000
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 52.0, // Integer input (52)
        country: 'Canada',
        pricePerLiter: 1.3000, // Auto-calculated
      );

      final errors = entry.validate();
      expect(errors, isEmpty, reason: 'Integer price format should be valid');
      expect(entry.isValid(), isTrue);
    });

    test('validates correctly - price consistency with decimal format', () {
      // Test that decimal format still works
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 52.00, // Decimal input
        country: 'Canada',
        pricePerLiter: 1.3000,
      );

      final errors = entry.validate();
      expect(errors, isEmpty);
      expect(entry.isValid(), isTrue);
    });

    test('validates correctly - price consistency with floating point precision', () {
      // Test floating point precision issues
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 33.33,
        price: 50.0,
        country: 'Canada',
        pricePerLiter: 1.5000, // 33.33 × 1.5000 = 49.995, close to 50.0
      );

      final errors = entry.validate();
      expect(errors, isEmpty, reason: 'Small floating point differences should be tolerated');
      expect(entry.isValid(), isTrue);
    });

    test('validates correctly - price consistency tolerance boundary', () {
      // Test that the tolerance (0.05) works correctly
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 52.0,
        country: 'Canada',
        pricePerLiter: 1.301, // 40 × 1.301 = 52.04, difference = 0.04 (within tolerance)
      );

      final errors = entry.validate();
      expect(errors, isEmpty, reason: 'Difference within tolerance should be valid');
      expect(entry.isValid(), isTrue);
    });

    test('validates correctly - price consistency exceeds tolerance', () {
      // Test that differences exceeding tolerance are still caught
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 52.0,
        country: 'Canada',
        pricePerLiter: 1.35, // 40 × 1.35 = 54.0, difference = 2.0 (exceeds tolerance)
      );

      final errors = entry.validate();
      expect(errors, isNotEmpty);
      expect(errors.first, contains('Price (52.00) does not match fuel amount × price per liter (54.00)'));
      expect(entry.isValid(), isFalse);
    });

    test('formatted properties work correctly', () {
      final entry = FuelEntryModel(
        id: 1,
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.5,
        price: 58.73,
        currency: 'USD',
        country: 'Canada',
        pricePerLiter: 1.45,
        consumption: 8.5,
        isFullTank: true,
      );

      expect(entry.formattedConsumption, equals('8.5 L/100km'));
      expect(entry.formattedPrice, equals('\$58.73'));
      expect(entry.formattedFuelAmount, equals('40.5L'));
      expect(entry.averagePricePerLiter, closeTo(1.45, 0.01));
    });

    test('formatted consumption handles null', () {
      final entry = FuelEntryModel.create(
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        country: 'Canada',
        pricePerLiter: 1.45,
      );

      expect(entry.formattedConsumption, equals('N/A'));
    });

    test('copyWith works correctly', () {
      final original = FuelEntryModel(
        id: 1,
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        currency: 'USD',
        country: 'Canada',
        pricePerLiter: 1.45,
        consumption: 8.5,
        isFullTank: true,
      );

      final copied = original.copyWith(
        currentKm: 50300.0,
        fuelAmount: 45.0,
      );

      expect(copied.id, equals(1));
      expect(copied.currentKm, equals(50300.0));
      expect(copied.fuelAmount, equals(45.0));
      expect(copied.vehicleId, equals(1));
      expect(copied.price, equals(58.0));
    });

    test('equality works correctly', () {
      final entry1 = FuelEntryModel(
        id: 1,
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        currency: 'USD',
        country: 'Canada',
        pricePerLiter: 1.45,
        consumption: 8.5,
        isFullTank: true,
      );

      final entry2 = FuelEntryModel(
        id: 1,
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        currency: 'USD',
        country: 'Canada',
        pricePerLiter: 1.45,
        consumption: 8.5,
        isFullTank: true,
      );

      final entry3 = entry1.copyWith(id: 2);

      expect(entry1, equals(entry2));
      expect(entry1, isNot(equals(entry3)));
    });

    test('toString works correctly', () {
      final entry = FuelEntryModel(
        id: 1,
        vehicleId: 1,
        date: testDate,
        currentKm: 50200.0,
        fuelAmount: 40.0,
        price: 58.0,
        currency: 'USD',
        country: 'Canada',
        pricePerLiter: 1.45,
        consumption: 8.5,
        isFullTank: true,
      );

      final result = entry.toString();
      expect(result, contains('FuelEntryModel'));
      expect(result, contains('id: 1'));
      expect(result, contains('vehicleId: 1'));
      expect(result, contains('fuelAmount: 40.0'));
    });

    group('Multi-currency support', () {
      test('should detect converted entries correctly', () {
        final normalEntry = FuelEntryModel.create(
          vehicleId: 1,
          date: testDate,
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          currency: 'USD',
          country: 'United States',
          pricePerLiter: 1.45,
        );

        final convertedEntry = FuelEntryModel.create(
          vehicleId: 1,
          date: testDate,
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 45.20,
          originalAmount: 50.0,
          currency: 'EUR',
          country: 'Germany',
          pricePerLiter: 1.25,
          exchangeRate: 0.904,
          rateDate: testDate,
        );

        expect(normalEntry.isConverted, false);
        expect(convertedEntry.isConverted, true);
      });

      test('should validate exchange rate correctly', () {
        final entryWithInvalidRate = FuelEntryModel.create(
          vehicleId: 1,
          date: testDate,
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          currency: 'USD',
          country: 'United States',
          pricePerLiter: 1.45,
          exchangeRate: -1.0, // Invalid negative rate
        );

        final errors = entryWithInvalidRate.validate();
        expect(errors, contains(contains('Exchange rate must be greater than 0')));
      });

      test('should validate high exchange rate', () {
        final entryWithHighRate = FuelEntryModel.create(
          vehicleId: 1,
          date: testDate,
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          currency: 'USD',
          country: 'United States',
          pricePerLiter: 1.45,
          exchangeRate: 15000.0, // Unreasonably high rate
        );

        final errors = entryWithHighRate.validate();
        expect(errors, contains(contains('unreasonably high')));
      });

      test('should require rate date when exchange rate is provided', () {
        final entryMissingRateDate = FuelEntryModel.create(
          vehicleId: 1,
          date: testDate,
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          currency: 'USD',
          country: 'United States',
          pricePerLiter: 1.45,
          exchangeRate: 0.85,
          // rateDate not provided
        );

        final errors = entryMissingRateDate.validate();
        expect(errors, contains(contains('Rate date is required when exchange rate is provided')));
      });

      test('should validate original amount', () {
        final entryWithInvalidOriginal = FuelEntryModel.create(
          vehicleId: 1,
          date: testDate,
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          originalAmount: -10.0, // Invalid negative amount
          currency: 'EUR',
          country: 'Germany',
          pricePerLiter: 1.45,
        );

        final errors = entryWithInvalidOriginal.validate();
        expect(errors, contains(contains('Original amount must be greater than 0')));
      });

      test('should format currency prices correctly', () {
        final convertedEntry = FuelEntryModel(
          id: 1,
          vehicleId: 1,
          date: testDate,
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 45.20,
          originalAmount: 50.0,
          currency: 'EUR',
          country: 'Germany',
          pricePerLiter: 1.25,
          consumption: 8.5,
          isFullTank: true,
          exchangeRate: 0.904,
          rateDate: testDate,
        );

        expect(convertedEntry.formattedOriginalPrice, contains('€'));
        expect(convertedEntry.formattedConvertedPrice, contains('\$'));
        expect(convertedEntry.formattedPriceWithOriginal, contains('€'));
        expect(convertedEntry.formattedPriceWithOriginal, contains('\$'));
      });

      test('should provide cost summary for converted entries', () {
        final convertedEntry = FuelEntryModel(
          id: 1,
          vehicleId: 1,
          date: testDate,
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 45.20,
          originalAmount: 50.0,
          currency: 'EUR',
          country: 'Germany',
          pricePerLiter: 1.25,
          consumption: 8.5,
          isFullTank: true,
          exchangeRate: 0.904,
          rateDate: testDate,
        );

        final costSummary = convertedEntry.costSummary;
        expect(costSummary, contains('€'));
        expect(costSummary, contains('\$'));
        expect(costSummary, contains('→'));
        expect(costSummary, contains('@'));
      });

      test('should check for complete conversion data', () {
        final incompleteEntry = FuelEntryModel.create(
          vehicleId: 1,
          date: testDate,
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 45.20,
          originalAmount: 50.0,
          currency: 'EUR',
          country: 'Germany',
          pricePerLiter: 1.25,
          // Missing exchange rate and rate date
        );

        final completeEntry = incompleteEntry.copyWith(
          exchangeRate: 0.904,
          rateDate: testDate,
        );

        expect(incompleteEntry.hasCompleteConversionData, false);
        expect(completeEntry.hasCompleteConversionData, true);
      });

      test('should calculate exchange rate age', () {
        final recentEntry = FuelEntryModel.create(
          vehicleId: 1,
          date: testDate,
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 45.20,
          currency: 'USD',
          country: 'United States',
          pricePerLiter: 1.13,
          exchangeRate: 1.0,
          rateDate: DateTime.now().subtract(const Duration(hours: 12)),
        );

        final oldEntry = recentEntry.copyWith(
          rateDate: DateTime.now().subtract(const Duration(hours: 48)),
        );

        expect(recentEntry.exchangeRateAgeInHours, lessThan(24));
        expect(recentEntry.isExchangeRateFresh, true);
        
        expect(oldEntry.exchangeRateAgeInHours, greaterThan(24));
        expect(oldEntry.isExchangeRateFresh, false);
      });

      test('should format exchange rate information', () {
        final entryWithRate = FuelEntryModel.create(
          vehicleId: 1,
          date: testDate,
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 45.20,
          originalAmount: 50.0,
          currency: 'EUR',
          country: 'Germany',
          pricePerLiter: 1.25,
          exchangeRate: 0.904,
          rateDate: testDate,
        );

        final normalEntry = FuelEntryModel.create(
          vehicleId: 1,
          date: testDate,
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          currency: 'USD',
          country: 'United States',
          pricePerLiter: 1.45,
        );

        expect(entryWithRate.formattedExchangeRate, isNotNull);
        expect(entryWithRate.formattedExchangeRate, contains('EUR'));
        expect(entryWithRate.formattedExchangeRate, contains('USD'));
        
        expect(normalEntry.formattedExchangeRate, isNull);
      });

      test('should format price per liter with currency', () {
        final eurEntry = FuelEntryModel.create(
          vehicleId: 1,
          date: testDate,
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 50.0,
          currency: 'EUR',
          country: 'Germany',
          pricePerLiter: 1.25,
        );

        final formatted = eurEntry.formattedPricePerLiterWithCurrency;
        expect(formatted, contains('€'));
        expect(formatted, contains('/L'));
      });

      test('should create entry with exchange rate data using factory', () {
        final entryWithRate = FuelEntryModel.create(
          vehicleId: 1,
          date: testDate,
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 45.20,
          originalAmount: 50.0,
          currency: 'EUR',
          country: 'Germany',
          pricePerLiter: 1.25,
          exchangeRate: 0.904,
          rateDate: testDate,
        );

        expect(entryWithRate.exchangeRate, 0.904);
        expect(entryWithRate.rateDate, testDate);
        expect(entryWithRate.originalAmount, 50.0);
        expect(entryWithRate.isConverted, true);
      });

      test('should include exchange rate fields in copyWith', () {
        final original = FuelEntryModel.create(
          vehicleId: 1,
          date: testDate,
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          currency: 'USD',
          country: 'United States',
          pricePerLiter: 1.45,
        );

        final updated = original.copyWith(
          exchangeRate: 0.85,
          rateDate: DateTime(2024, 1, 20),
        );

        expect(updated.exchangeRate, 0.85);
        expect(updated.rateDate, DateTime(2024, 1, 20));
        expect(updated.vehicleId, original.vehicleId);
        expect(updated.price, original.price);
      });

      test('should include exchange rate fields in equality comparison', () {
        final entry1 = FuelEntryModel.create(
          vehicleId: 1,
          date: testDate,
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          currency: 'USD',
          country: 'United States',
          pricePerLiter: 1.45,
          exchangeRate: 0.85,
          rateDate: testDate,
        );

        final entry2 = entry1.copyWith();
        final entry3 = entry1.copyWith(exchangeRate: 0.90);

        expect(entry1, equals(entry2));
        expect(entry1, isNot(equals(entry3)));
      });

      test('should include exchange rate fields in toString', () {
        final entry = FuelEntryModel.create(
          vehicleId: 1,
          date: testDate,
          currentKm: 50200.0,
          fuelAmount: 40.0,
          price: 58.0,
          currency: 'USD',
          country: 'United States',
          pricePerLiter: 1.45,
          exchangeRate: 0.85,
          rateDate: testDate,
        );

        final string = entry.toString();
        expect(string, contains('exchangeRate: 0.85'));
        expect(string, contains('rateDate: $testDate'));
      });
    });
  });
}