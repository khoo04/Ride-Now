import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/ride/domain/entities/place_details.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';

class FetchPlaceDetails
    implements Usecase<PlaceDetails, FetchPlaceDetailsParams> {
  final RideRepository _rideRepository;
  const FetchPlaceDetails(this._rideRepository);
  @override
  Future<Either<Failure, PlaceDetails>> call(FetchPlaceDetailsParams params) {
    return _rideRepository.fetchPlaceDetails(placeId: params.placeId);
  }
}

class FetchPlaceDetailsParams {
  final String placeId;

  FetchPlaceDetailsParams(this.placeId);
}
