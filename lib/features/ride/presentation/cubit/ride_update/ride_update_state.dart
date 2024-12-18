part of 'ride_update_cubit.dart';

@immutable
sealed class RideUpdateState {
  const RideUpdateState();
}

final class RideUpdateInitial extends RideUpdateState {
  final Ride? rideToUpdate;
  final List<Vehicle>? userVehicles;
  final PlaceDetails? origin;
  final PlaceDetails? destination;
  final DateTime? departureTime;
  final Vehicle? selectedVehicle;
  final double? price;
  final Map<String, String>? validationErrors;
  const RideUpdateInitial({
    this.origin,
    this.destination,
    this.departureTime,
    this.selectedVehicle,
    this.price,
    this.rideToUpdate,
    this.userVehicles,
    this.validationErrors,
  });

  RideUpdateInitial copyWith({
    Ride? rideToUpdate,
    List<Vehicle>? userVehicles,
    PlaceDetails? origin,
    PlaceDetails? destination,
    DateTime? departureTime,
    Vehicle? selectedVehicle,
    double? price,
    Map<String, String>? validationErrors,
  }) {
    return RideUpdateInitial(
      rideToUpdate: rideToUpdate ?? this.rideToUpdate,
      userVehicles: userVehicles ?? this.userVehicles,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      departureTime: departureTime ?? this.departureTime,
      price: price ?? this.price,
      validationErrors: validationErrors ?? this.validationErrors,
    );
  }

  @override
  String toString() {
    return "Ride Update Initial ( origin:$origin, destination:$destination, departureTime:$departureTime, price: $price, selectedVehicle: $selectedVehicle, )";
  }
}

final class RideUpdatePageLoading extends RideUpdateState {}

final class RideUpdateFailure extends RideUpdateState {
  final String message;
  const RideUpdateFailure(this.message);
}

final class RideUpdateSuccess extends RideUpdateState {
  final Ride ride;
  const RideUpdateSuccess(this.ride);
}
