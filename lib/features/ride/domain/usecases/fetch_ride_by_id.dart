import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';

class FetchRideById implements Usecase<Ride, FetchRideByIdParams> {
  final RideRepository _rideRepository;
  const FetchRideById(this._rideRepository);

  @override
  Future<Either<Failure, Ride>> call(FetchRideByIdParams params) {
    return _rideRepository.fetchRideById(rideId: params.rideId);
  }
}

class FetchRideByIdParams {
  final int rideId;
  FetchRideByIdParams({required this.rideId});
}
