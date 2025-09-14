import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker/utils/currency_formatter.dart';
import 'package:petrol_tracker/models/currency/currency_conversion.dart';
import 'package:petrol_tracker/models/currency/currency_settings.dart';

void main() {
  group('CurrencyFormatter', () {
    group('formatAmount', () {
      test('should format USD amounts correctly', () {
        expect(CurrencyFormatter.formatAmount(45.20, 'USD'), '\$45.20');
        expect(CurrencyFormatter.formatAmount(1000.50, 'USD'), '\$1000.50');
        expect(CurrencyFormatter.formatAmount(0.99, 'USD'), '\$0.99');
      });

      test('should format EUR amounts correctly', () {
        expect(CurrencyFormatter.formatAmount(45.20, 'EUR'), '€45.20');
        expect(CurrencyFormatter.formatAmount(1000.50, 'EUR'), '€1000.50');
      });

      test('should format JPY amounts correctly (no decimals)', () {
        expect(CurrencyFormatter.formatAmount(1500, 'JPY'), '¥1500');
        expect(CurrencyFormatter.formatAmount(1500.99, 'JPY'), '¥1501');
      });

      test('should format currency codes without symbols', () {
        expect(CurrencyFormatter.formatAmount(45.20, 'THB'), 'THB 45.20');
        expect(CurrencyFormatter.formatAmount(100.00, 'MYR'), 'MYR 100.00');
      });

      test('should respect custom decimal places', () {
        expect(CurrencyFormatter.formatAmount(45.123, 'USD', customDecimalPlaces: 3), '\$45.123');
        expect(CurrencyFormatter.formatAmount(45.123, 'USD', customDecimalPlaces: 1), '\$45.1');
        expect(CurrencyFormatter.formatAmount(45.123, 'USD', customDecimalPlaces: 0), '\$45');
      });

      test('should handle currency settings', () {
        final settings = CurrencySettings(decimalPlaces: 3);
        expect(CurrencyFormatter.formatAmount(45.123, 'USD', settings: settings), '\$45.123');
      });
    });

    group('formatConversion', () {
      test('should format currency conversion with rate', () {
        final conversion = CurrencyConversion(
          originalAmount: 50.0,
          originalCurrency: 'EUR',
          convertedAmount: 45.20,
          targetCurrency: 'USD',
          exchangeRate: 0.904,
          rateDate: DateTime(2024, 1, 15),
        );

        final result = CurrencyFormatter.formatConversion(conversion);
        expect(result, '€50.00 → \$45.20 (rate: 0.9040)');
      });

      test('should format currency conversion without rate', () {
        final conversion = CurrencyConversion(
          originalAmount: 50.0,
          originalCurrency: 'EUR',
          convertedAmount: 45.20,
          targetCurrency: 'USD',
          exchangeRate: 0.904,
          rateDate: DateTime(2024, 1, 15),
        );

        final result = CurrencyFormatter.formatConversion(conversion, showRate: false);
        expect(result, '€50.00 → \$45.20');
      });

      test('should respect currency settings for showing rates', () {
        final conversion = CurrencyConversion(
          originalAmount: 50.0,
          originalCurrency: 'EUR',
          convertedAmount: 45.20,
          targetCurrency: 'USD',
          exchangeRate: 0.904,
          rateDate: DateTime(2024, 1, 15),
        );

        final settings = CurrencySettings(showExchangeRates: false);
        final result = CurrencyFormatter.formatConversion(conversion, settings: settings);
        expect(result, '€50.00 → \$45.20');
      });
    });

    group('formatWithOriginal', () {
      test('should show both original and converted amounts', () {
        final result = CurrencyFormatter.formatWithOriginal(
          45.20,
          'USD',
          originalAmount: 50.0,
          originalCurrency: 'EUR',
        );
        expect(result, '€50.00 (\$45.20)');
      });

      test('should show only converted amount when showOriginal is false', () {
        final result = CurrencyFormatter.formatWithOriginal(
          45.20,
          'USD',
          originalAmount: 50.0,
          originalCurrency: 'EUR',
          showOriginal: false,
        );
        expect(result, '\$45.20');
      });

      test('should show only converted amount when original data is missing', () {
        final result = CurrencyFormatter.formatWithOriginal(45.20, 'USD');
        expect(result, '\$45.20');
      });

      test('should respect currency settings', () {
        final settings = CurrencySettings(showOriginalAmounts: false);
        final result = CurrencyFormatter.formatWithOriginal(
          45.20,
          'USD',
          originalAmount: 50.0,
          originalCurrency: 'EUR',
          settings: settings,
        );
        expect(result, '\$45.20');
      });
    });

    group('formatExchangeRate', () {
      test('should format exchange rate correctly', () {
        expect(CurrencyFormatter.formatExchangeRate('USD', 'EUR', 0.8542), '1 USD = 0.8542 EUR');
        expect(CurrencyFormatter.formatExchangeRate('EUR', 'USD', 1.1705), '1 EUR = 1.1705 USD');
      });

      test('should respect decimal places parameter', () {
        expect(CurrencyFormatter.formatExchangeRate('USD', 'EUR', 0.8542, decimals: 2), '1 USD = 0.85 EUR');
        expect(CurrencyFormatter.formatExchangeRate('USD', 'EUR', 0.8542, decimals: 6), '1 USD = 0.854200 EUR');
      });
    });

    group('formatPricePerUnit', () {
      test('should format price per unit correctly', () {
        expect(CurrencyFormatter.formatPricePerUnit(1.45, 'USD', 'L'), '\$1.45/L');
        expect(CurrencyFormatter.formatPricePerUnit(0.89, 'EUR', 'L'), '€0.89/L');
      });

      test('should handle currency codes without symbols', () {
        expect(CurrencyFormatter.formatPricePerUnit(5.50, 'THB', 'L'), 'THB 5.50/L');
      });
    });

    group('formatRange', () {
      test('should format currency range correctly', () {
        expect(CurrencyFormatter.formatRange(45.20, 52.80, 'USD'), '\$45.20 - \$52.80');
        expect(CurrencyFormatter.formatRange(100.0, 150.0, 'EUR'), '€100.00 - €150.00');
      });
    });

    group('formatPercentageChange', () {
      test('should format positive percentage with plus sign', () {
        expect(CurrencyFormatter.formatPercentageChange(15.2), '+15.2%');
        expect(CurrencyFormatter.formatPercentageChange(0.1), '+0.1%');
      });

      test('should format negative percentage correctly', () {
        expect(CurrencyFormatter.formatPercentageChange(-8.7), '-8.7%');
      });

      test('should format zero percentage correctly', () {
        expect(CurrencyFormatter.formatPercentageChange(0.0), '+0.0%');
      });
    });

    group('formatLargeAmount', () {
      test('should format small amounts normally', () {
        expect(CurrencyFormatter.formatLargeAmount(500.0, 'USD'), '\$500.00');
        expect(CurrencyFormatter.formatLargeAmount(999.0, 'USD'), '\$999.00');
      });

      test('should format thousands with K suffix', () {
        expect(CurrencyFormatter.formatLargeAmount(1500.0, 'USD'), '\$1.5K');
        expect(CurrencyFormatter.formatLargeAmount(25000.0, 'USD'), '\$25.0K');
      });

      test('should format millions with M suffix', () {
        expect(CurrencyFormatter.formatLargeAmount(1500000.0, 'USD'), '\$1.5M');
        expect(CurrencyFormatter.formatLargeAmount(25000000.0, 'USD'), '\$25.0M');
      });

      test('should format billions with B suffix', () {
        expect(CurrencyFormatter.formatLargeAmount(1500000000.0, 'USD'), '\$1.5B');
        expect(CurrencyFormatter.formatLargeAmount(25000000000.0, 'USD'), '\$25.0B');
      });

      test('should handle currency codes without symbols', () {
        expect(CurrencyFormatter.formatLargeAmount(1500.0, 'THB'), 'THB 1.5K');
        expect(CurrencyFormatter.formatLargeAmount(1500000.0, 'THB'), 'THB 1.5M');
      });
    });

    group('formatCompact', () {
      test('should format whole numbers without decimals', () {
        expect(CurrencyFormatter.formatCompact(45.0, 'USD'), '\$45');
        expect(CurrencyFormatter.formatCompact(100.0, 'EUR'), '€100');
      });

      test('should format non-whole numbers with decimals', () {
        expect(CurrencyFormatter.formatCompact(45.50, 'USD'), '\$45.50');
        expect(CurrencyFormatter.formatCompact(100.99, 'EUR'), '€100.99');
      });

      test('should handle JPY correctly (no decimals)', () {
        expect(CurrencyFormatter.formatCompact(1500.0, 'JPY'), '¥1500');
        expect(CurrencyFormatter.formatCompact(1500.50, 'JPY'), '¥1500');
      });

      test('should handle currency codes without symbols', () {
        expect(CurrencyFormatter.formatCompact(45.0, 'THB'), 'THB 45');
        expect(CurrencyFormatter.formatCompact(45.50, 'THB'), 'THB 45.50');
      });
    });

    group('formatForInput', () {
      test('should format amount for input fields', () {
        expect(CurrencyFormatter.formatForInput(45.20, 'USD'), '45.20');
        expect(CurrencyFormatter.formatForInput(1000.50, 'EUR'), '1000.50');
      });

      test('should handle JPY correctly (no decimals)', () {
        expect(CurrencyFormatter.formatForInput(1500, 'JPY'), '1500');
        expect(CurrencyFormatter.formatForInput(1500.99, 'JPY'), '1501');
      });
    });

    group('parseAmount', () {
      test('should parse formatted amounts correctly', () {
        expect(CurrencyFormatter.parseAmount('\$45.20'), 45.20);
        expect(CurrencyFormatter.parseAmount('€100.50'), 100.50);
        expect(CurrencyFormatter.parseAmount('¥1500'), 1500.0);
      });

      test('should parse currency codes', () {
        expect(CurrencyFormatter.parseAmount('THB 45.20'), 45.20);
        expect(CurrencyFormatter.parseAmount('USD 100.50'), 100.50);
      });

      test('should handle amounts with commas', () {
        expect(CurrencyFormatter.parseAmount('\$1,234.56'), 1234.56);
        expect(CurrencyFormatter.parseAmount('USD 10,000.00'), 10000.0);
      });

      test('should return null for invalid formats', () {
        expect(CurrencyFormatter.parseAmount('invalid'), null);
        expect(CurrencyFormatter.parseAmount(''), null);
        expect(CurrencyFormatter.parseAmount('abc123'), null);
      });
    });

    group('formatWithSeparators', () {
      test('should format amounts with thousand separators', () {
        expect(CurrencyFormatter.formatWithSeparators(1234.56, 'USD'), '\$1,234.56');
        expect(CurrencyFormatter.formatWithSeparators(1000000.0, 'EUR'), '€1,000,000.00');
      });

      test('should handle JPY correctly (no decimals)', () {
        expect(CurrencyFormatter.formatWithSeparators(1500000, 'JPY'), '¥1,500,000');
      });

      test('should handle currency codes without symbols', () {
        expect(CurrencyFormatter.formatWithSeparators(1234.56, 'THB'), 'THB 1,234.56');
      });

      test('should respect custom settings', () {
        final settings = CurrencySettings(decimalPlaces: 3);
        expect(CurrencyFormatter.formatWithSeparators(1234.56789, 'USD', settings: settings), '\$1,234.568');
      });
    });

    group('decimal and thousand separators', () {
      test('should return correct decimal separator', () {
        expect(CurrencyFormatter.getDecimalSeparator('USD'), '.');
        expect(CurrencyFormatter.getDecimalSeparator('EUR'), '.');
      });

      test('should return correct thousand separator', () {
        expect(CurrencyFormatter.getThousandSeparator('USD'), ',');
        expect(CurrencyFormatter.getThousandSeparator('EUR'), ',');
      });
    });

    group('edge cases', () {
      test('should handle zero amounts', () {
        expect(CurrencyFormatter.formatAmount(0.0, 'USD'), '\$0.00');
        expect(CurrencyFormatter.formatCompact(0.0, 'USD'), '\$0');
      });

      test('should handle very small amounts', () {
        expect(CurrencyFormatter.formatAmount(0.01, 'USD'), '\$0.01');
        expect(CurrencyFormatter.formatAmount(0.001, 'USD'), '\$0.00');
      });

      test('should handle case insensitive currency codes', () {
        expect(CurrencyFormatter.formatAmount(45.20, 'usd'), '\$45.20');
        expect(CurrencyFormatter.formatAmount(45.20, 'Eur'), '€45.20');
      });
    });
  });
}