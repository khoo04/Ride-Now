part of 'ride_create_bloc.dart';

@immutable
sealed class RideCreateState {
  const RideCreateState();
}

final class RideCreateInitial extends RideCreateState {
  final PlaceDetails? fromPlace;
  final PlaceDetails? toPlace;
  final DateTime? departureDateTime;
  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final double? priceSuggstion;
  final Map<String, String>? validationErrors;

  const RideCreateInitial({
    this.fromPlace,
    this.toPlace,
    this.departureDateTime,
    this.selectedVehicle,
    this.vehicles = const [],
    this.priceSuggstion,
    this.validationErrors,
  });

  RideCreateInitial copyWith({
    PlaceDetails? fromPlace,
    PlaceDetails? toPlace,
    DateTime? departureDateTime,
    List<Vehicle>? vehicles,
    Vehicle? selectedVehicle,
    double? priceSuggstion,
    Map<String, String>? validationErrors,
  }) {
    return RideCreateInitial(
      fromPlace: fromPlace ?? this.fromPlace,
      toPlace: toPlace ?? this.toPlace,
      vehicles: vehicles ?? this.vehicles,
      departureDateTime: departureDateTime ?? this.departureDateTime,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      priceSuggstion: priceSuggstion ?? this.priceSuggstion,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }
}

final class RideCreateLoading extends RideCreateState {
  final PlaceDetails? fromPlace;
  final PlaceDetails? toPlace;
  final List<Vehicle> vehicles;
  final DateTime? departureDateTime;
  final Vehicle? selectedVehicle;
  final double? priceSuggstion;

  const RideCreateLoading({
    this.fromPlace,
    this.toPlace,
    this.departureDateTime,
    this.vehicles = const [],
    this.selectedVehicle,
    this.priceSuggstion,
  });
}

final class RideCreateSuccess extends RideCreateState {
  final Ride ride;
  const RideCreateSuccess(this.ride);
}

final class RideCreateFailure extends RideCreateState {
  final String message;
  const RideCreateFailure(this.message);
}
