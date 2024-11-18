import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/features/ride/domain/entities/auto_complete_prediction.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';

abstract interface class RideRepository {
  Future<Either<Failure, List<Ride>>> fetchAvailableRides({
    required int pages,
  });

  Future<Either<Failure, List<AutoCompletePrediction>?>>
      fetchLocationAutoCompleteSuggestion({required String query});
}
