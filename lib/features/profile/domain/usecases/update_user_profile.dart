import 'dart:io';

import 'package:fpdart/src/either.dart';
import 'package:ride_now_app/core/common/entities/user.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/profile/domain/repositories/profile_repository.dart';

class UpdateUserProfile implements Usecase<User, UpdateUserProfileParams> {
  final ProfileRepository _profileRepository;
  const UpdateUserProfile(this._profileRepository);

  @override
  Future<Either<Failure, User>> call(UpdateUserProfileParams params) {
    return _profileRepository.updateUserProfile(
      name: params.name,
      phone: params.phone,
      email: params.email,
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
      profileImage: params.profileImage,
    );
  }
}

class UpdateUserProfileParams {
  final String? name;
  final String? phone;
  final String? email;
  final String? oldPassword;
  final String? newPassword;
  final File? profileImage;

  const UpdateUserProfileParams({
    this.name,
    this.phone,
    this.email,
    this.oldPassword,
    this.newPassword,
    this.profileImage,
  });
}
