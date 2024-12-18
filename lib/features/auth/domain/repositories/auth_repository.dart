import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/common/entities/user.dart';
import 'package:ride_now_app/core/error/failure.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, User>> loginWithEmailPassword({
    required String email,
    required String password,
    required bool isRemember,
  });

  Future<Either<Failure, User>> getCurrentUser();
  //Logout Function
  Future<Either<Failure, String>> logout();
  Future<Either<Failure, String>> rememberMeStatusChecked();
  Future<Either<Failure, User>> registerUser({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String confirmPassword,
  });

  Future<Either<Failure, String>> getBroadcastingAuthToken(
      {required String channelName, required String socketId});
}
