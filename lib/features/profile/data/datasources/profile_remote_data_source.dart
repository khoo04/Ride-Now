import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ride_now_app/core/constants/api_routes.dart';
import 'package:ride_now_app/core/constants/constants.dart';
import 'package:ride_now_app/core/error/exception.dart';
import 'package:ride_now_app/core/network/app_response.dart';
import 'package:ride_now_app/core/network/network_client.dart';
import 'package:ride_now_app/features/ride/data/models/vehicle_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<List<VehicleModel>> getUserVehicles();
  Future<VehicleModel> createVehicle({
    required String vehicleRegistrationNumber,
    required String manufacturer,
    required String model,
    required int seats,
    required double averageFuelConsumptions,
    required int vehicleTypeId,
  });

  Future<VehicleModel> updateVehicle({
    required int vehicleId,
    required String vehicleRegistrationNumber,
    required String manufacturer,
    required String model,
    required int seats,
    required double averageFuelConsumptions,
    required int vehicleTypeId,
  });

  Future<bool> deleteVehicle({required int vehicleId});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final NetworkClient _networkClient;
  final FlutterSecureStorage _flutterSecureStorage;
  ProfileRemoteDataSourceImpl(this._networkClient, this._flutterSecureStorage);

  @override
  Future<List<VehicleModel>> getUserVehicles() async {
    final token = await _flutterSecureStorage.read(key: "access_token");

    try {
      final response = await _networkClient.invoke(
        ApiRoutes.vehicle,
        RequestType.get,
        headers: {"Authorization": "Bearer $token"},
      );

      final appResponse = AppResponse.fromJson(response.data);

      if (response.statusCode == 200) {
        return (appResponse.data as List)
            .map((e) => VehicleModel.fromJson(e))
            .toList();
      } else {
        throw ServerException(appResponse.message);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException(Constants.connectionTimeout);
      }
      throw ServerException(e.message!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VehicleModel> createVehicle({
    required String vehicleRegistrationNumber,
    required String manufacturer,
    required String model,
    required int seats,
    required double averageFuelConsumptions,
    required int vehicleTypeId,
  }) async {
    try {
      final token = await _flutterSecureStorage.read(key: "access_token");
      final response = await _networkClient.invoke(
        ApiRoutes.vehicle,
        RequestType.post,
        requestBody: {
          "vehicle_registration_number": vehicleRegistrationNumber,
          "manufacturer": manufacturer,
          "model": model,
          "seats": seats,
          "average_fuel_consumptions": averageFuelConsumptions,
          "vehicle_type_id": vehicleTypeId,
        },
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final appResponse = AppResponse.fromJson(response.data);
        return VehicleModel.fromJson(appResponse.data);
      } else {
        throw ServerValidatorException.fromJson(response.data);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException(Constants.connectionTimeout);
      }
      throw ServerException(e.message!);
    } on ServerValidatorException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VehicleModel> updateVehicle({
    required int vehicleId,
    required String vehicleRegistrationNumber,
    required String manufacturer,
    required String model,
    required int seats,
    required double averageFuelConsumptions,
    required int vehicleTypeId,
  }) async {
    try {
      final token = await _flutterSecureStorage.read(key: "access_token");
      final response = await _networkClient.invoke(
        "${ApiRoutes.vehicle}/$vehicleId",
        RequestType.patch,
        requestBody: {
          "vehicle_registration_number": vehicleRegistrationNumber,
          "manufacturer": manufacturer,
          "model": model,
          "seats": seats,
          "average_fuel_consumptions": averageFuelConsumptions,
          "vehicle_type_id": vehicleTypeId,
        },
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final appResponse = AppResponse.fromJson(response.data);
        return VehicleModel.fromJson(appResponse.data);
      } else {
        throw ServerValidatorException.fromJson(response.data);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException(Constants.connectionTimeout);
      }
      throw ServerException(e.message!);
    } on ServerValidatorException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> deleteVehicle({required int vehicleId}) async {
    try {
      final token = await _flutterSecureStorage.read(key: "access_token");
      final response = await _networkClient.invoke(
        "${ApiRoutes.vehicle}/$vehicleId",
        RequestType.delete,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final appResponse = AppResponse.fromJson(response.data);
        return appResponse.success;
      } else {
        throw const ServerException("Unable to delete vehicle");
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException(Constants.connectionTimeout);
      }
      throw ServerException(e.message!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
