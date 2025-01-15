import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ride_now_app/core/constants/api_routes.dart';
import 'package:ride_now_app/core/constants/constants.dart';
import 'package:ride_now_app/core/error/exception.dart';
import 'package:ride_now_app/core/network/app_response.dart';
import 'package:ride_now_app/core/network/network_client.dart';
import 'package:ride_now_app/features/auth/data/models/user_model.dart';
import 'package:ride_now_app/features/profile/data/models/balance_data_model.dart';
import 'package:ride_now_app/features/profile/data/models/voucher_model.dart';
import 'package:ride_now_app/features/profile/domain/entities/balance_data.dart';
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
    String? vehicleRegistrationNumber,
    String? manufacturer,
    String? model,
    int? seats,
    double? averageFuelConsumptions,
    int? vehicleTypeId,
  });

  Future<bool> deleteVehicle({required int vehicleId});

  Future<List<VoucherModel>> getUserVouchers();

  Future<UserModel> updateUserProfile({
    String? name,
    String? phone,
    String? email,
    String? oldPassword,
    String? newPassword,
    File? profileImage,
  });

  Future<BalanceDataModel> getUserBalance();
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
    } on ServerException {
      rethrow;
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
      } else if (response.data["errors"] != null) {
        throw ServerValidatorException.fromJson(response.data);
      } else {
        throw ServerException(response.data["message"]);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException(Constants.connectionTimeout);
      }
      throw ServerException(e.message!);
    } on ServerValidatorException {
      rethrow;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VehicleModel> updateVehicle({
    required int vehicleId,
    String? vehicleRegistrationNumber,
    String? manufacturer,
    String? model,
    int? seats,
    double? averageFuelConsumptions,
    int? vehicleTypeId,
  }) async {
    try {
      final token = await _flutterSecureStorage.read(key: "access_token");

      Map<String, dynamic> requestBody = {};
      if (vehicleRegistrationNumber != null) {
        requestBody.addAll({
          "vehicle_registration_number": vehicleRegistrationNumber,
        });
      }

      if (manufacturer != null) {
        requestBody.addAll({
          "manufacturer": manufacturer,
        });
      }

      if (model != null) {
        requestBody.addAll({
          "model": model,
        });
      }

      if (seats != null) {
        requestBody.addAll({
          "seats": seats,
        });
      }
      if (averageFuelConsumptions != null) {
        requestBody.addAll({
          "average_fuel_consumptions": averageFuelConsumptions,
        });
      }
      if (vehicleTypeId != null) {
        requestBody.addAll({
          "vehicle_type_id": vehicleTypeId,
        });
      }

      final response = await _networkClient.invoke(
        "${ApiRoutes.vehicle}/$vehicleId",
        RequestType.patch,
        requestBody: requestBody,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final appResponse = AppResponse.fromJson(response.data);
        return VehicleModel.fromJson(appResponse.data);
      } else if (response.data["errors"] != null) {
        throw ServerValidatorException.fromJson(response.data);
      } else {
        throw ServerException(response.data["message"]);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException(Constants.connectionTimeout);
      }
      throw ServerException(e.message!);
    } on ServerValidatorException {
      rethrow;
    } on ServerException {
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
        throw ServerException(response.data["message"]);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException(Constants.connectionTimeout);
      }
      throw ServerException(e.message!);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<VoucherModel>> getUserVouchers() async {
    final token = await _flutterSecureStorage.read(key: "access_token");

    try {
      final response = await _networkClient.invoke(
        ApiRoutes.vouchers,
        RequestType.get,
        headers: {"Authorization": "Bearer $token"},
      );

      final appResponse = AppResponse.fromJson(response.data);

      if (response.statusCode == 200) {
        return (appResponse.data as List)
            .map((e) => VoucherModel.fromJson(e))
            .toList();
      } else {
        throw ServerException(appResponse.message);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException(Constants.connectionTimeout);
      }
      throw ServerException(e.message!);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    String? name,
    String? phone,
    String? email,
    String? oldPassword,
    String? newPassword,
    File? profileImage,
  }) async {
    final token = await _flutterSecureStorage.read(key: "access_token");

    Map<String, dynamic> body = {};
    if (name != null) {
      body.addAll({
        "name": name,
      });
    }

    if (profileImage != null) {
      body.addAll({
        "profile_picture": await MultipartFile.fromFile(profileImage.path,
            filename: profileImage.path.split('/').last)
      });
    }

    if (newPassword != null && oldPassword != null) {
      body.addAll({
        "new_password": newPassword,
        "old_password": oldPassword,
      });
    }

    if (email != null) {
      body.addAll({
        "email": email,
      });
    }

    if (phone != null) {
      body.addAll({
        "phone_number": phone,
      });
    }

    FormData formData = FormData.fromMap(body);

    try {
      final response = await _networkClient.invoke(
          ApiRoutes.updateProfile, RequestType.post,
          headers: {"Authorization": "Bearer $token"}, requestBody: formData);

      final appResponse = AppResponse.fromJson(response.data);

      if (response.statusCode == 200) {
        return UserModel.fromJson(appResponse.data);
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
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<BalanceDataModel> getUserBalance() async {
    final token = await _flutterSecureStorage.read(key: "access_token");

    try {
      final response = await _networkClient.invoke(
        ApiRoutes.balance,
        RequestType.get,
        headers: {"Authorization": "Bearer $token"},
      );

      final appResponse = AppResponse.fromJson(response.data);

      if (response.statusCode == 200) {
        return BalanceDataModel.fromJson(appResponse.data);
      } else {
        throw ServerException(appResponse.message);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException(Constants.connectionTimeout);
      }
      throw ServerException(e.message!);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
