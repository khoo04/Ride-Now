import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/common/entities/user.dart';
import 'package:ride_now_app/core/constants/constants.dart';
import 'package:ride_now_app/core/error/exception.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/network/connection_checker.dart';
import 'package:ride_now_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ride_now_app/features/profile/domain/entities/balance_data.dart';
import 'package:ride_now_app/features/profile/domain/entities/voucher.dart';
import 'package:ride_now_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:ride_now_app/features/ride/domain/entities/vehicle.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _profileRemoteDataSource;
  final ConnectionChecker _connectionChecker;

  ProfileRepositoryImpl(this._profileRemoteDataSource, this._connectionChecker);

  @override
  Future<Either<Failure, List<Vehicle>>> getUserVehicles() async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final vehicles = await _profileRemoteDataSource.getUserVehicles();

      return right(vehicles);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Vehicle>> createVehicle(
      {required String vehicleRegistrationNumber,
      required String manufacturer,
      required String model,
      required int seats,
      required double averageFuelConsumptions,
      required int vehicleTypeId}) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final vehicle = await _profileRemoteDataSource.createVehicle(
        vehicleRegistrationNumber: vehicleRegistrationNumber,
        manufacturer: manufacturer,
        model: model,
        seats: seats,
        averageFuelConsumptions: averageFuelConsumptions,
        vehicleTypeId: vehicleTypeId,
      );

      return right(vehicle);
    } on ServerValidatorException catch (e) {
      return left(Failure(e.message, e.errors));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Vehicle>> updateVehicle({
    required int vehicleId,
    required String? vehicleRegistrationNumber,
    required String? manufacturer,
    required String? model,
    required int? seats,
    required double? averageFuelConsumptions,
    required int? vehicleTypeId,
  }) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final vehicle = await _profileRemoteDataSource.updateVehicle(
        vehicleId: vehicleId,
        vehicleRegistrationNumber: vehicleRegistrationNumber,
        manufacturer: manufacturer,
        model: model,
        seats: seats,
        averageFuelConsumptions: averageFuelConsumptions,
        vehicleTypeId: vehicleTypeId,
      );

      return right(vehicle);
    } on ServerValidatorException catch (e) {
      return left(Failure(e.message, e.errors));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteVehicle({required int vehicleId}) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final vehicle = await _profileRemoteDataSource.deleteVehicle(
        vehicleId: vehicleId,
      );
      return right(vehicle);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Voucher>>> getUserVouchers() async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final vouchers = await _profileRemoteDataSource.getUserVouchers();

      return right(vouchers);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile({
    String? name,
    String? phone,
    String? email,
    String? oldPassword,
    String? newPassword,
    File? profileImage,
  }) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final updatedUser = await _profileRemoteDataSource.updateUserProfile(
        name: name,
        phone: phone,
        email: email,
        oldPassword: oldPassword,
        newPassword: newPassword,
        profileImage: profileImage,
      );

      return right(updatedUser);
    } on ServerValidatorException catch (e) {
      return left(Failure(e.message, e.errors));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, BalanceData>> getUserBalance() async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final balanceData = await _profileRemoteDataSource.getUserBalance();

      return right(balanceData);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
