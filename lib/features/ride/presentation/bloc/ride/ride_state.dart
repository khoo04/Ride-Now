part of 'ride_bloc.dart';

@immutable
sealed class RideState {
  final int? rideId;

  const RideState({this.rideId});
}

class RideInitial extends RideState {
  const RideInitial();
}

class RideSelected extends RideState {
  final Ride ride;
  final int seats;
  final Voucher? voucherSelected;
  const RideSelected({
    super.rideId,
    required this.ride,
    required this.seats,
    this.voucherSelected,
  });

  RideSelected copyWith({
    Ride? ride,
    int? seats,
    Voucher? voucherSelected,
  }) {
    return RideSelected(
      rideId: rideId,
      ride: ride ?? this.ride,
      seats: seats ?? this.seats,
      voucherSelected: voucherSelected ?? this.voucherSelected,
    );
  }
}

class RideLoading extends RideState {}

class RideActionSuccess extends RideState {
  final String message;
  const RideActionSuccess(this.message);
}

class RideFailure extends RideState {
  final String message;
  const RideFailure(this.message);
}
