import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ride_now_app/core/common/entities/user.dart';
import 'package:ride_now_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ride_now_app/features/profile/domain/usecases/update_user_profile.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UpdateUserProfile _updateUserProfile;
  final AuthBloc _authBloc;
  ProfileCubit({
    required UpdateUserProfile updateUserProfile,
    required AuthBloc authBloc,
  })  : _updateUserProfile = updateUserProfile,
        _authBloc = authBloc,
        super(ProfileInitial());

  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? email,
    String? oldPassword,
    String? newPassword,
    File? profileImage,
  }) async {
    emit(ProfileUpdateLoading());
    final res = await _updateUserProfile(
      UpdateUserProfileParams(
        name: name,
        phone: phone,
        email: email,
        oldPassword: oldPassword,
        newPassword: newPassword,
        profileImage: profileImage,
      ),
    );

    res.fold(
        (failure) => emit(ProfileUpdateFailure(
            validationErrors: failure.validatorErrors,
            message: failure.message)), (user) {
      _authBloc.add(AuthUpdateUser(user));
      emit(ProfileUpdateSuccess(user));
    });
  }

  void initializeCubit() {
    emit(ProfileInitial());
  }
}
