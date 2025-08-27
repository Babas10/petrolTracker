import 'package:drift/drift.dart';
import 'package:petrol_tracker/database/database.dart';

/// Model class for maintenance log entries
/// 
/// Represents a maintenance activity performed on a vehicle with all associated details.
class MaintenanceLogModel {
  final int? id;
  final int vehicleId;
  final int categoryId;
  final String title;
  final String? description;
  final DateTime serviceDate;
  final double odometerReading;
  final String? serviceProvider;
  final double partsCost;
  final double laborCost;
  final double totalCost;
  final String currency;
  final double? laborHours;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MaintenanceLogModel({
    this.id,
    required this.vehicleId,
    required this.categoryId,
    required this.title,
    this.description,
    required this.serviceDate,
    required this.odometerReading,
    this.serviceProvider,
    this.partsCost = 0.0,
    this.laborCost = 0.0,
    this.totalCost = 0.0,
    this.currency = 'USD',
    this.laborHours,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create model from database entity
  factory MaintenanceLogModel.fromEntity(MaintenanceLog entity) {
    return MaintenanceLogModel(
      id: entity.id,
      vehicleId: entity.vehicleId,
      categoryId: entity.categoryId,
      title: entity.title,
      description: entity.description,
      serviceDate: entity.serviceDate,
      odometerReading: entity.odometerReading,
      serviceProvider: entity.serviceProvider,
      partsCost: entity.partsCost,
      laborCost: entity.laborCost,
      totalCost: entity.totalCost,
      currency: entity.currency,
      laborHours: entity.laborHours,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert model to database companion for insert/update
  MaintenanceLogsCompanion toCompanion() {
    return MaintenanceLogsCompanion.insert(
      vehicleId: vehicleId,
      categoryId: categoryId,
      title: title,
      description: Value.absentIfNull(description),
      serviceDate: serviceDate,
      odometerReading: odometerReading,
      serviceProvider: Value.absentIfNull(serviceProvider),
      partsCost: Value(partsCost),
      laborCost: Value(laborCost),
      totalCost: Value(totalCost),
      currency: Value(currency),
      laborHours: Value.absentIfNull(laborHours),
      notes: Value.absentIfNull(notes),
      updatedAt: Value(DateTime.now()),
    );
  }

  /// Create a copy with updated values
  MaintenanceLogModel copyWith({
    int? id,
    int? vehicleId,
    int? categoryId,
    String? title,
    String? description,
    DateTime? serviceDate,
    double? odometerReading,
    String? serviceProvider,
    double? partsCost,
    double? laborCost,
    double? totalCost,
    String? currency,
    double? laborHours,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MaintenanceLogModel(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      serviceDate: serviceDate ?? this.serviceDate,
      odometerReading: odometerReading ?? this.odometerReading,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      partsCost: partsCost ?? this.partsCost,
      laborCost: laborCost ?? this.laborCost,
      totalCost: totalCost ?? this.totalCost,
      currency: currency ?? this.currency,
      laborHours: laborHours ?? this.laborHours,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MaintenanceLogModel &&
        other.id == id &&
        other.vehicleId == vehicleId &&
        other.categoryId == categoryId &&
        other.title == title &&
        other.description == description &&
        other.serviceDate == serviceDate &&
        other.odometerReading == odometerReading &&
        other.serviceProvider == serviceProvider &&
        other.partsCost == partsCost &&
        other.laborCost == laborCost &&
        other.totalCost == totalCost &&
        other.currency == currency &&
        other.laborHours == laborHours &&
        other.notes == notes;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      vehicleId,
      categoryId,
      title,
      description,
      serviceDate,
      odometerReading,
      serviceProvider,
      partsCost,
      laborCost,
      totalCost,
      currency,
      laborHours,
      notes,
    );
  }

  @override
  String toString() {
    return 'MaintenanceLogModel(id: $id, vehicleId: $vehicleId, title: $title, serviceDate: $serviceDate, totalCost: $totalCost)';
  }
}