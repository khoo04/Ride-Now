import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';

class StartRide implements Usecase<Ride, StartRideParams> {
  final RideRepository _rideRepository;
  const StartRide(this._rideRepository);
  @override
  Future<Either<Failure, Ride>> call(StartRideParams params) {
    return _rideRepository.startRide(rideId: params.rideId);
  }
}

class StartRideParams {
  final int rideId;
  StartRideParams({required this.rideId});
}
