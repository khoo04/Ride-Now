import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/common/entities/user.dart';
import 'package:ride_now_app/core/constants/constants.dart';
import 'package:ride_now_app/core/error/exception.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/network/connection_checker.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ride_now_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final ConnectionChecker _connectionChecker;
  final FlutterSecureStorage _flutterSecureStorage;

  AuthRepositoryImpl(this._authRemoteDataSource, this._connectionChecker,
      this._flutterSecureStorage);
  @override
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
    required bool isRemember,
  }) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final user = await _authRemoteDataSource.loginWithEmailPassword(
          email: email, password: password, isRemember: isRemember);

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    final isRemember = await _flutterSecureStorage.read(key: "isRemember");
    try {
      if (isRemember == null || isRemember == "false") {
        return left(Failure(Constants.sessionExpired));
      }
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final user = await _authRemoteDataSource.getUserDataByToken();

      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> rememberMeStatusChecked() async {
    try {
      final isRemember = await _flutterSecureStorage.read(key: "isRemember");

      if (isRemember == null || isRemember == "false") {
        await _flutterSecureStorage.delete(key: "access_token");
        // Call Logout Function
        return logout();
      } else {
        // Token is retained, return a success message or token if needed
        final token = await _flutterSecureStorage.read(key: "access_token");
        if (token != null) {
          return const Right("Token retained"); // Return the token if available
        } else {
          return Left(Failure("No access token found."));
        }
      }
    } catch (e) {
      return Left(Failure("An error occurred: ${e.toString()}"));
    }
  }

  @override
  Future<Either<Failure, String>> logout() async {
    try {
      final res = await _authRemoteDataSource.logout();
      if (res.success) {
        return right(res.message);
      } else {
        return left(Failure(res.message));
      }
    } on ServerException catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> registerUser({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final res = await _authRemoteDataSource.registerUser(
          name: name,
          phone: phone,
          email: email,
          password: password,
          confirmPassword: confirmPassword);
      return right(res);
    } on ServerValidatorException catch (e) {
      return left(Failure(e.message, e.errors));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
