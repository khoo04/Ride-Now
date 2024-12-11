import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/features/ride/domain/entities/place_details.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/usecases/search_available_rides.dart';

part 'ride_search_event.dart';
part 'ride_search_state.dart';

class RideSearchBloc extends Bloc<RideSearchEvent, RideSearchState> {
  //Use Cases
  final SearchAvailableRides _searchAvailableRides;
  RideSearchBloc({required SearchAvailableRides searchAvailableRides})
      : _searchAvailableRides = searchAvailableRides,
        super(const RideSearchInitial()) {
    on<UpdateRideSearchOrigin>(_onUpdateRideSearchOrigin);
    on<UpdateRideSearchDestination>(_onUpdateRideSearchDestination);
    on<UpdateRideSearchDateTime>(_onUpdateRideSearchDateTime);
    on<UpdateRideSearchSeats>(_onUpdateRideSearchSeats);
    on<ResetRideSearchState>(_onResetRideSearchState);
    on<SearchAvailableRidesEvent>(_onSearchAvailableRides);
  }

  void _onUpdateRideSearchOrigin(
      UpdateRideSearchOrigin event, Emitter<RideSearchState> emit) {
    if (state is! RideSearchInitial) return;

    final currentState = state as RideSearchInitial;
    emit(currentState.copyWith(
      fromPlace: event.fromPlace,
    ));
  }

  void _onUpdateRideSearchDestination(
      UpdateRideSearchDestination event, Emitter<RideSearchState> emit) {
    if (state is! RideSearchInitial) return;

    final currentState = state as RideSearchInitial;
    emit(currentState.copyWith(
      toPlace: event.toPlace,
    ));
  }

  void _onUpdateRideSearchDateTime(
      UpdateRideSearchDateTime event, Emitter<RideSearchState> emit) {
    if (state is! RideSearchInitial) return;

    final currentState = state as RideSearchInitial;
    emit(currentState.copyWith(
      dateTime: event.dateTime,
    ));
  }

  void _onUpdateRideSearchSeats(
      UpdateRideSearchSeats event, Emitter<RideSearchState> emit) {
    if (state is! RideSearchInitial) return;

    final currentState = state as RideSearchInitial;
    emit(currentState.copyWith(
      seats: event.seats,
    ));
  }

  void _onResetRideSearchState(
      ResetRideSearchState event, Emitter<RideSearchState> emit) {
    final currentState = state;
    if (currentState is RideSearchSuccess) {
      emit(RideSearchInitial(
        fromPlace: currentState.fromPlace,
        toPlace: currentState.toPlace,
        dateTime: currentState.departureTime,
        seats: currentState.seats,
      ));
    } else {
      emit(const RideSearchInitial());
    }
  }

  Future<void> _onSearchAvailableRides(
      SearchAvailableRidesEvent event, Emitter<RideSearchState> emit) async {
    emit(RideSearchLoading(
      fromPlace: event.fromPlace,
      toPlace: event.toPlace,
      dateTime: event.departureTime,
      seats: event.seats,
    ));
    final res = await _searchAvailableRides(
      SearchAvailableRidesParams(
        fromPlace: event.fromPlace,
        toPlace: event.toPlace,
        departureTime: event.departureTime,
        seats: event.seats,
      ),
    );

    res.fold(
      (l) => emit(RideSearchFailure(l.message)),
      (rides) => emit(RideSearchSuccess(
          fromPlace: event.fromPlace,
          toPlace: event.toPlace ??
              PlaceDetails(
                  name: "Any Places",
                  formattedAddress: "Any Places",
                  latitude: 0,
                  longitude: 0),
          departureTime: event.departureTime,
          seats: event.seats,
          searchRides: rides)),
    );
  }
}
