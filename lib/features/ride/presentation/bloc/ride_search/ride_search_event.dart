part of 'ride_search_bloc.dart';

@immutable
sealed class RideSearchEvent {
  const RideSearchEvent();
}

class UpdateRideSearchOrigin extends RideSearchEvent {
  final PlaceDetails fromPlace;
  const UpdateRideSearchOrigin(this.fromPlace);
}

class UpdateRideSearchDestination extends RideSearchEvent {
  final PlaceDetails toPlace;
  const UpdateRideSearchDestination(this.toPlace);
}

class UpdateRideSearchDateTime extends RideSearchEvent {
  final DateTime dateTime;
  const UpdateRideSearchDateTime(this.dateTime);
}

class UpdateRideSearchSeats extends RideSearchEvent {
  final int seats;
  const UpdateRideSearchSeats(this.seats);
}

class SearchAvailableRidesEvent extends RideSearchEvent {
  final PlaceDetails fromPlace;
  final PlaceDetails? toPlace;
  final DateTime departureTime;
  final int seats;

  const SearchAvailableRidesEvent({
    required this.fromPlace,
    this.toPlace,
    required this.departureTime,
    required this.seats,
  });
}

class ResetRideSearchState extends RideSearchEvent {}
