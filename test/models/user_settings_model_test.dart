import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/models/user_settings_model.dart';

void main() {
  group('UserSettingsModel', () {
    group('Constructor and Factory Methods', () {
      test('should create model with required fields', () {
        final now = DateTime.now();
        final model = UserSettingsModel(
          primaryCurrency: 'USD',
          createdAt: now,
          updatedAt: now,
        );

        expect(model.primaryCurrency, equals('USD'));
        expect(model.createdAt, equals(now));
        expect(model.updatedAt, equals(now));
        expect(model.id, isNull);
      });

      test('should create model with defaults using create factory', () {
        final model = UserSettingsModel.create();

        expect(model.primaryCurrency, equals('USD'));
        expect(model.id, isNull);
        expect(model.createdAt, isNotNull);
        expect(model.updatedAt, isNotNull);
      });

      test('should create model with custom currency using create factory', () {
        final model = UserSettingsModel.create(primaryCurrency: 'EUR');

        expect(model.primaryCurrency, equals('EUR'));
      });
    });

    group('Validation', () {
      test('should validate correct settings', () {
        final model = UserSettingsModel.create(primaryCurrency: 'USD');
        
        expect(model.isValid, isTrue);
        expect(model.validate(), isEmpty);
      });

      test('should reject empty currency', () {
        final now = DateTime.now();
        final model = UserSettingsModel(
          primaryCurrency: '',
          createdAt: now,
          updatedAt: now,
        );

        expect(model.isValid, isFalse);
        expect(model.validate(), contains('Primary currency is required'));
      });

      test('should reject currency with wrong length', () {
        final now = DateTime.now();
        final model = UserSettingsModel(
          primaryCurrency: 'US',
          createdAt: now,
          updatedAt: now,
        );

        expect(model.isValid, isFalse);
        expect(model.validate(), contains('Primary currency must be a 3-character currency code (e.g., USD, EUR)'));
      });

      test('should reject lowercase currency', () {
        final now = DateTime.now();
        final model = UserSettingsModel(
          primaryCurrency: 'usd',
          createdAt: now,
          updatedAt: now,
        );

        expect(model.isValid, isFalse);
        expect(model.validate(), contains('Primary currency code must be uppercase (e.g., USD, not usd)'));
      });

      test('should reject future dates', () {
        final future = DateTime.now().add(const Duration(hours: 1));
        final now = DateTime.now();
        
        final model1 = UserSettingsModel(
          primaryCurrency: 'USD',
          createdAt: future,
          updatedAt: now,
        );

        expect(model1.isValid, isFalse);
        expect(model1.validate(), contains('Created date cannot be in the future'));

        final model2 = UserSettingsModel(
          primaryCurrency: 'USD',
          createdAt: now,
          updatedAt: future,
        );

        expect(model2.isValid, isFalse);
        expect(model2.validate(), contains('Updated date cannot be in the future'));
      });

      test('should reject updated date before created date', () {
        final now = DateTime.now();
        final past = now.subtract(const Duration(hours: 1));
        
        final model = UserSettingsModel(
          primaryCurrency: 'USD',
          createdAt: now,
          updatedAt: past,
        );

        expect(model.isValid, isFalse);
        expect(model.validate(), contains('Updated date cannot be before created date'));
      });
    });

    group('Supported Currencies', () {
      test('should recognize supported currencies', () {
        final model = UserSettingsModel.create(primaryCurrency: 'USD');
        expect(model.isCurrencySupported, isTrue);

        final model2 = UserSettingsModel.create(primaryCurrency: 'EUR');
        expect(model2.isCurrencySupported, isTrue);

        final model3 = UserSettingsModel.create(primaryCurrency: 'XXX');
        expect(model3.isCurrencySupported, isFalse);
      });

      test('should include common currencies in supported list', () {
        expect(UserSettingsModel.supportedCurrencies, contains('USD'));
        expect(UserSettingsModel.supportedCurrencies, contains('EUR'));
        expect(UserSettingsModel.supportedCurrencies, contains('GBP'));
        expect(UserSettingsModel.supportedCurrencies, contains('CHF'));
        expect(UserSettingsModel.supportedCurrencies, contains('JPY'));
        expect(UserSettingsModel.supportedCurrencies.length, greaterThan(20));
      });
    });

    group('Copy Methods', () {
      test('should copy with updated values', () {
        final original = UserSettingsModel.create(primaryCurrency: 'USD');
        final updated = original.copyWith(primaryCurrency: 'EUR');

        expect(updated.primaryCurrency, equals('EUR'));
        expect(updated.createdAt, equals(original.createdAt));
        expect(updated.updatedAt, isNot(equals(original.updatedAt))); // Should auto-update
      });

      test('should copy with primary currency helper', () {
        final original = UserSettingsModel.create(primaryCurrency: 'USD');
        final updated = original.withPrimaryCurrency('EUR');

        expect(updated.primaryCurrency, equals('EUR'));
      });
    });

    group('Equality and Hashing', () {
      test('should be equal when all fields match', () {
        final now = DateTime.now();
        final model1 = UserSettingsModel(
          id: 1,
          primaryCurrency: 'USD',
          createdAt: now,
          updatedAt: now,
        );
        
        final model2 = UserSettingsModel(
          id: 1,
          primaryCurrency: 'USD',
          createdAt: now,
          updatedAt: now,
        );

        expect(model1, equals(model2));
        expect(model1.hashCode, equals(model2.hashCode));
      });

      test('should not be equal when fields differ', () {
        final now = DateTime.now();
        final model1 = UserSettingsModel(
          primaryCurrency: 'USD',
          createdAt: now,
          updatedAt: now,
        );
        
        final model2 = UserSettingsModel(
          primaryCurrency: 'EUR',
          createdAt: now,
          updatedAt: now,
        );

        expect(model1, isNot(equals(model2)));
      });
    });

    group('String Representation', () {
      test('should have meaningful toString', () {
        final model = UserSettingsModel.create(primaryCurrency: 'EUR');
        final str = model.toString();

        expect(str, contains('UserSettingsModel'));
        expect(str, contains('EUR'));
      });
    });

    group('Database Conversion', () {
      test('should convert to and from companion objects', () {
        final model = UserSettingsModel.create(primaryCurrency: 'CHF');
        final companion = model.toCompanion();
        
        expect(companion.primaryCurrency.value, equals('CHF'));
        expect(companion.createdAt.present, isTrue);
        expect(companion.updatedAt.present, isTrue);
      });

      test('should convert to update companion with ID', () {
        final model = UserSettingsModel.create(primaryCurrency: 'GBP').copyWith(id: 1);
        final companion = model.toUpdateCompanion();
        
        expect(companion.id.value, equals(1));
        expect(companion.primaryCurrency.value, equals('GBP'));
        expect(companion.updatedAt.present, isTrue);
      });
    });
  });
}