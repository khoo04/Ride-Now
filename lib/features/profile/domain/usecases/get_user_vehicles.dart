import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:ride_now_app/features/ride/domain/entities/vehicle.dart';

class GetUserVehicles implements Usecase<List<Vehicle>, NoParams> {
  final ProfileRepository _profileRepository;
  const GetUserVehicles(this._profileRepository);
  @override
  Future<Either<Failure, List<Vehicle>>> call(params) {
    return _profileRepository.getUserVehicles();
  }
}
