import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';

class LeaveRide implements Usecase<Ride, LeaveRideParams> {
  final RideRepository _rideRepository;
  const LeaveRide(this._rideRepository);
  @override
  Future<Either<Failure, Ride>> call(LeaveRideParams params) {
    return _rideRepository.leaveRide(rideId: params.rideId);
  }
}

class LeaveRideParams {
  final int rideId;
  LeaveRideParams({required this.rideId});
}
