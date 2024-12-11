import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/ride/domain/entities/place_details.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/entities/vehicle.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';

class UpdateRide implements Usecase<Ride, UpdateRideParams> {
  final RideRepository _rideRepository;
  const UpdateRide(this._rideRepository);
  @override
  Future<Either<Failure, Ride>> call(UpdateRideParams params) {
    return _rideRepository.updateRide(
      rideId: params.rideId,
      origin: params.origin,
      destination: params.destination,
      departureTime: params.departureTime,
      baseCost: params.baseCost,
      vehicle: params.vehicle,
    );
  }
}

class UpdateRideParams {
  final int rideId;
  final PlaceDetails? origin;
  final PlaceDetails? destination;
  final DateTime? departureTime;
  final Vehicle? vehicle;
  final double? baseCost;

  const UpdateRideParams({
    required this.rideId,
    this.origin,
    this.destination,
    this.departureTime,
    this.baseCost,
    this.vehicle,
  });
}
