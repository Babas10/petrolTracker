import '../models/currency/currency_conversion.dart';
import '../models/currency/currency_settings.dart';
import 'currency_validator.dart';

/// Utility class for formatting currency amounts and conversions
/// 
/// Provides static methods to format currency amounts with proper
/// symbols, decimal places, and cultural conventions.
class CurrencyFormatter {
  /// Format a currency amount with the appropriate symbol and decimal places
  /// 
  /// [amount] - The monetary amount to format
  /// [currency] - The 3-character currency code
  /// [settings] - Optional currency settings for customization
  static String formatAmount(
    double amount, 
    String currency, {
    CurrencySettings? settings,
    int? customDecimalPlaces,
  }) {
    final currencyCode = currency.toUpperCase();
    final decimals = customDecimalPlaces ?? 
                    (settings?.decimalPlaces) ?? 
                    CurrencyValidator.getDecimalPlaces(currencyCode);
    
    final symbol = CurrencyValidator.getCurrencySymbol(currencyCode);
    final formattedAmount = amount.toStringAsFixed(decimals);
    
    // Handle currencies with symbols vs currency codes
    if (CurrencyValidator.hasSymbol(currencyCode)) {
      return '$symbol$formattedAmount';
    } else {
      return '$currencyCode $formattedAmount';
    }
  }

  /// Format a currency conversion for display
  /// 
  /// Example output: "€50.00 → $45.20 (rate: 0.904)"
  static String formatConversion(
    CurrencyConversion conversion, {
    bool showRate = true,
    CurrencySettings? settings,
  }) {
    final originalStr = formatAmount(
      conversion.originalAmount, 
      conversion.originalCurrency,
      settings: settings,
    );
    
    final convertedStr = formatAmount(
      conversion.convertedAmount, 
      conversion.targetCurrency,
      settings: settings,
    );
    
    if (!showRate || settings?.showExchangeRates == false) {
      return '$originalStr → $convertedStr';
    }
    
    final rateStr = conversion.exchangeRate.toStringAsFixed(4);
    return '$originalStr → $convertedStr (rate: $rateStr)';
  }

  /// Format amount with original and converted values
  /// 
  /// Example: "€50.00 ($45.20)" or just "$45.20" if showOriginal is false
  static String formatWithOriginal(
    double convertedAmount,
    String convertedCurrency, {
    double? originalAmount,
    String? originalCurrency,
    bool showOriginal = true,
    CurrencySettings? settings,
  }) {
    final convertedStr = formatAmount(
      convertedAmount, 
      convertedCurrency,
      settings: settings,
    );
    
    if (!showOriginal || 
        originalAmount == null || 
        originalCurrency == null ||
        settings?.showOriginalAmounts == false) {
      return convertedStr;
    }
    
    final originalStr = formatAmount(
      originalAmount, 
      originalCurrency,
      settings: settings,
    );
    
    return '$originalStr ($convertedStr)';
  }

  /// Format an exchange rate for display
  /// 
  /// Example: "1 USD = 0.8542 EUR"
  static String formatExchangeRate(
    String baseCurrency, 
    String targetCurrency, 
    double rate, {
    int decimals = 4,
  }) {
    return '1 $baseCurrency = ${rate.toStringAsFixed(decimals)} $targetCurrency';
  }

  /// Format price per unit with currency
  /// 
  /// Example: "$1.45/L" for fuel price per liter
  static String formatPricePerUnit(
    double pricePerUnit, 
    String currency, 
    String unit, {
    CurrencySettings? settings,
  }) {
    final priceStr = formatAmount(pricePerUnit, currency, settings: settings);
    return '$priceStr/$unit';
  }

  /// Format a range of amounts
  /// 
  /// Example: "$45.20 - $52.80"
  static String formatRange(
    double minAmount, 
    double maxAmount, 
    String currency, {
    CurrencySettings? settings,
  }) {
    final minStr = formatAmount(minAmount, currency, settings: settings);
    final maxStr = formatAmount(maxAmount, currency, settings: settings);
    return '$minStr - $maxStr';
  }

  /// Format percentage change in currency value
  /// 
  /// Example: "+15.2%" or "-8.7%"
  static String formatPercentageChange(double percentage) {
    final sign = percentage >= 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(1)}%';
  }

  /// Format large amounts with appropriate suffixes (K, M, B)
  /// 
  /// Example: "$1.5M" instead of "$1,500,000.00"
  static String formatLargeAmount(
    double amount, 
    String currency, {
    CurrencySettings? settings,
  }) {
    if (amount < 1000) {
      return formatAmount(amount, currency, settings: settings);
    }
    
    final symbol = CurrencyValidator.getCurrencySymbol(currency);
    final hasSymbol = CurrencyValidator.hasSymbol(currency);
    
    String suffix;
    double scaledAmount;
    
    if (amount >= 1000000000) {
      suffix = 'B';
      scaledAmount = amount / 1000000000;
    } else if (amount >= 1000000) {
      suffix = 'M';
      scaledAmount = amount / 1000000;
    } else {
      suffix = 'K';
      scaledAmount = amount / 1000;
    }
    
    final formattedAmount = scaledAmount.toStringAsFixed(1);
    
    if (hasSymbol) {
      return '$symbol$formattedAmount$suffix';
    } else {
      return '$currency $formattedAmount$suffix';
    }
  }

  /// Format currency for compact display (minimal characters)
  /// 
  /// Example: "$45" instead of "$45.00" for whole numbers
  static String formatCompact(
    double amount, 
    String currency, {
    CurrencySettings? settings,
  }) {
    final currencyCode = currency.toUpperCase();
    final symbol = CurrencyValidator.getCurrencySymbol(currencyCode);
    final hasSymbol = CurrencyValidator.hasSymbol(currencyCode);
    
    // For whole numbers, don't show decimals
    if (amount == amount.truncateToDouble()) {
      final wholeAmount = amount.toInt().toString();
      return hasSymbol ? '$symbol$wholeAmount' : '$currencyCode $wholeAmount';
    }
    
    // For non-whole numbers, use minimal decimals
    final decimals = CurrencyValidator.usesDecimalPlaces(currencyCode) ? 2 : 0;
    final formattedAmount = amount.toStringAsFixed(decimals);
    
    return hasSymbol ? '$symbol$formattedAmount' : '$currencyCode $formattedAmount';
  }

  /// Format currency amount for input fields (no currency symbol)
  /// 
  /// Example: "45.20" for use in text input fields
  static String formatForInput(double amount, String currency) {
    final decimals = CurrencyValidator.getDecimalPlaces(currency);
    return amount.toStringAsFixed(decimals);
  }

  /// Parse a formatted currency string back to amount
  /// 
  /// Example: "$45.20" → 45.20
  static double? parseAmount(String formattedAmount) {
    try {
      // Remove common currency symbols and spaces
      final cleanAmount = formattedAmount
          .replaceAll(RegExp(r'[\$€£¥₩₹₽₺]'), '')
          .replaceAll(RegExp(r'[A-Z]{3}'), '') // Remove 3-letter codes
          .replaceAll(RegExp(r'[,\s]'), '')    // Remove commas and spaces
          .trim();
      
      return double.parse(cleanAmount);
    } catch (e) {
      return null;
    }
  }

  /// Get localized decimal separator based on currency
  /// 
  /// Most currencies use '.', but some regions use ','
  static String getDecimalSeparator(String currency) {
    // This is a simplified implementation
    // In a real app, you'd use proper localization
    return '.';
  }

  /// Get localized thousand separator based on currency
  /// 
  /// Most currencies use ',', but some regions use '.' or space
  static String getThousandSeparator(String currency) {
    // This is a simplified implementation
    // In a real app, you'd use proper localization
    return ',';
  }

  /// Format amount with thousand separators
  /// 
  /// Example: "$1,234.56"
  static String formatWithSeparators(
    double amount, 
    String currency, {
    CurrencySettings? settings,
  }) {
    final currencyCode = currency.toUpperCase();
    final decimals = settings?.decimalPlaces ?? 
                    CurrencyValidator.getDecimalPlaces(currencyCode);
    final symbol = CurrencyValidator.getCurrencySymbol(currencyCode);
    final hasSymbol = CurrencyValidator.hasSymbol(currencyCode);
    
    // Split into integer and decimal parts
    final parts = amount.toStringAsFixed(decimals).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';
    
    // Add thousand separators to integer part
    final formattedInteger = _addThousandSeparators(integerPart);
    
    // Combine parts
    final formattedAmount = decimals > 0 
        ? '$formattedInteger.${decimalPart.padRight(decimals, '0')}'
        : formattedInteger;
    
    return hasSymbol 
        ? '$symbol$formattedAmount'
        : '$currencyCode $formattedAmount';
  }

  /// Helper method to add thousand separators
  static String _addThousandSeparators(String number) {
    final reversed = number.split('').reversed.join();
    final withSeparators = reversed.replaceAllMapped(
      RegExp(r'(\d{3})(?=\d)'),
      (match) => '${match.group(1)},',
    );
    return withSeparators.split('').reversed.join();
  }
}