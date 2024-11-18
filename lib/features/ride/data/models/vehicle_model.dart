import 'package:ride_now_app/core/common/enums/vehicle_type.dart';
import 'package:ride_now_app/features/ride/domain/entities/vehicle.dart';

class VehicleModel extends Vehicle {
  VehicleModel({
    required super.vehicleId,
    required super.vehicleRegistrationNumber,
    required super.manufacturer,
    required super.model,
    required super.seats,
    required super.averageFuelConsumption,
    required super.vehicleType,
    required super.userId,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      vehicleId: json['vehicle_id'],
      vehicleRegistrationNumber: json['vehicle_registration_number'],
      manufacturer: json['manufacturer'],
      model: json['model'],
      seats: json['seats'],
      averageFuelConsumption: json['average_fuel_consumptions'],
      vehicleType: VehicleType
          .values[json['vehicle_type_id'] - 1], // Map nested ID to enum
      userId: json['user_id'],
    );
  }

  @override
  String toString() {
    return 'VehicleModel(vehicleId: $vehicleId, registrationNumber: $vehicleRegistrationNumber, manufacturer: $manufacturer, model: $model, seats: $seats, fuelConsumption: $averageFuelConsumption, vehicleType: $vehicleType, userId: $userId)';
  }
}
