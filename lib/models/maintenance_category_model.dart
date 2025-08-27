import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'package:petrol_tracker/database/database.dart';

/// Model class for maintenance categories
/// 
/// Represents a category of maintenance activities with visual styling.
class MaintenanceCategoryModel {
  final int? id;
  final String name;
  final String iconName;
  final String color;
  final bool isSystem;
  final DateTime createdAt;

  const MaintenanceCategoryModel({
    this.id,
    required this.name,
    required this.iconName,
    required this.color,
    this.isSystem = false,
    required this.createdAt,
  });

  /// Create model from database entity
  factory MaintenanceCategoryModel.fromEntity(MaintenanceCategory entity) {
    return MaintenanceCategoryModel(
      id: entity.id,
      name: entity.name,
      iconName: entity.iconName,
      color: entity.color,
      isSystem: entity.isSystem,
      createdAt: entity.createdAt,
    );
  }

  /// Convert model to database companion for insert/update
  MaintenanceCategoriesCompanion toCompanion() {
    return MaintenanceCategoriesCompanion.insert(
      name: name,
      iconName: iconName,
      color: color,
      isSystem: Value(isSystem),
    );
  }

  /// Get the Flutter icon for this category
  IconData get icon {
    switch (iconName) {
      case 'local_car_wash':
        return Icons.local_car_wash;
      case 'filter_alt':
        return Icons.filter_alt;
      case 'settings':
        return Icons.settings;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'tire_repair':
        return Icons.tire_repair;
      case 'speed':
        return Icons.speed;
      case 'car_repair':
        return Icons.car_repair;
      case 'search':
        return Icons.search;
      case 'cleaning_services':
        return Icons.cleaning_services;
      case 'build':
        return Icons.build;
      default:
        return Icons.build;
    }
  }

  /// Get the Flutter color for this category
  Color get colorValue {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }

  /// Create a copy with updated values
  MaintenanceCategoryModel copyWith({
    int? id,
    String? name,
    String? iconName,
    String? color,
    bool? isSystem,
    DateTime? createdAt,
  }) {
    return MaintenanceCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MaintenanceCategoryModel &&
        other.id == id &&
        other.name == name &&
        other.iconName == iconName &&
        other.color == color &&
        other.isSystem == isSystem;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      iconName,
      color,
      isSystem,
    );
  }

  @override
  String toString() {
    return 'MaintenanceCategoryModel(id: $id, name: $name, isSystem: $isSystem)';
  }
}