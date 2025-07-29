import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'package:petrol_tracker/api/dto/vehicle_dto.dart';
import 'package:petrol_tracker/api/dto/fuel_entry_dto.dart';
import 'package:petrol_tracker/api/dto/api_response_dto.dart';
import 'package:petrol_tracker/providers/vehicle_providers.dart';
import 'package:petrol_tracker/providers/fuel_entry_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// REST API Service for testing data insertion
/// This service is only enabled in debug mode for development/testing purposes
class RestApiService {
  static const int _defaultPort = 8080;
  static const String _version = '1.0.0';
  
  HttpServer? _server;
  final ProviderContainer _container;
  final int port;

  RestApiService({
    required ProviderContainer container,
    this.port = _defaultPort,
  }) : _container = container;

  /// Start the REST API server
  Future<void> start() async {
    if (!kDebugMode) {
      print('REST API is only available in debug mode');
      return;
    }

    // REST API is not supported on web platform
    if (kIsWeb) {
      print('REST API is not available on web platform - use mobile/desktop platforms');
      return;
    }

    try {
      final router = _createRouter();
      final handler = Pipeline()
          .addMiddleware(corsHeaders())
          .addMiddleware(_loggingMiddleware)
          .addMiddleware(_errorHandlingMiddleware)
          .addHandler(router);

      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
      print('🚀 REST API Server started on http://localhost:$port');
      print('📖 API Documentation:');
      print('   GET  /api/health          - Health check');
      print('   GET  /api/vehicles        - List vehicles');
      print('   POST /api/vehicles        - Create vehicle');
      print('   DEL  /api/vehicles/{id}   - Delete vehicle');
      print('   GET  /api/fuel-entries    - List fuel entries');
      print('   POST /api/fuel-entries    - Create fuel entry');
      print('   DEL  /api/fuel-entries/{id} - Delete fuel entry');
      print('   POST /api/bulk/vehicles   - Bulk create vehicles');
      print('   POST /api/bulk/fuel-entries - Bulk create fuel entries');
      print('   POST /api/bulk/data       - Bulk create mixed data');
      print('   DEL  /api/bulk/reset      - Clear all data');
    } catch (e) {
      print('❌ Failed to start REST API server: $e');
      rethrow;
    }
  }

  /// Stop the REST API server
  Future<void> stop() async {
    await _server?.close();
    _server = null;
    print('🛑 REST API Server stopped');
  }

  /// Create the router with all endpoints
  Router _createRouter() {
    final router = Router();

    // Health check
    router.get('/api/health', _handleHealthCheck);

    // Vehicle endpoints
    router.get('/api/vehicles', _handleGetVehicles);
    router.post('/api/vehicles', _handleCreateVehicle);
    router.delete('/api/vehicles/<id>', _handleDeleteVehicle);

    // Fuel entry endpoints
    router.get('/api/fuel-entries', _handleGetFuelEntries);
    router.post('/api/fuel-entries', _handleCreateFuelEntry);
    router.delete('/api/fuel-entries/<id>', _handleDeleteFuelEntry);

    // Bulk operations
    router.post('/api/bulk/vehicles', _handleBulkCreateVehicles);
    router.post('/api/bulk/fuel-entries', _handleBulkCreateFuelEntries);
    router.post('/api/bulk/data', _handleBulkCreateData);
    router.delete('/api/bulk/reset', _handleResetAllData);

    return router;
  }

  /// Logging middleware
  Middleware get _loggingMiddleware => (Handler handler) {
        return (Request request) async {
          final stopwatch = Stopwatch()..start();
          final response = await handler(request);
          stopwatch.stop();
          
          print('${request.method} ${request.url} - ${response.statusCode} (${stopwatch.elapsedMilliseconds}ms)');
          return response;
        };
      };

  /// Error handling middleware
  Middleware get _errorHandlingMiddleware => (Handler handler) {
        return (Request request) async {
          try {
            return await handler(request);
          } catch (e, stackTrace) {
            print('API Error: $e');
            if (kDebugMode) {
              print('Stack trace: $stackTrace');
            }

            final error = ApiResponseDto.error(
              statusCode: 500,
              message: 'Internal server error',
              details: e.toString(),
            );

            return Response.internalServerError(
              body: jsonEncode(error.toJson((data) => data)),
              headers: {'Content-Type': 'application/json'},
            );
          }
        };
      };

  /// Health check endpoint
  Future<Response> _handleHealthCheck(Request request) async {
    final health = HealthCheckDto(
      status: 'healthy',
      timestamp: DateTime.now(),
      version: _version,
    );

    final response = ApiResponseDto.success(
      data: health,
      message: 'REST API is running',
    );

    return Response.ok(
      jsonEncode(response.toJson((data) => (data as HealthCheckDto).toJson())),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// Get all vehicles
  Future<Response> _handleGetVehicles(Request request) async {
    try {
      final vehicleState = await _container.read(vehiclesNotifierProvider.future);
      final vehicles = vehicleState.vehicles
          .map((v) => VehicleResponseDto.fromModel(v))
          .toList();

      final response = ApiResponseDto.success(
        data: vehicles,
        message: 'Vehicles retrieved successfully',
      );

      return Response.ok(
        jsonEncode(response.toJson((data) => (data as List).map((v) => v.toJson()).toList())),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse(400, 'Failed to retrieve vehicles', e.toString());
    }
  }

  /// Create a vehicle
  Future<Response> _handleCreateVehicle(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final dto = VehicleCreateDto.fromJson(json);
      final vehicle = dto.toModel();

      // Validate the vehicle
      final errors = vehicle.validate();
      if (errors.isNotEmpty) {
        return _errorResponse(400, 'Validation failed', null, errors);
      }

      final notifier = _container.read(vehiclesNotifierProvider.notifier);
      final created = await notifier.addVehicle(vehicle);
      final responseDto = VehicleResponseDto.fromModel(created);

      final response = ApiResponseDto.success(
        data: responseDto,
        message: 'Vehicle created successfully',
      );

      return Response.ok(
        jsonEncode(response.toJson((data) => (data as VehicleResponseDto).toJson())),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse(400, 'Failed to create vehicle', e.toString());
    }
  }

  /// Delete a vehicle
  Future<Response> _handleDeleteVehicle(Request request) async {
    try {
      final idStr = request.params['id'];
      final id = int.tryParse(idStr ?? '');
      
      if (id == null) {
        return _errorResponse(400, 'Invalid vehicle ID', 'ID must be a valid integer');
      }

      final notifier = _container.read(vehiclesNotifierProvider.notifier);
      await notifier.deleteVehicle(id);

      final response = ApiResponseDto.success(
        message: 'Vehicle deleted successfully',
      );

      return Response.ok(
        jsonEncode(response.toJson((data) => data)),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse(400, 'Failed to delete vehicle', e.toString());
    }
  }

  /// Get all fuel entries
  Future<Response> _handleGetFuelEntries(Request request) async {
    try {
      final fuelState = await _container.read(fuelEntriesNotifierProvider.future);
      final entries = fuelState.entries
          .map((e) => FuelEntryResponseDto.fromModel(e))
          .toList();

      final response = ApiResponseDto.success(
        data: entries,
        message: 'Fuel entries retrieved successfully',
      );

      return Response.ok(
        jsonEncode(response.toJson((data) => (data as List).map((e) => e.toJson()).toList())),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse(400, 'Failed to retrieve fuel entries', e.toString());
    }
  }

  /// Create a fuel entry
  Future<Response> _handleCreateFuelEntry(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final dto = FuelEntryCreateDto.fromJson(json);
      final entry = dto.toModel();

      // Validate the entry
      final errors = entry.validate();
      if (errors.isNotEmpty) {
        return _errorResponse(400, 'Validation failed', null, errors);
      }

      final notifier = _container.read(fuelEntriesNotifierProvider.notifier);
      final created = await notifier.addFuelEntry(entry);
      final responseDto = FuelEntryResponseDto.fromModel(created);

      final response = ApiResponseDto.success(
        data: responseDto,
        message: 'Fuel entry created successfully',
      );

      return Response.ok(
        jsonEncode(response.toJson((data) => (data as FuelEntryResponseDto).toJson())),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse(400, 'Failed to create fuel entry', e.toString());
    }
  }

  /// Delete a fuel entry
  Future<Response> _handleDeleteFuelEntry(Request request) async {
    try {
      final idStr = request.params['id'];
      final id = int.tryParse(idStr ?? '');
      
      if (id == null) {
        return _errorResponse(400, 'Invalid fuel entry ID', 'ID must be a valid integer');
      }

      final notifier = _container.read(fuelEntriesNotifierProvider.notifier);
      await notifier.deleteFuelEntry(id);

      final response = ApiResponseDto.success(
        message: 'Fuel entry deleted successfully',
      );

      return Response.ok(
        jsonEncode(response.toJson((data) => data)),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse(400, 'Failed to delete fuel entry', e.toString());
    }
  }

  /// Bulk create vehicles
  Future<Response> _handleBulkCreateVehicles(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final dto = BulkVehiclesDto.fromJson(json);

      final created = <VehicleResponseDto>[];
      final errors = <String>[];

      final notifier = _container.read(vehiclesNotifierProvider.notifier);

      for (int i = 0; i < dto.vehicles.length; i++) {
        try {
          final vehicleDto = dto.vehicles[i];
          final vehicle = vehicleDto.toModel();
          
          final validationErrors = vehicle.validate();
          if (validationErrors.isNotEmpty) {
            errors.add('Vehicle $i: ${validationErrors.join(', ')}');
            continue;
          }

          final createdVehicle = await notifier.addVehicle(vehicle);
          created.add(VehicleResponseDto.fromModel(createdVehicle));
        } catch (e) {
          errors.add('Vehicle $i: $e');
        }
      }

      final response = BulkVehiclesResponseDto(
        created: created,
        errors: errors,
      );

      return Response.ok(
        jsonEncode(response.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse(400, 'Failed to bulk create vehicles', e.toString());
    }
  }

  /// Bulk create fuel entries
  Future<Response> _handleBulkCreateFuelEntries(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final dto = BulkFuelEntriesDto.fromJson(json);

      final created = <FuelEntryResponseDto>[];
      final errors = <String>[];

      final notifier = _container.read(fuelEntriesNotifierProvider.notifier);

      for (int i = 0; i < dto.fuelEntries.length; i++) {
        try {
          final entryDto = dto.fuelEntries[i];
          final entry = entryDto.toModel();
          
          final validationErrors = entry.validate();
          if (validationErrors.isNotEmpty) {
            errors.add('Entry $i: ${validationErrors.join(', ')}');
            continue;
          }

          final createdEntry = await notifier.addFuelEntry(entry);
          created.add(FuelEntryResponseDto.fromModel(createdEntry));
        } catch (e) {
          errors.add('Entry $i: $e');
        }
      }

      final response = BulkFuelEntriesResponseDto(
        created: created,
        errors: errors,
      );

      return Response.ok(
        jsonEncode(response.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse(400, 'Failed to bulk create fuel entries', e.toString());
    }
  }

  /// Bulk create mixed data
  Future<Response> _handleBulkCreateData(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final dto = BulkDataDto.fromJson(json);

      final vehiclesCreated = <VehicleResponseDto>[];
      final fuelEntriesCreated = <FuelEntryResponseDto>[];
      final errors = <String>[];

      // Create vehicles first
      if (dto.vehicles != null) {
        final vehicleNotifier = _container.read(vehiclesNotifierProvider.notifier);
        
        for (int i = 0; i < dto.vehicles!.length; i++) {
          try {
            final vehicleDto = dto.vehicles![i];
            final vehicle = vehicleDto.toModel();
            
            final validationErrors = vehicle.validate();
            if (validationErrors.isNotEmpty) {
              errors.add('Vehicle $i: ${validationErrors.join(', ')}');
              continue;
            }

            final created = await vehicleNotifier.addVehicle(vehicle);
            vehiclesCreated.add(VehicleResponseDto.fromModel(created));
          } catch (e) {
            errors.add('Vehicle $i: $e');
          }
        }
      }

      // Create fuel entries
      if (dto.fuelEntries != null) {
        final fuelNotifier = _container.read(fuelEntriesNotifierProvider.notifier);
        
        for (int i = 0; i < dto.fuelEntries!.length; i++) {
          try {
            final entryDto = dto.fuelEntries![i];
            final entry = entryDto.toModel();
            
            final validationErrors = entry.validate();
            if (validationErrors.isNotEmpty) {
              errors.add('Fuel Entry $i: ${validationErrors.join(', ')}');
              continue;
            }

            final created = await fuelNotifier.addFuelEntry(entry);
            fuelEntriesCreated.add(FuelEntryResponseDto.fromModel(created));
          } catch (e) {
            errors.add('Fuel Entry $i: $e');
          }
        }
      }

      final response = BulkDataResponseDto(
        vehiclesCreated: vehiclesCreated,
        fuelEntriesCreated: fuelEntriesCreated,
        errors: errors,
      );

      return Response.ok(
        jsonEncode(response.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse(400, 'Failed to bulk create data', e.toString());
    }
  }

  /// Reset all data
  Future<Response> _handleResetAllData(Request request) async {
    try {
      // Clear all fuel entries first (due to foreign key constraints)
      final fuelNotifier = _container.read(fuelEntriesNotifierProvider.notifier);
      await fuelNotifier.clearAllEntries();

      // Clear all vehicles
      final vehicleNotifier = _container.read(vehiclesNotifierProvider.notifier);
      await vehicleNotifier.clearAllVehicles();

      final response = ApiResponseDto.success(
        message: 'All data cleared successfully',
      );

      return Response.ok(
        jsonEncode(response.toJson((data) => data)),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return _errorResponse(400, 'Failed to reset data', e.toString());
    }
  }

  /// Helper method to create error responses
  Response _errorResponse(
    int statusCode, 
    String message, 
    String? details, 
    [List<String>? validationErrors]
  ) {
    final error = ApiResponseDto.error(
      statusCode: statusCode,
      message: message,
      details: details,
      validationErrors: validationErrors,
    );

    return Response(
      statusCode,
      body: jsonEncode(error.toJson((data) => data)),
      headers: {'Content-Type': 'application/json'},
    );
  }
}