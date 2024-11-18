import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';

class FetchAvailableRides
    implements Usecase<List<Ride>, FetchAvailableRidesParams> {
  final RideRepository _rideRepository;
  const FetchAvailableRides(this._rideRepository);
  @override
  Future<Either<Failure, List<Ride>>> call(FetchAvailableRidesParams params) {
    return _rideRepository.fetchAvailableRides(pages: params.pages);
  }
}

class FetchAvailableRidesParams {
  final int pages;

  FetchAvailableRidesParams({required this.pages});
}
