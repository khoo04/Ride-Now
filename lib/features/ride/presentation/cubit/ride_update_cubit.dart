import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/profile/domain/usecases/get_user_vehicles.dart';
import 'package:ride_now_app/features/ride/domain/entities/place_details.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/entities/vehicle.dart';
import 'package:ride_now_app/features/ride/domain/usecases/get_ride_cost_suggestion.dart';
import 'package:ride_now_app/features/ride/domain/usecases/update_ride.dart';

part 'ride_update_state.dart';

class RideUpdateCubit extends Cubit<RideUpdateState> {
  final GetUserVehicles _getUserVehicles;
  final UpdateRide _updateRide;
  final GetRideCostSuggestion _getRideCostSuggestion;
  RideUpdateCubit(
      {required GetUserVehicles getUserVehicles,
      required UpdateRide updateRide,
      required GetRideCostSuggestion getRideCostSuggestion})
      : _getUserVehicles = getUserVehicles,
        _updateRide = updateRide,
        _getRideCostSuggestion = getRideCostSuggestion,
        super(const RideUpdateInitial());

  Future<void> initializeUpdateRide(Ride ride) async {
    emit(RideUpdatePageLoading());
    final res = await _getUserVehicles(NoParams());

    res.fold(
      (l) => emit(RideUpdateFailure(l.message)),
      (vehicles) =>
          emit(RideUpdateInitial(userVehicles: vehicles, rideToUpdate: ride)),
    );
  }

  Future<void> getLatestPriceSuggstion() async {
    if (state is! RideUpdateInitial) return;

    final currentState = state as RideUpdateInitial;

    final origin = currentState.origin ?? currentState.rideToUpdate!.origin;
    final destination =
        currentState.destination ?? currentState.rideToUpdate!.destination;
    final fuelConsumption =
        currentState.selectedVehicle?.averageFuelConsumption ??
            currentState.rideToUpdate!.vehicle.averageFuelConsumption;

    final res = await _getRideCostSuggestion(
      GetRideCostSuggestionParams(
        fromPlace: origin,
        toPlace: destination,
        fuelConsumptions: fuelConsumption,
      ),
    );

    res.fold(
      (l) => emit(RideUpdateFailure(l.message)),
      (price) => emit(currentState.copyWith(price: price)),
    );
  }

  void onChangeRideDetails({
    PlaceDetails? origin,
    PlaceDetails? destination,
    DateTime? departureTime,
    Vehicle? selectedVehicle,
    double? price,
  }) {
    if (state is! RideUpdateInitial) return;

    final currentState = state as RideUpdateInitial;
    emit(currentState.copyWith(
      origin: origin,
      destination: destination,
      departureTime: departureTime,
      selectedVehicle: selectedVehicle,
      price: price,
    ));
  }

  Future<void> onUpdateRide() async {
    if (state is! RideUpdateInitial) return;

    final currentState = state as RideUpdateInitial;

    if (currentState.rideToUpdate != null) {
      final res = await _updateRide(UpdateRideParams(
        rideId: currentState.rideToUpdate!.rideId,
        origin: currentState.origin,
        destination: currentState.destination,
        departureTime: currentState.departureTime,
        baseCost: currentState.price,
        vehicle: currentState.selectedVehicle,
      ));

      res.fold(
        (failure) {
          if (failure.validatorErrors != null) {
            emit(currentState.copyWith(
                validationErrors: failure.validatorErrors));
          } else {
            emit(RideUpdateFailure(failure.message));
          }
        },
        (ride) => emit(RideUpdateSuccess(ride)),
      );
    } else {
      emit(const RideUpdateFailure("Error: Lack of parameters"));
    }
  }
}
