part of 'ride_bloc.dart';

@immutable
sealed class RideEvent {}

class SelectRideEvent extends RideEvent {
  final Ride ride;
  final int seats;
  SelectRideEvent({required this.ride, this.seats = 1});
}

class FetchRideDetails extends RideEvent {
  final int rideId;
  FetchRideDetails({required this.rideId});
}

class CancelRideEvent extends RideEvent {
  final int rideId;
  CancelRideEvent({required this.rideId});
}

class SelectVoucherOnRide extends RideEvent {
  final Voucher voucher;
  SelectVoucherOnRide({required this.voucher});
}

class GetUserCreatedNJoinedRides extends RideEvent {}

class ResetRideStateEvent extends RideEvent {}

//For real-time update
class UpdateSelectedRide extends RideEvent {
  final Ride updatedRide;
  UpdateSelectedRide(this.updatedRide);
}
