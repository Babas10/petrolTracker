// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'currency_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

CurrencyInfo _$CurrencyInfoFromJson(Map<String, dynamic> json) {
  return _CurrencyInfo.fromJson(json);
}

/// @nodoc
mixin _$CurrencyInfo {
  /// The 3-letter ISO 4217 currency code (e.g., 'USD', 'EUR')
  String get code => throw _privateConstructorUsedError;

  /// The full display name of the currency (e.g., 'US Dollar', 'Euro')
  String get name => throw _privateConstructorUsedError;

  /// The currency symbol (e.g., '$', '€', '¥')
  String get symbol => throw _privateConstructorUsedError;

  /// Number of decimal places typically used (usually 2)
  int get decimalPlaces => throw _privateConstructorUsedError;

  /// List of countries that primarily use this currency
  List<String> get countries => throw _privateConstructorUsedError;

  /// Alternative symbols that might be used (e.g., 'US$' for USD in international contexts)
  List<String> get alternativeSymbols => throw _privateConstructorUsedError;

  /// Whether this currency is commonly used internationally
  bool get isInternational => throw _privateConstructorUsedError;

  /// Regional variants or notes about usage
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CurrencyInfoCopyWith<CurrencyInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurrencyInfoCopyWith<$Res> {
  factory $CurrencyInfoCopyWith(
          CurrencyInfo value, $Res Function(CurrencyInfo) then) =
      _$CurrencyInfoCopyWithImpl<$Res, CurrencyInfo>;
  @useResult
  $Res call(
      {String code,
      String name,
      String symbol,
      int decimalPlaces,
      List<String> countries,
      List<String> alternativeSymbols,
      bool isInternational,
      String? notes});
}

/// @nodoc
class _$CurrencyInfoCopyWithImpl<$Res, $Val extends CurrencyInfo>
    implements $CurrencyInfoCopyWith<$Res> {
  _$CurrencyInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? symbol = null,
    Object? decimalPlaces = null,
    Object? countries = null,
    Object? alternativeSymbols = null,
    Object? isInternational = null,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      decimalPlaces: null == decimalPlaces
          ? _value.decimalPlaces
          : decimalPlaces // ignore: cast_nullable_to_non_nullable
              as int,
      countries: null == countries
          ? _value.countries
          : countries // ignore: cast_nullable_to_non_nullable
              as List<String>,
      alternativeSymbols: null == alternativeSymbols
          ? _value.alternativeSymbols
          : alternativeSymbols // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isInternational: null == isInternational
          ? _value.isInternational
          : isInternational // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CurrencyInfoImplCopyWith<$Res>
    implements $CurrencyInfoCopyWith<$Res> {
  factory _$$CurrencyInfoImplCopyWith(
          _$CurrencyInfoImpl value, $Res Function(_$CurrencyInfoImpl) then) =
      __$$CurrencyInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String code,
      String name,
      String symbol,
      int decimalPlaces,
      List<String> countries,
      List<String> alternativeSymbols,
      bool isInternational,
      String? notes});
}

/// @nodoc
class __$$CurrencyInfoImplCopyWithImpl<$Res>
    extends _$CurrencyInfoCopyWithImpl<$Res, _$CurrencyInfoImpl>
    implements _$$CurrencyInfoImplCopyWith<$Res> {
  __$$CurrencyInfoImplCopyWithImpl(
      _$CurrencyInfoImpl _value, $Res Function(_$CurrencyInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? name = null,
    Object? symbol = null,
    Object? decimalPlaces = null,
    Object? countries = null,
    Object? alternativeSymbols = null,
    Object? isInternational = null,
    Object? notes = freezed,
  }) {
    return _then(_$CurrencyInfoImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      decimalPlaces: null == decimalPlaces
          ? _value.decimalPlaces
          : decimalPlaces // ignore: cast_nullable_to_non_nullable
              as int,
      countries: null == countries
          ? _value._countries
          : countries // ignore: cast_nullable_to_non_nullable
              as List<String>,
      alternativeSymbols: null == alternativeSymbols
          ? _value._alternativeSymbols
          : alternativeSymbols // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isInternational: null == isInternational
          ? _value.isInternational
          : isInternational // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CurrencyInfoImpl implements _CurrencyInfo {
  const _$CurrencyInfoImpl(
      {required this.code,
      required this.name,
      required this.symbol,
      required this.decimalPlaces,
      required final List<String> countries,
      final List<String> alternativeSymbols = const [],
      this.isInternational = false,
      this.notes})
      : _countries = countries,
        _alternativeSymbols = alternativeSymbols;

  factory _$CurrencyInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CurrencyInfoImplFromJson(json);

  /// The 3-letter ISO 4217 currency code (e.g., 'USD', 'EUR')
  @override
  final String code;

  /// The full display name of the currency (e.g., 'US Dollar', 'Euro')
  @override
  final String name;

  /// The currency symbol (e.g., '$', '€', '¥')
  @override
  final String symbol;

  /// Number of decimal places typically used (usually 2)
  @override
  final int decimalPlaces;

  /// List of countries that primarily use this currency
  final List<String> _countries;

  /// List of countries that primarily use this currency
  @override
  List<String> get countries {
    if (_countries is EqualUnmodifiableListView) return _countries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_countries);
  }

  /// Alternative symbols that might be used (e.g., 'US$' for USD in international contexts)
  final List<String> _alternativeSymbols;

  /// Alternative symbols that might be used (e.g., 'US$' for USD in international contexts)
  @override
  @JsonKey()
  List<String> get alternativeSymbols {
    if (_alternativeSymbols is EqualUnmodifiableListView)
      return _alternativeSymbols;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alternativeSymbols);
  }

  /// Whether this currency is commonly used internationally
  @override
  @JsonKey()
  final bool isInternational;

  /// Regional variants or notes about usage
  @override
  final String? notes;

  @override
  String toString() {
    return 'CurrencyInfo(code: $code, name: $name, symbol: $symbol, decimalPlaces: $decimalPlaces, countries: $countries, alternativeSymbols: $alternativeSymbols, isInternational: $isInternational, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CurrencyInfoImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.decimalPlaces, decimalPlaces) ||
                other.decimalPlaces == decimalPlaces) &&
            const DeepCollectionEquality()
                .equals(other._countries, _countries) &&
            const DeepCollectionEquality()
                .equals(other._alternativeSymbols, _alternativeSymbols) &&
            (identical(other.isInternational, isInternational) ||
                other.isInternational == isInternational) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      code,
      name,
      symbol,
      decimalPlaces,
      const DeepCollectionEquality().hash(_countries),
      const DeepCollectionEquality().hash(_alternativeSymbols),
      isInternational,
      notes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CurrencyInfoImplCopyWith<_$CurrencyInfoImpl> get copyWith =>
      __$$CurrencyInfoImplCopyWithImpl<_$CurrencyInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CurrencyInfoImplToJson(
      this,
    );
  }
}

abstract class _CurrencyInfo implements CurrencyInfo {
  const factory _CurrencyInfo(
      {required final String code,
      required final String name,
      required final String symbol,
      required final int decimalPlaces,
      required final List<String> countries,
      final List<String> alternativeSymbols,
      final bool isInternational,
      final String? notes}) = _$CurrencyInfoImpl;

  factory _CurrencyInfo.fromJson(Map<String, dynamic> json) =
      _$CurrencyInfoImpl.fromJson;

  @override

  /// The 3-letter ISO 4217 currency code (e.g., 'USD', 'EUR')
  String get code;
  @override

  /// The full display name of the currency (e.g., 'US Dollar', 'Euro')
  String get name;
  @override

  /// The currency symbol (e.g., '$', '€', '¥')
  String get symbol;
  @override

  /// Number of decimal places typically used (usually 2)
  int get decimalPlaces;
  @override

  /// List of countries that primarily use this currency
  List<String> get countries;
  @override

  /// Alternative symbols that might be used (e.g., 'US$' for USD in international contexts)
  List<String> get alternativeSymbols;
  @override

  /// Whether this currency is commonly used internationally
  bool get isInternational;
  @override

  /// Regional variants or notes about usage
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$CurrencyInfoImplCopyWith<_$CurrencyInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}