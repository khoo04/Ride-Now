import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/profile/domain/repositories/profile_repository.dart';

class DeleteVehicle implements Usecase<bool, DeleteVehicleParams> {
  final ProfileRepository _profileRepository;
  const DeleteVehicle(this._profileRepository);
  @override
  Future<Either<Failure, bool>> call(DeleteVehicleParams params) {
    return _profileRepository.deleteVehicle(vehicleId: params.vehicleId);
  }
}

class DeleteVehicleParams {
  final int vehicleId;
  DeleteVehicleParams(this.vehicleId);
}
