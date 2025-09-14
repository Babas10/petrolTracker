import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/models/exchange_rate_cache_model.dart';

void main() {
  group('ExchangeRateCacheModel', () {
    group('Constructor and Factory Methods', () {
      test('should create model with required fields', () {
        final now = DateTime.now();
        final model = ExchangeRateCacheModel(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
          lastUpdated: now,
          createdAt: now,
        );

        expect(model.baseCurrency, equals('USD'));
        expect(model.targetCurrency, equals('EUR'));
        expect(model.rate, equals(0.8542));
        expect(model.lastUpdated, equals(now));
        expect(model.createdAt, equals(now));
        expect(model.id, isNull);
      });

      test('should create model with defaults using create factory', () {
        final model = ExchangeRateCacheModel.create(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
        );

        expect(model.baseCurrency, equals('USD'));
        expect(model.targetCurrency, equals('EUR'));
        expect(model.rate, equals(0.8542));
        expect(model.id, isNull);
        expect(model.lastUpdated, isNotNull);
        expect(model.createdAt, isNotNull);
      });

      test('should auto-uppercase currency codes in create factory', () {
        final model = ExchangeRateCacheModel.create(
          baseCurrency: 'usd',
          targetCurrency: 'eur',
          rate: 0.8542,
        );

        expect(model.baseCurrency, equals('USD'));
        expect(model.targetCurrency, equals('EUR'));
      });
    });

    group('Validation', () {
      test('should validate correct exchange rate', () {
        final model = ExchangeRateCacheModel.create(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
        );
        
        expect(model.isValid, isTrue);
        expect(model.validate(), isEmpty);
      });

      test('should reject empty currencies', () {
        final now = DateTime.now();
        final model1 = ExchangeRateCacheModel(
          baseCurrency: '',
          targetCurrency: 'EUR',
          rate: 0.8542,
          lastUpdated: now,
          createdAt: now,
        );

        expect(model1.isValid, isFalse);
        expect(model1.validate(), contains('Base currency is required'));

        final model2 = ExchangeRateCacheModel(
          baseCurrency: 'USD',
          targetCurrency: '',
          rate: 0.8542,
          lastUpdated: now,
          createdAt: now,
        );

        expect(model2.isValid, isFalse);
        expect(model2.validate(), contains('Target currency is required'));
      });

      test('should reject currencies with wrong length', () {
        final now = DateTime.now();
        final model = ExchangeRateCacheModel(
          baseCurrency: 'US',
          targetCurrency: 'EUR',
          rate: 0.8542,
          lastUpdated: now,
          createdAt: now,
        );

        expect(model.isValid, isFalse);
        expect(model.validate(), contains('Base currency must be a 3-character currency code (e.g., USD, EUR)'));
      });

      test('should reject lowercase currencies', () {
        final now = DateTime.now();
        final model = ExchangeRateCacheModel(
          baseCurrency: 'usd',
          targetCurrency: 'EUR',
          rate: 0.8542,
          lastUpdated: now,
          createdAt: now,
        );

        expect(model.isValid, isFalse);
        expect(model.validate(), contains('Base currency code must be uppercase (e.g., USD, not usd)'));
      });

      test('should reject same currency conversion', () {
        final now = DateTime.now();
        final model = ExchangeRateCacheModel(
          baseCurrency: 'USD',
          targetCurrency: 'USD',
          rate: 1.0,
          lastUpdated: now,
          createdAt: now,
        );

        expect(model.isValid, isFalse);
        expect(model.validate(), contains('Base and target currencies must be different'));
      });

      test('should reject invalid rates', () {
        final now = DateTime.now();
        final model1 = ExchangeRateCacheModel(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.0,
          lastUpdated: now,
          createdAt: now,
        );

        expect(model1.isValid, isFalse);
        expect(model1.validate(), contains('Exchange rate must be greater than 0'));

        final model2 = ExchangeRateCacheModel(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: -1.0,
          lastUpdated: now,
          createdAt: now,
        );

        expect(model2.isValid, isFalse);
        expect(model2.validate(), contains('Exchange rate must be greater than 0'));

        final model3 = ExchangeRateCacheModel(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 20000.0,
          lastUpdated: now,
          createdAt: now,
        );

        expect(model3.isValid, isFalse);
        expect(model3.validate(), contains('Exchange rate seems unreasonably high (>20000.00). Please verify.'));
      });

      test('should reject future dates', () {
        final future = DateTime.now().add(const Duration(hours: 1));
        final now = DateTime.now();
        
        final model1 = ExchangeRateCacheModel(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
          lastUpdated: future,
          createdAt: now,
        );

        expect(model1.isValid, isFalse);
        expect(model1.validate(), contains('Last updated date cannot be in the future'));

        final model2 = ExchangeRateCacheModel(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
          lastUpdated: now,
          createdAt: future,
        );

        expect(model2.isValid, isFalse);
        expect(model2.validate(), contains('Created date cannot be in the future'));
      });
    });

    group('Freshness and Age', () {
      test('should determine if rate is fresh', () {
        final now = DateTime.now();
        final fresh = ExchangeRateCacheModel(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
          lastUpdated: now,
          createdAt: now,
        );

        expect(fresh.isFresh, isTrue);

        final stale = ExchangeRateCacheModel(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
          lastUpdated: now.subtract(const Duration(hours: 25)),
          createdAt: now.subtract(const Duration(hours: 25)),
        );

        expect(stale.isFresh, isFalse);
      });

      test('should calculate age in hours', () {
        final now = DateTime.now();
        final model = ExchangeRateCacheModel(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
          lastUpdated: now.subtract(const Duration(hours: 5)),
          createdAt: now.subtract(const Duration(hours: 10)),
        );

        expect(model.ageInHours, equals(5));
      });
    });

    group('Currency Conversion', () {
      test('should convert amounts using the rate', () {
        final model = ExchangeRateCacheModel.create(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
        );

        expect(model.convertAmount(100.0), closeTo(85.42, 0.01));
        expect(model.convertAmount(1.0), equals(0.8542));
      });

      test('should provide inverse rate', () {
        final model = ExchangeRateCacheModel.create(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
        );

        expect(model.inverseRate, closeTo(1.1707, 0.0001));
      });

      test('should convert amounts using inverse rate', () {
        final model = ExchangeRateCacheModel.create(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
        );

        expect(model.convertAmountReverse(85.42), closeTo(100.0, 0.01));
      });
    });

    group('Formatting', () {
      test('should format rate for display', () {
        final model = ExchangeRateCacheModel.create(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
        );

        expect(model.formattedRate, equals('0.8542'));
      });

      test('should format currency pair', () {
        final model = ExchangeRateCacheModel.create(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
        );

        expect(model.currencyPair, equals('USD/EUR'));
      });

      test('should format display string', () {
        final model = ExchangeRateCacheModel.create(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
        );

        expect(model.displayString, equals('1 USD = 0.8542 EUR'));
      });
    });

    group('Copy Methods', () {
      test('should copy with updated values', () {
        final original = ExchangeRateCacheModel.create(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
        );
        
        final updated = original.copyWith(rate: 0.9000);

        expect(updated.rate, equals(0.9000));
        expect(updated.baseCurrency, equals(original.baseCurrency));
        expect(updated.targetCurrency, equals(original.targetCurrency));
      });

      test('should copy with updated rate and timestamp', () {
        final original = ExchangeRateCacheModel.create(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
        );
        
        final newTimestamp = DateTime.now().add(const Duration(hours: 1));
        final updated = original.withUpdatedRate(0.9000, timestamp: newTimestamp);

        expect(updated.rate, equals(0.9000));
        expect(updated.lastUpdated, equals(newTimestamp));
      });
    });

    group('Equality and Hashing', () {
      test('should be equal when all fields match', () {
        final now = DateTime.now();
        final model1 = ExchangeRateCacheModel(
          id: 1,
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
          lastUpdated: now,
          createdAt: now,
        );
        
        final model2 = ExchangeRateCacheModel(
          id: 1,
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
          lastUpdated: now,
          createdAt: now,
        );

        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should not be equal when fields differ', () {
        final now = DateTime.now();
        final model1 = ExchangeRateCacheModel(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
          lastUpdated: now,
          createdAt: now,
        );
        
        final model2 = ExchangeRateCacheModel(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.9000,
          lastUpdated: now,
          createdAt: now,
        );

        expect(model1, isNot(equals(model2)));
      });
    });

    group('String Representation', () {
      test('should have meaningful toString', () {
        final model = ExchangeRateCacheModel.create(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
        );
        
        final str = model.toString();

        expect(str, contains('ExchangeRateCacheModel'));
        expect(str, contains('USD'));
        expect(str, contains('EUR'));
        expect(str, contains('0.8542'));
      });
    });

    group('Database Conversion', () {
      test('should convert to and from companion objects', () {
        final model = ExchangeRateCacheModel.create(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
        );
        
        final companion = model.toCompanion();
        
        expect(companion.baseCurrency.value, equals('USD'));
        expect(companion.targetCurrency.value, equals('EUR'));
        expect(companion.rate.value, equals(0.8542));
        expect(companion.lastUpdated.present, isTrue);
        expect(companion.createdAt.present, isTrue);
      });

      test('should convert to update companion with ID', () {
        final model = ExchangeRateCacheModel.create(
          baseCurrency: 'USD',
          targetCurrency: 'EUR',
          rate: 0.8542,
        ).copyWith(id: 1);
        
        final companion = model.toUpdateCompanion();
        
        expect(companion.id.value, equals(1));
        expect(companion.baseCurrency.value, equals('USD'));
        expect(companion.targetCurrency.value, equals('EUR'));
        expect(companion.rate.value, equals(0.8542));
      });
    });
  });
}