import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/profile/domain/usecases/create_vehicle.dart';
import 'package:ride_now_app/features/profile/domain/usecases/delete_vehicle.dart';
import 'package:ride_now_app/features/profile/domain/usecases/get_user_vehicles.dart';
import 'package:ride_now_app/features/profile/domain/usecases/update_vehicle.dart';
import 'package:ride_now_app/features/ride/domain/entities/vehicle.dart';

part 'vehicle_event.dart';
part 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final GetUserVehicles _getUserVehicles;
  final CreateVehicle _createVehicle;
  final UpdateVehicle _updateVehicle;
  final DeleteVehicle _deleteVehicle;
  VehicleBloc({
    required GetUserVehicles getUserVehicles,
    required CreateVehicle createVehicle,
    required UpdateVehicle updateVehicle,
    required DeleteVehicle deleteVehicle,
  })  : _getUserVehicles = getUserVehicles,
        _createVehicle = createVehicle,
        _updateVehicle = updateVehicle,
        _deleteVehicle = deleteVehicle,
        super(VehicleInitial()) {
    on<FetchUserVehicles>(_fetchUserVehicles);
    on<CreateVehicleEvent>(_onCreateVehicle);
    on<UpdateVehicleEvent>(_onUpdateVehicle);
    on<DeleteVehicleEvent>(_onDeleteVehicle);
  }

  Future<void> _fetchUserVehicles(
      FetchUserVehicles event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());
    final res = await _getUserVehicles(NoParams());

    res.fold(
      (l) => emit(VehicleFailure(l.message)),
      (vehicles) => emit(VehicleDisplaySuccess(vehicles)),
    );
  }

  Future<void> _onCreateVehicle(
      CreateVehicleEvent event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());
    final res = await _createVehicle(CreateVehicleParams(
      vehicleRegistrationNumber: event.vehicleRegistrationNumber,
      manufacturer: event.manufacturer,
      model: event.model,
      seats: event.seats,
      averageFuelConsumptions: event.averageFuelConsumptions,
      vehicleTypeId: event.vehicleTypeId,
    ));

    res.fold(
      (failure) {
        if (failure.validatorErrors != null) {
          emit(VehicleRegisterFailure(failure.validatorErrors!));
        } else {
          emit(VehicleFailure(failure.message));
        }
      },
      (vehicle) => emit(VehicleRegisterSuccess(vehicle)),
    );
  }

  Future<void> _onUpdateVehicle(
      UpdateVehicleEvent event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());
    final res = await _updateVehicle(UpdateVehicleParams(
      vehicleId: event.vehicleId,
      vehicleRegistrationNumber: event.vehicleRegistrationNumber,
      manufacturer: event.manufacturer,
      model: event.model,
      seats: event.seats,
      averageFuelConsumptions: event.averageFuelConsumptions,
      vehicleTypeId: event.vehicleTypeId,
    ));

    res.fold(
      (failure) {
        if (failure.validatorErrors != null) {
          emit(VehicleRegisterFailure(failure.validatorErrors!));
        } else {
          emit(VehicleFailure(failure.message));
        }
      },
      (vehicle) => emit(VehicleRegisterSuccess(vehicle)),
    );
  }

  Future<void> _onDeleteVehicle(
      DeleteVehicleEvent event, Emitter<VehicleState> emit) async {
    emit(VehicleLoading());

    final res = await _deleteVehicle(DeleteVehicleParams(event.vehicleId));

    res.fold(
      (failure) => emit(VehicleFailure(failure.message)),
      (r) => emit(VehicleDeleteSuccess()),
    );
  }
}
