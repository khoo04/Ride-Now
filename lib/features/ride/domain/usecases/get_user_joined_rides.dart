import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';

class GetUserJoinedRides implements Usecase<List<Ride>, NoParams> {
  final RideRepository _rideRepository;

  const GetUserJoinedRides(this._rideRepository);

  @override
  Future<Either<Failure, List<Ride>>> call(NoParams params) {
    return _rideRepository.getJoinedRides();
  }
}
