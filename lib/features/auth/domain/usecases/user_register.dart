import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/common/entities/user.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/auth/domain/repositories/auth_repository.dart';

class UserRegister implements Usecase<User, UserRegisterParams> {
  final AuthRepository _authRepository;
  const UserRegister(this._authRepository);
  @override
  Future<Either<Failure, User>> call(UserRegisterParams params) {
    return _authRepository.registerUser(
      name: params.name,
      phone: params.phone,
      email: params.email,
      password: params.password,
      confirmPassword: params.confirmPassword,
    );
  }
}

class UserRegisterParams {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String confirmPassword;

  UserRegisterParams({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
}
