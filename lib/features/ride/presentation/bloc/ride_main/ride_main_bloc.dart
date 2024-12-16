import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/usecases/fetch_available_rides.dart';

part 'ride_main_event.dart';
part 'ride_main_state.dart';

class RideMainBloc extends Bloc<RideMainEvent, FetchRideState> {
  //Use Cases
  final FetchAvailableRides _fetchAvailableRides;
  RideMainBloc({
    required FetchAvailableRides fetchAvailableRides,
  })  : _fetchAvailableRides = fetchAvailableRides,
        super(FetchRideInitial()) {
    on<RideMainEvent>((event, emit) {});
    on<InitFetchRide>(_onInitRide);
    on<RetrieveAvailabeRides>(_onFetchAvailableRides);
    on<UpdateSpecificRideInList>(_onUpdateSpecificRide);
    on<RemoveSpecificRideInList>(_onRemoveSpecificRide);
  }

  _onInitRide(InitFetchRide event, Emitter<FetchRideState> emit) async {
    emit(FetchRideInitial());

    final res = await _fetchAvailableRides(FetchAvailableRidesParams(pages: 1));

    res.fold((failure) => emit(FetchRideFailure(failure.message)),
        (fetchedRides) {
      bool isEnd = fetchedRides.isEmpty;
      emit(FetchRideSuccess(rides: fetchedRides, isEnd: isEnd, currentPage: 2));
    });
  }

  _onFetchAvailableRides(
      RetrieveAvailabeRides event, Emitter<FetchRideState> emit) async {
    final currentPage =
        state is FetchRideSuccess ? (state as FetchRideSuccess).currentPage : 1;

    final res = await _fetchAvailableRides(
        FetchAvailableRidesParams(pages: currentPage));

    res.fold((failure) => emit(FetchRideFailure(failure.message)),
        (fetchedRides) {
      //Check the retrieved rides is empty or not, if empty = reach end
      bool isEnd = fetchedRides.isEmpty;

      // Get the current rides and page from the state
      final currentFetchedRides =
          state is FetchRideSuccess ? (state as FetchRideSuccess).rides : [];

      // Combine current rides with newly fetched rides
      final combinedRides = List<Ride>.from(currentFetchedRides)
        ..addAll(fetchedRides);

      emit(FetchRideSuccess(
          rides: combinedRides, isEnd: isEnd, currentPage: currentPage + 1));
    });
  }

  _onUpdateSpecificRide(
      UpdateSpecificRideInList event, Emitter<FetchRideState> emit) {
    if (state is FetchRideSuccess) {
      final currentState = state as FetchRideSuccess;

      final updatedRides = currentState.rides.map((ride) {
        return ride.rideId == event.ride.rideId ? event.ride : ride;
      }).toList();

      emit(currentState.copyWith(rides: updatedRides));
    }
  }

  _onRemoveSpecificRide(
      RemoveSpecificRideInList event, Emitter<FetchRideState> emit) {
    if (state is FetchRideSuccess) {
      final currentState = state as FetchRideSuccess;

      // Remove the canceled ride
      final updatedRides = currentState.rides
          .where((ride) => ride.rideId != event.ride.rideId)
          .toList();

      emit(currentState.copyWith(rides: updatedRides));
    }
  }
}
