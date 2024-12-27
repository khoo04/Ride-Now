import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/constants/constants.dart';
import 'package:ride_now_app/core/error/exception.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/network/connection_checker.dart';
import 'package:ride_now_app/features/ride/data/datasources/ride_remote_data_source.dart';
import 'package:ride_now_app/features/ride/domain/entities/auto_complete_prediction.dart';
import 'package:ride_now_app/features/ride/domain/entities/place_details.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/entities/vehicle.dart';
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

  @override
  Future<Either<Failure, PlaceDetails>> fetchPlaceDetails(
      {required String placeId}) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final placeDetails =
          await _rideRemoteDataSource.fetchPlaceDetails(placeId: placeId);

      return right(placeDetails);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, PlaceDetails>> geocodingFetchPlaceDetails(
      {required double latitude, required double longitude}) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final placeId = await _rideRemoteDataSource.geocodingFetchPlaceDetails(
          latitude: latitude, longitude: longitude);

      return right(placeId);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Ride>>> searchAvailableRides(
      {required PlaceDetails fromPlace,
      PlaceDetails? toPlace,
      required DateTime departureTime,
      required int seats}) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final rides = await _rideRemoteDataSource.searchAvailableRides(
        fromPlace: fromPlace,
        toPlace: toPlace,
        departureTime: departureTime,
        seats: seats,
      );

      return right(rides);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Ride>> fetchRideById({required int rideId}) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final ride = await _rideRemoteDataSource.fetchRideById(rideId: rideId);

      return right(ride);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, double>> getPriceSuggestionByDistance({
    required PlaceDetails fromPlace,
    required PlaceDetails toPlace,
    required double fuelConsumptions,
  }) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final priceSuggestion =
          await _rideRemoteDataSource.getPriceSuggestionByDistance(
        fromPlace: fromPlace,
        toPlace: toPlace,
        fuelConsumptions: fuelConsumptions,
      );

      return right(priceSuggestion);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Ride>> createRides(
      {required PlaceDetails origin,
      required PlaceDetails destination,
      required DateTime departureTime,
      required double baseCost,
      required Vehicle vehicle}) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final ride = await _rideRemoteDataSource.createRide(
        origin: origin,
        destination: destination,
        departureTime: departureTime,
        baseCost: baseCost,
        vehicleId: vehicle.vehicleId,
      );

      return right(ride);
    } on ServerValidatorException catch (e) {
      return left(Failure(e.message, e.errors));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Ride>> updateRide({
    required int rideId,
    required PlaceDetails? origin,
    required PlaceDetails? destination,
    required DateTime? departureTime,
    required double? baseCost,
    required Vehicle? vehicle,
  }) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final ride = await _rideRemoteDataSource.updateRide(
        rideId: rideId,
        origin: origin,
        destination: destination,
        departureTime: departureTime,
        baseCost: baseCost,
        vehicleId: vehicle?.vehicleId,
      );

      return right(ride);
    } on ServerValidatorException catch (e) {
      return left(Failure(e.message, e.errors));
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Ride>>> getCreatedRides() async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final createdRides = await _rideRemoteDataSource.getCreatedRides();

      return right(createdRides);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Ride>>> getJoinedRides() async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }

      final joinedRides = await _rideRemoteDataSource.getJoinedRides();

      return right(joinedRides);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Ride>> cancelRide({required int rideId}) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final ride = await _rideRemoteDataSource.cancelRide(rideId: rideId);

      return right(ride);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Ride>> completeRide({required int rideId}) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final ride = await _rideRemoteDataSource.completeRide(rideId: rideId);

      return right(ride);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> rateRide(
      {required int rideId, required double rating}) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final success =
          await _rideRemoteDataSource.rateRide(rideId: rideId, rating: rating);

      return right(success);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Ride>> startRide({required int rideId}) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final ride = await _rideRemoteDataSource.startRide(rideId: rideId);

      return right(ride);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
