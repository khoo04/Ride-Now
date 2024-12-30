part of 'vehicle_bloc.dart';

@immutable
sealed class VehicleEvent {}

class FetchUserVehicles extends VehicleEvent {}

class CreateVehicleEvent extends VehicleEvent {
  final String vehicleRegistrationNumber;
  final String manufacturer;
  final String model;
  final int seats;
  final double averageFuelConsumptions;
  final int vehicleTypeId;

  CreateVehicleEvent({
    required this.vehicleRegistrationNumber,
    required this.manufacturer,
    required this.model,
    required this.seats,
    required this.averageFuelConsumptions,
    required this.vehicleTypeId,
  });
}

class UpdateVehicleEvent extends VehicleEvent {
  final int vehicleId;
  final String? vehicleRegistrationNumber;
  final String? manufacturer;
  final String? model;
  final int? seats;
  final double? averageFuelConsumptions;
  final int? vehicleTypeId;

  UpdateVehicleEvent({
    required this.vehicleId,
    required this.vehicleRegistrationNumber,
    required this.manufacturer,
    required this.model,
    required this.seats,
    required this.averageFuelConsumptions,
    required this.vehicleTypeId,
  });
}

class DeleteVehicleEvent extends VehicleEvent {
  final int vehicleId;

  DeleteVehicleEvent({required this.vehicleId});
}
