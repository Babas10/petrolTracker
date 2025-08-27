// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $VehiclesTable extends Vehicles with TableInfo<$VehiclesTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialKmMeta = const VerificationMeta(
    'initialKm',
  );
  @override
  late final GeneratedColumn<double> initialKm = GeneratedColumn<double>(
    'initial_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, initialKm, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vehicle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('initial_km')) {
      context.handle(
        _initialKmMeta,
        initialKm.isAcceptableOrUnknown(data['initial_km']!, _initialKmMeta),
      );
    } else if (isInserting) {
      context.missing(_initialKmMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      initialKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}initial_km'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  /// Primary key - auto-incrementing integer
  final int id;

  /// Name/description of the vehicle (e.g., "Honda Civic 2020", "Work Car")
  /// Must not be empty and should be unique per user
  final String name;

  /// Initial kilometer reading when the vehicle was added to tracking
  /// This is used as a baseline for consumption calculations
  final double initialKm;

  /// When this vehicle record was created
  final DateTime createdAt;
  const Vehicle({
    required this.id,
    required this.name,
    required this.initialKm,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['initial_km'] = Variable<double>(initialKm);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      name: Value(name),
      initialKm: Value(initialKm),
      createdAt: Value(createdAt),
    );
  }

  factory Vehicle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      initialKm: serializer.fromJson<double>(json['initialKm']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'initialKm': serializer.toJson<double>(initialKm),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Vehicle copyWith({
    int? id,
    String? name,
    double? initialKm,
    DateTime? createdAt,
  }) => Vehicle(
    id: id ?? this.id,
    name: name ?? this.name,
    initialKm: initialKm ?? this.initialKm,
    createdAt: createdAt ?? this.createdAt,
  );
  Vehicle copyWithCompanion(VehiclesCompanion data) {
    return Vehicle(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      initialKm: data.initialKm.present ? data.initialKm.value : this.initialKm,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('initialKm: $initialKm, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, initialKm, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.id == this.id &&
          other.name == this.name &&
          other.initialKm == this.initialKm &&
          other.createdAt == this.createdAt);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> initialKm;
  final Value<DateTime> createdAt;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.initialKm = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VehiclesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double initialKm,
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       initialKm = Value(initialKm);
  static Insertable<Vehicle> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? initialKm,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (initialKm != null) 'initial_km': initialKm,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VehiclesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? initialKm,
    Value<DateTime>? createdAt,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      initialKm: initialKm ?? this.initialKm,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (initialKm.present) {
      map['initial_km'] = Variable<double>(initialKm.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('initialKm: $initialKm, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FuelEntriesTable extends FuelEntries
    with TableInfo<$FuelEntriesTable, FuelEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FuelEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentKmMeta = const VerificationMeta(
    'currentKm',
  );
  @override
  late final GeneratedColumn<double> currentKm = GeneratedColumn<double>(
    'current_km',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fuelAmountMeta = const VerificationMeta(
    'fuelAmount',
  );
  @override
  late final GeneratedColumn<double> fuelAmount = GeneratedColumn<double>(
    'fuel_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerLiterMeta = const VerificationMeta(
    'pricePerLiter',
  );
  @override
  late final GeneratedColumn<double> pricePerLiter = GeneratedColumn<double>(
    'price_per_liter',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consumptionMeta = const VerificationMeta(
    'consumption',
  );
  @override
  late final GeneratedColumn<double> consumption = GeneratedColumn<double>(
    'consumption',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFullTankMeta = const VerificationMeta(
    'isFullTank',
  );
  @override
  late final GeneratedColumn<bool> isFullTank = GeneratedColumn<bool>(
    'is_full_tank',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_full_tank" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    date,
    currentKm,
    fuelAmount,
    price,
    country,
    pricePerLiter,
    consumption,
    isFullTank,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fuel_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<FuelEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('current_km')) {
      context.handle(
        _currentKmMeta,
        currentKm.isAcceptableOrUnknown(data['current_km']!, _currentKmMeta),
      );
    } else if (isInserting) {
      context.missing(_currentKmMeta);
    }
    if (data.containsKey('fuel_amount')) {
      context.handle(
        _fuelAmountMeta,
        fuelAmount.isAcceptableOrUnknown(data['fuel_amount']!, _fuelAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_fuelAmountMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    } else if (isInserting) {
      context.missing(_countryMeta);
    }
    if (data.containsKey('price_per_liter')) {
      context.handle(
        _pricePerLiterMeta,
        pricePerLiter.isAcceptableOrUnknown(
          data['price_per_liter']!,
          _pricePerLiterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerLiterMeta);
    }
    if (data.containsKey('consumption')) {
      context.handle(
        _consumptionMeta,
        consumption.isAcceptableOrUnknown(
          data['consumption']!,
          _consumptionMeta,
        ),
      );
    }
    if (data.containsKey('is_full_tank')) {
      context.handle(
        _isFullTankMeta,
        isFullTank.isAcceptableOrUnknown(
          data['is_full_tank']!,
          _isFullTankMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FuelEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FuelEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      currentKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}current_km'],
      )!,
      fuelAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fuel_amount'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      )!,
      pricePerLiter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_per_liter'],
      )!,
      consumption: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}consumption'],
      ),
      isFullTank: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_full_tank'],
      )!,
    );
  }

  @override
  $FuelEntriesTable createAlias(String alias) {
    return $FuelEntriesTable(attachedDatabase, alias);
  }
}

class FuelEntry extends DataClass implements Insertable<FuelEntry> {
  /// Primary key - auto-incrementing integer
  final int id;

  /// Foreign key reference to the vehicle this entry belongs to
  final int vehicleId;

  /// Date and time when the fuel was purchased
  final DateTime date;

  /// Current odometer reading at the time of fuel purchase (in kilometers)
  /// Must be greater than or equal to the previous entry for the same vehicle
  final double currentKm;

  /// Amount of fuel purchased (in liters)
  /// Must be a positive number
  final double fuelAmount;

  /// Total price paid for the fuel purchase
  /// Must be a positive number
  final double price;

  /// Country where the fuel was purchased
  /// Used for price comparison analysis
  final String country;

  /// Price per liter (calculated or manually entered)
  /// Usually calculated as price / fuelAmount but can be overridden
  final double pricePerLiter;

  /// Calculated fuel consumption in L/100km
  /// This is calculated based on the distance traveled since the last entry
  /// and the fuel amount for this entry. Can be null for the first entry.
  final double? consumption;

  /// Indicates whether this was a full tank fill-up or a partial refuel
  /// Used for accurate consumption calculation - only full-to-full periods are used
  /// First entry for a vehicle must always be a full tank
  final bool isFullTank;
  const FuelEntry({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.currentKm,
    required this.fuelAmount,
    required this.price,
    required this.country,
    required this.pricePerLiter,
    this.consumption,
    required this.isFullTank,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['date'] = Variable<DateTime>(date);
    map['current_km'] = Variable<double>(currentKm);
    map['fuel_amount'] = Variable<double>(fuelAmount);
    map['price'] = Variable<double>(price);
    map['country'] = Variable<String>(country);
    map['price_per_liter'] = Variable<double>(pricePerLiter);
    if (!nullToAbsent || consumption != null) {
      map['consumption'] = Variable<double>(consumption);
    }
    map['is_full_tank'] = Variable<bool>(isFullTank);
    return map;
  }

  FuelEntriesCompanion toCompanion(bool nullToAbsent) {
    return FuelEntriesCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      date: Value(date),
      currentKm: Value(currentKm),
      fuelAmount: Value(fuelAmount),
      price: Value(price),
      country: Value(country),
      pricePerLiter: Value(pricePerLiter),
      consumption: consumption == null && nullToAbsent
          ? const Value.absent()
          : Value(consumption),
      isFullTank: Value(isFullTank),
    );
  }

  factory FuelEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FuelEntry(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      date: serializer.fromJson<DateTime>(json['date']),
      currentKm: serializer.fromJson<double>(json['currentKm']),
      fuelAmount: serializer.fromJson<double>(json['fuelAmount']),
      price: serializer.fromJson<double>(json['price']),
      country: serializer.fromJson<String>(json['country']),
      pricePerLiter: serializer.fromJson<double>(json['pricePerLiter']),
      consumption: serializer.fromJson<double?>(json['consumption']),
      isFullTank: serializer.fromJson<bool>(json['isFullTank']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'date': serializer.toJson<DateTime>(date),
      'currentKm': serializer.toJson<double>(currentKm),
      'fuelAmount': serializer.toJson<double>(fuelAmount),
      'price': serializer.toJson<double>(price),
      'country': serializer.toJson<String>(country),
      'pricePerLiter': serializer.toJson<double>(pricePerLiter),
      'consumption': serializer.toJson<double?>(consumption),
      'isFullTank': serializer.toJson<bool>(isFullTank),
    };
  }

  FuelEntry copyWith({
    int? id,
    int? vehicleId,
    DateTime? date,
    double? currentKm,
    double? fuelAmount,
    double? price,
    String? country,
    double? pricePerLiter,
    Value<double?> consumption = const Value.absent(),
    bool? isFullTank,
  }) => FuelEntry(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    date: date ?? this.date,
    currentKm: currentKm ?? this.currentKm,
    fuelAmount: fuelAmount ?? this.fuelAmount,
    price: price ?? this.price,
    country: country ?? this.country,
    pricePerLiter: pricePerLiter ?? this.pricePerLiter,
    consumption: consumption.present ? consumption.value : this.consumption,
    isFullTank: isFullTank ?? this.isFullTank,
  );
  FuelEntry copyWithCompanion(FuelEntriesCompanion data) {
    return FuelEntry(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      date: data.date.present ? data.date.value : this.date,
      currentKm: data.currentKm.present ? data.currentKm.value : this.currentKm,
      fuelAmount: data.fuelAmount.present
          ? data.fuelAmount.value
          : this.fuelAmount,
      price: data.price.present ? data.price.value : this.price,
      country: data.country.present ? data.country.value : this.country,
      pricePerLiter: data.pricePerLiter.present
          ? data.pricePerLiter.value
          : this.pricePerLiter,
      consumption: data.consumption.present
          ? data.consumption.value
          : this.consumption,
      isFullTank: data.isFullTank.present
          ? data.isFullTank.value
          : this.isFullTank,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FuelEntry(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('date: $date, ')
          ..write('currentKm: $currentKm, ')
          ..write('fuelAmount: $fuelAmount, ')
          ..write('price: $price, ')
          ..write('country: $country, ')
          ..write('pricePerLiter: $pricePerLiter, ')
          ..write('consumption: $consumption, ')
          ..write('isFullTank: $isFullTank')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    date,
    currentKm,
    fuelAmount,
    price,
    country,
    pricePerLiter,
    consumption,
    isFullTank,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FuelEntry &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.date == this.date &&
          other.currentKm == this.currentKm &&
          other.fuelAmount == this.fuelAmount &&
          other.price == this.price &&
          other.country == this.country &&
          other.pricePerLiter == this.pricePerLiter &&
          other.consumption == this.consumption &&
          other.isFullTank == this.isFullTank);
}

class FuelEntriesCompanion extends UpdateCompanion<FuelEntry> {
  final Value<int> id;
  final Value<int> vehicleId;
  final Value<DateTime> date;
  final Value<double> currentKm;
  final Value<double> fuelAmount;
  final Value<double> price;
  final Value<String> country;
  final Value<double> pricePerLiter;
  final Value<double?> consumption;
  final Value<bool> isFullTank;
  const FuelEntriesCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.date = const Value.absent(),
    this.currentKm = const Value.absent(),
    this.fuelAmount = const Value.absent(),
    this.price = const Value.absent(),
    this.country = const Value.absent(),
    this.pricePerLiter = const Value.absent(),
    this.consumption = const Value.absent(),
    this.isFullTank = const Value.absent(),
  });
  FuelEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int vehicleId,
    required DateTime date,
    required double currentKm,
    required double fuelAmount,
    required double price,
    required String country,
    required double pricePerLiter,
    this.consumption = const Value.absent(),
    this.isFullTank = const Value.absent(),
  }) : vehicleId = Value(vehicleId),
       date = Value(date),
       currentKm = Value(currentKm),
       fuelAmount = Value(fuelAmount),
       price = Value(price),
       country = Value(country),
       pricePerLiter = Value(pricePerLiter);
  static Insertable<FuelEntry> custom({
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<DateTime>? date,
    Expression<double>? currentKm,
    Expression<double>? fuelAmount,
    Expression<double>? price,
    Expression<String>? country,
    Expression<double>? pricePerLiter,
    Expression<double>? consumption,
    Expression<bool>? isFullTank,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (date != null) 'date': date,
      if (currentKm != null) 'current_km': currentKm,
      if (fuelAmount != null) 'fuel_amount': fuelAmount,
      if (price != null) 'price': price,
      if (country != null) 'country': country,
      if (pricePerLiter != null) 'price_per_liter': pricePerLiter,
      if (consumption != null) 'consumption': consumption,
      if (isFullTank != null) 'is_full_tank': isFullTank,
    });
  }

  FuelEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? vehicleId,
    Value<DateTime>? date,
    Value<double>? currentKm,
    Value<double>? fuelAmount,
    Value<double>? price,
    Value<String>? country,
    Value<double>? pricePerLiter,
    Value<double?>? consumption,
    Value<bool>? isFullTank,
  }) {
    return FuelEntriesCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      currentKm: currentKm ?? this.currentKm,
      fuelAmount: fuelAmount ?? this.fuelAmount,
      price: price ?? this.price,
      country: country ?? this.country,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      consumption: consumption ?? this.consumption,
      isFullTank: isFullTank ?? this.isFullTank,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (currentKm.present) {
      map['current_km'] = Variable<double>(currentKm.value);
    }
    if (fuelAmount.present) {
      map['fuel_amount'] = Variable<double>(fuelAmount.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (pricePerLiter.present) {
      map['price_per_liter'] = Variable<double>(pricePerLiter.value);
    }
    if (consumption.present) {
      map['consumption'] = Variable<double>(consumption.value);
    }
    if (isFullTank.present) {
      map['is_full_tank'] = Variable<bool>(isFullTank.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FuelEntriesCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('date: $date, ')
          ..write('currentKm: $currentKm, ')
          ..write('fuelAmount: $fuelAmount, ')
          ..write('price: $price, ')
          ..write('country: $country, ')
          ..write('pricePerLiter: $pricePerLiter, ')
          ..write('consumption: $consumption, ')
          ..write('isFullTank: $isFullTank')
          ..write(')'))
        .toString();
  }
}

class $MaintenanceCategoriesTable extends MaintenanceCategories
    with TableInfo<$MaintenanceCategoriesTable, MaintenanceCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenanceCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 7,
      maxTextLength: 7,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconName,
    color,
    isSystem,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenance_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaintenanceCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    } else if (isInserting) {
      context.missing(_iconNameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaintenanceCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenanceCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MaintenanceCategoriesTable createAlias(String alias) {
    return $MaintenanceCategoriesTable(attachedDatabase, alias);
  }
}

class MaintenanceCategory extends DataClass
    implements Insertable<MaintenanceCategory> {
  /// Primary key
  final int id;

  /// Category name (e.g., "Oil & Fluids", "Filters", "Engine")
  final String name;

  /// Icon name for the category (Material Icons)
  final String iconName;

  /// Hex color code for the category (e.g., "#FF5722")
  final String color;

  /// Whether this is a system-defined category (cannot be deleted)
  final bool isSystem;

  /// Creation timestamp
  final DateTime createdAt;
  const MaintenanceCategory({
    required this.id,
    required this.name,
    required this.iconName,
    required this.color,
    required this.isSystem,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon_name'] = Variable<String>(iconName);
    map['color'] = Variable<String>(color);
    map['is_system'] = Variable<bool>(isSystem);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MaintenanceCategoriesCompanion toCompanion(bool nullToAbsent) {
    return MaintenanceCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      iconName: Value(iconName),
      color: Value(color),
      isSystem: Value(isSystem),
      createdAt: Value(createdAt),
    );
  }

  factory MaintenanceCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenanceCategory(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconName: serializer.fromJson<String>(json['iconName']),
      color: serializer.fromJson<String>(json['color']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'iconName': serializer.toJson<String>(iconName),
      'color': serializer.toJson<String>(color),
      'isSystem': serializer.toJson<bool>(isSystem),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MaintenanceCategory copyWith({
    int? id,
    String? name,
    String? iconName,
    String? color,
    bool? isSystem,
    DateTime? createdAt,
  }) => MaintenanceCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    iconName: iconName ?? this.iconName,
    color: color ?? this.color,
    isSystem: isSystem ?? this.isSystem,
    createdAt: createdAt ?? this.createdAt,
  );
  MaintenanceCategory copyWithCompanion(MaintenanceCategoriesCompanion data) {
    return MaintenanceCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      color: data.color.present ? data.color.value : this.color,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('color: $color, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, iconName, color, isSystem, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenanceCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconName == this.iconName &&
          other.color == this.color &&
          other.isSystem == this.isSystem &&
          other.createdAt == this.createdAt);
}

class MaintenanceCategoriesCompanion
    extends UpdateCompanion<MaintenanceCategory> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> iconName;
  final Value<String> color;
  final Value<bool> isSystem;
  final Value<DateTime> createdAt;
  const MaintenanceCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.color = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MaintenanceCategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String iconName,
    required String color,
    this.isSystem = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       iconName = Value(iconName),
       color = Value(color);
  static Insertable<MaintenanceCategory> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? iconName,
    Expression<String>? color,
    Expression<bool>? isSystem,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconName != null) 'icon_name': iconName,
      if (color != null) 'color': color,
      if (isSystem != null) 'is_system': isSystem,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MaintenanceCategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? iconName,
    Value<String>? color,
    Value<bool>? isSystem,
    Value<DateTime>? createdAt,
  }) {
    return MaintenanceCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      color: color ?? this.color,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('color: $color, ')
          ..write('isSystem: $isSystem, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MaintenanceLogsTable extends MaintenanceLogs
    with TableInfo<$MaintenanceLogsTable, MaintenanceLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenanceLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES maintenance_categories (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 1000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serviceDateMeta = const VerificationMeta(
    'serviceDate',
  );
  @override
  late final GeneratedColumn<DateTime> serviceDate = GeneratedColumn<DateTime>(
    'service_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometerReadingMeta = const VerificationMeta(
    'odometerReading',
  );
  @override
  late final GeneratedColumn<double> odometerReading = GeneratedColumn<double>(
    'odometer_reading',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceProviderMeta = const VerificationMeta(
    'serviceProvider',
  );
  @override
  late final GeneratedColumn<String> serviceProvider = GeneratedColumn<String>(
    'service_provider',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 200),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partsCostMeta = const VerificationMeta(
    'partsCost',
  );
  @override
  late final GeneratedColumn<double> partsCost = GeneratedColumn<double>(
    'parts_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _laborCostMeta = const VerificationMeta(
    'laborCost',
  );
  @override
  late final GeneratedColumn<double> laborCost = GeneratedColumn<double>(
    'labor_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalCostMeta = const VerificationMeta(
    'totalCost',
  );
  @override
  late final GeneratedColumn<double> totalCost = GeneratedColumn<double>(
    'total_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('USD'),
  );
  static const VerificationMeta _laborHoursMeta = const VerificationMeta(
    'laborHours',
  );
  @override
  late final GeneratedColumn<double> laborHours = GeneratedColumn<double>(
    'labor_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 2000),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
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
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenance_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaintenanceLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('service_date')) {
      context.handle(
        _serviceDateMeta,
        serviceDate.isAcceptableOrUnknown(
          data['service_date']!,
          _serviceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceDateMeta);
    }
    if (data.containsKey('odometer_reading')) {
      context.handle(
        _odometerReadingMeta,
        odometerReading.isAcceptableOrUnknown(
          data['odometer_reading']!,
          _odometerReadingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_odometerReadingMeta);
    }
    if (data.containsKey('service_provider')) {
      context.handle(
        _serviceProviderMeta,
        serviceProvider.isAcceptableOrUnknown(
          data['service_provider']!,
          _serviceProviderMeta,
        ),
      );
    }
    if (data.containsKey('parts_cost')) {
      context.handle(
        _partsCostMeta,
        partsCost.isAcceptableOrUnknown(data['parts_cost']!, _partsCostMeta),
      );
    }
    if (data.containsKey('labor_cost')) {
      context.handle(
        _laborCostMeta,
        laborCost.isAcceptableOrUnknown(data['labor_cost']!, _laborCostMeta),
      );
    }
    if (data.containsKey('total_cost')) {
      context.handle(
        _totalCostMeta,
        totalCost.isAcceptableOrUnknown(data['total_cost']!, _totalCostMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('labor_hours')) {
      context.handle(
        _laborHoursMeta,
        laborHours.isAcceptableOrUnknown(data['labor_hours']!, _laborHoursMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaintenanceLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenanceLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      serviceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}service_date'],
      )!,
      odometerReading: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}odometer_reading'],
      )!,
      serviceProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_provider'],
      ),
      partsCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}parts_cost'],
      )!,
      laborCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}labor_cost'],
      )!,
      totalCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_cost'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      laborHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}labor_hours'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MaintenanceLogsTable createAlias(String alias) {
    return $MaintenanceLogsTable(attachedDatabase, alias);
  }
}

class MaintenanceLog extends DataClass implements Insertable<MaintenanceLog> {
  /// Primary key
  final int id;

  /// Vehicle this maintenance was performed on
  final int vehicleId;

  /// Category of maintenance (e.g., oil change, tire rotation)
  final int categoryId;

  /// Title/name of the maintenance activity
  final String title;

  /// Detailed description of the maintenance work
  final String? description;

  /// Date when the maintenance was performed
  final DateTime serviceDate;

  /// Odometer reading at time of service
  final double odometerReading;

  /// Service provider (garage, self, dealer, etc.)
  final String? serviceProvider;

  /// Cost of parts used
  final double partsCost;

  /// Cost of labor
  final double laborCost;

  /// Total cost (parts + labor + other)
  final double totalCost;

  /// Currency code (e.g., USD, EUR, CAD)
  final String currency;

  /// Hours of labor required
  final double? laborHours;

  /// Additional notes or comments
  final String? notes;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last updated timestamp
  final DateTime updatedAt;
  const MaintenanceLog({
    required this.id,
    required this.vehicleId,
    required this.categoryId,
    required this.title,
    this.description,
    required this.serviceDate,
    required this.odometerReading,
    this.serviceProvider,
    required this.partsCost,
    required this.laborCost,
    required this.totalCost,
    required this.currency,
    this.laborHours,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['category_id'] = Variable<int>(categoryId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['service_date'] = Variable<DateTime>(serviceDate);
    map['odometer_reading'] = Variable<double>(odometerReading);
    if (!nullToAbsent || serviceProvider != null) {
      map['service_provider'] = Variable<String>(serviceProvider);
    }
    map['parts_cost'] = Variable<double>(partsCost);
    map['labor_cost'] = Variable<double>(laborCost);
    map['total_cost'] = Variable<double>(totalCost);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || laborHours != null) {
      map['labor_hours'] = Variable<double>(laborHours);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MaintenanceLogsCompanion toCompanion(bool nullToAbsent) {
    return MaintenanceLogsCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      categoryId: Value(categoryId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      serviceDate: Value(serviceDate),
      odometerReading: Value(odometerReading),
      serviceProvider: serviceProvider == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceProvider),
      partsCost: Value(partsCost),
      laborCost: Value(laborCost),
      totalCost: Value(totalCost),
      currency: Value(currency),
      laborHours: laborHours == null && nullToAbsent
          ? const Value.absent()
          : Value(laborHours),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MaintenanceLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenanceLog(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      serviceDate: serializer.fromJson<DateTime>(json['serviceDate']),
      odometerReading: serializer.fromJson<double>(json['odometerReading']),
      serviceProvider: serializer.fromJson<String?>(json['serviceProvider']),
      partsCost: serializer.fromJson<double>(json['partsCost']),
      laborCost: serializer.fromJson<double>(json['laborCost']),
      totalCost: serializer.fromJson<double>(json['totalCost']),
      currency: serializer.fromJson<String>(json['currency']),
      laborHours: serializer.fromJson<double?>(json['laborHours']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'categoryId': serializer.toJson<int>(categoryId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'serviceDate': serializer.toJson<DateTime>(serviceDate),
      'odometerReading': serializer.toJson<double>(odometerReading),
      'serviceProvider': serializer.toJson<String?>(serviceProvider),
      'partsCost': serializer.toJson<double>(partsCost),
      'laborCost': serializer.toJson<double>(laborCost),
      'totalCost': serializer.toJson<double>(totalCost),
      'currency': serializer.toJson<String>(currency),
      'laborHours': serializer.toJson<double?>(laborHours),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MaintenanceLog copyWith({
    int? id,
    int? vehicleId,
    int? categoryId,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? serviceDate,
    double? odometerReading,
    Value<String?> serviceProvider = const Value.absent(),
    double? partsCost,
    double? laborCost,
    double? totalCost,
    String? currency,
    Value<double?> laborHours = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MaintenanceLog(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    categoryId: categoryId ?? this.categoryId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    serviceDate: serviceDate ?? this.serviceDate,
    odometerReading: odometerReading ?? this.odometerReading,
    serviceProvider: serviceProvider.present
        ? serviceProvider.value
        : this.serviceProvider,
    partsCost: partsCost ?? this.partsCost,
    laborCost: laborCost ?? this.laborCost,
    totalCost: totalCost ?? this.totalCost,
    currency: currency ?? this.currency,
    laborHours: laborHours.present ? laborHours.value : this.laborHours,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MaintenanceLog copyWithCompanion(MaintenanceLogsCompanion data) {
    return MaintenanceLog(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      serviceDate: data.serviceDate.present
          ? data.serviceDate.value
          : this.serviceDate,
      odometerReading: data.odometerReading.present
          ? data.odometerReading.value
          : this.odometerReading,
      serviceProvider: data.serviceProvider.present
          ? data.serviceProvider.value
          : this.serviceProvider,
      partsCost: data.partsCost.present ? data.partsCost.value : this.partsCost,
      laborCost: data.laborCost.present ? data.laborCost.value : this.laborCost,
      totalCost: data.totalCost.present ? data.totalCost.value : this.totalCost,
      currency: data.currency.present ? data.currency.value : this.currency,
      laborHours: data.laborHours.present
          ? data.laborHours.value
          : this.laborHours,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceLog(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('odometerReading: $odometerReading, ')
          ..write('serviceProvider: $serviceProvider, ')
          ..write('partsCost: $partsCost, ')
          ..write('laborCost: $laborCost, ')
          ..write('totalCost: $totalCost, ')
          ..write('currency: $currency, ')
          ..write('laborHours: $laborHours, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
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
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenanceLog &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.categoryId == this.categoryId &&
          other.title == this.title &&
          other.description == this.description &&
          other.serviceDate == this.serviceDate &&
          other.odometerReading == this.odometerReading &&
          other.serviceProvider == this.serviceProvider &&
          other.partsCost == this.partsCost &&
          other.laborCost == this.laborCost &&
          other.totalCost == this.totalCost &&
          other.currency == this.currency &&
          other.laborHours == this.laborHours &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MaintenanceLogsCompanion extends UpdateCompanion<MaintenanceLog> {
  final Value<int> id;
  final Value<int> vehicleId;
  final Value<int> categoryId;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> serviceDate;
  final Value<double> odometerReading;
  final Value<String?> serviceProvider;
  final Value<double> partsCost;
  final Value<double> laborCost;
  final Value<double> totalCost;
  final Value<String> currency;
  final Value<double?> laborHours;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MaintenanceLogsCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.serviceDate = const Value.absent(),
    this.odometerReading = const Value.absent(),
    this.serviceProvider = const Value.absent(),
    this.partsCost = const Value.absent(),
    this.laborCost = const Value.absent(),
    this.totalCost = const Value.absent(),
    this.currency = const Value.absent(),
    this.laborHours = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MaintenanceLogsCompanion.insert({
    this.id = const Value.absent(),
    required int vehicleId,
    required int categoryId,
    required String title,
    this.description = const Value.absent(),
    required DateTime serviceDate,
    required double odometerReading,
    this.serviceProvider = const Value.absent(),
    this.partsCost = const Value.absent(),
    this.laborCost = const Value.absent(),
    this.totalCost = const Value.absent(),
    this.currency = const Value.absent(),
    this.laborHours = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : vehicleId = Value(vehicleId),
       categoryId = Value(categoryId),
       title = Value(title),
       serviceDate = Value(serviceDate),
       odometerReading = Value(odometerReading);
  static Insertable<MaintenanceLog> custom({
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<int>? categoryId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? serviceDate,
    Expression<double>? odometerReading,
    Expression<String>? serviceProvider,
    Expression<double>? partsCost,
    Expression<double>? laborCost,
    Expression<double>? totalCost,
    Expression<String>? currency,
    Expression<double>? laborHours,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (categoryId != null) 'category_id': categoryId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (serviceDate != null) 'service_date': serviceDate,
      if (odometerReading != null) 'odometer_reading': odometerReading,
      if (serviceProvider != null) 'service_provider': serviceProvider,
      if (partsCost != null) 'parts_cost': partsCost,
      if (laborCost != null) 'labor_cost': laborCost,
      if (totalCost != null) 'total_cost': totalCost,
      if (currency != null) 'currency': currency,
      if (laborHours != null) 'labor_hours': laborHours,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MaintenanceLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? vehicleId,
    Value<int>? categoryId,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? serviceDate,
    Value<double>? odometerReading,
    Value<String?>? serviceProvider,
    Value<double>? partsCost,
    Value<double>? laborCost,
    Value<double>? totalCost,
    Value<String>? currency,
    Value<double?>? laborHours,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return MaintenanceLogsCompanion(
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
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (serviceDate.present) {
      map['service_date'] = Variable<DateTime>(serviceDate.value);
    }
    if (odometerReading.present) {
      map['odometer_reading'] = Variable<double>(odometerReading.value);
    }
    if (serviceProvider.present) {
      map['service_provider'] = Variable<String>(serviceProvider.value);
    }
    if (partsCost.present) {
      map['parts_cost'] = Variable<double>(partsCost.value);
    }
    if (laborCost.present) {
      map['labor_cost'] = Variable<double>(laborCost.value);
    }
    if (totalCost.present) {
      map['total_cost'] = Variable<double>(totalCost.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (laborHours.present) {
      map['labor_hours'] = Variable<double>(laborHours.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceLogsCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('odometerReading: $odometerReading, ')
          ..write('serviceProvider: $serviceProvider, ')
          ..write('partsCost: $partsCost, ')
          ..write('laborCost: $laborCost, ')
          ..write('totalCost: $totalCost, ')
          ..write('currency: $currency, ')
          ..write('laborHours: $laborHours, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MaintenanceSchedulesTable extends MaintenanceSchedules
    with TableInfo<$MaintenanceSchedulesTable, MaintenanceSchedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenanceSchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES maintenance_categories (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalKmMeta = const VerificationMeta(
    'intervalKm',
  );
  @override
  late final GeneratedColumn<double> intervalKm = GeneratedColumn<double>(
    'interval_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalMonthsMeta = const VerificationMeta(
    'intervalMonths',
  );
  @override
  late final GeneratedColumn<int> intervalMonths = GeneratedColumn<int>(
    'interval_months',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastServiceDateMeta = const VerificationMeta(
    'lastServiceDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastServiceDate =
      GeneratedColumn<DateTime>(
        'last_service_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastServiceKmMeta = const VerificationMeta(
    'lastServiceKm',
  );
  @override
  late final GeneratedColumn<double> lastServiceKm = GeneratedColumn<double>(
    'last_service_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextDueDateMeta = const VerificationMeta(
    'nextDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
    'next_due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextDueKmMeta = const VerificationMeta(
    'nextDueKm',
  );
  @override
  late final GeneratedColumn<double> nextDueKm = GeneratedColumn<double>(
    'next_due_km',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vehicleId,
    categoryId,
    title,
    intervalKm,
    intervalMonths,
    lastServiceDate,
    lastServiceKm,
    nextDueDate,
    nextDueKm,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenance_schedules';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaintenanceSchedule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vehicleIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('interval_km')) {
      context.handle(
        _intervalKmMeta,
        intervalKm.isAcceptableOrUnknown(data['interval_km']!, _intervalKmMeta),
      );
    }
    if (data.containsKey('interval_months')) {
      context.handle(
        _intervalMonthsMeta,
        intervalMonths.isAcceptableOrUnknown(
          data['interval_months']!,
          _intervalMonthsMeta,
        ),
      );
    }
    if (data.containsKey('last_service_date')) {
      context.handle(
        _lastServiceDateMeta,
        lastServiceDate.isAcceptableOrUnknown(
          data['last_service_date']!,
          _lastServiceDateMeta,
        ),
      );
    }
    if (data.containsKey('last_service_km')) {
      context.handle(
        _lastServiceKmMeta,
        lastServiceKm.isAcceptableOrUnknown(
          data['last_service_km']!,
          _lastServiceKmMeta,
        ),
      );
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
        _nextDueDateMeta,
        nextDueDate.isAcceptableOrUnknown(
          data['next_due_date']!,
          _nextDueDateMeta,
        ),
      );
    }
    if (data.containsKey('next_due_km')) {
      context.handle(
        _nextDueKmMeta,
        nextDueKm.isAcceptableOrUnknown(data['next_due_km']!, _nextDueKmMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaintenanceSchedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenanceSchedule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      intervalKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}interval_km'],
      ),
      intervalMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_months'],
      ),
      lastServiceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_service_date'],
      ),
      lastServiceKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_service_km'],
      ),
      nextDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_due_date'],
      ),
      nextDueKm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}next_due_km'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MaintenanceSchedulesTable createAlias(String alias) {
    return $MaintenanceSchedulesTable(attachedDatabase, alias);
  }
}

class MaintenanceSchedule extends DataClass
    implements Insertable<MaintenanceSchedule> {
  /// Primary key
  final int id;

  /// Vehicle this schedule applies to
  final int vehicleId;

  /// Category of maintenance this schedule is for
  final int categoryId;

  /// Title/name of the scheduled maintenance
  final String title;

  /// Kilometers interval for recurring maintenance (e.g., every 5000 km)
  final double? intervalKm;

  /// Months interval for recurring maintenance (e.g., every 6 months)
  final int? intervalMonths;

  /// Date of last service for this schedule
  final DateTime? lastServiceDate;

  /// Odometer reading at last service
  final double? lastServiceKm;

  /// Next due date (calculated based on intervals)
  final DateTime? nextDueDate;

  /// Next due odometer reading (calculated based on intervals)
  final double? nextDueKm;

  /// Whether this schedule is active
  final bool isActive;

  /// Creation timestamp
  final DateTime createdAt;
  const MaintenanceSchedule({
    required this.id,
    required this.vehicleId,
    required this.categoryId,
    required this.title,
    this.intervalKm,
    this.intervalMonths,
    this.lastServiceDate,
    this.lastServiceKm,
    this.nextDueDate,
    this.nextDueKm,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vehicle_id'] = Variable<int>(vehicleId);
    map['category_id'] = Variable<int>(categoryId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || intervalKm != null) {
      map['interval_km'] = Variable<double>(intervalKm);
    }
    if (!nullToAbsent || intervalMonths != null) {
      map['interval_months'] = Variable<int>(intervalMonths);
    }
    if (!nullToAbsent || lastServiceDate != null) {
      map['last_service_date'] = Variable<DateTime>(lastServiceDate);
    }
    if (!nullToAbsent || lastServiceKm != null) {
      map['last_service_km'] = Variable<double>(lastServiceKm);
    }
    if (!nullToAbsent || nextDueDate != null) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate);
    }
    if (!nullToAbsent || nextDueKm != null) {
      map['next_due_km'] = Variable<double>(nextDueKm);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MaintenanceSchedulesCompanion toCompanion(bool nullToAbsent) {
    return MaintenanceSchedulesCompanion(
      id: Value(id),
      vehicleId: Value(vehicleId),
      categoryId: Value(categoryId),
      title: Value(title),
      intervalKm: intervalKm == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalKm),
      intervalMonths: intervalMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalMonths),
      lastServiceDate: lastServiceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastServiceDate),
      lastServiceKm: lastServiceKm == null && nullToAbsent
          ? const Value.absent()
          : Value(lastServiceKm),
      nextDueDate: nextDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueDate),
      nextDueKm: nextDueKm == null && nullToAbsent
          ? const Value.absent()
          : Value(nextDueKm),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory MaintenanceSchedule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenanceSchedule(
      id: serializer.fromJson<int>(json['id']),
      vehicleId: serializer.fromJson<int>(json['vehicleId']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      title: serializer.fromJson<String>(json['title']),
      intervalKm: serializer.fromJson<double?>(json['intervalKm']),
      intervalMonths: serializer.fromJson<int?>(json['intervalMonths']),
      lastServiceDate: serializer.fromJson<DateTime?>(json['lastServiceDate']),
      lastServiceKm: serializer.fromJson<double?>(json['lastServiceKm']),
      nextDueDate: serializer.fromJson<DateTime?>(json['nextDueDate']),
      nextDueKm: serializer.fromJson<double?>(json['nextDueKm']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vehicleId': serializer.toJson<int>(vehicleId),
      'categoryId': serializer.toJson<int>(categoryId),
      'title': serializer.toJson<String>(title),
      'intervalKm': serializer.toJson<double?>(intervalKm),
      'intervalMonths': serializer.toJson<int?>(intervalMonths),
      'lastServiceDate': serializer.toJson<DateTime?>(lastServiceDate),
      'lastServiceKm': serializer.toJson<double?>(lastServiceKm),
      'nextDueDate': serializer.toJson<DateTime?>(nextDueDate),
      'nextDueKm': serializer.toJson<double?>(nextDueKm),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MaintenanceSchedule copyWith({
    int? id,
    int? vehicleId,
    int? categoryId,
    String? title,
    Value<double?> intervalKm = const Value.absent(),
    Value<int?> intervalMonths = const Value.absent(),
    Value<DateTime?> lastServiceDate = const Value.absent(),
    Value<double?> lastServiceKm = const Value.absent(),
    Value<DateTime?> nextDueDate = const Value.absent(),
    Value<double?> nextDueKm = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => MaintenanceSchedule(
    id: id ?? this.id,
    vehicleId: vehicleId ?? this.vehicleId,
    categoryId: categoryId ?? this.categoryId,
    title: title ?? this.title,
    intervalKm: intervalKm.present ? intervalKm.value : this.intervalKm,
    intervalMonths: intervalMonths.present
        ? intervalMonths.value
        : this.intervalMonths,
    lastServiceDate: lastServiceDate.present
        ? lastServiceDate.value
        : this.lastServiceDate,
    lastServiceKm: lastServiceKm.present
        ? lastServiceKm.value
        : this.lastServiceKm,
    nextDueDate: nextDueDate.present ? nextDueDate.value : this.nextDueDate,
    nextDueKm: nextDueKm.present ? nextDueKm.value : this.nextDueKm,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  MaintenanceSchedule copyWithCompanion(MaintenanceSchedulesCompanion data) {
    return MaintenanceSchedule(
      id: data.id.present ? data.id.value : this.id,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      title: data.title.present ? data.title.value : this.title,
      intervalKm: data.intervalKm.present
          ? data.intervalKm.value
          : this.intervalKm,
      intervalMonths: data.intervalMonths.present
          ? data.intervalMonths.value
          : this.intervalMonths,
      lastServiceDate: data.lastServiceDate.present
          ? data.lastServiceDate.value
          : this.lastServiceDate,
      lastServiceKm: data.lastServiceKm.present
          ? data.lastServiceKm.value
          : this.lastServiceKm,
      nextDueDate: data.nextDueDate.present
          ? data.nextDueDate.value
          : this.nextDueDate,
      nextDueKm: data.nextDueKm.present ? data.nextDueKm.value : this.nextDueKm,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceSchedule(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('intervalKm: $intervalKm, ')
          ..write('intervalMonths: $intervalMonths, ')
          ..write('lastServiceDate: $lastServiceDate, ')
          ..write('lastServiceKm: $lastServiceKm, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('nextDueKm: $nextDueKm, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vehicleId,
    categoryId,
    title,
    intervalKm,
    intervalMonths,
    lastServiceDate,
    lastServiceKm,
    nextDueDate,
    nextDueKm,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenanceSchedule &&
          other.id == this.id &&
          other.vehicleId == this.vehicleId &&
          other.categoryId == this.categoryId &&
          other.title == this.title &&
          other.intervalKm == this.intervalKm &&
          other.intervalMonths == this.intervalMonths &&
          other.lastServiceDate == this.lastServiceDate &&
          other.lastServiceKm == this.lastServiceKm &&
          other.nextDueDate == this.nextDueDate &&
          other.nextDueKm == this.nextDueKm &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class MaintenanceSchedulesCompanion
    extends UpdateCompanion<MaintenanceSchedule> {
  final Value<int> id;
  final Value<int> vehicleId;
  final Value<int> categoryId;
  final Value<String> title;
  final Value<double?> intervalKm;
  final Value<int?> intervalMonths;
  final Value<DateTime?> lastServiceDate;
  final Value<double?> lastServiceKm;
  final Value<DateTime?> nextDueDate;
  final Value<double?> nextDueKm;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const MaintenanceSchedulesCompanion({
    this.id = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.title = const Value.absent(),
    this.intervalKm = const Value.absent(),
    this.intervalMonths = const Value.absent(),
    this.lastServiceDate = const Value.absent(),
    this.lastServiceKm = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.nextDueKm = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  MaintenanceSchedulesCompanion.insert({
    this.id = const Value.absent(),
    required int vehicleId,
    required int categoryId,
    required String title,
    this.intervalKm = const Value.absent(),
    this.intervalMonths = const Value.absent(),
    this.lastServiceDate = const Value.absent(),
    this.lastServiceKm = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.nextDueKm = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : vehicleId = Value(vehicleId),
       categoryId = Value(categoryId),
       title = Value(title);
  static Insertable<MaintenanceSchedule> custom({
    Expression<int>? id,
    Expression<int>? vehicleId,
    Expression<int>? categoryId,
    Expression<String>? title,
    Expression<double>? intervalKm,
    Expression<int>? intervalMonths,
    Expression<DateTime>? lastServiceDate,
    Expression<double>? lastServiceKm,
    Expression<DateTime>? nextDueDate,
    Expression<double>? nextDueKm,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (categoryId != null) 'category_id': categoryId,
      if (title != null) 'title': title,
      if (intervalKm != null) 'interval_km': intervalKm,
      if (intervalMonths != null) 'interval_months': intervalMonths,
      if (lastServiceDate != null) 'last_service_date': lastServiceDate,
      if (lastServiceKm != null) 'last_service_km': lastServiceKm,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (nextDueKm != null) 'next_due_km': nextDueKm,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  MaintenanceSchedulesCompanion copyWith({
    Value<int>? id,
    Value<int>? vehicleId,
    Value<int>? categoryId,
    Value<String>? title,
    Value<double?>? intervalKm,
    Value<int?>? intervalMonths,
    Value<DateTime?>? lastServiceDate,
    Value<double?>? lastServiceKm,
    Value<DateTime?>? nextDueDate,
    Value<double?>? nextDueKm,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return MaintenanceSchedulesCompanion(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      intervalKm: intervalKm ?? this.intervalKm,
      intervalMonths: intervalMonths ?? this.intervalMonths,
      lastServiceDate: lastServiceDate ?? this.lastServiceDate,
      lastServiceKm: lastServiceKm ?? this.lastServiceKm,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      nextDueKm: nextDueKm ?? this.nextDueKm,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (intervalKm.present) {
      map['interval_km'] = Variable<double>(intervalKm.value);
    }
    if (intervalMonths.present) {
      map['interval_months'] = Variable<int>(intervalMonths.value);
    }
    if (lastServiceDate.present) {
      map['last_service_date'] = Variable<DateTime>(lastServiceDate.value);
    }
    if (lastServiceKm.present) {
      map['last_service_km'] = Variable<double>(lastServiceKm.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    if (nextDueKm.present) {
      map['next_due_km'] = Variable<double>(nextDueKm.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceSchedulesCompanion(')
          ..write('id: $id, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('categoryId: $categoryId, ')
          ..write('title: $title, ')
          ..write('intervalKm: $intervalKm, ')
          ..write('intervalMonths: $intervalMonths, ')
          ..write('lastServiceDate: $lastServiceDate, ')
          ..write('lastServiceKm: $lastServiceKm, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('nextDueKm: $nextDueKm, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $FuelEntriesTable fuelEntries = $FuelEntriesTable(this);
  late final $MaintenanceCategoriesTable maintenanceCategories =
      $MaintenanceCategoriesTable(this);
  late final $MaintenanceLogsTable maintenanceLogs = $MaintenanceLogsTable(
    this,
  );
  late final $MaintenanceSchedulesTable maintenanceSchedules =
      $MaintenanceSchedulesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vehicles,
    fuelEntries,
    maintenanceCategories,
    maintenanceLogs,
    maintenanceSchedules,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('maintenance_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('maintenance_schedules', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$VehiclesTableCreateCompanionBuilder =
    VehiclesCompanion Function({
      Value<int> id,
      required String name,
      required double initialKm,
      Value<DateTime> createdAt,
    });
typedef $$VehiclesTableUpdateCompanionBuilder =
    VehiclesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> initialKm,
      Value<DateTime> createdAt,
    });

final class $$VehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FuelEntriesTable, List<FuelEntry>>
  _fuelEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.fuelEntries,
    aliasName: $_aliasNameGenerator(db.vehicles.id, db.fuelEntries.vehicleId),
  );

  $$FuelEntriesTableProcessedTableManager get fuelEntriesRefs {
    final manager = $$FuelEntriesTableTableManager(
      $_db,
      $_db.fuelEntries,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_fuelEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MaintenanceLogsTable, List<MaintenanceLog>>
  _maintenanceLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.maintenanceLogs,
    aliasName: $_aliasNameGenerator(
      db.vehicles.id,
      db.maintenanceLogs.vehicleId,
    ),
  );

  $$MaintenanceLogsTableProcessedTableManager get maintenanceLogsRefs {
    final manager = $$MaintenanceLogsTableTableManager(
      $_db,
      $_db.maintenanceLogs,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceLogsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MaintenanceSchedulesTable,
    List<MaintenanceSchedule>
  >
  _maintenanceSchedulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.maintenanceSchedules,
        aliasName: $_aliasNameGenerator(
          db.vehicles.id,
          db.maintenanceSchedules.vehicleId,
        ),
      );

  $$MaintenanceSchedulesTableProcessedTableManager
  get maintenanceSchedulesRefs {
    final manager = $$MaintenanceSchedulesTableTableManager(
      $_db,
      $_db.maintenanceSchedules,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get initialKm => $composableBuilder(
    column: $table.initialKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> fuelEntriesRefs(
    Expression<bool> Function($$FuelEntriesTableFilterComposer f) f,
  ) {
    final $$FuelEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fuelEntries,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FuelEntriesTableFilterComposer(
            $db: $db,
            $table: $db.fuelEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> maintenanceLogsRefs(
    Expression<bool> Function($$MaintenanceLogsTableFilterComposer f) f,
  ) {
    final $$MaintenanceLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceLogs,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceLogsTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> maintenanceSchedulesRefs(
    Expression<bool> Function($$MaintenanceSchedulesTableFilterComposer f) f,
  ) {
    final $$MaintenanceSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceSchedules,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get initialKm => $composableBuilder(
    column: $table.initialKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get initialKm =>
      $composableBuilder(column: $table.initialKm, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> fuelEntriesRefs<T extends Object>(
    Expression<T> Function($$FuelEntriesTableAnnotationComposer a) f,
  ) {
    final $$FuelEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fuelEntries,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FuelEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.fuelEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> maintenanceLogsRefs<T extends Object>(
    Expression<T> Function($$MaintenanceLogsTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceLogs,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.maintenanceLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> maintenanceSchedulesRefs<T extends Object>(
    Expression<T> Function($$MaintenanceSchedulesTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.maintenanceSchedules,
          getReferencedColumn: (t) => t.vehicleId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.maintenanceSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          Vehicle,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (Vehicle, $$VehiclesTableReferences),
          Vehicle,
          PrefetchHooks Function({
            bool fuelEntriesRefs,
            bool maintenanceLogsRefs,
            bool maintenanceSchedulesRefs,
          })
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> initialKm = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                name: name,
                initialKm: initialKm,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double initialKm,
                Value<DateTime> createdAt = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                name: name,
                initialKm: initialKm,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehiclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                fuelEntriesRefs = false,
                maintenanceLogsRefs = false,
                maintenanceSchedulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (fuelEntriesRefs) db.fuelEntries,
                    if (maintenanceLogsRefs) db.maintenanceLogs,
                    if (maintenanceSchedulesRefs) db.maintenanceSchedules,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (fuelEntriesRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          FuelEntry
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._fuelEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).fuelEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (maintenanceLogsRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          MaintenanceLog
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._maintenanceLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (maintenanceSchedulesRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          MaintenanceSchedule
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._maintenanceSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceSchedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      Vehicle,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (Vehicle, $$VehiclesTableReferences),
      Vehicle,
      PrefetchHooks Function({
        bool fuelEntriesRefs,
        bool maintenanceLogsRefs,
        bool maintenanceSchedulesRefs,
      })
    >;
typedef $$FuelEntriesTableCreateCompanionBuilder =
    FuelEntriesCompanion Function({
      Value<int> id,
      required int vehicleId,
      required DateTime date,
      required double currentKm,
      required double fuelAmount,
      required double price,
      required String country,
      required double pricePerLiter,
      Value<double?> consumption,
      Value<bool> isFullTank,
    });
typedef $$FuelEntriesTableUpdateCompanionBuilder =
    FuelEntriesCompanion Function({
      Value<int> id,
      Value<int> vehicleId,
      Value<DateTime> date,
      Value<double> currentKm,
      Value<double> fuelAmount,
      Value<double> price,
      Value<String> country,
      Value<double> pricePerLiter,
      Value<double?> consumption,
      Value<bool> isFullTank,
    });

final class $$FuelEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $FuelEntriesTable, FuelEntry> {
  $$FuelEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias(
        $_aliasNameGenerator(db.fuelEntries.vehicleId, db.vehicles.id),
      );

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FuelEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $FuelEntriesTable> {
  $$FuelEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get currentKm => $composableBuilder(
    column: $table.currentKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fuelAmount => $composableBuilder(
    column: $table.fuelAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePerLiter => $composableBuilder(
    column: $table.pricePerLiter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get consumption => $composableBuilder(
    column: $table.consumption,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFullTank => $composableBuilder(
    column: $table.isFullTank,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FuelEntriesTable> {
  $$FuelEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get currentKm => $composableBuilder(
    column: $table.currentKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fuelAmount => $composableBuilder(
    column: $table.fuelAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePerLiter => $composableBuilder(
    column: $table.pricePerLiter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get consumption => $composableBuilder(
    column: $table.consumption,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFullTank => $composableBuilder(
    column: $table.isFullTank,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FuelEntriesTable> {
  $$FuelEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get currentKm =>
      $composableBuilder(column: $table.currentKm, builder: (column) => column);

  GeneratedColumn<double> get fuelAmount => $composableBuilder(
    column: $table.fuelAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<double> get pricePerLiter => $composableBuilder(
    column: $table.pricePerLiter,
    builder: (column) => column,
  );

  GeneratedColumn<double> get consumption => $composableBuilder(
    column: $table.consumption,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFullTank => $composableBuilder(
    column: $table.isFullTank,
    builder: (column) => column,
  );

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FuelEntriesTable,
          FuelEntry,
          $$FuelEntriesTableFilterComposer,
          $$FuelEntriesTableOrderingComposer,
          $$FuelEntriesTableAnnotationComposer,
          $$FuelEntriesTableCreateCompanionBuilder,
          $$FuelEntriesTableUpdateCompanionBuilder,
          (FuelEntry, $$FuelEntriesTableReferences),
          FuelEntry,
          PrefetchHooks Function({bool vehicleId})
        > {
  $$FuelEntriesTableTableManager(_$AppDatabase db, $FuelEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FuelEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FuelEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FuelEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double> currentKm = const Value.absent(),
                Value<double> fuelAmount = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<String> country = const Value.absent(),
                Value<double> pricePerLiter = const Value.absent(),
                Value<double?> consumption = const Value.absent(),
                Value<bool> isFullTank = const Value.absent(),
              }) => FuelEntriesCompanion(
                id: id,
                vehicleId: vehicleId,
                date: date,
                currentKm: currentKm,
                fuelAmount: fuelAmount,
                price: price,
                country: country,
                pricePerLiter: pricePerLiter,
                consumption: consumption,
                isFullTank: isFullTank,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vehicleId,
                required DateTime date,
                required double currentKm,
                required double fuelAmount,
                required double price,
                required String country,
                required double pricePerLiter,
                Value<double?> consumption = const Value.absent(),
                Value<bool> isFullTank = const Value.absent(),
              }) => FuelEntriesCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                date: date,
                currentKm: currentKm,
                fuelAmount: fuelAmount,
                price: price,
                country: country,
                pricePerLiter: pricePerLiter,
                consumption: consumption,
                isFullTank: isFullTank,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FuelEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable: $$FuelEntriesTableReferences
                                    ._vehicleIdTable(db),
                                referencedColumn: $$FuelEntriesTableReferences
                                    ._vehicleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FuelEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FuelEntriesTable,
      FuelEntry,
      $$FuelEntriesTableFilterComposer,
      $$FuelEntriesTableOrderingComposer,
      $$FuelEntriesTableAnnotationComposer,
      $$FuelEntriesTableCreateCompanionBuilder,
      $$FuelEntriesTableUpdateCompanionBuilder,
      (FuelEntry, $$FuelEntriesTableReferences),
      FuelEntry,
      PrefetchHooks Function({bool vehicleId})
    >;
typedef $$MaintenanceCategoriesTableCreateCompanionBuilder =
    MaintenanceCategoriesCompanion Function({
      Value<int> id,
      required String name,
      required String iconName,
      required String color,
      Value<bool> isSystem,
      Value<DateTime> createdAt,
    });
typedef $$MaintenanceCategoriesTableUpdateCompanionBuilder =
    MaintenanceCategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> iconName,
      Value<String> color,
      Value<bool> isSystem,
      Value<DateTime> createdAt,
    });

final class $$MaintenanceCategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MaintenanceCategoriesTable,
          MaintenanceCategory
        > {
  $$MaintenanceCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MaintenanceLogsTable, List<MaintenanceLog>>
  _maintenanceLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.maintenanceLogs,
    aliasName: $_aliasNameGenerator(
      db.maintenanceCategories.id,
      db.maintenanceLogs.categoryId,
    ),
  );

  $$MaintenanceLogsTableProcessedTableManager get maintenanceLogsRefs {
    final manager = $$MaintenanceLogsTableTableManager(
      $_db,
      $_db.maintenanceLogs,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceLogsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MaintenanceSchedulesTable,
    List<MaintenanceSchedule>
  >
  _maintenanceSchedulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.maintenanceSchedules,
        aliasName: $_aliasNameGenerator(
          db.maintenanceCategories.id,
          db.maintenanceSchedules.categoryId,
        ),
      );

  $$MaintenanceSchedulesTableProcessedTableManager
  get maintenanceSchedulesRefs {
    final manager = $$MaintenanceSchedulesTableTableManager(
      $_db,
      $_db.maintenanceSchedules,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceSchedulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MaintenanceCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $MaintenanceCategoriesTable> {
  $$MaintenanceCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> maintenanceLogsRefs(
    Expression<bool> Function($$MaintenanceLogsTableFilterComposer f) f,
  ) {
    final $$MaintenanceLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceLogs,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceLogsTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> maintenanceSchedulesRefs(
    Expression<bool> Function($$MaintenanceSchedulesTableFilterComposer f) f,
  ) {
    final $$MaintenanceSchedulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceSchedules,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceSchedulesTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceSchedules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MaintenanceCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MaintenanceCategoriesTable> {
  $$MaintenanceCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MaintenanceCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaintenanceCategoriesTable> {
  $$MaintenanceCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> maintenanceLogsRefs<T extends Object>(
    Expression<T> Function($$MaintenanceLogsTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceLogs,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.maintenanceLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> maintenanceSchedulesRefs<T extends Object>(
    Expression<T> Function($$MaintenanceSchedulesTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceSchedulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.maintenanceSchedules,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceSchedulesTableAnnotationComposer(
                $db: $db,
                $table: $db.maintenanceSchedules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MaintenanceCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaintenanceCategoriesTable,
          MaintenanceCategory,
          $$MaintenanceCategoriesTableFilterComposer,
          $$MaintenanceCategoriesTableOrderingComposer,
          $$MaintenanceCategoriesTableAnnotationComposer,
          $$MaintenanceCategoriesTableCreateCompanionBuilder,
          $$MaintenanceCategoriesTableUpdateCompanionBuilder,
          (MaintenanceCategory, $$MaintenanceCategoriesTableReferences),
          MaintenanceCategory,
          PrefetchHooks Function({
            bool maintenanceLogsRefs,
            bool maintenanceSchedulesRefs,
          })
        > {
  $$MaintenanceCategoriesTableTableManager(
    _$AppDatabase db,
    $MaintenanceCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenanceCategoriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MaintenanceCategoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MaintenanceCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<String> color = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MaintenanceCategoriesCompanion(
                id: id,
                name: name,
                iconName: iconName,
                color: color,
                isSystem: isSystem,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String iconName,
                required String color,
                Value<bool> isSystem = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MaintenanceCategoriesCompanion.insert(
                id: id,
                name: name,
                iconName: iconName,
                color: color,
                isSystem: isSystem,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MaintenanceCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                maintenanceLogsRefs = false,
                maintenanceSchedulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (maintenanceLogsRefs) db.maintenanceLogs,
                    if (maintenanceSchedulesRefs) db.maintenanceSchedules,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (maintenanceLogsRefs)
                        await $_getPrefetchedData<
                          MaintenanceCategory,
                          $MaintenanceCategoriesTable,
                          MaintenanceLog
                        >(
                          currentTable: table,
                          referencedTable:
                              $$MaintenanceCategoriesTableReferences
                                  ._maintenanceLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MaintenanceCategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (maintenanceSchedulesRefs)
                        await $_getPrefetchedData<
                          MaintenanceCategory,
                          $MaintenanceCategoriesTable,
                          MaintenanceSchedule
                        >(
                          currentTable: table,
                          referencedTable:
                              $$MaintenanceCategoriesTableReferences
                                  ._maintenanceSchedulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MaintenanceCategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceSchedulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MaintenanceCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaintenanceCategoriesTable,
      MaintenanceCategory,
      $$MaintenanceCategoriesTableFilterComposer,
      $$MaintenanceCategoriesTableOrderingComposer,
      $$MaintenanceCategoriesTableAnnotationComposer,
      $$MaintenanceCategoriesTableCreateCompanionBuilder,
      $$MaintenanceCategoriesTableUpdateCompanionBuilder,
      (MaintenanceCategory, $$MaintenanceCategoriesTableReferences),
      MaintenanceCategory,
      PrefetchHooks Function({
        bool maintenanceLogsRefs,
        bool maintenanceSchedulesRefs,
      })
    >;
typedef $$MaintenanceLogsTableCreateCompanionBuilder =
    MaintenanceLogsCompanion Function({
      Value<int> id,
      required int vehicleId,
      required int categoryId,
      required String title,
      Value<String?> description,
      required DateTime serviceDate,
      required double odometerReading,
      Value<String?> serviceProvider,
      Value<double> partsCost,
      Value<double> laborCost,
      Value<double> totalCost,
      Value<String> currency,
      Value<double?> laborHours,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$MaintenanceLogsTableUpdateCompanionBuilder =
    MaintenanceLogsCompanion Function({
      Value<int> id,
      Value<int> vehicleId,
      Value<int> categoryId,
      Value<String> title,
      Value<String?> description,
      Value<DateTime> serviceDate,
      Value<double> odometerReading,
      Value<String?> serviceProvider,
      Value<double> partsCost,
      Value<double> laborCost,
      Value<double> totalCost,
      Value<String> currency,
      Value<double?> laborHours,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$MaintenanceLogsTableReferences
    extends
        BaseReferences<_$AppDatabase, $MaintenanceLogsTable, MaintenanceLog> {
  $$MaintenanceLogsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias(
        $_aliasNameGenerator(db.maintenanceLogs.vehicleId, db.vehicles.id),
      );

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MaintenanceCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.maintenanceCategories.createAlias(
        $_aliasNameGenerator(
          db.maintenanceLogs.categoryId,
          db.maintenanceCategories.id,
        ),
      );

  $$MaintenanceCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$MaintenanceCategoriesTableTableManager(
      $_db,
      $_db.maintenanceCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MaintenanceLogsTableFilterComposer
    extends Composer<_$AppDatabase, $MaintenanceLogsTable> {
  $$MaintenanceLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serviceDate => $composableBuilder(
    column: $table.serviceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get odometerReading => $composableBuilder(
    column: $table.odometerReading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceProvider => $composableBuilder(
    column: $table.serviceProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get partsCost => $composableBuilder(
    column: $table.partsCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get laborCost => $composableBuilder(
    column: $table.laborCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get laborHours => $composableBuilder(
    column: $table.laborHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MaintenanceCategoriesTableFilterComposer get categoryId {
    final $$MaintenanceCategoriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.maintenanceCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceCategoriesTableFilterComposer(
                $db: $db,
                $table: $db.maintenanceCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MaintenanceLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $MaintenanceLogsTable> {
  $$MaintenanceLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serviceDate => $composableBuilder(
    column: $table.serviceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get odometerReading => $composableBuilder(
    column: $table.odometerReading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceProvider => $composableBuilder(
    column: $table.serviceProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get partsCost => $composableBuilder(
    column: $table.partsCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get laborCost => $composableBuilder(
    column: $table.laborCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get laborHours => $composableBuilder(
    column: $table.laborHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MaintenanceCategoriesTableOrderingComposer get categoryId {
    final $$MaintenanceCategoriesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.maintenanceCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceCategoriesTableOrderingComposer(
                $db: $db,
                $table: $db.maintenanceCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MaintenanceLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaintenanceLogsTable> {
  $$MaintenanceLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get serviceDate => $composableBuilder(
    column: $table.serviceDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get odometerReading => $composableBuilder(
    column: $table.odometerReading,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serviceProvider => $composableBuilder(
    column: $table.serviceProvider,
    builder: (column) => column,
  );

  GeneratedColumn<double> get partsCost =>
      $composableBuilder(column: $table.partsCost, builder: (column) => column);

  GeneratedColumn<double> get laborCost =>
      $composableBuilder(column: $table.laborCost, builder: (column) => column);

  GeneratedColumn<double> get totalCost =>
      $composableBuilder(column: $table.totalCost, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<double> get laborHours => $composableBuilder(
    column: $table.laborHours,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MaintenanceCategoriesTableAnnotationComposer get categoryId {
    final $$MaintenanceCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.maintenanceCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.maintenanceCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MaintenanceLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaintenanceLogsTable,
          MaintenanceLog,
          $$MaintenanceLogsTableFilterComposer,
          $$MaintenanceLogsTableOrderingComposer,
          $$MaintenanceLogsTableAnnotationComposer,
          $$MaintenanceLogsTableCreateCompanionBuilder,
          $$MaintenanceLogsTableUpdateCompanionBuilder,
          (MaintenanceLog, $$MaintenanceLogsTableReferences),
          MaintenanceLog,
          PrefetchHooks Function({bool vehicleId, bool categoryId})
        > {
  $$MaintenanceLogsTableTableManager(
    _$AppDatabase db,
    $MaintenanceLogsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenanceLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaintenanceLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaintenanceLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> serviceDate = const Value.absent(),
                Value<double> odometerReading = const Value.absent(),
                Value<String?> serviceProvider = const Value.absent(),
                Value<double> partsCost = const Value.absent(),
                Value<double> laborCost = const Value.absent(),
                Value<double> totalCost = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<double?> laborHours = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MaintenanceLogsCompanion(
                id: id,
                vehicleId: vehicleId,
                categoryId: categoryId,
                title: title,
                description: description,
                serviceDate: serviceDate,
                odometerReading: odometerReading,
                serviceProvider: serviceProvider,
                partsCost: partsCost,
                laborCost: laborCost,
                totalCost: totalCost,
                currency: currency,
                laborHours: laborHours,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vehicleId,
                required int categoryId,
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime serviceDate,
                required double odometerReading,
                Value<String?> serviceProvider = const Value.absent(),
                Value<double> partsCost = const Value.absent(),
                Value<double> laborCost = const Value.absent(),
                Value<double> totalCost = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<double?> laborHours = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MaintenanceLogsCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                categoryId: categoryId,
                title: title,
                description: description,
                serviceDate: serviceDate,
                odometerReading: odometerReading,
                serviceProvider: serviceProvider,
                partsCost: partsCost,
                laborCost: laborCost,
                totalCost: totalCost,
                currency: currency,
                laborHours: laborHours,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MaintenanceLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable:
                                    $$MaintenanceLogsTableReferences
                                        ._vehicleIdTable(db),
                                referencedColumn:
                                    $$MaintenanceLogsTableReferences
                                        ._vehicleIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable:
                                    $$MaintenanceLogsTableReferences
                                        ._categoryIdTable(db),
                                referencedColumn:
                                    $$MaintenanceLogsTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MaintenanceLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaintenanceLogsTable,
      MaintenanceLog,
      $$MaintenanceLogsTableFilterComposer,
      $$MaintenanceLogsTableOrderingComposer,
      $$MaintenanceLogsTableAnnotationComposer,
      $$MaintenanceLogsTableCreateCompanionBuilder,
      $$MaintenanceLogsTableUpdateCompanionBuilder,
      (MaintenanceLog, $$MaintenanceLogsTableReferences),
      MaintenanceLog,
      PrefetchHooks Function({bool vehicleId, bool categoryId})
    >;
typedef $$MaintenanceSchedulesTableCreateCompanionBuilder =
    MaintenanceSchedulesCompanion Function({
      Value<int> id,
      required int vehicleId,
      required int categoryId,
      required String title,
      Value<double?> intervalKm,
      Value<int?> intervalMonths,
      Value<DateTime?> lastServiceDate,
      Value<double?> lastServiceKm,
      Value<DateTime?> nextDueDate,
      Value<double?> nextDueKm,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });
typedef $$MaintenanceSchedulesTableUpdateCompanionBuilder =
    MaintenanceSchedulesCompanion Function({
      Value<int> id,
      Value<int> vehicleId,
      Value<int> categoryId,
      Value<String> title,
      Value<double?> intervalKm,
      Value<int?> intervalMonths,
      Value<DateTime?> lastServiceDate,
      Value<double?> lastServiceKm,
      Value<DateTime?> nextDueDate,
      Value<double?> nextDueKm,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

final class $$MaintenanceSchedulesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MaintenanceSchedulesTable,
          MaintenanceSchedule
        > {
  $$MaintenanceSchedulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias(
        $_aliasNameGenerator(db.maintenanceSchedules.vehicleId, db.vehicles.id),
      );

  $$VehiclesTableProcessedTableManager get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id')!;

    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MaintenanceCategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.maintenanceCategories.createAlias(
        $_aliasNameGenerator(
          db.maintenanceSchedules.categoryId,
          db.maintenanceCategories.id,
        ),
      );

  $$MaintenanceCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$MaintenanceCategoriesTableTableManager(
      $_db,
      $_db.maintenanceCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MaintenanceSchedulesTableFilterComposer
    extends Composer<_$AppDatabase, $MaintenanceSchedulesTable> {
  $$MaintenanceSchedulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalMonths => $composableBuilder(
    column: $table.intervalMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastServiceDate => $composableBuilder(
    column: $table.lastServiceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lastServiceKm => $composableBuilder(
    column: $table.lastServiceKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get nextDueKm => $composableBuilder(
    column: $table.nextDueKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MaintenanceCategoriesTableFilterComposer get categoryId {
    final $$MaintenanceCategoriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.maintenanceCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceCategoriesTableFilterComposer(
                $db: $db,
                $table: $db.maintenanceCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MaintenanceSchedulesTableOrderingComposer
    extends Composer<_$AppDatabase, $MaintenanceSchedulesTable> {
  $$MaintenanceSchedulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalMonths => $composableBuilder(
    column: $table.intervalMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastServiceDate => $composableBuilder(
    column: $table.lastServiceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lastServiceKm => $composableBuilder(
    column: $table.lastServiceKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get nextDueKm => $composableBuilder(
    column: $table.nextDueKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MaintenanceCategoriesTableOrderingComposer get categoryId {
    final $$MaintenanceCategoriesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.maintenanceCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceCategoriesTableOrderingComposer(
                $db: $db,
                $table: $db.maintenanceCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MaintenanceSchedulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaintenanceSchedulesTable> {
  $$MaintenanceSchedulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalMonths => $composableBuilder(
    column: $table.intervalMonths,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastServiceDate => $composableBuilder(
    column: $table.lastServiceDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lastServiceKm => $composableBuilder(
    column: $table.lastServiceKm,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get nextDueKm =>
      $composableBuilder(column: $table.nextDueKm, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MaintenanceCategoriesTableAnnotationComposer get categoryId {
    final $$MaintenanceCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.maintenanceCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.maintenanceCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MaintenanceSchedulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaintenanceSchedulesTable,
          MaintenanceSchedule,
          $$MaintenanceSchedulesTableFilterComposer,
          $$MaintenanceSchedulesTableOrderingComposer,
          $$MaintenanceSchedulesTableAnnotationComposer,
          $$MaintenanceSchedulesTableCreateCompanionBuilder,
          $$MaintenanceSchedulesTableUpdateCompanionBuilder,
          (MaintenanceSchedule, $$MaintenanceSchedulesTableReferences),
          MaintenanceSchedule,
          PrefetchHooks Function({bool vehicleId, bool categoryId})
        > {
  $$MaintenanceSchedulesTableTableManager(
    _$AppDatabase db,
    $MaintenanceSchedulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenanceSchedulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaintenanceSchedulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MaintenanceSchedulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> vehicleId = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<double?> intervalKm = const Value.absent(),
                Value<int?> intervalMonths = const Value.absent(),
                Value<DateTime?> lastServiceDate = const Value.absent(),
                Value<double?> lastServiceKm = const Value.absent(),
                Value<DateTime?> nextDueDate = const Value.absent(),
                Value<double?> nextDueKm = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MaintenanceSchedulesCompanion(
                id: id,
                vehicleId: vehicleId,
                categoryId: categoryId,
                title: title,
                intervalKm: intervalKm,
                intervalMonths: intervalMonths,
                lastServiceDate: lastServiceDate,
                lastServiceKm: lastServiceKm,
                nextDueDate: nextDueDate,
                nextDueKm: nextDueKm,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int vehicleId,
                required int categoryId,
                required String title,
                Value<double?> intervalKm = const Value.absent(),
                Value<int?> intervalMonths = const Value.absent(),
                Value<DateTime?> lastServiceDate = const Value.absent(),
                Value<double?> lastServiceKm = const Value.absent(),
                Value<DateTime?> nextDueDate = const Value.absent(),
                Value<double?> nextDueKm = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => MaintenanceSchedulesCompanion.insert(
                id: id,
                vehicleId: vehicleId,
                categoryId: categoryId,
                title: title,
                intervalKm: intervalKm,
                intervalMonths: intervalMonths,
                lastServiceDate: lastServiceDate,
                lastServiceKm: lastServiceKm,
                nextDueDate: nextDueDate,
                nextDueKm: nextDueKm,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MaintenanceSchedulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({vehicleId = false, categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (vehicleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.vehicleId,
                                referencedTable:
                                    $$MaintenanceSchedulesTableReferences
                                        ._vehicleIdTable(db),
                                referencedColumn:
                                    $$MaintenanceSchedulesTableReferences
                                        ._vehicleIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable:
                                    $$MaintenanceSchedulesTableReferences
                                        ._categoryIdTable(db),
                                referencedColumn:
                                    $$MaintenanceSchedulesTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MaintenanceSchedulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaintenanceSchedulesTable,
      MaintenanceSchedule,
      $$MaintenanceSchedulesTableFilterComposer,
      $$MaintenanceSchedulesTableOrderingComposer,
      $$MaintenanceSchedulesTableAnnotationComposer,
      $$MaintenanceSchedulesTableCreateCompanionBuilder,
      $$MaintenanceSchedulesTableUpdateCompanionBuilder,
      (MaintenanceSchedule, $$MaintenanceSchedulesTableReferences),
      MaintenanceSchedule,
      PrefetchHooks Function({bool vehicleId, bool categoryId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$FuelEntriesTableTableManager get fuelEntries =>
      $$FuelEntriesTableTableManager(_db, _db.fuelEntries);
  $$MaintenanceCategoriesTableTableManager get maintenanceCategories =>
      $$MaintenanceCategoriesTableTableManager(_db, _db.maintenanceCategories);
  $$MaintenanceLogsTableTableManager get maintenanceLogs =>
      $$MaintenanceLogsTableTableManager(_db, _db.maintenanceLogs);
  $$MaintenanceSchedulesTableTableManager get maintenanceSchedules =>
      $$MaintenanceSchedulesTableTableManager(_db, _db.maintenanceSchedules);
}
