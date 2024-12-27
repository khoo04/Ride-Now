import 'package:ride_now_app/features/auth/data/models/user_model.dart';
import 'package:ride_now_app/features/ride/data/models/place_details_model.dart';
import 'package:ride_now_app/features/ride/data/models/vehicle_model.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';

class RideModel extends Ride {
  RideModel({
    required super.rideId,
    required super.origin,
    required super.destination,
    required super.departureTime,
    required super.status,
    required super.baseCost,
    required super.driver,
    required super.passengers,
    required super.vehicle,
    required super.isRated,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      rideId: json['ride_id'],
      origin: PlaceDetailsModel.fromApiJson(json['origin']),
      destination: PlaceDetailsModel.fromApiJson(json['destination']),
      departureTime: DateTime.parse(json['departure_time']),
      status: json['status'],
      baseCost: double.parse(json['base_cost']),
      driver: UserModel.fromJson(json['driver']),
      passengers: (json['passengers'] as List)
          .map((passengerJson) => UserModel.fromJson(passengerJson))
          .toList(),
      vehicle: VehicleModel.fromJson(json['vehicle']),
      isRated: json['isRated'] as bool?,
    );
  }

  @override
  String toString() {
    return 'RideModel(rideId: $rideId, origin: ${origin.toString()}, destination: ${destination.toString()}, departureTime: $departureTime, status: $status, baseCost: $baseCost, driver: ${driver.toString()}, passengers: ${passengers.map((p) => p.toString()).toList()}, vehicle: ${vehicle.toString()}, isRated: $isRated)';
  }
}
