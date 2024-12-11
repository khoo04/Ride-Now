import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/ride/domain/entities/place_details.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';

class SearchAvailableRides
    implements Usecase<List<Ride>, SearchAvailableRidesParams> {
  final RideRepository _rideRepository;
  const SearchAvailableRides(this._rideRepository);
  @override
  Future<Either<Failure, List<Ride>>> call(SearchAvailableRidesParams params) {
    return _rideRepository.searchAvailableRides(
      fromPlace: params.fromPlace,
      toPlace: params.toPlace,
      departureTime: params.departureTime,
      seats: params.seats,
    );
  }
}

class SearchAvailableRidesParams {
  final PlaceDetails fromPlace;
  final PlaceDetails? toPlace;
  final DateTime departureTime;
  final int seats;

  SearchAvailableRidesParams({
    required this.fromPlace,
    this.toPlace,
    required this.departureTime,
    required this.seats,
  });
}
