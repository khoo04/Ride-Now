import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';

class GetUserCreatedRides implements Usecase<List<Ride>, NoParams> {
  final RideRepository _rideRepository;

  const GetUserCreatedRides(this._rideRepository);
  @override
  Future<Either<Failure, List<Ride>>> call(NoParams params) {
    return _rideRepository.getCreatedRides();
  }
}
