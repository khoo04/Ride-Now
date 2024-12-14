import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';

class CancelRide implements Usecase<Ride, CancelRideParams> {
  final RideRepository _rideRepository;
  const CancelRide(this._rideRepository);
  @override
  Future<Either<Failure, Ride>> call(CancelRideParams params) {
    return _rideRepository.cancelRide(rideId: params.rideId);
  }
}

class CancelRideParams {
  final int rideId;
  CancelRideParams({required this.rideId});
}
