import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';

class RateRide implements Usecase<bool, RateRideParams> {
  final RideRepository _rideRepository;
  RateRide(this._rideRepository);
  @override
  Future<Either<Failure, bool>> call(RateRideParams params) {
    return _rideRepository.rateRide(
        rideId: params.rideId, rating: params.rating);
  }
}

class RateRideParams {
  final int rideId;
  final double rating;
  RateRideParams({required this.rideId, required this.rating});
}
