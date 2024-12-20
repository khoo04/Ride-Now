import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/profile/domain/usecases/get_user_vehicles.dart';
import 'package:ride_now_app/features/ride/domain/entities/place_details.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/entities/vehicle.dart';
import 'package:ride_now_app/features/ride/domain/usecases/create_ride.dart';
import 'package:ride_now_app/features/ride/domain/usecases/get_ride_cost_suggestion.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_search/ride_search_bloc.dart';

part 'ride_create_event.dart';
part 'ride_create_state.dart';

class RideCreateBloc extends Bloc<RideCreateEvent, RideCreateState> {
  final GetUserVehicles _getUserVehicles;
  final GetRideCostSuggestion _getRideCostSuggestion;
  final CreateRide _createRide;
  RideCreateBloc(
      {required GetUserVehicles getUserVehicles,
      required GetRideCostSuggestion getRideCostSuggestion,
      required CreateRide createRide})
      : _getUserVehicles = getUserVehicles,
        _getRideCostSuggestion = getRideCostSuggestion,
        _createRide = createRide,
        super(const RideCreateInitial()) {
    on<InitializeCreateRideEvent>(_onInitializeCreateRideEvent);
    on<UpdateCreateRideParams>(_onUpdateCreateRideParams);
    on<GetRidePriceSuggestion>(_onGetPriceSuggstion);
    on<CreateRideEvent>(_onCreateRide);
  }

  Future<void> _onInitializeCreateRideEvent(
      InitializeCreateRideEvent event, Emitter<RideCreateState> emit) async {
    final res = await _getUserVehicles(NoParams());

    res.fold(
      (l) => emit(RideCreateFailure(l.message)),
      (vehicles) => emit(RideCreateInitial(vehicles: vehicles)),
    );
  }

  void _onUpdateCreateRideParams(
      UpdateCreateRideParams event, Emitter<RideCreateState> emit) {
    if (state is! RideCreateInitial) return;

    final currentState = state as RideCreateInitial;
    emit(currentState.copyWith(
      fromPlace: event.origin,
      toPlace: event.destination,
      departureDateTime: event.departureTime,
      selectedVehicle: event.selectedVehicle,
      priceSuggstion: event.price,
    ));
  }

  Future<void> _onGetPriceSuggstion(
      GetRidePriceSuggestion event, Emitter<RideCreateState> emit) async {
    if (state is! RideCreateInitial) return;

    final currentState = state as RideCreateInitial;

    if (currentState.fromPlace == null || currentState.toPlace == null) {
      emit(const RideCreateFailure("Origin and destination is not selected"));
      return;
    }

    final res = await _getRideCostSuggestion(GetRideCostSuggestionParams(
      fromPlace: currentState.fromPlace!,
      toPlace: currentState.toPlace!,
      fuelConsumptions: currentState.selectedVehicle!.averageFuelConsumption,
    ));

    res.fold((failure) => emit(RideCreateFailure(failure.message)),
        (priceSuggestion) {
      emit(currentState.copyWith(priceSuggstion: priceSuggestion));
    });
  }

  Future<void> _onCreateRide(
      CreateRideEvent event, Emitter<RideCreateState> emit) async {
    if (state is! RideCreateInitial) return;

    final currentState = state as RideCreateInitial;

    emit(RideCreateLoading(
      fromPlace: currentState.fromPlace,
      toPlace: currentState.toPlace,
      departureDateTime: currentState.departureDateTime,
      priceSuggstion: currentState.priceSuggstion,
      selectedVehicle: currentState.selectedVehicle,
      vehicles: currentState.vehicles,
    ));

    final res = await _createRide(CreateRideParams(
      origin: currentState.fromPlace!,
      destination: currentState.toPlace!,
      departureDateTime: currentState.departureDateTime!,
      baseCost: currentState.priceSuggstion!,
      vehicle: currentState.selectedVehicle!,
    ));

    res.fold(
      (failure) {
        if (failure.validatorErrors != null) {
          emit(
              currentState.copyWith(validationErrors: failure.validatorErrors));
        } else {
          emit(RideCreateFailure(failure.message));
        }
      },
      (ride) => emit(RideCreateSuccess(ride)),
    );
  }
}
