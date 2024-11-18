import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/constants/constants.dart';
import 'package:ride_now_app/core/error/exception.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/network/connection_checker.dart';
import 'package:ride_now_app/features/ride/data/datasources/ride_remote_data_source.dart';
import 'package:ride_now_app/features/ride/domain/entities/auto_complete_prediction.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';

class RideRepositoryImpl implements RideRepository {
  final RideRemoteDataSource _rideRemoteDataSource;
  final ConnectionChecker _connectionChecker;

  RideRepositoryImpl(this._rideRemoteDataSource, this._connectionChecker);
  @override
  Future<Either<Failure, List<Ride>>> fetchAvailableRides(
      {required int pages}) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final availableRides =
          await _rideRemoteDataSource.listAvailableRides(pages: pages);

      return right(availableRides);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<AutoCompletePrediction>?>>
      fetchLocationAutoCompleteSuggestion({required String query}) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final autoCompleteSuggestion = await _rideRemoteDataSource
          .locationAutoCompleteSuggestion(query: query);

      return right(autoCompleteSuggestion);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
