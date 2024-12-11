part of 'ride_search_bloc.dart';

@immutable
sealed class RideSearchState {
  const RideSearchState();
}

class RideSearchLoading extends RideSearchState {
  final PlaceDetails? fromPlace;
  final PlaceDetails? toPlace;
  final DateTime? dateTime;
  final int seats;

  const RideSearchLoading({
    this.fromPlace,
    this.toPlace,
    this.dateTime,
    this.seats = 1,
  });
}

final class RideSearchInitial extends RideSearchState {
  final PlaceDetails? fromPlace;
  final PlaceDetails? toPlace;
  final DateTime? dateTime;
  final int seats;

  const RideSearchInitial({
    this.fromPlace,
    this.toPlace,
    this.dateTime,
    this.seats = 1,
  });

  RideSearchInitial copyWith({
    PlaceDetails? fromPlace,
    PlaceDetails? toPlace,
    DateTime? dateTime,
    int? seats,
  }) {
    return RideSearchInitial(
      fromPlace: fromPlace ?? this.fromPlace,
      toPlace: toPlace ?? this.toPlace,
      dateTime: dateTime ?? this.dateTime,
      seats: seats ?? this.seats,
    );
  }
}

final class RideSearchSuccess extends RideSearchState {
  final PlaceDetails fromPlace;
  final PlaceDetails toPlace;
  final DateTime departureTime;
  final int seats;
  final List<Ride> searchRides;

  const RideSearchSuccess({
    required this.fromPlace,
    required this.toPlace,
    required this.departureTime,
    required this.seats,
    required this.searchRides,
  });
}

final class RideSearchFailure extends RideSearchState {
  final String message;
  const RideSearchFailure(this.message);
}
