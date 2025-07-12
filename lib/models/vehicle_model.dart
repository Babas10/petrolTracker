import 'package:drift/drift.dart';
import 'package:petrol_tracker/database/database.dart';

/// Data model for Vehicle with validation and business logic
class VehicleModel {
  final int? id;
  final String name;
  final double initialKm;
  final DateTime createdAt;

  const VehicleModel({
    this.id,
    required this.name,
    required this.initialKm,
    required this.createdAt,
  });

  /// Creates a VehicleModel from a Drift Vehicle entity
  factory VehicleModel.fromEntity(Vehicle entity) {
    return VehicleModel(
      id: entity.id,
      name: entity.name,
      initialKm: entity.initialKm,
      createdAt: entity.createdAt,
    );
  }

  /// Creates a VehicleModel for new vehicle creation
  factory VehicleModel.create({
    required String name,
    required double initialKm,
  }) {
    return VehicleModel(
      name: name,
      initialKm: initialKm,
      createdAt: DateTime.now(),
    );
  }

  /// Converts to Drift VehiclesCompanion for database operations
  VehiclesCompanion toCompanion() {
    return VehiclesCompanion.insert(
      name: name,
      initialKm: initialKm,
      createdAt: Value(createdAt),
    );
  }

  /// Converts to Drift VehiclesCompanion for updates
  VehiclesCompanion toUpdateCompanion() {
    return VehiclesCompanion(
      id: Value(id!),
      name: Value(name),
      initialKm: Value(initialKm),
      createdAt: Value(createdAt),
    );
  }

  /// Validates vehicle data
  List<String> validate() {
    final errors = <String>[];

    // Name validation
    if (name.trim().isEmpty) {
      errors.add('Vehicle name is required');
    } else if (name.trim().length < 2) {
      errors.add('Vehicle name must be at least 2 characters long');
    } else if (name.trim().length > 100) {
      errors.add('Vehicle name must be less than 100 characters');
    }

    // Initial km validation
    if (initialKm < 0) {
      errors.add('Initial kilometers must be 0 or greater');
    }

    return errors;
  }

  /// Returns true if the vehicle data is valid
  bool get isValid => validate().isEmpty;

  /// Creates a copy with updated values
  VehicleModel copyWith({
    int? id,
    String? name,
    double? initialKm,
    DateTime? createdAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      initialKm: initialKm ?? this.initialKm,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VehicleModel &&
        other.id == id &&
        other.name == name &&
        other.initialKm == initialKm &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, name, initialKm, createdAt);
  }

  @override
  String toString() {
    return 'VehicleModel(id: $id, name: $name, initialKm: $initialKm, createdAt: $createdAt)';
  }
}