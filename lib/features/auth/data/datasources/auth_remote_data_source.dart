import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ride_now_app/core/constants/api_routes.dart';
import 'package:ride_now_app/core/constants/constants.dart';
import 'package:ride_now_app/core/error/exception.dart';
import 'package:ride_now_app/core/network/app_response.dart';
import 'package:ride_now_app/core/network/network_client.dart';
import 'package:ride_now_app/features/auth/data/models/auth_response.dart';
import 'package:ride_now_app/features/auth/data/models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
    required bool isRemember,
  });
  Future<UserModel> registerUser({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  });
  Future<UserModel> getUserDataByToken();
  Future<AppResponse> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final NetworkClient _networkClient;
  final FlutterSecureStorage _flutterSecureStorage;
  AuthRemoteDataSourceImpl(this._networkClient, this._flutterSecureStorage);
  @override
  Future<UserModel> loginWithEmailPassword(
      {required String email,
      required String password,
      required bool isRemember}) async {
    try {
      final response = await _networkClient.invoke(
        ApiRoutes.login,
        RequestType.post,
        requestBody: {
          "email": email,
          "password": password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final mappedResponse = AuthResponse.fromJson(response.data);
        //Remember user login token or not
        if (isRemember) {
          await _flutterSecureStorage.write(key: "isRemember", value: "true");
        } else {
          await _flutterSecureStorage.write(key: "isRemember", value: "false");
        }

        //Write user access token to storage
        await _flutterSecureStorage.write(
          key: "access_token",
          value: mappedResponse.accessToken,
        );

        return UserModel.fromJson(mappedResponse.data);
      } else {
        throw ServerException(response.statusMessage!);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException(Constants.connectionTimeout);
      }
      throw ServerException(e.message!);
    } on ServerException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<UserModel> getUserDataByToken() async {
    final token = await _flutterSecureStorage.read(key: "access_token");
    try {
      final response = await _networkClient.invoke(
          ApiRoutes.getUserData, RequestType.post,
          headers: {"Authorization": "Bearer $token"});

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data["data"]);
      } else {
        throw ServerException(response.statusMessage!);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException(Constants.connectionTimeout);
      }
      throw ServerException(e.message!);
    } on ServerException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<AppResponse> logout() async {
    final token = await _flutterSecureStorage.read(key: "access_token");
    try {
      final response = await _networkClient.invoke(
          ApiRoutes.logout, RequestType.post,
          headers: {"Authorization": "Bearer $token"});

      if (response.statusCode == 200 || response.statusCode == 201) {
        //Delete token from local storage
        await _flutterSecureStorage.write(key: "isRemember", value: "false");
        await _flutterSecureStorage.delete(key: "access_token");
        return AppResponse.fromJson(response.data);
      } else {
        throw ServerException(response.statusMessage!);
      }
    } on ServerException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  Future<UserModel> registerUser({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _networkClient.invoke(
        ApiRoutes.register,
        RequestType.post,
        requestBody: {
          "name": name,
          "email": email,
          "password": password,
          "password_confirmation": confirmPassword,
          "phone_number": phone,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final mappedResponse = AuthResponse.fromJson(response.data);
        //Assume when the account is successfully register, keep user login state
        await _flutterSecureStorage.write(key: "isRemember", value: "true");

        //Write user access token to storage
        await _flutterSecureStorage.write(
          key: "access_token",
          value: mappedResponse.accessToken,
        );

        return UserModel.fromJson(mappedResponse.data);
      } else {
        throw ServerValidatorException.fromJson(response.data);
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw const ServerException(Constants.connectionTimeout);
      }
      throw ServerException(e.message!);
    } on ServerException catch (e) {
      throw ServerException(e.message);
    }
  }
}
