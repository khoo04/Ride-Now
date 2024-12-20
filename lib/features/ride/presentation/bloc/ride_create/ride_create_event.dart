part of 'ride_create_bloc.dart';

@immutable
sealed class RideCreateEvent {
  const RideCreateEvent();
}

class InitializeCreateRideEvent extends RideCreateEvent {}

class UpdateCreateRideParams extends RideCreateEvent {
  final PlaceDetails? origin;
  final PlaceDetails? destination;
  final Vehicle? selectedVehicle;
  final DateTime? departureTime;
  final double? price;
  const UpdateCreateRideParams({
    this.origin,
    this.destination,
    this.selectedVehicle,
    this.departureTime,
    this.price,
  });
}

class GetRidePriceSuggestion extends RideCreateEvent {
  const GetRidePriceSuggestion();
}


class CreateRideEvent extends RideCreateEvent {
  const CreateRideEvent();
}
