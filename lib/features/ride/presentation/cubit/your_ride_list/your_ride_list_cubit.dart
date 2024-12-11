import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/domain/usecases/get_user_created_rides.dart';
import 'package:ride_now_app/features/ride/domain/usecases/get_user_joined_rides.dart';

part 'your_ride_list_state.dart';

class RideListCubit extends Cubit<RideListState> {
  final GetUserCreatedRides _getUserCreatedRides;
  final GetUserJoinedRides _getUserJoinedRides;
  RideListCubit({
    required GetUserCreatedRides getUserCreatedRides,
    required GetUserJoinedRides getUserJoinedRides,
  })  : _getUserJoinedRides = getUserJoinedRides,
        _getUserCreatedRides = getUserCreatedRides,
        super(RideListInitial());

  Future<void> getUserCreatedNJoinedRides() async {
    emit(RideListLoading());

    final joinedRides = await _getUserJoinedRides(NoParams());

    final createdRides = await _getUserCreatedRides(NoParams());

    joinedRides.fold((failure) => emit(RideListFailure(failure.message)),
        (joinedRides) {
      createdRides.fold((failure) => emit(RideListFailure(failure.message)),
          (createdRides) {
        emit(
          RidesDisplaySuccess(
            joinedRides: joinedRides,
            createdRides: createdRides,
          ),
        );
      });
    });
  }
}
