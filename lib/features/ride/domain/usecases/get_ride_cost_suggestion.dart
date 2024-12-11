import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/ride/domain/entities/place_details.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';

class GetRideCostSuggestion
    implements Usecase<double, GetRideCostSuggestionParams> {
  final RideRepository _rideRepository;

  const GetRideCostSuggestion(this._rideRepository);
  @override
  Future<Either<Failure, double>> call(GetRideCostSuggestionParams params) {
    return _rideRepository.getPriceSuggestionByDistance(
      fromPlace: params.fromPlace,
      toPlace: params.toPlace,
      fuelConsumptions: params.fuelConsumptions,
    );
  }
}

class GetRideCostSuggestionParams {
  final PlaceDetails fromPlace;
  final PlaceDetails toPlace;
  final double fuelConsumptions;

  const GetRideCostSuggestionParams(
      {required this.fromPlace,
      required this.toPlace,
      required this.fuelConsumptions});
}
