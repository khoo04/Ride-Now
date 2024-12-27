import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';

class CompleteRide implements Usecase<Ride, CompleteRideParams> {
  final RideRepository _rideRepository;
  const CompleteRide(this._rideRepository);
  @override
  Future<Either<Failure, Ride>> call(CompleteRideParams params) {
    return _rideRepository.completeRide(rideId: params.rideId);
  }
}

class CompleteRideParams {
  final int rideId;
  CompleteRideParams({required this.rideId});
}
