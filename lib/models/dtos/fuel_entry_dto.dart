import 'package:json_annotation/json_annotation.dart';

part 'fuel_entry_dto.g.dart';

/// DTO for FuelEntry API communication with multi-currency support
/// 
/// This DTO handles JSON serialization/deserialization for fuel entries
/// when communicating with REST APIs or external services.
@JsonSerializable()
class FuelEntryDto {
  /// Entry ID (null for new entries)
  final int? id;
  
  /// Vehicle ID this entry belongs to
  @JsonKey(name: 'vehicle_id')
  final int vehicleId;
  
  /// Date of fuel purchase (ISO 8601 format)
  final DateTime date;
  
  /// Current odometer reading in kilometers
  @JsonKey(name: 'current_km')
  final double currentKm;
  
  /// Amount of fuel purchased in liters
  @JsonKey(name: 'fuel_amount')
  final double fuelAmount;
  
  /// Total price paid (in primary currency after conversion)
  final double price;
  
  /// Original amount paid in local currency (if different from price)
  @JsonKey(name: 'original_amount')
  final double? originalAmount;
  
  /// Currency code for the transaction (3-character ISO 4217)
  final String currency;
  
  /// Country where fuel was purchased
  final String country;
  
  /// Price per liter (calculated or manually entered)
  @JsonKey(name: 'price_per_liter')
  final double pricePerLiter;
  
  /// Calculated fuel consumption in L/100km
  final double? consumption;
  
  /// Whether this was a full tank fill-up
  @JsonKey(name: 'is_full_tank')
  final bool isFullTank;
  
  /// Exchange rate used for conversion (if applicable)
  @JsonKey(name: 'exchange_rate')
  final double? exchangeRate;
  
  /// Date when exchange rate was effective
  @JsonKey(name: 'rate_date')
  final DateTime? rateDate;
  
  /// Timestamp when entry was created
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  
  /// Timestamp when entry was last updated
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  const FuelEntryDto({
    this.id,
    required this.vehicleId,
    required this.date,
    required this.currentKm,
    required this.fuelAmount,
    required this.price,
    this.originalAmount,
    this.currency = 'USD',
    required this.country,
    required this.pricePerLiter,
    this.consumption,
    this.isFullTank = true,
    this.exchangeRate,
    this.rateDate,
    this.createdAt,
    this.updatedAt,
  });

  /// Create from JSON (API response)
  factory FuelEntryDto.fromJson(Map<String, dynamic> json) => 
      _$FuelEntryDtoFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$FuelEntryDtoToJson(this);
}

/// Extension methods for FuelEntryDto business logic
extension FuelEntryDtoExtension on FuelEntryDto {
  /// Check if this entry represents a currency conversion
  bool get isConverted => originalAmount != null && originalAmount != price;
  
  /// Get the effective price (original or converted)
  double get effectivePrice => originalAmount ?? price;
  
  /// Get formatted price with currency
  String get formattedPrice {
    if (isConverted && originalAmount != null) {
      return '${originalAmount!.toStringAsFixed(2)} $currency (≈\$${price.toStringAsFixed(2)})';
    }
    return '${price.toStringAsFixed(2)} $currency';
  }
  
  /// Get formatted consumption or 'N/A' if not available
  String get formattedConsumption {
    if (consumption == null) return 'N/A';
    return '${consumption!.toStringAsFixed(1)} L/100km';
  }
  
  /// Get formatted fuel amount
  String get formattedFuelAmount => '${fuelAmount.toStringAsFixed(1)}L';
  
  /// Get formatted price per liter
  String get formattedPricePerLiter => '${pricePerLiter.toStringAsFixed(3)}/$currency/L';
  
  /// Calculate total cost including conversion info
  String get totalCostSummary {
    if (!isConverted) {
      return '${price.toStringAsFixed(2)} $currency';
    }
    
    final rateInfo = exchangeRate != null ? ' @ ${exchangeRate!.toStringAsFixed(4)}' : '';
    return '${originalAmount!.toStringAsFixed(2)} $currency → \$${price.toStringAsFixed(2)}$rateInfo';
  }
  
  /// Validate that this DTO has valid data
  bool get isValid {
    return vehicleId > 0 &&
           currentKm >= 0 &&
           fuelAmount > 0 &&
           price > 0 &&
           currency.length == 3 &&
           country.isNotEmpty &&
           pricePerLiter > 0 &&
           (originalAmount == null || originalAmount! > 0) &&
           (exchangeRate == null || exchangeRate! > 0);
  }
  
  /// Get list of validation errors
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (vehicleId <= 0) errors.add('Vehicle ID must be positive');
    if (currentKm < 0) errors.add('Current km cannot be negative');
    if (fuelAmount <= 0) errors.add('Fuel amount must be positive');
    if (price <= 0) errors.add('Price must be positive');
    if (currency.length != 3) errors.add('Currency must be 3 characters');
    if (country.isEmpty) errors.add('Country is required');
    if (pricePerLiter <= 0) errors.add('Price per liter must be positive');
    if (originalAmount != null && originalAmount! <= 0) errors.add('Original amount must be positive');
    if (exchangeRate != null && exchangeRate! <= 0) errors.add('Exchange rate must be positive');
    
    return errors;
  }
  
  /// Get entry type description
  String get entryType {
    if (isConverted) return 'Multi-currency entry';
    if (isFullTank) return 'Full tank';
    return 'Partial fill';
  }
  
  /// Get age of this entry in days
  int get ageInDays {
    final now = DateTime.now();
    return now.difference(date).inDays;
  }
  
  /// Check if this is a recent entry (within last 7 days)
  bool get isRecent => ageInDays <= 7;
  
  /// Get efficiency rating based on consumption
  String get efficiencyRating {
    if (consumption == null) return 'Unknown';
    
    if (consumption! <= 5.0) return 'Excellent';
    if (consumption! <= 7.0) return 'Good';
    if (consumption! <= 9.0) return 'Average';
    if (consumption! <= 12.0) return 'Poor';
    return 'Very Poor';
  }
  
  /// Get cost efficiency (currency per km)
  double? get costPerKm {
    // This would require previous entry data to calculate distance
    // For now, return null as it requires additional context
    return null;
  }
  
  /// Create a summary string for this entry
  String get summary {
    return 'Vehicle $vehicleId: ${formattedFuelAmount} at ${formattedPrice} '
           '(${formattedPricePerLiter}) on ${date.toIso8601String().split('T')[0]} '
           'in $country';
  }
}