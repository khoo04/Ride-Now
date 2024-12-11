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
  const UpdateCreateRideParams({
    this.origin,
    this.destination,
    this.selectedVehicle,
    this.departureTime,
  });
}

class GetRidePriceSuggestion extends RideCreateEvent {
  const GetRidePriceSuggestion();
}


class CreateRideEvent extends RideCreateEvent {
  const CreateRideEvent();
}
