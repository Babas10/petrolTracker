// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiErrorDto _$ApiErrorDtoFromJson(Map<String, dynamic> json) => ApiErrorDto(
  statusCode: (json['statusCode'] as num).toInt(),
  message: json['message'] as String,
  details: json['details'] as String?,
  validationErrors: (json['validationErrors'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$ApiErrorDtoToJson(ApiErrorDto instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'message': instance.message,
      'details': instance.details,
      'validationErrors': instance.validationErrors,
    };

ApiResponseDto<T> _$ApiResponseDtoFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => ApiResponseDto<T>(
  success: json['success'] as bool,
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
  message: json['message'] as String?,
  error: json['error'] == null
      ? null
      : ApiErrorDto.fromJson(json['error'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ApiResponseDtoToJson<T>(
  ApiResponseDto<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
  'message': instance.message,
  'error': instance.error,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);

HealthCheckDto _$HealthCheckDtoFromJson(Map<String, dynamic> json) =>
    HealthCheckDto(
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      version: json['version'] as String,
    );

Map<String, dynamic> _$HealthCheckDtoToJson(HealthCheckDto instance) =>
    <String, dynamic>{
      'status': instance.status,
      'timestamp': instance.timestamp.toIso8601String(),
      'version': instance.version,
    };
