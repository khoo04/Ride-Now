import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/common/entities/user.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/auth/domain/repositories/auth_repository.dart';

class UserLogin implements Usecase<User, UserLoginParams> {
  final AuthRepository _authRepository;
  const UserLogin(this._authRepository);

  @override
  Future<Either<Failure, User>> call(UserLoginParams params) {
    return _authRepository.loginWithEmailPassword(
      email: params.email,
      password: params.password,
      isRemember: params.isRemember,
    );
  }
}

class UserLoginParams {
  final String email;
  final String password;
  final bool isRemember;

  UserLoginParams({
    required this.email,
    required this.password,
    required this.isRemember,
  });
}
