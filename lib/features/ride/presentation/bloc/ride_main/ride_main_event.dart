part of 'ride_main_bloc.dart';

@immutable
sealed class RideMainEvent {
  const RideMainEvent();
}

class InitFetchRide extends RideMainEvent {
  const InitFetchRide();
}

class RetrieveAvailabeRides extends RideMainEvent {
  const RetrieveAvailabeRides();
}

class UpdateSpecificRideInList extends RideMainEvent {
  final Ride ride;
  const UpdateSpecificRideInList({required this.ride});
}

class RemoveSpecificRideInList extends RideMainEvent {
  final Ride ride;
  const RemoveSpecificRideInList({required this.ride});
}
