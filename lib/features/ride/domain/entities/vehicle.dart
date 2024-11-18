import 'package:ride_now_app/core/common/enums/vehicle_type.dart';

class Vehicle {
  final int vehicleId;
  final String vehicleRegistrationNumber;
  final String manufacturer;
  final String model;
  final int seats;
  final double averageFuelConsumption;
  final VehicleType vehicleType;
  final int userId;

  Vehicle({
    required this.vehicleId,
    required this.vehicleRegistrationNumber,
    required this.manufacturer,
    required this.model,
    required this.seats,
    required this.averageFuelConsumption,
    required this.vehicleType,
    required this.userId,
  });
}
