import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/ride/domain/entities/place_details.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';

class GeocodingFetchPlaceDetails
    implements Usecase<PlaceDetails, GeocodingFetchPlaceDetailsParams> {
  final RideRepository _rideRepository;
  const GeocodingFetchPlaceDetails(this._rideRepository);
  @override
  Future<Either<Failure, PlaceDetails>> call(
      GeocodingFetchPlaceDetailsParams params) {
    return _rideRepository.geocodingFetchPlaceDetails(
        latitude: params.latitude, longitude: params.longitude);
  }
}

class GeocodingFetchPlaceDetailsParams {
  final double latitude;
  final double longitude;

  GeocodingFetchPlaceDetailsParams(this.latitude, this.longitude);
}
