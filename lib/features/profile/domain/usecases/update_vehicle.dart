import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:ride_now_app/features/ride/domain/entities/vehicle.dart';

class UpdateVehicle implements Usecase<Vehicle, UpdateVehicleParams> {
  final ProfileRepository _profileRepository;
  const UpdateVehicle(this._profileRepository);
  @override
  Future<Either<Failure, Vehicle>> call(UpdateVehicleParams params) {
    return _profileRepository.updateVehicle(
      vehicleId: params.vehicleId,
      vehicleRegistrationNumber: params.vehicleRegistrationNumber,
      manufacturer: params.manufacturer,
      model: params.model,
      seats: params.seats,
      averageFuelConsumptions: params.averageFuelConsumptions,
      vehicleTypeId: params.vehicleTypeId,
    );
  }
}

class UpdateVehicleParams {
  final int vehicleId;
  final String vehicleRegistrationNumber;
  final String manufacturer;
  final String model;
  final int seats;
  final double averageFuelConsumptions;
  final int vehicleTypeId;

  UpdateVehicleParams({
    required this.vehicleId,
    required this.vehicleRegistrationNumber,
    required this.manufacturer,
    required this.model,
    required this.seats,
    required this.averageFuelConsumptions,
    required this.vehicleTypeId,
  });
}
