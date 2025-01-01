import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/features/ride/domain/entities/auto_complete_prediction.dart';
import 'package:ride_now_app/features/ride/domain/entities/place_details.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/entities/vehicle.dart';

abstract interface class RideRepository {
  ///Internal API Call
  Future<Either<Failure, List<Ride>>> fetchAvailableRides({
    required int pages,
  });

  Future<Either<Failure, List<Ride>>> searchAvailableRides({
    required PlaceDetails fromPlace,
    PlaceDetails? toPlace,
    required DateTime departureTime,
    required int seats,
  });

  Future<Either<Failure, Ride>> fetchRideById({required int rideId});

  Future<Either<Failure, Ride>> createRides({
    required PlaceDetails origin,
    required PlaceDetails destination,
    required DateTime departureTime,
    required double baseCost,
    required Vehicle vehicle,
  });

  Future<Either<Failure, Ride>> updateRide({
    required int rideId,
    required PlaceDetails? origin,
    required PlaceDetails? destination,
    required DateTime? departureTime,
    required double? baseCost,
    required Vehicle? vehicle,
  });

  Future<Either<Failure, List<Ride>>> getCreatedRides();

  Future<Either<Failure, List<Ride>>> getJoinedRides();

  Future<Either<Failure, Ride>> cancelRide({required int rideId});

  Future<Either<Failure, Ride>> startRide({required int rideId});

  Future<Either<Failure, Ride>> completeRide({required int rideId});

  Future<Either<Failure, bool>> rateRide(
      {required int rideId, required double rating});

  Future<Either<Failure, Ride>> leaveRide({required int rideId});

  ///External API Call (Google Maps / Open Street Maps)
  Future<Either<Failure, List<AutoCompletePrediction>?>>
      fetchLocationAutoCompleteSuggestion({required String query});

  Future<Either<Failure, PlaceDetails>> geocodingFetchPlaceDetails({
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, PlaceDetails>> fetchPlaceDetails(
      {required String placeId});

  Future<Either<Failure, double>> getPriceSuggestionByDistance({
    required PlaceDetails fromPlace,
    required PlaceDetails toPlace,
    required double fuelConsumptions,
  });
}
