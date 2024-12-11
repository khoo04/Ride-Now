import 'package:ride_now_app/core/common/entities/user.dart';
import 'package:ride_now_app/features/ride/domain/entities/place_details.dart';
import 'package:ride_now_app/features/ride/domain/entities/vehicle.dart';

class Ride {
  final int rideId;
  final PlaceDetails origin;
  final PlaceDetails destination;
  final DateTime departureTime;
  final String status;
  final double baseCost;
  final List<User> passengers;
  final User driver;
  final Vehicle vehicle;

  Ride({
    required this.rideId,
    required this.origin,
    required this.destination,
    required this.departureTime,
    required this.status,
    required this.baseCost,
    required this.driver,
    required this.passengers,
    required this.vehicle,
  });
}
