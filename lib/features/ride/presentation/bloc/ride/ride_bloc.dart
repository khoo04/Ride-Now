import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/profile/domain/entities/voucher.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/usecases/cancel_ride.dart';
import 'package:ride_now_app/features/ride/domain/usecases/fetch_ride_by_id.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_main/ride_main_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/cubit/your_ride_list/your_ride_list_cubit.dart';

part 'ride_event.dart';
part 'ride_state.dart';

class RideBloc extends Bloc<RideEvent, RideState> {
  //Use Cases
  final FetchRideById _fetchRideById;
  final CancelRide _cancelRide;
  //Bloc
  final RideMainBloc _rideMainBloc;
  //Cubits
  final YourRideListCubit _yourRideListCubit;
  RideBloc({
    required FetchRideById fetchRideById,
    required CancelRide cancelRide,
    required RideMainBloc rideMainBloc,
    required YourRideListCubit yourRideListCubit,
  })  : _fetchRideById = fetchRideById,
        _cancelRide = cancelRide,
        _rideMainBloc = rideMainBloc,
        _yourRideListCubit = yourRideListCubit,
        super(const RideInitial()) {
    on<SelectRideEvent>(_onSelectRide);
    on<SelectVoucherOnRide>(_onSelectVoucherOnRide);
    on<FetchRideDetails>(_onFetchRideById);
    on<CancelRideEvent>(_onCancelRide);
    on<ResetRideStateEvent>(_onResetRideBloc);
  }

  void _onSelectRide(SelectRideEvent event, Emitter<RideState> emit) {
    emit(RideSelected(
      ride: event.ride,
      seats: event.seats,
      rideId: event.ride.rideId,
    ));
  }

  void _onSelectVoucherOnRide(
      SelectVoucherOnRide event, Emitter<RideState> emit) {
    if (state is RideSelected) {
      final currentState = state as RideSelected;

      emit(currentState.copyWith(voucherSelected: event.voucher));
    }
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

  Future<void> _onCancelRide(
      CancelRideEvent event, Emitter<RideState> emit) async {
    final currentState = state as RideSelected;

    emit(RideLoading());

    final ride = await _cancelRide(
      CancelRideParams(rideId: event.rideId),
    );

    ride.fold((failure) {
      emit(RideFailure(failure.message));
      emit(currentState);
    }, (ride) {
      emit(const RideActionSuccess("Ride canceled successfully"));
      _rideMainBloc.add(RemoveSpecificRideInList(ride: ride));
      _yourRideListCubit.updateRideInList(ride);
      emit(currentState.copyWith(ride: ride));
    });
  }

  void _onResetRideBloc(ResetRideStateEvent event, Emitter<RideState> emit) {
    emit(const RideInitial());
  }
}
