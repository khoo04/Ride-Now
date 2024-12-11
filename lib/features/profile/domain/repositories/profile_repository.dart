import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
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
    required String vehicleRegistrationNumber,
    required String manufacturer,
    required String model,
    required int seats,
    required double averageFuelConsumptions,
    required int vehicleTypeId,
  });

  Future<Either<Failure, bool>> deleteVehicle({required int vehicleId});
}
