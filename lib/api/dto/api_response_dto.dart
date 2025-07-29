import 'package:json_annotation/json_annotation.dart';

part 'api_response_dto.g.dart';

/// Standard API error response
@JsonSerializable()
class ApiErrorDto {
  final int statusCode;
  final String message;
  final String? details;
  final List<String>? validationErrors;

  const ApiErrorDto({
    required this.statusCode,
    required this.message,
    this.details,
    this.validationErrors,
  });

  factory ApiErrorDto.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ApiErrorDtoToJson(this);
}

/// Success response with data
@JsonSerializable(genericArgumentFactories: true)
class ApiResponseDto<T> {
  final bool success;
  final T? data;
  final String? message;
  final ApiErrorDto? error;

  const ApiResponseDto({
    required this.success,
    this.data,
    this.message,
    this.error,
  });

  factory ApiResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseDtoFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ApiResponseDtoToJson(this, toJsonT);

  /// Create success response
  factory ApiResponseDto.success({T? data, String? message}) {
    return ApiResponseDto(
      success: true,
      data: data,
      message: message,
    );
  }

  /// Create error response
  factory ApiResponseDto.error({
    required int statusCode,
    required String message,
    String? details,
    List<String>? validationErrors,
  }) {
    return ApiResponseDto(
      success: false,
      error: ApiErrorDto(
        statusCode: statusCode,
        message: message,
        details: details,
        validationErrors: validationErrors,
      ),
    );
  }
}

/// Health check response
@JsonSerializable()
class HealthCheckDto {
  final String status;
  final DateTime timestamp;
  final String version;

  const HealthCheckDto({
    required this.status,
    required this.timestamp,
    required this.version,
  });

  factory HealthCheckDto.fromJson(Map<String, dynamic> json) =>
      _$HealthCheckDtoFromJson(json);

  Map<String, dynamic> toJson() => _$HealthCheckDtoToJson(this);
}