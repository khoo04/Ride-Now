import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/common/entities/user.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/features/profile/domain/entities/balance_data.dart';
import 'package:ride_now_app/features/profile/domain/entities/voucher.dart';
import 'package:ride_now_app/features/ride/domain/entities/vehicle.dart';

abstract interface class ProfileRepository {
  Future<Either<Failure, List<Vehicle>>> getUserVehicles();

  Future<Either<Failure, Vehicle>> createVehicle({
    required String vehicleRegistrationNumber,
    required String manufacturer,
    required String model,
    required int seats,
    required double averageFuelConsumptions,
    required int vehicleTypeId,
  });

  Future<Either<Failure, Vehicle>> updateVehicle({
    required int vehicleId,
    required String? vehicleRegistrationNumber,
    required String? manufacturer,
    required String? model,
    required int? seats,
    required double? averageFuelConsumptions,
    required int? vehicleTypeId,
  });

  Future<Either<Failure, bool>> deleteVehicle({required int vehicleId});

  Future<Either<Failure, List<Voucher>>> getUserVouchers();

  Future<Either<Failure, User>> updateUserProfile({
    String? name,
    String? phone,
    String? email,
    String? oldPassword,
    String? newPassword,
    File? profileImage,
  });

  Future<Either<Failure, BalanceData>> getUserBalance();
}
