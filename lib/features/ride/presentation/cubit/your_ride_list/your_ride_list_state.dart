part of 'your_ride_list_cubit.dart';

@immutable
sealed class RideListState {
  const RideListState();
}

final class RideListInitial extends RideListState {}

final class RideListLoading extends RideListState {}

final class RidesDisplaySuccess extends RideListState {
  final List<Ride> joinedRides;
  final List<Ride> createdRides;

  const RidesDisplaySuccess({
    required this.joinedRides,
    required this.createdRides,
  });
}

class RideListFailure extends RideListState {
  final String message;
  const RideListFailure(this.message);
}
