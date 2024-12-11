import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/profile/domain/entities/voucher.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/usecases/fetch_ride_by_id.dart';
import 'package:ride_now_app/features/ride/domain/usecases/get_user_created_rides.dart';
import 'package:ride_now_app/features/ride/domain/usecases/get_user_joined_rides.dart';

part 'ride_event.dart';
part 'ride_state.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  //Use Cases
  final FetchRideById _fetchRideById;

  RideBloc({
    required FetchRideById fetchRideById,
  })  : _fetchRideById = fetchRideById,
        super(const RideInitial()) {
    on<SelectRideEvent>(_onSelectRide);
    on<FetchRideDetails>(_onFetchRideById);
    on<ResetRideStateEvent>(_onResetRideBloc);
  }

  void _onSelectRide(SelectRideEvent event, Emitter<RideState> emit) {
    emit(RideSelected(
      ride: event.ride,
      seats: event.seats,
      rideId: event.ride.rideId,
    ));
  }

  Future<void> _onFetchRideById(
      FetchRideDetails event, Emitter<RideState> emit) async {
    if (state is! RideSelected) return;
    final currentState = state as RideSelected;

    final ride = await _fetchRideById(
      FetchRideByIdParams(rideId: event.rideId),
    );

    ride.fold((failure) {
      emit(RideFailure(failure.message));
    }, (ride) {
      emit(currentState.copyWith(ride: ride));
    });
  }

  void _onResetRideBloc(ResetRideStateEvent event, Emitter<RideState> emit) {
    emit(const RideInitial());
  }
}
