part of 'vehicle_bloc.dart';

@immutable
sealed class VehicleState {
  const VehicleState();
}

final class VehicleInitial extends VehicleState {}

final class VehicleDisplaySuccess extends VehicleState {
  final List<Vehicle> vehicles;

  const VehicleDisplaySuccess(this.vehicles);
}

final class VehicleRegisterSuccess extends VehicleState {
  final Vehicle vehicle;
  const VehicleRegisterSuccess(this.vehicle);
}

final class VehicleLoading extends VehicleState {}

final class VehicleDeleteSuccess extends VehicleState {}

final class VehicleFailure extends VehicleState {
  final String message;
  const VehicleFailure(this.message);
}

final class VehicleRegisterFailure extends VehicleState {
  final Map<String, String> registrationErrors;
  const VehicleRegisterFailure(this.registrationErrors);
}
