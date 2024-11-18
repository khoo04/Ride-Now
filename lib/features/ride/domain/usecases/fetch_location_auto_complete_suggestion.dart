import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/ride/domain/entities/auto_complete_prediction.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';

class FetchLocationAutoCompleteSuggestion
    implements
        Usecase<List<AutoCompletePrediction>?,
            FetchLocationAutoCompleteSuggestionParams> {
  final RideRepository _rideRepository;
  const FetchLocationAutoCompleteSuggestion(this._rideRepository);
  @override
  Future<Either<Failure, List<AutoCompletePrediction>?>> call(
      FetchLocationAutoCompleteSuggestionParams params) {
    return _rideRepository.fetchLocationAutoCompleteSuggestion(
        query: params.query);
  }
}

class FetchLocationAutoCompleteSuggestionParams {
  final String query;

  FetchLocationAutoCompleteSuggestionParams({required this.query});
}
