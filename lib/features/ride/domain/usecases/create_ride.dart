import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/ride/domain/entities/place_details.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/entities/vehicle.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';

class CreateRide implements Usecase<Ride, CreateRideParams> {
  final RideRepository _rideRepository;
  const CreateRide(this._rideRepository);
  @override
  Future<Either<Failure, Ride>> call(CreateRideParams params) {
    return _rideRepository.createRides(
      origin: params.origin,
      destination: params.destination,
      departureTime: params.departureDateTime,
      baseCost: params.baseCost,
      vehicle: params.vehicle,
    );
  }
}

class CreateRideParams {
  final PlaceDetails origin;
  final PlaceDetails destination;
  final DateTime departureDateTime;
  final double baseCost;
  final Vehicle vehicle;

  const CreateRideParams({
    required this.origin,
    required this.destination,
    required this.departureDateTime,
    required this.baseCost,
    required this.vehicle,
  });
}
